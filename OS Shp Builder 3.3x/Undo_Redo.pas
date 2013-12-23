unit Undo_Redo;

interface

uses
  Graphics, SHP_file, Math; //OS_Document_Engine;

type
TUndoType = (utSingleFrame,utMultiFrame,utResize,utAddFrame,utDeleteFrame,utReverseFrame,utMoveFrame,utSwapFrames);

TUndoRedo_Item = record
        X : integer;
        Y : integer;
        Colour : byte;
end;

TUndoRedo_Frames = array of packed record
        Num : cardinal;
        FrameID : word;
        Items : array of TUndoRedo_Item;
end;

TUndoLink = ^TUndoRedo;
TUndoRedo_Items = array of packed record
        Num : cardinal;
        ItemType : TUndoType;
        ExternalLink : TUndoLink;
        Frames : TUndoRedo_Frames;
        Width,Height : word;
end;

TUndoRedo = record
        Num : cardinal;
        Items : TUndoRedo_Items;
end;

// Functions for Undo Adition Of Single Frames
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP: TSHP; const TempView : TObjectData; TempView_num : integer;FrameImage : TFrameImage; FrameImage_no : Cardinal); overload;
procedure AddToUndo(var UndoRedo : TUndoRedo; const TempView : TObjectData; TempView_num : integer; FrameImage_no,Height,Width : Cardinal); overload;
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP; FrameImage_no : Cardinal); overload;
procedure AddToUndo(var UndoRedo : TUndoRedo; var Shp : TSHP; FrameIndex : integer; var Selection : TSelection); overload;


// Functions for multiframed undo purpouses.
procedure GenerateNewUndoItem(var UndoRedo : TUndoRedo);
procedure AddToUndoMultiFrames(var UndoRedo : TUndoRedo; framenumber:word; xpos,ypos:smallint; colour:byte);
procedure AddToUndoMultiFramesB(var UndoRedo : TUndoRedo; framenumber:word; xpos,ypos:smallint; colour:byte);
procedure NewUndoItemValidation(var UndoRedo : TUndoRedo);

// Functions for resizing undo purpouses
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP); overload;

// Functions used for ranged frames (like auto-shadows)
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP; Start,Final: word); overload;

// Functions for insert and delete frame situations.
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; FrameImage_no : word); overload;
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; FrameImage_no1,FrameImage_no2 : word); overload;
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; StartFrame,EndFrame : word; flag : boolean); overload;
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; StartFrame,EndFrame,StartShadowFrame : word); overload;
procedure AddToUndoRemovedFrame(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no : word); overload;
procedure AddToUndoRemovedFrame(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no1,FrameImage_no2 : word); overload;
procedure AddToUndoRemovedFrames(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no,Ammount : word); overload;
procedure AddToUndoRemovedFrames(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no,ShadowImage_no,Ammount : word); overload;

// Functions for reversed and swapped frames.
procedure StartUndoSwappedFrames(var UndoRedo:TUndoRedo; ItemAmmount : Integer);
procedure StartUndoReversedFrames(var UndoRedo:TUndoRedo; ItemAmmount : Integer);
procedure AddToUndoReversedFrames(var UndoRedo: TUndoRedo; Item,Frame1,Frame2 : Integer);

// Undo data cleanance
Procedure ClearUndo(var UndoList:TUndoRedo);

// This when the program really undo the stuff
procedure UndoAction(var SHP : TSHP; var UndoRedo : TUndoRedo; var SizeChanged:Boolean);
// Auxiliary function to undo resized frames.
procedure UndoResize(var SHP : TSHP; var UndoRedo : TUndoRedo; var SizeChanged:Boolean);
// Auxiliary functions to undo, filling frames
procedure UndoFrame (var SHP: TSHP; UndoRedo : TUndoRedo; z : integer);
procedure UndoFrames (var SHP: TSHP; UndoRedo : TUndoRedo);
// Auxiliary function to undo deleted frames
procedure UndoDeleteFrames (var SHP: TSHP; UndoRedo : TUndoRedo);
// Auxiliary function to undo reversed and swapped frames
procedure UndoReverseFrames (var SHP : TSHP; UndoRedo : TUndoRedo);
procedure UndoSwapFrames (var SHP : TSHP; UndoRedo : TUndoRedo);
// Auxiliary function to undo add frames
procedure UndoAddFrames (var SHP: TSHP; UndoRedo : TUndoRedo);


// Get Undo Status (now expanded for multi-files purpouses)
function GetUndoStatus(const UndoList:TUndoRedo) : boolean;


implementation

uses SHP_Frame, FormMain;


//---------------------------------------------
// AddToUndo : Store original pixels before modification.
//             Retrieves colors from FrameImage.     
// PARAMS 
//    UndoRedo       : Undo List
//    SHP            : Shp
//    TempView       : Frame Pixels to store
//    TempView_num   : Pixel Count
//    FrameImage     : Frame
//    FrameImage_no  : Frame Index     
//---------------------------------------------
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP: TSHP; const TempView : TObjectData; TempView_num : integer; FrameImage : TFrameImage; FrameImage_no : Cardinal); overload;
var
   x : cardinal;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,TempView_num);

   // Default values 
   UndoRedo.Items[UndoRedo.Num].Width := 0; 
   UndoRedo.Items[UndoRedo.Num].Height := 0;

   UndoRedo.Items[UndoRedo.Num].ItemType := utSingleFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].num := TempView_num;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no;
   UndoRedo.Items[UndoRedo.num].Num := 1;

   for x := 0 to TempView_num - 1 do
   begin
      // 3.35: Make sure it doesn't add items that are outside the frame.
      if (TempView[X].X < SHP.Header.Width) and (TempView[X].Y < SHP.Header.Height) then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[x].colour := FrameImage[TempView[x].X,TempView[x].Y];
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[x].X := TempView[x].X;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[x].Y := TempView[x].Y;
      end;
   end;

   inc(UndoRedo.num);
end;


//---------------------------------------------
// AddToUndo : Store original pixels before modification.
//             Retrieves colors from TempView.
// PARAMS :
//    UndoRedo       : Undo List
//    TempView       : Frame pixels to store
//    TempView_num   : Pixel Count
//    FrameImage_no  : Frame Index
//    Height         : Frame Height
//    Width          : Frame Width
//---------------------------------------------
// 3.35: Specially done for BrushDarkenLighten
procedure AddToUndo(var UndoRedo : TUndoRedo; const TempView : TObjectData; TempView_num : integer; FrameImage_no,Height,Width : Cardinal); overload;
var
   x : cardinal;
begin
   SetLength(UndoRedo.Items, UndoRedo.num + 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames, 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items, TempView_num + 1);

   UndoRedo.Items[UndoRedo.Num].Width := 0; 
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utSingleFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].num := TempView_num;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no;
   UndoRedo.Items[UndoRedo.num].Num := 1;

   for x := 1 to TempView_num do
   begin
      // 3.35: Make sure it doesn't add items that are outside the frame.
      if (UndoRedo.Items[UndoRedo.num].Frames[0].Items[X-1].X < Width) and (UndoRedo.Items[UndoRedo.num].Frames[0].Items[X-1].Y < Height) then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[X-1].colour := TempView[X].colour;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[X-1].X := TempView[X].X;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[X-1].Y := TempView[X].Y;
      end;
   end;

   UndoRedo.num := UndoRedo.num + 1;
end;


///---------------------------------------------
// AddToUndo : Store all frame pixels.
//             Retrieve colors directly from FrameImage. 
// PARAMS
//    UndoRedo       : Undo List
//    SHP            : Shp
//    FrameImage_no  : Frame Index
//---------------------------------------------
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP; FrameImage_no : Cardinal); overload;
var
   x,y,c : integer;
begin
   SetLength(UndoRedo.Items,UndoRedo.num + 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames, 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items, (SHP.Header.Height * SHP.Header.Width) + 1);

   UndoRedo.Items[UndoRedo.Num].Width := 0;
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utSingleFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no;
   UndoRedo.Items[UndoRedo.num].Num := 1;


   c := -1;

   for x := 0 to SHP.Header.Width - 1 do
   for y := 0 to SHP.Header.Height - 1 do
   begin
      c := c + 1;
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].colour := SHP.Data[FrameImage_no].FrameImage[X,Y];
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].X := X;
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].Y := Y;
   end;

   UndoRedo.Items[UndoRedo.num].Frames[0].num := c + 1;
   UndoRedo.num := UndoRedo.num + 1;
end;


///---------------------------------------------
// AddToUndo : Store original pixels before modification.
//             Retrieves colors directly from FrameImage.
//             * before pasting selection
// PARAMS
//    UndoRedo       : Undo List
//    Shp            : Shp
//    FrameIndex     : Frame Index
//    Selection      : Selected Area
//---------------------------------------------
procedure AddToUndo(var UndoRedo : TUndoRedo; var Shp : TSHP; FrameIndex : integer; var Selection : TSelection); overload;
var
   x, y, i, j, c : integer;
   UndoFrameItem : TUndoRedo_Frames;
begin
   SetLength(UndoRedo.Items, UndoRedo.num + 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames, 1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items, (Selection.Width * Selection.Height)); 

   UndoRedo.Items[UndoRedo.Num].Width := 0;
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utSingleFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Num := 1;  


   // Init pixels
   c := 0;
   for i := 0 to Selection.Width - 1 do
   begin
      x := Selection.X + i;
      if( x < 0 ) or (x >= Shp.Header.Width ) then continue;

      for j := 0 to Selection.Height - 1 do
      begin
         y := Selection.Y + j;
         if (y < 0) or (y >= Shp.Header.Height) then continue;

         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].X := x;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].Y := y;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].Colour := Shp.Data[FrameIndex].FrameImage[x, y];
         inc(c);
      end;
   end;

   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameIndex;
   UndoRedo.Items[UndoRedo.num].Frames[0].Num := c;

   UndoRedo.num := UndoRedo.num + 1;
end;



// This one transfer the whole SHP file (used for Resize)
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP); overload;
var
x,y,z,c : integer;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,SHP.Header.NumImages);

   UndoRedo.Items[UndoRedo.Num].Width := SHP.Header.Width;
   UndoRedo.Items[UndoRedo.Num].Height := SHP.Header.Height;
   UndoRedo.Items[UndoRedo.Num].ItemType := utResize;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Num := SHP.Header.NumImages;

   for z:= 0 to (SHP.Header.NumImages-1) do
   begin
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[z].Items,(SHP.Header.Height*SHP.Header.Width)+1);
      UndoRedo.Items[UndoRedo.num].Frames[z].FrameID := z+1;

      c := 0;

      for x := 0 to SHP.Header.Width-1 do
      for y := 0 to SHP.Header.Height-1 do
      if SHP.Data[z+1].FrameImage[X,Y] <> 0 then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].colour := SHP.Data[z+1].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].Y := Y;
         c := c +1;
      end;

      UndoRedo.Items[UndoRedo.num].Frames[z].num := c;
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[z].Items,c);
   end;

   UndoRedo.num := UndoRedo.num+1;
end;


// add to undo, ranged situation... from start to final. (autoshadows)
procedure AddToUndo(var UndoRedo : TUndoRedo; const SHP:TSHP; Start,Final: word); overload;
var
x,y,z,c : integer;
temp : word;
begin
   if Final < Start then
   begin
      temp := final;
      final := start;
      start := temp;
   end;

   SetLength(UndoRedo.Items,UndoRedo.num+1);
   UndoRedo.Items[UndoRedo.Num].Width := 0;
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utMultiFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Num := Final - Start + 1;

   SetLength(UndoRedo.Items[UndoRedo.num].Frames,UndoRedo.Items[UndoRedo.num].Num);


   for z:= 0 to (Final - Start) do
   begin
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[z].Items,(SHP.Header.Height*SHP.Header.Width)+1);

      UndoRedo.Items[UndoRedo.num].Frames[z].FrameID := Start+z;

      c := 0;

      for x := 0 to SHP.Header.Width-1 do
      for y := 0 to SHP.Header.Height-1 do
      begin
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].colour := SHP.Data[Start+z].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[z].Items[c].Y := Y;
         c := c +1;
      end;

      UndoRedo.Items[UndoRedo.num].Frames[z].num := c;

   end;

   UndoRedo.num := UndoRedo.num+1;
end;


Procedure ClearUndo(var UndoList:TUndoRedo);
begin
   SetLength(UndoList.Items,0);
   UndoList.num := 0;
end;


// Insert a blank frame.
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; FrameImage_no : word); overload;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,0);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utAddFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no;
   UndoRedo.Items[UndoRedo.num].Frames[0].Num := 0;
   UndoRedo.Items[UndoRedo.Num].Num := 1;
   UndoRedo.num := UndoRedo.num+1;
end;


// Insert blank frame and its shadow.
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; FrameImage_no1,FrameImage_no2 : word); overload;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,2);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,0);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[1].Items,0);

   FrameImage_no2 := Min(FrameImage_no1,FrameImage_no2);
   FrameImage_no1 := Max(FrameImage_no1,FrameImage_no2);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utAddFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no1;
   UndoRedo.Items[UndoRedo.num].Frames[0].Num := 0;
   UndoRedo.Items[UndoRedo.num].Frames[1].FrameID := FrameImage_no2;
   UndoRedo.Items[UndoRedo.num].Frames[1].Num := 0;
   UndoRedo.Items[UndoRedo.Num].Num := 2;
   UndoRedo.num := UndoRedo.num+1;
end;


// Insert some consecutive blank frames.
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; StartFrame,EndFrame : word; flag : boolean); overload; // Flag is just a dummy thing to differentiate it from the previous function.
var
   Counter : word;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,EndFrame - StartFrame + 1);
   // Now, it will set the items from all frames
   for counter := 0 to (EndFrame - StartFrame) do
   begin
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[counter].Items,0);
      UndoRedo.Items[UndoRedo.num].Frames[counter].FrameID := EndFrame - counter;
      UndoRedo.Items[UndoRedo.num].Frames[counter].Num := 0;
   end;
   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utAddFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.Num].Num := EndFrame - StartFrame + 1;
   UndoRedo.num := UndoRedo.num+1;
end;


// Insert some consecutive blank frames with shadows.
procedure AddToUndoBlankFrame(var UndoRedo:TUndoRedo; StartFrame,EndFrame,StartShadowFrame : word); overload;
var
   Counter,FrameAmmount,EndShadowFrame : word;
begin
   FrameAmmount := EndFrame - StartFrame + 1;
   EndShadowFrame := StartShadowFrame + FrameAmmount - 1;

   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,FrameAmmount * 2);

   // Now, it will set the items from all frames
   for counter := 0 to (EndFrame - StartFrame) do
   begin
      // set shadow (first)
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[FrameAmmount + Counter].Items,0);
      UndoRedo.Items[UndoRedo.num].Frames[Counter].FrameID := EndShadowFrame - Counter;
      UndoRedo.Items[UndoRedo.num].Frames[Counter].Num := 0;
      // set active  (last)
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Counter].Items,0);
      UndoRedo.Items[UndoRedo.num].Frames[FrameAmmount + Counter].FrameID := EndFrame - Counter;
      UndoRedo.Items[UndoRedo.num].Frames[FrameAmmount + Counter].Num := 0;
   end;
   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utAddFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.Num].Num := FrameAmmount * 2;
   UndoRedo.num := UndoRedo.num+1;
end;


procedure StartUndoSwappedFrames(var UndoRedo:TUndoRedo; ItemAmmount : Integer);
begin
   if ItemAmmount <= 0 then exit;

   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,ItemAmmount);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utSwapFrames;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := 0;
   UndoRedo.Items[UndoRedo.num].Frames[0].Num := ItemAmmount;
   UndoRedo.Items[UndoRedo.Num].Num := 1;
   UndoRedo.num := UndoRedo.num+1;
end;


procedure StartUndoReversedFrames(var UndoRedo:TUndoRedo; ItemAmmount : Integer);
begin
   if ItemAmmount <= 0 then exit;

   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,ItemAmmount);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utReverseFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := 0;
   UndoRedo.Items[UndoRedo.num].Frames[0].Num := ItemAmmount;
   UndoRedo.Items[UndoRedo.Num].Num := 1;
   UndoRedo.num := UndoRedo.num+1;
end;


procedure AddToUndoReversedFrames(var UndoRedo: TUndoRedo; Item,Frame1,Frame2 : Integer);
begin
   UndoRedo.Items[UndoRedo.num-1].Frames[0].Items[Item].X := Frame1;
   UndoRedo.Items[UndoRedo.num-1].Frames[0].Items[Item].Y := Frame2;
end;


procedure AddToUndoRemovedFrame(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no : word); overload;
var
   c,x,y : integer;
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,(SHP.Header.Height*SHP.Header.Width)+1);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utDeleteFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no;

   c := -1;
   for x := 0 to SHP.Header.Width-1 do
   for y := 0 to SHP.Header.Height-1 do
      if SHP.Data[FrameImage_no].FrameImage[X,Y] <> 0 then
      begin
         c := c +1;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].colour := SHP.Data[FrameImage_no].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].Y := Y;
      end;

   UndoRedo.Items[UndoRedo.num].Frames[0].num := c+1;
   UndoRedo.Items[UndoRedo.Num].Num := 1;
   UndoRedo.num := UndoRedo.num+1;
end;


procedure AddToUndoRemovedFrame(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no1,FrameImage_no2 : word); overload;
var
   c,x,y : integer;
   temp: word;
begin
   // Set Lengths and stuff to prevent access violation
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,2);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[0].Items,(SHP.Header.Height*SHP.Header.Width)+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames[1].Items,(SHP.Header.Height*SHP.Header.Width)+1);

   // Check for data integrity to avoid future problems when undoing
   temp:= Min(FrameImage_no1,FrameImage_no2);
   FrameImage_no2 := Max(FrameImage_no1,FrameImage_no2);
   FrameImage_no1 := temp;

   // Specify sizes and hacking info for program inteligence
   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utDeleteFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;
   UndoRedo.Items[UndoRedo.num].Frames[0].FrameID := FrameImage_no1;
   UndoRedo.Items[UndoRedo.num].Frames[1].FrameID := FrameImage_no2;

   // fill removed frame (owner)
   c := -1;
   for x := 0 to SHP.Header.Width-1 do
   for y := 0 to SHP.Header.Height-1 do
   if SHP.Data[FrameImage_no1].FrameImage[X,Y] <> 0 then
   begin
      c := c +1;
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].colour := SHP.Data[FrameImage_no1].FrameImage[X,Y];
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].X := X;
      UndoRedo.Items[UndoRedo.num].Frames[0].Items[c].Y := Y;
   end;

   UndoRedo.Items[UndoRedo.num].Frames[0].num := c+1;

   // fill removed frame (shadow)
      c := -1;
   for x := 0 to SHP.Header.Width-1 do
   for y := 0 to SHP.Header.Height-1 do
   if SHP.Data[FrameImage_no2].FrameImage[X,Y] <> 0 then
   begin
      c := c +1;
      UndoRedo.Items[UndoRedo.num].Frames[1].Items[c].colour := SHP.Data[FrameImage_no2].FrameImage[X,Y];
      UndoRedo.Items[UndoRedo.num].Frames[1].Items[c].X := X;
      UndoRedo.Items[UndoRedo.num].Frames[1].Items[c].Y := Y;
   end;

   UndoRedo.Items[UndoRedo.num].Frames[1].num := c+1;
   // Final Stuff and Increase Item Count.
   UndoRedo.Items[UndoRedo.Num].Num := 2;
   UndoRedo.num := UndoRedo.num+1;
end;


///---------------------------------------------
// Add to Undo : Removed Frames
//---------------------------------------------
procedure AddToUndoRemovedFrames(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no,Ammount : word); overload;
var
   c,x,y : integer;
   Frame: word;
begin
   // Basic Setup
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,Ammount);
   // Frame Operations
   For Frame := 0 to (Ammount-1) do
   begin
      // Initial Frame Setup
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame].Items,(SHP.Header.Height*SHP.Header.Width)+1);
      UndoRedo.Items[UndoRedo.num].Frames[Frame].FrameID := FrameImage_no + Frame;
      // Copy Data to Frame
      c := 0;
      for x := 0 to SHP.Header.Width-1 do
      for y := 0 to SHP.Header.Height-1 do
      if SHP.Data[FrameImage_no + Frame].FrameImage[X,Y] <> 0 then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].colour := SHP.Data[FrameImage_no + Frame].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].Y := Y;
         inc(c);
      end;
      // Shrink it and set up space.
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame].Items,c);
      UndoRedo.Items[UndoRedo.num].Frames[Frame].num := c;
   end;
   // Final Undo Setup
   UndoRedo.Items[UndoRedo.Num].Width := 0;
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utDeleteFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;

   UndoRedo.Items[UndoRedo.Num].Num := Ammount;
   UndoRedo.num := UndoRedo.num+1;
end;


//---------------------------------------------
// Add to Undo : Removed Frames with Shadows
//---------------------------------------------
procedure AddToUndoRemovedFrames(var UndoRedo:TUndoRedo; const SHP:TSHP; FrameImage_no,ShadowImage_no,Ammount : word); overload;
var
   c,x,y : integer;
   Frame: word;
begin
   // Basic Setup
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,Ammount*2);
   // Frame Operations
   For Frame := 0 to (Ammount-1) do
   begin
      // Initial Frame Setup
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame].Items,(SHP.Header.Height*SHP.Header.Width)+1);
      UndoRedo.Items[UndoRedo.num].Frames[Frame].FrameID := FrameImage_no + Frame;
      // Initial Shadow Setup
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].Items,(SHP.Header.Height*SHP.Header.Width)+1);
      UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].FrameID := ShadowImage_no + Frame;
      // Copy Data to Frame
      c := 0;
      for x := 0 to SHP.Header.Width-1 do
      for y := 0 to SHP.Header.Height-1 do
      if SHP.Data[FrameImage_no + Frame].FrameImage[X,Y] <> 0 then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].colour := SHP.Data[FrameImage_no + Frame].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[Frame].Items[c].Y := Y;
         inc(c);
      end;
      // Shrink it and set up space.
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame].Items,c);
      UndoRedo.Items[UndoRedo.num].Frames[Frame].num := c;
      // Copy Data to Shadow
      c := 0;
      for x := 0 to SHP.Header.Width-1 do
      for y := 0 to SHP.Header.Height-1 do
      if SHP.Data[ShadowImage_no + Frame].FrameImage[X,Y] <> 0 then
      begin
         UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].Items[c].colour := SHP.Data[ShadowImage_no + Frame].FrameImage[X,Y];
         UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].Items[c].X := X;
         UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].Items[c].Y := Y;
         inc(c);
      end;
      // Shrink it and set up space.
      SetLength(UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].Items,c);
      UndoRedo.Items[UndoRedo.num].Frames[Frame+Ammount].num := c;
   end;
   // Final Undo Setup
   UndoRedo.Items[UndoRedo.Num].Width := 0;
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utDeleteFrame;
   UndoRedo.Items[UndoRedo.Num].ExternalLink := nil;

   UndoRedo.Items[UndoRedo.Num].Num := Ammount*2;
   UndoRedo.num := UndoRedo.num+1;
end;


///---------------------------------------------
// Add to undo : Multi frames ??
// PARAMS 
//    UndoRedo    : Undo List
//    Framenumber : Frame Count
//    xpos        : X
//    ypos        : Y
//    colour      : Colour
//---------------------------------------------
procedure AddToUndoMultiFrames(var UndoRedo : TUndoRedo; framenumber:word; xpos,ypos:smallint; colour:byte);
var
   lastframe,lastitem : cardinal;
begin

   // First case: Item was added, but has nothing
   if UndoRedo.Items[UndoRedo.Num-1].Num = 0 then
   begin // We will generate the first data of the item

      // Data To Simplify My Side
      lastframe := 0;
      lastitem := 0;

      // Set Length for changed arrays
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames,1);
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames[lastframe].Items,1);

      // Set Values of changed arrays
      UndoRedo.Items[UndoRedo.Num-1].Num := 1;
      UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Num := 1;

   end
   // Second Case: An item will be added in the same frame
   else if UndoRedo.Items[UndoRedo.Num-1].Frames[UndoRedo.Items[UndoRedo.Num-1].Num - 1].FrameID = framenumber then
   begin  // Only the item will be affected by the operations below

      // Data To Simplify My Side
      lastframe := UndoRedo.Items[UndoRedo.Num-1].Num - 1;
      lastitem := UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Num;

      // Set Length for changed arrays
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames[lastframe].Items,lastitem+1);

      // Set Values of changed arrays
      UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Num := lastitem+1;

   end

   // 3rd case: An item will be added in a different frame
   else
   begin  // Item will be reset, Frame will increase

      // Data To Simplify My Side
      lastframe := UndoRedo.Items[UndoRedo.Num-1].Num;
      lastitem := 0;

      // Set Length for changed arrays
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames,lastframe+1);
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames[lastframe].Items,1);

      // Set Values of changed arrays
      UndoRedo.Items[UndoRedo.Num-1].Num := lastframe+1;
      UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Num := 1;

   end;

   // Add Item values to the current Undo Item
   UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].FrameID := framenumber;
   UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Items[lastitem].X := xpos;
   UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Items[lastitem].Y := ypos;
   UndoRedo.Items[UndoRedo.Num-1].Frames[lastframe].Items[lastitem].Colour := colour;
end;


///---------------------------------------------
// Add to Undo : Multi frames ??
//---------------------------------------------
procedure AddToUndoMultiFramesB(var UndoRedo : TUndoRedo; framenumber:word; xpos,ypos:smallint; colour:byte);
var
   Frame : word;
   Item: longword;
   FrameExists : Boolean;
begin
   // Verify if the Frame[framenumber] exists.
   FrameExists := false;
   Frame := 0;
   while (Frame < UndoRedo.Items[UndoRedo.Num-1].Num) and (not FrameExists) do
   begin
      if UndoRedo.Items[UndoRedo.Num-1].Frames[Frame].FrameID = framenumber then
      begin
         FrameExists := true;
         dec(Frame);
      end;
      inc(Frame);
   end;

   if not FrameExists then
   begin
      // If the frame doesn't exist, we create it.
      inc(UndoRedo.Items[UndoRedo.Num-1].Num);
      SetLength(UndoRedo.Items[UndoRedo.num-1].Frames,Frame+1);
      UndoRedo.Items[UndoRedo.num-1].Frames[Frame].FrameID := framenumber;
   end;

   // Now make new item;
   Item := UndoRedo.Items[UndoRedo.Num-1].Frames[Frame].Num;
   inc(UndoRedo.Items[UndoRedo.Num-1].Frames[Frame].Num);
   SetLength(UndoRedo.Items[UndoRedo.num-1].Frames[Frame].Items,UndoRedo.Items[UndoRedo.Num-1].Frames[Frame].Num);
   UndoRedo.Items[UndoRedo.num-1].Frames[Frame].Items[Item].X := XPos;
   UndoRedo.Items[UndoRedo.num-1].Frames[Frame].Items[Item].Y := YPos;
   UndoRedo.Items[UndoRedo.num-1].Frames[Frame].Items[Item].Colour := Colour;
end;


// ===============================================
// UNDO ACTIONS
// ===============================================


///---------------------------------------------
// MAIN Undo Frame Edit
//---------------------------------------------
procedure UndoAction(var SHP : TSHP; var UndoRedo : TUndoRedo; var SizeChanged:Boolean);
begin
   if UndoRedo.num = 0 then exit; // no undo's


   case (UndoRedo.Items[UndoRedo.Num-1].ItemType) of
      utSingleFrame:
      begin
         UndoFrame(SHP, UndoRedo, 0);
      end;
      utMultiFrame:
      begin
         UndoFrames(SHP,UndoRedo);
      end;
      utResize:
      begin
         UndoResize(SHP,UndoRedo,SizeChanged);
         UndoFrames(SHP,UndoRedo);
      end;
      utAddFrame:
      begin
         UndoAddFrames(SHP,UndoRedo);
      end;
      utDeleteFrame:
      begin
         UndoDeleteFrames(SHP,UndoRedo);
      end;
      utReverseFrame:
      begin
         UndoReverseFrames(SHP,UndoRedo);
      end;
      utSwapFrames:
      begin
         UndoSwapFrames(SHP,UndoRedo);
      end;
   end; // End of case
   UndoRedo.num := UndoRedo.num-1; // Remove last undo.
end;


///---------------------------------------------
// Undo Resize
//---------------------------------------------
procedure UndoResize(var SHP : TSHP; var UndoRedo : TUndoRedo; var SizeChanged:Boolean);
var
   z : integer;
begin
   // Check if it's a resize case...
   if (UndoRedo.Items[UndoRedo.Num-1].Width <> 0) or (UndoRedo.Items[UndoRedo.Num-1].Height <> 0)  then
   begin
      SHP.Header.Width := UndoRedo.Items[UndoRedo.Num-1].Width;
      SHP.Header.Height := UndoRedo.Items[UndoRedo.Num-1].Height;
      SizeChanged := true;
      for z := 1 to SHP.Header.NumImages do
      begin
         SetLength(SHP.Data[z].FrameImage,SHP.Header.Width,SHP.Header.Height);
         // This is being used to avoid adding loads of
         // transparent items to RAM.
         ClearFrameImage(SHP,z);
      end;
   end;
end;


///---------------------------------------------
// Undo Frame Editing
//---------------------------------------------
procedure UndoFrame (var SHP: TSHP; UndoRedo : TUndoRedo; z : integer);
var
   x: integer;
begin
   if (UndoRedo.Items[UndoRedo.num - 1].Frames[z].num > 0) then
      for x := 0 to (UndoRedo.Items[UndoRedo.num - 1].Frames[z].num - 1) do
      begin
         with UndoRedo.Items[UndoRedo.num - 1].Frames[z] do
            SHP.Data[FrameID].FrameImage[Items[x].X, Items[x].Y] := Items[x].Colour;
      end;
end;


procedure UndoFrames (var SHP: TSHP; UndoRedo : TUndoRedo);
var
   Frame : Integer;
begin
   for Frame := 0 to (UndoRedo.Items[UndoRedo.num-1].num-1) do
       UndoFrame(SHP,UndoRedo,Frame);
end;

procedure UndoAddFrames (var SHP: TSHP; UndoRedo : TUndoRedo);
var
   Frame: Integer;
begin
   for Frame:= 0 to (UndoRedo.Items[UndoRedo.Num-1].Num - 1) do
   begin
      MoveFrameImagesDown(SHP,UndoRedo.Items[UndoRedo.Num-1].Frames[Frame].FrameID);
   end;
end;

procedure UndoDeleteFrames (var SHP: TSHP; UndoRedo : TUndoRedo);
var
   x,z : integer;
begin
   // z counts from first filled frame to the last frame. (this for will loop once or twice)
   for z:= {(UndoRedo.Items[UndoRedo.Num-1].Num div 2)}0 to (UndoRedo.Items[UndoRedo.Num-1].Num - 1) do
   begin
      // re add a frame at FrameID.
      MoveFrameImagesUp(SHP,UndoRedo.Items[UndoRedo.Num-1].Frames[z].FrameID-1);

      // Fill added frame.
      ClearFrameImage(SHP,UndoRedo.Items[UndoRedo.Num-1].Frames[z].FrameID);
      for x := 0 to UndoRedo.Items[UndoRedo.num-1].Frames[z].num-1 do
      begin
         with UndoRedo.Items[UndoRedo.num-1].Frames[z] do
            SHP.Data[FrameID].FrameImage[Items[x].X,Items[x].Y] := Items[x].colour;
      end;
   end;
end;

procedure UndoReverseFrames (var SHP : TSHP; UndoRedo : TUndoRedo);
var
   TempFrame : TFrameImage;
   z : integer;
   x,y : integer;
begin
   // Initialize it, so Delphi won't bitch about it.
   TempFrame := nil;
   // Scan all Items.
   for z := 0 to UndoRedo.Items[UndoRedo.Num-1].Frames[0].Num - 1 do
   begin
      // Reverse "Frame x" with "Frame y"
      SetLength(Tempframe,SHP.Header.Width,SHP.Header.Height);
      for x := 0 to SHP.Header.Width-1 do
         for y := 0 to SHP.Header.Height-1 do
         begin
            TempFrame[x,y] := SHP.Data[UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].X].FrameImage[x,y];
            SHP.Data[UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].X].FrameImage[x,y] := SHP.Data[UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].Y].FrameImage[x,y];
            SHP.Data[UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].Y].FrameImage[x,y] := TempFrame[x,y];
         end;
   end;
end;

procedure UndoSwapFrames (var SHP : TSHP; UndoRedo : TUndoRedo);
var
   z : integer;
begin
   // Scan all Items.
   for z := 0 to UndoRedo.Items[UndoRedo.Num-1].Frames[0].Num - 1 do
      SwapFrameImages(SHP,UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].X,UndoRedo.Items[UndoRedo.Num-1].Frames[0].Items[z].Y);
end;


function GetUndoStatus(const UndoList:TUndoRedo) : boolean;
begin
   If UndoList.Num = 0 then
      Result := false
   else
      Result := true;
end;

procedure GenerateNewUndoItem(var UndoRedo : TUndoRedo);
begin
   SetLength(UndoRedo.Items,UndoRedo.num+1);
   SetLength(UndoRedo.Items[UndoRedo.num].Frames,0);

   UndoRedo.Items[UndoRedo.Num].Width := 0; // default value for not changed
   UndoRedo.Items[UndoRedo.Num].Height := 0;
   UndoRedo.Items[UndoRedo.Num].Num := 0;
   UndoRedo.Items[UndoRedo.Num].ItemType := utMultiFrame;
   UndoRedo.num := UndoRedo.num+1;
end;


procedure NewUndoItemValidation(var UndoRedo : TUndoRedo);
begin
   if UndoRedo.Items[UndoRedo.Num-1].Num = 0 then
   begin
      SetLength(UndoRedo.Items,UndoRedo.num);
      UndoRedo.num := UndoRedo.num-1;
   end;
end;


end.
