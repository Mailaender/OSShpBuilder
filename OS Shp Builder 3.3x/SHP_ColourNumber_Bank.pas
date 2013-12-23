unit SHP_ColourNumber_Bank;

{

// 3.31: Scrapped! Using SHP_ColourNumber_List instead.


TColour ID: It's a binary search tree that holds the number of
the colours and avoids repetitive aditions. It allows you to
add and remove elements as the user/programmer adds and remove
them and there is also a final procedure to clear the tree.

There is no procedure to re-ballance the tree. Here's the
specifications of TColourID tree:

(Note: Consider the default base for log binary, since processors only work with 0 and 1)

Initialialization: Very Fast  | O(1)
Add Element: Fast | O(log n)
Search Element: Fast | O(log n)
Confirm Element's presence: Fast | O(log n)
Remove Element: Fast |O(log n)
Clear Tree: A Bit Fast | O(n)


}
interface

type
   TColourID = ^tcolouriddata;

   tcolouriddata = record
      ID:   byte;
      r, l: TColourID;
   end;


// Here's the engine:


// Global Functions:
procedure InitializeColourID(var Top: TColourID);
procedure AddColourID(var Top: TColourID; ID: byte);
function IsColourInColourIDList(var Top: TColourID; ID: byte): boolean;
procedure RemoveColourID(var Top: TColourID; ID: byte);
procedure ClearColourIDTree(var Top: TColourID);

// Internal functions (related to removal of elements)
procedure FindCloserColourID(var ElementToBeDeleted, CloserElement: TColourID);
procedure FindLinkerFromColourID(var Top, ColourID, Linker: TColourID);
procedure WipeColourID(var Top, ColourID: TColourID);
procedure ClearColourIDTreeElement(var ColourID: TColourID);


implementation

procedure InitializeColourID(var Top: TColourID);
begin
   Top := nil;
end;

procedure AddColourID(var Top: TColourID; ID: byte);
var
   newstuff, position, newposition: TColourID;
begin
   // Create new item
   new(newstuff);

   // Find out where to place
   if Top = nil then // first element?
      Top := newstuff
   else // not first element
   begin
      newposition := Top; // reset newposition
      position    := newposition;
      while (newposition <> nil) do // hunt last element
      begin
         position := newposition;
         if newposition^.ID > ID then
            newposition := newposition^.l
         else if newposition^.ID < ID then
            newposition := newposition^.r
         else
            exit; // nothing to add.
      end;

      // link new element.
      if position^.ID > ID then
         position^.l := newstuff
      else
         position^.r := newstuff;
   end;

   // add contents
   newstuff^.ID := ID;
   newstuff^.r  := nil;
   newstuff^.l  := nil;
end;

function IsColourInColourIDList(var Top: TColourID; ID: byte): boolean;
var
   position: TColourID;
begin
   Result   := False;
   position := Top; // reset position
   while (position <> nil) do // hunt element
   begin
      if position^.ID > ID then
         position := position^.l
      else if position^.ID < ID then
         position := position^.r
      else
      begin
         Result := True; // Colour found.
         exit;
      end;
   end;
end;

procedure FindCloserColourID(var ElementToBeDeleted, CloserElement: TColourID);
begin
   if ElementToBeDeleted^.l <> nil then
   begin
      CloserElement := ElementToBeDeleted^.l;
      while CloserElement^.r <> nil do
         CloserElement := CloserElement^.r;
   end
   else if ElementToBeDeleted^.r <> nil then
   begin
      CloserElement := ElementToBeDeleted^.r;
      while CloserElement^.l <> nil do
         CloserElement := CloserElement^.l;
   end
   else
      CloserElement := nil;
end;

procedure FindLinkerFromColourID(var Top, ColourID, Linker: TColourID);
var
   RealLinker: TColourID;
begin
   Linker     := Top;
   RealLinker := Top;
   while (Linker <> nil) do // hunt ID element
   begin
      if Linker^.ID > ColourID^.ID then
      begin
         RealLinker := Linker;
         Linker     := Linker^.l;
      end
      else if Linker^.ID < ColourID^.ID then
      begin
         RealLinker := Linker;
         Linker     := Linker^.r;
      end
      else
      begin
         Linker := RealLinker;
         exit;
      end;
   end; // if Link is nil, it's a leaf, first element.
end;

procedure WipeColourID(var Top, ColourID: TColourID);
var
   CloserElement, Linker: TColourID;
begin
   if (ColourID^.l = nil) and (ColourID^.r = nil) then // leaf, wipe!
   begin
      FindLinkerFromColourID(Top, ColourID, Linker);
      if Linker^.l = ColourID then
         Linker^.l := nil
      else if Linker^.r = ColourID then
         Linker^.r := nil
      else
         Top := nil;
      Dispose(ColourID);
   end
   else if ColourID <> nil then
   begin
      FindCloserColourID(ColourID, CloserElement);
      ColourID^.ID := CloserElement^.ID;
      WipeColourID(Top, CloserElement);
   end; // if it's nil, there is nothing to remove.
end;

procedure RemoveColourID(var Top: TColourID; ID: byte);
var
   ColourID: TColourID;
begin
   ColourID := Top;
   while ColourID <> nil do
   begin
      if ID > ColourID^.ID then
         ColourID := ColourID^.r
      else if ID < ColourID^.ID then
         ColourID := ColourID^.l
      else
      begin
         WipeColourID(Top, ColourID);
         exit;
      end;
   end;
end;

procedure ClearColourIDTreeElement(var ColourID: TColourID);
begin
   if (ColourID <> nil) then // leaf: WIPE!
   begin
      ClearColourIDTreeElement(ColourID^.l);
      ClearColourIDTreeElement(ColourID^.r);
      ColourID^.l := nil;
      ColourID^.r := nil;
      Dispose(ColourID);
   end;
end;

procedure ClearColourIDTree(var Top: TColourID);
begin
   if (Top <> nil) then // The tree has elements!
   begin
      ClearColourIDTreeElement(Top);
      InitializeColourID(Top);
   end;
end;

end.
