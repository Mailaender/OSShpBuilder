unit SHP_Colour_Bank;

interface

uses Windows, Palette;

type
   colour_element = ^bank_colour;

   bank_colour = record
      rleft, rright, gleft, gright, bleft, bright: colour_element;
      r, g, b, col: byte;
   end;


// Colour_Bank Manipulation Code
function IsEmptyBank(Start: colour_element): boolean;
function GetWrittingPosition(var Start: colour_element; r, g, b: byte): byte;
procedure AddToBank(var Start: colour_element; r, g, b, col: byte);
function ColourInBank(Start: colour_element; r, g, b: byte): integer;
procedure RemoveElementBank(var X: colour_element);
procedure ClearBank(var Start: colour_element);
procedure InitializeBank(var Start: colour_element);

implementation

// Colour Bank Manipulation Procedures/Functions

function IsEmptyBank(Start: colour_element): boolean;
begin
   if (Start = nil) then
      Result := True
   else
      Result := False;
end;

function GetWrittingPosition(var Start: colour_element; r, g, b: byte): byte;
begin
   Result := 0;
{ New Non-Recursive Code:
  It checks for the position that the element should be written
  And returns a code where AddToBank interprets to do the linkage}
   while Start <> nil do
   begin
      if r = Start^.r then
      begin
         if g = Start^.g then
         begin
            if b = Start^.b then
            begin
               // this is not supposed to happen, but in the worse
               // of the cases...
               Result := 0;
               break;
            end
            else if b > Start^.b then
            begin
               if Start^.bright <> nil then
                  Start := Start^.bright
               else
               begin
                  Result := 5;
                  break;
               end;
            end
            else if b < Start^.b then
            begin
               if Start^.bleft <> nil then
                  Start := Start^.bleft
               else
               begin
                  Result := 6;
                  break;
               end;
            end;
         end
         else if g > Start^.g then
         begin
            if Start^.gright <> nil then
               Start := Start^.gright
            else
            begin
               Result := 3;
               break;
            end;
         end
         else if g < Start^.g then
         begin
            if Start^.gleft <> nil then
               Start := Start^.gleft
            else
            begin
               Result := 4;
               break;
            end;
         end;
      end
      else if r > Start^.r then
      begin
         if Start^.rright <> nil then
            Start := Start^.rright
         else
         begin
            Result := 1;
            break;
         end;
      end
      else if r < Start^.r then
      begin
         if Start^.rleft <> nil then
            Start := Start^.rleft
         else
         begin
            Result := 2;
            break;
         end;
      end;
   end;
end;

procedure AddToBank(var Start: colour_element; r, g, b, col: byte);
var
   x, Element: colour_element;
   a: byte;
begin
   // Generate the Element
   new(Element);

   // Provides the info to the new Element
   Element^.r   := r;
   Element^.g   := g;
   Element^.b   := b;
   Element^.col := col;

   // Check if the it's the first element or just an yet another one
   if IsEmptyBank(Start) then
      Start := Element
   else
   begin
      // find last element
      x := Start;
      a := GetWrittingPosition(x, r, g, b);
      if a = 1 then
         x^.rright := Element
      else if a = 2 then
         x^.rleft := Element
      else if a = 3 then
         x^.gright := Element
      else if a = 4 then
         x^.gleft := Element
      else if a = 5 then
         x^.bright := Element
      else if a = 6 then
         x^.bleft := Element;
   end;
   // Other linking stuff...
   Element^.rleft  := nil;
   Element^.rright := nil;
   Element^.gleft  := nil;
   Element^.gright := nil;
   Element^.bleft  := nil;
   Element^.bright := nil;
end;

function ColourInBank(Start: colour_element; r, g, b: byte): integer;
var
   colour: integer;
begin
   colour := -1;
   while Start <> nil do
   begin
      if r = Start^.r then
      begin
         if g = Start^.g then
         begin
            if b = Start^.b then
            begin
               colour := Start^.col;
               break;
            end
            else if b > Start^.b then
               Start := Start^.bright
            else if b < Start^.b then
               Start := Start^.bleft;
         end
         else if g > Start^.g then
            Start := Start^.gright
         else if g < Start^.g then
            Start := Start^.gleft;
      end
      else if r > Start^.r then
         Start := Start^.rright
      else if r < Start^.r then
         Start := Start^.rleft;
   end;
   Result := colour;
end;

procedure RemoveElementBank(var X: colour_element);
begin
   if (X <> nil) then
   begin
      RemoveElementBank(X^.rright);
      RemoveElementBank(X^.rleft);
      RemoveElementBank(X^.gright);
      RemoveElementBank(X^.gleft);
      RemoveElementBank(X^.bright);
      RemoveElementBank(X^.bleft);
      X^.rright := nil;
      X^.rleft  := nil;
      X^.gright := nil;
      X^.gleft  := nil;
      X^.bright := nil;
      X^.bleft  := nil;
      dispose(X);
   end;
end;

procedure ClearBank(var Start: colour_element);
var
   scout: colour_element;
begin
   // playtime. Let's eliminate all colours (6) :twisted:
   new(scout);
   // We cannot clear an empty list
   if not IsEmptyBank(Start) then
   begin
      // Time to track the last element. Recursion sounds good.
      scout := Start;
      RemoveElementBank(scout);
   end;
end;

procedure InitializeBank(var Start: colour_element);
begin
   Start := nil;
end;


end.
