 // SHP_ENGINE.PAS
 // By Banshee & Stucuk

unit Shp_Engine;

interface

uses
   Windows, Dialogs, SysUtils, Classes, ExtCtrls, Shp_File, Shp_Engine_Image, Palette, Graphics;

const
   SHP_ENGINE_VER = '2.91';
   SHP_ENGINE_BY  = 'Banshee & Stucuk';
 // OS SHP Builder 3.36:
 //- Remappable detection.
 //- Compression 2 support.
 // OS SHP Builder 3.35:
 //- Smarter SHP Type auto detect.
 //- Support for SHPGame.
 //- Better documentation and archived stuff deleted.
 //- Files are now closed if they are invalid SHP (TS).

function LoadSHP(const Filename: string; var SHP: TSHP): boolean;
function LoadSHPWithLog(Filename: string; var SHP: TSHP): boolean;
function LoadSHPOnRescue(Filename: string; var SHP: TSHP): boolean;
function LoadSHPSafe(Filename: string; var SHP: TSHP): boolean;
function LoadSHPSupraFast(Filename: string; var SHP: TSHP): boolean;
function WorkOutOffset(SHP: TSHP; Frame: integer): integer;
procedure SaveSHP(const Filename: string; var SHP: TSHP); overload;
procedure SaveSHPCompressed(const Filename: string; var SHP: TSHP); overload;
procedure SaveSHPUncompressed(const Filename: string; var SHP: TSHP); overload;
procedure SaveSHPHalfCompression(const Filename: string; var SHP: TSHP); overload;
procedure CompressFrameImage(SHP: TSHP; Frame: integer; var SHPData: TSHPData);
procedure CompressFrameImages(var SHP: TSHP);
procedure CreateFrameImage(var SHP: TSHP; const Frame: integer);
function CreateFrameImages(var SHP: TSHP): boolean;
function NewSHP(var SHP: TSHP; const TotalFrames, Width, Height: integer): boolean;
function GetSHPType(SHP: TSHP): string;
function GetSHPGame(SHP: TSHP): string;
procedure FindSHPType(var SHP: TSHP); overload;
procedure FindSHPType(const Filename: string; var SHP: TSHP); overload;
procedure FindSHPGame(var SHP: TSHP);
function IsSHPRemmapable(const SHPType : TSHPType): boolean;
procedure FindSHPRadarColors(const _SHP: TSHP; _Palette: TPalette);
procedure FindSHPFrameRadarColor(const _SHP: TSHP; _Frame: integer; _Palette: TPalette);

implementation

function FindNextOffsetFrom(const SHP: TSHP; Init, Last: integer): longint;
begin
   Result := 0;
   Inc(Last);
   while (Result = 0) and (Init < Last) do
   begin
      Result := SHP.Data[Init].Header_Image.offset;
      Inc(Init);
   end;
end;

function LoadSHP(const Filename: string; var SHP: TSHP): boolean;
var
   f:      TStream;
   x, c: integer;
   Databuffer: TDatabuffer;
   PDatabuffer, PCurrentData: PByte;
   Image_Size: integer;
   NextOffset: longint;
begin
   Result := False;
   F      := TFileStream.Create(Filename, fmOpenRead); // Open file
   SHP.SHPType := stUnit;
   SHP.SHPGame := sgTS;

   F.Read(SHP.Header, Sizeof(SHP.Header));

   // 3.34: Check if it's a valid SHP file.
   if SHP.Header.A <> 0 then
   begin // 3.35: Close invalid files before leave
      F.Free;
      exit;
   end;

   // 3.36: Verify Height and Width:
   if (SHP.Header.Width = 0) or (SHP.Header.Height = 0) then
   begin
      ShowMessage('This SHP file is null and it has no content. Start a new image instead.');
      F.Free;
      exit;
   end;

   setlength(SHP.Data, SHP.header.NumImages + 1);
   // Set the Data array to have SHP.header.NumImages+1 records

   FindSHPType(Filename, SHP);
   // check extension to see if its actualy a TEM or SNO
   if extractfileext(Filename) = '.tem' then
      SHP.SHPType := sttem
   else if extractfileext(Filename) = '.sno' then
      SHP.SHPType := stsno
   else if extractfileext(Filename) = '.urb' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := sturb;
   end
   else if extractfileext(Filename) = '.ubn' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stnewurb;
   end
   else if extractfileext(Filename) = '.lun' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stlun;
   end
   else if extractfileext(Filename) = '.des' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stdes;
   end;

   for x := 1 to SHP.header.NumImages do // Load Image Headers
      F.Read(SHP.Data[x].header_image, Sizeof(THeader_Image));

   // Read and decode each image from the file
   for x := 1 to SHP.header.NumImages do
   begin
      // Clear Buffers
      setlength(SHP.Data[x].Databuffer, 0);
      setlength(Databuffer, 0);
      // Does it really reads the frame?
      if SHP.Data[x].header_image.offset <> 0 then
      begin
         // Now it checks the compression:
         if (SHP.Data[x].header_image.compression = 3) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);
            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;
               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               F.Seek(SHP.Data[x].header_image.offset, soFromBeginning);
               // Read byte per byte from one offset to the other.
               GetMem(PDataBuffer, Image_Size);
               F.Read(PDatabuffer^, Image_Size);
               PCurrentData := PDataBuffer;
               for c := 0 to Image_Size - 1 do
               begin
                  Databuffer[c] := PCurrentData^;
                  Inc(PCurrentData);
               end;
               // decode it
               Decode3(Databuffer, SHP.Data[x].Databuffer,
                  SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               F.Seek(SHP.Data[x].header_image.offset, soFromBeginning);
               Image_Size := F.Size - F.Position - 1;
               setlength(Databuffer, Image_Size);
               GetMem(PDatabuffer, Image_Size);
               if Image_Size > 0 then
               begin
                  F.Read(PDatabuffer^, Image_Size);
               end;
               // Copy PDatabuffer bytes into SHP Databuffer
               PCurrentData := PDataBuffer;
               for c := 0 to Image_Size - 1 do
               begin
                  Databuffer[c] := PCurrentData^;
                  Inc(PCurrentData);
               end;
               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               // decode it
               Decode3(Databuffer, SHP.Data[x].Databuffer,
                  SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         // Compression 2
         else if (SHP.Data[x].header_image.compression = 2) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);
            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;
               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               F.Seek(SHP.Data[x].header_image.offset, soFromBeginning);
               // Read byte per byte from one offset to the other.
               GetMem(PDataBuffer, Image_Size);
               F.Read(PDatabuffer^, Image_Size);
               PCurrentData := PDataBuffer;
               for c := 0 to Image_Size - 1 do
               begin
                  Databuffer[c] := PCurrentData^;
                  Inc(PCurrentData);
               end;
               // decode it
               Decode2(Databuffer, SHP.Data[x].Databuffer, SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               F.Seek(SHP.Data[x].header_image.offset, soFromBeginning);
               Image_Size := F.Size - F.Position - 1;
               setlength(Databuffer, Image_Size);
               GetMem(PDatabuffer, Image_Size);
               if Image_Size > 0 then
               begin
                  F.Read(PDatabuffer^, Image_Size);
               end;
               // Copy PDatabuffer bytes into SHP Databuffer
               PCurrentData := PDataBuffer;
               for c := 0 to Image_Size - 1 do
               begin
                  Databuffer[c] := PCurrentData^;
                  Inc(PCurrentData);
               end;
               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               // decode it
               Decode2(Databuffer, SHP.Data[x].Databuffer,
                  SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         else  // Compression 1
         begin
            Image_Size := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;
            // Set the lengths of the data buffers
            setlength(SHP.Data[x].Databuffer, Image_Size);
            F.Seek(SHP.Data[x].header_image.offset, soFromBeginning);
            // Read byte per byte from one offset to the other.
            GetMem(PDatabuffer, Image_Size);
            F.Read(PDataBuffer^, Image_Size);
            PCurrentData := PDataBuffer;
            for c := 0 to Image_Size - 1 do
            begin
               SHP.Data[x].Databuffer[c] := PCurrentData^;
               Inc(PCurrentData);
            end;
         end;
         FreeMem(PDatabuffer);
      end;
   end;
   F.Free;
   Result := True;

   // Final check of SHP game
   if (SHP.SHPType = stUnit) or (SHP.SHPType = stBuilding) or
      (SHP.SHPType = stBuildAnim) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) then
      FindSHPGame(SHP);
end;

function LoadSHPWithLog(Filename: string; var SHP: TSHP): boolean;
var
   f:      file;
   Read, x, c: integer;
   colour: byte;
   Databuffer, Databuffer2: TDatabuffer;
   Image_Size: integer;
   NextOffset: longint;
   L:      Text;
begin
   Result := False;

   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?

   AssignFile(L, extractfiledir(ParamStr(0)) + '/openlog.txt');
   Rewrite(L);

   SHP.SHPType := stUnit;
   SHP.SHPGame := sgTS;

   BlockRead(F, SHP.Header, Sizeof(SHP.Header)); // Read Header

   // 3.4: Check if it's a valid SHP file.
   if SHP.Header.A <> 0 then
   begin
      Close(L);
      CloseFile(F);
      exit;
   end;

   // 3.36: Verify Height and Width:
   if (SHP.Header.Width = 0) or (SHP.Header.Height = 0) then
   begin
      ShowMessage('This SHP file is null and it has no content. Start a new image instead.');
      Close(L);
      CloseFile(F);
      exit;
   end;

   setlength(SHP.Data, SHP.header.NumImages + 1);
   // Set the Data array to have SHP.header.NumImages+1 records

   FindSHPType(Filename, SHP);
   // check extention to see if its actualy a TEM or SNO
   if extractfileext(Filename) = '.tem' then
      SHP.SHPType := sttem
   else if extractfileext(Filename) = '.sno' then
      SHP.SHPType := stsno
   else if extractfileext(Filename) = '.urb' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := sturb;
   end
   else if extractfileext(Filename) = '.ubn' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stnewurb;
   end
   else if extractfileext(Filename) = '.lun' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stlun;
   end
   else if extractfileext(Filename) = '.des' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stdes;
   end;

   for x := 1 to SHP.header.NumImages do // Load Image Headers
      BlockRead(F, SHP.Data[x].header_image, Sizeof(THeader_Image));


   // Read and decode each image from the file
   for x := 1 to SHP.header.NumImages do
   begin

      // Clear Buffers
      setlength(SHP.Data[x].Databuffer, 0);
      setlength(Databuffer, 0);
      setlength(Databuffer2, 0);

      // Does it really reads the frame?
      if SHP.Data[x].header_image.offset <> 0 then
      begin

         // Now it checks the compression:
         if (SHP.Data[x].header_image.compression = 3) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);

            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Compression: 3');

               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               // Read byte by byte from one offset to the other.
               for c := 1 to Image_Size do
               begin
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[c - 1] := colour;
               end;

               // decode it
               Decode3(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image
               while not EOF(F) do
               begin
                  Inc(Image_Size);
                  setlength(Databuffer, Image_Size);
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[Image_Size - 1] := colour;
               end;

               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Compression: 3');
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               // decode it
               Decode3(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         // Compression 2
         else if (SHP.Data[x].header_image.compression = 2) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);

            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Compression: 3');

               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               // Read byte by byte from one offset to the other.
               for c := 1 to Image_Size do
               begin
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[c - 1] := colour;
               end;

               // decode it
               Decode2(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image
               while not EOF(F) do
               begin
                  Inc(Image_Size);
                  setlength(Databuffer, Image_Size);
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[Image_Size - 1] := colour;
               end;

               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Compression: 3');
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               // decode it
               Decode2(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         else  // Compression 1
         begin
            Image_Size := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;

            Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
            Writeln(L);
            writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
            writeln(L, 'Compression: 1');
            writeln(L, 'Image Size: ', Image_Size);
            writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
               SHP.Data[x].header_image.cy);
            Writeln(L);

            // Set the lengths of the data buffers
            setlength(SHP.Data[x].Databuffer, Image_Size + 1);
            setlength(Databuffer2, Image_Size + 1);

            Seek(F, SHP.Data[x].header_image.offset);
            // Goto the Line of the file that contains the start of the image

            // Read byte by byte from one offset to the other.
            for c := 1 to Image_Size do
            begin
               BlockRead(F, colour, Sizeof(byte), Read);
               Databuffer2[c - 1] := colour;
            end;
         end;
      end;

      // Set the shp's databuffer to the result after decompression
      SHP.Data[x].Databuffer := Databuffer2;
   end;

   Close(L);
   CloseFile(F);

   Result := True;

   // Final check of SHP game
   if (SHP.SHPType = stUnit) or (SHP.SHPType = stBuilding) or
      (SHP.SHPType = stBuildAnim) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) then
      FindSHPGame(SHP);
end;

// 3.3: Failen idea to restore screwed up files.. hidden
function LoadSHPOnRescue(Filename: string; var SHP: TSHP): boolean;
var
   f:      file;
   Read, x, c: integer;
   colour: byte;
   Databuffer, Databuffer2: TDatabuffer;
   Image_Size: integer;
   NextOffset: longint;
   LastOffset, LastSize, Difference: longint;
   L:      Text;
begin
   Result := False;

   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?

   AssignFile(L, extractfiledir(ParamStr(0)) + '/openlog.txt');
   Rewrite(L);

   SHP.SHPType := stUnit;
   SHP.SHPGame := sgTS;

   BlockRead(F, SHP.Header, Sizeof(SHP.Header)); // Read Header

   // 3.4: Check if it's a valid SHP file.
   if SHP.Header.A <> 0 then
   begin
      Close(L);
      CloseFile(F);
      exit;
   end;

   // 3.36: Verify Height and Width:
   if (SHP.Header.Width = 0) or (SHP.Header.Height = 0) then
   begin
      ShowMessage('This SHP file is null and it has no content. Start a new image instead.');
      Close(L);
      CloseFile(F);
      exit;
   end;

   setlength(SHP.Data, SHP.header.NumImages + 1);
   // Set the Data array to have SHP.header.NumImages+1 records

   FindSHPType(Filename, SHP);
   // check extention to see if its actualy a TEM or SNO
   if extractfileext(Filename) = '.tem' then
      SHP.SHPType := sttem
   else if extractfileext(Filename) = '.sno' then
      SHP.SHPType := stsno
   else if extractfileext(Filename) = '.urb' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := sturb;
   end
   else if extractfileext(Filename) = '.ubn' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stnewurb;
   end
   else if extractfileext(Filename) = '.lun' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stlun;
   end
   else if extractfileext(Filename) = '.des' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stdes;
   end;

   for x := 1 to SHP.header.NumImages do // Load Image Headers
      BlockRead(F, SHP.Data[x].header_image, Sizeof(THeader_Image));

   // Reset special rescue values
   LastOffset := 0;
   LastSize   := 0;

   // Read and decode each image from the file
   x := 1;
   while (x <= SHP.header.NumImages) do
   begin

      // Clear Buffers
      setlength(SHP.Data[x].Databuffer, 0);
      setlength(Databuffer, 0);
      setlength(Databuffer2, 0);

      // Does it really reads the frame?
      if SHP.Data[x].header_image.offset <> 0 then
      begin

         // Now it checks the compression:
         if (SHP.Data[x].header_image.compression = 3) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);

            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               // This condition should never happen, but it does
               // with some OS SHP Builder 3.x files (before 3.3)
               if NextOffset < LastOffset then
               begin
                  Difference := NextOffset - SHP.Data[x].Header_Image.Offset;
                  SHP.Data[x].Header_Image.Offset := LastOffset + LastSize;
                  NextOffset := SHP.Data[x].Header_Image.Offset + Difference;
               end;
               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Last Offset: ', LastOffset);
               writeln(L, 'Next Offset: ', NextOffset);
               writeln(L, 'Compression: 3');

               LastOffset := SHP.Data[x].Header_Image.Offset;

               // ImageSize calculation.
               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;

               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'Last Size: ', LastSize);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               LastSize := Image_Size;

               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               // Read byte by byte from one offset to the other.
               for c := 1 to Image_Size do
               begin
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[c - 1] := colour;
               end;

               // decode it
               Decode3(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               if SHP.Data[x].Header_Image.offset < LastOffset then
               begin
                  SHP.Data[x].header_image.offset := LastOffset + LastSize;
               end;
               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               while not EOF(F) do
               begin
                  Inc(Image_Size);
                  setlength(Databuffer, Image_Size);
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[Image_Size - 1] := colour;
               end;

               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Last Offset: ', LastOffset);
               writeln(L, 'Compression: 3');
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'Last Size: ', LastSize);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               LastSize := Image_Size;

               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               // decode it
               Decode3(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         else if (SHP.Data[x].header_image.compression = 2) then
         begin
            // Find next offset
            NextOffset := FindNextOffsetFrom(SHP, x + 1, SHP.Header.NumImages);

            if NextOffset <> 0 then
               // The big deal: How to detect the image size properly
            begin
               // This condition should never happen, but it does
               // with some OS SHP Builder 3.x files (before 3.3)
               if NextOffset < LastOffset then
               begin
                  Difference := NextOffset - SHP.Data[x].Header_Image.Offset;
                  SHP.Data[x].Header_Image.Offset := LastOffset + LastSize;
                  NextOffset := SHP.Data[x].Header_Image.Offset + Difference;
               end;
               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Last Offset: ', LastOffset);
               writeln(L, 'Next Offset: ', NextOffset);
               writeln(L, 'Compression: 3');

               LastOffset := SHP.Data[x].Header_Image.Offset;

               // ImageSize calculation.
               Image_Size := NextOffset - SHP.Data[x].Header_Image.Offset;

               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'Last Size: ', LastSize);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               LastSize := Image_Size;

               // Set the lengths of the data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer, Image_Size);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               // Read byte by byte from one offset to the other.
               for c := 1 to Image_Size do
               begin
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[c - 1] := colour;
               end;

               // decode it
               Decode2(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end
            else
            begin
               Image_Size := 0;
               if SHP.Data[x].Header_Image.offset < LastOffset then
               begin
                  SHP.Data[x].header_image.offset := LastOffset + LastSize;
               end;
               Seek(F, SHP.Data[x].header_image.offset);
               // Goto the Line of the file that contains the start of the image

               while not EOF(F) do
               begin
                  Inc(Image_Size);
                  setlength(Databuffer, Image_Size);
                  BlockRead(F, colour, Sizeof(byte), Read);
                  Databuffer[Image_Size - 1] := colour;
               end;

               Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
               Writeln(L);
               writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
               writeln(L, 'Last Offset: ', LastOffset);
               writeln(L, 'Compression: 3');
               writeln(L, 'Image Size: ', Image_Size);
               writeln(L, 'Last Size: ', LastSize);
               writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
                  SHP.Data[x].header_image.cy);
               Writeln(L);

               LastSize := Image_Size;

               // Set the lengths of the other data buffers
               setlength(SHP.Data[x].Databuffer,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);
               setlength(Databuffer2,
                  (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) + 1);

               // decode it
               Decode2(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
                  SHP.Data[x].header_image.cy, Image_Size); // Compression 3
            end;
         end
         else  // Compression 1
         begin
            if SHP.Data[x].header_image.offset < LastOffset then
            begin
               SHP.Data[x].header_image.offset := LastOffset + LastSize;
            end;

            Image_Size := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;

            Writeln(L, 'Starting frame ', x, ' out of ', SHP.Header.NumImages);
            Writeln(L);
            writeln(L, 'Current Offset: ', SHP.Data[x].Header_Image.Offset);
            writeln(L, 'Last Offset: ', LastOffset);
            writeln(L, 'Compression: 1');
            writeln(L, 'Image Size: ', Image_Size);
            writeln(L, 'Last Size: ', LastSize);
            writeln(L, 'True Size: ', SHP.Data[x].header_image.cx *
               SHP.Data[x].header_image.cy);
            Writeln(L);

            LastOffset := LastOffset + LastSize;
            LastSize   := Image_Size;

            // Set the lengths of the data buffers
            setlength(SHP.Data[x].Databuffer, Image_Size + 1);
            setlength(Databuffer2, Image_Size + 1);

            Seek(F, SHP.Data[x].header_image.offset);
            // Goto the Line of the file that contains the start of the image

            // Read byte by byte from one offset to the other.
            for c := 1 to Image_Size do
            begin
               BlockRead(F, colour, Sizeof(byte), Read);
               Databuffer2[c - 1] := colour;
            end;
         end;
      end;
{      else
         LastSize := 0;}

      // Set the shp's databuffer to the result after decompression
      SHP.Data[x].Databuffer := Databuffer2;
      Inc(x); // check next frame
   end;

   Close(L);
   CloseFile(F);

   Result := True;

   // Final check of SHP game
   if (SHP.SHPType = stUnit) or (SHP.SHPType = stBuilding) or
      (SHP.SHPType = stBuildAnim) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) then
      FindSHPGame(SHP);
end;

 // Supra load is the mega fast way to load SHP files with only
 // one disk access. Since the greatest majority of the SHP
 // files are smaller than 2 mb, this method should not
 // compromise the RAM. Also, it doesn't rely on offsets.
function LoadSHPSupraFast(Filename: string; var SHP: TSHP): boolean;
var
   F:    TStream;
   FileSize: longword;
   x, c: integer;
   PData, PCurrentData: PByte;
begin
   Result := False;
   F      := TFileStream.Create(Filename, fmOpenRead);
   SHP.SHPType := stUnit;
   SHP.SHPGame := sgTS;

   // Store the whole file in the memory
   FileSize := F.Size;
   Getmem(PData, FileSize);
   F.Read(PData^, FileSize);
   PCurrentData := PData;
   F.Free;

   // Get Header
   SHP.Header.A := word(PWord(PCurrentData)^);
   Inc(PCurrentData, 2);
   SHP.Header.Width := word(PWord(PCurrentData)^);
   Inc(PCurrentData, 2);
   SHP.Header.Height := word(PWord(PCurrentData)^);
   Inc(PCurrentData, 2);
   SHP.Header.NumImages := word(PWord(PCurrentData)^);
   Inc(PCurrentData, 2);

   // 3.4: Check if it's a valid SHP file.
   if SHP.Header.A <> 0 then
   begin
      FreeMem(PData);
      exit;
   end;

   // 3.36: Verify Height and Width:
   if (SHP.Header.Width = 0) or (SHP.Header.Height = 0) then
   begin
      ShowMessage('This SHP file is null and it has no content. Start a new image instead.');
      FreeMem(PData);
      exit;
   end;

   setlength(SHP.Data, SHP.header.NumImages + 1);
   // Set the Data array to have SHP.header.NumImages+1 records

   FindSHPType(Filename, SHP);
   // check extention to see if its actualy a TEM or SNO
   if extractfileext(Filename) = '.tem' then
      SHP.SHPType := sttem
   else if extractfileext(Filename) = '.sno' then
      SHP.SHPType := stsno
   else if extractfileext(Filename) = '.urb' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := sturb;
   end
   else if extractfileext(Filename) = '.ubn' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stnewurb;
   end
   else if extractfileext(Filename) = '.lun' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stlun;
   end
   else if extractfileext(Filename) = '.des' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stdes;
   end;

   for x := 1 to SHP.header.NumImages do // Load Image Headers
   begin
      SHP.Data[x].Header_Image.x := word(PWord(PCurrentData)^);
      Inc(PCurrentData, 2);
      SHP.Data[x].Header_Image.y := word(PWord(PCurrentData)^);
      Inc(PCurrentData, 2);
      SHP.Data[x].Header_Image.cx := word(PWord(PCurrentData)^);
      Inc(PCurrentData, 2);
      SHP.Data[x].Header_Image.cy := word(PWord(PCurrentData)^);
      Inc(PCurrentData, 2);
      SHP.Data[x].Header_Image.compression := longword(PLongWord(PCurrentData)^);
      Inc(PCurrentData, 12);
      SHP.Data[x].Header_Image.offset := longword(PLongWord(PCurrentData)^);
      Inc(PCurrentData, 4);
      // Skip zero, unknown and offset.
   end;
   // Read and decode each image from the file
   for x := 1 to SHP.header.NumImages do
   begin
      // Set Length of Databuffer
      setlength(SHP.Data[x].Databuffer, SHP.Data[x].header_image.cx *
         SHP.Data[x].header_image.cy);

      // Does it really reads the frame?
      if SHP.Data[x].header_image.offset <> 0 then
      begin
         // Now it checks the compression:
         if (SHP.Data[x].header_image.compression = 3) then
         begin
            // decode it
            Decode3Supra(PCurrentData, SHP.Data[x].Databuffer,
               SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, FileSize); // Compression 3
         end
         else if (SHP.Data[x].header_image.compression = 2) then
         begin
            // decode it
            Decode2Supra(PCurrentData, SHP.Data[x].Databuffer,
               SHP.Data[x].header_image.cx, SHP.Data[x].header_image.cy, FileSize); // Compression 3
         end
         else  // Compression 1
         begin
            for c := 0 to (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) - 1 do
            begin
               SHP.Data[x].Databuffer[c] := PCurrentData^;
               Inc(PCurrentData);
            end;
         end;
      end;

      // Set the shp's databuffer to the result after decompression
   end;

   FreeMem(PData);
   Result := True;

   // Final check of SHP game
   if (SHP.SHPType = stUnit) or (SHP.SHPType = stBuilding) or
      (SHP.SHPType = stBuildAnim) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) then
      FindSHPGame(SHP);
end;


function LoadSHPSafe(Filename: string; var SHP: TSHP): boolean;
var
   f:      file;
   Read, x, c: integer;
   colour: byte;
   Databuffer, Databuffer2: TDatabuffer;
   Image_Size: integer;
begin
   Result := False;

   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?

   SHP.SHPType := stUnit;
   SHP.SHPGame := sgTS;

   BlockRead(F, SHP.Header, Sizeof(SHP.Header)); // Read Header

   // 3.4: Check if it's a valid SHP file.
   if SHP.Header.A <> 0 then
   begin
      CloseFile(F);
      exit;
   end;

   // 3.36: Verify Height and Width:
   if (SHP.Header.Width = 0) or (SHP.Header.Height = 0) then
   begin
      ShowMessage('This SHP file is null and it has no content. Start a new image instead.');
      CloseFile(F);
      exit;
   end;

   setlength(SHP.Data, SHP.header.NumImages + 1);
   // Set the Data array to have SHP.header.NumImages+1 records

   FindSHPType(Filename, SHP);

   // check extention to see if its actualy a TEM or SNO
   if extractfileext(Filename) = '.tem' then
      SHP.SHPType := sttem
   else if extractfileext(Filename) = '.sno' then
      SHP.SHPType := stsno
   else if extractfileext(Filename) = '.urb' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := sturb;
   end
   else if extractfileext(Filename) = '.ubn' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stnewurb;
   end
   else if extractfileext(Filename) = '.lun' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stlun;
   end
   else if extractfileext(Filename) = '.des' then
   begin
      SHP.SHPGame := sgRA2;
      SHP.SHPType := stdes;
   end;

   for x := 1 to SHP.header.NumImages do // Load Image Headers
      BlockRead(F, SHP.Data[x].header_image, Sizeof(THeader_Image));


   // Read and decode each image from the file
   for x := 1 to SHP.header.NumImages do
   begin

      // the ammount of bytes in a image (Width * Height)
      Image_Size := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;

      // Clear Buffers
      setlength(SHP.Data[x].Databuffer, 0);
      setlength(Databuffer, 0);
      setlength(Databuffer2, 0);

      // Set the lengths of the data buffers
      setlength(SHP.Data[x].Databuffer, Image_Size + 1);
      setlength(Databuffer, Image_Size + 1);
      setlength(Databuffer2, Image_Size + 1);

      Seek(F, SHP.Data[x].header_image.offset);
      // Goto the Line of the file that contains the start of the image

      // Read byte by byte from one offset to the other.
      for c := 1 to SHP.Data[x].header_image.cy * SHP.Data[x].header_image.cx do
      begin
         BlockRead(F, colour, Sizeof(byte), Read);
         Databuffer[c - 1] := colour;
      end;


      // If Compression3 try n decode it else databuffer2 = databuffer
      if (SHP.Data[x].header_image.compression = 3) then
         Decode3(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
            SHP.Data[x].header_image.cy, Image_Size) // Compression 3
      else if (SHP.Data[x].header_image.compression = 2) then
         Decode2(Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
            SHP.Data[x].header_image.cy, Image_Size) // Compression 3
      else
         Databuffer2 := Databuffer; // Compression 1

      // Set the shp's databuffer to the result after decompression
      SHP.Data[x].Databuffer := Databuffer2;
   end;

   CloseFile(F);

   Result := True;

   // Final check of SHP game
   if (SHP.SHPType = stUnit) or (SHP.SHPType = stBuilding) or
      (SHP.SHPType = stBuildAnim) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) then
      FindSHPGame(SHP);
end;

function WorkOutOffset(SHP: TSHP; Frame: integer): integer;
var
   size, x: integer;
begin
   size := SizeOf(THeader);

   for x := 1 to SHP.Header.NumImages do
      size := size + SizeOf(THeader_Image);

   if Frame > 1 then
      for x := 1 to Frame - 1 do
         size := size + (SHP.Data[x].Header_Image.cx * SHP.Data[x].Header_Image.cy);

   if SHP.Data[Frame].Header_Image.cx * SHP.Data[Frame].Header_Image.cy = 0 then
      size := 0;

   Result := size;
end;

// Old one, accepts compression 1 only.
procedure SaveSHPUncompressed(const Filename: string; var SHP: TSHP); overload;
var
   f: file;
   Written, x, c: integer;
   Image_Size: cardinal;
begin
   AssignFile(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   SHP.Header.A := 0;
   BlockWrite(F, SHP.Header, Sizeof(THeader), Written); // Write Header

   for x := 1 to SHP.header.NumImages do
   begin
      if (SHP.header.NumImages > 0) or (x < (SHP.header.NumImages / 2)) then
      begin
         SHP.Data[x].Header_Image.RadarColor := $70000;
      end
      else
      begin
         SHP.Data[x].Header_Image.RadarColor := 0;
      end;
      SHP.Data[x].header_image.compression := 1;
      SHP.Data[x].header_image.offset      := WorkOutOffset(SHP, X); // Works out offset
   end;

   for x := 1 to SHP.header.NumImages do // Save Image Headers
   begin
      BlockWrite(F, SHP.Data[x].header_image, Sizeof(THeader_Image), Written);
   end;

   // Save each image to the file
   for x := 1 to SHP.header.NumImages do
   begin
      // the ammount of bytes in a image (Width * Height)
      Image_Size := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;

      // Write byte by byte SHP.Data[x].header_image.cy * SHP.Data[x].header_image.cx times
      if SHP.Data[x].Header_Image.offset <> 0 then
         for c := 1 to Image_Size do
         begin
            BlockWrite(F, SHP.Data[x].Databuffer[c - 1], Sizeof(byte), Written);
         end;
   end;
   CloseFile(F);
end;


// Compression 3 and 1.
procedure SaveSHP(const Filename: string; var SHP: TSHP); overload;
var
   F:    file;
   Written, x, c: integer;
   Databuffer2: TDatabuffer;
   size: array of integer;
   CurrentOffset: integer;
begin
   Assign(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   SHP.Header.A := 0;
   BlockWrite(F, SHP.Header, Sizeof(THeader), Written); // Write Header

   setlength(size, SHP.Header.NumImages);

   CurrentOffset := SizeOf(THeader) + (SHP.Header.NumImages * SizeOf(THeader_Image));

   for x := 1 to SHP.header.NumImages do
   begin
{
      if (SHP.header.NumImages > 0) or (x < (SHP.header.NumImages / 2)) then
      begin
         SHP.Data[x].Header_Image.RadarColor := $70000;
      end
      else
      begin
         SHP.Data[x].Header_Image.RadarColor := 0;
      end;
}
      // Avoid encoding null stuff.
      if SHP.Data[x].Header_Image.cx * SHP.Data[x].Header_Image.cy > 0 then
      begin
         Encode3(SHP.Data[x].Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
            SHP.Data[x].header_image.cy, size[x - 1]); // Compression 3

         // Selects compression to use.
         if size[x - 1] < (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) then
         begin
            SetLength(SHP.Data[x].Databuffer, size[x - 1]);
            SHP.Data[x].Databuffer := Copy(Databuffer2);
            SHP.Data[x].header_image.compression := 3;
            SHP.Data[x].Header_Image.offset := CurrentOffset;
            CurrentOffset := CurrentOffset + size[x - 1]; // Works out new offset
         end
         else   // Compression 1
         begin
            size[x - 1] := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;
            SetLength(SHP.Data[x].Databuffer, size[x - 1]);
            SHP.Data[x].Header_Image.compression := 1;
            SHP.Data[x].Header_Image.offset := CurrentOffset;
            CurrentOffset := CurrentOffset + size[x - 1]; // Works out offset
         end;
      end
      else
      begin
         size[x - 1] := 0;
         SHP.Data[x].header_image.offset := 0;
         SHP.Data[x].header_image.compression := 1;
      end;
   end;

   for x := 1 to SHP.header.NumImages do // Save Image Headers
   begin
      BlockWrite(F, SHP.Data[x].header_image, Sizeof(THeader_Image), Written);
   end;

   // Save each image to the file
   for x := 1 to SHP.header.NumImages do
   begin
      // Write byte by byte SHP.Data[x].header_image.cy * SHP.Data[x].header_image.cx times
      if SHP.Data[x].Header_Image.offset <> 0 then
         for c := 1 to size[x - 1] do// Image_Size do
         begin
            BlockWrite(F, SHP.Data[x].Databuffer[c - 1], Sizeof(byte), Written);
         end;
   end;

   CloseFile(F);
end;

procedure SaveSHPHalfCompression(const Filename: string; var SHP: TSHP); overload;
var
   F:    file;
   Written, x, c: integer;
   Databuffer2: TDatabuffer;
   size: array of integer;
   CurrentOffset: integer;
begin
   Assign(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   SHP.Header.A := 0;
   BlockWrite(F, SHP.Header, Sizeof(THeader), Written); // Write Header

   setlength(size, SHP.Header.NumImages);

   CurrentOffset := SizeOf(THeader) + (SHP.Header.NumImages * SizeOf(THeader_Image));

   for x := 1 to (SHP.header.NumImages shr 1) do
   begin
{
      if (SHP.header.NumImages > 0) then
      begin
         SHP.Data[x].Header_Image.RadarColor := $70000;
      end
      else
      begin
         SHP.Data[x].Header_Image.RadarColor := 0;
      end;
}
      // Avoid encoding null stuff.
      if SHP.Data[x].Header_Image.cx * SHP.Data[x].Header_Image.cy > 0 then
      begin
         Encode3(SHP.Data[x].Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
            SHP.Data[x].header_image.cy, size[x - 1]); // Compression 3

         // Selects compression to use.
         if size[x - 1] < (SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy) then
         begin
            SetLength(SHP.Data[x].Databuffer, size[x - 1]);
            SHP.Data[x].Databuffer := Copy(Databuffer2);
            SHP.Data[x].header_image.compression := 3;
            SHP.Data[x].Header_Image.offset := CurrentOffset;
            CurrentOffset := CurrentOffset + size[x - 1]; // Works out new offset
         end
         else   // Compression 1
         begin
            size[x - 1] := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;
            SetLength(SHP.Data[x].Databuffer, size[x - 1]);
            SHP.Data[x].Header_Image.compression := 1;
            SHP.Data[x].Header_Image.offset := CurrentOffset;
            CurrentOffset := CurrentOffset + size[x - 1]; // Works out offset
         end;
      end
      else
      begin
         size[x - 1] := 0;
         SHP.Data[x].header_image.offset := 0;
         SHP.Data[x].header_image.compression := 1;
      end;
   end;

   for x := ((SHP.header.NumImages shr 1) + 1) to SHP.header.NumImages do
   begin
      // Avoid encoding null stuff.
      if SHP.Data[x].Header_Image.cx * SHP.Data[x].Header_Image.cy > 0 then
      begin
         // Selects compression to use.
         size[x - 1] := SHP.Data[x].header_image.cx * SHP.Data[x].header_image.cy;
         SetLength(SHP.Data[x].Databuffer, size[x - 1]);
         SHP.Data[x].Header_Image.compression := 1;
         SHP.Data[x].Header_Image.offset := CurrentOffset;
         CurrentOffset := CurrentOffset + size[x - 1]; // Works out offset
      end
      else
      begin
         size[x - 1] := 0;
         SHP.Data[x].header_image.offset := 0;
         SHP.Data[x].header_image.compression := 1;
      end;
   end;

   for x := 1 to SHP.header.NumImages do // Save Image Headers
   begin
      BlockWrite(F, SHP.Data[x].header_image, Sizeof(THeader_Image), Written);
   end;

   // Save each image to the file
   for x := 1 to SHP.header.NumImages do
   begin
      // Write byte by byte SHP.Data[x].header_image.cy * SHP.Data[x].header_image.cx times
      if SHP.Data[x].Header_Image.offset <> 0 then
         for c := 1 to size[x - 1] do// Image_Size do
         begin
            BlockWrite(F, SHP.Data[x].Databuffer[c - 1], Sizeof(byte), Written);
         end;
   end;

   CloseFile(F);
end;

procedure SaveSHPCompressed(const Filename: string; var SHP: TSHP); overload;
var
   F:    file;
   Written, x, c: integer;
   Databuffer2: TDatabuffer;
   size: array of integer;
   CurrentOffset: integer;
begin
   AssignFile(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   SHP.Header.A := 0;
   BlockWrite(F, SHP.Header, Sizeof(THeader), Written); // Write Header

   setlength(size, SHP.Header.NumImages);
   CurrentOffset := SizeOf(THeader) + (SHP.Header.NumImages * SizeOf(THeader_Image));

   for x := 1 to SHP.header.NumImages do
   begin
 {
      if (SHP.header.NumImages > 0) or (x < (SHP.header.NumImages / 2)) then
      begin
         SHP.Data[x].Header_Image.RadarColor := $70000;
      end
      else
      begin
         SHP.Data[x].Header_Image.RadarColor := 0;
      end;
}
      if SHP.Data[x].Header_Image.cx * SHP.Data[x].Header_Image.cy > 0 then
      begin
         Encode3(SHP.Data[x].Databuffer, Databuffer2, SHP.Data[x].header_image.cx,
            SHP.Data[x].header_image.cy, size[x - 1]); // Compression 3
         SetLength(Databuffer2, size[x - 1]);
         SetLength(SHP.Data[x].Databuffer, size[x - 1]);
         SHP.Data[x].Databuffer := Copy(Databuffer2);
         SHP.Data[x].header_image.offset := CurrentOffset;
         CurrentOffset := CurrentOffset + size[x - 1]; // Works out new offset
      end
      else
      begin
         size[x - 1] := 0;
         SetLength(SHP.Data[x].Databuffer, 0);
         SHP.Data[x].header_image.offset := 0;
      end;
      SHP.Data[x].header_image.compression := 3;
   end;

   for x := 1 to SHP.header.NumImages do // Save Image Headers
   begin
      BlockWrite(F, SHP.Data[x].header_image, Sizeof(THeader_Image), Written);
   end;

   // Save each image to the file
   for x := 1 to SHP.header.NumImages do
   begin
      // Write byte by byte size times
      if SHP.Data[x].Header_Image.offset <> 0 then
         for c := 1 to Size[x - 1] do
         begin
            BlockWrite(F, SHP.Data[x].Databuffer[c - 1], Sizeof(byte), Written);
         end;
   end;

   CloseFile(F);
end;

procedure CreateFrameImage(var SHP: TSHP; const Frame: integer);
var
   x, y, xx, yy, c: integer;
begin
   //Clear Frame Image
   Setlength(SHP.Data[Frame].FrameImage, 0, 0);
   // Set FrameImage
   Setlength(SHP.Data[Frame].FrameImage, SHP.Header.Width + 1, SHP.Header.Height + 1);
   // Get the position of where to draw the frame from
   xx := SHP.Data[Frame].header_image.x;
   yy := SHP.Data[Frame].header_image.y;

   c := -1;
   if SHP.Data[Frame].header_image.cx * SHP.Data[Frame].header_image.cy > 0 then
      for y := 0 to SHP.Data[Frame].Header_Image.cy - 1 do
         for x := 0 to SHP.Data[Frame].Header_Image.cx - 1 do
         begin
            c := c + 1;
            SHP.Data[Frame].FrameImage[xx + x, yy + y] := shp.Data[Frame].databuffer[c];
         end;
end;

function CreateFrameImages(var SHP: TSHP): boolean;
var
   x: integer;
begin
   Result := true;
   try
      for x := 1 to SHP.Header.NumImages do
         CreateFrameImage(SHP, x);
   except
      Result := false;
   end;
end;

procedure GetFrameImageUsedXY(SHP: TSHP; Frame: integer; var X1, Y1, X2, Y2: integer);
var
   x, y: integer;
   used: boolean;
begin
   used := False;

   X1 := SHP.Header.Width;
   Y1 := SHP.Header.Height;
   X2 := -1;
   Y2 := -1;

   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         if SHP.Data[frame].FrameImage[x, y] > 0 then
         begin
            if X1 > x then
               X1 := x;
            if X2 < x then
               X2 := x;

            if Y1 > Y then
               Y1 := Y;
            if Y2 < Y then
               Y2 := Y;
            used := True;
         end;

   if used = False then
   begin
      X1 := -1;
      X2 := -1;
      Y1 := -1;
      Y2 := -1;
   end;
end;

procedure CompressFrameImage(SHP: TSHP; Frame: integer; var SHPData: TSHPData);
var
   x1, x2, y1, y2, x, y, c: integer;
begin
   GetFrameImageUsedXY(SHP, Frame, X1, Y1, X2, Y2);
   if (X1 = -1) or (X2 = -1) or (Y1 = -1) or (Y2 = -1) then
   begin
      SHPData.Header_Image.cx   := 0;
      SHPData.Header_Image.cy   := 0;
      SHPData.Header_Image.x    := 0;
      SHPData.Header_Image.y    := 0;
      SHPData.Header_Image.align[0] := 0;
      SHPData.Header_Image.align[1] := 0;
      SHPData.Header_Image.align[2] := 0;
      SHPData.Header_Image.RadarColor := 0;
      SHPData.Header_Image.zero := 0;
   end
   else
   begin
      setlength(SHPData.Databuffer, 0);
      setlength(SHPData.Databuffer, (Y2 - Y1 + 1) * (X2 - X1 + 1) + 1);

      SHPData.Header_Image.cx   := (X2 - X1 + 1);
      SHPData.Header_Image.cy   := (Y2 - Y1 + 1);
      SHPData.Header_Image.x    := X1;
      SHPData.Header_Image.y    := Y1;
      SHPData.Header_Image.align[0] := 0;
      SHPData.Header_Image.align[1] := 0;
      SHPData.Header_Image.align[2] := 0;
      SHPData.Header_Image.RadarColor := 0;
      SHPData.Header_Image.zero := 0;

      c := -1;
      for y := Y1 to Y2 do
         for x := X1 to X2 do
         begin
            c := c + 1;
            SHPData.Databuffer[c] := SHPData.FrameImage[x, y];
         end;

      if c > (Y2 - Y1 + 1) * (X2 - X1 + 1) then
         ShowMessage(IntToStr(c) + ' ' + IntToStr((Y2 - Y1) * (X2 - X1)) +
            ' ' + IntToStr(X1) + ' ' + IntToStr(Y1) + ' ' + IntToStr(X2) + ' ' + IntToStr(Y2));
   end;
end;

procedure CompressFrameImages(var SHP: TSHP);
var
   x: integer;
begin
   for x := 1 to SHP.Header.NumImages do
      CompressFrameImage(SHP, x, SHP.Data[x]);
end;

function NewSHP(var SHP: TSHP; const TotalFrames, Width, Height: integer): boolean;
var
   x: integer;
begin
   Result := false;
   // Clear then set the length of SHP's Data Array
   setlength(SHP.Data, 0);
   setlength(SHP.Data, TotalFrames + 1);

   // Set SHP Width, Height and Frames
   SHP.Header.A := 0;
   SHP.Header.Width     := Width;
   SHP.Header.Height    := Height;
   SHP.Header.NumImages := TotalFrames;

   SHP.SHPType := stUnit; // Assume unit;
   SHP.SHPGame := sgTS;   // Assume TS.

   FindSHPType(SHP);

   // Clear Header_Image
   for x := 1 to TotalFrames do
   begin
      SHP.Data[x].Header_Image.cx     := 0;
      SHP.Data[x].Header_Image.cy     := 0;
      SHP.Data[x].Header_Image.x      := 0;
      SHP.Data[x].Header_Image.y      := 0;
      SHP.Data[x].Header_Image.compression := 1;
      SHP.Data[x].Header_Image.align[0] := 0;
      SHP.Data[x].Header_Image.align[1] := 0;
      SHP.Data[x].Header_Image.align[2] := 0;
      SHP.Data[x].Header_Image.offset := 0;
      SHP.Data[x].Header_Image.zero   := 0;
      SHP.Data[x].Header_Image.RadarColor := 0;
   end;

   // Create the blank frame images
   Result := CreateFrameImages(SHP);
end;

function GetSHPType(SHP: TSHP): string;
begin
   Result := '!ERROR!'; // Assume worst case scenario

   if SHP.SHPType = stUnit then
      Result := 'Unit'
   else if SHP.SHPType = stcameo then
      Result := 'Cameo'
   else if SHP.SHPType = stBuilding then
      Result := 'Building'
   else if SHP.SHPType = stAnimation then
      Result := 'Animation'
   else if SHP.SHPType = stBuildAnim then
      Result := 'Building Animation'
   else if SHP.SHPType = stTem then
      Result := 'Temperate'
   else if SHP.SHPType = stSno then
      Result := 'Snow'
   else if SHP.SHPType = stUrb then
      Result := 'Urban'
   else if SHP.SHPType = stNewUrb then
      Result := 'New Urban'
   else if SHP.SHPType = stWin then
      Result := 'Winter'
   else if SHP.SHPType = stDes then
      Result := 'Desert'
   else if SHP.SHPType = stLun then
      Result := 'Lunar'
   else if SHP.SHPType = stInt then
      Result := 'Interior';
end;

function GetSHPGame(SHP: TSHP): string;
begin
   Result := '!ERROR!'; // Assume worst case scenario

   if SHP.SHPGame = sgTD then
      Result := 'TD'
   else if SHP.SHPGame = sgRA1 then
      Result := 'RA1'
   else if SHP.SHPGame = sgTS then
      Result := 'TS'
   else if SHP.SHPGame = sgRA2 then
      Result := 'RA2';
end;

procedure FindSHPType(const Filename: string; var SHP: TSHP); overload;
begin
   // Detect cameo:
   if SHP.Header.NumImages = 1 then
   begin
      if SHP.SHPGame = sgTS then
      begin
         if (SHP.Header.Width = 60) and (SHP.Header.Height = 48) then
         begin
            SHP.SHPType := stCameo; // If only one image assume cameo
            SHP.SHPGame := sgRA2;
            exit;
         end
         else
         begin
            if (SHP.Header.Width = 64) and (SHP.Header.Height = 48) then
            begin
               SHP.SHPType := stCameo; // If only one image assume cameo
               SHP.SHPGame := sgTS;
               exit;
            end;
         end;
      end
      else if SHP.SHPGame = sgTD then
      begin
         if (SHP.Header.Width = 64) and (SHP.Header.Height = 48) then
         begin
            SHP.SHPType := stCameo; // If only one image assume cameo
            SHP.SHPGame := sgTD;
            exit;
         end;
      end;
   end;

   // Detect non RA2 buildings
   if ((SHP.Header.Width mod 24) = 0) and ((SHP.Header.Height mod 24) = 0) then
   begin
      if (SHP.SHPGame = sgTS) then
      begin
         if (SHP.Header.NumImages < 7) and (SHP.Header.NumImages > 1) then
         begin
            SHP.SHPType := stBuilding; // If less than 7 but more than 1 assume building
            exit;
         end
         else
         begin
            if ((SHP.Header.NumImages mod 2) = 0) then
            begin
               SHP.SHPType := stBuildAnim;
               exit;
            end;
         end;
      end
      else if (SHP.SHPGame = sgTD) or (SHP.SHPGame = sgRA1) then
      begin
         if Length(Filename) <= 8 then   // RA1 building names are a maximum of XXXX.shp
         begin
            SHP.SHPType := stBuilding;
            exit;
         end
         else // Buildups are XXXXmake.shp
         begin
            SHP.SHPType := stBuildAnim;
            exit;
         end;
      end;
   end;

   // Detect RA2 buildings.
   if (SHP.SHPGame = sgRA2) or (SHP.SHPGame = sgTS) then
   begin
      if (SHP.Header.NumImages = 6) or (SHP.Header.NumImages = 8) then
      begin
         SHP.SHPGame := sgRA2;
         SHP.SHPType := stBuilding;
         exit;
      end;
   end;

   // Detect random animations
   if (((SHP.Header.NumImages < 100) and (SHP.Header.NumImages > 6)) or
      ((SHP.Header.NumImages mod 2) <> 0)) then
      SHP.SHPType := stAnimation; // If less than 100 but more than 6 assume animation

   // Detect units
   if ((SHP.Header.NumImages mod 8) = 0) then
      SHP.SHPType := stUnit;
end;

procedure FindSHPType(var SHP: TSHP); overload;
begin
   FindSHPType('whatever.shp',SHP);
end;

procedure FindSHPGame(var SHP: TSHP);
var
   Frame:     longword;
   OffsetSum: longword;
begin
   OffsetSum := 0;
   for Frame := ((SHP.Header.NumImages div 2) + 1) to (SHP.Header.NumImages - 1) do
   begin
      OffsetSum := OffsetSum + SHP.Data[Frame].Header_Image.offset;
   end;
   if OffsetSum = 0 then
      SHP.SHPGame := sgRA2;
end;

// 3.36: This function checks if the SHP can be remmaped
function IsSHPRemmapable(const SHPType : TSHPType): boolean;
begin
   Result := false;
   if (SHPType = stUnit) or (SHPType = stBuilding) or (SHPType = stBuildAnim) or (SHPType = sttem) or (SHPType = stsno) or (SHPType = sturb) or (SHPType = stlun) or (SHPType = stdes) or (SHPType = stnewurb) or (SHPType = stint) or (SHPType = stwin) then
      Result := true
end;

procedure FindSHPRadarColors(const _SHP: TSHP; _Palette: TPalette);
var
   f: cardinal;
begin
   for f := 1 to _SHP.Header.NumImages do
   begin
      FindSHPFrameRadarColor(_SHP,f,_Palette);
   end;
end;

procedure FindSHPFrameRadarColor(const _SHP: TSHP; _Frame: integer; _Palette: TPalette);
var
   x,y: integer;
   Counter: array of cardinal;
   r,g,b: real;
   colorCounter,maxCount: cardinal;
begin
   // Prepare counter.
   SetLength(Counter,256);
   for x := 0 to High(Counter) do
   begin
      Counter[x] := 0;
   end;
   // Make a histogram.
   for x := 0 to (_SHP.Header.Width-1) do
   begin
      for y := 0 to (_SHP.Header.Height - 1) do
      begin
         inc(Counter[_SHP.Data[_Frame].FrameImage[x,y]]);
      end;
   end;
   // Get the average of the highest scoring colors. Ignore color #0.
   r := GetRValue(_Palette[1]);
   g := GetBValue(_Palette[1]);
   b := GetGValue(_Palette[1]);
   colorCounter := 1;
   maxCount := Counter[1];
   for x := 2 to High(Counter) do
   begin
      if Counter[x] > maxCount then
      begin
         r := GetRValue(_Palette[x]);
         g := GetBValue(_Palette[x]);
         b := GetGValue(_Palette[x]);
         colorCounter := 1;
         maxCount := Counter[x];
      end
      else if Counter[x] = maxCount then
      begin
         r := r + GetRValue(_Palette[x]);
         g := g + GetBValue(_Palette[x]);
         b := b + GetGValue(_Palette[x]);
         inc(colorCounter);
      end;
   end;
   r := r / colorCounter;
   g := g / colorCounter;
   b := b / colorCounter;
   // Write SHP Radar Color
   _SHP.Data[_Frame].Header_Image.RadarColor := RGB(trunc(r),trunc(g),trunc(b));
   if _SHP.Data[_Frame].Header_Image.RadarColor = 0 then
   begin
      _SHP.Data[_Frame].Header_Image.RadarColor := $70000;
   end;
end;

end.
