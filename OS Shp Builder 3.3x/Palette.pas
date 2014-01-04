unit Palette;
// PALETTE.PAS
// By Banshee & Stucuk

interface

uses
   Windows, Variants, Graphics, SysUtils, math, Shp_File, Dialogs;

const
   TRANSPARENT = 0;

type
   TPalette3Bytes = array [0..255] of record
      red,green,blue:byte;
   end;
   TPalette = array[0..255] of TColor;


// Compiler fix for Delphi 2006/Turbo Delphi
function RGB(r,g,b : integer): TColor;
function GetRValue(rgb: TColor): Byte;
function GetGValue(rgb: TColor): Byte;
function GetBValue(rgb: TColor): Byte;

// Palette function starts here
procedure LoadPaletteFromFile(const Filename : string; var Palette : TPalette);
procedure SavePaletteToFile(Filename : string; var SHPPalette:TPalette);
procedure GetPaletteFromFile(Filename : string; var Palette:TPalette);
Procedure CreateBlankPalette(SHPPalette:TPalette); // does a gradient effect
Procedure CreateBlankPalette_True(SHPPalette:TPalette); // Makes all 0
procedure LoadJASCPaletteFromFile(Filename : string; var Palette:TPalette);
procedure SavePaletteToJASCFile(Filename : string; var SHPPalette:TPalette);
procedure PaletteGradient(var SHPPalette:TPalette; StartNum,EndNum :byte; StartColour,EndColour : TColor);
procedure GetPaletteForGif(const Source : TPalette; var Dest : TPalette);
Function LoadAPaletteFromFile(Filename:String; var Palette:TPalette) : integer;
procedure LoadAnyPaletteFromFile(Filename:String; var Palette:TPalette);
procedure ChangeRemappable (var Palette:TPalette; side: byte);
procedure ChangeRemappableRA1 (var Palette:TPalette; side: byte);
procedure ChangeRemappableTD (var Palette:TPalette; side: byte);
procedure DifferentiateColour(ColourNumber: byte; var Palette:TPalette);
function IsUnitXPalette(filename: string):boolean;
function IsCameoPalette(filename: string):boolean;
function IsRA2Palette(filename: string):boolean;
function BuildCacheReplacementForGradients(const Palette: TPalette; Source,Destiny : byte):TCache;
procedure CopyPalette(const Source: TPalette; var Destination : TPalette);

implementation

uses FormMain;

// These functions are not inline, which prevents compiling problems with the
// latest Delphi versions (2006, 2007?)
function RGB(r,g,b : integer): TColor;
begin
   Result := (r or (g shl 8) or (b shl 16));
end;

function GetRValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb);
end;

function GetGValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb shr 8);
end;

function GetBValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb shr 16);
end;


// Loads TS/RA2 Palette into the SHPPalette
procedure LoadPaletteFromFile(const Filename : string; var Palette : TPalette);
var
   Palette_f : TPalette3Bytes;
   x: Integer;
   F : file;
begin
   try
      // open palette file
      AssignFile(F,Filename);
      FileMode := fmOpenRead;
      Reset(F,1); // file of byte

      BlockRead(F,Palette_f,sizeof(Palette_f));
      CloseFile(F);
      for x := 0 to 255 do
      begin
         Palette[x] := RGB(Palette_f[x].red*4,Palette_f[x].green*4,Palette_f[x].blue*4);
      end;
   except on E : EInOutError do
      MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
   end;
end;

// Saves TS/RA2 Palette from the SHPPalette
procedure SavePaletteToFile(Filename : string; var SHPPalette:TPalette);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   x: Integer;
   F : file;
begin
   for x := 0 to 255 do
   begin
      Palette_f[x].red := GetRValue(SHPPalette[x]) div 4;
      Palette_f[x].green := GetGValue(SHPPalette[x]) div 4;
      Palette_f[x].blue := GetBValue(SHPPalette[x]) div 4;
   end;

   AssignFile(F,Filename);
   Rewrite(F,1);

   BlockWrite(F,Palette_f,sizeof(Palette_f));
   CloseFile(F);
end;

procedure GetPaletteFromFile(Filename : string; var Palette:TPalette);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
    x: Integer;
    Colour : string;
    F : file;
begin
   // open palette file
   AssignFile(F,Filename);
   Reset(F,1); // file of byte

   BlockRead(F,Palette_f,sizeof(Palette_f));
   CloseFile(F);

   for x := 0 to 255 do
   begin
      Colour := '$00' + IntToHex(Palette_f[x].blue * 4,2) + IntToHex(Palette_f[x].green * 4,2) + IntToHex(Palette_f[x].red * 4,2);
      Palette[x] := StringToColor(Colour);
   end;
end;

Procedure CreateBlankPalette(SHPPalette:TPalette);
var
   x : integer;
begin
   for x := 0 to 255 do
      SHPPalette[x] := RGB(255-x,255-x,255-x);
end;

Procedure CreateBlankPalette_True(SHPPalette:TPalette);
var
   x : integer;
begin
   for x := 0 to 255 do
      SHPPalette[x] := 0;
end;

// Loads JASC 8Bit Palette into the SHPPalette
procedure LoadJASCPaletteFromFile(Filename : string; var Palette:TPalette);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   signature,binaryvalue:string[10];
   x,colours : Integer;
   F : text;
   R,G,B : byte;
begin
   // open palette file
   AssignFile(F,Filename);
   Reset(F);

   {Jasc format validation}
   readln(F,signature); {JASC-PAL}
   readln(F,binaryvalue); {0100}
   readln(F,colours); {256 (number of colours)}

   if (signature <> 'JASC-PAL') then
      MessageBox(0,'Error: JASC Signature Incorrect','Load Palette Error',0)
   else if ((binaryvalue <> '0100') or (colours <> 256)) then
      MessageBox(0,'Error: Palette Must Be 8Bit(256 Colours)','Load Palette Error',0)
   else
   Begin
      {Now, convert colour per colour}
      for x:= 0 to 255 do
      begin
         {read source info}
         readln(F,R,G,B);

         {Note: No colour conversion needed since JASC-PAL colours are the same as SHPPalette ones}
         Palette_f[x].red := r;
         Palette_f[x].green := g;
         Palette_f[x].blue := b;

         Palette[x] := RGB(Palette_f[x].red,Palette_f[x].green,Palette_f[x].blue);
      end;
   end;
   CloseFile(F);
end;

// Saves the SHPPalette As JASC-PAL
procedure SavePaletteToJASCFile(Filename : string; var SHPPalette:TPalette);
var
   signature,binaryvalue:string[10];
   x,colours : Integer;
   F : text;
begin
   AssignFile(F,Filename);
   Rewrite(F);

   signature := 'JASC-PAL';
   binaryvalue := '0100';
   colours := 256;
   writeln(F,signature); {JASC-PAL}
   writeln(F,binaryvalue); {0100}
   writeln(F,colours); {256 (number of colours)}

   for x := 0 to 255 do
      writeln(F,inttostr(GetRValue(SHPPalette[x]))+' ',inttostr(GetGValue(SHPPalette[x]))+' ',GetBValue(SHPPalette[x]));

   CloseFile(F);
end;

procedure PaletteGradient(var SHPPalette:TPalette; StartNum,EndNum :byte; StartColour,EndColour : TColor);
var
   X,Distance : integer;
   StepR,StepG,StepB : Real;
   R,G,B : integer;
begin
   Distance := EndNum-StartNum;

   if Distance = 0 then // Catch the Divison By 0's
   begin
      MessageBox(0,'Error: PaletteGradient Needs Start Num And '+#13+#13+'End Num To Be Different Numbers','PaletteGradient Input Error',0);
      Exit;
   end;

   StepR := (Max(GetRValue(EndColour),GetRValue(StartColour)) - Min(GetRValue(EndColour),GetRValue(StartColour))) / Distance;
   StepG := (Max(GetGValue(EndColour),GetGValue(StartColour)) - Min(GetGValue(EndColour),GetGValue(StartColour))) / Distance;
   StepB := (Max(GetBValue(EndColour),GetBValue(StartColour)) - Min(GetBValue(EndColour),GetBValue(StartColour))) / Distance;

   if GetRValue(EndColour) < GetRValue(StartColour) then
      StepR := -StepR;

   if GetGValue(EndColour) < GetGValue(StartColour) then
      StepG := -StepG;

   if GetBValue(EndColour) < GetBValue(StartColour) then
      StepB := -StepB;

   R := GetRValue(StartColour);
   G := GetGValue(StartColour);
   B := GetBValue(StartColour);

   for x := StartNum to EndNum do
   begin
      if Round(R + StepR) < 0 then
         R := 0
      else
         R := Round(R + StepR);
      if Round(G + StepG) < 0 then
         G := 0
      else
         G := Round(G + StepG);
      if Round(B + StepB) < 0 then
         B := 0
      else
         B := Round(B + StepB);

      if R > 255 then
         R := 255;
      if G > 255 then
         G := 255;
      if B > 255 then
         B := 255;

      SHPPalette[x] := RGB(R,G,B);
   end;
end;


Function LoadAPaletteFromFile(Filename:String; var Palette:TPalette) : integer; // Works out which filetype it is
var
    signature:string[10];
    F : text;
begin
   Result := 1; // Assume TS/RA2

   // open palette file
   AssignFile(F,Filename);
   Reset(F);

   {Jasc format validation}
   readln(F,signature); {JASC-PAL}
   CloseFile(F);

   if (signature <> 'JASC-PAL') then // If Signature is not JASC-PAL Assume its a TS/RA2 Palette
      LoadPaletteFromFile(Filename,Palette)
   else
   begin
      Result := 2;
      LoadJASCPaletteFromFile(Filename,Palette);
   end;
end;

procedure LoadAnyPaletteFromFile(Filename:String; var Palette:TPalette); // Works out which filetype it is
var
    signature:string[10];
    F : text;
begin
     // open palette file
     AssignFile(F,Filename);
     Reset(F);

     {Jasc format validation}
     readln(F,signature); {JASC-PAL}
     CloseFile(F);

     if (signature <> 'JASC-PAL') then // If Signature is not JASC-PAL Assume its a TS/RA2 Palette
     LoadPaletteFromFile(Filename,Palette)
     else
     begin
     LoadJASCPaletteFromFile(Filename,Palette);
     end;
end;


procedure ChangeRemappable (var Palette:TPalette; side: byte);
var
   rmult,gmult,bmult,base,x,rsub,gsub,bsub:byte;
begin
   base := 64;
   case side of
   0 : begin
      rmult := 2;
      gmult := 2;
      bmult := 1;
   end;
   2 : begin
      rmult := 0;
      gmult := 0;
      bmult := 2;
   end;
   3 : begin
      rmult := 0;
      gmult := 2;
      bmult := 0;
   end;
   4 : begin
      rmult := 2;
      gmult := 1;
      bmult := 0;
   end;
   5 : begin
      rmult := 0;
      gmult := 2;
      bmult := 2;
   end;
   6 : begin
      rmult := 2;
      gmult := 1;
      bmult := 2;
   end;
   7 : begin
      rmult := 1;
      gmult := 0;
      bmult := 1;
   end;
   else
   begin
      rmult := 2;
      gmult := 0;
      bmult := 0;
   end;
   end;
   // Generate Remmapable colours
   if rmult <> 0 then
     rsub := 1
   else
     rsub := 0;
   if gmult <> 0 then
     gsub := 1
   else
     gsub := 0;
   if bmult <> 0 then
     bsub := 1
   else
     bsub := 0;

   for x := 16 to 31 do
   begin
      Palette[x]:= RGB((((base*2)*rmult)-rsub),(((base*2)*gmult)-gsub),(((base*2)*bmult)-bsub));
      if (((x+1) div 3) <> 0) then
         base := base - 4
      else
         base := base - 3;
   end;
end;

procedure ChangeRemappableRA1 (var Palette:TPalette; side: byte);
type
   TRA1ColourArray = array [0..2,80..95] of byte;
var
   rmult,gmult,bmult,x:byte;
   ColourValues : TRA1ColourArray;
begin
   // This array is based on RA1 temperat.pal
   // Weak colours
   ColourValues[0,80] := 120;
   ColourValues[0,81] := 112;
   ColourValues[0,82] := 104;
   ColourValues[0,83] := 96;
   ColourValues[0,84] := 88;
   ColourValues[0,85] := 84;
   ColourValues[0,86] := 76;
   ColourValues[0,87] := 64;
   ColourValues[0,88] := 56;
   ColourValues[0,89] := 56;
   ColourValues[0,90] := 44;
   ColourValues[0,91] := 36;
   ColourValues[0,92] := 32;
   ColourValues[0,93] := 28;
   ColourValues[0,94] := 20;
   ColourValues[0,95] := 8;
   // Medium colours
   ColourValues[1,80] := 212;
   ColourValues[1,81] := 200;
   ColourValues[1,82] := 188;
   ColourValues[1,83] := 176;
   ColourValues[1,84] := 164;
   ColourValues[1,85] := 152;
   ColourValues[1,86] := 136;
   ColourValues[1,87] := 116;
   ColourValues[1,88] := 112;
   ColourValues[1,89] := 100;
   ColourValues[1,90] := 84;
   ColourValues[1,91] := 76;
   ColourValues[1,92] := 68;
   ColourValues[1,93] := 52;
   ColourValues[1,94] := 44;
   ColourValues[1,95] := 32;
   // Strong colours
   ColourValues[2,80] := 244;
   ColourValues[2,81] := 228;
   ColourValues[2,82] := 212;
   ColourValues[2,83] := 196;
   ColourValues[2,84] := 180;
   ColourValues[2,85] := 168;
   ColourValues[2,86] := 144;
   ColourValues[2,87] := 144;
   ColourValues[2,88] := 132;
   ColourValues[2,89] := 108;
   ColourValues[2,90] := 88;
   ColourValues[2,91] := 84;
   ColourValues[2,92] := 72;
   ColourValues[2,93] := 56;
   ColourValues[2,94] := 52;
   ColourValues[2,95] := 40;



   case side of
   0 : begin  // gold
      rmult := 2;
      gmult := 1;
      bmult := 0;
   end;
   2 : begin   // blue
      rmult := 0;
      gmult := 0;
      bmult := 2;
   end;
   3 : begin  // green
      rmult := 0;
      gmult := 2;
      bmult := 0;
   end;
   4 : begin   // orange
      rmult := 1;
      gmult := 1;
      bmult := 0;
   end;
   5 : begin  // sky blue
      rmult := 0;
      gmult := 1;
      bmult := 2;
   end;
   6 : begin  // pink
      rmult := 2;
      gmult := 1;
      bmult := 2;
   end;
   7 : begin   // purple
      rmult := 1;
      gmult := 0;
      bmult := 1;
   end;
   else
   begin
      rmult := 2;
      gmult := 0;
      bmult := 0;
   end;
   end;
   // Generate Remmapable colours
   for x := 80 to 95 do
   begin
      Palette[x]:= RGB(ColourValues[rmult,x],ColourValues[gmult,x],ColourValues[bmult,x]);
   end;
end;

procedure ChangeRemappableTD (var Palette:TPalette; side: byte);
type
   TTDColourArray = array [0..2,176..191] of byte;
var
   rmult,gmult,bmult,x:byte;
   ColourValues : TTDColourArray;
begin
   // This array is based on TD temperat.pal
   // Weak colours
   ColourValues[0,176] := 120;
   ColourValues[0,177] := 104;
   ColourValues[0,178] := 92;
   ColourValues[0,179] := 80;
   ColourValues[0,180] := 56;
   ColourValues[0,181] := 36;
   ColourValues[0,182] := 20;
   ColourValues[0,183] := 4;
   ColourValues[0,184] := 96;
   ColourValues[0,185] := 84;
   ColourValues[0,186] := 76;
   ColourValues[0,187] := 64;
   ColourValues[0,188] := 56;
   ColourValues[0,189] := 44;
   ColourValues[0,190] := 36;
   ColourValues[0,191] := 28;
   // Medium colours
   ColourValues[1,176] := 212;
   ColourValues[1,177] := 188;
   ColourValues[1,178] := 168;
   ColourValues[1,179] := 148;
   ColourValues[1,180] := 112;
   ColourValues[1,181] := 76;
   ColourValues[1,182] := 44;
   ColourValues[1,183] := 12;
   ColourValues[1,184] := 172;
   ColourValues[1,185] := 152;
   ColourValues[1,186] := 136;
   ColourValues[1,187] := 116;
   ColourValues[1,188] := 100;
   ColourValues[1,189] := 84;
   ColourValues[1,190] := 68;
   ColourValues[1,191] := 52;
   // Strong colours
   ColourValues[2,176] := 244;
   ColourValues[2,177] := 220;
   ColourValues[2,178] := 196;
   ColourValues[2,179] := 176;
   ColourValues[2,180] := 136;
   ColourValues[2,181] := 96;
   ColourValues[2,182] := 56;
   ColourValues[2,183] := 16;
   ColourValues[2,184] := 192;
   ColourValues[2,185] := 168;
   ColourValues[2,186] := 144;
   ColourValues[2,187] := 124;
   ColourValues[2,188] := 108;
   ColourValues[2,189] := 88;
   ColourValues[2,190] := 72;
   ColourValues[2,191] := 56;

   // Now, we get the power of each side.
   case side of
   0 : begin  // gold
      rmult := 2;
      gmult := 1;
      bmult := 0;
   end;
   2 : begin  // blue
      rmult := 0;
      gmult := 0;
      bmult := 2;
   end;
   3 : begin // green
      rmult := 0;
      gmult := 2;
      bmult := 0;
   end;
   4 : begin  // orange
      rmult := 1;
      gmult := 0;
      bmult := 0;
   end;
   5 : begin   // sky blue
      rmult := 0;
      gmult := 1;
      bmult := 2;
   end;
   6 : begin // purple
      rmult := 2;
      gmult := 1;
      bmult := 2;
   end;
   7 : begin // pink
      rmult := 1;
      gmult := 0;
      bmult := 1;
   end;
   else // red
   begin
      rmult := 2;
      gmult := 0;
      bmult := 0;
   end;
   end;
   // Generate Remmapable colours
   for x := 176 to 191 do
   begin
      Palette[x]:= RGB(ColourValues[rmult,x],ColourValues[gmult,x],ColourValues[bmult,x]);
   end;
end;

procedure DifferentiateColour(ColourNumber: byte; var Palette :TPalette);
begin
   Palette[ColourNumber] := RGB(GetRValue(Palette[ColourNumber]) + 1,GetGValue(Palette[ColourNumber]) + 1,GetBValue(Palette[ColourNumber]) + 1);
end;

function IsUnitXPalette(filename: string):boolean;
begin
   filename := extractfilename(filename);
   if filename[1] = 'u' then
      if filename[2] = 'n' then
         if filename[3] = 'i' then
            if filename[4] = 't' then
            begin
               result := true;
               exit;
            end;

   result := false;
end;

function IsRA2Palette(filename: string):boolean;
var
   c : byte; // position of char that is being read
begin
   filename := extractfiledir(filename);
   c := length(filename);
   if filename[c-1] = '2' then
      if (filename[c-2] = 'A') or (filename[c-2] = 'a') then
        if (filename[c-3] = 'R') or (filename[c-3] = 'r') then
        begin
           result := true;
           exit;
        end;

   result := false;
end;

function IsCameoPalette(filename: string):boolean;
begin
   filename := extractfilename(filename);
   if filename[1] = 'c' then
      if filename[2] = 'a' then
         if filename[3] = 'm' then
            if filename[4] = 'e' then
               if filename[5] = 'o' then
               begin
                  result := true;
                  exit;
               end;

   result := false;
end;

procedure GetPaletteForGif(const Source : TPalette; var Dest : TPalette);
var
   x : integer;
   r,g,b: byte;
begin
   for x := 0 to 255 do
   begin
      r := GetRValue(Source[x]);
      g := GetGValue(Source[x]);
      b := GetBValue(Source[x]);
      if (r <= $30) and (g <= $30) and (b <= $30) then
         Dest[x] := $301028      // random black
      else
         Dest[x] := Source[x];
   end;
   Dest[0] := 0;
end;

procedure GetColourAndStructure(const Colour : TColor; var r,g,b: byte; var rmult,gmult,bmult: real);
var
   maxfreq : byte;
begin
   // Get the colour
   R := GetRValue(Colour);
   G := GetGValue(Colour);
   B := GetBValue(Colour);

   // Get strongest frequency:
   maxfreq := max(max(r,g),b);

   // Get multipliers (colour structure)
   if r <> 0 then
      rmult := r / maxfreq
   else
      rmult := 0;
   if g <> 0 then
      gmult := g / maxfreq
   else
      gmult := 0;
   if b <> 0 then
      bmult := b / maxfreq
   else
      bmult := 0;

   // Now check for the special (0,0,0) case.
   if Colour = 0 then
   begin
      rmult := 1;
      gmult := 1;
      bmult := 1;
   end;
end;

// Compare colour structures with a tolerance of 8/256 (0,015625 for up and down)
function HasSimilarColourStructure(const r1mult,g1mult,b1mult,r2mult,g2mult,b2mult : real): Boolean;
begin
   // True unless it's confirmed to be wrong.
   result := true;

   if abs(r1mult - r2mult) > 0.1 then
      result := false;

   if abs(g1mult - g2mult) > 0.1 then
      result := false;

   if abs(b1mult - b2mult) > 0.1 then
      result := false;
end;

function HasSimilarColourDecrease(const r1,g1,b1,r2,g2,b2 : byte): Boolean;
var
   diference : byte;
begin
   diference := abs(r1 - r2);
   Result := true; // expect true until it gets false.
   if abs(g1 - g2) <> diference then
      Result := false;
   if abs(b1 - b2) <> diference then
      Result := false;
end;

function BuildCacheReplacementForGradients(const Palette: TPalette; Source,Destiny : byte):TCache;
var
   r,g,b : byte;   // first.
   rc,gc,bc : byte; // current
   rl,gl,bl : byte; // last
   rmult,gmult,bmult : real;
   rcmult,gcmult,bcmult : real;
   rlmult,glmult,blmult : real;
   IsLooping : boolean;
   CurrentColour : integer;
   Counter : byte;
   dmult,dcounter : real; // destiny 'multiplier', destiny counter
   minsource,maxsource,mindest,maxdest : byte;
begin
   // Set Defaults:
   minsource := Source;
   maxsource := Source;
   mindest := Destiny;
   maxdest := Destiny;

   // First Mission: we analyse the source and check the
   // gradient range.
   //////////////////////////////////////////////////////////

   // Get the source colour and structure
   GetColourAndStructure(Palette[Source],R,G,B,RMult,GMult,BMult);

   // Once we have the colour structure (rmult,gmult,bmult), we
   // check if nearby colours have similar structure.

   // Check colours below it.
   CurrentColour := Source-1;
   IsLooping := true;
   rl := r;
   gl := g;
   bl := b;
   rlmult := rmult;
   glmult := gmult;
   blmult := bmult;
   while (CurrentColour >= 0) and (IsLooping) do
   begin
      // Get the current colour
      GetColourAndStructure(Palette[CurrentColour],RC,GC,BC,RCMult,GCMult,BCMult);

      IsLooping := HasSimilarColourStructure(rlmult,glmult,blmult,rcmult,gcmult,bcmult) or HasSimilarColourDecrease(rl,gl,bl,rc,gc,bc);
      rl := rc;
      gl := gc;
      bl := bc;
      rlmult := rcmult;
      glmult := gcmult;
      blmult := bcmult;

      if IsLooping then
         minsource := CurrentColour;

      dec(CurrentColour);
   end;

   // Check colours above it.
   CurrentColour := Source+1;
   IsLooping := true;
   rl := r;
   gl := g;
   bl := b;
   rlmult := rmult;
   glmult := gmult;
   blmult := bmult;
   while (CurrentColour <= 255) and (IsLooping) do
   begin
      // Get the current colour
      GetColourAndStructure(Palette[CurrentColour],RC,GC,BC,RCMult,GCMult,BCMult);

      IsLooping := HasSimilarColourStructure(rlmult,glmult,blmult,rcmult,gcmult,bcmult) or HasSimilarColourDecrease(rl,gl,bl,rc,gc,bc);
      rl := rc;
      gl := gc;
      bl := bc;
      rlmult := rcmult;
      glmult := gcmult;
      blmult := bcmult;

      if IsLooping then
         maxsource := CurrentColour;

      inc(CurrentColour);
   end;

   // Second Mission: we analyse the destiny and check the
   // gradient range.
   //////////////////////////////////////////////////////////

   // Get the source colour and structure
   GetColourAndStructure(Palette[Destiny],R,G,B,RMult,GMult,BMult);

   // Once we have the colour structure (rmult,gmult,bmult), we
   // check if nearby colours have similar structure.

   // Check colours below it.
   CurrentColour := Destiny-1;
   IsLooping := true;
   rl := r;
   gl := g;
   bl := b;
   rlmult := rmult;
   glmult := gmult;
   blmult := bmult;
   while (CurrentColour >= 0) and (IsLooping) do
   begin
      // Get the current colour
      GetColourAndStructure(Palette[CurrentColour],RC,GC,BC,RCMult,GCMult,BCMult);

      IsLooping := HasSimilarColourStructure(rlmult,glmult,blmult,rcmult,gcmult,bcmult) or HasSimilarColourDecrease(rl,gl,bl,rc,gc,bc);
      rl := rc;
      gl := gc;
      bl := bc;
      rlmult := rcmult;
      glmult := gcmult;
      blmult := bcmult;
      if IsLooping then
         mindest := CurrentColour;

      dec(CurrentColour);
   end;

   // Check colours above it.
   CurrentColour := Destiny+1;
   IsLooping := true;
   rl := r;
   gl := g;
   bl := b;
   rlmult := rmult;
   glmult := gmult;
   blmult := bmult;
   while (CurrentColour <= 255) and (IsLooping) do
   begin
      // Get the current colour
      GetColourAndStructure(Palette[CurrentColour],RC,GC,BC,RCMult,GCMult,BCMult);

      IsLooping := HasSimilarColourStructure(rlmult,glmult,blmult,rcmult,gcmult,bcmult) or HasSimilarColourDecrease(rl,gl,bl,rc,gc,bc);
      rl := rc;
      gl := gc;
      bl := bc;
      rlmult := rcmult;
      glmult := gcmult;
      blmult := bcmult;
      if IsLooping then
         maxdest := CurrentColour;

      inc(CurrentColour);
   end;

   // Third Mission: We reset the TCache result.
   //////////////////////////////////////////////////////////
   for counter := 0 to 255 do
      Result[counter] := counter;

   // Fourth Mission: we analyse the gradient destiny
   // multipliers.
   //////////////////////////////////////////////////////////
   dmult := 0;
   if (maxsource <> minsource) then
      dmult := (maxdest - mindest) / (maxsource - minsource);
   dcounter := Destiny;

   // Make Cache now.
   for counter := minsource to maxsource do
   begin
      Result[counter] := Round(dcounter);
      dcounter := dcounter + dmult;
   end;
end;

procedure CopyPalette(const Source: TPalette; var Destination : TPalette);
var
   Counter : Byte;
begin
   for Counter := 0 to 255 do
   begin
      Destination[Counter] := Source[Counter];
   end;
end;

end.
