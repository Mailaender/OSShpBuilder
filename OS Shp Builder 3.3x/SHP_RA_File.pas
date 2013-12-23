unit SHP_RA_File;

interface

uses Classes, SysUtils, SHP_File, Dialogs;

type
   //---------------------------------------------------------
   // File Header
   //---------------------------------------------------------

   TSHPTDHeader = record
      NumImages: word;    {Number of images}
      UnknownA: word;
      UnknownB: word;  {Unknown, possibly x, y, although the numbers are too high for that make sense}
      Width : word;
      Height: word;    {Width and Height of the images}
      UnknownC: longword;      {Offset for something}
   end;

   // Note: C has showed the following behaviour:
   // Pictures with 1 frame: Last byte of the file
   // Tanks, units: Offset for the declaration of one of the middle frames.
   // BuildUp animations: Offset to somewhere in the middle of the file.


   //---------------------------------------------------------
   // Frame Header
   //---------------------------------------------------------

   TSHPTDOffsetUnit = record
      Offset:   longword;  {Offset of image in file: this is 3 bytes long}
      Compression: byte;
      ReOffset: longword; // 0 for 80h, Offset from another frame for 40h, number of frame for 20h (also 3 bytes long).
      CompressionExtra: byte;
   end;

   //---------------------------------------------------------
   // FrameHeaders[]
   //---------------------------------------------------------

   TSHPTDOffsets = array of TSHPTDOffsetUnit;

   //---------------------------------------------------------
   // Frame Data
   //---------------------------------------------------------

   TSHPTDFrame = record
      Data: TFrameImage;
   end;

   //---------------------------------------------------------
   // Class Shp TD
   //---------------------------------------------------------

   C_SHPTD = class
   public
      IsValid: boolean;
      // constructors and destructors
      destructor Destroy; override;
      // I/O
      procedure Load(const Filename: string);
      function getSHP(): TSHP;
      function saveSHP(const SHP: TSHP; const Filename: string): boolean;
   private
      NumImages: word;
      Width:     word;
      Height:    word;
      Frames:    array of TSHPTDFrame;
      FileSize:  longword;
      Name:      string;
      FrameHeaders: TSHPTDOffsets;
      // Offset related.
      function FindNextRAOffsetFrom(const FrameHeaders: TSHPTDOffsets; Init, Last: integer): longint;
      function FindFrameSize(const FrameHeaders: TSHPTDOffsets; Frame: integer; Filesize: integer): integer;
      function HuntMyOffset(const Offset: word; const MyFrame: integer; const FrameHeaders: TSHPTDOffsets): integer;
   end;



implementation

{$D+}

uses SHP_RA_Code, SHP_Engine;

//---------------------------------------------------------
// Destructor
//---------------------------------------------------------

destructor C_SHPTD.Destroy;
var
   f,l: integer;
begin
   // Dispose frames.
   for f := Low(Frames) to High(Frames) do
   begin
      for l := Low(Frames[f].Data) to High(Frames[f].Data) do
      begin
         SetLength(Frames[f].Data[l],0);
      end;
      SetLength(Frames[f].Data,0);
   end;
   SetLength(Frames,0);
   // Dispose frame headers.
   SetLength(FrameHeaders,0);
   // Dispose everything else.
   inherited Destroy;
end;

//---------------------------------------------------------
// Load Shp TD from disk.
//---------------------------------------------------------

procedure C_SHPTD.Load(const Filename: string);
var
   f:    TStream;
   PData, PCurrentData, PNewData, PWriteData, PFrame: PByte;
   Counter: word;
   DataBuffers: array of TDatabuffer;
   CurrentDB: TDatabuffer;
   ReFrame: integer; // Base frame for Fmt40/20
   x, y: longword;
   Size, BufferSize: longword;
begin
   IsValid := False;

   // Load file in memory
   Name := ExtractFileName(Filename);
   if not FileExists(Filename) then
      exit;

   F := TFileStream.Create(Filename, fmOpenRead);
   FileSize := F.Size;
   Getmem(PData, FileSize);
   try
      F.Read(PData^, FileSize);
   except
      F.Free;
      FreeMem(PData);
      exit;
   end;
   PCurrentData := PData;
   F.Free;

   // Reading..
   //          Frame Count
   NumImages := word(PWord(PCurrentData)^);

   if (NumImages = 0) then
   begin
      FreeMem(PData);
      exit;
   end;

   //          A, B
   Inc(PCurrentData, 6);

   //          Frame Width
   Width := word(PWord(PCurrentData)^);
   if (Width = 0) then
   begin
      FreeMem(PData);
      exit;
   end;
   Inc(PCurrentData, 2);

   //          Frame Height
   Height := word(PWord(PCurrentData)^);
   if (Height = 0) then
   begin
      FreeMem(PData);
      exit;
   end;

   //          C
   Inc(PCurrentData, 6);


   //          Frame Headers
   SetLength(FrameHeaders, NumImages);
   for Counter := 0 to (NumImages - 1) do
   begin
      FrameHeaders[Counter].Offset := (PCurrentData^);
      Inc(PCurrentData, 1);
      FrameHeaders[Counter].Offset := FrameHeaders[Counter].Offset + (PCurrentData^) shl 8;
      Inc(PCurrentData, 1);
      FrameHeaders[Counter].Offset := FrameHeaders[Counter].Offset + (PCurrentData^) shl 16;
      Inc(PCurrentData, 1);

      FrameHeaders[Counter].Compression := PCurrentData^;
      Inc(PCurrentData, 1);

      FrameHeaders[Counter].ReOffset := (PCurrentData^);
      Inc(PCurrentData, 1);
      FrameHeaders[Counter].ReOffset := FrameHeaders[Counter].ReOffset + (PCurrentData^) shl 8;
      Inc(PCurrentData, 1);
      FrameHeaders[Counter].ReOffset := FrameHeaders[Counter].ReOffset + (PCurrentData^) shl 16;
      Inc(PCurrentData, 1);

      FrameHeaders[Counter].CompressionExtra := PCurrentData^;
      Inc(PCurrentData, 1);
   end;


   // Copy encoded frames to DataBuffers[]
   SetLength(DataBuffers, NumImages);
   for counter := 0 to (NumImages - 1) do
   begin
      SetLength(DataBuffers[counter], Width * Height);
      Size := FindFrameSize(FrameHeaders, Counter, Filesize);
      PCurrentData := PData;
      Inc(PCurrentData, FrameHeaders[Counter].Offset);
      Dec(size);
      for x := 0 to Size do
      begin
         DataBuffers[Counter, x] := PCurrentData^;
         Inc(PCurrentData);
      end;
   end;
   FreeMem(PData);

   //--------------------------------------
   // Decoding frames
   for Counter := 0 to (NumImages - 1) do
   begin
      // The behaviour now depends on the compression.
      if (FrameHeaders[Counter].Compression = $80) then
      begin
         // ============== FMT 80 ==============
         // Source
         PFrame := PByte(DataBuffers[counter]);
         // Destination
         GetMem(PNewData, Width * Height);
         PCurrentData := PNewData;
         // Decode Fmt80
         try
            Buffersize := Decode80d(PFrame, PCurrentData, Width * Height);
         except
            ShowMessage('Error when decoding a FMT80 frame [' + IntToStr(Counter) + ']! Please, report it at the OS SHP Builder Forums.');
            FreeMem(PNewData);
            FreeMem(PData);
            exit;
         end;
         // Copy decoded frame to DataBuffers.
         PCurrentData := PNewData;
         for x := 0 to Buffersize - 1 do
         begin
            DataBuffers[Counter, x] := PCurrentData^;
            Inc(PCurrentData);
         end;
         FreeMem(PNewData);
      end
      else if (FrameHeaders[Counter].Compression = $40) then
      begin
         // ============== FMT 40 ==============
         // Base frame
         ReFrame      := HuntMyOffset(FrameHeaders[Counter].ReOffset, Counter, FrameHeaders);
         PCurrentData := PByte(DataBuffers[ReFrame]);
         // Destination
         GetMem(PNewData, Width * Height);
         PWriteData := PNewData;
         // Source
         PFrame     := PByte(DataBuffers[counter]);
         // Decode Fmt40
         try
            Buffersize := Decode40Tri(PFrame, PCurrentData, PWriteData);
         except
            ShowMessage('Error when decoding a FMT40 frame [' + IntToStr(Counter) + ']! Please, report it at the OS SHP Builder Forums.');
            FreeMem(PNewData);
            FreeMem(PData);
            exit;
         end;
         // Copy decoded frame to DataBuffers[]
         SetLength(DataBuffers[Counter], Buffersize);
         PWriteData := PNewData;
         for x := 0 to Buffersize - 1 do
         begin
            DataBuffers[Counter, x] := PWriteData^;
            Inc(PWriteData);
         end;
         FreeMem(PNewData);
      end
      else if (FrameHeaders[Counter].Compression = $20) then
      begin
         // ============== FMT 20 ==============
         // Base frame
         ReFrame      := Counter - 1;//FrameHeaders[Counter].ReOffset;
         PCurrentData := PByte(DataBuffers[ReFrame]);
         // Destination
         GetMem(PNewData, Width * Height);
         PWriteData := PNewData;
         // Source
         PFrame     := PByte(DataBuffers[counter]);
         // Decode Fmt20
         try
            Buffersize := Decode40Tri(PFrame, PCurrentData, PWriteData);
         except
            ShowMessage('Error when decoding a FMT20 frame [' + IntToStr(Counter) + ']! Please, report it at the OS SHP Builder Forums.');
            FreeMem(PNewData);
            FreeMem(PData);
            exit;
         end;
         // Copy decoded frame to DataBuffers[]
         SetLength(DataBuffers[Counter], Buffersize);
         PWriteData := PNewData;
         for x := 0 to Buffersize - 1 do
         begin
            DataBuffers[Counter, x] := PWriteData^;
            Inc(PWriteData);
         end;
         FreeMem(PNewData);
      end
      else if (FrameHeaders[Counter].Compression <> 0) then
      begin
         // ============== Unknown ==============
         // Invalid File.
         SetLength(Databuffers,0);
         exit;
      end;
   end;
   // Create full Frames.
   SetLength(Frames, NumImages + 1);
   SetLength(Frames[0].Data, 0, 0);
   for counter := 1 to NumImages do
   begin
      SetLength(Frames[counter].Data, Width, Height);
      for x := 0 to (Width - 1) do
      begin
         for y := 0 to (Height - 1) do
         begin
            Frames[counter].Data[x, y] := DataBuffers[counter - 1, (y * Width) + x];
         end;
      end;
   end;

   PCurrentData := nil;
   SetLength(Databuffers,0);
   IsValid      := True;
end;

//---------------------------------------------------------
// Get usable Shp.
// Note: biggest part is to determine GameType and ShpType.
//---------------------------------------------------------

function C_SHPTD.getSHP(): TSHP;
var
   Frame, x, y: longword;
   CountTD, CountRA1: longword;
   Found: boolean;
begin
   //--------------------------------------
   // Header.
   Result.Header.Width     := Width;
   Result.Header.Height    := Height;
   Result.Header.NumImages := NumImages;

   //--------------------------------------
   // Frames.
   SetLength(Result.Data, NumImages + 1);
   for Frame := 1 to NumImages do
   begin
      // Header.
      Result.Data[Frame].Header_Image.x  := 0;
      Result.Data[Frame].Header_Image.y  := 0;
      Result.Data[Frame].Header_Image.cx := Width;
      Result.Data[Frame].Header_Image.cy := Height;
      Result.Data[Frame].Header_Image.compression := FrameHeaders[Frame - 1].Compression;

      // Data.
      SetLength(Result.Data[Frame].FrameImage, Width, Height);
      for x := 0 to (Width - 1) do
         for y := 0 to (Height - 1) do
            Result.Data[Frame].FrameImage[x, y] := Frames[Frame].Data[x, y];
   end;

   //--------------------------------------
   // Game and Type

   // Defaults
   Result.SHPType := stUnit;
   Result.SHPGame := sgTD;

   FindSHPType(Name, Result);

   // Fast cameo checkup
   if (Result.SHPType = stCameo) then
   begin
      if (Result.Data[1].FrameImage[0, 0] = 193) then
         Result.SHPGame := sgTD
      else if (Result.Data[1].FrameImage[0, 0] = 15) then
         Result.SHPGame := sgRA1;
      exit;
   end
   else if (Result.SHPType <> stAnimation) then
   begin
      // Determine GameType on Remappable Colors
      CountTD  := 0;
      CountRA1 := 0;
      // Get first non-empty frame.
      Frame    := 1;
      Found    := False;
      while (Frame <= NumImages) and (not Found) do
      begin
         if (FindFrameSize(FrameHeaders, Frame - 1, Filesize) > 0) then
         begin
            Found := True;
         end
         else
            Inc(Frame);
      end;
      // Count remmapables colors.
      for x := 0 to Width - 1 do
         for y := 0 to Height - 1 do
         begin
            if (Result.Data[Frame].FrameImage[x, y] > 79) and
               (Result.Data[Frame].FrameImage[x, y] < 96) then
               Inc(CountRA1)
            else if (Result.Data[Frame].FrameImage[x, y] > 175) and
               (Result.Data[Frame].FrameImage[x, y] < 192) then
               Inc(CountTD);
         end;
      // Now, we do the comparison.
      if (CountRA1 > CountTD) then
         Result.SHPGame := sgRA1
      else if (CountTD > CountRA1) then
         Result.SHPGame := sgTD;
   end;

   if extractfileext(Name) = '.des' then
   begin
      Result.SHPType := stdes;
      Result.SHPGame := sgTD;
   end
   else if extractfileext(Name) = '.tem' then
   begin
      Result.SHPType := sttem;
      Result.SHPGame := sgRA1;
   end
   else if extractfileext(Name) = '.sno' then
   begin
      Result.SHPType := stsno;
      Result.SHPGame := sgRA1;
   end
   else if extractfileext(Name) = '.win' then
   begin
      Result.SHPType := stwin;
      Result.SHPGame := sgTD;
   end
   else if extractfileext(Name) = '.int' then
   begin
      Result.SHPType := stint;
      Result.SHPGame := sgRA1;
   end;
end;

//---------------------------------------------------------
// Save Shp TD on disk.
//---------------------------------------------------------

function C_SHPTD.saveSHP(const SHP: TSHP; const Filename: string): boolean;
var
   F:     file;
   Written: integer;
   MainHeader : TSHPTDHeader;
   Frame, x, y: longword;
   Dummy: longword;
   FrameHeaders: TSHPTDOffsets;
   CurrentOffset: longword;
   CurrentDB: TDatabuffer;
   Databuffer: array of TDatabuffer;
   PSource, PDest, PNewData: PByte;
   EncSize : longword;
   v:Byte;
begin
   // Not saved yet.
   Result := False;

   //--------------------------------------
   // Load file
   Assign(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   //--------------------------------------
   // File Header
   MainHeader.NumImages := SHP.Header.NumImages;
   MainHeader.UnknownA := 0;
   MainHeader.UnknownB := 0;
   MainHeader.Width := SHP.Header.Width;
   MainHeader.Height := SHP.Header.Height;

   //--------------------------------------
   // Frame Headers
   SetLength(FrameHeaders, SHP.Header.NumImages);
   SetLength(Databuffer, SHP.Header.NumImages);
   CurrentOffset := 14 + ((SHP.Header.NumImages + 2) * 8); //(sizeof(TSHPTDOffsetUnit)-2));

   for Frame := 1 to SHP.Header.NumImages do
   begin
      //--------------------------------------
      // All Frames are encoded in Fmt80.
      FrameHeaders[Frame - 1].Offset := CurrentOffset;
      FrameHeaders[Frame - 1].Compression := $80;

      SetLength(CurrentDB, SHP.Header.Width * SHP.Header.Height);
      for x := 0 to SHP.Header.Width - 1 do
         for y := 0 to SHP.Header.Height - 1 do
            CurrentDB[(y * SHP.Header.Width) + x] := SHP.Data[Frame].FrameImage[x, y];

      // Source
      SetLength(Databuffer[Frame - 1], SHP.Header.Width * SHP.Header.Height);
      PSource := PByte(CurrentDB);

      // Destination
      GetMem(PNewData, SHP.Header.Width * SHP.Header.Height);
      PDest    := PNewData;

      // Encode Fmt80
      EncSize := Encode80(PSource, PDest, SHP.Header.Width * SHP.Header.Height);
      CurrentOffset := CurrentOffset + EncSize;

      // Copy encoded data to DataBuffers
      SetLength(Databuffer[Frame - 1], EncSize);
      PDest := PNewData;
      for x := 0 to EncSize - 1 do
      begin
         Databuffer[Frame - 1, x] := PDest^;
         Inc(PDest);
      end;
      FreeMem(PNewData);
   end;

   //--------------------------------------
   // Set Unknown field C.
   if SHP.Header.NumImages > 1 then
      MainHeader.UnknownC := 0
   else
   begin
      MainHeader.UnknownC := CurrentOffset;
   end;

   //--------------------------------------
   // Writing ..
   //   File header
   Blockwrite(F, MainHeader, 14, Written);

   //   Frame headers
   Dummy := 0;
   for Frame := 0 to SHP.Header.NumImages - 1 do
   begin
      Blockwrite(F, FrameHeaders[Frame].Offset, 3, Written);
      Blockwrite(F, FrameHeaders[Frame].Compression, 1, Written);
      Blockwrite(F, Dummy, 4, Written);
   end;

   //   File size
   Blockwrite(F, CurrentOffset, 4, Written);

   //   Zero
   Blockwrite(F, Dummy, 4, Written);
   Blockwrite(F, Dummy, 4, Written);
   Blockwrite(F, Dummy, 4, Written);

   //   Encoded frames
   for Frame := 0 to SHP.Header.NumImages - 1 do
   begin
      for x := Low(Databuffer[Frame]) to High(Databuffer[Frame]) do
      begin
         Blockwrite(F, Databuffer[Frame, x], sizeof(byte), Written);
      end;
   end;
   CloseFile(F);
end;


//---------------------------------------------------------
// Find Next Offset
//---------------------------------------------------------

function C_SHPTD.FindNextRAOffsetFrom(const FrameHeaders: TSHPTDOffsets; Init, Last: integer): longint;
begin
   Result := 0;
   Inc(Last);
   while (Result = 0) and (Init < Last) do
   begin
      Result := FrameHeaders[Init].offset;
      Inc(Init);
   end;
end;

//---------------------------------------------------------
// Find Frame Size
//---------------------------------------------------------

function C_SHPTD.FindFrameSize(const FrameHeaders: TSHPTDOffsets; Frame: integer; Filesize: integer): integer;
var
   Next: integer;
begin
   Next := FindNextRAOffsetFrom(FrameHeaders, Frame + 1, High(FrameHeaders));
   if Next <> 0 then
      Result := Next - FrameHeaders[Frame].Offset
   else
      Result := FileSize - FrameHeaders[Frame].Offset;
end;

//---------------------------------------------------------
// Find index of base frame.
//---------------------------------------------------------

function C_SHPTD.HuntMyOffset(const Offset: word; const MyFrame: integer; const FrameHeaders: TSHPTDOffsets): integer;
var
   Counter: integer;
begin
   Counter := MyFrame;
   while Counter > -1 do
   begin
      if Offset = FrameHeaders[Counter].Offset then
      begin
         Result := Counter;
         exit;
      end;
      Dec(Counter);
   end;
   Result := Counter;
end;

end.
