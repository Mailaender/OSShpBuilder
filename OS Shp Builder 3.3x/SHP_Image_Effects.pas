unit SHP_Image_Effects;

interface

uses Windows, Graphics, Palette, SHP_File, Miscelaneous, SHP_Engine_CCMs,
   Colour_list, SHP_Colour_Bank, Undo_Redo, Math;

type
   TRGBPixel = record
      r, g, b: integer;
   end;

   TYIQPixel = record
      y, i, q: integer;
   end;

   TRGBFrame   = array of array of TRGBPixel;
   TYIQPalette = array [0..255] of TYIQPixel;


//  Note:


 // Bg = Background colour. Usually 0, but when you want to
 // keep the 0, change it to -1 ;).

//Basic stuff
procedure ConvertMatrixToFrameImage(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);
procedure PeakPointControl(var r, g, b: integer; r0, g0, b0: byte;
   var Pixel: TRGBPixel; mode: byte);

// Smooth Blur
procedure ConservativeSmoothing(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);

procedure Mean(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
procedure MeanCross(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);

procedure Median(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
procedure MedianCross(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);

// Sharpening
procedure UnsharpMasking(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
procedure SharpeningBallanced(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure SharpeningUmballanced(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);

// Arithmetics
procedure Exponential(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
procedure Logarithm(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
procedure LogarithmLighting(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
procedure LogarithmDarkening(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);

// 3D Looking Effects
procedure ButtonizeWeak(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure ButtonizeStrong(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure ButtonizeVeryStrong(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);

// Texturizers
procedure BasicTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure IcedTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure WhiteTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure Petroglyph(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure Rocker(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure Stonify(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   Mode: byte; var UndoList: TUndoRedo);

// Miscelaneous
procedure MessItUp(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure X_Depth(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure UnFocus(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure Underline(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure PolyMean(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
procedure Square_Depth(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
procedure MeanSquared(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
// This one is known as Uber Noise. Because it just mess up the picture :P!
procedure MeanXor(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);

// Black & White
procedure GetYIQPalette(const Palette: TPalette; var YIQPalette: TYIQPalette);
function ConvertYIQToRGB(const YIQPixel: TYIQPixel): TRGBPixel;

// Flip and Mirror
procedure MirrorFrame(var Frame : TFrameImage);
procedure FlipFrame(var Frame : TFrameImage);


implementation

uses FormMain;

procedure ConvertMatrixToFrameImage(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);
var
   x, y, bg2:  integer;
   List, Last: listed_colour;
   Start:      colour_element;
   IgnoreBackground: boolean;
begin
   bg2 := 0;
   if bg = -2 then
   begin
      IgnoreBackground := True;
      bg2 := -1;
   end
   else
      IgnoreBackground := False;
   GenerateColourList(Palette, List, Last, Palette[0], IgnoreBackground,
      True, IgnoreEvilColours, RedToRemapable);
   PrepareBank(Start, List, Last);
   for x := left to Width do
   begin
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> bg2 then
         begin
            AddToUndoMultiFrames(UndoList, Frame, x, y, SHP.Data[Frame].FrameImage[x, y]);
            SHP.Data[Frame].FrameImage[x, y] :=
               LoadPixel(List, Last, alg, RGB(Matrix[x, y].r, Matrix[x, y].g, Matrix[x, y].b));
         end;
      end;
   end;

   // Remove the trash:
   ClearColourList(List, Last);
   ClearBank(Start);
end;

procedure PeakPointControl(var r, g, b: integer; r0, g0, b0: byte;
   var Pixel: TRGBPixel; mode: byte);
var
   maxi: integer;
begin
   case mode of
      0: // Disabled
      begin
         if r < 0 then
            Pixel.r := 0
         else if r > 255 then
            Pixel.r := 255
         else
            Pixel.r := r;

         if g < 0 then
            Pixel.g := 0
         else if g > 255 then
            Pixel.g := 255
         else
            Pixel.g := g;

         if b < 0 then
            Pixel.b := 0
         else if b > 255 then
            Pixel.b := 255
         else
            Pixel.b := b;
      end;
      1: // Enabled (turn it to the original)
      begin
         if r < 0 then
            Pixel.r := r0
         else if r > 255 then
            Pixel.r := r0
         else
            Pixel.r := r;

         if g < 0 then
            Pixel.g := g0
         else if g > 255 then
            Pixel.g := g0
         else
            Pixel.g := g;

         if b < 0 then
            Pixel.b := b0
         else if b > 255 then
            Pixel.b := b0
         else
            Pixel.b := b;
      end;
      2: // Enabled (turn it to avarage mode)
      begin
         if r < 0 then
            Pixel.r := r0 div 2
         else if r > 255 then
            Pixel.r := (r0 + 255) div 2
         else
            Pixel.r := r;

         if g < 0 then
            Pixel.g := g0 div 2
         else if g > 255 then
            Pixel.g := (g0 + 255) div 2
         else
            Pixel.g := g;

         if b < 0 then
            Pixel.b := b0 div 2
         else if b > 255 then
            Pixel.b := (b0 + 255) div 2
         else
            Pixel.b := b;
      end;
      else  // Enabled (turn it to percentual mode)
         maxi := max(abs(r), max(abs(g), abs(b)));
         if maxi = 0 then
            Inc(maxi);
         if r < 0 then
            Pixel.r := r0 + (r0 * (r div maxi))
         else if r > 255 then
            Pixel.r := r0 + ((255 - r0) * (r div maxi))
         else
            Pixel.r := r;

         if g < 0 then
            Pixel.g := g0 + (g0 * (g div maxi))
         else if g > 255 then
            Pixel.g := g0 + ((255 - g0) * (g div maxi))
         else
            Pixel.g := g;

         if b < 0 then
            Pixel.b := b0 + (b0 * (b div maxi))
         else if b > 255 then
            Pixel.b := b0 + ((255 - b0) * (b div maxi))
         else
            Pixel.b := b;
   end;
end;

procedure ConservativeSmoothing(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   Minimum, Maximum:    TRGBPixel;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count     := 0;
            Maximum.r := 0;
            Maximum.g := 0;
            Maximum.b := 0;
            Minimum.r := 255;
            Minimum.g := 255;
            Minimum.b := 255;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        ((xc - (x - 1)) <> (yc - (y - 1))) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           if GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) <
                              Minimum.r then
                              Minimum.r :=
                                 GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]])
                           else if GetRValue(
                              Palette[SHP.Data[Frame].FrameImage[xc, yc]]) >
                              Maximum.r then
                              Maximum.r :=
                                 GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           if GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) <
                              Minimum.g then
                              Minimum.g :=
                                 GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]])
                           else if GetGValue(
                              Palette[SHP.Data[Frame].FrameImage[xc, yc]]) >
                              Maximum.g then
                              Maximum.g :=
                                 GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           if GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) <
                              Minimum.b then
                              Minimum.b :=
                                 GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]])
                           else if GetBValue(
                              Palette[SHP.Data[Frame].FrameImage[xc, yc]]) >
                              Maximum.b then
                              Maximum.b :=
                                 GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Now it provides the value.
            if Count <> 0 then
            begin
               if GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) < Minimum.r then
                  Matrix[x, y].r := Minimum.r
               else if GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) >
                  Maximum.r then
                  Matrix[x, y].r := Maximum.r
               else
                  Matrix[x, y].r :=
                     GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               if GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) < Minimum.g then
                  Matrix[x, y].g := Minimum.g
               else if GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) >
                  Maximum.g then
                  Matrix[x, y].g := Maximum.g
               else
                  Matrix[x, y].g :=
                     GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               if GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) < Minimum.b then
                  Matrix[x, y].b := Minimum.b
               else if GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) >
                  Maximum.b then
                  Matrix[x, y].b := Maximum.b
               else
                  Matrix[x, y].b :=
                     GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Mean(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   Sum: TRGBPixel;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - Radious) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y + Radious) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.g :=
                              Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.b :=
                              Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Now it provides the value.
            if Count <> 0 then
            begin
               Matrix[x, y].r := Sum.r div Count;
               Matrix[x, y].g := Sum.g div Count;
               Matrix[x, y].b := Sum.b div Count;
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure MeanCross(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   Sum: TRGBPixel;
   MultiplyMatrix: array [0..2, 0..2] of integer;
begin
   // Set Multiply matrix to cancel the non-cross sections
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 1;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[1, 0] := 1;
   MultiplyMatrix[1, 1] := 1;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.g :=
                              Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.b :=
                              Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Now it provides the value.
            if Count <> 0 then
            begin
               Matrix[x, y].r := Sum.r div Count;
               Matrix[x, y].g := Sum.g div Count;
               Matrix[x, y].b := Sum.b div Count;
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Median(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MiniMatrixRed, MiniMatrixGreen, MiniMatrixBlue: array of byte;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan matrix
            Count := 0;
            for xc := (x - Radious) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y + Radious) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           SetLength(MiniMatrixRed, Count + 1);
                           SetLength(MiniMatrixGreen, Count + 1);
                           SetLength(MiniMatrixBlue, Count + 1);
                           MiniMatrixRed[Count]   :=
                              GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MiniMatrixGreen[Count] :=
                              GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MiniMatrixBlue[Count]  :=
                              GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Quicksort the MiniMatrixs
            QuickSort(MiniMatrixRed, 0, Count - 1);
            QuickSort(MiniMatrixGreen, 0, Count - 1);
            QuickSort(MiniMatrixBlue, 0, Count - 1);

            // Now it provides the value.
            if Count > 0 then
            begin
               Matrix[x, y].r := MiniMatrixRed[Count div 2];
               Matrix[x, y].g := MiniMatrixGreen[Count div 2];
               Matrix[x, y].b := MiniMatrixBlue[Count div 2];
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure MedianCross(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MiniMatrixRed, MiniMatrixGreen, MiniMatrixBlue: array of byte;
   MultiplyMatrix:      array [0..2, 0..2] of integer;
begin
   // Set Multiply matrix to cancel the non-cross sections
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 1;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[1, 0] := 1;
   MultiplyMatrix[1, 1] := 1;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan matrix
            Count := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           SetLength(MiniMatrixRed, Count + 1);
                           SetLength(MiniMatrixGreen, Count + 1);
                           SetLength(MiniMatrixBlue, Count + 1);
                           MiniMatrixRed[Count]   :=
                              GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MiniMatrixGreen[Count] :=
                              GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MiniMatrixBlue[Count]  :=
                              GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Quicksort the MiniMatrixs
            QuickSort(MiniMatrixRed, 0, Count - 1);
            QuickSort(MiniMatrixGreen, 0, Count - 1);
            QuickSort(MiniMatrixBlue, 0, Count - 1);

            // Now it provides the value.
            if Count > 0 then
            begin
               Matrix[x, y].r := MiniMatrixRed[Count div 2];
               Matrix[x, y].g := MiniMatrixGreen[Count div 2];
               Matrix[x, y].b := MiniMatrixBlue[Count div 2];
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;


procedure UnsharpMasking(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   MultiplyMatrix[0, 0] := -1;
   MultiplyMatrix[0, 1] := -1;
   MultiplyMatrix[0, 2] := -1;
   MultiplyMatrix[1, 0] := -1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -1;
   MultiplyMatrix[2, 0] := -1;
   MultiplyMatrix[2, 1] := -1;
   MultiplyMatrix[2, 2] := -1;
   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // build the 3x3 matrix
         Count := 0;
         Sum.r := 0;
         Sum.g := 0;
         Sum.b := 0;
         for xc := (x - 1) to (x + 1) do
         begin
            if (xc > -1) and (xc < SHP.Header.Width) then
            begin
               for yc := (y - 1) to (y + 1) do
               begin
                  // check if current pixel is valid
                  if (yc > -1) and (yc < SHP.Header.Height) then
                     if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                     begin
                        Sum.r :=
                           Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                           MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                        Sum.g :=
                           Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                           MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                        Sum.b :=
                           Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                           MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                        Inc(Count);
                     end;
               end;
            end;
         end;

         // Now we do the final calculations
         if Count = 0 then
            Inc(Count);
         Sum.r := Sum.r div Count;
         Sum.g := Sum.g div Count;
         Sum.b := Sum.b div Count;

         // Sharpen
         Sum.r := Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * 2);
         Sum.g := Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * 2);
         Sum.b := Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * 2);

         // Now we fix the estimated value
         if Sum.r < 0 then
            Sum.r := 0
         else if Sum.r > 255 then
            Sum.r := 255;

         if Sum.g < 0 then
            Sum.g := 0
         else if Sum.g > 255 then
            Sum.g := 255;

         if Sum.b < 0 then
            Sum.b := 0
         else if Sum.b > 255 then
            Sum.b := 255;

         // Now it provides the value.
         Matrix[x, y].r := Sum.r;
         Matrix[x, y].g := Sum.g;
         Matrix[x, y].b := Sum.b;
      end;
end;

procedure SharpeningBallanced(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := -1;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[1, 0] := -1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -1;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := -1;
   MultiplyMatrix[2, 2] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Count :=
                              Count + (-1 * MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                        end;
                  end;
               end;
            end;

            // Now we do the final calculations
            Inc(Count);

            // Sharpen
            Sum.r := Sum.r +
               (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);
            Sum.g := Sum.g +
               (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);
            Sum.b := Sum.b +
               (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;


procedure SharpeningUmballanced(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   MultiplyMatrix[0, 0] := -2;
   MultiplyMatrix[0, 1] := 1;
   MultiplyMatrix[0, 2] := -2;
   MultiplyMatrix[1, 0] := 1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[2, 0] := -2;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := -2;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                           Count :=
                              Count + (-1 * MultiplyMatrix[(xc - (x - 1)), (yc - (y - 1))]);
                        end;
                  end;
               end;
            end;

            // Now we do the final calculations
            Inc(Count);

            // Sharpen
            Sum.r := Sum.r +
               (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);
            Sum.g := Sum.g +
               (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);
            Sum.b := Sum.b +
               (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) * Count);

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

// Arithmethics
procedure Exponential(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y:  integer;
   Sum:   TRGBPixel;
   scale: extended;
begin
   // Get the scale value
   scale := (255 / (power(1.01, 255)));

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // Calculate exponential
         Sum.r := round(scale *
            power(1.01, GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));
         Sum.g := round(scale *
            power(1.01, GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));
         Sum.b := round(scale *
            power(1.01, GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));

         // Now we fix the estimated value
         if Sum.r < 0 then
            Sum.r := 0
         else if Sum.r > 255 then
            Sum.r := 255;

         if Sum.g < 0 then
            Sum.g := 0
         else if Sum.g > 255 then
            Sum.g := 255;

         if Sum.b < 0 then
            Sum.b := 0
         else if Sum.b > 255 then
            Sum.b := 255;

         // Now it provides the value.
         Matrix[x, y].r := Sum.r;
         Matrix[x, y].g := Sum.g;
         Matrix[x, y].b := Sum.b;
      end;
end;

procedure Logarithm(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y:  integer;
   Sum:   TRGBPixel;
   scale: extended;
begin
   // Get the scale value
   scale := (255 / (1 + log2(255)));

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // Calculate logarithm
         Sum.r := round(scale *
            log2(1 + GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));
         Sum.g := round(scale *
            log2(1 + GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));
         Sum.b := round(scale *
            log2(1 + GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]])));

         // Now we fix the estimated value
         if Sum.r < 0 then
            Sum.r := 0
         else if Sum.r > 255 then
            Sum.r := 255;

         if Sum.g < 0 then
            Sum.g := 0
         else if Sum.g > 255 then
            Sum.g := 255;

         if Sum.b < 0 then
            Sum.b := 0
         else if Sum.b > 255 then
            Sum.b := 255;

         // Now it provides the value.
         Matrix[x, y].r := Sum.r;
         Matrix[x, y].g := Sum.g;
         Matrix[x, y].b := Sum.b;
      end;
end;

procedure LogarithmLighting(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y: integer;
   Sum:  TRGBPixel;
begin
   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // Calculate logarithm
         Sum.r := round(GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) +
            (2 * log2(1 + GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));
         Sum.g := round(GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) +
            (2 * log2(1 + GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));
         Sum.b := round(GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) +
            (2 * log2(1 + GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));

         // Now we fix the estimated value
         if Sum.r < 0 then
            Sum.r := 0
         else if Sum.r > 255 then
            Sum.r := 255;

         if Sum.g < 0 then
            Sum.g := 0
         else if Sum.g > 255 then
            Sum.g := 255;

         if Sum.b < 0 then
            Sum.b := 0
         else if Sum.b > 255 then
            Sum.b := 255;

         // Now it provides the value.
         Matrix[x, y].r := Sum.r;
         Matrix[x, y].g := Sum.g;
         Matrix[x, y].b := Sum.b;
      end;
end;

// Now for some cool effects: Buttonizers
procedure ButtonizeWeak(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..4, 0..4] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := 1;
   MultiplyMatrix[0, 3] := 0;
   MultiplyMatrix[0, 4] := 0;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 1;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[1, 3] := 1;
   MultiplyMatrix[1, 4] := 0;
   MultiplyMatrix[2, 0] := 1;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 0;
   MultiplyMatrix[2, 3] := 1;
   MultiplyMatrix[2, 4] := 1;
   MultiplyMatrix[3, 0] := 0;
   MultiplyMatrix[3, 1] := 1;
   MultiplyMatrix[3, 2] := 1;
   MultiplyMatrix[3, 3] := 1;
   MultiplyMatrix[3, 4] := 0;
   MultiplyMatrix[4, 0] := 0;
   MultiplyMatrix[4, 1] := 0;
   MultiplyMatrix[4, 2] := 1;
   MultiplyMatrix[4, 3] := 0;
   MultiplyMatrix[4, 4] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 5x5 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 2) to (x + 2) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 2) to (y + 2) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 2), xc - (x - 2)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.g :=
                              Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.b :=
                              Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Sharpen
            Sum.r := (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.r;
            Sum.g := (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.g;
            Sum.b := (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.b;

            // Now we fix the estimated value
            if Sum.r < -255 then
               Sum.r := -255
            else if Sum.r > 255 then
               Sum.r := 255;

            if Sum.g < -255 then
               Sum.g := -255
            else if Sum.g > 255 then
               Sum.g := 255;

            if Sum.b < -255 then
               Sum.b := -255
            else if Sum.b > 255 then
               Sum.b := 255;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure ButtonizeStrong(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..6, 0..6] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[0, 3] := 1;
   MultiplyMatrix[0, 4] := 0;
   MultiplyMatrix[0, 5] := 0;
   MultiplyMatrix[0, 6] := 0;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[1, 3] := 1;
   MultiplyMatrix[1, 4] := 1;
   MultiplyMatrix[1, 5] := 0;
   MultiplyMatrix[1, 6] := 0;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 1;
   MultiplyMatrix[2, 3] := 1;
   MultiplyMatrix[2, 4] := 1;
   MultiplyMatrix[2, 5] := 1;
   MultiplyMatrix[2, 6] := 0;
   MultiplyMatrix[3, 0] := 1;
   MultiplyMatrix[3, 1] := 1;
   MultiplyMatrix[3, 2] := 1;
   MultiplyMatrix[3, 3] := 0;
   MultiplyMatrix[3, 4] := 1;
   MultiplyMatrix[3, 5] := 1;
   MultiplyMatrix[3, 6] := 1;
   MultiplyMatrix[4, 0] := 0;
   MultiplyMatrix[4, 1] := 1;
   MultiplyMatrix[4, 2] := 1;
   MultiplyMatrix[4, 3] := 1;
   MultiplyMatrix[4, 4] := 1;
   MultiplyMatrix[4, 5] := 1;
   MultiplyMatrix[4, 6] := 0;
   MultiplyMatrix[5, 0] := 0;
   MultiplyMatrix[5, 1] := 0;
   MultiplyMatrix[5, 2] := 1;
   MultiplyMatrix[5, 3] := 1;
   MultiplyMatrix[5, 4] := 1;
   MultiplyMatrix[5, 5] := 0;
   MultiplyMatrix[5, 6] := 0;
   MultiplyMatrix[6, 0] := 0;
   MultiplyMatrix[6, 1] := 0;
   MultiplyMatrix[6, 2] := 0;
   MultiplyMatrix[6, 3] := 1;
   MultiplyMatrix[6, 4] := 0;
   MultiplyMatrix[6, 5] := 0;
   MultiplyMatrix[6, 6] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 5x5 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 3) to (x + 3) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 3) to (y + 3) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 3), xc - (x - 3)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.g :=
                              Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.b :=
                              Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Sharpen
            Sum.r := (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.r;
            Sum.g := (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.g;
            Sum.b := (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.b;

            // Now we fix the estimated value
            if Sum.r < -255 then
               Sum.r := -255
            else if Sum.r > 255 then
               Sum.r := 255;

            if Sum.g < -255 then
               Sum.g := -255
            else if Sum.g > 255 then
               Sum.g := 255;

            if Sum.b < -255 then
               Sum.b := -255
            else if Sum.b > 255 then
               Sum.b := 255;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure ButtonizeVeryStrong(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..6, 0..6] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := 1;
   MultiplyMatrix[0, 3] := 1;
   MultiplyMatrix[0, 4] := 1;
   MultiplyMatrix[0, 5] := 0;
   MultiplyMatrix[0, 6] := 0;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 1;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[1, 3] := 1;
   MultiplyMatrix[1, 4] := 1;
   MultiplyMatrix[1, 5] := 1;
   MultiplyMatrix[1, 6] := 0;
   MultiplyMatrix[2, 0] := 1;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 1;
   MultiplyMatrix[2, 3] := 1;
   MultiplyMatrix[2, 4] := 1;
   MultiplyMatrix[2, 5] := 1;
   MultiplyMatrix[2, 6] := 1;
   MultiplyMatrix[3, 0] := 1;
   MultiplyMatrix[3, 1] := 1;
   MultiplyMatrix[3, 2] := 1;
   MultiplyMatrix[3, 3] := 0;
   MultiplyMatrix[3, 4] := 1;
   MultiplyMatrix[3, 5] := 1;
   MultiplyMatrix[3, 6] := 1;
   MultiplyMatrix[4, 0] := 1;
   MultiplyMatrix[4, 1] := 1;
   MultiplyMatrix[4, 2] := 1;
   MultiplyMatrix[4, 3] := 1;
   MultiplyMatrix[4, 4] := 1;
   MultiplyMatrix[4, 5] := 1;
   MultiplyMatrix[4, 6] := 1;
   MultiplyMatrix[5, 0] := 0;
   MultiplyMatrix[5, 1] := 1;
   MultiplyMatrix[5, 2] := 1;
   MultiplyMatrix[5, 3] := 1;
   MultiplyMatrix[5, 4] := 1;
   MultiplyMatrix[5, 5] := 1;
   MultiplyMatrix[5, 6] := 0;
   MultiplyMatrix[6, 0] := 0;
   MultiplyMatrix[6, 1] := 0;
   MultiplyMatrix[6, 2] := 1;
   MultiplyMatrix[6, 3] := 1;
   MultiplyMatrix[6, 4] := 1;
   MultiplyMatrix[6, 5] := 0;
   MultiplyMatrix[6, 6] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 5x5 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 3) to (x + 3) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 3) to (y + 3) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 3), xc - (x - 3)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.g :=
                              Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Sum.b :=
                              Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Sharpen
            Sum.r := (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.r;
            Sum.g := (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.g;
            Sum.b := (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.b;

            // Now we fix the estimated value
            if Sum.r < -255 then
               Sum.r := -255
            else if Sum.r > 255 then
               Sum.r := 255;

            if Sum.g < -255 then
               Sum.g := -255
            else if Sum.g > 255 then
               Sum.g := 255;

            if Sum.b < -255 then
               Sum.b := -255
            else if Sum.b > 255 then
               Sum.b := 255;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

// Texturizers
procedure BasicTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 3;
   MultiplyMatrix[0, 1] := -5;
   MultiplyMatrix[0, 2] := -5;
   MultiplyMatrix[1, 0] := 3;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -5;
   MultiplyMatrix[2, 0] := 3;
   MultiplyMatrix[2, 1] := 3;
   MultiplyMatrix[2, 2] := 3;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure IcedTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := -3;
   MultiplyMatrix[0, 1] := 5;
   MultiplyMatrix[0, 2] := 5;
   MultiplyMatrix[1, 0] := -3;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 5;
   MultiplyMatrix[2, 0] := -3;
   MultiplyMatrix[2, 1] := -3;
   MultiplyMatrix[2, 2] := -3;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure WhiteTexturizer(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 3;
   MultiplyMatrix[0, 1] := 3;
   MultiplyMatrix[0, 2] := 3;
   MultiplyMatrix[1, 0] := -5;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 3;
   MultiplyMatrix[2, 0] := -5;
   MultiplyMatrix[2, 1] := -5;
   MultiplyMatrix[2, 2] := 3;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Petroglyph(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := -1;
   MultiplyMatrix[0, 2] := -2;
   MultiplyMatrix[1, 0] := 1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -1;
   MultiplyMatrix[2, 0] := 2;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Rocker(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := -1;
   MultiplyMatrix[0, 2] := -1;
   MultiplyMatrix[1, 0] := 1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -1;
   MultiplyMatrix[2, 0] := 1;
   MultiplyMatrix[2, 1] := 1;
   MultiplyMatrix[2, 2] := 1;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Stonify(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 1;
   MultiplyMatrix[0, 1] := 1;
   MultiplyMatrix[0, 2] := 1;
   MultiplyMatrix[1, 0] := -1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 1;
   MultiplyMatrix[2, 0] := -1;
   MultiplyMatrix[2, 1] := -1;
   MultiplyMatrix[2, 2] := 1;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            Dec(Count);

            // Finish it.
            Sum.r := Sum.r - GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            Sum.g := Sum.g - GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            Sum.b := Sum.b - GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

// Miscelaneous
procedure MessItUp(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 4;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := -3;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := 0;
   MultiplyMatrix[2, 0] := -2;
   MultiplyMatrix[2, 1] := 0;
   MultiplyMatrix[2, 2] := 1;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure X_Depth(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..6, 0..6] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 1;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[0, 3] := 0;
   MultiplyMatrix[0, 4] := 0;
   MultiplyMatrix[0, 5] := 0;
   MultiplyMatrix[0, 6] := 1;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 2;
   MultiplyMatrix[1, 2] := 0;
   MultiplyMatrix[1, 3] := 0;
   MultiplyMatrix[1, 4] := 0;
   MultiplyMatrix[1, 5] := 2;
   MultiplyMatrix[1, 6] := 0;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := 0;
   MultiplyMatrix[2, 2] := 3;
   MultiplyMatrix[2, 3] := 0;
   MultiplyMatrix[2, 4] := 0;
   MultiplyMatrix[2, 5] := 0;
   MultiplyMatrix[2, 6] := 0;
   MultiplyMatrix[3, 0] := 0;
   MultiplyMatrix[3, 1] := 0;
   MultiplyMatrix[3, 2] := 0;
   MultiplyMatrix[3, 3] := 0;
   MultiplyMatrix[3, 4] := 0;
   MultiplyMatrix[3, 5] := 0;
   MultiplyMatrix[3, 6] := 0;
   MultiplyMatrix[4, 0] := 0;
   MultiplyMatrix[4, 1] := 0;
   MultiplyMatrix[4, 2] := 3;
   MultiplyMatrix[4, 3] := 0;
   MultiplyMatrix[4, 4] := 3;
   MultiplyMatrix[4, 5] := 0;
   MultiplyMatrix[4, 6] := 0;
   MultiplyMatrix[5, 0] := 0;
   MultiplyMatrix[5, 1] := 2;
   MultiplyMatrix[5, 2] := 0;
   MultiplyMatrix[5, 3] := 0;
   MultiplyMatrix[5, 4] := 0;
   MultiplyMatrix[5, 5] := 2;
   MultiplyMatrix[5, 6] := 0;
   MultiplyMatrix[6, 0] := 1;
   MultiplyMatrix[6, 1] := 0;
   MultiplyMatrix[6, 2] := 0;
   MultiplyMatrix[6, 3] := 0;
   MultiplyMatrix[6, 4] := 0;
   MultiplyMatrix[6, 5] := 0;
   MultiplyMatrix[6, 6] := 1;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 3) to (x + 3) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 3) to (y + 3) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 3), xc - (x - 3)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Count := Count + MultiplyMatrix[yc - (y - 3), xc - (x - 3)];
                        end;
                  end;
               end;
            end;

            Inc(Count);
            // Finish it.
            Sum.r := (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.r;
            Sum.g := (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.g;
            Sum.b := (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.b;
            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

// Miscelaneous
procedure UnFocus(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := -1;
   MultiplyMatrix[0, 1] := -1;
   MultiplyMatrix[0, 2] := -1;
   MultiplyMatrix[1, 0] := 4;
   MultiplyMatrix[1, 1] := -1;
   MultiplyMatrix[1, 2] := 4;
   MultiplyMatrix[2, 0] := -1;
   MultiplyMatrix[2, 1] := -1;
   MultiplyMatrix[2, 2] := -1;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            // Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x,y]]) + Sum.r;
            // Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x,y]]) + Sum.g;
            // Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x,y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Underline(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..2, 0..2] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 1;
   MultiplyMatrix[0, 2] := 0;
   MultiplyMatrix[1, 0] := -1;
   MultiplyMatrix[1, 1] := 0;
   MultiplyMatrix[1, 2] := -3;
   MultiplyMatrix[2, 0] := 0;
   MultiplyMatrix[2, 1] := 3;
   MultiplyMatrix[2, 2] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 1) to (x + 1) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 1) to (y + 1) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 1), xc - (x - 1)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 1), xc - (x - 1)]);
                           Count := Count + MultiplyMatrix[yc - (y - 1), xc - (x - 1)];
                        end;
                  end;
               end;
            end;

            if Count <> 0 then
            begin
               Sum.r := Sum.r div abs(Count);
               Sum.g := Sum.g div abs(Count);
               Sum.b := Sum.b div abs(Count);
            end;

            // Finish it.
            Sum.r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.r;
            Sum.g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.g;
            Sum.b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) + Sum.b;

            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure GetYIQPalette(const Palette: TPalette; var YIQPalette: TYIQPalette);
var
   x: word;
begin
   // scan image
   for x := 0 to 255 do
   begin
      YIQPalette[x].y := round((GetRValue(Palette[x]) * 0.299) +
         (GetGValue(Palette[x]) * 0.587) + (GetBValue(Palette[x]) * 0.114));
      YIQPalette[x].i := round((GetRValue(Palette[x]) * 0.596) +
         (GetGValue(Palette[x]) * (-0.275)) + (GetBValue(Palette[x]) * (-0.321)));
      YIQPalette[x].q := round((GetRValue(Palette[x]) * 0.212) +
         (GetGValue(Palette[x]) * (-0.528)) + (GetBValue(Palette[x]) * 0.311));
   end;
end;

function ConvertYIQToRGB(const YIQPixel: TYIQPixel): TRGBPixel;
begin
   Result.r := round((YIQPixel.y * 1.0028) + (YIQPixel.i * 0.9544) +
      (YIQPixel.q * 0.6178));
   Result.r := round((YIQPixel.y * 0.9965) + (YIQPixel.i * -0.2705) +
      (YIQPixel.q * -0.6445));
   Result.r := round((YIQPixel.y * 1.0083) + (YIQPixel.i * -1.1101) +
      (YIQPixel.q * 1.6992));
end;

procedure FindTheEdges(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y, xc, yc: integer;
   YIQPalette:   TYIQPalette;
begin
   // Get the Intensity scale, used in these Black & White TV
   GetYIQPalette(Palette, YIQPalette);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // build the 3x3 matrix
         //            count := 0;
         for xc := (x - 1) to (x + 1) do
         begin
            if (xc > -1) and (xc < SHP.Header.Width) then
            begin
               for yc := (y - 1) to (y + 1) do
               begin
                  // check if current pixel is valid
                  if (yc > -1) and (yc < SHP.Header.Height) and
                     (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                  begin
                  end;
               end;
            end;
         end;
      end;
end;

 // 3.36: New experiences
 // Gets a 8 shaped polygon with radius 2 and 3 and do mean
procedure PolyMean(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   Sum: TRGBPixel;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for y := top to Height do
   begin
      for x := left to Width do
      begin
         // Check if it has background colour
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - Radious) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y + Radious) do
                  begin
                     // check if it's one of the pixels that should be
                     // analysed.
                     if ((yc = y - Radious) and (xc <> x - Radious) and
                        (xc <> x + Radious)) or ((yc = y + Radious) and (xc <> x - Radious) and (xc <> x + Radious)) or
                        ((yc <> y - Radious) and (yc <> y + Radious) and ((xc = x - Radious) or
                        (xc = x + Radious))) then
                     begin
                        // check if current pixel is valid
                        if (yc > -1) and (yc < SHP.Header.Height) then
                           if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                           begin
                              Sum.r :=
                                 Sum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                              Sum.g :=
                                 Sum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                              Sum.b :=
                                 Sum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                              Inc(Count);
                           end;
                     end;
                  end;
               end;

               // Now it provides the value.
               if Count <> 0 then
               begin
                  Matrix[x, y].r := Sum.r div Count;
                  Matrix[x, y].g := Sum.g div Count;
                  Matrix[x, y].b := Sum.b div Count;
               end
               else
               begin
                  Matrix[x, y].r :=
                     GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
                  Matrix[x, y].g :=
                     GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
                  Matrix[x, y].b :=
                     GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               end;
            end;
         end;
      end;
   end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure Square_Depth(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; IgnoreEvilColours, RedToRemapable: boolean; alg: byte;
   mode: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   MultiplyMatrix: array [0..6, 0..6] of integer;
   Sum: TRGBPixel;
begin
   // Set Multiply Matrix constants
   MultiplyMatrix[0, 0] := 0;
   MultiplyMatrix[0, 1] := 0;
   MultiplyMatrix[0, 2] := 4;
   MultiplyMatrix[0, 3] := 4;
   MultiplyMatrix[0, 4] := 4;
   MultiplyMatrix[0, 5] := 0;
   MultiplyMatrix[0, 6] := 0;
   MultiplyMatrix[1, 0] := 0;
   MultiplyMatrix[1, 1] := 4;
   MultiplyMatrix[1, 2] := 0;
   MultiplyMatrix[1, 3] := 0;
   MultiplyMatrix[1, 4] := 0;
   MultiplyMatrix[1, 5] := 4;
   MultiplyMatrix[1, 6] := 0;
   MultiplyMatrix[2, 0] := 4;
   MultiplyMatrix[2, 1] := 0;
   MultiplyMatrix[2, 2] := -8;
   MultiplyMatrix[2, 3] := -8;
   MultiplyMatrix[2, 4] := -8;
   MultiplyMatrix[2, 5] := 0;
   MultiplyMatrix[2, 6] := 4;
   MultiplyMatrix[3, 0] := 4;
   MultiplyMatrix[3, 1] := 0;
   MultiplyMatrix[3, 2] := -8;
   MultiplyMatrix[3, 3] := 1;
   MultiplyMatrix[3, 4] := -8;
   MultiplyMatrix[3, 5] := 0;
   MultiplyMatrix[3, 6] := 4;
   MultiplyMatrix[4, 0] := 4;
   MultiplyMatrix[4, 1] := 0;
   MultiplyMatrix[4, 2] := -8;
   MultiplyMatrix[4, 3] := -8;
   MultiplyMatrix[4, 4] := -8;
   MultiplyMatrix[4, 5] := 0;
   MultiplyMatrix[4, 6] := 4;
   MultiplyMatrix[5, 0] := 0;
   MultiplyMatrix[5, 1] := 4;
   MultiplyMatrix[5, 2] := 0;
   MultiplyMatrix[5, 3] := 0;
   MultiplyMatrix[5, 4] := 0;
   MultiplyMatrix[5, 5] := 4;
   MultiplyMatrix[5, 6] := 0;
   MultiplyMatrix[6, 0] := 0;
   MultiplyMatrix[6, 1] := 0;
   MultiplyMatrix[6, 2] := 4;
   MultiplyMatrix[6, 3] := 4;
   MultiplyMatrix[6, 4] := 4;
   MultiplyMatrix[6, 5] := 0;
   MultiplyMatrix[6, 6] := 0;

   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // build the 3x3 matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - 3) to (x + 3) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - 3) to (y + 3) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) and
                        (MultiplyMatrix[yc - (y - 3), xc - (x - 3)] <> 0) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Sum.g :=
                              Sum.g + (GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Sum.b :=
                              Sum.b + (GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]) *
                              MultiplyMatrix[yc - (y - 3), xc - (x - 3)]);
                           Count := Count + MultiplyMatrix[yc - (y - 3), xc - (x - 3)];
                        end;
                  end;
               end;
            end;

            Inc(Count);
            // Finish it.
            Sum.r := (GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.r;
            Sum.g := (GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.g;
            Sum.b := (GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) *
               Count) - Sum.b;
            PeakPointControl(Sum.r, Sum.g, Sum.b, GetRValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetGValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), GetBValue(
               Palette[SHP.Data[Frame].FrameImage[x, y]]), Matrix[x, y], mode);
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure MeanSquared(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, maincount, Count: integer;
   MidSum, Sum: TRGBPixel;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count     := 0;
            maincount := 0;
            Sum.r     := 0;
            Sum.g     := 0;
            Sum.b     := 0;
            MidSum.r  := 0;
            MidSum.g  := 0;
            MidSum.b  := 0;
            // Square Top Left
            for xc := (x - Radious) to (x) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           MidSum.r :=
                              MidSum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.g :=
                              MidSum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.b :=
                              MidSum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;
            // Ackowledge first square
            if Count <> 0 then
            begin
               Sum.r := MidSum.r div Count;
               Sum.g := MidSum.g div Count;
               Sum.b := MidSum.b div Count;
               Inc(maincount);
            end;
            // Reset data.
            Count    := 0;
            MidSum.r := 0;
            MidSum.g := 0;
            MidSum.b := 0;
            // Square Top Right
            for xc := (x) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           MidSum.r :=
                              MidSum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.g :=
                              MidSum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.b :=
                              MidSum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;
            // Ackowledge second square
            if Count <> 0 then
            begin
               Sum.r := Sum.r + (MidSum.r div Count);
               Sum.g := Sum.g + (MidSum.g div Count);
               Sum.b := Sum.b + (MidSum.b div Count);
               Inc(maincount);
            end;
            // Reset data.
            Count    := 0;
            MidSum.r := 0;
            MidSum.g := 0;
            MidSum.b := 0;
            // Square Bottom Left
            for xc := (x - Radious) to (x) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y) to (y + Radious) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           MidSum.r :=
                              MidSum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.g :=
                              MidSum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.b :=
                              MidSum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;
            // Ackowledge third square
            if Count <> 0 then
            begin
               Sum.r := Sum.r + (MidSum.r div Count);
               Sum.g := Sum.g + (MidSum.g div Count);
               Sum.b := Sum.b + (MidSum.b div Count);
               Inc(maincount);
            end;
            // Reset data.
            Count    := 0;
            MidSum.r := 0;
            MidSum.g := 0;
            MidSum.b := 0;
            // Square Bottom Right
            for xc := (x) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y) to (y + Radious) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           MidSum.r :=
                              MidSum.r + GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.g :=
                              MidSum.g + GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           MidSum.b :=
                              MidSum.b + GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]);
                           Inc(Count);
                        end;
                  end;
               end;
            end;
            // Ackowledge last square
            if Count <> 0 then
            begin
               Sum.r := Sum.r + (MidSum.r div Count);
               Sum.g := Sum.g + (MidSum.g div Count);
               Sum.b := Sum.b + (MidSum.b div Count);
               Inc(maincount);
            end;


            // Now it provides the value.
            if maincount <> 0 then
            begin
               Matrix[x, y].r := Sum.r div maincount;
               Matrix[x, y].g := Sum.g div maincount;
               Matrix[x, y].b := Sum.b div maincount;
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

// Mean with XOR. Must bring some insane result.
procedure MeanXor(var SHP: TSHP; var Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame;
   Bg: smallint; Radious: byte; IgnoreEvilColours, RedToRemapable: boolean;
   alg: byte; var UndoList: TUndoRedo);
var
   x, y, xc, yc, Count: integer;
   Sum: TRGBPixel;
begin
   // Set the Matrix
   SetLength(Matrix, SHP.Header.Width + 1, SHP.Header.Height + 1);

   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         if SHP.Data[Frame].FrameImage[x, y] <> Bg then
         begin
            // scan the matrix
            Count := 0;
            Sum.r := 0;
            Sum.g := 0;
            Sum.b := 0;
            for xc := (x - Radious) to (x + Radious) do
            begin
               if (xc > -1) and (xc < SHP.Header.Width) then
               begin
                  for yc := (y - Radious) to (y + Radious) do
                  begin
                     // check if current pixel is valid
                     if (yc > -1) and (yc < SHP.Header.Height) then
                        if (SHP.Data[Frame].FrameImage[xc, yc] <> Bg) then
                        begin
                           Sum.r :=
                              Sum.r + (Sum.r xor GetRValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]));
                           Sum.g :=
                              Sum.g + (Sum.g xor GetGValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]));
                           Sum.b :=
                              Sum.b + (Sum.b xor GetBValue(Palette[SHP.Data[Frame].FrameImage[xc, yc]]));
                           Inc(Count);
                        end;
                  end;
               end;
            end;

            // Now it provides the value.
            if Count <> 0 then
            begin
               Matrix[x, y].r := Sum.r div Count;
               Matrix[x, y].g := Sum.g div Count;
               Matrix[x, y].b := Sum.b div Count;
            end
            else
            begin
               Matrix[x, y].r := GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].g := GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
               Matrix[x, y].b := GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]);
            end;
         end;
      end;
   //Finish the job
   ConvertMatrixToFrameImage(SHP, Palette, Frame, Left, Width, Top,
      Height, Matrix, Bg, IgnoreEvilColours, RedToRemapable, alg, UndoList);
end;

procedure LogarithmDarkening(const SHP: TSHP; const Palette: TPalette;
   Frame, Left, Width, Top, Height: integer; var Matrix: TRGBFrame; Bg: smallint);
var
   x, y: integer;
   Sum:  TRGBPixel;
begin
   // scan image
   for x := left to Width do
      for y := top to Height do
      begin
         // Calculate logarithm
         Sum.r := round(GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) -
            (2 * log2(1 + GetRValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));
         Sum.g := round(GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) -
            (2 * log2(1 + GetGValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));
         Sum.b := round(GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]) -
            (2 * log2(1 + GetBValue(Palette[SHP.Data[Frame].FrameImage[x, y]]))));

         // Now we fix the estimated value
         if Sum.r < 0 then
            Sum.r := 0
         else if Sum.r > 255 then
            Sum.r := 255;

         if Sum.g < 0 then
            Sum.g := 0
         else if Sum.g > 255 then
            Sum.g := 255;

         if Sum.b < 0 then
            Sum.b := 0
         else if Sum.b > 255 then
            Sum.b := 255;

         // Now it provides the value.
         Matrix[x, y].r := Sum.r;
         Matrix[x, y].g := Sum.g;
         Matrix[x, y].b := Sum.b;
      end;
end;

procedure SwitchColourOnFrame(var Frame : TFrameImage; x1,x2,y1,y2 : integer);
var
   temp : byte;
begin
   Temp := Frame[x1,y1];
   Frame[x1,y1] := Frame[x2,y2];
   Frame[x2,y2] := Temp;
end;

// Flip and Mirror
procedure MirrorFrame(var Frame : TFrameImage);
var
   maxx, maxy, x1, x2, y: integer;
begin
   maxx := High(Frame);
   if maxx >= 0 then
   begin
      maxy := High(Frame[0]);
      if maxy >= 0 then
      begin
         x2 := maxx;
         for x1 := 0 to (maxx div 2) do
         begin
            for y := 0 to maxy do
            begin
               SwitchColourOnFrame(Frame,x1,x2,y,y);
            end;
            dec(x2);
         end;
      end;
   end;
end;

procedure FlipFrame(var Frame : TFrameImage);
var
   maxx, maxy, x, y1, y2: integer;
begin
   maxx := High(Frame);
   if maxx >= 0 then
   begin
      maxy := High(Frame[0]);
      if maxy >= 0 then
      begin
         y2 := maxy;
         for y1 := 0 to (maxy div 2) do
         begin
            for x := 0 to maxx do
            begin
               SwitchColourOnFrame(Frame,x,x,y1,y2);
            end;
            dec(y2);
         end;
      end;
   end;
end;


end.
