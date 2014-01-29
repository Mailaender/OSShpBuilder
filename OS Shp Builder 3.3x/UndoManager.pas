unit UndoManager;

interface

uses 
    System.Generics.Collections, IUndoItem;

type
    //---------------------------------------------
    // Class UndoManager
    //---------------------------------------------
    TUndoManager = class 
    private
        items : TStack<IUndoItem>;        
    public
        procedure Undo;
        procedure AddItem(var IUndoItem);

        constructor Create;
        destructor Destroy : override;
    end;



//================================================
implementation
//===============================================


//---------------------------------------------
// Constructor
//---------------------------------------------
constructor TUndoManager.Create;
begin
    items = TStack<IUndoItem>.Create;
end;


//---------------------------------------------
// Destructor
//---------------------------------------------
destructor TUndoManager.Destroy;
begin
    items.Free;
end;


//---------------------------------------------
// Undo
//---------------------------------------------
procedure TUndoManager.Undo;
begin
    items.Extract.Undo;
end;
