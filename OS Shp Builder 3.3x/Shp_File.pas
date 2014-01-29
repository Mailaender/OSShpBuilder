 // SHP_FILE.PAS
 // By Banshee & Stucuk
 // Portions Of XCC Code were converted from C to Delphi

unit Shp_File;

interface

uses
   Graphics, SysUtils;

type

   TSelection = record
      Layer : array of array of byte;
      X : integer;
      Y : integer;
      Width : integer;
      Height : integer;
      HasData : boolean;
      Visible : boolean;
      IsFromClipboard : Boolean; 
      HasMoved : Boolean;
   end;


   TRGB32 = packed record
      B, G, R, A: byte;
   end;
   TRGB32Array = packed array[0..MaxInt div SizeOf(TRGB32) - 1] of TRGB32;
   PRGB32Array = ^TRGB32Array;


   PByte     = ^byte;
   PWord     = ^word;
   PLongWord = ^longword;

   TDatabuffer = array of byte;

   THeader = record
      A: word; {Unknown}
      Width, Height,    {Width and Height of the images}
      NumImages: word;{Number of images}
   end;

   THeader_Image = record
      x, y, cx, cy: word; {cx and cy are width n height of stored image}
      compression: byte;
      align: array [0..2] of byte;
      RadarColor : TColor;
      zero, offset: longint; {Unknown}
   end;

   TFrameImage = array of array of byte;

   TSHPData = record
      Header_Image: THeader_Image;
      Databuffer:   TDatabuffer;
      FrameImage:   TFrameImage;
   end;

   TSHPType = (stUnit, stBuilding, stCameo, stAnimation, stBuildAnim, sttem,
      stsno, sturb, stlun, stdes, stnewurb, stint, stwin);
   TSHPGame = (sgTD, sgRA1, sgTS, sgRA2);

   TSHP = record
      SHPType: TSHPType;
      SHPGame: TSHPGame;
      Header:  THeader;
      Data:    array of TSHPDATA;
   end;

   EFileError = class(Exception);

   TSelectArea = record
      X1, Y1, X2, Y2: integer;
   end;

type
   TPoint2D = record
      X, Y: integer;
   end;

type
   TSelectData = record
      SourceData, DestData: TSelectArea;
      HasSource:    boolean;
      MouseClicked: TPoint2D;
   end;

   TCache = array [0..255] of byte;


   // Imported from 3.4 OS_SHP_Document Engine
   // Temporarily Here For Compatibility
   TObjectData_Item = record
      X:      integer;
      Y:      integer;
      colour: tcolor;
      colour_used: boolean; // UNUSED
   end;
   TObjectData = array of TObjectData_Item;


 // Important notice: The code below is a translation from XCC
 // code originally written by Olaf Van Der Spek. So, all hail
 // Olaf Van Der Spek for his great job and thank him a lot

// Without him, this program would be only in our dreams ;).

// Thanks a lot, Olaf!


// ~ Banshee


 // Note: Stucuk and Banshee did the translation of decode3
 // and Banshee translated encode3 and get_run_length

// misc
function get_run_length(const Source: Tdatabuffer; SP, SP_end: integer): integer;
procedure reinterpretbytesfromword(FullValue: word; var Byte1, Byte2: byte);
procedure reinterpretwordfrombytes(Byte1, Byte2: byte; var FullValue: word); overload;
procedure reinterpretwordfrombytes(Byte1, Byte2: byte; var FullValue: cardinal); overload;


// Compression 3:
procedure Decode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: integer);
procedure Decode3Supra(var Source: PByte; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: longword);
procedure Decode2(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: integer);
procedure Decode2Supra(var Source: PByte; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: longword);
procedure Encode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer); overload;
procedure Encode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var DP: integer); overload;

implementation

procedure reinterpretwordfrombytes(Byte1, Byte2: byte; var FullValue: word); overload;
begin
   FullValue := (Byte2 * 256) + Byte1;
end;

procedure reinterpretwordfrombytes(Byte1, Byte2: byte; var FullValue: cardinal); overload;
begin
   FullValue := (Byte2 * 256) + Byte1;
end;

procedure Decode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: integer);
var
   SP, DP, x, y, Count, v, maxdp: integer;
   Pos: word;
begin

   maxdp := cx * cy;

   SP := 0;
   DP := 0;

   for y := 1 to cy do
   begin
      reinterpretwordfrombytes(Source[SP], Source[SP + 1], Pos);
      Count := Pos - 2;
      // count := Source[SP]-2;
      SP    := SP + 2;
      x     := 0;
      while Count > 0 do
      begin

         Dec(Count);
         if (SP > max) or (DP > maxdp) then
            exit; // SP has reached max value, exit
         v := Source[SP];
         Inc(SP);
         if v <> 0 then
         begin
            Inc(x);
            Dest[DP] := v;
            Inc(DP);
         end
         else
         begin
            Dec(Count);
            v := Source[SP];
            Inc(SP);
            if (x + v) > cx then
               v := cx - x;
            x := x + v;
            while v > 0 do
            begin
               Dec(v);
               Dest[DP] := 0;
               Inc(DP);
               if (SP > max) or (DP > maxdp) then
                  exit; // SP has reached max value, exit
            end;
         end;
      end;

      if (SP >= max) or (DP >= maxdp) then
         exit; // SP has reached max value, exit

   end;

end;

// 3.4: Decode 3, for SupraLoad
procedure Decode3Supra(var Source: PByte; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: longword);
var
   DP, x, y, Count, v, maxdp: integer;
begin
   DP    := 0;
   maxdp := cx * cy;
   for y := 1 to cy do
   begin
      Count := word(PWord(Source)^) - 2;
      Inc(Source, 2);
      x := 0;
      while Count > 0 do
      begin
         Dec(Count);
         v := Source^;
         Inc(Source);
         if v <> 0 then
         begin
            Inc(x);
            if DP > maxdp then
               exit;
            Dest[DP] := v;
            Inc(DP);
         end
         else
         begin
            Dec(Count);
            v := Source^;
            Inc(Source);
            if (x + v) > cx then
               v := cx - x;
            x := x + v;
            while v > 0 do
            begin
               Dec(v);
               if DP > maxdp then
                  exit;
               Dest[DP] := 0;
               Inc(DP);
            end;
         end;
      end;
   end;

end;

// 3.36: Decode Compression 2.
procedure Decode2(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: integer);
var
   SP, DP, y, maxdp: integer;
   Count : word;
begin
   maxdp := cx * cy;
   SP := 0;
   DP := 0;

   for y := 1 to cy do
   begin
      reinterpretwordfrombytes(Source[SP], Source[SP + 1], Count);
      Count := Count - 2;
      inc(SP,2);
      while Count > 0 do
      begin
         Dec(Count);
         if (SP > max) or (DP > maxdp) then
            exit; // SP has reached max value, exit
         Dest[DP] := Source[SP];
         Inc(SP);
         Inc(DP);
      end;
      if (SP >= max) or (DP >= maxdp) then
         exit; // SP has reached max value, exit
   end;
end;

// 3.36: Decode 2, for SupraLoad
procedure Decode2Supra(var Source: PByte; var Dest: Tdatabuffer;
   const cx, cy: integer; var max: longword);
var
   DP, y, Count, maxdp: integer;
begin
   DP    := 0;
   maxdp := cx * cy;
   for y := 1 to cy do
   begin
      Count := word(PWord(Source)^) - 2;
      Inc(Source, 2);
      if (DP + Count) > maxdp then
         Count := maxdp - DP;
      while Count > 0 do
      begin
         Dec(Count);
         Dest[DP] := Source^;
         Inc(Source);
         Inc(DP);
      end;
   end;
end;


procedure reinterpretbytesfromword(FullValue: word; var Byte1, Byte2: byte);
begin
   Byte2 := FullValue div 256;
   Byte1 := FullValue mod 256;
end;

function get_run_length(const Source: Tdatabuffer; SP, SP_end: integer): integer;
var
   v, Count: integer;
begin
   Count := 1;
   v     := Source[SP];
   Inc(SP);
   while (SP < SP_end) and (Source[SP] = v) do
   begin
      Inc(SP);
      Inc(Count);
   end;
   Result := Count;
end;

procedure Encode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer); overload;
var
   SP, DP, SPEnd, DPLine, y, v, c: integer;
   b1, b2: byte;
begin

   //   max := cx * cy;
   SP := 0;
   DP := 0;


   for y := 1 to cy do
   begin
      SPEnd  := SP + cx;
      DPLine := DP;
      DP     := DP + 2;
      while SP < SPEnd do
      begin
         v := Source[SP];
         setlength(Dest, DP + 1);
         Dest[DP] := v;
         Inc(DP);
         if v <> 0 then
            Inc(SP)
         else
         begin
            c := get_run_length(Source, SP, SPEnd);
            if (c > 255) then
               c := 255;
            SP := SP + c;
            setlength(Dest, DP + 1);
            Dest[DP] := c;
            Inc(DP);
         end;
      end;
      reinterpretbytesfromword(DP - DPLine, b1, b2);
      Dest[DPLine]     := b1;
      Dest[DPLine + 1] := b2;
      //      if (SP > max) then
      //         exit; // SP has reached max value, exit
   end;
end;

procedure Encode3(const Source: Tdatabuffer; var Dest: Tdatabuffer;
   const cx, cy: integer; var DP: integer); overload;
var
   SP, SPEnd, DPLine, y, v, c: integer;
   b1, b2: byte;
begin

   //   max := cx * cy;
   SP := 0;
   DP := 0;


   for y := 1 to cy do
   begin
      SPEnd  := SP + cx;
      DPLine := DP;
      DP     := DP + 2;
      while SP < SPEnd do
      begin
         v := Source[SP];
         setlength(Dest, DP + 1);
         Dest[DP] := v;
         Inc(DP);
         if v <> 0 then
            Inc(SP)
         else
         begin
            c := get_run_length(Source, SP, SPEnd);
            if (c > 255) then
               c := 255;
            SP := SP + c;
            setlength(Dest, DP + 1);
            Dest[DP] := c;
            Inc(DP);
         end;
      end;
      reinterpretbytesfromword(DP - DPLine, b1, b2);
      Dest[DPLine]     := b1;
      Dest[DPLine + 1] := b2;
      //      if (SP > max) then
      //         exit; // SP has reached max value, exit
   end;
end;

end.
