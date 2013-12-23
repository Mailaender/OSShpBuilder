unit Colour_list;

interface
uses Windows,Palette;

type
   listed_colour = ^list_colour;
   list_colour = record
                 id,r,g,b:byte;
                 next:listed_colour;
                 end;

// Colour_List Manipulation Code
Procedure InitializeColourList (var List,Last:listed_colour);
Procedure AddToColourList(var List,Last:listed_colour; Palette:TPalette; start,final:byte);
Procedure AddToColourList2(var List,Last:listed_colour; r,g,b,id:byte);
Procedure ClearColourList (var List,Last:listed_colour);

implementation
// Colour List Codes Starts Here:

Procedure InitializeColourList(var List,Last:listed_colour);
begin
   List := nil;
   Last := nil;
end;

Procedure AddToColourList(var List,Last:listed_colour; Palette:TPalette; start,final:byte);
var
   adition:listed_colour;
   count:byte;
begin
   if final >= start then
   begin
      for count:=start to final do
      begin
        new(adition);
        adition^.r := GetRValue(Palette[count]);
        adition^.g := GetGValue(Palette[count]);
        adition^.b := GetBValue(Palette[count]);
        adition^.id := count;
        if List = nil then
        begin
           List := adition;
        end
        else
        begin
           Last^.next := adition;
        end;
        Last := adition;
        Last^.next := nil;
      end;
   end;
end;

Procedure AddToColourList2(var List,Last:listed_colour; r,g,b,id:byte);
var
   adition:listed_colour;
begin
   new(adition);
   adition^.r := r;
   adition^.g := g;
   adition^.b := b;
   adition^.id := id;
   if List = nil then
      List := adition
   else
      Last^.next := adition;
   Last := adition;
   adition^.next := nil;
end;

Procedure ClearColourList (var List,Last:listed_colour);
var
  p,q : listed_colour;
begin
  p := List;
  while p <> nil do
  begin
     q := p^.next;
     p^.next := nil;
     dispose(p);
     p := q;
  end;
  InitializeColourList(List,Last);
end;


end.
