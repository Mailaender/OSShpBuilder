unit SHP_Engine_CCMs;

interface
uses
  Windows,Shp_File,ComCtrls,Palette,Graphics,math,SHP_Colour_Bank,Colour_list,Dialogs,SysUtils;

Const
 MaxAlg = 7; // Used in the auto select alg.
 Infurium = 6; //

type
 TNeighborhoodSection = record
    r,g,b : byte;
 end;
 TNeighborhoodArray = array[1..3,1..3] of TNeighborhoodSection;
 TNeighborhood = record
     Data : TNeighborhoodArray;
     xmin,xmax,ymin,ymax : byte;
 end;

// The New CCM Engine

// Initialization Procedures
Procedure GenerateColourList(var Palette:TPalette; var List,Last:listed_colour; BGColour : Tcolor; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours,RedToRemap:Boolean); overload;
Procedure GenerateColourList(var Palette:TPalette; var List,Last:listed_colour; BGColour : Tcolor; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean); overload;
Procedure PrepareBank(var Start:colour_element; var List,Last:listed_colour);
Procedure PrepareNeighborhood (const Bitmap:TBitmap; x,y : integer; var Neighbour: TNeighborhood); overload;

// Auto Selection Algorithm
function AutoSelectALG_Progress(var ProgressBar : TProgressBar; var Bitmap:TBitmap; var SHPPalette:TPalette; var List,Last: listed_colour) : byte; overload;
function AutoSelectALG_Progress(var Bitmap:TBitmap; var SHPPalette:TPalette; var List,Last: listed_colour) : byte; overload;

// Palette Conversion Procedures
procedure GeneratePaletteCache(var Origin,Destiny:TPalette; var Cache : TCache; alg : byte); overload;
procedure GeneratePaletteCache(var Origin,Destiny:TPalette; var Cache : TCache; alg,side : byte; const game : TSHPGame; hasRemaps: boolean); overload;

// Frame Loading Procedures
Procedure LoadFrameImageToSHP(var SHP:TSHP; const Frame:integer; var Bitmap:TBitmap; var List,Last:listed_colour; var Start:colour_element; alg : byte; ApplyDithering : Boolean); overload;
Function LoadFrameImageToSHP(const Bitmap : TBitmap; const SHPPalette:TPalette; var List, Last: listed_colour; alg : byte) : real; overload;
Procedure LoadFrameImageToSHP(var Frame: TFrameImage; var Bitmap:TBitmap; var List,Last:listed_colour; var Start:colour_element; alg : byte; ApplyDithering : Boolean); overload;

// Pixel Loading Functions
function LoadPixel(var Bitmap:TBitmap; var Start:colour_element; var List,Last : listed_colour; alg : byte; x,y : integer; Dithering : Boolean) : integer; overload;
function LoadPixel(const Bitmap:TBitmap; var List,Last : listed_colour; alg : byte; x,y : integer) : integer; overload;
function LoadPixel(var List,Last : listed_colour; alg : byte; Colour : TColor) : integer; overload;

// Colour Conversion Methods: Functions
function RGBDiff(const Colour : TColor; var List,Last:listed_colour) : byte;
function RGBAdvDifference(const Colour : TColor; var List,Last:listed_colour) : byte;
function RGBDifference(const Colour : Tcolor; var List,Last : listed_colour) : byte;
function RGB3DFullDiff(const Colour : Tcolor; var List,Last:listed_colour) : byte;
function RGB3DColourPlus(const Colour : Tcolor; var List,Last:listed_colour) : byte;
function RGB3DStructuralis(const Colour : Tcolor; var List,Last:listed_colour) : byte;
Function RGB3DInfurium(const Color : Tcolor; var List,Last:listed_colour; const Neighbor : TNeighborhood; var Start:colour_element) : byte;


// Old Engine

// Misc Functions
function getpalettecolour(Palette: TPalette; Colour : Tcolor) : integer;
function getpalettecolour2(Palette: TPalette; Colour,BGColour: TColor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
function getpalettecolour_new(Palette: TPalette; Colour : Tcolor; Start:colour_element; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
Function SetFrameImageFrmBMP2Diff(const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
function AutoSelectALG(Bitmap : TBitmap; Palette:TPalette; BGColour : TColor; BcNone,ssShadow,ssIgnoreLAstColours : Boolean) : byte;
function AutoSelectALG_Progress(ProgressBar : TProgressBar; Bitmap : TBitmap; Palette:TPalette; BGColour : TColor; BcNone,ssShadow,ssIgnoreLAstColours : Boolean) : byte; overload;

// Misc Procedures
Procedure SetFrameImageFrmBMP(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap);
Procedure SetFrameImageFrmBMP2(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean);
Procedure SetFrameImageFrmBMP2NoBG(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreShadow,IgnoreGlowingColours:Boolean);
Procedure SetFrameImageFrmBMP2WithShadows(var SHP:TSHP; const Frame:integer;Bitmap : TBitmap; BGColour : Tcolor);
Procedure SetFrameImageUsingNeighborhoodChecker(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean);
Procedure SetFrameImageFrmBMPForAutoShadows(var SHP:TSHP; const Frame:integer;const Palette:TPalette;const Bitmap : TBitmap; shadowcolour : byte);

implementation


//---------------------------------------------
// Generate Color List
// -- PARAMS --
//    Palette     :
//    List        :
//    Last        :
//    BGColor     :
//    Ignore BG   :
//    Ignore Shad :
//    Ignore Glow :
//    RedToRemap  : 
//---------------------------------------------
Procedure GenerateColourList(var Palette:TPalette; var List,Last:listed_colour; BGColour : Tcolor; 
   IgnoreBackground, IgnoreShadow, IgnoreGlowingColours, RedToRemap:Boolean); overload;
var
   Temp: TColor;
begin
   Temp := Palette[0];
   if not IgnoreBackground then
      Palette[0] := BGColour;

   // Prepare list of colours that can be checked:
   InitializeColourList(List,Last);
   if IgnoreGlowingColours then
   begin
      if not IgnoreShadow then
         if IgnoreBackGround then
            AddToColourList(List,Last,Palette,1,1)
         else
            AddToColourList(List,Last,Palette,0,1);
      if RedToRemap then
      begin
         AddToColourList(List,Last,Palette,16,199);
         AddToColourList(List,Last,Palette,204,239);
      end
      else
         AddToColourList(List,Last,Palette,16,239);
   end
   else
   begin
      if IgnoreShadow then
      begin
         if not IgnoreBackGround then
            AddToColourList(List,Last,Palette,0,0);
         if RedToRemap then
         begin
            AddToColourList(List,Last,Palette,2,5);
            AddToColourList(List,Last,Palette,7,7);
            AddToColourList(List,Last,Palette,9,199);
            AddToColourList(List,Last,Palette,204,248);
            AddToColourList(List,Last,Palette,250,255);
         end
         else
            AddToColourList(List,Last,Palette,2,255);
      end
      else
      begin
         if not IgnoreBackGround then
            AddToColourList(List,Last,Palette,0,1)
         else
            AddToColourList(List,Last,Palette,1,2);

         if RedToRemap then
         begin
            AddToColourList(List,Last,Palette,2,5);
            AddToColourList(List,Last,Palette,7,7);
            AddToColourList(List,Last,Palette,9,199);
            AddToColourList(List,Last,Palette,204,248);
            AddToColourList(List,Last,Palette,250,255);
         end
         else
            AddToColourList(List,Last,Palette,2,255);
      end;
   end;
   Palette[0] := Temp;
end;


//---------------------------------------------
// Generate Color List
// -- PARAMS --
//    Palette     :
//    List        :
//    Last        :
//    BGColor     :
//    Ignore BG   :
//    Ignore Shad :
//    Ignore Glow :
//---------------------------------------------
Procedure GenerateColourList(var Palette : TPalette; var List, Last:listed_colour; BGColour : Tcolor; 
   IgnoreBackground, IgnoreShadow, IgnoreGlowingColours:Boolean); overload;
var
   Temp: TColor;
begin
   Temp := Palette[0];
   if not IgnoreBackground then
      Palette[0] := BGColour;

   // Prepare list of colours that can be checked:
   InitializeColourList(List, Last);
   if IgnoreGlowingColours then
   begin
      if not IgnoreShadow then
      begin
         if IgnoreBackGround then
            AddToColourList(List,Last,Palette,1,1)
         else
            AddToColourList(List,Last,Palette,0,1);
      end
      else if not IgnoreBackGround then
         AddToColourList(List,Last,Palette,0,0);
      AddToColourList(List,Last,Palette,16,239);
   end
   else
   begin
      if IgnoreShadow then
      begin
         if not IgnoreBackGround then
            AddToColourList(List,Last,Palette,0,0);
         AddToColourList(List,Last,Palette,2,255);
      end
      else
        if not IgnoreBackGround then
           AddToColourList(List, Last, Palette, 0, 255)
        else
           AddToColourList(List, Last, Palette, 1, 255);
     end;
     Palette[0] := Temp;
end;


//---------------------------------------------
// Prepare Color Bank 
// -- PARAMS --
//    Start    :
//    List     :
//    Last     :
//---------------------------------------------
Procedure PrepareBank(var Start:colour_element; var List,Last:listed_colour);
begin
   // Initializing Colour Bank
   InitializeBank(Start);
   AddToBank(Start,List^.r,List^.g,List^.b,List^.id);
end;


//--------------------------------------------- 
// Auto Selection Algorithm
//---------------------------------------------
function AutoSelectALG_Progress(var ProgressBar : TProgressBar; var Bitmap:TBitmap; var SHPPalette:TPalette; var List,Last: listed_colour) : byte; overload;
var
   Diff,difft: real;
   x : integer;
   alg : byte;
begin
   alg := 1;
   diff := 999999999; // Max value
   ProgressBar.Visible := true;
   ProgressBar.Max := MaxAlg-1;
   for x := 1 to MaxAlg do
   begin
      ProgressBar.Position := x-1;
      ProgressBar.Refresh;
      difft := LoadFrameImageToSHP(Bitmap,SHPPalette,List,Last,x); // SetFrameImageFrmBMP2Diff(1,SHPPalette,Bitmap,BGColour,x,bcNone,ssShadow,ssIgnoreLastColours);
      if difft < diff then
      begin
         diff := difft;
         alg := x;
      end;
   end;
   Result := alg;
end;


//---------------------------------------------
// Auto Selection Algorithm
//---------------------------------------------
function AutoSelectALG_Progress(var Bitmap:TBitmap; var SHPPalette:TPalette; var List,Last: listed_colour) : byte; overload;
var
   Diff,difft: real;
   x : integer;
   alg : byte;
begin
   alg := 1;
   diff := 999999999; // Max value
   for x := 1 to MaxAlg do
   begin
      difft := LoadFrameImageToSHP(Bitmap,SHPPalette,List,Last,x); // SetFrameImageFrmBMP2Diff(1,SHPPalette,Bitmap,BGColour,x,bcNone,ssShadow,ssIgnoreLastColours);
      if difft < diff then
      begin
         diff := difft;
         alg := x;
      end;
   end;
   Result := alg;
end;


//---------------------------------------------
// Prepare Neighborhood
//---------------------------------------------
Procedure PrepareNeighborhood (const Bitmap:TBitmap; x,y : integer; var Neighbour: TNeighborhood); overload;
var
   maxH,MaxW : Integer;
begin
   maxH := Bitmap.Height;
   maxW := Bitmap.Width;
   if x > 0 then
   begin
      Neighbour.xmin := 1;
      // [1,1] Pixel (left top)
      if y > 0 then
      begin
         Neighbour.Data[1,1].r := GetRValue(Bitmap.Canvas.Pixels[x-1,y-1]);
         Neighbour.Data[1,1].g := GetGValue(Bitmap.Canvas.Pixels[x-1,y-1]);
         Neighbour.Data[1,1].b := GetBValue(Bitmap.Canvas.Pixels[x-1,y-1]);
      end;
      // [1,2] Pixel (left mid)
      Neighbour.Data[1,2].r := GetRValue(Bitmap.Canvas.Pixels[x-1,y]);
      Neighbour.Data[1,2].g := GetGValue(Bitmap.Canvas.Pixels[x-1,y]);
      Neighbour.Data[1,2].b := GetBValue(Bitmap.Canvas.Pixels[x-1,y]);
      // [1,3] Pixel (left bottom)
      if y < (maxH - 1) then
      begin
         Neighbour.Data[1,3].r := GetRValue(Bitmap.Canvas.Pixels[x-1,y+1]);
         Neighbour.Data[1,3].g := GetGValue(Bitmap.Canvas.Pixels[x-1,y+1]);
         Neighbour.Data[1,3].b := GetBValue(Bitmap.Canvas.Pixels[x-1,y+1]);
      end;
   end
   else
      Neighbour.xmin := 2;
   // [2,1] Pixel (mid top)
   if y > 0 then
   begin
      Neighbour.ymin := 1;
      Neighbour.Data[2,1].r := GetRValue(Bitmap.Canvas.Pixels[x,y-1]);
      Neighbour.Data[2,1].g := GetGValue(Bitmap.Canvas.Pixels[x,y-1]);
      Neighbour.Data[2,1].b := GetBValue(Bitmap.Canvas.Pixels[x,y-1]);
   end
   else
      Neighbour.ymin := 2;
   // [2,2] Pixel (mid mid)
   Neighbour.Data[2,2].r := GetRValue(Bitmap.Canvas.Pixels[x,y]);
   Neighbour.Data[2,2].g := GetGValue(Bitmap.Canvas.Pixels[x,y]);
   Neighbour.Data[2,2].b := GetBValue(Bitmap.Canvas.Pixels[x,y]);
   // [2,3] Pixel (mid bottom)
   if y < (maxH - 1) then
   begin
      Neighbour.ymax := 3;
      Neighbour.Data[2,3].r := GetRValue(Bitmap.Canvas.Pixels[x,y+1]);
      Neighbour.Data[2,3].g := GetGValue(Bitmap.Canvas.Pixels[x,y+1]);
      Neighbour.Data[2,3].b := GetBValue(Bitmap.Canvas.Pixels[x,y+1]);
   end
   else
      Neighbour.ymax := 2;

   if x < (MaxW - 1) then
   begin
      Neighbour.xmax := 3;
      // [3,1] Pixel (right top)
      if y > 0 then
      begin
         Neighbour.Data[3,1].r := GetRValue(Bitmap.Canvas.Pixels[x+1,y-1]);
         Neighbour.Data[3,1].g := GetGValue(Bitmap.Canvas.Pixels[x+1,y-1]);
         Neighbour.Data[3,1].b := GetBValue(Bitmap.Canvas.Pixels[x+1,y-1]);
      end;
      // [3,2] Pixel (right mid)
      Neighbour.Data[3,2].r := GetRValue(Bitmap.Canvas.Pixels[x+1,y]);
      Neighbour.Data[3,2].g := GetGValue(Bitmap.Canvas.Pixels[x+1,y]);
      Neighbour.Data[3,2].b := GetBValue(Bitmap.Canvas.Pixels[x+1,y]);
      // [3,3] Pixel (right bottom)
      if y < (maxH - 1) then
      begin
         Neighbour.Data[3,3].r := GetRValue(Bitmap.Canvas.Pixels[x+1,y+1]);
         Neighbour.Data[3,3].g := GetGValue(Bitmap.Canvas.Pixels[x+1,y+1]);
         Neighbour.Data[3,3].b := GetBValue(Bitmap.Canvas.Pixels[x+1,y+1]);
      end;
   end
   else
      Neighbour.xmax := 2;
end;


//---------------------------------------------
// Palette Conversion
//---------------------------------------------
procedure GeneratePaletteCache(var Origin,Destiny:TPalette; var Cache : TCache; alg : byte); overload;
var
   List,Last:listed_colour;
   count : byte;
begin
   GenerateColourList(Destiny,List,Last,Origin[0],true,false,false);
   Cache[0]:= 0;
   for count := 1 to 255 do
      Cache[count] := LoadPixel(List,Last,alg,Origin[count]);

   ClearColourList(List,Last);
end;


//---------------------------------------------
// Generate Palette Cache
//---------------------------------------------
procedure GeneratePaletteCache(var Origin,Destiny:TPalette; var Cache : TCache; alg,side : byte; const game : TSHPGame; hasRemaps: boolean); overload;
var
   List,Last:listed_colour;
   count : byte;
begin
   GenerateColourList(Destiny,List,Last,Origin[0],true,false,false);
   if hasRemaps then
   begin
      if game = sgTD then
         ChangeRemappableTD(Origin,side)
      else if game = sgRA1 then
         ChangeRemappableRA1(Origin,side)
      else
         ChangeRemappable(Origin,side);
   end;
   for count := 0 to 255 do
      Cache[count] := LoadPixel(List,Last,alg,Origin[count]);
   ChangeRemappable(Origin,1); // Undo Palette change
   ClearColourList(List,Last);
end;


//---------------------------------------------
// Frame Loading Procedures
//---------------------------------------------
Procedure LoadFrameImageToSHP(var SHP:TSHP; const Frame:integer; var Bitmap:TBitmap; var List,Last:listed_colour; var Start:colour_element; alg : byte; ApplyDithering : Boolean); overload;
var
   x,y : integer;
begin
   // Populate the image pixel by pixel
   for y := 0 to Bitmap.Height-1 do
      for x := 0 to Bitmap.Width-1 do
      begin
         SHP.Data[Frame].FrameImage[x,y] := LoadPixel(Bitmap,Start,List,Last,alg,x,y,ApplyDithering);
      end;
end;


//---------------------------------------------
// Load Frame Image To Shp
//---------------------------------------------
Procedure LoadFrameImageToSHP(var Frame: TFrameImage; var Bitmap:TBitmap; var List,Last:listed_colour; var Start:colour_element; alg : byte; ApplyDithering : Boolean); overload;
var
   x,y : integer;
begin
   // Populate the image pixel by pixel
   for y := 0 to Bitmap.Height-1 do
      for x := 0 to Bitmap.Width-1 do
      begin
         Frame[x,y] := LoadPixel(Bitmap,Start,List,Last,alg,x,y,ApplyDithering);
      end;
end;


Function LoadFrameImageToSHP(const Bitmap : TBitmap; const SHPPalette:TPalette; var List, Last: listed_colour; alg : byte) : real; overload;
var
   x,y,rr,gg,bb,col : integer;
begin
   result := 0;

   for y := 0 to Bitmap.Height-1 do
      for x := 0 to Bitmap.Width-1 do
      begin
         col := LoadPixel(Bitmap,List,Last,alg,x,y);
         rr := abs(GetRValue(Bitmap.Canvas.Pixels[x,y]) - GetRValue(SHPPalette[col]));
         gg := abs(GetGValue(Bitmap.Canvas.Pixels[x,y]) - GetGValue(SHPPalette[col]));
         bb := abs(GetBValue(Bitmap.Canvas.Pixels[x,y]) - GetBValue(SHPPalette[col]));

         result := result + sqrt((abs(rr) * abs(rr)) + (abs(gg) * abs(gg)) + (abs(bb) * abs(bb)));
      end;
end;

Function GetColourFronList(var List : listed_colour; Col : Integer) : TColor;
var
   Pos : listed_colour;
begin
   Pos := List;
   While (Pos <> nil) and (Pos^.id <> Col) do
   begin
      pos := pos^.next;
   end;

   if (Pos <> nil) then
      Result := RGB(pos^.r,pos^.g,pos^.b)
   else
      Result := clblack;
end;

//##################################//
// DITHER CODE                      //
//##################################//

type
   TRGBColorI = Record
   r,g,b : Integer;
end;

Procedure AddTRGBColourToTColorWithError(var Color1 : TColor; const Color2 : TRGBColorI; ErrorPercent : Single);
var
   NewColor : TRGBColorI;
begin
   NewColor.r := Max(Min(trunc(GetRValue(Color1) + (Color2.r*ErrorPercent)),255),0);
   NewColor.g := Max(Min(trunc(GetGValue(Color1) + (Color2.g*ErrorPercent)),255),0);
   NewColor.b := Max(Min(trunc(GetBValue(Color1) + (Color2.b*ErrorPercent)),255),0);
   Color1 := RGB(NewColor.r,NewColor.g,NewColor.b);
end;

   // http://www.vbaccelerator.com/codelib/gfx/clrman2.htm
   // Stu - It seems to work PERFECTLY! "IM INVINCIBLE!" - Boris from James Bond
Procedure ApplyDithering(Var Bitmap : TBitmap; Const Colour1,Colour2 : TColor; X,Y : Integer);
var
   xx,yy,c : Integer;
   Error : TRGBColorI;
   Color : TColor;
begin
   If Odd(y) then
      c := 3
   else
      c := 0;

   Error.r := GetRValue(Colour1)-GetRValue(Colour2);
   Error.g := GetGValue(Colour1)-GetGValue(Colour2);
   Error.b := GetBValue(Colour1)-GetBValue(Colour2);

   if odd(y) then
   begin
      for yy := y+1 downto y do
         for xx := x+1 downto x-1 do
            If ((xx <> x-1) and (xx <> x)) or (yy <> y) then
               if (xx < Bitmap.Width) and (xx >= 0) then
                  if (yy < Bitmap.Height) and (yy >= 0) then
                  begin
                     Color := Bitmap.Canvas.Pixels[xx,yy];
                     if c = 0 then
                        AddTRGBColourToTColorWithError(Color,Error,7/16)
                     else if c = 1 then
                        AddTRGBColourToTColorWithError(Color,Error,3/16)
                     else if c = 2 then
                        AddTRGBColourToTColorWithError(Color,Error,5/16)
                     else if c = 3 then
                        AddTRGBColourToTColorWithError(Color,Error,1/16)
                     else
                        AddTRGBColourToTColorWithError(Color,Error,1/16);

                     Bitmap.Canvas.Pixels[xx,yy] := Color;
                     dec(c);
                  end;
   end
   else
      for yy := y to y+1 do
         for xx := x-1 to x+1 do
            If ((xx <> x-1) and (xx <> x)) or (yy <> y) then
               if (xx < Bitmap.Width) and (xx >= 0) then
                  if (yy < Bitmap.Height) and (yy >= 0) then
                  begin
                     Color := Bitmap.Canvas.Pixels[xx,yy];
                     if c = 0 then
                        AddTRGBColourToTColorWithError(Color,Error,7/16)
                     else if c = 1 then
                        AddTRGBColourToTColorWithError(Color,Error,3/16)
                     else if c = 2 then
                        AddTRGBColourToTColorWithError(Color,Error,5/16)
                     else if c = 3 then
                        AddTRGBColourToTColorWithError(Color,Error,1/16)
                     else
                        AddTRGBColourToTColorWithError(Color,Error,1/16);

                     Bitmap.Canvas.Pixels[xx,yy] := Color;
                     inc(c);
                  end;
end;

//##################################//
// DITHER CODE END                  //
//##################################//

//---------------------------------------------
// Load Pixel
// -- PARAMS --
//    Bitmap   : bitmap image
//    Start    : 
//    List     :
//    Last     : 
//    Algorithm: 
//    X        : Y pixel position
//    Y        : X pixel position
//---------------------------------------------
function LoadPixel(var Bitmap:TBitmap; var Start:colour_element; var List,Last : listed_colour; alg : byte; x,y : integer; Dithering : Boolean) : integer; overload;
var
   col : integer;
   Colour : Tcolor;
   Neighbour: TNeighborhood;
begin
   Colour := Bitmap.Canvas.Pixels[x,y];


   if alg <> Infurium then
   begin
      col := ColourInBank(Start, GetRValue(Colour), GetGValue(Colour), GetBValue(Colour));

      if (col = -1) then
      begin
         if alg = 1 then
            col := RGBDiff(Colour,List,Last)
         else if alg = 2 then
            col := RGBAdvDifference(Colour,List,Last)
         else if alg = 3 then
            col := RGBDifference(Colour,List,Last)
         else if alg = 4 then
            col := RGB3DFullDiff(Colour,List,Last)
         else if alg = 5 then
            col := RGB3DColourPlus(Colour,List,Last)
         else if alg = 7 then
            col := RGB3DStructuralis(Colour,List,Last);

         If Dithering then
            ApplyDithering(Bitmap,Colour,GetColourFronList(List,Col),x,y);

         AddToBank(Start,GetRValue(Colour),GetGValue(Colour),GetBValue(Colour),col);
      end;
   end
   else // if Infurium then
   begin
      // 3.36: Infurium has caching again, but restricted.
      col := ColourInBank(Start,GetRValue(Colour),GetGValue(Colour),GetBValue(Colour));
      if (col = -1) then
      begin
         PrepareNeighborhood(Bitmap,x,y,Neighbour);
         col := RGB3DInfurium(Colour,List,Last,Neighbour,Start);
      end;
   end;

   result := col;
end;


//---------------------------------------------
// Load Pixel
// -- PARAMS --
//    Bitmap   : bitmap image
//    List     :
//    Last     : 
//    alg      : Algorithm 
//    X        : Y pixel position
//    Y        : X pixel position
// -- RETURN --
//    int      : Color Index
//---------------------------------------------
function LoadPixel(const Bitmap:TBitmap; var List,Last : listed_colour; alg : byte; x,y : integer) : integer; overload;
var
   col : integer;
   Colour : Tcolor;
   Neighbour: TNeighborhood;
   Start:colour_element;
begin
   Start := nil;
   Colour := Bitmap.Canvas.Pixels[x,y];

   if alg = 1 then
      col := RGBDiff(Colour,List,Last)
   else if alg = 2 then
      col := RGBAdvDifference(Colour,List,Last)
   else if alg = 3 then
      col := RGBDifference(Colour,List,Last)
   else if alg = 4 then
      col := RGB3DFullDiff(Colour,List,Last)
   else if alg = 5 then
      col := RGB3DColourPlus(Colour,List,Last)
   else if alg = 7 then
      col := RGB3DStructuralis(Colour,List,Last)
   else // if Infurium then
   begin
      PrepareNeighborhood(Bitmap, x, y, Neighbour);
      col := RGB3DInfurium(Colour, List, Last, Neighbour, Start);
   end;

   result := col;
end;


//---------------------------------------------
// Load Pixel
// -- PARAMS --
//    List     :
//    Last     : 
//    Algorithm: 
//    Colour   : 
//---------------------------------------------
function LoadPixel(var List,Last : listed_colour; alg : byte; Colour : TColor) : integer; overload;
var
   col : integer;
begin
   if alg = 1 then
      col := RGBDiff(Colour,List,Last)
   else if alg = 2 then
      col := RGBAdvDifference(Colour,List,Last)
   else if alg = 3 then
      col := RGBDifference(Colour,List,Last)
   else if alg = 4 then
      col := RGB3DFullDiff(Colour,List,Last)
   else if alg = 5 then
      col := RGB3DColourPlus(Colour,List,Last)
   else if alg = 7 then
      col := RGB3DStructuralis(Colour,List,Last)
   else // if Infurium then
      col := RGB3DFullDiff(Colour,List,Last);

   result := col;
end;



// ===============================================
// Colour Conversion Methods
// ===============================================


//---------------------------------------------
// RGB Difference
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGBDiff(const Colour : TColor; var List,Last:listed_colour) : byte;
var
   pos : listed_colour;
   r,g,b,rr,gg,bb : byte;
   cc : integer;
begin
   cc := -1;

   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);
   rr := 255;
   gg := 255;
   bb := 255;

   pos := List;

   while pos <> nil do
   begin
      if (((r = pos^.r) and (g = pos^.g)) and (b = pos^.b)) then
      begin
         cc := pos^.id;
         break;
      end
      else
      begin
         if (max(r,pos^.r) - min(r,pos^.r)) <= rr then
         if (max(g,pos^.g) - min(g,pos^.g)) <= gg then
         if (max(b,pos^.b) - min(b,pos^.b)) <= bb then
         begin
            rr := max(r,pos^.r) - min(r,pos^.r);
            gg := max(g,pos^.g) - min(g,pos^.g);
            bb := max(b,pos^.b) - min(b,pos^.b);
            cc := pos^.id;
         end;
      end;
      pos := pos^.next;
   end;
   result := cc;
end;


//---------------------------------------------
// RGB Advanced Difference
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGBAdvDifference(const Colour : TColor; var List,Last:listed_colour) : byte;
type
   TColourDifferenceArray = array [0..255] of record
      R,G,B,RT,GT,BT,CR,CG,CB,ID : integer;
   end;
   TColourList = array [0..255] of record
   Colour: byte;
end;
var
   CDAStart,CDAFinal: byte;
   pos : listed_colour;
   r,g,b,x,xx,start2 : byte;
   ColourDifferenceArray : TColourDifferenceArray;
   ColourList : TColourList;
   ColourList_no : byte;
   DifferenceTotal,r3,g3,b3,r2,g2,b2 : integer;
   t,T0 : real;
   Temp : string;
begin
   Result := 0;

   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);
   t := 99999;

   // Populate Array
   x := 0;  // Specops Variable :P! It's a super-hero!!!
   pos := List;
   while pos <> nil do
   begin
      ColourDifferenceArray[x].RT := abs(Integer(r) - Integer(pos^.r));
      ColourDifferenceArray[x].GT := abs(Integer(g) - Integer(pos^.g));
      ColourDifferenceArray[x].BT := abs(Integer(b) - Integer(pos^.b));
      ColourDifferenceArray[x].R := ColourDifferenceArray[x].RT;
      ColourDifferenceArray[x].G := ColourDifferenceArray[x].GT;
      ColourDifferenceArray[x].B := ColourDifferenceArray[x].BT;
      ColourDifferenceArray[x].CR := pos^.r;
      ColourDifferenceArray[x].CG := pos^.g;
      ColourDifferenceArray[x].CB := pos^.b;
      ColourDifferenceArray[x].ID := pos^.id;
      inc(x);
      pos := pos^.next;
   end;

   // Now we have reduced the list to only uniques find the best difference total
   CDAStart := 0;
   CDAFinal := x-1;
   DifferenceTotal := 999999;

   for x := CDAStart to CDAFinal do
      if (ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B) < DifferenceTotal then
         DifferenceTotal := ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B;

   // Now we have the best difference value remove the rest
   for x := CDAStart to CDAFinal do
      if ColourDifferenceArray[x].RT <> 999999 then
         if (ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B) > DifferenceTotal then
            ColourDifferenceArray[x].RT := 999999;

   // Find the lowest R,G,B values
   r2 := 999999;
   g2 := 999999;
   b2 := 999999;

   for x := CDAStart to CDAFinal do
      if ColourDifferenceArray[x].RT <> 999999 then
         if ColourDifferenceArray[x].R <= r2 then
            if ColourDifferenceArray[x].G <= g2 then
               if ColourDifferenceArray[x].B <= b2 then
               begin
                  r2 := ColourDifferenceArray[x].R;
                  g2 := ColourDifferenceArray[x].G;
                  b2 := ColourDifferenceArray[x].B;
               end;

   // Remove colours with high differences
   for x := CDAStart to CDAFinal do
      if ColourDifferenceArray[x].RT <> 999999 then
         if ColourDifferenceArray[x].R > r2 then
            if ColourDifferenceArray[x].G > g2 then
               if ColourDifferenceArray[x].B > b2 then
                  ColourDifferenceArray[x].RT := 999999;

   // Make colour List
   ColourList_no := 0;

   for x := CDAStart to CDAFinal do
      if ColourDifferenceArray[x].RT <> 999999 then
      begin
         ColourList[ColourList_no].Colour := x;
         ColourList_no := ColourList_no+1;
      end;

   if ColourList_no = 1 then
   begin
      result := ColourDifferenceArray[ColourList[0].Colour].ID;
      exit;
   end;

   //find lowest value of t
   for x := 0 to ColourList_no do
      if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
      begin
         r3 := ColourDifferenceArray[ColourList[x].Colour].CR; //Integer(r) - ColourDifferenceArray[ColourList[x].Colour].RT; // GetRValue(SHPPalette[ColourList[x].Colour]);
         g3 := ColourDifferenceArray[ColourList[x].Colour].CG; //Integer(g) - ColourDifferenceArray[ColourList[x].Colour].GT;// GetGValue(SHPPalette[ColourList[x].Colour]);
         b3 := ColourDifferenceArray[ColourList[x].Colour].CB; //Integer(b) - ColourDifferenceArray[ColourList[x].Colour].BT;// GetBValue(SHPPalette[ColourList[x].Colour]);

         if (r = r3) and (g = g3) and (b = b3) then
            t0 := 0
         else
            try
               t0 := sqrt(((r - r3) * (r - r3)) + ((g - g3) * (g - g3)) + ((b - b3) * (b - b3)));
            except
               ShowMessage('Please, screenshot me and post it in PPM forums! r = ' + IntToStr(r) + ' and r3 = ' + IntToStr(r3) + ' and g = ' + IntToStr(g) + ' and g3 = ' + IntToStr(g3) + ' and b = ' + IntToStr(b) + ' and b3 = ' + IntToStr(b3));
               t0 := t+1;
            end;
         if t0 < t then
         begin
            t := t0;
      //    col := p;
         end;
      end;

   for x := 0 to ColourList_no do
      if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
      begin
         r3 := ColourDifferenceArray[ColourList[x].Colour].CR; //r - ColourDifferenceArray[ColourList[x].Colour].RT; // GetRValue(SHPPalette[ColourList[x].Colour]);
         g3 := ColourDifferenceArray[ColourList[x].Colour].CG; //g - ColourDifferenceArray[ColourList[x].Colour].GT;// GetGValue(SHPPalette[ColourList[x].Colour]);
         b3 := ColourDifferenceArray[ColourList[x].Colour].CB; //b - ColourDifferenceArray[ColourList[x].Colour].BT;// GetBValue(SHPPalette[ColourList[x].Colour]);
         if (r = r3) and (g = g3) and (b = b3) then
            t0 := 0
         else
            t0 := sqrt(((r - r3) * (r - r3)) + ((g - g3) * (g - g3)) + ((b - b3) * (b - b3)));
         if t0 > t then
         begin
            ColourDifferenceArray[ColourList[x].Colour].RT := 999999;
         end;
      end;

      if ColourList_no > 1 then
      begin
         for x := 0 to ColourList_no do
            if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
            begin
               result := ColourDifferenceArray[ColourList[0].Colour].ID;
               exit;
            end;
      end
      else
      begin
         result := ColourDifferenceArray[ColourList[0].Colour].ID;
         exit;
      end;
end;


//---------------------------------------------
// RGB Difference 2
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGBDifference(const Colour : Tcolor; var List,Last : listed_colour) : byte;
var
   t,col : integer; {p = counter, col: colour}
   r,g,b : byte; {BitMap colour: (r, g, b)}
   pos : listed_colour; {pointer}
begin
   // Get values of the colour (translating it to SHP style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);


   // Set position to the beggining of the list
   pos := List;

   // Set default value
   col := 0;
   t := 9999;

   // Here we start the search for the best colour.
   while pos <> nil do
   begin
      if (((r = pos^.r) and (g = pos^.g)) and (b = pos^.b)) then
      begin
         // If the colour matches exactly, col receives p.
         col := pos^.id;
         break;
      end
      else
      begin
         // If it doesnt match (as usual), it reads the p
         // colours. Compare the sum of the differences between
         // the bitmap and palette colours
         if (abs(r - pos^.r) + abs(g - pos^.g) + abs(b - pos^.b)) < t then
         begin
            t := abs(r - pos^.r) + abs(g - pos^.g) + abs(b - pos^.b);
            col := pos^.id;
         end;
      end;
      pos := pos^.next;
   end;
   result := col;
end;


//---------------------------------------------
// RGB (3D?) Full Difference
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGB3DFullDiff(const Colour : Tcolor; var List,Last:listed_colour) : byte;
var
   col : integer; {p = counter, col: colour}
   r,g,b : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
   t,t0:real; // Max difference allowed
   pos : listed_colour; {pointer}
begin
   // Get values of the colour (without translation it to SHP
   // style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // Set position to the beggining of the list
   pos := List;

   // Set default value
   col := 0;
   t := 9999;

   // Here we start the search for the best colour.
   while pos <> nil do
   begin
      if (((r = pos^.r) and (g = pos^.g)) and (b = pos^.b)) then
      begin
         // If the colour matches exactly, col receives p.
         col := pos^.id;
         break;
      end
      else
      begin
      // if it doesnt match (as usual), it reads the p colours.
      // compare the sum of the differences between the bitmap
      // and palette colours
         t0 := sqrt((abs(r - pos^.r) * abs(r - pos^.r)) + (abs(g - pos^.g) * abs(g - pos^.g)) + (abs(b - pos^.b) * abs(b - pos^.b)));
         if t0 < t then
         begin
            t := t0;
            col := pos^.id;
         end;
      end;
      pos := pos^.next;
   end;
   result := col;
end;


//---------------------------------------------
// RGB 3D Colour Plus
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGB3DColourPlus(const Colour : Tcolor; var List,Last:listed_colour) : byte;
var
   col : integer; {p = counter, col: colour}
   r,g,b : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
   rmult,gmult,bmult:real; {multipliers to priorize higher colours}
   t,t0:real; // Max difference allowed
   pos : listed_colour;
begin
   // Get values of the colour (without translation it to SHP
   // style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // Colour+ original adition goes here
   rmult := (r + 1) / 256;
   gmult := (g + 1) / 256;
   bmult := (b + 1) / 256;

   // Set default values
   col := 0;
   t := 9999;

   // Set position to the beggining of the list
   pos := List;

   // Here we start the search for the best colour.
   while pos <> nil do
   begin
      if (((r = pos^.r) and (g = pos^.g)) and (b = pos^.b)) then
      begin
         // If the colour matches exactly, col receives p.
         col := pos^.id;
         break;
      end
      else
      begin
         // if it doesnt match (as usual), it reads the p colours.
         // compare the sum of the differences between the bitmap
         // and palette colours
         t0 := sqrt((rmult * (abs(r - pos^.r) * abs(r - pos^.r))) + (gmult * (abs(g - pos^.g) * abs(g - pos^.g))) + (bmult * (abs(b - pos^.b) * abs(b - pos^.b))));
         if t0 < t then
         begin
            t := t0;
            col := pos^.id;
         end;
      end;
      pos := pos^.next;
   end;
   result := col;
end;


//---------------------------------------------
// RGB 3D Structuralis
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//---------------------------------------------
function RGB3DStructuralis(const Colour : Tcolor; var List,Last:listed_colour) : byte;
var
   col : integer; {p = counter, col: colour}
   r,g,b : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
   t,t0:real; // Max difference allowed
   pos : listed_colour; {pointer}
   candidate_list,candidate_last:listed_colour;
   rs,gs,bs,r0s,g0s,b0s: real; // colour structure values.
   top : byte;
begin
   // Get values of the colour (without translation it to SHP
   // style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // Set position to the beggining of the list
   pos := List;
   InitializeColourList(candidate_list,candidate_last);

   // Set default value
   col := 0;
   t := 9999;

   // Here we start the search for the best colour.
   while pos <> nil do
   begin
      if (((r = pos^.r) and (g = pos^.g)) and (b = pos^.b)) then
      begin
         // If the colour matches exactly, col receives p.
         col := pos^.id;
         ClearColourList(candidate_list,candidate_last);
         t := 0;
         break;
      end
      else
      begin
      // if it doesnt match (as usual), it reads the p colours.
      // compare the sum of the differences between the bitmap
      // and palette colours
         t0 := sqrt((abs(r - pos^.r) * abs(r - pos^.r)) + (abs(g - pos^.g) * abs(g - pos^.g)) + (abs(b - pos^.b) * abs(b - pos^.b)));
         if t0 < t then
         begin
            t := t0;
            col := pos^.id;
            ClearColourList(candidate_list,candidate_last);
            AddToColourList2(candidate_list,candidate_last,pos^.r,pos^.g,pos^.b,pos^.id);
         end
         // if the distance ties with the smaller, it divides the prize:
         else if t0 = t then
            AddToColourList2(candidate_list,candidate_last,pos^.r,pos^.g,pos^.b,pos^.id);
      end;
      pos := pos^.next;
   end;
   // Part 2: Check the structure of the colour.
   if (candidate_list = candidate_last) and (candidate_list <> nil) then
   begin
      col := candidate_list^.id;
      ClearColourList(candidate_list,candidate_last);
   end
   else if (t > 0) then
   begin
      // Now we see, which of the candidate colours gets closer to the average of the neighborhood.
      pos := candidate_list;

      // get colour structure value.
      top := max(r,max(g,b));
      if top <> 0 then
      begin
         rs := r / top;
         gs := g / top;
         bs := b / top;
      end
      else
      begin
         rs := 1;
         gs := 1;
         bs := 1;
      end;

      t := 1;
      while (pos <> nil) do
      begin
         // get colour structure value of the current colour.
         top := max(pos^.r,max(pos^.g,pos^.b));
         if top <> 0 then
         begin
            r0s := pos^.r / top;
            g0s := pos^.g / top;
            b0s := pos^.b / top;
         end
         else
         begin
            r0s := 1;
            g0s := 1;
            b0s := 1;
         end;

         t0 := sqrt((abs(rs - r0s) * abs(rs - r0s)) + (abs(gs - g0s) * abs(gs - g0s)) + (abs(bs - b0s) * abs(bs - b0s)));
         if t0 < t then
         begin
            t := t0;
            col := pos^.id;
         end;
         // Now, we get the smallest distance.
         pos := pos^.next;
      end;
   end;
   result := col;
end;


//---------------------------------------------
// RGB 3D Infurium
// -- PARAMS --
//    Colour   :
//    List     :
//    Last     :
//    Neighbor :
//    Start    :
//---------------------------------------------
Function RGB3DInfurium(const Color : Tcolor; var List,Last:listed_colour; const Neighbor : TNeighborhood; var Start:colour_element) : byte;
var
   col : integer;
   r,g,b,ncount:byte;
   maxH,maxW:integer;
   t,t0:real;
   r0,g0,b0:byte;
   xcounter,ycounter:byte;
   tn : real;
   colour,candidate_list,candidate_last:listed_colour;
   finalist_list,finalist_last:listed_colour;
begin
   // Get colours
   r := GetRValue(Color);
   g := GetGValue(Color);
   b := GetBValue(Color);

   // Initialize values
   colour := List;
   InitializeColourList(candidate_list,candidate_last);
   t := 9999;
   col := 0;

   // First Part Of Colour Detection: Get the best colours

   // Here we start the search for the best colour.
   while colour <> nil do
   begin
      r0 := colour^.r;
      g0 := colour^.g;
      b0 := colour^.b;

      if (((r = r0) and (g = g0)) and (b = b0)) then
      begin
         // If the colour matches exactly, ends.
         col := colour^.id;
         ClearColourList(candidate_list,candidate_last);
         t := 0;
         break;
      end
      else
      begin
      // if it doesnt match (as usual), it reads the colours.
      // compare the 3D distance of the colours
         t0 := sqrt((abs(r - r0) * abs(r - r0)) + (abs(g - g0) * abs(g - g0)) + (abs(b - b0) * abs(b - b0)));
      // if the distance is smaller, it gets the prize:
         if t0 < t then
         begin
            t := t0;
            ClearColourList(candidate_list,candidate_last);
            AddToColourList2(candidate_list,candidate_last,r0,g0,b0,colour^.id);
         end
         // if the distance ties with the smaller, it divides the prize:
         else if t0 = t then
            AddToColourList2(candidate_list,candidate_last,r0,g0,b0,colour^.id);
         colour := colour^.next;
      end;
   end;

   // Part 2: Check the neighborhood colours to find out which of them would fit more.
   // Bitmap.Canvas.Pixels[x,y]
   if (candidate_list = candidate_last) and (candidate_list <> nil) then
   begin
      col := candidate_list^.id;
      // 3.36: Add to bank if it only has one candidate.
      AddToBank(Start,candidate_list^.r,candidate_list^.g,candidate_list^.b,candidate_list^.id);
      ClearColourList(candidate_list,candidate_last);
   end
   else if (t > 0) then
   begin
      // Now we see, which of the candidate colours gets closer to the avarage of the neighborhood.
      colour := candidate_list;
      InitializeColourList(finalist_list,finalist_last);
      t := 9999;

      while colour <> nil do
      begin
         r0 := colour^.r;
         g0 := colour^.g;
         b0 := colour^.b;

         // compare the 3D distance of the colours of the neighborhood
         t0 := 0;
         for xcounter := Neighbor.xmin to Neighbor.xmax do
            for ycounter := Neighbor.ymin to Neighbor.ymax do
            begin
               t0 := t0 + sqrt((r0 - Neighbor.Data[xcounter,ycounter].r) * (r0 - Neighbor.Data[xcounter,ycounter].r) + (g0 - Neighbor.Data[xcounter,ycounter].g) * (g0 - Neighbor.Data[xcounter,ycounter].g) + (b0 - Neighbor.Data[xcounter,ycounter].b) * (b0 - Neighbor.Data[xcounter,ycounter].b));
            end;
         // if the distance is smaller, it gets the prize:
         if t0 < t then
         begin
            t := t0;
            ClearColourList(finalist_list,finalist_last);
            AddToColourList2(finalist_list,finalist_last,r0,g0,b0,colour^.id);
         end
         // if the distance ties with the smaller, it divides the prize:
         else if t0 = t then
            AddToColourList2(finalist_list,finalist_last,r0,g0,b0,colour^.id);
         colour := colour^.next;
      end;

      // The chances of this part happens is very hard... but this is
      // the final decision. It will choose the colour based on darkness
      // or light...
      if (finalist_list = finalist_last) and (finalist_list <> nil) then
      begin
         col := finalist_list^.id;
         ClearColourList(candidate_list,candidate_last);
      end
      else // Last Try, lighting value.
      begin
         // Determine lighting value.
         ncount := 0;
         tn := 0;
         for xcounter := Neighbor.xmin to Neighbor.xmax do
            for ycounter := Neighbor.ymin to Neighbor.ymax do
            begin
               tn := tn + sqrt((Neighbor.Data[xcounter,ycounter].r * Neighbor.Data[xcounter,ycounter].r) + (Neighbor.Data[xcounter,ycounter].g * Neighbor.Data[xcounter,ycounter].g) + (Neighbor.Data[xcounter,ycounter].b * Neighbor.Data[xcounter,ycounter].b));
               inc(ncount);
            end;
         // Get avarage.
         tn := tn / ncount;
         // determines if the colour is light or dark
         if tn >= 221.702503368816293573513131712752 then // this value is not random... used calculator :P and result was really 221,702503368816293573513131712752
         begin
            // colour is light
            colour := finalist_list;
            t := 9999;

            while colour <> nil do
            begin
               r0 := colour^.r;
               g0 := colour^.g;
               b0 := colour^.b;

               // if it doesnt match (as usual), it reads the colours.
               // compare the 3D distance of the colours
               t0 := sqrt((abs(255 - r0) * abs(255 - r0)) + (abs(255 - g0) * abs(255 - g0)) + (abs(255 - b0) * abs(255 - b0)));
               // if the distance is smaller, it gets the prize:
               if t0 < t then
               begin
                  t := t0;
                  col := colour^.id;
               end;
               colour := colour^.next;
            end;
            ClearColourList(finalist_list,finalist_last);
         end
         else
         begin
            // colour is dark
            colour := finalist_list;
            t := 9999;

            while colour <> nil do
            begin
               r0 := colour^.r;
               g0 := colour^.g;
               b0 := colour^.b;

   // if it doesnt match (as usual), it reads the colours.
   // compare the 3D distance of the colours
               t0 := sqrt((r0 * r0) + (g0 * g0) + (b0 * b0));
   // if the distance is smaller, it gets the prize:
               if t0 < t then
               begin
                  t := t0;
                  col := colour^.id;
               end;
               colour := colour^.next;
            end;
            ClearColourList(finalist_list,finalist_last);
         end;
      end;
   end;
   // Return results
   result := col;
end;










// Old Trash

function getpalettecolour(Palette: TPalette; Colour : Tcolor) : integer;
var
   p,col,ccol : integer;
   r,g,b : byte;
   t : single;
begin
   col := -1;

   for p := 0 to 255 do
      if Colour = Palette[p] then
         col := p;

   t := 10000;

   if col = -1 then
   begin
      ccol := -1;
      for p := 0 to 255 do
      begin
         r := GetRValue(ColortoRGB(Colour)) - GetRValue(ColortoRGB(Palette[p])) ;
         g := GetGValue(ColortoRGB(Colour)) - GetGValue(ColortoRGB(Palette[p])) ;
         b := GetBValue(ColortoRGB(Colour)) - GetBValue(ColortoRGB(Palette[p])) ;

         if Sqrt(r*r + g*g + b+b) < t then
         begin
            t := Sqrt(r*r + g*g + b+b);
            ccol := p;
         end;
      end;

      if (ccol = -1) or (t = 10000) then
         ccol := TRANSPARENT;
      col := ccol;
   end;

   result := col;
end;

Procedure AddLighting(var r,g,b: byte);
begin
   // If colour can receive some light, then...
   if ((r <= 252) and (g <= 252) and (b <= 252)) then
   begin
      r := r + 4;
      g := g + 4;
      b := b + 4;
   end;
end;

function GetBestColour2(Colour : TColor; SHPPalette : TPalette; start,final:byte; t : real) : byte;
type
   TColourDifferenceArray = array [0..255] of record
      R,G,B,RT,GT,BT : integer;
   end;
   TColourList = array [0..255] of record
      Colour: byte;
   end;
var
   r,g,b,x,xx,start2 : byte;
   ColourDifferenceArray : TColourDifferenceArray;
   ColourList : TColourList;
   ColourList_no : byte;
   DifferenceTotal,r3,g3,b3,r2,g2,b2 : integer;
   T0 : real;
   Temp : string;
begin
   if start = 0 then
      start2 := 1
   else
      start2 := start;

   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // Populate Array
   for x := Start to Final do
   begin
      ColourDifferenceArray[x].RT := r - GetRValue(SHPPalette[x]);
      ColourDifferenceArray[x].GT := g - GetGValue(SHPPalette[x]);
      ColourDifferenceArray[x].BT := b - GetBValue(SHPPalette[x]);
      ColourDifferenceArray[x].R := max(ColourDifferenceArray[x].RT,-ColourDifferenceArray[x].RT);
      ColourDifferenceArray[x].G := max(ColourDifferenceArray[x].GT,-ColourDifferenceArray[x].GT);
      ColourDifferenceArray[x].B := max(ColourDifferenceArray[x].BT,-ColourDifferenceArray[x].BT);
   end;

   // Remove similer colours
   {for x := Start to Final do
      for xx := Start2 to Final do
         if x <> xx then
            if ColourDifferenceArray[x].RT <> 999999 then
               if (ColourDifferenceArray[x].RT = ColourDifferenceArray[xx].RT) then
                  if (ColourDifferenceArray[x].GT = ColourDifferenceArray[xx].GT) then
                     if (ColourDifferenceArray[x].BT = ColourDifferenceArray[xx].BT) then
                        ColourDifferenceArray[xx].RT := 999999;    }


   // Now we have reduced the list to only uniques find the best difference total
   DifferenceTotal := 999999;

   for x := Start to Final do
      if ColourDifferenceArray[x].RT <> 999999 then
         if (ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B) < DifferenceTotal then
            DifferenceTotal := ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B;

   // Now we have the best difference value remove the rest
   for x := Start to Final do
      if ColourDifferenceArray[x].RT <> 999999 then
         if (ColourDifferenceArray[x].R + ColourDifferenceArray[x].G + ColourDifferenceArray[x].B) > DifferenceTotal then
            ColourDifferenceArray[x].RT := 999999;

   //showmessage(inttostr(DifferenceTotal));

   // Find the lowest R,G,B values
   r2 := 999999;
   g2 := 999999;
   b2 := 999999;

   for x := Start to Final do
      if ColourDifferenceArray[x].RT <> 999999 then
         if ColourDifferenceArray[x].R <= r2 then
            if ColourDifferenceArray[x].G <= g2 then
               if ColourDifferenceArray[x].B <= b2 then
               begin
                  r2 := ColourDifferenceArray[x].R;
                  g2 := ColourDifferenceArray[x].G;
                  b2 := ColourDifferenceArray[x].B;
               end;

   // Remove colours with high differences
   for x := Start to Final do
      if ColourDifferenceArray[x].RT <> 999999 then
         if ColourDifferenceArray[x].R > r2 then
            if ColourDifferenceArray[x].G > g2 then
               if ColourDifferenceArray[x].B > b2 then
                  ColourDifferenceArray[x].RT := 999999;

   // Make colour List
   ColourList_no := 0;

   for x := Start to Final do
      if ColourDifferenceArray[x].RT <> 999999 then
      begin
         ColourList[ColourList_no].Colour := x;
         ColourList_no := ColourList_no+1;
      end;

   if ColourList_no = 1 then
   begin
      result := ColourList[0].Colour;
      exit;
   end;

   //find lowest value of t
   for x := 0 to ColourList_no do
      if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
      begin
         r3 := GetRValue(SHPPalette[ColourList[x].Colour]);
         g3 := GetGValue(SHPPalette[ColourList[x].Colour]);
         b3 := GetBValue(SHPPalette[ColourList[x].Colour]);
         t0 := sqrt((abs(r - r3) * abs(r - r3)) + (abs(g - g3) * abs(g - g3)) + (abs(b - b3) * abs(b - b3)));
         if t0 < t then
         begin
            t := t0;
            // col := p;
         end;
      end;

   for x := 0 to ColourList_no do
      if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
      begin
         r3 := GetRValue(SHPPalette[ColourList[x].Colour]);
         g3 := GetGValue(SHPPalette[ColourList[x].Colour]);
         b3 := GetBValue(SHPPalette[ColourList[x].Colour]);
         t0 := sqrt((abs(r - r3) * abs(r - r3)) + (abs(g - g3) * abs(g - g3)) + (abs(b - b3) * abs(b - b3)));
         if t0 > t then
         begin
            ColourDifferenceArray[ColourList[x].Colour].RT := 999999;
         end;
      end;

   if ColourList_no > 1 then
   begin
      {Temp := 'GetBestColour2 - Posible colours'+#13#13+'Original Colour:'+#13;

      Temp := Temp + 'Colour:'+ColorToString(colour)+ ' R:'+inttostr(GetRValue(colour))+ ' G:'+inttostr(GetGValue(colour))+ ' B:'+inttostr(GetBValue(colour))+#13#13+'List:'+#13;

      for x := 0 to ColourList_no-1 do
         Temp := Temp + 'Index: '+inttostr(ColourList[x].Colour) + ' Colour:'+ColorToString(SHPPalette[ColourList[x].Colour])+ ' R:'+inttostr(GetRValue(SHPPalette[ColourList[x].Colour]))+ ' G:'+inttostr(GetGValue(SHPPalette[ColourList[x].Colour]))+ ' B:'+inttostr(GetBValue(SHPPalette[ColourList[x].Colour]))+#13;
      showmessage(temp);    }

      for x := 0 to ColourList_no do
         if ColourDifferenceArray[ColourList[x].Colour].RT <> 999999 then
         begin
            result := ColourList[0].Colour;
            exit;
         end;
   end
   else
   begin
      result := ColourList[0].Colour;
      exit;
   end;
end;

function GetBestColour(Colour : TColor; SHPPalette : TPalette; start,final:byte; rr,gg,bb : byte) : byte;
var
   r,g,b,r2,g2,b2 : byte;
   c,cc : integer;
begin
   cc := -1;
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   for c := start to final do
   begin
      r2 := GetRValue(SHPPalette[c]);
      g2 := GetGValue(SHPPalette[c]);
      b2 := GetBValue(SHPPalette[c]);
      if (((r = r2) and (g = g2)) and (b = b2)) then
      begin
         cc := c;
         break;
      end
      else
      begin
         if (max(r,r2) - min(r,r2)) <= rr then
            if (max(g,g2) - min(g,g2)) <= gg then
               if (max(b,b2) - min(b,b2)) <= bb then
               begin
                  rr := max(r,r2) - min(r,r2);
                  gg := max(g,g2) - min(g,g2);
                  bb := max(b,b2) - min(b,b2);
                  cc := c;
               end;
      end;
   end;
   result := cc;
end;

function GetBestColourLight(Colour : TColor; SHPPalette : TPalette; start,final:byte; var rr,gg,bb:byte) : byte;
var
   r,g,b,r2,g2,b2 : byte;
   c,cc : integer;
begin
   cc := -1;
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);
   // the big difference. Result is lighter or distorted.
   AddLighting(r,g,b);

   for c := start to final do
   begin
      r2 := GetRValue(SHPPalette[c]);
      g2 := GetGValue(SHPPalette[c]);
      b2 := GetBValue(SHPPalette[c]);
      if (((r = r2) and (g = g2)) and (b = b2)) then
      begin
         cc := c;
         break;
      end
      else
      begin
         if (max(r,r2) - min(r,r2)) <= rr then
            if (max(g,g2) - min(g,g2)) <= gg then
               if (max(b,b2) - min(b,b2)) <= bb then
               begin
                  rr := max(r,r2) - min(r,r2);
                  gg := max(g,g2) - min(g,g2);
                  bb := max(b,b2) - min(b,b2);
                  cc := c;
               end;
      end;
   end;
   result := cc;
end;

function getbestcolour_banshee(Colour : Tcolor;Palette: TPalette; start,final:byte; var t:integer) : integer;
var
   p,col : integer; {p = counter, col: colour}
   r,g,b,r0,b0,g0 : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
begin
   // Get values of the colour (translating it to SHP style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // it the difference gets above 96, you get a transparent
   col := -1;

   // Here we start the search for the best colour.
   for p := start to final do
   begin
      r0 := GetRValue(Palette[p]);
      g0 := GetGValue(Palette[p]);
      b0 := GetBValue(Palette[p]);

      if (((r = r0) and (g = g0)) and (b = b0)) then
      begin
         // If the colour matches exactly, col receives p.
         col := p;
         t := 0;
         break;
      end
      else
      begin
         // if it doesnt match (as usual), it reads the p colours.
         // compare the sum of the differences between the bitmap
         // and palette colours
         if (abs(r - r0) + abs(g - g0) + abs(b - b0)) < t then
         begin
            t := abs(r - r0) + abs(g - g0) + abs(b - b0);
            col := p;
         end;
      end;
   end;
   // bye bye function, it's over... result is the number of the
   // colour of the palette.
   result := col;
end;

function getbestcolour_banshee_maxquality(Colour : Tcolor;Palette: TPalette; start,final:byte; var t:integer) : integer;
var
   p,col : integer; {p = counter, col: colour}
   r,g,b,r0,b0,g0 : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
   t0:integer; // Max difference allowed
begin
   // Get values of the colour (without translation it to SHP style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   col := -1;
   // Here we start the search for the best colour.
   for p := start to final do
   begin
      r0 := GetRValue(Palette[p]);
      g0 := GetGValue(Palette[p]);
      b0 := GetBValue(Palette[p]);

      if (((r = r0) and (g = g0)) and (b = b0)) then
      begin
         // If the colour matches exactly, col receives p.
         col := p;
         t := 0;
         break;
      end
      else
      begin
         // if it doesnt match (as usual), it reads the p colours.
         // compare the sum of the differences between the bitmap
         // and palette colours
         t0 := round(sqrt((abs(r - r0) * abs(r - r0)) + (abs(g - g0) * abs(g - g0)) + (abs(b - b0) * abs(b - b0))));
         if t0 < t then
         begin
            t := t0;
            col := p;
         end;
      end;
   end;
   // bye bye function, it's over... result is the number of the
   // colour of the palette.
   result := col;
end;

function getbestcolour_banshee_maxquality_colourplus(Colour : Tcolor;Palette: TPalette; start,final:byte; var t:integer) : integer;
var
   p,col : integer; {p = counter, col: colour}
   r,g,b,r0,b0,g0 : byte; {BitMap colour: (r, g, b), Palette (r0,g0,b0)}
   rmult,gmult,bmult:real; {multipliers to priorize higher colours}
   t0:integer; // Max difference allowed
begin
   // Get values of the colour (without translation it to SHP style)
   r := GetRValue(Colour);
   g := GetGValue(Colour);
   b := GetBValue(Colour);

   // Colour+ original adition goes here
   rmult := (r + 1) / 256;
   gmult := (g + 1) / 256;
   bmult := (b + 1) / 256;

   // it the difference gets above 96, you get a transparent
   col := -1;

   // Here we start the search for the best colour.
   for p := start to final do
   begin
      r0 := GetRValue(Palette[p]);
      g0 := GetGValue(Palette[p]);
      b0 := GetBValue(Palette[p]);

      if (((r = r0) and (g = g0)) and (b = b0)) then
      begin
         // If the colour matches exactly, col receives p.
         col := p;
         t:=0;
         break;
      end
      else
      begin
         // if it doesnt match (as usual), it reads the p colours.
         // compare the sum of the differences between the bitmap
         // and palette colours
         t0 := round(sqrt((rmult * (abs(r - r0) * abs(r - r0))) + (gmult * (abs(g - g0) * abs(g - g0))) + (bmult * (abs(b - b0) * abs(b - b0)))));
         if t0 < t then
         begin
            t := t0;
            col := p;
         end;
      end;
   end;
   // bye bye function, it's over... result is the number of the
   // colour of the palette.
   result := col;
end;

procedure getpalettecolour3(Palette: TPalette; Colour : Tcolor; alg,start,final : byte; var col,t:integer; var rr,gg,bb:byte);
begin
   if alg = 0 then
      alg := 1;

   if alg = 1 then
      col := GetBestColour(Colour,Palette,start,final,rr,gg,bb)
   else if alg = 2 then
      col := GetBestColour2(Colour,Palette,start,final,t)//GetBestColourLight(Colour,SHPPalette,start,final,rr,gg,bb)
   else if alg = 3 then
      col := getbestcolour_banshee(Colour,Palette,start,final,t)
   else if alg = 4 then
      col := getbestcolour_banshee_maxquality(Colour,Palette,start,final,t)
   else if alg = 5 then
      col := getbestcolour_banshee_maxquality_colourplus(Colour,Palette,start,final,t)
   else if alg = Infurium then
      col := getbestcolour_banshee_maxquality(Colour,Palette,start,final,t);
end;


function getpalettecolour_new(Palette: TPalette; Colour : Tcolor; Start:colour_element; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
var
   col,t : integer;
   rr,gg,bb : byte;
begin
   // reseting stuff
   col := 0;
   t := 9999;

   rr := 255;
   gg := 255;
   bb := 255;

   // Check if the colour was already checked before. It speed
   // up repetitive colours
   col := ColourInBank(Start,GetRValue(Colour),GetGValue(Colour),GetBValue(Colour));
   if (col = -1) then
   begin
      // If it ignores shadows, the conversion starts on 2.
      if IgnoreGlowingColours then
      begin
         if not IgnoreShadow then
            if IgnoreBackGround then
               getpalettecolour3(Palette,Colour,alg,1,1,col,t,rr,gg,bb)
            else
               getpalettecolour3(Palette,Colour,alg,0,1,col,t,rr,gg,bb);
         getpalettecolour3(Palette,Colour,alg,16,239,col,t,rr,gg,bb);
      end
      else
      begin
         if IgnoreShadow then
         begin
            if not IgnoreBackGround then
               getpalettecolour3(Palette,Colour,alg,0,0,col,t,rr,gg,bb);
            getpalettecolour3(Palette,Colour,alg,2,255,col,t,rr,gg,bb);
         end
         else
            if not IgnoreBackGround then
               getpalettecolour3(Palette,Colour,alg,0,255,col,t,rr,gg,bb)
            else
               getpalettecolour3(Palette,Colour,alg,1,255,col,t,rr,gg,bb);
      end;
      AddToBank(Start,GetRValue(Colour),GetGValue(Colour),GetBValue(Colour),col);
   end;
   result := col;
end;


function getpalettecolour2(Palette: TPalette; Colour : Tcolor; BGColour:Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
var
   col,t : integer;
   rr,gg,bb : byte;
begin
   // reseting stuff
   col := 0;
   t := 9999;
   rr := 255;
   gg := 255;
   bb := 255;

   if (not (colour = bgcolour)) or (IgnoreBackground) then
   begin
      // If it ignores shadows, the conversion starts on 2.
      if IgnoreGlowingColours then
      begin
         if not IgnoreShadow then
            getpalettecolour3(Palette,Colour,alg,1,1,col,t,rr,gg,bb);
         getpalettecolour3(Palette,Colour,alg,16,239,col,t,rr,gg,bb);
      end
      else
      begin
         if IgnoreShadow then
            getpalettecolour3(Palette,Colour,alg,2,255,col,t,rr,gg,bb)
         else
            getpalettecolour3(Palette,Colour,alg,1,255,col,t,rr,gg,bb);
      end;
   end;
   result := col;
end;


function getpalettecolour2Diff(Palette: TPalette; Colour : Tcolor; BGColour:Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
var
   col : integer;
   rr,gg,bb : byte;
   T : integer;
begin
   // reseting stuff
   col := 0;
   t := 9999;

   if (not (colour = bgcolour)) or (IgnoreBackground) then
   begin
      // If it ignores shadows, the conversion starts on 2.
      if IgnoreGlowingColours then
      begin
         if not IgnoreShadow then
            getpalettecolour3(Palette,Colour,alg,1,1,col,t,rr,gg,bb);
         getpalettecolour3(Palette,Colour,alg,16,239,col,t,rr,gg,bb);
      end
      else
      begin
         if IgnoreShadow then
            getpalettecolour3(Palette,Colour,alg,2,255,col,t,rr,gg,bb)
         else
            getpalettecolour3(Palette,Colour,alg,1,255,col,t,rr,gg,bb);
      end;
   end;

   rr := abs(GetRValue(Colour) - GetRValue(Palette[col]));
   gg := abs(GetGValue(Colour) - GetGValue(Palette[col]));
   bb := abs(GetBValue(Colour) - GetBValue(Palette[col]));
   result := rr+gg+bb;
end;

Procedure SetFrameImageFrmBMP2(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean);
var
   x,y,maxH,maxW : integer;
   r,g,b:byte;
   Start:colour_element;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);

   // Initializing Colour Bank
   InitializeBank(Start);
   if not IgnoreBackground then
   begin
      r := GetRValue(BGColour);
      g := GetGValue(BGColour);
      b := GetBValue(BGColour);
   end
   else // Aditional trash to make it work for cameos
   begin
      r := GetRValue(Palette[1]);
      g := GetGValue(Palette[1]);
      b := GetBValue(Palette[1]);
   end;
   AddToBank(Start,r,g,b,0);
   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         shp.data[Frame].frameimage[x,y] := getpalettecolour_new(Palette,Bitmap.Canvas.Pixels[x,y],Start,alg,IgnoreBackground,IgnoreShadow,IgnoreGlowingColours);
      end;
   ClearBank(Start);
end;


// Neighborhood Checker Procedure
Procedure SetFrameImageUsingNeighborhoodChecker(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean);
var
   col : integer;
   x,y,maxH,maxW : integer;
   r,g,b,ncount:byte;
   Start:colour_element;
   List,Last:listed_colour;
   t,t0:integer;
   r0,g0,b0,r1,g1,b1:byte;
   colour,candidate_list,candidate_last,neighbor_list,neighbor_last:listed_colour;
   finalist_list,finalist_last:listed_colour;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);
   col := 0;
  
   if not IgnoreBackground then
      Palette[0] := BGColour;


   // Prepare list of colours that can be checked:
   InitializeColourList(List,Last);
   if IgnoreGlowingColours then
   begin
      if not IgnoreShadow then
         if IgnoreBackGround then
            AddToColourList(List,Last,Palette,1,1)
         else
            AddToColourList(List,Last,Palette,0,1);
      AddToColourList(List,Last,Palette,16,239);
   end
   else
   begin
      if IgnoreShadow then
      begin
         if not IgnoreBackGround then
            AddToColourList(List,Last,Palette,0,0);
         AddToColourList(List,Last,Palette,2,255);
      end
      else
        if not IgnoreBackGround then
           AddToColourList(List,Last,Palette,0,255)
        else
           AddToColourList(List,Last,Palette,1,255);
   end;

   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         // Get colours
         r := GetRValue(Bitmap.Canvas.Pixels[x,y]);
         g := GetGValue(Bitmap.Canvas.Pixels[x,y]);
         b := GetBValue(Bitmap.Canvas.Pixels[x,y]);

         // Initializing values
         colour := List;
         InitializeColourList(candidate_list,candidate_last);
         t := 9999;

         // First Part Of Colour Detection: Get the best colours

         // Here we start the search for the best colour.
         while colour <> nil do
         begin
            r0 := colour^.r;
            g0 := colour^.g;
            b0 := colour^.b;

            if (((r = r0) and (g = g0)) and (b = b0)) then
            begin
               // If the colour matches exactly, ends.
               col := colour^.id;
               ClearColourList(candidate_list,candidate_last);
               t := 0;
               break;
            end
            else
            begin
               // if it doesnt match (as usual), it reads the colours.
               // compare the 3D distance of the colours
               t0 := round(sqrt((abs(r - r0) * abs(r - r0)) + (abs(g - g0) * abs(g - g0)) + (abs(b - b0) * abs(b - b0))));
               // if the distance is smaller, it gets the prize:
               if t0 < t then
               begin
                  t := t0;
                  ClearColourList(candidate_list,candidate_last);
                  AddToColourList2(candidate_list,candidate_last,r0,g0,b0,colour^.id);
               end
               // if the distance ties with the smaller, it divides the prize:
               else if t0 = t then
                  AddToColourList2(candidate_list,candidate_last,r0,g0,b0,colour^.id);
               colour := colour^.next;
            end;
         end;

         // Part 2: Check the neighborhood colours to find out which of them would
         // fit more.
         // Bitmap.Canvas.Pixels[x,y]
         if (candidate_list = candidate_last) and (candidate_list <> nil) then
            col := candidate_list^.id
         else if (t > 0) then
         begin
            InitializeColourList(neighbor_list,neighbor_last);

            // Add neighbor colours
            if x > 0 then
            begin
               if y > 0 then
                  AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x-1,y-1]),GetGValue(Bitmap.Canvas.Pixels[x-1,y-1]),GetBValue(Bitmap.Canvas.Pixels[x-1,y-1]),0);
               AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x-1,y]),GetGValue(Bitmap.Canvas.Pixels[x-1,y]),GetBValue(Bitmap.Canvas.Pixels[x-1,y]),0);
               if y < (maxH - 1) then
                  AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x-1,y+1]),GetGValue(Bitmap.Canvas.Pixels[x-1,y+1]),GetBValue(Bitmap.Canvas.Pixels[x-1,y+1]),0);
            end;
            if y > 0 then
               AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x,y-1]),GetGValue(Bitmap.Canvas.Pixels[x,y-1]),GetBValue(Bitmap.Canvas.Pixels[x,y-1]),0);
            AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x,y]),GetGValue(Bitmap.Canvas.Pixels[x,y]),GetBValue(Bitmap.Canvas.Pixels[x,y]),0);
            if y < (maxH - 1) then
               AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x,y+1]),GetGValue(Bitmap.Canvas.Pixels[x,y+1]),GetBValue(Bitmap.Canvas.Pixels[x,y+1]),0);
            if x < (MaxW - 1) then
            begin
               if y > 0 then
                  AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x+1,y-1]),GetGValue(Bitmap.Canvas.Pixels[x+1,y-1]),GetBValue(Bitmap.Canvas.Pixels[x+1,y-1]),0);
               AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x+1,y]),GetGValue(Bitmap.Canvas.Pixels[x+1,y]),GetBValue(Bitmap.Canvas.Pixels[x+1,y]),0);
               if y < (maxH - 1) then
                  AddToColourList2(neighbor_list,neighbor_last,GetRValue(Bitmap.Canvas.Pixels[x+1,y+1]),GetGValue(Bitmap.Canvas.Pixels[x+1,y+1]),GetBValue(Bitmap.Canvas.Pixels[x+1,y+1]),0);
            end;

            // Now we get an avarage colour from the neighborhood:
            colour := neighbor_list;
            r1 := 0;
            g1 := 0;
            b1 := 0;
            ncount := 0;
            while colour <> nil do
            begin
               r0 := colour^.r;
               g0 := colour^.g;
               b0 := colour^.b;

               r1 := r1 + r0;
               g1 := g1 + g0;
               b1 := b1 + b0;
               inc(ncount);
               colour := colour^.next;
            end;
            r1 := r1 div ncount;
            g1 := g1 div ncount;
            b1 := b1 div ncount;

            // Now we see, which of the candidate colours gets closer to the avarage of the neighborhood.
            colour := candidate_list;
            InitializeColourList(finalist_list,finalist_last);
            t := 9999;

            while colour <> nil do
            begin
               r0 := colour^.r;
               g0 := colour^.g;
               b0 := colour^.b;

               // if it doesnt match (as usual), it reads the colours.
               // compare the 3D distance of the colours
               t0 := round(sqrt((abs(r1 - r0) * abs(r1 - r0)) + (abs(g1 - g0) * abs(g1 - g0)) + (abs(b1 - b0) * abs(b1 - b0))));
               // if the distance is smaller, it gets the prize:
               if t0 < t then
               begin
                  t := t0;
                  ClearColourList(finalist_list,finalist_last);
                  AddToColourList2(finalist_list,finalist_last,r0,g0,b0,colour^.id);
               end
               // if the distance ties with the smaller, it divides the prize:
               else if t0 = t then
                  AddToColourList2(finalist_list,finalist_last,r0,g0,b0,colour^.id);
               colour := colour^.next;
            end;

            // The chances of this part happens is very hard... but this is
            // the final decision. It will choose the colour based on darkness
            // or light...
            if (finalist_list = finalist_last) and (finalist_list <> nil) then
               col := finalist_list^.id
            // determines if the colour is light or dark
            else if round(sqrt((abs(255 - r1) * abs(255 - r1)) + (abs(255 - g1) * abs(255 - g1)) + (abs(255 - b1) * abs(255 - b1)))) >= round(sqrt((r1 * r1) + (g1 * g1) + (b1 * b1))) then
            begin
               // colour is light
               colour := candidate_list;
               t := 9999;

               while colour <> nil do
               begin
                  r0 := colour^.r;
                  g0 := colour^.g;
                  b0 := colour^.b;

                  // if it doesnt match (as usual), it reads the colours.
                  // compare the 3D distance of the colours
                  t0 := round(sqrt((abs(255 - r0) * abs(255 - r0)) + (abs(255 - g0) * abs(255 - g0)) + (abs(255 - b0) * abs(255 - b0))));
                  // if the distance is smaller, it gets the prize:
                  if t0 < t then
                  begin
                     t := t0;
                     col := colour^.id;
                  end;
                  colour := colour^.next;
               end;
            end
            else
            begin
               // colour is dark
               colour := candidate_list;
               t := 9999;

               while colour <> nil do
               begin
                  r0 := colour^.r;
                  g0 := colour^.g;
                  b0 := colour^.b;

                  // if it doesnt match (as usual), it reads the colours.
                  // compare the 3D distance of the colours
                  t0 := round(sqrt((r0 * r0) + (g0 * g0) + (b0 * b0)));
                  // if the distance is smaller, it gets the prize:
                  if t0 < t then
                  begin
                     t := t0;
                     col := colour^.id;
                  end;
                  colour := colour^.next;
               end;
            end;
         end;

         shp.data[Frame].frameimage[x,y] := col;
      end;
end;


Function SetFrameImageFrmBMP2Diff(const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreBackground,IgnoreShadow,IgnoreGlowingColours:Boolean) : integer;
var
   x,y,rr,gg,bb,col : integer;
begin
   result := 0;

   for y := 0 to Bitmap.Height-1 do
      for x := 0 to Bitmap.Width-1 do
      begin
         col := getpalettecolour2(Palette,Bitmap.Canvas.Pixels[x,y],BGColour,alg,IgnoreBackground,IgnoreShadow,IgnoreGlowingColours);
         rr := abs(GetRValue(Bitmap.Canvas.Pixels[x,y]) - GetRValue(Palette[col]));
         gg := abs(GetGValue(Bitmap.Canvas.Pixels[x,y]) - GetGValue(Palette[col]));
         bb := abs(GetBValue(Bitmap.Canvas.Pixels[x,y]) - GetBValue(Palette[col]));
         result := result + rr+gg+bb;
      end;
end;


Procedure SetFrameImageFrmBMP2NoBG(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap; BGColour : Tcolor; alg : byte; IgnoreShadow,IgnoreGlowingColours:Boolean);
var
   x,y,maxH,maxW : integer;
   Start:colour_element;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);
   InitializeBank(Start);
   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         if Bitmap.Canvas.Pixels[x,y] <> BGColour then
            shp.data[Frame].frameimage[x,y] := getpalettecolour_new(Palette,Bitmap.Canvas.Pixels[x,y],Start,alg,true,IgnoreShadow,IgnoreGlowingColours);
      end;
   ClearBank(Start);
end;


Procedure SetFrameImageFrmBMP2WithShadows(var SHP:TSHP; const Frame:integer;Bitmap : TBitmap; BGColour : Tcolor);
var
   x,y,maxH,maxW : integer;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);

   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         if Bitmap.Canvas.Pixels[x,y] = BGColour then
            shp.data[Frame].frameimage[x,y] := 0
         else
            shp.data[Frame].frameimage[x,y] := 1;
      end;
end;


Procedure SetFrameImageFrmBMP(var SHP:TSHP; const Frame:integer;Palette:TPalette;Bitmap : TBitmap);
var
   x,y,maxH,maxW : integer;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);
   // Clear the image of colour (fills with the transparent colour)
   //BMP.Canvas.Brush.Color := palette[TRANSPARENT];
   //BMP.Canvas.FillRect(rect(0,0,BMP.Width,BMP.Height));

   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         shp.data[Frame].frameimage[x,y] := getpalettecolour(Palette,Bitmap.Canvas.Pixels[x,y]);
      end;
end;


Procedure SetFrameImageFrmBMPForAutoShadows(var SHP:TSHP; const Frame:integer;const Palette:TPalette;const Bitmap : TBitmap; shadowcolour:byte);
var
   x,y,maxH,maxW : integer;
begin
   maxH := min(SHP.Header.Height,Bitmap.Height);
   maxW := min(SHP.Header.Width,Bitmap.Width);
   // Clear the image of colour (fills with the transparent colour)
   //BMP.Canvas.Brush.Color := palette[TRANSPARENT];
   //BMP.Canvas.FillRect(rect(0,0,BMP.Width,BMP.Height));

   // Populate the image pixel by pixel
   for y := 0 to maxH-1 do
      for x := 0 to maxW-1 do
      begin
         if (Bitmap.Canvas.Pixels[x,y] <> Palette[0]) and (shp.data[Frame].frameimage[x,y] = 0) then
            shp.data[Frame].frameimage[x,y] := shadowcolour;
      end;
end;


function AutoSelectALG(Bitmap : TBitmap; Palette:TPalette; BGColour : TColor; BcNone,ssShadow,ssIgnoreLAstColours : Boolean) : byte;
var
   Diff,difft,x : integer;
   alg : byte;
begin
   alg := 1;
   diff := 999999999; // Max value
   for x := 1 to MaxAlg do
   begin
      difft := SetFrameImageFrmBMP2Diff(1,Palette,Bitmap,BGColour,x,bcNone,ssShadow,ssIgnoreLastColours);
      if difft < diff then
      begin
         diff := difft;
         alg := x;
      end;
   end;
   Result := alg;
end;


function AutoSelectALG_Progress(ProgressBar : TProgressBar; Bitmap : TBitmap; Palette: TPalette; BGColour : TColor; BcNone,ssShadow,ssIgnoreLAstColours : Boolean) : byte; overload;
var
   Diff,difft,x : integer;
   alg : byte;
begin
   alg := 1;
   diff := 999999999; // Max value
   ProgressBar.Visible := true;
   ProgressBar.Max := MaxAlg-1;
   for x := 1 to MaxAlg do
   begin
      ProgressBar.Position := x-1;
      ProgressBar.Refresh;
      difft := SetFrameImageFrmBMP2Diff(1,Palette,Bitmap,BGColour,x,bcNone,ssShadow,ssIgnoreLastColours);
      if difft < diff then
      begin
         diff := difft;
         alg := x;
      end;
   end;
   Result := alg;
end;

end.
