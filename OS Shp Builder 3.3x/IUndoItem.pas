unit IUndoItem;

interface

uses 
    System.Generics.Collections, SHP_File, Math;

type
    //---------------------------------------------
    // Pixel
    //---------------------------------------------
    TPixel = record
        X : integer;
        Y : integer;
        Colour : byte;
    end;


    //---------------------------------------------
    // Frame
    //---------------------------------------------
    TFrame = record
        ID : word;
        Pixels : array of TPixelChanged;
    end;

    
    //---------------------------------------------
    // Interface UndoItem
    //---------------------------------------------
    IUndoItem = Interface(IInterface)
        procedure Undo;
    end;