 // SHP_ENGINE_IMAGE.PAS
 // By Banshee & Stucuk

{
14 Dec 2003 Stucuk: Fixed MoveFrameImagesDown, minor error.
17 Dec 2003 Stucuk: Added function GetBMPFromImageFile and Procedure Save_Bmp_As_Jpeg
18 Dec 2003 Stucuk: Added function SaveImageFileFromBMP
19 Dec 2003 Stucuk: Added procedure FrameImage_Section_Move


}

unit Shp_Engine_Image;

interface

uses
   Windows, Dialogs, SysUtils, ComCtrls, Classes, ExtCtrls, Shp_File, Palette,
   Graphics, Math, Jpeg, Controls, PCXCtrl, SHP_Colour_Bank, Colour_list,
   SHP_Engine_CCMs, SHP_Shadows, SHP_Image;

// Misc Functions
function AntiAlias_S2(Bitmap: tbitmap; BGColour: TColor): TBitmap;

// Misc Procedures
procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer;
   Source, Dest: TSelectArea);

// Data From DataBuffer
procedure DrawImageWithShadow(SHP: TSHP; Frame: integer; Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);
procedure DrawShadowWithImage(SHP: TSHP; Frame: integer; Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);
procedure DrawImage(SHP: TSHP; Frame: integer; Flood, Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);

// Using TPaintBox
procedure DrawFrameImageCanvas(SHP: TSHP; Frame, Zoom: integer;
   Flood, Grayscale: boolean; Palette: TPalette; var PaintBox: TPaintBox);

implementation

// Misc

procedure FrameImage_Section_Move(var SHP: TSHP; Frame: integer;
   Source, Dest: TSelectArea);
var
   x, y, XDifference, YDifference: integer;
   FrameImage: array of array of byte;
begin

   XDifference := Max(Source.X1, Source.X2) - Min(Source.X1, Source.X2);
   YDifference := Max(Source.Y1, Source.Y2) - Min(Source.Y1, Source.Y2);

   SetLength(FrameImage, SHP.Header.Width, SHP.Header.Height);

   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         if (x >= Min(Source.X1, Source.X2)) and (x <= Max(Source.X1, Source.X2)) and
            (y >= Min(Source.Y1, Source.Y2)) and (y < Max(Source.Y1, Source.Y2)) then
            FrameImage[x, y] := 0
         else
            FrameImage[x, y] := SHP.Data[Frame].FrameImage[x, y];

   for x := 0 to XDifference - 1 do
      for y := 0 to YDifference - 1 do
         if ((Min(Dest.X1, Dest.X2) + x) < SHP.Header.Width) and
            ((Min(Dest.Y1, Dest.Y2) + y) < SHP.Header.Height) then // Check its in range
            if ((Min(Dest.X1, Dest.X2) + x) >= 0) and ((Min(Dest.Y1, Dest.Y2) + y) >= 0) then
               // Check its in range
            begin

               if ((Min(Source.X1, Source.X2) + x) < SHP.Header.Width) and
                  ((Min(Source.Y1, Dest.Y2) + y) < SHP.Header.Height) and
                  ((Min(Source.X1, Source.X2) + x) >= 0) and ((Min(Source.Y1, Source.Y2) + y) >= 0) then
                  // Check its in range
                  FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] :=
                     SHP.Data[Frame].FrameImage[Min(Source.X1, Source.X2) + x, Min(Source.Y1, Source.Y2) + y]
               else
                  FrameImage[Min(Dest.X1, Dest.X2) + x, Min(Dest.Y1, Dest.Y2) + y] := 0;
               // Source is out fo bounds, defult to 0;

            end;

   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         SHP.Data[Frame].FrameImage[x, y] := FrameImage[x, y];

end;

 // Drawing Procedures
 // Misc

// Data From DataBuffer

procedure DrawImageWithShadow(SHP: TSHP; Frame: integer; Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);
begin

   if HasShadows(SHP) then  // Make sure SHP has shadows
   begin
      DrawImage(SHP, GetShadowFromOposite(SHP, Frame), True, False, Palette, Image1); // Draw Shadow
      DrawImage(SHP, Frame, False, GrayScale, Palette, Image1); // Draw Owner
   end
   else
      DrawImage(SHP, Frame, True, GrayScale, Palette, Image1); // Draw Owner

end;

procedure DrawShadowWithImage(SHP: TSHP; Frame: integer; Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);
begin
   if HasShadows(SHP) then  // Make sure SHP has shadows
   begin
      DrawImage(SHP, Frame, True, False, Palette, Image1);
      DrawImage(SHP, GetShadowOposite(SHP, frame), False, GrayScale, Palette, Image1);
   end
   else
      DrawImage(SHP, Frame, True, GrayScale, Palette, Image1); // Draw Owner
end;

procedure DrawImage(SHP: TSHP; Frame: integer; Flood, Grayscale: boolean;
   Palette: TPalette; var Image1: Timage);
var
   x, y, c, xx, yy: integer;
begin

   // Check to see frame is not above the number of images
   if Frame > shp.Header.NumImages then
      Exit;

   //check to see it is not below 1  (images start at 1)
   if Frame < 1 then
      Exit;

   // Set image width n height
   image1.Picture.Bitmap.Width  := SHP.header.Width;
   image1.Picture.Bitmap.Height := SHP.header.Height;

   // Get the position of where to draw the frame from
   xx := SHP.Data[Frame].header_image.x;
   yy := SHP.Data[Frame].header_image.y;

   // Clear the image of colour (fills with the transparent colour)
   image1.Picture.Bitmap.Canvas.Brush.Color := palette[TRANSPARENT];
   if flood then // Only clear image if flood is set to true
      image1.Picture.Bitmap.Canvas.FillRect(
         rect(0, 0, image1.Picture.Bitmap.Width, image1.Picture.Bitmap.Height));
   c := -1;

   // Populate the image pixel by pixel
   for y := 0 to shp.Data[Frame].header_image.cy - 1 do
      for x := 0 to shp.Data[Frame].header_image.cx - 1 do
      begin
         c := c + 1;

         if shp.Data[Frame].databuffer[c] <> TRANSPARENT then
            // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
            if grayscale then
               image1.Picture.Bitmap.Canvas.Pixels[xx + x, yy + y] :=
                  colourtogray(palette[shp.Data[Frame].databuffer[c]])
            else
               image1.Picture.Bitmap.Canvas.Pixels[xx + x, yy + y] :=
                  palette[shp.Data[Frame].databuffer[c]];
      end;

end;


// Drawing Using TPaintBox Canvas insted of TImage

procedure DrawFrameImageCanvas(SHP: TSHP; Frame, Zoom: integer;
   Flood, Grayscale: boolean; Palette: TPalette; var PaintBox: TPaintBox);
var
   x, y: integer;
begin

   // Check to see frame is not above the number of images
   if Frame > shp.Header.NumImages then
      Exit;

   //check to see it is not below 1  (images start at 1)
   if Frame < 1 then
      Exit;

   // Zoom can't be 0.
   if Zoom < 1 then
      Zoom := 1;


   // Clear the image of colour (fills with the transparent colour)
   PaintBox.Canvas.Brush.Color := palette[TRANSPARENT];
   if flood then // Only clear image if flood is set to true
      PaintBox.Canvas.FillRect(rect(0, 0, SHP.header.Width * zoom, SHP.header.Height * zoom));

   // Populate the image pixel by pixel
   if zoom > 1 then
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin

            if grayscale then
               PaintBox.Canvas.Brush.Color :=
                  colourtogray(palette[shp.Data[Frame].frameimage[x, y]])
            else
               PaintBox.Canvas.Brush.Color := palette[shp.Data[Frame].frameimage[x, y]];

            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               PaintBox.Canvas.FillRect(Rect((x * zoom), (y * zoom), (x * zoom) + zoom, (y * zoom) + zoom));
         end
   else
      for y := 0 to SHP.header.Height - 1 do
         for x := 0 to SHP.header.Width - 1 do
         begin

            if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
               // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
               if grayscale then
                  PaintBox.Canvas.Pixels[x, y] :=
                     colourtogray(palette[shp.Data[Frame].frameimage[x, y]])
               else
                  PaintBox.Canvas.Pixels[x, y] := palette[shp.Data[Frame].frameimage[x, y]];
         end;

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

end.
