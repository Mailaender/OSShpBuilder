unit SHP_Engine_Resize;

interface

uses shp_file, Windows, ComCtrls, Graphics, Types, Palette, SHP_Frame,
   SHP_engine, SHP_Engine_CCMs, Colour_List, SHP_Colour_Bank;

// Pixel Resizing Procedures
procedure Resize_Frame_Blocky(var SHP: TSHP; Frame, Width, Height: integer);
procedure Resize_Frames_Blocky(var SHP: TSHP; Width, Height: integer);
procedure Resize_Frames_Blocky_Progress(var SHP: TSHP; Width, Height: integer;
   Progress: TProgressbar);
procedure Resize_Bitmap_Blocky(var Bitmap: TBitmap; Width, Height: integer);
procedure Resize_FrameImage_Blocky(var Input: TFrameImage;
   InputWidth, InputHeight, Width, Height: integer);

// Property changes procedures
procedure Resize_SHP(var SHP: TSHP; Width, Height: integer);


// MS Paint related
procedure Resize_Frames_MSPaint(var SHP: TSHP; Palette: TPalette; Width, Height: integer);
procedure Resize_Frames_MSPaint_Progress(var SHP: TSHP; Palette: TPalette; Width, Height: integer;
   Progress: TProgressbar);
procedure Resize_FrameImage_MSPaint(var Input: TFrameImage;
   Palette : TPalette; InputWidth, InputHeight, Width, Height: integer;
   SHPType : TSHPType; SHPGame : TSHPGame; SmartMode: Boolean);


implementation

uses FormMain;

procedure Resize_Frame_Blocky(var SHP: TSHP; Frame, Width, Height: integer);
var
   cx, cy: integer; {current x and y, used as pointer for output.}
   x, y:   integer; {counter x and y for input}
   Output: array of array of byte;
   {this is a temporary matrix with the results, so I can have a reference of the original input}
   xmult, ymult: real; {multiplier of the width and height respectivelly}
   bx, by: integer;    {counters used when increasing X or Y to fill the gaps}
   maxcx, maxcy: integer; {reference to max cx and cy when increasing X or Y}

begin
   // Some basic data first
   xmult := Width / SHP.Header.Width;
   ymult := Height / SHP.Header.Height;

   SetLength(Output, Width + 1, Height + 1); {now output has memory alocated to it :)}
   {This will be the blocky mode, the crappiest, but most versatile method so far}
   // Blocky Mode begins...

   // Lets start with our big and lovely friend X
   // Shrinking operation and Raising will differ a bit, that's why I need to detect
   // what kind of operation it will do.

   if (SHP.Header.Width >= Width) then {shrink X}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (SHP.Header.Height >= Height) then  {shrink Y}
      begin
         // This will be the easiest code :)
         // X and Y will be multiplied by the percentage and the botton frames will replace
         // the top frames if they coincide...

         // Lines first, then columns...
         for y := 0 to SHP.Header.Height - 1 do
         begin
            cy := round(y * ymult);
            for x := 0 to SHP.Header.Width - 1 do
            begin
               cx := round(x * xmult);
               Output[cx, cy] := SHP.Data[Frame].FrameImage[x, y];
            end;
         end;
      end
      else if (SHP.Header.Height < Height) then
         {make Y bigger... I doubt someone will do something like that :P}
      begin
         // X will work like the code above, but Y will have a particular problem to be
         // solved. If you just multiply, there will be blank lines. So, we will need to
         // fill the gap with the previous line. This will give a blocky result, bad quality
         // but versatile.

         // Lines first, then columns
         for y := 0 to SHP.Header.Height - 1 do
         begin
            // Now, here comes the problem. "by" will be the counter used to detect when the
            // line changes.
            by    := 0; {resets counter}
            // this is the minimum cy. "by" will be increased to fill the gaps.
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               for x := 0 to SHP.Header.Width - 1 do
               begin
                  cx := round(x * xmult);
                  Output[cx, cy + by] := SHP.Data[Frame].FrameImage[x, y];
               end;
               Inc(by);
            end;
         end;
      end;
   end
   else if (SHP.Header.Width < Width) then {make X bigger}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (SHP.Header.Height >= Height) then  {shrink Y, another weirdo combination}
      begin
         // Y will work like the first code, but X will have the same particular problem
         // that Y had above. If you just multiply, there will be blank columns. So, we will
         // need to fill the gap with the previous columns. This will give a blocky result,
         // bad quality but versatile.

         // Lines first, then columns
         for y := 0 to SHP.Header.Height - 1 do
         begin
            for x := 0 to SHP.Header.Width - 1 do
            begin
               // Y is a piece of cake
               cy := round(y * ymult);

               // X Part (Big problem)
               bx    := 0; {resets counter}
               cx    := round(x * xmult);
               maxcx := round((x * xmult) + xmult);
               // Removed:    if (cx < 0) then cx:=0; {avoids access violation}
               //  Note: this access violation thing is useless. cx is never below 0.
               while ((cx + bx) <= maxcx) do
                  // copy the current line to the position until it reachs the max cx
               begin
                  Output[cx + bx, cy] := SHP.Data[Frame].FrameImage[x, y];
                  Inc(bx);
               end;
            end;
         end;
      end
      else if (SHP.Header.Height < Height) then {make Y bigger}
      begin
         // Both X and Y will have that particular problem above. If you just multiply them,
         // there will be blank lines and blank columns. So, we will need to fill the gaps
         // with the previous lines and columns. This will give a blocky result, bad
         // quality but versatile.

         // Lines first, then columns
         for y := 0 to SHP.Header.Height - 1 do
         begin
            // Y starts here.
            by    := 0; {resets counter}
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);
            // Removed: if (cy < 0) then cy := 0;

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               // X starts here
               for x := 0 to SHP.Header.Width - 1 do
               begin
                  bx    := 0; {resets counter}
                  cx    := round(x * xmult);
                  maxcx := round((x * xmult) + xmult);
                  // Removed:       if (cx < 0) then cx:=0; {avoids access violation}

                  while ((cx + bx) <= maxcx) do
                     // copy the current line to the position until it reachs the max cx
                  begin
                     Output[cx + bx, cy + by] := SHP.Data[Frame].FrameImage[x, y];
                     Inc(bx);
                  end;
               end;
               Inc(by);
            end;
         end;
      end;
   end;

   // Now, save the output in the SHP file.
   SetLength(SHP.Data[Frame].FrameImage, Width + 1, Height + 1);
   for y := 0 to Height do
      for x := 0 to Width do
         SHP.Data[Frame].FrameImage[x, y] := Output[x, y];
end;

procedure Resize_Frames_Blocky(var SHP: TSHP; Width, Height: integer);
var
   x: integer;
begin

   for x := 1 to SHP.Header.NumImages do
      Resize_Frame_Blocky(SHP, X, Width, Height);

   SHP.Header.Width  := Width;
   SHP.Header.Height := Height;
end;

procedure Resize_Frames_Blocky_Progress(var SHP: TSHP; Width, Height: integer;
   Progress: TProgressbar);
var
   x: integer;
begin
   Progress.Max      := SHP.Header.NumImages - 1;
   Progress.Position := 0;

   for x := 1 to SHP.Header.NumImages do
   begin
      Resize_Frame_Blocky(SHP, X, Width, Height);
      Progress.Position := x - 1; // Progressbar starts on 0 not 1.
      Progress.Refresh;
   end;

   SHP.Header.Width  := Width;
   SHP.Header.Height := Height;
end;

procedure Resize_Bitmap_Blocky(var Bitmap: TBitmap; Width, Height: integer);
var
   cx, cy: integer; {current x and y, used as pointer for output.}
   x, y:   integer; {counter x and y for input}
   Output: array of array of TColor;
   {this is a temporary matrix with the results, so I can have a reference of the original input}
   xmult, ymult: real; {multiplier of the width and height respectivelly}
   bx, by: integer;    {counters used when increasing X or Y to fill the gaps}
   maxcx, maxcy: integer; {reference to max cx and cy when increasing X or Y}

begin
   // Some basic data first
   xmult := Width / Bitmap.Width;
   ymult := Height / Bitmap.Height;

   SetLength(Output, Width + 1, Height + 1); {now output has memory alocated to it :)}
   {This will be the blocky mode, the crappiest, but most versatile method so far}
   // Blocky Mode begins...

   // Lets start with our big and lovely friend X
   // Shrinking operation and Raising will differ a bit, that's why I need to detect
   // what kind of operation it will do.

   if (Bitmap.Width >= Width) then {shrink X}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (Bitmap.Height >= Height) then  {shrink Y}
      begin
         // This will be the easiest code :)
         // X and Y will be multiplied by the percentage and the botton frames will replace
         // the top frames if they coincide...

         // Lines first, then columns...
         for y := 0 to Bitmap.Height - 1 do
         begin
            cy := round(y * ymult);
            for x := 0 to Bitmap.Width - 1 do
            begin
               cx := round(x * xmult);
               Output[cx, cy] := Bitmap.Canvas.Pixels[x, y];
            end;
         end;
      end
      else if (Bitmap.Height < Height) then
         {make Y bigger... I doubt someone will do something like that :P}
      begin
         // X will work like the code above, but Y will have a particular problem to be
         // solved. If you just multiply, there will be blank lines. So, we will need to
         // fill the gap with the previous line. This will give a blocky result, bad quality
         // but versatile.

         // Lines first, then columns
         for y := 0 to Bitmap.Height - 1 do
         begin
            // Now, here comes the problem. "by" will be the counter used to detect when the
            // line changes.
            by    := 0; {resets counter}
            // this is the minimum cy. "by" will be increased to fill the gaps.
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);
            //          if (cy < 0) then cy := 0;

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               for x := 0 to Bitmap.Width - 1 do
               begin
                  cx := round(x * xmult);
                  Output[cx, cy + by] := Bitmap.Canvas.Pixels[x, y];
               end;
               Inc(by);
            end;
         end;
      end;
   end
   else if (Bitmap.Width < Width) then {make X bigger}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (Bitmap.Height >= Height) then  {shrink Y, another weirdo combination}
      begin
         // Y will work like the first code, but X will have the same particular problem
         // that Y had above. If you just multiply, there will be blank columns. So, we will
         // need to fill the gap with the previous columns. This will give a blocky result,
         // bad quality but versatile.

         // Lines first, then columns
         for y := 0 to Bitmap.Height - 1 do
         begin
            for x := 0 to Bitmap.Width - 1 do
            begin
               // Y is a piece of cake
               cy := round(y * ymult);

               // X Part (Big problem)
               bx    := 0; {resets counter}
               cx    := round(x * xmult);
               maxcx := round((x * xmult) + xmult);
               // Removed:    if (cx < 0) then cx:=0; {avoids access violation}
               //  Note: this access violation thing is useless. cx is never below 0.
               while ((cx + bx) <= maxcx) do
                  // copy the current line to the position until it reachs the max cx
               begin
                  Output[cx + bx, cy] := Bitmap.Canvas.Pixels[x, y];
                  Inc(bx);
               end;
            end;
         end;
      end
      else if (Bitmap.Height < Height) then {make Y bigger}
      begin
         // Both X and Y will have that particular problem above. If you just multiply them,
         // there will be blank lines and blank columns. So, we will need to fill the gaps
         // with the previous lines and columns. This will give a blocky result, bad
         // quality but versatile.

         // Lines first, then columns
         for y := 0 to Bitmap.Height - 1 do
         begin
            // Y starts here.
            by    := 0; {resets counter}
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               // X starts here
               for x := 0 to Bitmap.Width - 1 do
               begin
                  bx    := 0; {resets counter}
                  cx    := round(x * xmult);
                  maxcx := round((x * xmult) + xmult);
                  // Removed:       if (cx < 0) then cx:=0; {avoids access violation}

                  while ((cx + bx) <= maxcx) do
                     // copy the current line to the position until it reachs the max cx
                  begin
                     Output[cx + bx, cy + by] := Bitmap.Canvas.Pixels[x, y];
                     Inc(bx);
                  end;
               end;
               Inc(by);
            end;
         end;
      end;
   end;

   // Now, save the output in the Bitmap file.
   Bitmap.Height := Height + 1;
   Bitmap.Width  := Width + 1;
   for y := 0 to Height do
      for x := 0 to Width do
         Bitmap.Canvas.Pixels[x, y] := Output[x, y];
end;

procedure Resize_FrameImage_Blocky(var Input: TFrameImage;
   InputWidth, InputHeight, Width, Height: integer);
var
   cx, cy: integer; {current x and y, used as pointer for output.}
   x, y:   integer; {counter x and y for input}
   Output: array of array of byte;
   {this is a temporary matrix with the results, so I can have a reference of the original input}
   xmult, ymult: real; {multiplier of the width and height respectivelly}
   bx, by: integer;    {counters used when increasing X or Y to fill the gaps}
   maxcx, maxcy: integer; {reference to max cx and cy when increasing X or Y}

begin
   // Some basic data first
   xmult := Width / InputWidth;
   ymult := Height / InputHeight;

   SetLength(Output, Width + 1, Height + 1); {now output has memory alocated to it :)}
   {This will be the blocky mode, the crappiest, but most versatile method so far}
   // Blocky Mode begins...

   // Lets start with our big and lovely friend X
   // Shrinking operation and Raising will differ a bit, that's why I need to detect
   // what kind of operation it will do.

   if (InputWidth >= Width) then {shrink X}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (InputHeight >= Height) then  {shrink Y}
      begin
         // This will be the easiest code :)
         // X and Y will be multiplied by the percentage and the botton frames will replace
         // the top frames if they coincide...

         // Lines first, then columns...
         for y := 0 to InputHeight - 1 do
         begin
            cy := round(y * ymult);
            for x := 0 to InputWidth - 1 do
            begin
               cx := round(x * xmult);
               Output[cx, cy] := Input[x, y];
            end;
         end;
      end
      else if (InputHeight < Height) then
         {make Y bigger... I doubt someone will do something like that :P}
      begin
         // X will work like the code above, but Y will have a particular problem to be
         // solved. If you just multiply, there will be blank lines. So, we will need to
         // fill the gap with the previous line. This will give a blocky result, bad quality
         // but versatile.

         // Lines first, then columns
         for y := 0 to InputHeight - 1 do
         begin
            // Now, here comes the problem. "by" will be the counter used to detect when the
            // line changes.
            by    := 0; {resets counter}
            // this is the minimum cy. "by" will be increased to fill the gaps.
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               for x := 0 to InputWidth - 1 do
               begin
                  cx := round(x * xmult);
                  Output[cx, cy + by] := Input[x, y];
               end;
               Inc(by);
            end;
         end;
      end;
   end
   else if (InputWidth < Width) then {make X bigger}
   begin
      // Now we have to know the same thing for our lovely friend Y
      if (InputHeight >= Height) then  {shrink Y, another weirdo combination}
      begin
         // Y will work like the first code, but X will have the same particular problem
         // that Y had above. If you just multiply, there will be blank columns. So, we will
         // need to fill the gap with the previous columns. This will give a blocky result,
         // bad quality but versatile.

         // Lines first, then columns
         for y := 0 to InputHeight - 1 do
         begin
            for x := 0 to InputWidth - 1 do
            begin
               // Y is a piece of cake
               cy := round(y * ymult);

               // X Part (Big problem)
               bx    := 0; {resets counter}
               cx    := round(x * xmult);
               maxcx := round((x * xmult) + xmult);
               // Removed:    if (cx < 0) then cx:=0; {avoids access violation}
               //  Note: this access violation thing is useless. cx is never below 0.
               while ((cx + bx) <= maxcx) do
                  // copy the current line to the position until it reachs the max cx
               begin
                  Output[cx + bx, cy] := Input[x, y];
                  Inc(bx);
               end;
            end;
         end;
      end
      else if (InputHeight < Height) then {make Y bigger}
      begin
         // Both X and Y will have that particular problem above. If you just multiply them,
         // there will be blank lines and blank columns. So, we will need to fill the gaps
         // with the previous lines and columns. This will give a blocky result, bad
         // quality but versatile.

         // Lines first, then columns
         for y := 0 to InputHeight - 1 do
         begin
            // Y starts here.
            by    := 0; {resets counter}
            cy    := round(y * ymult);
            maxcy := round((y * ymult) + ymult);
            // Removed: if (cy < 0) then cy := 0;

            while ((cy + by) <= maxcy) do
               // copy the current line to the position until it reachs the max cy
            begin
               // X starts here
               for x := 0 to InputWidth - 1 do
               begin
                  bx    := 0; {resets counter}
                  cx    := round(x * xmult);
                  maxcx := round((x * xmult) + xmult);
                  // Removed:       if (cx < 0) then cx:=0; {avoids access violation}

                  while ((cx + bx) <= maxcx) do
                     // copy the current line to the position until it reachs the max cx
                  begin
                     Output[cx + bx, cy + by] := Input[x, y];
                     Inc(bx);
                  end;
               end;
               Inc(by);
            end;
         end;
      end;
   end;

   // Now, save the output in the FrameImage variable.
   SetLength(Input, Width + 1, Height + 1);
   for y := 0 to Height do
      for x := 0 to Width do
         Input[x, y] := Output[x, y];
end;

// Yes, it is that simple!!!
procedure Resize_SHP(var SHP: TSHP; Width, Height: integer);
var
   Frame : integer;
begin
   SHP.Header.Width := Width;
   SHP.Header.Height := Height;
   for Frame := 1 to SHP.Header.NumImages do
   begin
      SetLength(SHP.Data[Frame].FrameImage,width,height);
   end;
end;

procedure Resize_Frames_MSPaint(var SHP: TSHP; Palette: TPalette; Width, Height: integer);
var
   x: integer;
begin
   for x := 1 to SHP.Header.NumImages do
      Resize_FrameImage_MSPaint(SHP.Data[X].FrameImage, Palette, SHP.Header.Width, SHP.Header.Height, Width, Height, SHP.SHPType, SHP.SHPGame, false);

   SHP.Header.Width  := Width;
   SHP.Header.Height := Height;
end;

procedure Resize_Frames_MSPaint_Progress(var SHP: TSHP; Palette: TPalette; Width, Height: integer;
   Progress: TProgressbar);
var
   x: integer;
begin
   Progress.Max      := SHP.Header.NumImages - 1;
   Progress.Position := 0;

   for x := 1 to SHP.Header.NumImages do
   begin
      Resize_FrameImage_MSPaint(SHP.Data[X].FrameImage, Palette, SHP.Header.Width, SHP.Header.Height, Width, Height, SHP.SHPType, SHP.SHPGame, false);
      Progress.Position := x - 1; // Progressbar starts on 0 not 1.
      Progress.Refresh;
   end;

   SHP.Header.Width  := Width;
   SHP.Header.Height := Height;
end;

procedure Resize_FrameImage_MSPaint(var Input: TFrameImage;
   Palette : TPalette; InputWidth, InputHeight, Width, Height: integer;
   SHPType : TSHPType; SHPGame : TSHPGame; SmartMode: Boolean);
var
   OldBitmap,NewBitmap : TBitmap;
   List,Last:listed_colour;
   Start : colour_element;
begin
   NewBitmap := TBitmap.Create;
   OldBitmap := GetBMPOfFrameImage(Input,Palette,InputWidth,InputHeight);
   NewBitmap.Width := Width;
   NewBitmap.Height := Height;
   NewBitmap.Canvas.StretchDraw(Rect(0,0,NewBitmap.Height,NewBitmap.Width),OldBitmap);

   GenerateColourList(Palette,List,Last,Palette[0],true,false,false);
   PrepareBank(Start,List,Last);
   SetLength(Input,Width,Height);
   LoadFrameImageToSHP(Input,NewBitmap,List,Last,Start,FrmMain.alg,false);

   // Now, insert the code to translate the bitmap back to SHP.
{
   if SmartMode then
   begin
      if not (SHPType = stCameo) then
      begin
         // We should consider the ignoring background here.
         if IsSHPRemmapable(SHPType) then
         begin
            // We'll add a special treatment to remaps here.
            case (SHPGame) of
              sgTD:
              begin
              end;
              sgRA1:
              begin
              end;
              else
              begin
              end;
            end;
         end
         else
         begin
            // Treatment only for colour #0.
         end;
      end;
   end;
}
   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
   NewBitmap.Free;
   OldBitmap.Free;
end;

end.
