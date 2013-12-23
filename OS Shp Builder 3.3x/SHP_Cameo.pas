unit SHP_Cameo;

interface

uses
   Windows, SysUtils, ComCtrls, Classes, ExtCtrls, Shp_File, Palette, Graphics,
   Controls, SHP_Engine_CCMs, Colour_List, SHP_Colour_Bank;

// Built Following Blades RA2 Cameo Tutorial
procedure DrawCameoBar_DarkSide_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_LightSide_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_LightTop_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);

// Built using Kravvitz's Cameos
procedure DrawCameoBar_Kravvitz(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_Kravvitz2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);

// 2
procedure DrawCameoBar_DarkSides_s1(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_LightSides_s1(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);

// WW1
procedure DrawCameoBar_DarkSides_s2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_LightSides_s2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);

// TD & RA1
procedure DrawCameo_TDBevel(var SHP: TSHP);
procedure DrawCameo_RA1Bevel(var SHP: TSHP);

// Misc
procedure DrawCameoBar_TextBar(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoBar_TextBar2(var SHP: TSHP; var SHPPalette: TPalette; Value: byte;
   ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoText(var SHP: TSHP; const Text: string; ImageList: TImageList;
   ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameoText2(var SHP: TSHP; const Text: string;
   ImageList: TImageList; ALG: integer; var List, Last: listed_colour;
   var Start: Colour_element);
procedure DrawEliteIconRA2(var SHP: TSHP; const ImageList: TImageList;
   EI, ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
procedure DrawCameo_Transparent(var SHP: TSHP);
procedure DrawDark_Cameo(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
procedure DrawLight_Cameo(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
procedure DrawLight_Cameo2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
function WorkOutTextBarDV(SHP: TSHP; var SHPPalette: TPalette): integer;

implementation

uses FormMain;

//Cameo Procedures/Fuctions
procedure DrawCameoBar_TextBar(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawDark_Cameo(SHP, SHPPalette, Value, ALG, 0, SHP.Header.Width - 1,
      SHP.Header.Height - 7, SHP.Header.Height - 1, List, Last, Start);
end;

procedure DrawCameoBar_TextBar2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawDark_Cameo(SHP, SHPPalette, Value, ALG, 0, SHP.Header.Width - 1,
      SHP.Header.Height - 13, SHP.Header.Height - 1, List, Last, Start);
end;

procedure DrawCameoBar_DarkSide_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawDark_Cameo(SHP, SHPPalette, Value, ALG, 0, 0, 2, SHP.Header.Height - 3, List, Last, Start);
end;

procedure DrawCameoBar_LightSide_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawLight_Cameo(SHP, SHPPalette, Value, ALG, SHP.Header.Width - 2,
      SHP.Header.Width - 2, 1, SHP.Header.Height - 2, List, Last, Start);
end;

procedure DrawCameoBar_LightTop_Blade(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
var
   x, y: integer;
   c:    tcolor;
   r, g, b: byte;
begin
   DrawLight_Cameo(SHP, SHPPalette, Value, ALG, 4, 33, 1, 2, List, Last, Start);
   DrawLight_Cameo(SHP, SHPPalette, Value, ALG, 34, 34, 2, 2, List, Last, Start);

   for x := 1 to 3 do
      for y := 1 to 2 do
         if not ((x = 1) and (y = 1)) then
         begin
            c := SHPPalette[SHP.Data[1].FrameImage[34, 2]];

            R := GetRValue(c);
            G := GetGValue(c);
            B := GetBValue(c);

            if r + Value * 2 > 255 then
               r := 255
            else
               r := r + Value * 2;

            if g + Value * 2 > 255 then
               g := 255
            else
               g := g + Value * 2;

            if b + Value * 2 > 255 then
               b := 255
            else
               b := b + Value * 2;

            SHP.Data[1].FrameImage[x, y] := LoadPixel(List, Last, ALG, RGB(r, g, b));
         end;

end;

procedure DrawCameo_Transparent(var SHP: TSHP);
var
   W, H: integer;
begin
   W := SHP.Header.Width - 1;
   H := SHP.Header.Height - 1;

   SHP.Data[1].FrameImage[0, 0] := 0;
   SHP.Data[1].FrameImage[0, 1] := 0;
   SHP.Data[1].FrameImage[1, 0] := 0;

   SHP.Data[1].FrameImage[W, H]     := 0;
   SHP.Data[1].FrameImage[W - 1, H] := 0;
   SHP.Data[1].FrameImage[W, H - 1] := 0;

   SHP.Data[1].FrameImage[W, 0]     := 0;
   SHP.Data[1].FrameImage[W, 1]     := 0;
   SHP.Data[1].FrameImage[W - 1, 0] := 0;

   SHP.Data[1].FrameImage[0, H]     := 0;
   SHP.Data[1].FrameImage[1, H]     := 0;
   SHP.Data[1].FrameImage[0, H - 1] := 0;
end;

procedure DrawCameo_TDBevel(var SHP: TSHP);
var
   W, H: integer;
   x:    integer;
begin
   W := SHP.Header.Width - 1;
   H := SHP.Header.Height - 1;

   // write first line.
   for x := 0 to (W - 1) do
      SHP.Data[1].FrameImage[x, 0] := 193;
   // write first row
   for x := 0 to (H - 1) do
      SHP.Data[1].FrameImage[0, x] := 193;
   // write colour #14
   SHP.Data[1].FrameImage[0, H] := 14;
   SHP.Data[1].FrameImage[W, 0] := 14;
   // write last line.
   for x := 1 to (W - 1) do
      SHP.Data[1].FrameImage[x, H] := 12;
   // write last row
   for x := 1 to H do
      SHP.Data[1].FrameImage[W, x] := 12;
end;

procedure DrawCameo_RA1Bevel(var SHP: TSHP);
var
   W, H: integer;
   x:    integer;
begin
   W := SHP.Header.Width - 1;
   H := SHP.Header.Height - 1;

   // write first line.
   for x := 0 to (W - 1) do
      SHP.Data[1].FrameImage[x, 0] := 15;
   // write first row
   for x := 0 to (H - 1) do
      SHP.Data[1].FrameImage[0, x] := 15;
   // write colour #14
   SHP.Data[1].FrameImage[0, H] := 14;
   SHP.Data[1].FrameImage[W, 0] := 14;
   // write last line.
   for x := 1 to (W - 1) do
      SHP.Data[1].FrameImage[x, H] := 12;
   // write last row
   for x := 1 to H do
      SHP.Data[1].FrameImage[W, x] := 12;
end;


procedure DrawEliteIconRA2(var SHP: TSHP; const ImageList: TImageList;
   EI, ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
var
   Bitmap: TBitmap;
   x, y:   integer;
begin
   Bitmap := TBitmap.Create;

   Bitmap.Width  := ImageList.Width + 1;
   Bitmap.Height := ImageList.Height + 1;

   ImageList.Draw(Bitmap.Canvas, 0, 0, EI);

   if alg = 0 then
      alg := 4;

   for x := 2 to ImageList.Width + 1 do
      for y := 2 to ImageList.Height + 1 do
         if Bitmap.Canvas.Pixels[x - 2, y - 2] <> clblue then
            SHP.Data[1].FrameImage[x, y] :=
               LoadPixel(Bitmap, Start, List, Last, alg, x - 2, y - 2, False);

   Bitmap.Free;
end;

function WorkOutCharLength(Index: integer; ImageList: TImageList): integer;
var
   Bitmap: tbitmap;
   x, y:   integer;
begin
   Bitmap := TBitmap.Create;
   Bitmap.Width := ImageList.Width;
   Bitmap.Height := ImageList.Height;

   ImageList.Draw(Bitmap.Canvas, 0, 0, Index);

   x := 2;

   for y := 0 to 5 do
      if Bitmap.Canvas.Pixels[2, y] <> clblue then
         x := 3;

   for y := 0 to 5 do
      if Bitmap.Canvas.Pixels[3, y] <> clblue then
         x := 4;

   for y := 0 to 5 do
      if Bitmap.Canvas.Pixels[4, y] <> clblue then
         x := 5;

   for y := 0 to 5 do
      if Bitmap.Canvas.Pixels[5, y] <> clblue then
         x := 6;

   Result := x;
   Bitmap.Free;
end;

procedure AddCharToBMP(var Bitmap: TBitmap; const Text: string;
   Index: integer; ImageList: TImageList);
var
   C: string[1];
   I, X, W: integer;
begin
   Bitmap.Height := ImageList.Height;

   C := AnsiUpperCase(copy(Text, Index, 1));

   I := -1;

   for X := 0 to 9 do
      if C = IntToStr(X) then
         I := X;

   for x := 65 to 65 + 25 do
      if C = char(X) then
         I := X - 65 + 10;

   if C = '.' then
      I := 36;


   if C = ' ' then
      I := -2;

   if I = -1 then
      exit; // Illegal charactor exit;

   W := Bitmap.Width;
   if I = -2 then
      Bitmap.Width := Bitmap.Width + 3
   else
      Bitmap.Width := Bitmap.Width + WorkOutCharLength(I, ImageList);

   if I > 0 then
      ImageList.Draw(Bitmap.Canvas, W, 0, I);
end;

procedure AddCharToBMP2(var Bitmap: TBitmap; const Text: string;
   Index: integer; ImageList: TImageList);
var
   C: string[1];
   I, X, W: integer;
begin
   Bitmap.Height := ImageList.Height;

   C := AnsiUpperCase(copy(Text, Index, 1));

   I := -1;

   for X := 0 to 9 do
      if C = IntToStr(X) then
         I := X;

   for x := 65 to 65 + 25 do
      if C = char(X) then
         I := X - 65 + 10;

   if C = '.' then
      I := 36;


   if C = ' ' then
      I := -2;

   if I = -1 then
      exit; // Illegal charactor exit;

   if (I <> -2) and (I <> 36) then
      I := I + 38;

   W := Bitmap.Width;
   if I = -2 then
      Bitmap.Width := Bitmap.Width + 3
   else
      Bitmap.Width := Bitmap.Width + WorkOutCharLength(I, ImageList);

   if I > 0 then
      ImageList.Draw(Bitmap.Canvas, W, 0, I);
end;

procedure DrawCameoText(var SHP: TSHP; const Text: string; ImageList: TImageList;
   ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
var
   Bitmap:  TBitmap;
   x, y, c: integer;
begin
   Bitmap := TBitmap.Create;
   Bitmap.Canvas.Brush.Color := clblue;

   if alg = 0 then
      alg := 4;

   for x := 1 to length(Text) do
      AddCharToBMP(Bitmap, Text, x, ImageList);

   c := ((SHP.Header.Width) div 2) - ((Bitmap.Width) div 2);

   if Bitmap.Width > SHP.Header.Width then
   begin
      Bitmap.Width := SHP.Header.Width;
      c := 0;
   end;


   for x := c to c + Bitmap.Width - 1 do
      for y := 42 to 47 do
         if Bitmap.Canvas.Pixels[x - c, y - 42] <> clblue then
            SHP.Data[1].FrameImage[x, y] :=
               LoadPixel(Bitmap, Start, List, Last, alg, x - c, y - 42, False);


   Bitmap.Free;
end;

procedure DrawCameoText2(var SHP: TSHP; const Text: string;
   ImageList: TImageList; ALG: integer; var List, Last: listed_colour;
   var Start: Colour_element);
var
   Bitmap:  TBitmap;
   x, y, c: integer;
begin
   Bitmap := TBitmap.Create;
   Bitmap.Canvas.Brush.Color := clblue;

   if alg = 0 then
      alg := 4;

   for x := 1 to length(Text) do
      AddCharToBMP2(Bitmap, Text, x, ImageList);

   c := ((SHP.Header.Width) div 2) - ((Bitmap.Width) div 2);

   if Bitmap.Width > SHP.Header.Width then
   begin
      Bitmap.Width := SHP.Header.Width;
      c := 0;
   end;


   for x := c to c + Bitmap.Width - 1 do
      for y := (SHP.Header.Height - 12) to (SHP.Header.Height - 7) do
         if Bitmap.Canvas.Pixels[x - c, y - (SHP.Header.Height - 12)] <> clblue then
            SHP.Data[1].FrameImage[x, y] :=
               LoadPixel(Bitmap, Start, List, Last, alg, x - c, y - (SHP.Header.Height - 12), False);


   Bitmap.Free;
end;

procedure DrawDark_Cameo(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
var
   x, y: integer;
   c:    tcolor;
   r, g, b: byte;
begin

   // Bug Fix: If CCM is set to AutoSelect, it takes 3D RGB FD
   if alg = 0 then
      alg := 4;

   for x := x1 to x2 do
      for y := y1 to y2 do
      begin
         c := SHPPalette[SHP.Data[1].FrameImage[x, y]];

         R := GetRValue(c);
         G := GetGValue(c);
         B := GetBValue(c);

         if r - Value < 0 then
            r := 0
         else
            r := r - Value;

         if g - Value < 0 then
            g := 0
         else
            g := g - Value;

         if b - Value < 0 then
            b := 0
         else
            b := b - Value;

         SHP.Data[1].FrameImage[x, y] := LoadPixel(List, Last, ALG, RGB(r, g, b));
      end;

end;

procedure DrawLight_Cameo(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
var
   x, y: integer;
   c:    tcolor;
   r, g, b: byte;
begin

   // Bug Fix: If CCM is set to AutoSelect, it takes 3D RGB FD
   if alg = 0 then
      alg := 4;

   for x := x1 to x2 do
      for y := y1 to y2 do
      begin
         c := SHPPalette[SHP.Data[1].FrameImage[x, y]];

         R := GetRValue(c);
         G := GetGValue(c);
         B := GetBValue(c);

         if r + Value > 255 then
            r := 255
         else
            r := r + Value;

         if g + Value > 255 then
            g := 255
         else
            g := g + Value;

         if b + Value > 255 then
            b := 255
         else
            b := b + Value;

         SHP.Data[1].FrameImage[x, y] := LoadPixel(List, Last, ALG, RGB(r, g, b));
      end;

end;

procedure DrawLight_Cameo2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG, X1, X2, Y1, Y2: integer; var List, Last: listed_colour;
   var Start: Colour_element);
var
   x, y, xv, yv: integer;
   c: tcolor;
   r, g, b, v, step: byte;
begin

   // Bug Fix: If CCM is set to AutoSelect, it takes 3D RGB FD
   if alg = 0 then
      alg := 4;

   XV := X2 - X1;
   if XV = 0 then
      XV := 1;

   YV := Y2 - Y1;
   if YV = 0 then
      YV := 1;

   step := Value div (XV * YV);

   v := Value;

   for x := x1 to x2 do
      for y := y1 to y2 do
      begin
         c := SHPPalette[SHP.Data[1].FrameImage[x, y]];

         R := GetRValue(c);
         G := GetGValue(c);
         B := GetBValue(c);

         if r + v > 255 then
            r := 255
         else
            r := r + v;

         if g + v > 255 then
            g := 255
         else
            g := g + v;

         if b + v > 255 then
            b := 255
         else
            b := b + v;

         SHP.Data[1].FrameImage[x, y] := LoadPixel(List, Last, ALG, RGB(r, g, b));

         if v - step < 0 then
            v := 0
         else
            v := v - step;
      end;

end;

procedure DrawCameoBar_DarkSides_s1(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin

   DrawDark_Cameo(SHP, SHPPalette, Value * 2, alg, 0, 0, 2, SHP.Header.Height - 3, List, Last, Start);
   DrawDark_Cameo(SHP, SHPPalette, Value, alg, 1, 1, 1, SHP.Header.Height - 2, List, Last, Start);

{DrawDark_Cameo(SHP,Value*2,alg,SHP.Header.Width-1,SHP.Header.Width-1,2,SHP.Header.Height-3);
DrawDark_Cameo(SHP,Value,alg,SHP.Header.Width-2,SHP.Header.Width-2,2,SHP.Header.Height-3); }

   DrawDark_Cameo(SHP, SHPPalette, Value * 2, alg, 2, SHP.Header.Width - 3, 0, 0, List, Last, Start);
   DrawDark_Cameo(SHP, SHPPalette, Value, alg, 1, SHP.Header.Width - 2, 1, 1, List, Last, Start);

{DrawDark_Cameo(SHP,Value*2,alg,2,SHP.Header.Width-3,SHP.Header.Height-1,SHP.Header.Height-1);
DrawDark_Cameo(SHP,Value,alg,2,SHP.Header.Width-3,SHP.Header.Height-2,SHP.Header.Height-2);}
end;

procedure DrawCameoBar_LightSides_s1(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawLight_Cameo(SHP, SHPPalette, Value, alg, SHP.Header.Width - 1,
      SHP.Header.Width - 1, 2, SHP.Header.Height - 3, List, Last, Start);
   //DrawLight_Cameo(SHP,Value*2,alg,SHP.Header.Width-2,SHP.Header.Width-2,1,SHP.Header.Height-2);

{DrawLight_Cameo(SHP,Value*2,alg,2,SHP.Header.Width-3,SHP.Header.Height-1,SHP.Header.Height-1);
DrawLight_Cameo(SHP,Value,alg,2,SHP.Header.Width-3,SHP.Header.Height-2,SHP.Header.Height-2);    }
end;

procedure DrawCameoBar_DarkSides_s2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawDark_Cameo(SHP, SHPPalette, Value * 2, alg, 0, 0, 2, SHP.Header.Height - 3, List, Last, Start);
   DrawDark_Cameo(SHP, SHPPalette, Value, alg, 1, 1, 1, SHP.Header.Height - 2, List, Last, Start);

   DrawDark_Cameo(SHP, SHPPalette, Value * 2, alg, SHP.Header.Width - 1,
      SHP.Header.Width - 1, 2, SHP.Header.Height - 3, List, Last, Start);
   DrawDark_Cameo(SHP, SHPPalette, Value, alg, SHP.Header.Width - 2,
      SHP.Header.Width - 2, 1, SHP.Header.Height - 2, List, Last, Start);

   DrawLight_Cameo(SHP, SHPPalette, Value * 2, alg, 2, SHP.Header.Width - 3, 0, 0, List, Last, Start);
end;

procedure DrawCameoBar_LightSides_s2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawLight_Cameo(SHP, SHPPalette, Value, alg, 2, SHP.Header.Width - 3, 0, 0, List, Last, Start);
end;

procedure DrawCameoBar_Kravvitz(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin

   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 1, 1, 2, SHP.Header.Height - 2, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 2, 2, 17, List, Last, Start);

   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, SHP.Header.Width - 2, 1, 1, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 30, 2, 2, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 4, 3, 3, List, Last, Start);

   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, SHP.Header.Width - 2,
      SHP.Header.Width - 2, 2, SHP.Header.Height - 2, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value div 2, alg, SHP.Header.Width - 1,
      SHP.Header.Width - 1, 2, SHP.Header.Height - 2, List, Last, Start);
end;

procedure DrawCameoBar_Kravvitz2(var SHP: TSHP; var SHPPalette: TPalette;
   Value: byte; ALG: integer; var List, Last: listed_colour; var Start: Colour_element);
begin
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 1, 1, 2, SHP.Header.Height - 2, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 2, 2, 17, List, Last, Start);

   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, SHP.Header.Width - 2, 1, 1, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 30, 2, 2, List, Last, Start);
   DrawLight_Cameo2(SHP, SHPPalette, Value, alg, 2, 4, 3, 3, List, Last, Start);
end;

function WorkOutTextBarDV(SHP: TSHP; var SHPPalette: TPalette): integer;
var
   x, y, RGBA, A, C: integer;
   r, g, b: byte;
begin

   A := 0;
   C := 0;

   for x := 0 to shp.Header.Width - 1 do
      for y := shp.Header.Height - 7 to shp.Header.Height - 1 do
      begin
         C := C + 1;

         R := GetRValue(SHPPalette[SHP.Data[1].FrameImage[x, y]]);
         G := GetGValue(SHPPalette[SHP.Data[1].FrameImage[x, y]]);
         B := GetBValue(SHPPalette[SHP.Data[1].FrameImage[x, y]]);

         RGBA := (R + G + B) div 3;

         A := A + RGBA;
      end;

   A := A div C;

   Result := A;
end;

end.
