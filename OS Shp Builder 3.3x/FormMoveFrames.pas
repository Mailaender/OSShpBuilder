unit FormMoveFrames;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, Math, SHP_File, Undo_Redo,
  SHP_Frame, FormCanvasResize, SHP_Canvas, SHP_Engine_Resize, Palette, SHP_DataMatrix,
  XPMan;

type
  TDataList = array of pointer;
  TMoveProc = procedure (var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);


  TFrmMoveFrames = class(TForm)
    SpFrom: TSpinEdit;
    SpTo: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    BtGoToOne: TButton;
    BtGoToEnd: TButton;
    SpDestiny: TSpinEdit;
    Label3: TLabel;
    CbCopyShadows: TCheckBox;
    GbResize: TGroupBox;
    RbPixels: TRadioButton;
    RbCanvas: TRadioButton;
    LbPasteAtFile: TListBox;
    Label4: TLabel;
    Bevel1: TBevel;
    BtCancel: TButton;
    BtOK: TButton;
    XPManifest: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LbPasteAtFileClick(Sender: TObject);
    procedure SpFromClick(Sender: TObject);
    procedure SpToClick(Sender: TObject);
    procedure SpDestinyClick(Sender: TObject);
    procedure BtGoToOneClick(Sender: TObject);
    procedure BtGoToEndClick(Sender: TObject);
    procedure CbCopyShadowsClick(Sender: TObject);
    procedure RbPixelsClick(Sender: TObject);
    procedure RbCanvasClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure SetMoveProcedure;
  private
    { Private declarations }
    DataList : TDataList;
    Data_No : Integer;
    PLastFocus : ^TSpinEdit;
    MoveSHP : TMoveProc;
  public
    { Public declarations }
  end;

  // These functions will make the move easier to code.
  procedure MoveToTheSameSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
  procedure MoveToTheSameSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
  procedure MoveToADifferentSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
  procedure MoveToADifferentSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
  procedure MoveToANewSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
  procedure MoveToANewSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);


implementation

Uses FormMain;
{$R *.dfm}

procedure TFrmMoveFrames.SetMoveProcedure;
var
    Data : TSHPImageData;
begin
   if lbPasteAtFile.ItemIndex = Data_No then
   begin // New file
      if CbCopyShadows.Checked then
      begin
         MoveSHP := MoveToANewSHPWithShadows;
      end
      else
      begin
         MoveSHP := MoveToANewSHPWithoutShadows;
      end;
   end
   else
   begin
      Data := DataList[LbPasteAtFile.ItemIndex];
      if Data = FrmMain.ActiveData then
      begin // Same SHP
         if CbCopyShadows.Checked then
         begin
            MoveSHP := MoveToTheSameSHPWithShadows;
         end
         else
         begin
            MoveSHP := MoveToTheSameSHPWithoutShadows;
         end;
      end
      else
      begin // Different SHP
         if CbCopyShadows.Checked then
         begin
            MoveSHP := MoveToADifferentSHPWithShadows;
         end
         else
         begin
            MoveSHP := MoveToADifferentSHPWithoutShadows;
         end;
      end;
   end;
end;

procedure TFrmMoveFrames.FormCreate(Sender: TObject);
var
   Data : TSHPImageData;
begin
   // Fill the Paste To File part:
   Data := MainData^.Next;
   Data_No := 0;
   while Data <> nil do
   begin
      // Add data option to user
      if Data^.Filename <> '' then
         LbPasteAtFile.Items.Add(Data^.Filename)
      else
         LbPasteAtFile.Items.Add('Untitled ' + inttostr(Data^.ID));

      // Add data option to computer
      setlength(DataList,Data_No+1);
      DataList[Data_No] := Data;
      inc(Data_No);

      // go to the next data
      Data := Data^.Next;
   end;

   // Now it adds a "New SHP" option
   LbPasteAtFile.Items.Add('New SHP File');
   setlength(DataList,Data_No+1);
   DataList[Data_No] := nil;
end;

procedure TFrmMoveFrames.FormShow(Sender: TObject);
begin
   // Setting up the default values on the spin edits
   spFrom.Value := FrmMain.ActiveForm^.FrameIndex;
   spTo.Value := FrmMain.ActiveForm^.FrameIndex;
   spFrom.Increment := 1;
   spTo.Increment := 1;
   spDestiny.Increment := 1;
   spDestiny.Value := 1;
   spFrom.MinValue := 1;
   spFrom.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   spTo.MinValue := 1;
   spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   PLastFocus := @spFrom;
   // Set up the Paste At File list
   LbPasteAtFile.ItemIndex := 0;
   LbPasteAtFileClick(sender);
   // Set focus on From
   spFrom.SetFocus;
end;

procedure TFrmMoveFrames.LbPasteAtFileClick(Sender: TObject);
var
   Data : TSHPImageData;
begin
   if lbPasteAtFile.ItemIndex < Data_No then
   begin
      Data := DataList[LbPasteAtFile.ItemIndex];
      spDestiny.Enabled := true;
      spDestiny.MinValue := 1;
      if cbCopyShadows.Checked and (Data = FrmMain.ActiveData) then
         spDestiny.MaxValue := (Data^.SHP.Header.NumImages div 2) + 1
      else
         spDestiny.MaxValue := Data^.SHP.Header.NumImages + 1;
   end
   else
   begin
      spDestiny.MinValue := 1;
      spDestiny.MaxValue := 1;
      spDestiny.Value := 1;
      spDestiny.Enabled := false;
   end;

   if spDestiny.Value > spDestiny.MaxValue then
      spDestiny.Value := spDestiny.MaxValue;
   if spDestiny.Value < 1 then
      spDestiny.Value := 1;

   SetMoveProcedure;
end;

procedure TFrmMoveFrames.SpFromClick(Sender: TObject);
begin
   PLastFocus := @spFrom;
end;

procedure TFrmMoveFrames.SpToClick(Sender: TObject);
begin
   PLastFocus := @spTo;
end;

procedure TFrmMoveFrames.SpDestinyClick(Sender: TObject);
begin
   PLastFocus := @spDestiny;
end;

procedure TFrmMoveFrames.BtGoToOneClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MinValue;
end;

procedure TFrmMoveFrames.BtGoToEndClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MaxValue;
end;

procedure TFrmMoveFrames.CbCopyShadowsClick(Sender: TObject);
begin
   if CbCopyShadows.Checked then
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages div 2
   else
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   if spTo.Value >= spTo.MaxValue then
      spTo.Value := spTo.MaxValue;
   LbPasteAtFileClick(Sender);
end;

procedure TFrmMoveFrames.RbPixelsClick(Sender: TObject);
begin
   RbPixels.Checked := true;
   RbCanvas.Checked := false;
end;

procedure TFrmMoveFrames.RbCanvasClick(Sender: TObject);
begin
   RbPixels.Checked := false;
   RbCanvas.Checked := true;
end;

procedure MoveToTheSameSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   ActiveFrameBuffer,ShadowFrameBuffer : array of TFrameImage;
   OldFrames : longword;
   Frame : word;
   x,y : Integer;
begin
   // Set buffers
   setlength(ActiveFrameBuffer,MaxFrames);
   setlength(ShadowFrameBuffer,MaxFrames);
   // Copy contents with shadow to buffer
   For Frame := 0 to MaxFrames-1 do
   begin
      SetLength(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      SetLength(ShadowFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
         begin
            ActiveFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[From + Frame].FrameImage[x,y];
            ShadowFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From + Frame].FrameImage[x,y];
         end;
   end;

   // Get OldFrames.
   OldFrames := Data^.SHP.Header.NumImages;

   // Add Undo Item
   StartUndoSwappedFrames(FrmMain.ActiveData^.UndoList,MaxFrames*2);
   for Frame := 0 to MaxFrames-1 do
   begin
      // Exchange Normal frames
      AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,Frame,From + Frame,Destiny + Frame);
      // Exchange Shadow frames
      AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,MaxFrames + Frame,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From + Frame,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + Destiny + Frame);
   end;

   // Paste buffer on blank frames
   For Frame := 0 to MaxFrames-1 do
   begin
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
         begin
            FrmMain.ActiveData^.SHP.Data[Destiny + Frame].FrameImage[x,y] := ActiveFrameBuffer[Frame,x,y];
            FrmMain.ActiveData^.SHP.Data[(Data^.SHP.Header.NumImages div 2) + Destiny + Frame].FrameImage[x,y] := ShadowFrameBuffer[Frame,x,y];
         end;
   end;

   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(Data^.UndoList);
end;

procedure MoveToTheSameSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   ActiveFrameBuffer : array of TFrameImage;
   Frame,NewDestiny : word;
   x,y: integer;
begin
   // Set buffers
   setlength(ActiveFrameBuffer,MaxFrames);
   // Copy contents with shadow to buffer
   For Frame := 0 to MaxFrames-1 do
   begin
      SetLength(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            ActiveFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[From + Frame].FrameImage[x,y];
   end;

   // Now exclude original content from ActiveData
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,From,MaxFrames);

   // Fix to avoid problems with MoveSeveralFramesDown action above
   if Destiny > From then
      NewDestiny := Destiny - MaxFrames
   else
      NewDestiny := Destiny;

   // Generate blank frames
   MoveSeveralFrameImagesUp(FrmMain.ActiveData^.SHP,NewDestiny,MaxFrames);

   // Add Undo Item
   StartUndoSwappedFrames(FrmMain.ActiveData^.UndoList,MaxFrames);
   for Frame := 0 to MaxFrames-1 do
   begin
      // Exchange Normal frames
      AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,Frame,From + Frame,Destiny + Frame);
   end;

   // Paste buffer on blank frames
   For Frame := 0 to MaxFrames-1 do
   begin
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            FrmMain.ActiveData^.SHP.Data[Destiny + Frame].FrameImage[x,y] := ActiveFrameBuffer[Frame,x,y];
   end;

   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(Data^.UndoList);
end;

procedure MoveToADifferentSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   ActiveFrameBuffer,ShadowFrameBuffer : array of TFrameImage;
   OldFrames: longword;
   xb,yb,xe,ye : integer;
   x,y: integer;
   Frame : word;
   FrmCanvasResize : TFrmCanvasResize;
begin
   // Set buffers
   setlength(ActiveFrameBuffer,MaxFrames);
   setlength(ShadowFrameBuffer,MaxFrames);
   // Copy contents with shadow to buffer
   For Frame := 0 to MaxFrames-1 do
   begin
      SetLength(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      SetLength(ShadowFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
         begin
            ActiveFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[From + Frame].FrameImage[x,y];
            ShadowFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From + Frame].FrameImage[x,y];
         end;
   end;
   // Get OldFrames.
   OldFrames := Data^.SHP.Header.NumImages;
   // Add Undo Item
   AddToUndoBlankFrame(Data^.UndoList,Destiny,Destiny + MaxFrames - 1,(Data^.SHP.Header.NumImages div 2) + Destiny + MaxFrames - 1);
   AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,From,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From,MaxFrames);
   // Now exclude original content from ActiveData
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From,MaxFrames);
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,From,MaxFrames);
   // Generate blank frames
   MoveSeveralFrameImagesUp(Data^.SHP,Destiny,MaxFrames);
   MoveSeveralFrameImagesUp(Data^.SHP,(OldFrames div 2) + Destiny + MaxFrames,MaxFrames);

   // Check if the size of the frames are different
   if (FrmMain.ActiveData^.SHP.Header.Width <> Data^.SHP.Header.Width) or (FrmMain.ActiveData^.SHP.Header.Height <> Data^.SHP.Header.Height) then
   begin // Now, we'll check what the user has choosen
      if ResizeType then // Resize pixels
      begin
         For Frame := 0 to MaxFrames-1 do
         begin
            Resize_FrameImage_Blocky(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height,Data^.SHP.Header.Width,Data^.SHP.Header.Height);
            Resize_FrameImage_Blocky(ShadowFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height,Data^.SHP.Header.Width,Data^.SHP.Header.Height);
         end;
      end
      else // Resize canvas
      begin
         FrmCanvasResize := TFrmCanvasResize.Create(nil);
         FrmCanvasResize.Bitmap := nil;
         FrmCanvasResize.FrameImage := FrmMain.ActiveData^.SHP.Data[FrmMain.Current_Frame.Value].FrameImage;
         FrmCanvasResize.SHPPalette := FrmMain.ActiveData^.SHPPalette;
         FrmCanvasResize.Height := Data^.SHP.Header.Height;
         FrmCanvasResize.Width := Data^.SHP.Header.Width;
         FrmCanvasResize.LockSize := true;
         FrmCanvasResize.ShowModal;
         if FrmCanvasResize.changed then
         begin
            xb := StrToIntDef(FrmCanvasResize.SpinL.text,0);
            xe := StrToIntDef(FrmCanvasResize.SpinR.Text,0);
            yb := StrToIntDef(FrmCanvasResize.SpinT.Text,0);
            ye := StrToIntDef(FrmCanvasResize.SpinB.Text,0);

            if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
            begin
               For Frame := 0 to MaxFrames-1 do
               begin
                  CanvasResize(ActiveFrameBuffer[Frame],FrmCanvasResize.Width,FrmCanvasResize.Height,-xb,-yb,xe,ye,0);
                  CanvasResize(ShadowFrameBuffer[Frame],FrmCanvasResize.Width,FrmCanvasResize.Height,-xb,-yb,xe,ye,0);
               end;
            end;
         end;
         FrmCanvasResize.Release;
      end;
   end;
   // Paste buffer on blank frames
   For Frame := 0 to MaxFrames-1 do
   begin
      for x := 0 to Data^.SHP.Header.Width-1 do
         for y := 0 to Data^.SHP.Header.Height-1 do
         begin
            Data^.SHP.Data[Destiny + Frame].FrameImage[x,y] := ActiveFrameBuffer[Frame,x,y];
            Data^.SHP.Data[(Data^.SHP.Header.NumImages div 2) + Destiny + Frame].FrameImage[x,y] := ShadowFrameBuffer[Frame,x,y];
         end;
   end;

   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(Data^.UndoList);
end;

procedure MoveToADifferentSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   ActiveFrameBuffer : array of TFrameImage;
   xb,yb,xe,ye : integer;
   x,y: integer;
   Frame : word;
   FrmCanvasResize : TFrmCanvasResize;
begin
   // Set buffers
   setlength(ActiveFrameBuffer,MaxFrames);
   // Copy contents with shadow to buffer
   For Frame := 0 to MaxFrames-1 do
   begin
      SetLength(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            ActiveFrameBuffer[Frame,x,y] := FrmMain.ActiveData^.SHP.Data[From + Frame].FrameImage[x,y];
   end;
   // Add Undo Item
   AddToUndoBlankFrame(Data^.UndoList,Destiny,Destiny + MaxFrames - 1);
   AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,From,MaxFrames);
   // Now exclude original content from ActiveData
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,From,MaxFrames);
   // Generate blank frames
   MoveSeveralFrameImagesUp(Data^.SHP,Destiny,MaxFrames);

   // Check if the size of the frames are different
   if (FrmMain.ActiveData^.SHP.Header.Width <> Data^.SHP.Header.Width) or (FrmMain.ActiveData^.SHP.Header.Height <> Data^.SHP.Header.Height) then
   begin // Now, we'll check what the user has choosen
      if ResizeType then // Resize pixels
      begin
         For Frame := 0 to MaxFrames-1 do
         begin
            Resize_FrameImage_Blocky(ActiveFrameBuffer[Frame],FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height,Data^.SHP.Header.Width,Data^.SHP.Header.Height);
         end;
      end
      else // Resize canvas
      begin
         FrmCanvasResize := TFrmCanvasResize.Create(nil);
         FrmCanvasResize.Bitmap := nil;
         FrmCanvasResize.FrameImage := FrmMain.ActiveData^.SHP.Data[FrmMain.Current_Frame.Value].FrameImage;
         FrmCanvasResize.SHPPalette := FrmMain.ActiveData^.SHPPalette;
         FrmCanvasResize.Height := Data^.SHP.Header.Height;
         FrmCanvasResize.Width := Data^.SHP.Header.Width;
         FrmCanvasResize.LockSize := true;
         FrmCanvasResize.ShowModal;
         if FrmCanvasResize.changed then
         begin
            xb := StrToIntDef(FrmCanvasResize.SpinL.text,0);
            xe := StrToIntDef(FrmCanvasResize.SpinR.Text,0);
            yb := StrToIntDef(FrmCanvasResize.SpinT.Text,0);
            ye := StrToIntDef(FrmCanvasResize.SpinB.Text,0);

            if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
            begin
               For Frame := 0 to MaxFrames-1 do
               begin
                  CanvasResize(ActiveFrameBuffer[Frame],FrmCanvasResize.Width,FrmCanvasResize.Height,-xb,-yb,xe,ye,0);
               end;
            end;
         end;
         FrmCanvasResize.Release;
      end;
   end;
   // Paste buffer on blank frames
   For Frame := 0 to MaxFrames-1 do
   begin
      for x := 0 to Data^.SHP.Header.Width-1 do
         for y := 0 to Data^.SHP.Header.Height-1 do
            Data^.SHP.Data[Destiny + Frame].FrameImage[x,y] := ActiveFrameBuffer[Frame,x,y];
   end;

   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(Data^.UndoList);
end;

procedure MoveToANewSHPWithShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   Frame : word;
   x,y: integer;
begin
   AddNewSHPDataItem(Data,FrmMain.TotalImages,MaxFrames * 2,FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height,FrmMain.ActiveData^.SHPPaletteFilename);
   // Copy contents with shadow
   For Frame := 1 to MaxFrames do
   begin
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
         begin
            Data^.SHP.Data[Frame].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[From - 1 + Frame].FrameImage[x,y];
            Data^.SHP.Data[MaxFrames + Frame].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From - 1 + Frame].FrameImage[x,y];
         end;
   end;
   // Add the operation to undo from the activedata
   AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,From,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From,MaxFrames);
   // Now exclude original content from ActiveData
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + From,MaxFrames);
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,From,MaxFrames);

   if FrmMain.GenerateNewWindow(Data) then
   begin
      LoadNewSHPImageSettings(Data,FrmMain.ActiveForm^);
   end
   else
   begin
      ClearUpData(Data);
      ShowMessage('MDI Error! Out of memory!');
   end;
end;

procedure MoveToANewSHPWithoutShadows(var Data: TSHPImageData; const MaxFrames,From,Destiny : integer; const ResizeType: Boolean);
var
   Frame : word;
   x,y: integer;
begin
   AddNewSHPDataItem(Data,FrmMain.TotalImages,MaxFrames,FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height,FrmMain.ActiveData^.SHPPaletteFilename);
   // Copy contents without shadow
   For Frame := 1 to MaxFrames do
   begin
      for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
         for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            Data^.SHP.Data[Frame].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[From - 1 + Frame].FrameImage[x,y];
   end;
   // Add the operation to undo from the activedata
   AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,From,MaxFrames);
   // Now we exclude the copied frames from the ActiveData
   MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,From,MaxFrames);

   if FrmMain.GenerateNewWindow(Data) then
   begin
      LoadNewSHPImageSettings(Data,FrmMain.ActiveForm^);
   end
   else
   begin
      ClearUpData(Data);
      ShowMessage('MDI Error! Out of memory!');
   end;
end;


procedure TFrmMoveFrames.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmMoveFrames.BtOKClick(Sender: TObject);
var
   Data : TSHPImageData;
   MaxFrames,FromValue,ToValue : Integer;
begin
   // We start with a check up to see if the values are valid:
   FromValue := spFrom.Value;
   ToValue := spTo.Value;
   spFrom.Value := Min(FromValue,ToValue);
   spTo.Value := Max(FromValue,ToValue);
   MaxFrames := spTo.Value - spFrom.Value + 1;
   Data := DataList[LbPasteAtFile.ItemIndex];
   // Beta 12: Let's check if we can actually move the content without killing
   // the current image.
   if MaxFrames < FrmMain.ActiveData^.SHP.Header.NumImages then
   begin
      // And time for action. MoveSHP is a pointer to the correct procedure
      MoveSHP(Data,MaxFrames,spFrom.Value,spTo.Value,RbPixels.Checked);
      close;
   end
   else
   begin
      ShowMessage('Error: You cannot move all frames at once. Be aware that Move Frames do delete the original frames, while features such as Copy Frames leave them intact.');
   end;
end;

end.
