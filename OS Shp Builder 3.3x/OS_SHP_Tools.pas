unit OS_SHP_Tools;

interface
uses Windows, Graphics, SHP_Image, SHP_File, math, Palette, Colour_list, SHP_Colour_Bank,
     SHP_Engine_CCMs;


// Functions

// Line
function GetGradient(last,first : TPoint2D) : single;

procedure PreviewLine(var tempview : TObjectData; var tempViewLength : integer; var last,first : TPoint2D);

// Flood And Fill
procedure FloodFillTool(var SHP: TSHP; Frame,Xpos,Ypos: Integer; Colour : byte);
procedure FloodFillGradientTool(var SHP: TSHP; Frame,Xpos,Ypos: Integer; Palette : TPalette; Colour : byte);
procedure FloodFillWithBlur(var SHP: TSHP; Frame,Xpos,Ypos: Integer; Palette : TPalette; Colour,Alg : byte);

// Rectangle
procedure Rectangle(var tempView: TObjectData; var tempViewLength : integer; x1, y1, x2, y2 : Integer; doFill: Boolean);
procedure Rectangle_dotted(const SHP: TSHP; var TempView: TObjectData; var TempView_no:integer; const SHPPalette:TPalette; Frame: Word; Xpos,Ypos,Xpos2,Ypos2:Integer);

// Elipse
procedure Elipse(var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos,Xpos2,Ypos2:Integer; Fill: Boolean);

// Brush
procedure BrushTool(var SHP: TSHP; var TempView: TObjectData; var tempViewLength: integer; Xc, Yc, BrushMode, Colour: TColor);


// DarkenLighten
procedure BrushToolDarkenLighten(var SHP:TSHP; Frame: Word; Xc,Yc: Integer; BrushMode: Integer); overload;
procedure BrushToolDarkenLighten(var SHP:TSHP; var TempView: TObjectData; var TempView_no: integer; Frame: Word; Xc,Yc: Integer; BrushMode: Integer); overload;
function darkenlightenv(Darken:boolean; Current_Value,Value : byte) : byte;

// Damager
procedure AddColourToSHP(var SHP : TSHP; var Palette: TPalette; frameIndex, x, y, alg:Integer; var List, Last : listed_colour; bias, division:byte);
procedure AddColourToTempview(const SHP:TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);

procedure Crash(const SHP: TSHP; var Palette: TPalette; var tempView: TObjectData; var tempViewLength : integer; Xpos,Ypos:Integer; const frameIndex: integer; const Alg : integer); overload;
procedure Crash(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashLight(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashLight(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashBig(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashBig(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashBigLight(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure CrashBigLight(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure Dirty(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure Dirty(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;

// Snowy
procedure AddSnowColourToTempview(const SHP:TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);
procedure AddSnowColourToSHP(var SHP:TSHP; const Palette: TPalette; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);
procedure Snow(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure Snow(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;

// Etc...
function InImageBounds(x,y : integer; const SHP:TSHP) : boolean;
function OpositeColour(color : TColor) : tcolor;


implementation

uses FormMain;


//---------------------------------------------
// Get Gradient
//---------------------------------------------
function GetGradient(last, first : TPoint2D) : single;
begin
   if (first.X = last.X) or (first.Y = last.Y) then
      result := 0
   else
      result := (first.Y-last.Y) / (first.X-last.X);
end;


//---------------------------------------------
// Draw Straight Line - Preview
//---------------------------------------------
procedure PreviewLine(var tempview : TObjectData; var tempViewLength : integer; var last, first : TPoint2D);
var
   x, y : integer;
   gradient, c : single;
begin
   tempViewLength := 0;
   SetLength(tempView, 0);

   gradient := GetGradient(last, first);
   c := last.Y - (last.X * gradient);

   if (gradient = 0) and (first.X = last.X) then
      for y := min(first.Y,last.y) to max(first.Y,last.y) do
      begin
         tempViewLength := tempViewLength + 1;
         SetLength(tempView, tempViewLength + 1);

         tempView[tempViewLength].X := first.X;
         tempView[tempViewLength].Y := y;
      end  
   else
   if (gradient = 0) and (first.Y = last.Y) then
      for x := min(first.x,last.x) to max(first.x,last.x) do
      begin
         tempViewLength := tempViewLength +1;
         setlength(tempView,tempViewLength+1);

         tempView[tempViewLength].X := x;
         tempView[tempViewLength].Y := first.Y;
      end
   else
   begin
      for x := min(first.X,last.X) to max(first.X,last.X) do
      begin
         tempViewLength := tempViewLength +1;
         setlength(tempView,tempViewLength+1);

         tempView[tempViewLength].X := x;
         tempView[tempViewLength].Y := round((gradient*x)+c);
      end;


      for y := min(first.Y,last.Y) to max(first.Y,last.Y) do
      begin
         tempViewLength := tempViewLength +1;
         setlength(tempView,tempViewLength+1);

         tempView[tempViewLength].X := round((y-c)/ gradient);
         tempView[tempViewLength].Y := y;
      end;
   end;
end;


//---------------------------------------------
// Do Flood Fill - On frame
//---------------------------------------------
procedure FloodFillTool(var SHP: TSHP; Frame, Xpos, Ypos: Integer; Colour : byte);
type
   FloodSet = (Left,Right,Up,Down);
   Flood2DPoint = record
      X,Y: Integer;
   end;
   StackType = record
      Dir: set of FloodSet;
      p: Flood2DPoint;
   end;

   function PointOK(var SHP:TSHP; l: Flood2DPoint): Boolean;
   begin
      PointOK:=False;
      if (l.X<0) or (l.Y<0) then Exit;
      if (l.X>=SHP.Header.Width) or (l.Y>=SHP.Header.Height) then Exit;
      PointOK:=True;
   end;
var
   z1,z2: byte;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: Flood2DPoint;
   Full: set of FloodSet;
   Done: Array of Array of Boolean;
begin
   SetLength(Done,SHP.Header.Width,SHP.Header.Height);
   SetLength(Stack,SHP.Header.Width*SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i:=0 to SHP.Header.Width - 1 do
      for j:=0 to SHP.Header.Height - 1 do
         Done[i,j]:=False;

   z1 := SHP.Data[Frame].FrameImage[Xpos,Ypos];
   SHP.Data[Frame].FrameImage[Xpos,Ypos] := Colour;


   Full:=[Left,Right,Up,Down];
   Sp:=0;
   Stack[Sp].Dir:=Full;
   Stack[Sp].p.X:=Xpos; Stack[Sp].p.Y:=Ypos;
   SC:=1;
   while (SC>0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Left];
         po:=Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Right]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Right];
         po:=Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Left]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check right
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Up];
         po:=Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Down]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Down];
         po:=Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Up]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if (Stack[Sp].Dir = []) then
      begin
         Dec(Sp);
         Dec(SC);
         //decrease stack pointer and stack count
      end;
   end;
   SetLength(Stack,0); // Free Up Memory
   SetLength(Done,0); // Free Up Memory
end;


//---------------------------------------------
// Do Flood Fill with Gradient - On frame
//---------------------------------------------
procedure FloodFillGradientTool(var SHP: TSHP; Frame,Xpos,Ypos: Integer; Palette : TPalette; Colour : byte);
type
   FloodSet = (Left,Right,Up,Down);
   Flood2DPoint = record
      X,Y: Integer;
   end;
   StackType = record
      Dir: set of FloodSet;
      p: Flood2DPoint;
   end;
   function PointOK(var SHP:TSHP; l: Flood2DPoint): Boolean;
   begin
      PointOK:=False;
      if (l.X<0) or (l.Y<0) then Exit;
      if (l.X>=SHP.Header.Width) or (l.Y>=SHP.Header.Height) then Exit;
      PointOK:=True;
   end;
var
   z1,z2: byte;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: Flood2DPoint;
   Full: set of FloodSet;
   Done: Array of Array of Boolean;
   Cache : TCache;
begin
   // 3.36: Build gradient cache
   Cache := BuildCacheReplacementForGradients(Palette,SHP.Data[Frame].FrameImage[XPos,YPos],Colour);
   // end of gradient cache code.
   SetLength(Done,SHP.Header.Width,SHP.Header.Height);
   SetLength(Stack,SHP.Header.Width*SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i:=0 to SHP.Header.Width - 1 do
      for j:=0 to SHP.Header.Height - 1 do
         Done[i,j]:=False;

   z1 := SHP.Data[Frame].FrameImage[Xpos,Ypos];
   SHP.Data[Frame].FrameImage[Xpos,Ypos] := Colour;


   Full:=[Left,Right,Up,Down];
   Sp:=0;
   Stack[Sp].Dir:=Full;
   Stack[Sp].p.X:=Xpos; Stack[Sp].p.Y:=Ypos;
   SC:=1;
   while (SC>0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Left];
         po:=Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2 <> Cache[z2] then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Cache[z2];
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Right]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Right];
         po:=Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2 <> Cache[z2] then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Cache[z2];
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Left]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
        end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Up];
         po:=Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2 <> Cache[z2] then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Cache[z2];
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Down]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Down];
         po:=Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2 <> Cache[z2] then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Cache[z2];
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Up]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if (Stack[Sp].Dir = []) then
      begin
         Dec(Sp);
         Dec(SC);
         //decrease stack pointer and stack count
      end;
   end;
   SetLength(Stack,0); // Free Up Memory
   SetLength(Done,0); // Free Up Memory
end;


//---------------------------------------------
// Do Flood Fill with Blur - On frame
//---------------------------------------------
procedure FloodFillWithBlur(var SHP: TSHP; Frame,Xpos,Ypos: Integer; Palette : TPalette; Colour,Alg : byte);
type
   FloodSet = (Left,Right,Up,Down);
   Flood2DPoint = record
      X,Y: Integer;
   end;
   StackType = record
      Dir: set of FloodSet;
      p: Flood2DPoint;
   end;
   TFinalListElement = record
      P : Flood2DPoint;
      Colour : integer;
   end;
   TFinalList = array of TFinalListElement;
   function PointOK(const SHP:TSHP; l: Flood2DPoint): Boolean;
   begin
      PointOK:=False;
      if (l.X<0) or (l.Y<0) then Exit;
      if (l.X>=SHP.Header.Width) or (l.Y>=SHP.Header.Height) then Exit;
      PointOK:=True;
   end;

   procedure AddToFinalList(var _FinalList : TFinalList; _x, _y :integer);
   begin
      SetLength(_FinalList,High(_FinalList)+2);
      _FinalList[High(_FinalList)].P.X := _x;
      _FinalList[High(_FinalList)].P.Y := _y;
   end;

   function GetBlurredColour(const _SHP: TSHP; const _Palette : TPalette; var _List,_Last: listed_colour; const _Point : Flood2DPoint; _Frame,_Alg : integer): integer;
   var
      count,x,y : integer;
      CurrentPoint : Flood2DPoint;
      TempR,TempG,TempB : integer;
   begin
      Result := -1;
      count := 0;
      TempR := 0;
      TempG := 0;
      TempB := 0;
      for x := (_Point.X - 1) to (_Point.X + 1) do
      begin
         for y := (_Point.Y - 1) to (_Point.Y + 1) do
         begin
            CurrentPoint.X := x;
            CurrentPoint.Y := y;
            if PointOK(_SHP,CurrentPoint) then
            begin
               inc(count);
               TempR := TempR + GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[x,y]]);
               TempG := TempG + GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[x,y]]);
               TempB := TempB + GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[x,y]]);
            end;
         end;
      end;
      if count = 0 then exit;
      // Now, if things work fine, we'll continue.
      TempR := TempR div count;
      TempG := TempG div count;
      TempB := TempB div count;
      // Now, we get the result.
      Result := LoadPixel(_List,_Last,_alg,RGB(TempR,TempG,TempB));
   end;
var
   z1,z2: byte;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: Flood2DPoint;
   Full: set of FloodSet;
   Done: Array of Array of Boolean;
   // The new things from the Blurr one.
   FinalList : TFinalList;
   List,Last: listed_colour;
   Start : colour_element;
begin
   // 3.36: FinalList initialization
   SetLength(FinalList,0);
   // Set List and Last
   GenerateColourList(Palette,List,Last,Palette[0],true,false,false,false);
   // Prepare Bank
   PrepareBank(Start,List,Last);

   // Old code resumes here...
   SetLength(Done,SHP.Header.Width,SHP.Header.Height);
   SetLength(Stack,SHP.Header.Width*SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i:=0 to SHP.Header.Width - 1 do
      for j:=0 to SHP.Header.Height - 1 do
         Done[i,j]:=False;

   z1 := SHP.Data[Frame].FrameImage[Xpos,Ypos];
   SHP.Data[Frame].FrameImage[Xpos,Ypos] := Colour;


   Full:=[Left,Right,Up,Down];
   Sp:=0;
   Stack[Sp].Dir:=Full;
   Stack[Sp].p.X:=Xpos; Stack[Sp].p.Y:=Ypos;
   SC:=1;
   while (SC>0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Left];
         po:=Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Right]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList,po.x,po.y);
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Right];
         po:=Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Left]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList,po.x,po.y);
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check right
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Up];
         po:=Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Down]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList,po.x,po.y);
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Down];
         po:=Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(SHP,po) then
         begin
            z2 := SHP.Data[Frame].FrameImage[po.X,po.Y];
            if z2=z1 then
            begin
               SHP.Data[Frame].FrameImage[po.X,po.Y] := Colour;
               if not Done[po.X,po.Y] then
               begin
                  Stack[SC].Dir:=Full-[Up]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList,po.x,po.y);
               end;
               Done[po.X,po.Y]:=True;
            end;
         end;
      end;
      if (Stack[Sp].Dir = []) then
      begin
         Dec(Sp);
         Dec(SC);
         //decrease stack pointer and stack count
      end;
   end;
   SetLength(Stack,0); // Free Up Memory
   SetLength(Done,0); // Free Up Memory

   // 3.36: Now, we go to the exclusive blurr part.
   // Step 1: Scan Final List to get the new colours.
   for i := Low(FinalList) to High(FinalList) do
   begin
      FinalList[i].Colour := GetBlurredColour(SHP,Palette,List,Last,FinalList[i].P,Frame,Alg);
   end;
   // Step 2: Now we paint the whole thing.
   for i := Low(FinalList) to High(FinalList) do
   begin
      if FinalList[i].Colour > -1 then
         SHP.Data[Frame].FrameImage[FinalList[i].P.X,FinalList[i].P.Y] := FinalList[i].Colour;
   end;
   SetLength(FinalList,0);
end;



//---------------------------------------------
// Draw Rectangle - Preview
//---------------------------------------------
procedure Rectangle(var tempView: TObjectData; var tempViewLength : integer; x1, y1, x2, y2 : Integer; doFill: Boolean);
var
  i, j: Integer;
  Inside, Exact: Integer;
begin
   tempViewLength := 0;
   SetLength(tempView, tempViewLength);


   for i:= Min(x1, x2) to Max(x1, x2) do 
   begin
      for j:=Min(y1, y2) to Max(y1, y2) do 
      begin
         Inside := 0; 
         Exact := 0;

         if (i > Min(x1, x2)) and (i < Max(x1, x2)) then Inc(Inside);
         if (j > Min(y1, y2)) and (j < Max(y1, y2)) then Inc(Inside);
         if (i = Min(x1, x2)) or (i = Max(x1, x2)) then Inc(Exact);
         if (j = Min(y1, y2)) or (j = Max(y1, y2)) then Inc(Exact);

         if doFill then 
         begin
            if Inside + Exact = 2 then 
            begin
               tempViewLength := tempViewLength + 1;
               SetLength(tempview, tempViewLength + 1);
               tempview[tempViewLength].X := i;
               tempview[tempViewLength].Y := j;
            end;
         end 
         else 
         begin
            if (Exact >= 1) and (Inside + Exact = 2) then 
            begin
              tempViewLength := tempViewLength +1;
              SetLength(tempview, tempViewLength +1);
              tempview[tempViewLength].X := i;
              tempview[tempViewLength].Y := j;
            end;
      end;
    end;
  end;
end;


//---------------------------------------------
// Draw Ellipse - Preview
//---------------------------------------------
procedure Elipse(var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos,Xpos2,Ypos2:Integer; Fill: Boolean);
var
  i,j,k,a,b,c,d,last:smallint;
begin

  tempview_no := 0;
  setlength(tempview,0);
  if abs(Xpos - Xpos2) >= abs(Ypos - Ypos2) then
  begin
     a := sqr(abs((Xpos - Xpos2) div 2));
     b := sqr(abs((Ypos - Ypos2) div 2));
     c := (Ypos + Ypos2) div 2;
     d := (Xpos + Xpos2) div 2;
     if (a >= 1) and not Fill then
     begin
        last := round(sqrt((b * (a - ((d - Min(Xpos,Xpos2)) * (d - Min(Xpos,Xpos2))))) div a));
        for i:=(d - Min(Xpos,Xpos2)) downto 0 do
        begin
           j := round(sqrt((b * (a - (i * i))) div a));
           if abs(j - last) > 1 then
           begin
              for k := abs(j - last) downto 0 do
              begin
                 tempview_no := tempview_no +1;
                 setlength(tempview,tempview_no +4);
                 tempview[tempview_no].X := d + i;
                 tempview[tempview_no].Y := c + j - k;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := d + i;
                 tempview[tempview_no].Y := c - j + k;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := d - i;
                 tempview[tempview_no].Y := c + j - k;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := d - i;
                 tempview[tempview_no].Y := c - j + k;
              end;
           end
           else
           begin
              tempview_no := tempview_no +1;
              setlength(tempview,tempview_no +4);
              tempview[tempview_no].X := d + i;
              tempview[tempview_no].Y := c + j;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := d + i;
              tempview[tempview_no].Y := c - j;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := d - i;
              tempview[tempview_no].Y := c + j;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := d - i;
              tempview[tempview_no].Y := c - j;
           end;
           last := j;
        end;
     end
     else if (a >= 1) and Fill then
     begin
        for i:= (d - Min(Xpos,Xpos2)) downto 0 do
        begin
           j := round(sqrt((b * (a - (i * i))) div a));
           for k := (c - j) to (c + j) do
           begin
              tempview_no := tempview_no +1;
              setlength(tempview,tempview_no +2);
              tempview[tempview_no].X := d + i;
              tempview[tempview_no].Y := k;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := d - i;
              tempview[tempview_no].Y := k;
           end;
        end;
     end
     else
     begin
        tempview_no := tempview_no +1;
        setlength(tempview,tempview_no +1);
        tempview[tempview_no].X := Xpos;
        tempview[tempview_no].Y := Ypos;
     end;
  end
  else
  begin
     a := sqr(abs((Ypos - Ypos2) div 2));
     b := sqr(abs((Xpos - Xpos2) div 2));
     c := (Xpos + Xpos2) div 2;
     d := (Ypos + Ypos2) div 2;
     if (a >= 1) and not Fill then
     begin
        last := round(sqrt((b * (a - ((d - Min(Ypos,Ypos2)) * (d - Min(Ypos,Ypos2))))) div a));
        for i:= (d - Min(Ypos,Ypos2)) downto 0 do
        begin
           j := round(sqrt((b * (a - (i * i))) div a));
           if abs(j - last) > 1 then
           begin
              for k := abs(j - last) downto 0 do
              begin
                 tempview_no := tempview_no +1;
                 setlength(tempview,tempview_no +4);
                 tempview[tempview_no].X := c + j - k;
                 tempview[tempview_no].Y := d + i;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := c - j + k;
                 tempview[tempview_no].Y := d + i;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := c + j - k;
                 tempview[tempview_no].Y := d - i;
                 tempview_no := tempview_no +1;
                 tempview[tempview_no].X := c - j + k;
                 tempview[tempview_no].Y := d - i;
              end;
           end
           else
           begin
              tempview_no := tempview_no +1;
              setlength(tempview,tempview_no +4);
              tempview[tempview_no].X := c + j;
              tempview[tempview_no].Y := d + i;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := c - j;
              tempview[tempview_no].Y := d + i;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := c + j;
              tempview[tempview_no].Y := d - i;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := c - j;
              tempview[tempview_no].Y := d - i;
           end;
           last := j;
        end;
     end
     else if (a >= 1) and Fill then
     begin
        for i:= (d - Min(Ypos,Ypos2)) downto 0 do
        begin
           j := round(sqrt((b * (a - (i * i))) div a));
           for k := (c - j) to (c + j) do
           begin
              tempview_no := tempview_no +1;
              setlength(tempview,tempview_no +2);
              tempview[tempview_no].X := k;
              tempview[tempview_no].Y := d + i;
              tempview_no := tempview_no +1;
              tempview[tempview_no].X := k;
              tempview[tempview_no].Y := d - i;
           end;
        end;
     end
     else
     begin
        tempview_no := tempview_no +1;
        setlength(tempview,tempview_no +1);
        tempview[tempview_no].X := Xpos;
        tempview[tempview_no].Y := Ypos;
     end;
  end;
end;


//---------------------------------------------
// Add Color - Preview
//---------------------------------------------
procedure AddColourToTempview(const SHP:TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);
begin
   if (YPos < SHP.Header.Height) and (YPos >= 0) then
      if (XPos < SHP.Header.Width) and (XPos >= 0) then
         if (SHP.Data[Frame].FrameImage[XPos,YPos] <> 0) then
         begin
            inc(tempview_no);
            SetLength(Tempview,Tempview_No + 1);
            Tempview[Tempview_no].X := XPos;
            TempView[Tempview_no].Y := YPos;
            TempView[Tempview_no].colour := Palette[LoadPixel(List,Last,alg,RGB(GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) - (bias * (GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) div division)),GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) - (bias *(GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) div division)),GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) - (bias * (GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) div division))))];
            TempView[tempview_no].colour_used := true;
         end;
end;


//---------------------------------------------
// Add Color - On frame
//---------------------------------------------
procedure AddColourToSHP(var SHP : TSHP; var Palette: TPalette; frameIndex, x, y, alg:Integer; var List, Last : listed_colour; bias, division:byte);
begin
   if (y < SHP.Header.Height) and (y >= 0) then
      if (x < SHP.Header.Width) and (x >= 0) then
         if (SHP.Data[frameIndex].FrameImage[x, y] <> 0) then
         begin
            SHP.Data[frameIndex].FrameImage[x, y] := 
               LoadPixel(List, Last, alg, 
                  RGB( 
                     GetRValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) - (bias * (GetRValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) div division)),
                     GetGValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) - (bias * (GetGValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) div division)),
                     GetBValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) - (bias * (GetBValue(Palette[SHP.Data[frameIndex].FrameImage[x, y]]) div division))
                     )
                  );
         end;
end;


//---------------------------------------------
// Add Snow Color - Preview
//---------------------------------------------
procedure AddSnowColourToTempview(const SHP:TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);
begin
   if (YPos < SHP.Header.Height) and (YPos >= 0) then
      if (XPos < SHP.Header.Width) and (XPos >= 0) then
         if (SHP.Data[Frame].FrameImage[XPos,YPos] <> 0) then
         begin
            inc(tempview_no);
            SetLength(Tempview,Tempview_No + 1);
            Tempview[Tempview_no].X := XPos;
            TempView[Tempview_no].Y := YPos;
            TempView[Tempview_no].colour := Palette[LoadPixel(List,Last,alg,RGB(GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias * ((255 - GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division)),GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias *((255 - GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division)),GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias * ((255 - GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division))))];
            TempView[tempview_no].colour_used := true;
         end;
end;


//---------------------------------------------
// Add Snow Color - On frame
//---------------------------------------------
procedure AddSnowColourToSHP(var SHP:TSHP; const Palette: TPalette; Frame,Xpos,Ypos,alg:Integer; var List,Last:listed_colour; bias,division:byte);
begin
   if (YPos < SHP.Header.Height) and (YPos >= 0) then
      if (XPos < SHP.Header.Width) and (XPos >= 0) then
         if (SHP.Data[Frame].FrameImage[XPos,YPos] <> 0) then
         begin
            SHP.Data[Frame].FrameImage[XPos,YPos] := LoadPixel(List,Last,alg,RGB(GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias * ((255 - GetRValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division)),GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias * ((255 - GetGValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division)),GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]]) + (bias * ((255 - GetBValue(Palette[SHP.Data[Frame].FrameImage[XPos,YPos]])) div division))));
         end;
end;


//---------------------------------------------
// Add Crash - Preview
//---------------------------------------------
procedure Crash(const SHP: TSHP; var Palette: TPalette; var tempView: TObjectData; var tempViewLength : integer; Xpos,Ypos:Integer; const frameIndex: integer; const Alg : integer); overload;
var
   List,Last: listed_colour;
   Start : colour_element;
begin
   tempViewLength := 0;
   SetLength(tempview, tempViewLength); // Clean

   // Set List and Last
   GenerateColourList(Palette, List, Last, Palette[0], true, true, true);
   // Prepare Bank
   PrepareBank(Start,List,Last);

   // Now, grab the colours -- First row (XPos-1)
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos-1, Ypos-1,alg,List,Last,1,3);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos-1, Ypos,alg,List,Last,2,3);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos-1, Ypos+1,alg,List,Last,1,3);

   // middle row (XPos)
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos, Ypos-1, alg, List, Last, 2,3);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos, Ypos, alg, List, Last, 3,4);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos, Ypos+1, alg, List, Last, 2,3);
 
   // final row (XPos + 1)
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos+1, Ypos-1, alg,List,Last,1,3);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos+1, Ypos, alg,List,Last,2,3);
   AddColourToTempview( SHP, Palette, tempView, tempViewLength, frameIndex, Xpos+1, Ypos+1, alg,List,Last,1,3);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Crash - On frame
//---------------------------------------------
procedure Crash(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  // Set List and Last
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-1)
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,3);

  // middle row (XPos)
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,3,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,2,3);

  // final row (XPos + 1)
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,3);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Crash Light - Preview
//---------------------------------------------
procedure CrashLight(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  tempview_no := 0;
  setlength(tempview,0); // Clean

  // Set List and Last
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);
  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,6);

  // middle row (XPos)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,1,4);

  // final row (XPos + 1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,6);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;

//---------------------------------------------
// Add Crash Light - On frame
//---------------------------------------------
procedure CrashLight(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-1)
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,6);

  // middle row (XPos)
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,1,4);

  // final row (XPos + 1)
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,6);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Crash Big - Preview
//---------------------------------------------
procedure CrashBig(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  tempview_no := 0;
  setlength(tempview,0); // Clean

  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);
  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-1,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+1,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+2,alg,List,Last,1,10);

  // Now, grab the colours -- Second row (XPos-2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-3,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-2,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-1,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+1,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+2,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+3,alg,List,Last,1,10);

  // Now, grab the colours -- Third row (XPos-1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-3,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-2,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,2,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+2,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+3,alg,List,Last,1,5);

  // middle row (XPos)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-3,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-2,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,2,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,3,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,2,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+2,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+3,alg,List,Last,1,3);

  // fifth row (XPos + 1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-3,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-2,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,2,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+2,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+3,alg,List,Last,1,5);

  // sixth row (XPos+2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-3,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-2,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-1,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos,alg,List,Last,1,2);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+1,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+2,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+3,alg,List,Last,1,10);

  // Bout Time -- Final row (XPos+3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-1,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+1,alg,List,Last,1,5);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+2,alg,List,Last,1,10);

  // Remove the trash:
  ClearColourList(List,Last);
  ClearBank(Start);
end;


//---------------------------------------------
// Add Crasg Big - On frame
//---------------------------------------------
procedure CrashBig(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-1,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+1,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+2,alg,List,Last,1,10);

  // Second row (XPos-2)
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-3,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-2,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+2,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+3,alg,List,Last,1,10);

  // Third row (XPos-1)
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-3,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-2,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+2,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+3,alg,List,Last,1,5);

  // middle row (XPos)
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-3,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-2,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,3,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+2,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+3,alg,List,Last,1,3);

  // Fifth row (XPos + 1)
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-3,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-2,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,2,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+2,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+3,alg,List,Last,1,5);

  // Sixth row (XPos + 2)
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-3,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-2,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos,alg,List,Last,1,2);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+1,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+2,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+3,alg,List,Last,1,10);

  // Final row (XPos + 3)
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-1,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+1,alg,List,Last,1,5);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+2,alg,List,Last,1,10);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Crash Big Light - Preview
//---------------------------------------------
procedure CrashBigLight(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  tempview_no := 0;
  setlength(tempview,0); // Clean

  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);
  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-2,alg,List,Last,1,20);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-1,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+1,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+2,alg,List,Last,1,20);

  // Now, grab the colours -- Second row (XPos-2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-3,alg,List,Last,1,20);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+3,alg,List,Last,1,20);

  // Now, grab the colours -- Third row (XPos-1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-3,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+3,alg,List,Last,1,10);

  // middle row (XPos)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,1,3);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

  // fifth row (XPos + 1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-3,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+3,alg,List,Last,1,10);

  // sixth row (XPos+2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-3,alg,List,Last,1,20);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+2,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+3,alg,List,Last,1,20);

  // Bout Time -- Final row (XPos+3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-2,alg,List,Last,1,20);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-1,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+1,alg,List,Last,1,10);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+2,alg,List,Last,1,20);

  // Remove the trash:
  ClearColourList(List,Last);
  ClearBank(Start);
end;


//---------------------------------------------
// Add Crash Big Light - On frame
//---------------------------------------------
procedure CrashBigLight(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-2,alg,List,Last,1,20);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-1,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+1,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+2,alg,List,Last,1,20);

  // Second row (XPos-2)
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-3,alg,List,Last,1,20);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-1,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+1,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+3,alg,List,Last,1,20);

  // Third row (XPos-1)
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-3,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-2,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+2,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+3,alg,List,Last,1,10);

  // middle row (XPos)
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,1,3);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

  // Fifth row (XPos + 1)
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-3,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-2,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+2,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+3,alg,List,Last,1,10);

  // Sixth row (XPos + 2)
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-3,alg,List,Last,1,20);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-1,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+1,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+2,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+3,alg,List,Last,1,20);

  // Final row (XPos + 3)
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-2,alg,List,Last,1,20);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-1,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+1,alg,List,Last,1,10);
  AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+2,alg,List,Last,1,20);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Dirt - Preview
//---------------------------------------------
procedure Dirty(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  tempview_no := 0;
  setlength(tempview,0); // Clean

  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);
  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+1,alg,List,Last,1,8);

  // Now, grab the colours -- Second row (XPos-2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+2,alg,List,Last,1,8);

  // Now, grab the colours -- Third row (XPos-1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-3,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+3,alg,List,Last,1,8);

  // middle row (XPos)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

  // fifth row (XPos + 1)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-3,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,4);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+2,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+3,alg,List,Last,1,8);

  // sixth row (XPos+2)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-2,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+1,alg,List,Last,1,6);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+2,alg,List,Last,1,8);

  // Bout Time -- Final row (XPos+3)
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-1,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
  AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+1,alg,List,Last,1,8);

  // Remove the trash:
  ClearColourList(List,Last);
  ClearBank(Start);
end;


//---------------------------------------------
// Add Dirt - On frame
//---------------------------------------------
procedure Dirty(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
   List,Last: listed_colour;
   Start : colour_element;
begin
   // Set List and Last
   InitializeColourList(List,Last);
   GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

   // Prepare Bank
   PrepareBank(Start,List,Last);

   // Now, grab the colours -- First row (XPos-3)
   AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-1,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+1,alg,List,Last,1,8);

   // Second row (XPos-2)
   AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-2,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-1,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+1,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+2,alg,List,Last,1,8);

   // Third row (XPos-1)
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-3,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+3,alg,List,Last,1,8);

   // middle row (XPos)
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

   // Fifth row (XPos + 1)
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-3,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,4);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+2,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+3,alg,List,Last,1,8);

   // Sixth row (XPos + 2)
   AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-2,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-1,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+1,alg,List,Last,1,6);
   AddColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+2,alg,List,Last,1,8);

   // Final row (XPos + 3)
   AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-1,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
   AddColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+1,alg,List,Last,1,8);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Snow - Preview
//---------------------------------------------
procedure Snow(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
   tempview_no := 0;
   setlength(tempview,0); // Clean

   // Set List and Last
   InitializeColourList(List,Last);
   GenerateColourList(Palette,List,Last,Palette[0],true,true,true);
   // Prepare Bank
   PrepareBank(Start,List,Last);

   // Now, grab the colours -- First row (XPos-3)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos-1,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-3,Ypos+1,alg,List,Last,1,8);

   // Now, grab the colours -- Second row (XPos-2)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-2,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos-1,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+1,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-2,Ypos+2,alg,List,Last,1,8);

   // Now, grab the colours -- Third row (XPos-1)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-3,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+3,alg,List,Last,1,8);

   // middle row (XPos)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

   // fifth row (XPos + 1)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-3,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,4);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+2,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+3,alg,List,Last,1,8);

   // sixth row (XPos+2)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-2,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos-1,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+1,alg,List,Last,1,6);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+2,Ypos+2,alg,List,Last,1,8);

   // Bout Time -- Final row (XPos+3)
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos-1,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
   AddSnowColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+3,Ypos+1,alg,List,Last,1,8);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Add Snow - On frame
//---------------------------------------------
procedure Snow(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
var
  List,Last: listed_colour;
  Start : colour_element;
begin
  // Set List and Last
  InitializeColourList(List,Last);
  GenerateColourList(Palette,List,Last,Palette[0],true,true,true);

  // Prepare Bank
  PrepareBank(Start,List,Last);

  // Now, grab the colours -- First row (XPos-3)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos-1,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-3,Ypos+1,alg,List,Last,1,8);

  // Second row (XPos-2)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-2,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos-1,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+1,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-2,Ypos+2,alg,List,Last,1,8);

  // Third row (XPos-1)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-3,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos-1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos-1,Ypos+3,alg,List,Last,1,8);

  // middle row (XPos)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos-3,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos-2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos-1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos+1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos+2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos,Ypos+3,alg,List,Last,1,8);

  // Fifth row (XPos + 1)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-3,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos-1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+1,alg,List,Last,1,3);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+2,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+1,Ypos+3,alg,List,Last,1,8);

  // Sixth row (XPos + 2)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-2,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos-1,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+1,alg,List,Last,1,6);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+2,Ypos+2,alg,List,Last,1,8);

  // Final row (XPos + 3)
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos-1,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos,alg,List,Last,1,8);
  AddSnowColourToSHP(SHP,Palette,Frame,Xpos+3,Ypos+1,alg,List,Last,1,8);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);
end;


//---------------------------------------------
// Get Opposite Color
//---------------------------------------------
function OpositeColour(color : TColor) : tcolor;
var
   r,g,b : byte;
begin
   r := 255 - GetRValue(color);
   g := 255 - GetGValue(color);
   b := 255 - GetBValue(color);
   Result := RGB(r,g,b);
end;


//---------------------------------------------
// Draw brush - Preview
//---------------------------------------------
procedure BrushTool(var SHP: TSHP; var TempView: TObjectData; var tempViewLength: integer; Xc, Yc, BrushMode, Colour: TColor);
var
  Shape: Array[-5..5,-5..5] of 0..1;
  i,j,r1,r2: Integer;
begin
   Randomize;

   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;

   Shape[0, 0] := 1;

   // Initialize Brush
   if BrushMode >= 1 then 
   begin
      Shape[0,1] := 1; Shape[0,-1] := 1; Shape[1,0] := 1; Shape[-1,0] := 1;
   end;

   if BrushMode >= 2 then begin
      Shape[1,1] := 1; Shape[1,-1] := 1; Shape[-1,-1] := 1; Shape[-1,1] := 1;
   end;

   if BrushMode >= 3 then begin
      Shape[0,2] := 1; Shape[0,-2] := 1; Shape[2,0] := 1; Shape[-2,0] := 1;
   end;

   if BrushMode = 4 then begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i,j] := 0;

      for i := 1 to 4 do begin
         r1 := random(7) - 3; 
         r2 := random(7) - 3;
         Shape[r1,r2] := 1;
      end;
   end;

   for i := -5 to 5 do begin
      for j := -5 to 5 do begin
         if Shape[i, j] = 1 then begin

            inc(tempViewLength);
            SetLength(TempView, tempViewLength);

            TempView[tempViewLength - 1].Colour := Colour;
            TempView[tempViewLength - 1].X := Max(Min(Xc + i, SHP.Header.Width - 1),0);
            TempView[tempViewLength - 1].Y := Max(Min(Yc + j, SHP.Header.Height - 1),0);
      end;
    end;
  end;
end;


//---------------------------------------------
// Is coordinate in image
//---------------------------------------------
function InImageBounds(x, y : integer; const SHP:TSHP) : boolean;
begin
   result := false; 

   if (x >= 0) and (y >= 0) and (x < SHP.Header.Width) and (y < SHP.Header.Height) then
      result := true;
end;


//---------------------------------------------
// Draw Dotted Border (rectangle) - Preview 
//---------------------------------------------
procedure Rectangle_dotted(const SHP: TSHP; var TempView: TObjectData; var TempView_no:integer; const SHPPalette:TPalette; Frame: Word; Xpos,Ypos,Xpos2,Ypos2:Integer);
var
   x,y,c: Integer;
begin
   tempview_no := 0;
   setlength(tempview,0);
   c := 0;

   // write top line
   for x := Max(Min(Xpos,Xpos2),0) to Min(SHP.Header.Width-1,Max(Xpos,Xpos2)) do
   begin
      inc(c);
      if (c <4) and (InImageBounds(x,Min(Ypos,Ypos2),SHP)) then
      begin
         tempview_no := tempview_no +1;
         setlength(tempview,tempview_no +1);
         tempview[tempview_no].X := x;
         tempview[tempview_no].Y := Min(Ypos,Ypos2);
         tempview[tempview_no].colour_used := true;
         tempview[tempview_no].colour := OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[x,Min(Ypos,Ypos2)]]);
      end
      else
         c := 0;
   end;

   c := 0;
   // write bottom line
   for x := Max(Min(Xpos,Xpos2),0) to Min(SHP.Header.Width-1,Max(Xpos,Xpos2)) do
   begin
      inc(c);
      if (c <4) and (InImageBounds(x,Max(Ypos,Ypos2),SHP)) then
      begin
         tempview_no := tempview_no +1;
         setlength(tempview,tempview_no +1);
         tempview[tempview_no].X := x;
         tempview[tempview_no].Y := Max(Ypos,Ypos2);
         tempview[tempview_no].colour_used := true;
         tempview[tempview_no].colour := OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[x,Max(Ypos,Ypos2)]]);
      end
      else
         c := 0;
   end;

   c := 0;
   // write left line
   for y := Max(Min(Ypos,Ypos2),0) to Min(SHP.Header.Height-1,Max(Ypos,Ypos2)) do
   begin
      inc(c);
      if (c <4) and (InImageBounds(Min(Xpos,Xpos2),y,SHP)) then
      begin
         tempview_no := tempview_no +1;
         setlength(tempview,tempview_no +1);
         tempview[tempview_no].X := Min(Xpos,Xpos2);
         tempview[tempview_no].Y := y;
         tempview[tempview_no].colour_used := true;
         tempview[tempview_no].colour := OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[Min(Xpos,Xpos2),y]]);
      end
      else
         c := 0;
   end;

   c := 0;
   // write right line
   for y := Max(Min(Ypos,Ypos2),0) to Min(SHP.Header.Height-1,Max(Ypos,Ypos2)) do
   begin
      inc(c);
      if (c < 4) and (InImageBounds(Max(Xpos,Xpos2),y,SHP)) then
      begin
         tempview_no := tempview_no +1;
         setlength(tempview,tempview_no +1);
         tempview[tempview_no].X := Max(Xpos,Xpos2);
         tempview[tempview_no].Y := y;
         tempview[tempview_no].colour_used := true;
         tempview[tempview_no].colour := OpositeColour(SHPPalette[SHP.Data[Frame].FrameImage[Max(Xpos,Xpos2),y]]);
      end
      else
         c := 0;
   end;
end;


//---------------------------------------------
// DarkenLight Env ???
//---------------------------------------------
function darkenlightenv(Darken:boolean; Current_Value,Value : byte) : byte;
var 
   temp : word;
begin
   if darken then
      temp := Current_Value - Value
   else
      temp := Current_Value + Value;

   if temp < 1 then
      temp := temp + 255;

   if temp > 255 then
      temp := temp - 255;

   Result := temp;
end;


//---------------------------------------------
// Darken/Lighten - Preview
//---------------------------------------------
procedure BrushToolDarkenLighten(var SHP:TSHP; var TempView: TObjectData; var TempView_no: integer; Frame: Word; Xc,Yc: Integer; BrushMode: Integer); overload;
var
   Shape: Array[-5..5,-5..5] of 0..1;
   i,j,r1,r2: Integer;
   t : byte;
begin
   Randomize;
   for i:=-5 to 5 do
      for j:=-5 to 5 do
         Shape[i,j]:=0;
   Shape[0,0]:=1;
   if BrushMode>=1 then
   begin
      Shape[0,1]:=1; Shape[0,-1]:=1; Shape[1,0]:=1; Shape[-1,0]:=1;
   end;
   if BrushMode>=2 then
   begin
      Shape[1,1]:=1; Shape[1,-1]:=1; Shape[-1,-1]:=1; Shape[-1,1]:=1;
   end;
   if BrushMode>=3 then
   begin
      Shape[0,2]:=1; Shape[0,-2]:=1; Shape[2,0]:=1; Shape[-2,0]:=1;
   end;

   if BrushMode =4 then
   begin
      for i:=-5 to 5 do
         for j:=-5 to 5 do
            Shape[i,j]:=0;

      for i:=1 to 4 do
      begin
         r1 := random(7)-3; r2 := random(7)-3;
         Shape[r1,r2]:=1;
      end;
   end;
    //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i:=-5 to 5 do
   begin
      for j:=-5 to 5 do
      begin
         if Shape[i,j]=1 then
         begin
            inc(TempView_no);
            SetLength(TempView,TempView_no+1);
            TempView[TempView_no].X := Max(Min(Xc+i,SHP.Header.Width-1),0);
            TempView[TempView_no].Y := Max(Min(Yc+j,SHP.Header.Height-1),0);
            t := SHP.Data[Frame].FrameImage[Max(Min(Xc+i,SHP.Header.Width-1),0),Max(Min(Yc+j,SHP.Header.Height-1),0)];
            TempView[TempView_no].colour := t;
            TempView[tempview_no].colour_used := true;
            SHP.Data[Frame].FrameImage[Max(Min(Xc+i,SHP.Header.Width-1),0),Max(Min(Yc+j,SHP.Header.Height-1),0)] := darkenlightenv(FrmMain.DarkenLighten_B,t,FrmMain.DarkenLighten_N);
         end;
      end;
   end;
end;


//---------------------------------------------
// Darken/Lighten - On frame
//---------------------------------------------
procedure BrushToolDarkenLighten(var SHP:TSHP; Frame: Word; Xc,Yc: Integer; BrushMode: Integer); overload;
var
  Shape: Array[-5..5,-5..5] of 0..1;
  i,j,r1,r2: Integer;
  t : byte;
begin
   Randomize;
   for i:=-5 to 5 do
      for j:=-5 to 5 do
         Shape[i,j]:=0;
   Shape[0,0]:=1;
   if BrushMode>=1 then
   begin
      Shape[0,1]:=1; Shape[0,-1]:=1; Shape[1,0]:=1; Shape[-1,0]:=1;
   end;
   if BrushMode>=2 then
   begin
      Shape[1,1]:=1; Shape[1,-1]:=1; Shape[-1,-1]:=1; Shape[-1,1]:=1;
   end;
   if BrushMode>=3 then
   begin
      Shape[0,2]:=1; Shape[0,-2]:=1; Shape[2,0]:=1; Shape[-2,0]:=1;
   end;

   if BrushMode =4 then
   begin
      for i:=-5 to 5 do
         for j:=-5 to 5 do
            Shape[i,j]:=0;

      for i:=1 to 4 do
      begin
         r1 := random(7)-3; r2 := random(7)-3;
         Shape[r1,r2]:=1;
      end;
   end;
    //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i:=-5 to 5 do
   begin
      for j:=-5 to 5 do
      begin
         if Shape[i,j]=1 then
         begin
            t := SHP.Data[Frame].FrameImage[Max(Min(Xc+i,SHP.Header.Width-1),0),Max(Min(Yc+j,SHP.Header.Height-1),0)];
            SHP.Data[Frame].FrameImage[Max(Min(Xc+i,SHP.Header.Width-1),0),Max(Min(Yc+j,SHP.Header.Height-1),0)] := darkenlightenv(FrmMain.DarkenLighten_B,t,FrmMain.DarkenLighten_N);
         end;
      end;
   end;
end;


end.
