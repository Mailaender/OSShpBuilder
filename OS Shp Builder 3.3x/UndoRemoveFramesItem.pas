unit UndoRemoveFramesItem;

interface
uses
    IUndoItem, Shp_File, Classes;
    
type
    //---------------------------------------------
    // Undo - RemoveFrame
    //---------------------------------------------
    TUndoRemoveFramesItem = class(IUndoItem)
    private
        frames : TList<TFrame>;
    public
        constructor Create(var shp : TSHP; frameIDs : TList<Integer>);
        procedure Undo;
    end;


//===============================================
implementation
//===============================================


//---------------------------------------------
// Constructor
//---------------------------------------------
constructor TUndoRemoveFramesItem.Create(var shp : TSHP; frameIDs : TList<Integer>);
var
    i, 
    x, y, 
    pixelCount : integer;
    frameImage : TFrameImage;
    frame : TFrame;
begin
    // Init.
    frames := TList<TFrame>.Create(frameIDs.Count);

    for i := 0 to frameIDs.Count - 1 do
    begin
        frame.ID := frameIDs.Items[i];
        frameImage := shp.Data[frame.ID];

        for x := 0 to shp.Header.Width - 1 do
            for y := 0 to shp.Header.Height - 1 do
            begin
                if frame[x, y] <> 0 then

            end;
    end;
end;
