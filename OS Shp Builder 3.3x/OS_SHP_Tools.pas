unit OS_SHP_Tools;

interface
uses Windows, Graphics, SHP_Image, SHP_File, math, Palette, Colour_list, SHP_Colour_Bank,
     SHP_Engine_CCMs;


type
   FloodSet = (Left,Right,Up,Down);
   StackType = record
      Dir: set of FloodSet;
      p: TPoint2D;
   end;

// Functions

// Line
function GetGradient(_Last,_First : TPoint2D) : single;
procedure DrawLine(var _Tempview : TObjectData; var _TempView_no : integer; var _Last,_First : TPoint2D);

// Flood And Fill
procedure FloodFillTool(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; _Colour : byte);
procedure FloodFillGradientTool(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; const _Palette : TPalette; _Colour : byte);
procedure FloodFillWithBlur(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; var _Palette : TPalette; _Colour,_Alg : byte);

// Rectangle
procedure Rectangle(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos,_Xpos2,_Ypos2:Integer; _Fill: Boolean);
procedure Rectangle_dotted(const _SHP: TSHP; var _TempView: TObjectData; var _TempView_no:integer; const _SHPPalette:TPalette; _Frame: Word; _Xpos, _Ypos, _Xpos2, _Ypos2:Integer);

// Elipse
procedure Elipse(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos,_Xpos2,_Ypos2:Integer; _Fill: Boolean);

// Brush
procedure BrushTool(var _SHP: TSHP; var _TempView: TObjectData; var _TempView_no: integer; _Xc,_Yc,_BrushMode,_Colour: Integer);

// DarkenLighten
procedure BrushToolDarkenLighten(var _SHP:TSHP; _Frame: Word; _Xc, _Yc: Integer; _BrushMode: Integer); overload;
procedure BrushToolDarkenLighten(var _SHP:TSHP; var _TempView: TObjectData; var _TempView_no: integer; _Frame: Word; _Xc, _Yc: Integer; _BrushMode: Integer); overload;

// Damager
procedure Crash(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
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
procedure Snow(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
procedure Snow(var SHP: TSHP; var Palette: TPalette; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;

// Etc...
procedure Add2DPointToTempview(const _SHP:TSHP; var _TempView: TObjectData; var _TempView_no : integer; _Frame,_XPos,_YPos:Integer);
procedure Add2DPointToTempviewUnsafe(var _TempView: TObjectData; var _TempView_No : integer; _XPos,_YPos:Integer);
procedure AddTwo2DPointsToTempviewUnsafe(var _TempView: TObjectData; var _TempView_No : integer; _XPos1,_YPos1,_XPos2,_YPos2:Integer);
procedure AddFour2DPointsToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _XPos1,_YPos1,_XPos2,_YPos2,_XPos3,_YPos3,_XPos4,_YPos4:Integer);
procedure AddAnyColourToTempview(const _SHP:TSHP; var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos: Integer; _Colour: TColor);
procedure AddAnyColourToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos: Integer; _Colour: TColor);
procedure AddColourToTempView(const _SHP:TSHP; var _Palette: TPalette; var _Tempview: TObjectData; var _TempView_no : integer; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
procedure AddColourToSHP(var _SHP:TSHP; var _Palette: TPalette; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
procedure AddSnowColourToTempview(const _SHP:TSHP; var _Palette: TPalette; var _TempView: TObjectData; var _TempView_no : integer; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
procedure AddSnowColourToSHP(var _SHP:TSHP; const _Palette: TPalette; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
function OpositeColour(_Color : TColor) : tcolor;
function DarkenLightenV(_Darken:boolean; _Current_Value, _Value : byte) : byte;
function PointOK(const _SHP:TSHP; const _L: TPoint2D): Boolean; overload;
function PointOK(const _SHP:TSHP; _X, _Y: integer): Boolean; overload;


implementation

uses FormMain;

//---------------------------------------------
// Auxiliary Functions
//---------------------------------------------
function GetGradient(_Last,_First : TPoint2D) : single;
begin
   if (_First.X = _Last.X) or (_First.Y = _Last.Y) then
      result := 0
   else
      result := (_First.Y - _Last.Y) / (_First.X - _Last.X);
end;

function PointOK(const _SHP:TSHP; const _L: TPoint2D): Boolean;
begin
   Result := False;
   if (_L.X < 0) or (_L.Y < 0) then Exit;
   if (_L.X >= _SHP.Header.Width) or (_L.Y >= _SHP.Header.Height) then Exit;
   Result := True;
end;

function PointOK(const _SHP:TSHP; _X, _Y: integer): Boolean;
begin
   Result := False;
   if (_X < 0) or (_Y < 0) then Exit;
   if (_X >= _SHP.Header.Width) or (_Y >= _SHP.Header.Height) then Exit;
   Result := True;
end;



//---------------------------------------------
// Draw Straight Line - on Preview
//---------------------------------------------
procedure DrawLine(var _Tempview : TObjectData; var _TempView_no : integer; var _Last,_First : TPoint2D);
var
   x,y : integer;
   gradient,c : single;
begin
   // Straight Line Equation : Y=MX+C
   gradient := getgradient(_Last,_First);
   c := _Last.Y-(_Last.X * gradient);
   _TempView_no := 0;
   SetLength(_Tempview,0);

   if (gradient=0) and (_First.X = _Last.X) then
      for y := min(_First.Y,_Last.y) to max(_First.Y,_Last.y) do
      begin
         Add2DPointToTempViewUnsafe(_TempView, _TempView_No, _First.X, Y);
      end
      else if (gradient=0) and (_First.Y = _Last.Y) then
         for x := min(_First.x,_Last.x) to max(_First.x,_Last.x) do
         begin
            Add2DPointToTempViewUnsafe(_TempView, _TempView_No, X, _First.Y);
         end
      else
      begin
         for x := min(_First.X,_Last.X) to max(_First.X,_Last.X) do
         begin
            Add2DPointToTempViewUnsafe(_TempView, _TempView_No, X, Round((gradient * x) + c));
         end;
         for y := min(_First.Y,_Last.Y) to max(_First.Y,_Last.Y) do
         begin
            Add2DPointToTempViewUnsafe(_TempView, _TempView_No, Round((y - c) / gradient), Y);
         end;
      end;
end;

//---------------------------------------------
// Do Flood Fill - On frame
//---------------------------------------------
// Note: Flood Fill Code Taken From Voxel Section Editor and adapted to this program
procedure FloodFillTool(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; _Colour : byte);
var
   z1,z2: byte;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: TPoint2D;
   Full: set of FloodSet;
   Done: Array of Array of Boolean;
begin
   SetLength(Done,_SHP.Header.Width, _SHP.Header.Height);
   SetLength(Stack,_SHP.Header.Width * _SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i := 0 to _SHP.Header.Width - 1 do
      for j := 0 to _SHP.Header.Height - 1 do
         Done[i, j] := False;

   z1 := _SHP.Data[_Frame].FrameImage[_Xpos, _Ypos];
   _SHP.Data[_Frame].FrameImage[_Xpos, _Ypos] := _Colour;


   Full := [Left, Right, Up, Down];
   Sp:=0;
   Stack[Sp].Dir := Full;
   Stack[Sp].p.X := _Xpos;
   Stack[Sp].p.Y := _Ypos;
   SC:=1;
   while (SC > 0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Left];
         po := Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Right]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Right];
         po := Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Left]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check right
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Up];
         po := Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Down]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y]:=True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Down];
         po := Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Up]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
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
   SetLength(Stack, 0); // Free Up Memory
   SetLength(Done, 0); // Free Up Memory
end;


//---------------------------------------------
// Do Flood Fill with Gradient - On frame
//---------------------------------------------
procedure FloodFillGradientTool(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; const _Palette : TPalette; _Colour : byte);
var
   z1,z2: byte;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: TPoint2D;
   Full: set of FloodSet;
   Done: Array of Array of Boolean;
   Cache : TCache;
begin
   // 3.36: Build gradient cache
   Cache := BuildCacheReplacementForGradients(_Palette, _SHP.Data[_Frame].FrameImage[_XPos,_YPos], _Colour);
   // end of gradient cache code.
   SetLength(Done, _SHP.Header.Width, _SHP.Header.Height);
   SetLength(Stack, _SHP.Header.Width * _SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i := 0 to _SHP.Header.Width - 1 do
      for j := 0 to _SHP.Header.Height - 1 do
         Done[i, j] := False;

   z1 := _SHP.Data[_Frame].FrameImage[_Xpos,_Ypos];
   _SHP.Data[_Frame].FrameImage[_Xpos,_Ypos] := _Colour;

   Full := [Left, Right, Up, Down];
   Sp := 0;
   Stack[Sp].Dir := Full;
   Stack[Sp].p.X := _Xpos;
   Stack[Sp].p.Y := _Ypos;
   SC := 1;
   while (SC > 0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Left];
         po := Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 <> Cache[z2] then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := Cache[z2];
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Right]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Right];
         po := Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 <> Cache[z2] then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := Cache[z2];
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Left]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
        end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Up];
         po := Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 <> Cache[z2] then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := Cache[z2];
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Down]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Down];
         po := Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 <> Cache[z2] then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := Cache[z2];
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full-[Up]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X, po.Y] := True;
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
   SetLength(Stack, 0); // Free Up Memory
   SetLength(Done, 0); // Free Up Memory
end;

//---------------------------------------------
// Do Flood Fill with Blur - On frame
//---------------------------------------------
procedure FloodFillWithBlur(var _SHP: TSHP; _Frame,_Xpos,_Ypos: Integer; var _Palette : TPalette; _Colour,_Alg : byte);
type
   TFinalListElement = record
      P : TPoint2D;
      Colour : integer;
   end;
   TFinalList = array of TFinalListElement;
   procedure AddToFinalList(var _FinalList : TFinalList; _x, _y :integer);
   begin
      SetLength(_FinalList,High(_FinalList)+2);
      _FinalList[High(_FinalList)].P.X := _x;
      _FinalList[High(_FinalList)].P.Y := _y;
   end;

   function GetBlurredColour(const _SHP: TSHP; const _Palette : TPalette; var _List,_Last: listed_colour; const _Point : TPoint2D; _Frame,_Alg : integer): integer;
   var
      count,x,y : integer;
      CurrentPoint : TPoint2D;
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
            if PointOK(_SHP, CurrentPoint) then
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
   po: TPoint2D;
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
   GenerateColourList(_Palette,List,Last,_Palette[0],true,false,false,false);
   // Prepare Bank
   PrepareBank(Start,List,Last);

   // Old code resumes here...
   SetLength(Done, _SHP.Header.Width, _SHP.Header.Height);
   SetLength(Stack, _SHP.Header.Width * _SHP.Header.Height);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i := 0 to _SHP.Header.Width - 1 do
      for j := 0 to _SHP.Header.Height - 1 do
         Done[i, j] := False;

   z1 := _SHP.Data[_Frame].FrameImage[_Xpos, _Ypos];
   _SHP.Data[_Frame].FrameImage[_Xpos, _Ypos] := _Colour;

   Full := [Left, Right, Up, Down];
   Sp := 0;
   Stack[Sp].Dir := Full;
   Stack[Sp].p.X := _Xpos;
   Stack[Sp].p.Y := _Ypos;
   SC := 1;
   while (SC > 0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Left];
         po := Stack[Sp].p;
         Dec(po.X);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Right]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList, po.x, po.y);
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Right];
         po := Stack[Sp].p;
         Inc(po.X);
         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Left]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList, po.x, po.y);
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check right
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Up];
         po := Stack[Sp].p;
         Dec(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Down]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList, po.x, po.y);
               end;
               Done[po.X, po.Y] := True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir := Stack[Sp].Dir - [Down];
         po := Stack[Sp].p;
         Inc(po.Y);

         //now check this point - only if it's within range, check it.
         if PointOK(_SHP, po) then
         begin
            z2 := _SHP.Data[_Frame].FrameImage[po.X, po.Y];
            if z2 = z1 then
            begin
               _SHP.Data[_Frame].FrameImage[po.X, po.Y] := _Colour;
               if not Done[po.X, po.Y] then
               begin
                  Stack[SC].Dir := Full - [Up]; //Don't go back
                  Stack[SC].p := po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
                  AddToFinalList(FinalList, po.x, po.y);
               end;
               Done[po.X, po.Y] := True;
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
   SetLength(Stack, 0); // Free Up Memory
   SetLength(Done, 0); // Free Up Memory

   // 3.36: Now, we go to the exclusive blurr part.
   // Step 1: Scan Final List to get the new colours.
   for i := Low(FinalList) to High(FinalList) do
   begin
      FinalList[i].Colour := GetBlurredColour(_SHP, _Palette, List, Last, FinalList[i].P, _Frame, _Alg);
   end;
   // Step 2: Now we paint the whole thing.
   for i := Low(FinalList) to High(FinalList) do
   begin
      if FinalList[i].Colour > -1 then
         _SHP.Data[_Frame].FrameImage[FinalList[i].P.X, FinalList[i].P.Y] := FinalList[i].Colour;
   end;
   SetLength(FinalList, 0);
end;

//---------------------------------------------
// Draw Rectangle - Preview
//---------------------------------------------
procedure Rectangle(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos,_Xpos2,_Ypos2:Integer; _Fill: Boolean);
var
   i, j: Integer;
   Inside, Exact: Integer;
begin
   _Tempview_no := 0;
   SetLength(_Tempview, 0);

   for i := Min(_Xpos, _Xpos2) to Max(_Xpos, _Xpos2) do
   begin
      for j := Min(_Ypos, _Ypos2) to Max(_Ypos, _Ypos2) do
      begin
         Inside := 0;
         Exact := 0;

         if (i > Min(_Xpos, _Xpos2)) and (i < Max(_Xpos, _Xpos2)) then
            Inc(Inside);
         if (j > Min(_Ypos, _Ypos2)) and (j < Max(_Ypos, _Ypos2)) then
            Inc(Inside);
         if (i = Min(_Xpos, _Xpos2)) or (i = Max(_Xpos, _Xpos2)) then
            Inc(Exact);
         if (j = Min(_Ypos, _Ypos2)) or (j = Max(_Ypos, _Ypos2)) then
            Inc(Exact);

         if _Fill then
         begin
            if (Inside + Exact) = 2 then
            begin
               Add2DPointToTempViewUnsafe(_TempView, _TempView_No, i, j);
            end;
         end
         else
         begin
            if (Exact >= 1) and (Inside + Exact = 2) then
            begin
               Add2DPointToTempViewUnsafe(_TempView, _TempView_No, i, j);
            end;
         end;
      end;
   end;
end;

//---------------------------------------------
// Draw Ellipse - Preview
//---------------------------------------------
procedure Elipse(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos,_Xpos2,_Ypos2:Integer; _Fill: Boolean);
var
   i, j, k, a, b, c, d, Last:smallint;
begin
   _Tempview_no := 0;
   SetLength(_Tempview, 0);
   if abs(_Xpos - _Xpos2) >= abs(_Ypos - _Ypos2) then
   begin
      a := Sqr(abs((_Xpos - _Xpos2) div 2));
      b := Sqr(abs((_Ypos - _Ypos2) div 2));
      c := (_Ypos + _Ypos2) div 2;
      d := (_Xpos + _Xpos2) div 2;
      if (a >= 1) and not _Fill then
      begin
         Last := Round(Sqrt((b * (a - ((d - Min(_Xpos, _Xpos2)) * (d - Min(_Xpos, _Xpos2))))) div a));
         for i := (d - Min(_Xpos, _Xpos2)) downto 0 do
         begin
            j := Round(Sqrt((b * (a - (i * i))) div a));
            if abs(j - Last) > 1 then
            begin
               for k := abs(j - Last) downto 0 do
               begin
                  AddFour2DPointsToTempViewUnsafe(_TempView, _TempView_No, d + i, c + j - k, d + i, c - j + k, d - i, c + j - k, d - i, c - j + k);
               end;
            end
            else
            begin
               AddFour2DPointsToTempViewUnsafe(_TempView, _TempView_No, d + i, c + j, d + i, c - j, d - i, c + j, d - i, c - j);
            end;
            last := j;
         end;
      end
      else if (a >= 1) and _Fill then
      begin
         for i := (d - Min(_Xpos, _Xpos2)) downto 0 do
         begin
            j := Round(Sqrt((b * (a - (i * i))) div a));
            for k := (c - j) to (c + j) do
            begin
               AddTwo2DPointsToTempViewUnsafe(_TempView, _TempView_No, d + i, k, d - i, k);
            end;
         end;
      end
      else
      begin
         Add2DPointToTempViewUnsafe(_TempView, _TempView_No, _XPos, _YPos);
      end;
   end
   else
   begin
      a := Sqr(abs((_Ypos - _Ypos2) div 2));
      b := Sqr(abs((_Xpos - _Xpos2) div 2));
      c := (_Xpos + _Xpos2) div 2;
      d := (_Ypos + _Ypos2) div 2;
      if (a >= 1) and not _Fill then
      begin
         Last := Round(Sqrt((b * (a - ((d - Min(_Ypos, _Ypos2)) * (d - Min(_Ypos, _Ypos2))))) div a));
         for i := (d - Min(_Ypos, _Ypos2)) downto 0 do
         begin
            j := Round(Sqrt((b * (a - (i * i))) div a));
            if abs(j - Last) > 1 then
            begin
               for k := abs(j - Last) downto 0 do
               begin
                  AddFour2DPointsToTempViewUnsafe(_TempView, _TempView_No, c + j - k, d + i, c - j + k, d + i, c + j - k, d - i, c - j + k, d - i);
               end;
            end
            else
            begin
               AddFour2DPointsToTempViewUnsafe(_TempView, _TempView_No, c + j, d + i, c - j, d + i, c + j, d - i, c - j, d - i);
            end;
            Last := j;
         end;
      end
      else if (a >= 1) and _Fill then
      begin
         for i := (d - Min(_Ypos, _Ypos2)) downto 0 do
         begin
            j := Round(Sqrt((b * (a - (i * i))) div a));
            for k := (c - j) to (c + j) do
            begin
               AddTwo2DPointsToTempViewUnsafe(_TempView, _TempView_No, k, d + i, k, d - i);
            end;
         end;
      end
      else
      begin
         Add2DPointToTempViewUnsafe(_TempView, _TempView_No, _XPos, _YPos);
      end;
   end;
end;

//---------------------------------------------
// Add Crash - Preview
//---------------------------------------------
procedure Crash(const SHP: TSHP; var Palette: TPalette; var Tempview: TObjectData; var TempView_no : integer; Xpos,Ypos:Integer; const Frame: integer; const Alg : integer); overload;
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
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos-1,alg,List,Last,1,3);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos,alg,List,Last,2,3);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos-1,Ypos+1,alg,List,Last,1,3);

   // middle row (XPos)
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos-1,alg,List,Last,2,3);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos,alg,List,Last,3,4);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos,Ypos+1,alg,List,Last,2,3);

   // final row (XPos + 1)
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos-1,alg,List,Last,1,3);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos,alg,List,Last,2,3);
   AddColourToTempview(SHP,Palette,Tempview,TempView_no,Frame,Xpos+1,Ypos+1,alg,List,Last,1,3);

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
//  l : text;  // Debug system (I had several problems to implement this tool)
begin
//  AssignFile(l,'e:\test.txt');
//  Rewrite(l);
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
// Add Crash Big - On frame
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
// Add Dirty - Preview
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
// Add Dirty - On frame
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
// Draw Brush - Preview
//---------------------------------------------
// Note: BrushToolDarkenLighten Code Taken From Voxel Section Editor and adapted to this program
procedure BrushTool(var _SHP: TSHP; var _TempView: TObjectData; var _TempView_no: integer; _Xc,_Yc,_BrushMode,_Colour: Integer);
var
   Shape: Array[-5..5,-5..5] of 0..1;
   i,j,r1,r2: Integer;
begin
   Randomize;
   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;

   Shape[0, 0] := 1;
   if _BrushMode >= 1 then
   begin
      Shape[0, 1] := 1;
      Shape[0, -1] := 1;
      Shape[1, 0] := 1;
      Shape[-1, 0] := 1;
   end;
   if _BrushMode >= 2 then
   begin
      Shape[1, 1] := 1;
      Shape[1, -1] := 1;
      Shape[-1, -1] := 1;
      Shape[-1, 1] := 1;
   end;
   if _BrushMode >= 3 then
   begin
      Shape[0, 2] := 1;
      Shape[0, -2] := 1;
      Shape[2, 0] := 1;
      Shape[-2, 0] := 1;
   end;

   if _BrushMode =4 then
   begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i, j] := 0;

      for i := 1 to 4 do
      begin
         r1 := random(7) - 3;
         r2 := random(7) - 3;
         Shape[r1, r2] := 1;
      end;
   end;
   //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i := -5 to 5 do
   begin
      for j := -5 to 5 do
      begin
         if Shape[i, j] = 1 then
         begin
            Add2DPointToTempViewUnsafe(_TempView, _TempView_No, Max(Min(_Xc + i, _SHP.Header.Width - 1), 0), Max(Min(_Yc + j, _SHP.Header.Height - 1), 0));
         end;
      end;
   end;
end;

//---------------------------------------------
// Draw Rectangle Dotted - Preview
//---------------------------------------------
procedure Rectangle_dotted(const _SHP: TSHP; var _TempView: TObjectData; var _TempView_no:integer; const _SHPPalette:TPalette; _Frame: Word; _Xpos, _Ypos, _Xpos2, _Ypos2:Integer);
var
   x, y, c: Integer;
begin
   // Reset Tempview
   _TempView_No := 0;
   SetLength(_TempView,0);

   // Resets counter
   c := 0;
   // write top line
   for x := Max(Min(_XPos, _XPos2), 0) to Min(_SHP.Header.Width - 1, Max(_XPos, _XPos2)) do
   begin
      inc(c);
      if (c  < 4) and (PointOK(_SHP, x, Min(_YPos, _YPos2))) then
      begin
         AddAnyColourToTempViewUnsafe(_TempView, _TempView_No, x, Min(_YPos, _YPos2), OpositeColour(_SHPPalette[_SHP.Data[_Frame].FrameImage[x,Min(_YPos, _YPos2)]]));
      end
      else
         c := 0;
   end;

   c := 0;
   // write bottom line
   for x := Max(Min(_XPos, _XPos2), 0) to Min(_SHP.Header.Width - 1, Max(_XPos, _XPos2)) do
   begin
      inc(c);
      if (c < 4) and (PointOK(_SHP, x, Max(_YPos, _YPos2))) then
      begin
         AddAnyColourToTempViewUnsafe(_TempView, _TempView_No, x, Max(_YPos, _YPos2), OpositeColour(_SHPPalette[_SHP.Data[_Frame].FrameImage[x,Max(_YPos, _YPos2)]]));
      end
      else
         c := 0;
   end;

   c := 0;
   // write left line
   for y := Max(Min(_YPos, _YPos2), 0) to Min(_SHP.Header.Height - 1, Max(_YPos, _YPos2)) do
   begin
      inc(c);
      if (c < 4) and (PointOK(_SHP, Min(_XPos, _XPos2), y)) then
      begin
         AddAnyColourToTempViewUnsafe(_TempView, _TempView_No, Min(_XPos, _XPos2), y, OpositeColour(_SHPPalette[_SHP.Data[_Frame].FrameImage[Min(_XPos, _XPos2), y]]));
      end
      else
         c := 0;
   end;

   c := 0;
   // write right line
   for y := Max(Min(_YPos, _YPos2), 0) to Min(_SHP.Header.Height - 1, Max(_YPos, _YPos2)) do
   begin
      inc(c);
      if (c < 4) and (PointOK(_SHP, Max(_XPos, _XPos2), y)) then
      begin
         AddAnyColourToTempViewUnsafe(_TempView, _TempView_No, Max(_XPos, _XPos2), y, OpositeColour(_SHPPalette[_SHP.Data[_Frame].FrameImage[Max(_XPos, _XPos2), y]]));
      end
      else
         c := 0;
   end;
end;

//---------------------------------------------
// Draw Brush for Darken Lighten - Preview
//---------------------------------------------
// Note: BrushToolDarkenLighten Code Taken From Voxel Section Editor and adapted to this program
procedure BrushToolDarkenLighten(var _SHP:TSHP; var _TempView: TObjectData; var _TempView_no: integer; _Frame: Word; _Xc, _Yc: Integer; _BrushMode: Integer); overload;
var
   Shape: Array[-5..5, -5..5] of 0..1;
   i, j, r1, r2: Integer;
   t : byte;
begin
   Randomize;
   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;

   Shape[0, 0] := 1;
   if _BrushMode >= 1 then
   begin
      Shape[0, 1] := 1;
      Shape[0, -1] := 1;
      Shape[1, 0] := 1;
      Shape[-1, 0] := 1;
   end;
   if _BrushMode >= 2 then
   begin
      Shape[1, 1] := 1;
      Shape[1, -1] := 1;
      Shape[-1, -1] := 1;
      Shape[-1, 1] := 1;
   end;
   if _BrushMode >= 3 then
   begin
      Shape[0, 2] := 1;
      Shape[0, -2] := 1;
      Shape[2, 0] := 1;
      Shape[-2, 0] := 1;
   end;
   if _BrushMode = 4 then
   begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i, j] := 0;

      for i := 1 to 4 do
      begin
         r1 := random(7) - 3;
         r2 := random(7) - 3;
         Shape[r1, r2] := 1;
      end;
   end;
    //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i := -5 to 5 do
   begin
      for j := -5 to 5 do
      begin
         if Shape[i, j] = 1 then
         begin
            t := _SHP.Data[_Frame].FrameImage[Max(Min(_Xc + i, _SHP.Header.Width - 1), 0), Max(Min(_Yc + j, _SHP.Header.Height - 1), 0)];
            AddAnyColourToTempViewUnsafe(_TempView, _TempView_No, Max(Min(_Xc + i, _SHP.Header.Width - 1), 0), Max(Min(_Yc + j, _SHP.Header.Height - 1), 0), t);
            _SHP.Data[_Frame].FrameImage[Max(Min(_Xc + i, _SHP.Header.Width - 1), 0), Max(Min(_Yc + j, _SHP.Header.Height - 1), 0)] := darkenlightenv(FrmMain.DarkenLighten_B, t, FrmMain.DarkenLighten_N);
         end;
      end;
   end;
end;

//---------------------------------------------
// Draw Brush for Darken Lighten - On frame
//---------------------------------------------
procedure BrushToolDarkenLighten(var _SHP:TSHP; _Frame: Word; _Xc,_Yc: Integer; _BrushMode: Integer); overload;
var
  Shape: Array[-5..5, -5..5] of 0..1;
  i, j, r1, r2: Integer;
  t : byte;
begin
   Randomize;
   for i := -5 to 5 do
      for j := -5 to 5 do
         Shape[i, j] := 0;

   Shape[0, 0] := 1;
   if _BrushMode >= 1 then
   begin
      Shape[0, 1] := 1;
      Shape[0, -1] := 1;
      Shape[1, 0] := 1;
      Shape[-1, 0] := 1;
   end;
   if _BrushMode >= 2 then
   begin
      Shape[1, 1] := 1;
      Shape[1, -1] := 1;
      Shape[-1, -1] := 1;
      Shape[-1, 1] := 1;
   end;
   if _BrushMode >= 3 then
   begin
      Shape[0, 2] := 1;
      Shape[0, -2] := 1;
      Shape[2, 0] := 1;
      Shape[-2, 0] := 1;
   end;
   if _BrushMode = 4 then
   begin
      for i := -5 to 5 do
         for j := -5 to 5 do
            Shape[i, j] := 0;

      for i := 1 to 4 do
      begin
         r1 := random(7) - 3;
         r2 := random(7) - 3;
         Shape[r1, r2] := 1;
      end;
   end;
    //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   for i := -5 to 5 do
   begin
      for j := -5 to 5 do
      begin
         if Shape[i, j] = 1 then
         begin
            t := _SHP.Data[_Frame].FrameImage[Max(Min(_Xc + i, _SHP.Header.Width- 1 ), 0), Max(Min(_Yc + j, _SHP.Header.Height - 1), 0)];
            _SHP.Data[_Frame].FrameImage[Max(Min(_Xc + i, _SHP.Header.Width - 1), 0),Max(Min(_Yc + j, _SHP.Header.Height - 1), 0)] := darkenlightenv(FrmMain.DarkenLighten_B, t, FrmMain.DarkenLighten_N);
         end;
      end;
   end;
end;

//---------------------------------------------
// Get Opposite Color
//---------------------------------------------
function OpositeColour(_Color : TColor) : tcolor;
var
   r,g,b : byte;
begin
   r := 255 - GetRValue(_Color);
   g := 255 - GetGValue(_Color);
   b := 255 - GetBValue(_Color);
   Result := RGB(r,g,b);
end;

//---------------------------------------------
// Get Dark'en/Light'en value.
//---------------------------------------------
function DarkenLightenV(_Darken:boolean; _Current_Value, _Value : byte) : byte;
var
   temp : word;
begin
   if _Darken then
      temp := _Current_Value - _Value
   else
      temp := _Current_Value + _Value;

   if temp < 1 then
      temp := temp + 255;

   if temp > 255 then
      temp := temp - 255;

   Result := temp;
end;


//---------------------------------------------
// Add 1 Coordinate - Preview
//---------------------------------------------
procedure Add2DPointToTempview(const _SHP:TSHP; var _Tempview: TObjectData; var _TempView_no : integer; _Frame,_XPos,_YPos:Integer);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
      begin
         SetLength(_Tempview, _Tempview_No + 1);
         _Tempview[_Tempview_no].X := _XPos;
         _TempView[_Tempview_no].Y := _YPos;
         inc(_Tempview_no);
      end;
end;

//---------------------------------------------
// Add 1 Coordinate (Unsafe Mode) - Preview
//---------------------------------------------
procedure Add2DPointToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _XPos,_YPos:Integer);
begin
   SetLength(_Tempview, _Tempview_No + 1);
   _Tempview[_Tempview_no].X := _XPos;
   _TempView[_Tempview_no].Y := _YPos;
   inc(_Tempview_no);
end;

//---------------------------------------------
// Add 2 Coordinates (Unsafe Mode) - Preview
//---------------------------------------------
procedure AddTwo2DPointsToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _XPos1,_YPos1,_XPos2,_YPos2:Integer);
begin
   SetLength(_Tempview, _Tempview_No + 2);
   _Tempview[_Tempview_no].X := _XPos1;
   _TempView[_Tempview_no].Y := _YPos1;
   inc(_Tempview_no);
   _Tempview[_Tempview_no].X := _XPos2;
   _TempView[_Tempview_no].Y := _YPos2;
   inc(_Tempview_no);
end;

//---------------------------------------------
// Add 4 Coordinates (Unsafe Mode) - Preview
//---------------------------------------------
procedure AddFour2DPointsToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _XPos1,_YPos1,_XPos2,_YPos2,_XPos3,_YPos3,_XPos4,_YPos4:Integer);
begin
   SetLength(_Tempview, _Tempview_No + 4);
   _Tempview[_Tempview_no].X := _XPos1;
   _TempView[_Tempview_no].Y := _YPos1;
   inc(_Tempview_no);
   _Tempview[_Tempview_no].X := _XPos2;
   _TempView[_Tempview_no].Y := _YPos2;
   inc(_Tempview_no);
   _Tempview[_Tempview_no].X := _XPos3;
   _TempView[_Tempview_no].Y := _YPos3;
   inc(_Tempview_no);
   _Tempview[_Tempview_no].X := _XPos4;
   _TempView[_Tempview_no].Y := _YPos4;
   inc(_Tempview_no);
end;

//---------------------------------------------
// Add Color - Preview
//---------------------------------------------
procedure AddColourToTempview(const _SHP:TSHP; var _Palette: TPalette; var _Tempview: TObjectData; var _TempView_no : integer; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
         if (_SHP.Data[_Frame].FrameImage[_XPos, _YPos] <> 0) then
         begin
            SetLength(_TempView, _TempView_No + 1);
            _TempView[_TempView_No].X := _XPos;
            _TempView[_TempView_No].Y := _YPos;
            _TempView[_TempView_No].colour := _Palette[LoadPixel(_List, _Last, _Alg, RGB(GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division)), GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division)), GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division))))];
            _TempView[_TempView_No].colour_used := true;
            inc(_TempView_No);
         end;
end;

//---------------------------------------------
// Add any Color - Preview
//---------------------------------------------
procedure AddAnyColourToTempview(const _SHP:TSHP; var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos: Integer; _Colour: TColor);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
      begin
         SetLength(_TempView, _TempView_No + 1);
         _TempView[_TempView_No].X := _XPos;
         _TempView[_TempView_No].Y := _YPos;
         _TempView[_TempView_No].colour := _Colour;
         _TempView[_TempView_No].colour_used := true;
         inc(_TempView_No);
      end;
end;

//---------------------------------------------
// Add any Color (Unsafe Mode) - Preview
//---------------------------------------------
procedure AddAnyColourToTempviewUnsafe(var _Tempview: TObjectData; var _TempView_no : integer; _Xpos,_Ypos: Integer; _Colour: TColor);
begin
   SetLength(_TempView, _TempView_No + 1);
   _TempView[_TempView_No].X := _XPos;
   _TempView[_TempView_No].Y := _YPos;
   _TempView[_TempView_No].colour := _Colour;
   _TempView[_TempView_No].colour_used := true;
   inc(_TempView_No);
end;

//---------------------------------------------
// Add Color - On frame
//---------------------------------------------
procedure AddColourToSHP(var _SHP:TSHP; var _Palette: TPalette; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
         if (_SHP.Data[_Frame].FrameImage[_XPos, _YPos] <> 0) then
         begin
            _SHP.Data[_Frame].FrameImage[_XPos, _YPos] := LoadPixel(_List, _Last, _Alg, RGB(GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division)), GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division)),GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) - (_Bias * (GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) div _Division))));
         end;
end;

//---------------------------------------------
// Add Snow Color - Preview
//---------------------------------------------
procedure AddSnowColourToTempview(const _SHP:TSHP; var _Palette: TPalette; var _TempView: TObjectData; var _TempView_no : integer; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
         if (_SHP.Data[_Frame].FrameImage[_XPos, _YPos] <> 0) then
         begin
            SetLength(_TempView, _TempView_No + 1);
            _TempView[_TempView_No].X := _XPos;
            _TempView[_TempView_No].Y := _YPos;
            _TempView[_TempView_No].colour := _Palette[LoadPixel(_List, _Last, _Alg, RGB(GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division)), GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division)), GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division))))];
            _TempView[_TempView_No].colour_used := true;
            inc(_TempView_No);
         end;
end;

//---------------------------------------------
// Add Snow Color - On frame
//---------------------------------------------
procedure AddSnowColourToSHP(var _SHP:TSHP; const _Palette: TPalette; _Frame,_Xpos,_Ypos,_Alg:Integer; var _List,_Last:listed_colour; _Bias,_Division:byte);
begin
   if (_YPos < _SHP.Header.Height) and (_YPos >= 0) then
      if (_XPos < _SHP.Header.Width) and (_XPos >= 0) then
         if (_SHP.Data[_Frame].FrameImage[_XPos, _YPos] <> 0) then
         begin
            _SHP.Data[_Frame].FrameImage[_XPos, _YPos] := LoadPixel(_List, _Last, _Alg, RGB(GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetRValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division)), GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetGValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division)), GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]]) + (_Bias * ((255 - GetBValue(_Palette[_SHP.Data[_Frame].FrameImage[_XPos, _YPos]])) div _Division))));
         end;
end;

end.
