unit SHP_Canvas;

interface

uses Windows, Classes, Graphics, shp_file;

// Canvas Resizing Procedures (FrameImage)
procedure CanvasResize(var Frame: TFrameImage;
   Width, Height, XBegin, YBegin, XEnd, YEnd: integer; PaletteColour: byte); overload;
procedure CanvasPullHorizontal(var Frame: TFrameImage; MaxHeight, Position: integer);
   overload;
procedure CanvasPullVertical(var Frame: TFrameImage; MaxWidth, Position: integer);
   overload;
procedure CanvasPushHorizontal(var Frame: TFrameImage;
   MaxWidth, MaxHeight, Position: integer); overload;
procedure CanvasPushVertical(var Frame: TFrameImage;
   MaxWidth, MaxHeight, Position: integer); overload;
procedure CanvasCreateEmptyHorizontalQueue(var Frame: TFrameImage;
   MaxWidth, Position: integer; PaletteColour: byte);
procedure CanvasCreateEmptyVerticalQueue(var Frame: TFrameImage;
   MaxHeight, Position: integer; PaletteColour: byte);

// Canvas Resizing Procedures (Bitmap)
procedure CanvasResize(var Bitmap: TBitmap;
   Width, Height, XBegin, YBegin, XEnd, YEnd: integer);
   overload;
procedure CanvasPullHorizontal(var Bitmap: TBitmap; MaxHeight, Position: integer);
   overload;
procedure CanvasPullVertical(var Bitmap: TBitmap; MaxWidth, Position: integer); overload;
procedure CanvasPushHorizontal(var Bitmap: TBitmap;
   MaxWidth, MaxHeight, Position: integer);
   overload;
procedure CanvasPushVertical(var Bitmap: TBitmap;
   MaxWidth, MaxHeight, Position: integer);
   overload;

implementation

// Canvas Procedures (FrameImage)
procedure CanvasResize(var Frame: TFrameImage;
   Width, Height, XBegin, YBegin, XEnd, YEnd: integer; PaletteColour: byte);
begin
   // The objective is to make XBegin, YBegin, XEnd and YEnd become 0.

   // They are the ammount of canvas to be added or subtracted from
   // the beggining and/or the end in horizontal and/or vertical positions.

   Dec(Width);
   Dec(Height);

   while XBegin < 0 do
   begin
      Inc(Width);
      SetLength(Frame, Width + 1, Height + 1);
      CanvasPushHorizontal(Frame, Width, Height, 1);
      CanvasCreateEmptyVerticalQueue(Frame, Height, 0, PaletteColour);
      Inc(XBegin);
   end;
   while (XBegin > 0) do
   begin
      Dec(Width);
      CanvasPullHorizontal(Frame, Height, Width);
      SetLength(Frame, Width + 1, Height + 1);
      Dec(XBegin);
   end;
   while (XEnd > 0) do
   begin
      Inc(Width);
      SetLength(Frame, Width + 1, Height + 1);
      CanvasCreateEmptyVerticalQueue(Frame, Height, Width, PaletteColour);
      Dec(xend);
   end;
   while (XEnd < 0) do
   begin
      Dec(Width);
      SetLength(Frame, Width + 1, Height + 1);
      Inc(xend);
   end;
   while (YBegin < 0) do
   begin
      Inc(Height);
      SetLength(Frame, Width + 1, Height + 1);
      CanvasPushVertical(Frame, Width, Height, 0);
      CanvasCreateEmptyHorizontalQueue(Frame, Width, 0, PaletteColour);
      Inc(ybegin);
   end;
   while (YBegin > 0) do
   begin
      CanvasPullVertical(Frame, Width, Height);
      Dec(Height);
      SetLength(Frame, Width + 1, Height + 1);
      Dec(ybegin);
   end;
   while (YEnd > 0) do
   begin
      Inc(Height);
      SetLength(Frame, Width + 1, Height + 1);
      CanvasCreateEmptyHorizontalQueue(Frame, Width, Height, PaletteColour);
      Dec(yend);
   end;
   while (YEnd < 0) do
   begin
      Dec(Height);
      SetLength(Frame, Width + 1, Height + 1);
      Inc(yend);
   end;
end;

// The four procedures below works in a recursive way.
procedure CanvasPullHorizontal(var Frame: TFrameImage; MaxHeight, Position: integer);
var
   y: integer;
begin
   // This works in a simple way:

   // If the position is -1 it does nothing
   // Otherwise, it copies the following position into the current one
   if Position >= 0 then
   begin
      CanvasPullHorizontal(Frame, MaxHeight, Position - 1);
      // copy previous position to current one
      for y := 0 to MaxHeight do
         Frame[position, y] := Frame[position + 1, y];
   end;
end;

procedure CanvasPushHorizontal(var Frame: TFrameImage;
   MaxWidth, MaxHeight, Position: integer);
var
   y: integer;
begin
   // This works in a simple way:

   // If the position is bigger than the max width, it does nothing
   // Otherwise, it copies the previous position into the current one
   if Position <= MaxWidth then
   begin
      CanvasPushHorizontal(Frame, MaxWidth, MaxHeight, Position + 1);
      // copy previous position to current one
      for y := 0 to MaxHeight do
         Frame[position, y] := Frame[position - 1, y];
   end;
end;

procedure CanvasPullVertical(var Frame: TFrameImage; MaxWidth, Position: integer);
var
   x: integer;
begin
   // This works in a simple way:

   // If the position is -1 it does nothing
   // Otherwise, it copies the following position into the current one
   if Position >= 0 then
   begin
      CanvasPullVertical(Frame, MaxWidth, Position - 1);
      // copy previous position to current one
      for x := 0 to MaxWidth do
         Frame[x, position] := Frame[x, position + 1];
   end;
end;

procedure CanvasPushVertical(var Frame: TFrameImage;
   MaxWidth, MaxHeight, Position: integer);
var
   x: integer;
begin
   // This works in a simple way:

   // If the position is bigger than the max height, it does nothing
   // Otherwise, it copies the previous position into the current one
   if Position <= MaxHeight then
   begin
      CanvasPushVertical(Frame, MaxWidth, MaxHeight, Position + 1);
      // copy previous position to current one
      for x := 0 to MaxWidth do
         Frame[x, position] := Frame[x, position - 1];
   end;
end;

// Create empty queues, very easy to understand
procedure CanvasCreateEmptyHorizontalQueue(var Frame: TFrameImage;
   MaxWidth, Position: integer; PaletteColour: byte);
var
   x: integer;
begin
   for x := 0 to MaxWidth do
      Frame[x, position] := PaletteColour;

end;

procedure CanvasCreateEmptyVerticalQueue(var Frame: TFrameImage;
   MaxHeight, Position: integer; PaletteColour: byte);
var
   y: integer;
begin
   for y := 0 to MaxHeight do
      Frame[position, y] := PaletteColour;

end;


// Canvas Procedures (Bitmap)
procedure CanvasResize(var Bitmap: TBitmap;
   Width, Height, XBegin, YBegin, XEnd, YEnd: integer);
   overload;
begin
   // The objective is to make XBegin, YBegin, XEnd and YEnd become 0.

   // They are the ammount of canvas to be added or subtracted from
   // the beggining and/or the end in horizontal and/or vertical positions.

   Dec(Width);
   Dec(Height);


   while XBegin < 0 do
   begin
      Bitmap.Width := Bitmap.Width + 1;
      Inc(Width);
      Bitmap.Canvas.Brush.Color := Bitmap.Canvas.Pixels[0, 0];
      CanvasPushHorizontal(Bitmap, Width, Height, 1);
      Bitmap.Canvas.FillRect(Rect(0, 0, 0, Height));
      Inc(XBegin);
   end;
   while (XBegin > 0) do
   begin
      CanvasPullHorizontal(Bitmap, Height, Width - 1);
      Bitmap.Width := Bitmap.Width - 1;
      Dec(Width);
      Dec(XBegin);
   end;
   while (XEnd > 0) do
   begin
      Bitmap.Width := Bitmap.Width + 1;
      Inc(Width);
      Bitmap.Canvas.Brush.Color := Bitmap.Canvas.Pixels[0, 0];
      Bitmap.Canvas.FillRect(Rect(Width, 0, Width, Height));
      Dec(xend);
   end;
   while (XEnd < 0) do
   begin
      Bitmap.Width := Bitmap.Width - 1;
      Dec(Width);
      Inc(xend);
   end;
   while (YBegin < 0) do
   begin
      Bitmap.Height := Bitmap.Height + 1;
      Inc(Height);
      CanvasPushVertical(Bitmap, Width, Height, 1);
      Bitmap.Canvas.Brush.Color := Bitmap.Canvas.Pixels[0, 0];
      Bitmap.Canvas.FillRect(Rect(0, 0, Width, 0));
      Inc(ybegin);
   end;
   while (YBegin > 0) do
   begin
      CanvasPullVertical(Bitmap, Width, Height - 1);
      Bitmap.Height := Bitmap.Height - 1;
      Dec(Height);
      Dec(ybegin);
   end;
   while (YEnd > 0) do
   begin
      Bitmap.Height := Bitmap.Height + 1;
      Inc(Height);
      Bitmap.Canvas.Brush.Color := Bitmap.Canvas.Pixels[0, 0];
      Bitmap.Canvas.FillRect(Rect(0, Height, Width, Height));
      Dec(yend);
   end;
   while (YEnd < 0) do
   begin
      Bitmap.Height := Bitmap.Height - 1;
      Inc(yend);
   end;
end;

// The four procedures below works in a recursive way.
procedure CanvasPullHorizontal(var Bitmap: TBitmap; MaxHeight, Position: integer);
var
   y: integer;
begin
   // This works in a simple way:

   // If the position is -1 it does nothing
   // Otherwise, it copies the following position into the current one
   if Position >= 0 then
   begin
      CanvasPullHorizontal(Bitmap, MaxHeight, Position - 1);
      // copy previous position to current one
      for y := 0 to MaxHeight do
         Bitmap.Canvas.Pixels[position, y] := Bitmap.Canvas.Pixels[position + 1, y];
   end;
end;

procedure CanvasPushHorizontal(var Bitmap: TBitmap;
   MaxWidth, MaxHeight, Position: integer);
var
   y: integer;
begin
   // This works in a simple way:

   // If the position is bigger than the max width, it does nothing
   // Otherwise, it copies the previous position into the current one
   if Position <= MaxWidth then
   begin
      CanvasPushHorizontal(Bitmap, MaxWidth, MaxHeight, Position + 1);
      // copy previous position to current one
      for y := 0 to MaxHeight do
         Bitmap.Canvas.Pixels[position, y] := Bitmap.Canvas.Pixels[position - 1, y];
   end;
end;

procedure CanvasPullVertical(var Bitmap: TBitmap; MaxWidth, Position: integer);
var
   x: integer;
begin
   // This works in a simple way:

   // If the position is -1 it does nothing
   // Otherwise, it copies the following position into the current one
   if Position >= 0 then
   begin
      CanvasPullVertical(Bitmap, MaxWidth, Position - 1);
      // copy previous position to current one
      for x := 0 to MaxWidth do
         Bitmap.Canvas.Pixels[x, position] := Bitmap.Canvas.Pixels[x, position + 1];
   end;
end;

procedure CanvasPushVertical(var Bitmap: TBitmap;
   MaxWidth, MaxHeight, Position: integer);
var
   x: integer;
begin
   // This works in a simple way:

   // If the position is bigger than the max height, it does nothing
   // Otherwise, it copies the previous position into the current one
   if Position <= MaxHeight then
   begin
      CanvasPushVertical(Bitmap, MaxWidth, MaxHeight, Position + 1);
      // copy previous position to current one
      for x := 0 to MaxWidth do
         Bitmap.Canvas.Pixels[x, position] := Bitmap.Canvas.Pixels[x, position - 1];
   end;
end;

{

Function CanvasResize(Bitmap:TBitmap; XBegin,YBegin,XEnd,YEnd:Integer)TBitmap; overload;
var
X,Y : integer;
begin
Result := TBitmap.Create;
Result.Width := XEnd-XBegin;
Result.Height := YEnd-YBegin;

for x := 1 to Result.Width do
for y := 1 to Result.Height do
Result.Canvas.Pixels[x,y] := Bitmap.Canvas.Pixels[x+XBegin,y+YBegin];

end;

}


end.
