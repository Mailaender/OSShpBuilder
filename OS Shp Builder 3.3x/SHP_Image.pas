unit SHP_Image;

interface

uses
   Windows, SHP_File, Palette, ExtCtrls, Classes, Graphics, SHP_Shadows, SysUtils, Math;

type
   TColourMatch = record
      Original: TColor;
      Match:    byte;
   end;

   TShadowMatch = array [0..255] of TColourMatch;

 // Drawing Procedures/Functions
 // Misc
procedure SwapValues(var i1, i2 : integer);
procedure ForceInRangeValues(var baseArea, twinArea : TSelectArea; minX, maxX, minY, maxY : integer);
function ColourToTRGB32(const Colour: Tcolor): TRGB32;
function OpositeColour(const color: TColor): tcolor;
function colourtogray(const colour: cardinal): cardinal;
function AntiAlias_S2(Bitmap: tbitmap; BGColour: TColor): TBitmap;

// Frame Image Drawing
procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea; copyBackground : boolean; backgroundColor : byte);
procedure DrawFrameImageWithShadow(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
procedure DrawShadowWithFrameImage(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
procedure DrawFrameImage(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale, Preview: boolean; var Palette: TPalette; var Image: TImage);
procedure AssignBitmapToImage(var Bitmap: TBitmap; Image: TImage);

 // Drawing Procedures/Functions
 // Misc
function CreateBmpArray(var Bmp: array of TBitmap; var SHP: TSHP; ShadowType: integer; FrameRange: boolean; StartFrame, EndFrame: integer; Shadow_Match: TShadowMatch; SHPPalette: TPalette; Zoom: integer): integer;
function CreateTextureDataPointer(SHP: TSHP; FrameStart, FrameEnd: integer; Palette: TPalette; var Width, Height, InRow, NumRows: integer): Pointer;

implementation


uses FormMain;


//---------------------------------------------
// Colour To RGB32
//---------------------------------------------
function ColourToTRGB32(const Colour: Tcolor): TRGB32;
begin
   Result.R := GetRValue(Colour);
   Result.G := GetGValue(Colour);
   Result.B := GetBValue(Colour);
end;


//---------------------------------------------
// Get Opposite Colour
//---------------------------------------------
function OpositeColour(const Color: TColor): TColor;
var
   r, g, b:   byte;
   NewColour: TColor;
begin
   R := 255 - GetRValue(Color);
   G := 255 - GetGValue(Color);
   B := 255 - GetBValue(Color);

   NewColour := RGB(R, G, B);

   // If Same Colour then Pick Another.
   if (R = GetRValue(Color)) or (G = GetGValue(Color)) or (B = GetBValue(Color)) then
      NewColour := RGB(R + (GetRValue(color) div 2), G + (GetGValue(color) div 2), B + (GetBValue(color) div 2));

   // Fixes Prob With Gray On UnitTem.pal
   if ((R > 120) and (R < 130)) or ((G > 120) and (G < 130)) or ((B > 120) and (B < 130)) then
      NewColour := RGB(R + (GetRValue(color) div 2), G + (GetGValue(color) div 2), B + (GetBValue(color) div 2));

   Result := NewColour;
end;


//---------------------------------------------
// Get Grayscale of Colour
//---------------------------------------------
function colourtogray(const colour: cardinal): cardinal;
var
   temp: char;
begin
   temp   := char((GetBValue(colour) * 29 + GetGValue(colour) * 150 + GetRValue(colour) * 77) div 256);
   Result := RGB(Ord(temp), Ord(temp), Ord(temp));
end;


//---------------------------------------------
// Draw Frame Image
//---------------------------------------------
procedure DrawFrameImage(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale, Preview: boolean; var Palette: TPalette; var Image: TImage);
var
   x, y:   word;
   Bitmap: TBitmap;
begin
   Bitmap := TBitmap.Create;

   Image.Picture.Bitmap.Width := SHP.header.Width * zoom;
   Image.Picture.Bitmap.Height := SHP.header.Height * zoom;

   Bitmap.Width  := image.Picture.Bitmap.Width;
   Bitmap.Height := image.Picture.Bitmap.Height;


   // CLEAR IMAGE
   if flood then 
   begin
      Bitmap.Canvas.Brush.Color := palette[TRANSPARENT];
      Bitmap.Canvas.FillRect(rect(0, 0, SHP.header.Width * zoom, SHP.header.Height * zoom));
   end
   else
      Bitmap.Canvas.Draw(0, 0, Image.Picture.Bitmap);


   // DRAW FRAME
   for y := 0 to SHP.header.Height - 1 do
      for x := 0 to SHP.header.Width - 1 do
      begin
         if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
         begin
            if grayscale then
               Bitmap.Canvas.Brush.Color := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original
            else
            begin
               Bitmap.Canvas.Brush.Color := palette[shp.Data[Frame].frameimage[x, y]];
            end;

            Bitmap.Canvas.FillRect(Rect((x * zoom), (y * zoom), (x * zoom) + zoom, (y * zoom) + zoom));
         end;
      end;

   Image.Canvas.Draw(0, 0, Bitmap);
   Bitmap.Free;
end;


//---------------------------------------------
// Draw Frame with Shadow Image
//---------------------------------------------
procedure DrawFrameImageWithShadow(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
begin
   DrawFrameImage(SHP, Shadow_Match, GetShadowFromOposite(SHP, Frame), Zoom, True, False, Preview, Palette, Image);
   DrawFrameImage(SHP, Shadow_Match, Frame, Zoom, False, GrayScale, Preview, Palette, Image);
end;


//---------------------------------------------
// Draw Shadow with Frame Image
//---------------------------------------------
procedure DrawShadowWithFrameImage(var SHP: TSHP; Frame, Zoom: integer; Grayscale, Preview: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TImage);
begin
   DrawFrameImage(SHP, Shadow_Match, Frame, Zoom, True, False, Preview, Palette, Image); 
   DrawFrameImage(SHP, Shadow_Match, GetShadowOposite(SHP, frame), Zoom, False, GrayScale, Preview, Palette, Image);
end;


//---------------------------------------------
// Draw Frame to Bitmap
//---------------------------------------------
procedure DrawFrameImageToBMP(var SHP: TSHP; var Shadow_Match: TShadowMatch; Frame, Zoom: integer; Flood, Grayscale: boolean; var Palette: TPalette; var Image: TBitmap);
var
   x, y: word;
begin
   //BANSHEE LEAVE THIS HERE THINGS ACTUALY NEED IT!
   Image.Width  := SHP.header.Width * zoom;
   Image.Height := SHP.header.Height * zoom;

   // Clear the image of colour (fills with the transparent colour)
   if flood then // Only clear image if flood is set to true
   begin
      Image.Canvas.Brush.Color := palette[TRANSPARENT];
      Image.Canvas.FillRect(rect(0, 0, SHP.header.Width * zoom, SHP.header.Height * zoom));
   end;

   // Populate the image pixel by pixel
   if zoom > 1 then
   begin
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin
            if grayscale then
            begin
               Image.Canvas.Brush.Color := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original;// colourtogray(palette[shp.data[Frame].frameimage[x,y]])
            end
            else
            begin
               Image.Canvas.Brush.Color := palette[shp.Data[Frame].frameimage[x, y]];
            end;

            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               Image.Canvas.FillRect(Rect((x * zoom), (y * zoom), (x * zoom) + zoom, (y * zoom) + zoom));
         end
   end
   else
   begin
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin
            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               if grayscale then
                  Image.Canvas.Pixels[x, y] := Shadow_Match[shp.Data[Frame].frameimage[x, y]].Original// colourtogray(palette[shp.data[Frame].frameimage[x,y]])
               else
                  Image.Canvas.Pixels[x, y] := palette[shp.Data[Frame].frameimage[x, y]];
         end;
   end;
end;


procedure DrawFrameImageWithShadowToBMP(var SHP: TSHP; Frame, Zoom: integer; Grayscale: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TBitmap);
begin
   DrawFrameImageToBMP(SHP, Shadow_Match, GetShadowFromOposite(SHP, Frame), Zoom, True, False, Palette, Image); // Draw Shadow
   DrawFrameImageToBMP(SHP, Shadow_Match, Frame, Zoom, False, GrayScale, Palette, Image); //Draw Owner
end;

procedure DrawShadowWithFrameImageToBMP(var SHP: TSHP; Frame, Zoom: integer; Grayscale: boolean; var Palette: TPalette; var Shadow_Match: TShadowMatch; var Image: TBitmap);
begin
   DrawFrameImageToBMP(SHP, Shadow_Match, Frame, Zoom, True, False, Palette, Image); // Draw Shadow
   DrawFrameImageToBMP(SHP, Shadow_Match, GetShadowOposite(SHP, frame), Zoom, False, GrayScale, Palette, Image); //Draw Owner
end;

// Modifyed ver of AntiAliasRect from janFX by Jan Verhoeven
function AntiAlias_S2(Bitmap: tbitmap; BGColour: TColor): TBitmap;
var
   x, y: integer;
   p0, p1, p2, r1: pbytearray;
   p01, p02, p03, p21, p22, p23, p31, p32, p33, p41, p42, p43: byte;
begin
   Bitmap.PixelFormat := pf24bit;
   Result := TBitmap.Create;
   Result.Width := Bitmap.Width;
   Result.Height := Bitmap.Height;
   Result.PixelFormat := pf24bit;

   Result.Canvas.Brush.Color := BGColour;
   Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));

   for y := 1 to Result.Height - 2 do
   begin
      p0 := Bitmap.ScanLine[y - 1];
      p1 := Bitmap.scanline[y];
      p2 := Bitmap.ScanLine[y + 1];
      r1 := Result.ScanLine[y];
      for x := 1 to Result.Width - 2 do
         if RGB(p1[x * 3 + 2], p1[x * 3 + 1], p1[x * 3]) <> BGColour then
         begin
            // Should stop BG Interfearence
            if RGB(p0[x * 3 + 2], p0[x * 3 + 1], p0[x * 3]) <> BGColour then
            begin
               p01 := p0[x * 3];
               p02 := p0[x * 3 + 1];
               p03 := p0[x * 3 + 2];
            end
            else
            begin
               p01 := p1[x * 3];
               p02 := p1[x * 3 + 1];
               p03 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p2[x * 3 + 2], p2[x * 3 + 1], p2[x * 3]) <> BGColour then
            begin
               p21 := p2[x * 3];
               p22 := p2[x * 3 + 1];
               p23 := p2[x * 3 + 2];
            end
            else
            begin
               p21 := p1[x * 3];
               p22 := p1[x * 3 + 1];
               p23 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p1[(x - 1) * 3 + 2], p1[(x - 1) * 3 + 1], p1[(x - 1) * 3]) <> BGColour then
            begin
               p31 := p1[(x - 1) * 3];
               p32 := p1[(x - 1) * 3 + 1];
               p33 := p1[(x - 1) * 3 + 2];
            end
            else
            begin
               p31 := p1[x * 3];
               p32 := p1[x * 3 + 1];
               p33 := p1[x * 3 + 2];
            end;

            // Should stop BG Interfearence
            if RGB(p1[(x + 1) * 3 + 2], p1[(x + 1) * 3 + 1], p1[(x + 1) * 3]) <> BGColour then
            begin
               p41 := p1[(x + 1) * 3];
               p42 := p1[(x + 1) * 3 + 1];
               p43 := p1[(x + 1) * 3 + 2];
            end
            else
            begin
               p41 := p1[x * 3];
               p42 := p1[x * 3 + 1];
               p43 := p1[x * 3 + 2];
            end;

            r1[x * 3]     := (p01 + p21 + p31 + p41) div 4;
            r1[x * 3 + 1] := (p02 + p22 + p32 + p42) div 4;
            r1[x * 3 + 2] := (p03 + p23 + p33 + p43) div 4;
         end;
   end;
end;


//---------------------------------------------
// Move Selected Area - With Background
// REMARK:
// * Source selection must be in BOUNDS.
//---------------------------------------------
procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer; Source, Dest: TSelectArea; copyBackground : boolean; backgroundColor : byte);
var
   x, y, maxY, maxX : integer;
   srcArea: array of array of byte;
begin
   // Validate 
   if(backgroundColor < 0) or (backgroundColor > 255) then
      copyBackground := false;

   // Swap - Source / Destination
   if(Source.X1 > Source.X2) then
   begin
      SwapValues(Source.X1, Source.X2);
      SwapValues(Dest.X1, Dest.X2);
   end;
   if(Source.Y1 > Source.Y2) then
   begin
      SwapValues(Source.Y1, Source.Y2);
      SwapValues(Dest.Y1, Dest.Y2);
   end;

   ForceInRangeValues(Source, Dest, 0, SHP.Header.Width, 0, SHP.Header.Height);
   ForceInRangeValues(Dest, Source, 0, SHP.Header.Width, 0, SHP.Header.Height);

   // Copy original frame
   maxX := Source.X2 - Source.X1;
   maxY := Source.Y2 - Source.Y1;
   SetLength(srcArea, maxX + 1, maxY + 1);
   for x := 0 to  maxX do
   begin
      for y := 0 to maxY  do
      begin
         srcArea[x,y] := SHP.Data[Frame].FrameImage[Source.X1 + x, Source.Y1 + y];
      end;
   end;
      

   // Copy Source to Destination
   maxX := 0;
   maxY := 0;
   for x := Dest.X1 to Dest.X2 do
   begin
      for y := Dest.Y1 to Dest.Y2 do
      begin
         // Skip if necessary
         if (not copyBackground) and (srcArea[maxX, maxY] = 0) then continue;

          SHP.Data[Frame].FrameImage[x, y] := srcArea[maxX, maxY];
          maxY := maxY + 1;
      end;
      maxX := maxX + 1;
      maxY := 0;
   end;

end;


//---------------------------------------------
// Resize BaseArea so that it's in bounds.
// TwinArea is the area associated with it.
//---------------------------------------------
procedure ForceInRangeValues(var baseArea, twinArea : TSelectArea; minX, maxX, minY, maxY : integer);
begin
   // Force in-range values
   if(baseArea.X1 < minX) then
   begin
      twinArea.X1 := twinArea.X1 + Abs(baseArea.X1);
      baseArea.X1 := minX;
   end;
   if(baseArea.Y1 < minY) then
   begin
      twinArea.Y1 := twinArea.Y1 + Abs(baseArea.Y1);
      baseArea.Y1 := minY;
   end;
   if(baseArea.X2 > maxX) then
   begin
      twinArea.X2 := twinArea.X2 - (baseArea.X2 - maxX);
      baseArea.X2 := maxX;
   end;
   if(baseArea.Y2 > maxY) then
   begin
      twinArea.Y2 := twinArea.Y2 - (baseArea.Y2 - maxY);
      baseArea.Y2 := maxY;
   end;
end;

//---------------------------------------------
// Swap values of two integers.
//---------------------------------------------
procedure SwapValues(var i1, i2 : integer);
var
   tmp : integer;
begin
   tmp := i1;
   i1 := i2;
   i2 := tmp;
end;


//---------------------------------------------
// Assign Bitmap to image
//---------------------------------------------
procedure AssignBitmapToImage(var Bitmap: TBitmap; Image: TImage);
begin
   Image.picture.Bitmap.Width  := Bitmap.Width;
   Image.picture.Bitmap.Height := Bitmap.Height;
   Image.picture.Bitmap.Canvas.Draw(0, 0, Bitmap);
   Bitmap.Free;
end;

function CreateBmpArray(var Bmp: array of TBitmap; var SHP: TSHP; ShadowType: integer; FrameRange: boolean; StartFrame, EndFrame: integer; Shadow_Match: TShadowMatch; SHPPalette: TPalette; Zoom: integer): integer;
var
   X, SF, SE, Length: integer;
begin
   // Detect length by checking if it uses shadows or not.
   if ShadowType = 0 then
      Length := SHP.Header.NumImages
   else
      Length := SHP.Header.NumImages div 2;

   // Detect range
   if FrameRange then
   begin
      SF := StartFrame;
      SE := EndFrame;
   end
   else
   begin
      SF := 1;// 1???
      SE := Length;
   end;

   // Write result
   Result := SE - SF + 1;
   // Build bitmaps.
   for x := SF to SE do
   begin
      bmp[x - SF] := TBitmap.Create;
      bmp[x - SF].TransparentColor := SHPPalette[0];
      if ShadowType = 2 then
         DrawFrameImageWithShadowToBMP(SHP, x, Zoom, False, SHPPalette, Shadow_Match, bmp[x - SF])
      else
         DrawFrameImageToBMP(SHP, Shadow_Match, x, Zoom, True, False, SHPPalette, bmp[x - SF]);
   end;
end;

procedure AddColour(R, G, B, A: byte; var P: Pointer);
begin
   byte(P^) := R;
   Inc(integer(P));
   byte(P^) := G;
   Inc(integer(P));
   byte(P^) := B;
   Inc(integer(P));
   byte(P^) := A;
   Inc(integer(P));
end;

type
   TColour = record
      R, G, B, A: byte;
   end;

function ColorToTColour(Color: TColor): TColour;
begin
   Result.R := GetRValue(Color);
   Result.G := GetGValue(Color);
   Result.B := GetBValue(Color);
   Result.A := 255;

end;

procedure AddFrameRow(SHP: TSHP; Palette: TPalette; Frame, y: integer; var P: Pointer);
var
   x:      integer;
   Colour: TColour;
begin
   for x := SHP.header.Width - 1 downto 0 do
   begin
      if (frame > 0) and (shp.Data[Frame].frameimage[x, y] <> TRANSPARENT) then
         Colour := ColorToTColour(palette[shp.Data[Frame].frameimage[x, y]])
      else
      begin
         Colour.R := 0;
         Colour.G := 0;
         Colour.B := 252;
         Colour.A := 0;
      end;
      AddColour(Colour.R, Colour.G, Colour.B, Colour.A, P);
   end;
end;


function CreateTextureDataPointer(SHP: TSHP; FrameStart, FrameEnd: integer; Palette: TPalette; var Width, Height, InRow, NumRows: integer): Pointer;
var
   x, y, Frame, c: integer;
   P: Pointer;
begin
   Width  := SHP.header.Width * (FrameEnd - FrameStart + 1);
   Height := SHP.header.Height;
   InRow  := FrameEnd - FrameStart + 1;

   if Width > 64 * 64 then
   begin
      InRow := Trunc((64 * 64) / (SHP.header.Width));
      //FrameEnd := FrameStart + InRow-1;
      Width := SHP.header.Width * (InRow);
      SetRoundMode(rmUp);
      NumRows := Round((FrameEnd - FrameStart + 1) / InRow);
      Height  := (NumRows) * SHP.header.Height;
      SetRoundMode(rmNearest);
   end;

   GetMem(Result, Width * Height * 4);
   //addr
   P     := Addr(integer(Result^));
   Frame := FrameStart + 1;
   C     := 0;

   repeat
      for y := SHP.header.Height - 1 downto 0 do
         for x := 0 to InRow - 1 do
         begin
            if Frame + x + c > FrameEnd then
               AddFrameRow(SHP, Palette, 0, y, P) // add fake image to fill gaps
            else
               AddFrameRow(SHP, Palette, Frame + x + c, y, P);
         end;
      Inc(C, InRow);
   until C >= FrameEnd - FrameStart + 1;
end;


end.
