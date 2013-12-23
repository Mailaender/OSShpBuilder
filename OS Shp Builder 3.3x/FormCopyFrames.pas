unit FormCopyFrames;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Spin, ExtCtrls, Math, SHP_File, Undo_Redo,
   SHP_Frame, FormCanvasResize, SHP_Canvas, SHP_Engine_Resize, Palette, XPMan;

type
   TDataList = array of pointer;

   TFrmCopyFrames = class(TForm)
      Bevel1:    TBevel;
      BtOK:      TButton;
      BtCancel:  TButton;
      Label1:    TLabel;
      Label2:    TLabel;
      SpFrom:    TSpinEdit;
      SpTo:      TSpinEdit;
      Label3:    TLabel;
      SpDestiny: TSpinEdit;
      LbPasteAtFile: TListBox;
      Label4:    TLabel;
      BtGoToEnd: TButton;
      BtGoToOne: TButton;
      CbCopyShadows: TCheckBox;
      GbResize:  TGroupBox;
      RbPixels:  TRadioButton;
      RbCanvas:  TRadioButton;
    XPManifest: TXPManifest;
      procedure FormCreate(Sender: TObject);
      procedure BtCancelClick(Sender: TObject);
      procedure BtGoToOneClick(Sender: TObject);
      procedure BtGoToEndClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure LbPasteAtFileClick(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure SpFromClick(Sender: TObject);
      procedure SpToClick(Sender: TObject);
      procedure SpDestinyClick(Sender: TObject);
      procedure RbPixelsClick(Sender: TObject);
      procedure RbCanvasClick(Sender: TObject);
      procedure CbCopyShadowsClick(Sender: TObject);
   private
      { Private declarations }
      DataList:   TDataList;
      Data_No:    integer;
      PLastFocus: ^TSpinEdit;
   public
      { Public declarations }
   end;

implementation

uses FormMain, SHP_DataMatrix;

{$R *.dfm}

procedure TFrmCopyFrames.FormCreate(Sender: TObject);
var
   Data: TSHPImageData;
begin
   // Fill the Paste To File part:
   Data    := MainData^.Next;
   Data_No := 0;
   while Data <> nil do
   begin
      // Add data option to user
      if Data^.Filename <> '' then
         LbPasteAtFile.Items.Add(Data^.Filename)
      else
         LbPasteAtFile.Items.Add('Untitled ' + IntToStr(Data^.ID));

      // Add data option to computer
      setlength(DataList, Data_No + 1);
      DataList[Data_No] := Data;
      Inc(Data_No);

      // go to the next data
      Data := Data^.Next;
   end;

   // Now it adds a "New SHP" option
   LbPasteAtFile.Items.Add('New SHP File');
   setlength(DataList, Data_No + 1);
   DataList[Data_No] := nil;
end;

procedure TFrmCopyFrames.FormShow(Sender: TObject);
begin
   // Setting up the default values on the spin edits
   spFrom.Value    := FrmMain.ActiveForm^.FrameIndex;
   spTo.Value      := FrmMain.ActiveForm^.FrameIndex;
   spFrom.Increment := 1;
   spTo.Increment  := 1;
   spDestiny.Increment := 1;
   spDestiny.Value := 1;
   spFrom.MinValue := 1;
   spFrom.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   spTo.MinValue   := 1;
   spTo.MaxValue   := FrmMain.ActiveData^.SHP.Header.NumImages;
   PLastFocus      := @spFrom;
   // Set up the Paste At File list
   LbPasteAtFile.ItemIndex := 0;
   LbPasteAtFileClick(Sender);
   // Set focus on From
   spFrom.SetFocus;
end;

procedure TFrmCopyFrames.BtGoToOneClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MinValue;
end;

procedure TFrmCopyFrames.BtGoToEndClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MaxValue;
end;

procedure TFrmCopyFrames.LbPasteAtFileClick(Sender: TObject);
var
   Data: TSHPImageData;
begin
   if lbPasteAtFile.ItemIndex < Data_No then
   begin
      Data := DataList[LbPasteAtFile.ItemIndex];
      spDestiny.Enabled := true;
      if (Data = FrmMain.ActiveData) and CbCopyShadows.Checked then
      begin
         spDestiny.MaxValue := (Data^.SHP.Header.NumImages div 2) + 1;
      end
      else
         spDestiny.MaxValue := Data^.SHP.Header.NumImages + 1;
      spDestiny.MinValue := 1;
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
end;

procedure TFrmCopyFrames.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmCopyFrames.BtOKClick(Sender: TObject);
var
   Data: TSHPImageData;
   Frame, MaxFrames, OldFrames, xb, yb, xe, ye, FromValue, ToValue: integer;
   ActiveFrameBuffer, ShadowFrameBuffer: array of TFrameImage;
   FrmCanvasResize: TFrmCanvasResize;
   x, y: integer;
begin
   // We start with a check up to see if the values are valid:
   FromValue := spFrom.Value;
   ToValue := spTo.Value;
   spFrom.Value := Min(FromValue,ToValue);
   spTo.Value := Max(FromValue,ToValue);
   MaxFrames    := spTo.Value - spFrom.Value + 1;
   // First, we detect the situation. If ItemIndex = Data_No,
   // then the user will create a new SHP
   if LbPasteAtFile.ItemIndex = Data_No then
   begin
      // Destiny is a new SHP
      if CbCopyShadows.Checked then
      begin
         AddNewSHPDataItem(Data, FrmMain.TotalImages, MaxFrames *
            2, FrmMain.ActiveData^.SHP.Header.Width, FrmMain.ActiveData^.SHP.Header.Height,
            FrmMain.ActiveData^.SHPPaletteFilename);
         // Copy contents with shadow
         for Frame := 1 to MaxFrames do
         begin
            for x := 0 to FrmMain.ActiveData^.SHP.Header.Width - 1 do
               for y := 0 to FrmMain.ActiveData^.SHP.Header.Height - 1 do
               begin
                  Data^.SHP.Data[Frame].FrameImage[x, y] :=
                     FrmMain.ActiveData^.SHP.Data[spFrom.Value - 1 + Frame].FrameImage[x, y];
                  Data^.SHP.Data[MaxFrames + Frame].FrameImage[x, y] :=
                     FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) +
                     spFrom.Value - 1 + Frame].FrameImage[x, y];
               end;
         end;
      end
      else
      begin
         AddNewSHPDataItem(Data, FrmMain.TotalImages, MaxFrames,
            FrmMain.ActiveData^.SHP.Header.Width, FrmMain.ActiveData^.SHP.Header.Height,
            FrmMain.ActiveData^.SHPPaletteFilename);
         // Copy contents without shadow
         for Frame := 1 to MaxFrames do
         begin
            for x := 0 to FrmMain.ActiveData^.SHP.Header.Width - 1 do
               for y := 0 to FrmMain.ActiveData^.SHP.Header.Height - 1 do
               begin
                  Data^.SHP.Data[Frame].FrameImage[x, y] :=
                     FrmMain.ActiveData^.SHP.Data[spFrom.Value - 1 + Frame].FrameImage[x, y];
               end;
         end;
      end;
      if FrmMain.GenerateNewWindow(Data) then
      begin
         LoadNewSHPImageSettings(Data, FrmMain.ActiveForm^);
      end
      else
      begin
         ClearUpData(Data);
         ShowMessage('MDI Error: Out of memory!');
         close;
      end;
   end
   else // copies from one document to an existing document
   begin
      // First step, we have to find out if the victim is
      // the source.
      Data := DataList[LbPasteAtFile.ItemIndex];
      // Set buffers
      setlength(ActiveFrameBuffer, MaxFrames);
      // Check if it will copy the shadows
      if CbCopyShadows.Checked then
      begin
         setlength(ShadowFrameBuffer, MaxFrames);
         // Copy contents with shadow to buffer
         for Frame := 0 to MaxFrames - 1 do
         begin
            SetLength(ActiveFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
               FrmMain.ActiveData^.SHP.Header.Height);
            SetLength(ShadowFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
               FrmMain.ActiveData^.SHP.Header.Height);
            for x := 0 to FrmMain.ActiveData^.SHP.Header.Width - 1 do
               for y := 0 to FrmMain.ActiveData^.SHP.Header.Height - 1 do
               begin
                  ActiveFrameBuffer[Frame, x, y] :=
                     FrmMain.ActiveData^.SHP.Data[spFrom.Value + Frame].FrameImage[x, y];
                  ShadowFrameBuffer[Frame, x, y] :=
                     FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) +
                     spFrom.Value + Frame].FrameImage[x, y];
               end;
         end;
         // Get OldFrames.
         OldFrames := Data^.SHP.Header.NumImages;
         // Add Undo Item
         AddToUndoBlankFrame(Data^.UndoList, spDestiny.Value, spDestiny.Value +
            MaxFrames - 1, (Data^.SHP.Header.NumImages div 2) + spDestiny.Value + MaxFrames - 1);
         // Generate blank frames
         MoveSeveralFrameImagesUp(Data^.SHP, spDestiny.Value, MaxFrames);
         MoveSeveralFrameImagesUp(Data^.SHP, (OldFrames div 2) +
            spDestiny.Value + MaxFrames, MaxFrames);
         if Data <> FrmMain.ActiveData then
         begin // It will copy from one document to another.
               // Alright, our first step is to find if they
               // have compatible dimensions. If they don't have
               // it, we will properly adapt it.
            if (FrmMain.ActiveData^.SHP.Header.Width <> Data^.SHP.Header.Width) or
               (FrmMain.ActiveData^.SHP.Header.Height <> Data^.SHP.Header.Height) then
            begin // Now, we'll check what the user has choosen
               if RbPixels.Checked then // Resize pixels
               begin
                  for Frame := 0 to MaxFrames - 1 do
                  begin
                     Resize_FrameImage_Blocky(
                        ActiveFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
                        FrmMain.ActiveData^.SHP.Header.Height, Data^.SHP.Header.Width, Data^.SHP.Header.Height);
                     Resize_FrameImage_Blocky(
                        ShadowFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
                        FrmMain.ActiveData^.SHP.Header.Height, Data^.SHP.Header.Width, Data^.SHP.Header.Height);
                  end;
               end
               else // Resize canvas
               begin
                  FrmCanvasResize := TFrmCanvasResize.Create(self);
                  FrmCanvasResize.Bitmap := nil;
                  FrmCanvasResize.FrameImage :=
                     FrmMain.ActiveData^.SHP.Data[FrmMain.Current_Frame.Value].FrameImage;
                  FrmCanvasResize.SHPPalette := FrmMain.ActiveData^.SHPPalette;
                  FrmCanvasResize.Height := Data^.SHP.Header.Height;
                  FrmCanvasResize.Width := Data^.SHP.Header.Width;
                  FrmCanvasResize.LockSize := True;
                  FrmCanvasResize.ShowModal;
                  if FrmCanvasResize.changed then
                  begin
                     xb := StrToIntDef(FrmCanvasResize.SpinL.Text, 0);
                     xe := StrToIntDef(FrmCanvasResize.SpinR.Text, 0);
                     yb := StrToIntDef(FrmCanvasResize.SpinT.Text, 0);
                     ye := StrToIntDef(FrmCanvasResize.SpinB.Text, 0);

                     if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
                     begin
                        for Frame := 0 to MaxFrames - 1 do
                        begin
                           CanvasResize(ActiveFrameBuffer[Frame],
                              FrmCanvasResize.Width, FrmCanvasResize.Height, -xb, -yb, xe, ye, 0);
                           CanvasResize(ShadowFrameBuffer[Frame],
                              FrmCanvasResize.Width, FrmCanvasResize.Height, -xb, -yb, xe, ye, 0);
                        end;
                     end;
                  end;
                  FrmCanvasResize.Release;
               end;
            end;
         end;
         // Paste buffer on blank frames
         for Frame := 0 to MaxFrames - 1 do
         begin
            for x := 0 to Data^.SHP.Header.Width - 1 do
               for y := 0 to Data^.SHP.Header.Height - 1 do
               begin
                  Data^.SHP.Data[spDestiny.Value + Frame].FrameImage[x, y] :=
                     ActiveFrameBuffer[Frame, x, y];
                  Data^.SHP.Data[(Data^.SHP.Header.NumImages div 2) +
                     spDestiny.Value + Frame].FrameImage[x, y] := ShadowFrameBuffer[Frame, x, y];
               end;
         end;
      end
      else // No shadows
      begin
         // Copy contents without shadow to buffer
         for Frame := 0 to MaxFrames - 1 do
         begin
            SetLength(ActiveFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
               FrmMain.ActiveData^.SHP.Header.Height);
            for x := 0 to FrmMain.ActiveData^.SHP.Header.Width - 1 do
               for y := 0 to FrmMain.ActiveData^.SHP.Header.Height - 1 do
                  ActiveFrameBuffer[Frame, x, y] :=
                     FrmMain.ActiveData^.SHP.Data[spFrom.Value + Frame].FrameImage[x, y];
         end;
         // Add Undo Item
         AddToUndoBlankFrame(Data^.UndoList, spDestiny.Value, spDestiny.Value +
            MaxFrames - 1, False);
         // Generate blank frames
         MoveSeveralFrameImagesUp(Data^.SHP, spDestiny.Value, MaxFrames);
         if Data <> FrmMain.ActiveData then
         begin // It will copy from one document to another.
               // Alright, our first step is to find if they
               // have compatible dimensions. If they don't have
               // it, we will properly adapt it.
            if (FrmMain.ActiveData^.SHP.Header.Width <> Data^.SHP.Header.Width) or
               (FrmMain.ActiveData^.SHP.Header.Height <> Data^.SHP.Header.Height) then
            begin // Now, we'll check what the user has choosen
               if RbPixels.Checked then // Resize pixels
               begin
                  for Frame := 0 to MaxFrames - 1 do
                  begin
                     Resize_FrameImage_Blocky(
                        ActiveFrameBuffer[Frame], FrmMain.ActiveData^.SHP.Header.Width,
                        FrmMain.ActiveData^.SHP.Header.Height, Data^.SHP.Header.Width, Data^.SHP.Header.Height);
                  end;
               end
               else // Resize canvas
               begin
                  FrmCanvasResize := TFrmCanvasResize.Create(self);
                  FrmCanvasResize.Bitmap := nil;
                  FrmCanvasResize.FrameImage :=
                     FrmMain.ActiveData^.SHP.Data[FrmMain.Current_Frame.Value].FrameImage;
                  FrmCanvasResize.SHPPalette := FrmMain.ActiveData^.SHPPalette;
                  FrmCanvasResize.Height := Data^.SHP.Header.Height;
                  FrmCanvasResize.Width := Data^.SHP.Header.Width;
                  FrmCanvasResize.LockSize := True;
                  FrmCanvasResize.ShowModal;
                  if FrmCanvasResize.changed then
                  begin
                     xb := StrToIntDef(FrmCanvasResize.SpinL.Text, 0);
                     xe := StrToIntDef(FrmCanvasResize.SpinR.Text, 0);
                     yb := StrToIntDef(FrmCanvasResize.SpinT.Text, 0);
                     ye := StrToIntDef(FrmCanvasResize.SpinB.Text, 0);

                     if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
                     begin
                        for Frame := 0 to MaxFrames - 1 do
                           CanvasResize(ActiveFrameBuffer[Frame],
                              FrmCanvasResize.Width, FrmCanvasResize.Height, -xb, -yb, xe, ye, 0);
                     end;
                  end;
                  FrmCanvasResize.Release;
               end;
            end;
         end;
         // Paste buffer on blank frames
         for Frame := 0 to MaxFrames - 1 do
         begin
            for x := 0 to Data^.SHP.Header.Width - 1 do
               for y := 0 to Data^.SHP.Header.Height - 1 do
                  Data^.SHP.Data[spDestiny.Value + Frame].FrameImage[x, y] :=
                     ActiveFrameBuffer[Frame, x, y];
         end;
      end;
      FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode);
      // Fakes a shadow change so frame lengths are set
      FrmMain.UndoUpdate(Data^.UndoList);
   end;
   Close;
end;

procedure TFrmCopyFrames.SpFromClick(Sender: TObject);
begin
   PLastFocus := @spFrom;
end;

procedure TFrmCopyFrames.SpToClick(Sender: TObject);
begin
   PLastFocus := @spTo;
end;

procedure TFrmCopyFrames.SpDestinyClick(Sender: TObject);
begin
   PLastFocus := @spDestiny;
end;

procedure TFrmCopyFrames.RbPixelsClick(Sender: TObject);
begin
   RbPixels.Checked := True;
   RbCanvas.Checked := False;
end;

procedure TFrmCopyFrames.RbCanvasClick(Sender: TObject);
begin
   RbPixels.Checked := False;
   RbCanvas.Checked := True;
end;

procedure TFrmCopyFrames.CbCopyShadowsClick(Sender: TObject);
var
   Data: TSHPImageData;
begin
   if CbCopyShadows.Checked then
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages div 2
   else
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   if spTo.Value >= spTo.MaxValue then
      spTo.Value := spTo.MaxValue;

   if LbPasteAtFile.ItemIndex <> Data_No then
   begin
      Data := DataList[LbPasteAtFile.ItemIndex];
      if (Data = FrmMain.ActiveData) and CbCopyShadows.Checked then
      begin
         spDestiny.MaxValue := (Data^.SHP.Header.NumImages div 2) + 1;
      end
      else
         spDestiny.MaxValue := (Data^.SHP.Header.NumImages) + 1;
   end
   else
      spDestiny.MaxValue := 1;

   if spDestiny.Value >= spDestiny.MaxValue then
      spDestiny.Value := spDestiny.MaxValue;

end;

end.
