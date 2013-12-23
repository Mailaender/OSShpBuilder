unit SHP_ColourNumber_List;

interface

type
   TColourID = ^tcolouriddata;

   tcolouriddata = record
      ID:   byte;
      Next: TColourID;
   end;

// Here's the engine:


// Global Functions:
procedure InitializeColourID(var Top: TColourID);
procedure AddColourID(var Top: TColourID; ID: byte);
function IsColourInColourIDList(var Top: TColourID; ID: byte): boolean;
procedure RemoveColourID(var Top: TColourID; ID: byte);
procedure ClearColourIDTree(var Top: TColourID);


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
         position    := newposition;
         newposition := newposition^.Next;
      end;

      // link new element.
      position^.Next := newstuff;
   end;

   // add contents
   newstuff^.ID   := ID;
   newstuff^.Next := nil;
end;

function IsColourInColourIDList(var Top: TColourID; ID: byte): boolean;
var
   position: TColourID;
begin
   Result   := False;
   position := Top; // reset position
   while (position <> nil) do // hunt element
   begin
      if position^.ID = ID then
      begin
         Result := True;
         exit;
      end;
      position := position^.Next;
   end;
end;

procedure RemoveColourID(var Top: TColourID; ID: byte);
var
   ColourID, Previous: TColourID;
begin
   ColourID := Top;
   Previous := Top;
   // 3.36: check top first.
   if ColourID <> nil then
   begin
      if ID = ColourID^.ID then
      begin // Element found
            // Unlink the victim
         Top := Top^.Next;
         dispose(ColourID);
         exit;
      end
      else
      begin // Element not found
            // Try next element.
         Previous := ColourID;
         ColourID := ColourID^.Next;
      end;
   end;
   // Now, we continue with the old code.
   while ColourID <> nil do
   begin
      if ID = ColourID^.ID then
      begin // Element found
            // Unlink the victim
         Previous^.Next := ColourID^.Next;
         dispose(ColourID);
         exit;
      end
      else
      begin // Element not found
            // Try next element.
         Previous := ColourID;
         ColourID := ColourID^.Next;
      end;
   end;
end;

procedure ClearColourIDTree(var Top: TColourID);
var
   Next: TColourID;
begin
   if (Top <> nil) then // The tree has elements!
   begin
      Next := Top^.Next;
      Dispose(Top);
      Top := Next;
   end;
   Top := nil;
end;

end.
