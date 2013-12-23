unit FormReverseFrames;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, SHP_File, Math, Undo_Redo, XPMan;

type
  TFrmReverseFrames = class(TForm)
    Label1: TLabel;
    spFrom: TSpinEdit;
    spTo: TSpinEdit;
    Label2: TLabel;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    CbShadow: TCheckBox;
    BtToOne: TButton;
    BtToEnd: TButton;
    XPManifest: TXPManifest;
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure CbShadowClick(Sender: TObject);
    procedure BtToOneClick(Sender: TObject);
    procedure BtToEndClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spFromClick(Sender: TObject);
    procedure spToClick(Sender: TObject);
  private
    { Private declarations }
    PLastFocus : ^TSpinEdit;
  public
    { Public declarations }
  end;

implementation

uses FormMain;
{$R *.dfm}


procedure TFrmReverseFrames.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmReverseFrames.BtOKClick(Sender: TObject);
var
   TempFrame : TFrameImage;
   FrameCounter,MaxFrames, FromValue, ToValue : Integer;
   x,y : integer;
begin
   // We start with a check up to see if the values are valid:
   FromValue := spFrom.Value;
   ToValue := spTo.Value;
   spFrom.Value := Min(FromValue,ToValue);
   spTo.Value := Max(FromValue,ToValue);
   MaxFrames := (spTo.Value - spFrom.Value + 1) div 2;
   // Check if it goes with shadows or not.
   if CbShadow.Checked then
   begin
      StartUndoReversedFrames(FrmMain.ActiveData^.UndoList,MaxFrames*2);
      // Now, we proceed with a loop to change pair of frames.
      for FrameCounter := 0 to MaxFrames-1 do
      begin
         // Exchange Normal frames
         AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,FrameCounter,spFrom.Value + FrameCounter,spTo.Value - FrameCounter);
         SetLength(TempFrame,FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
         for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
            for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            begin
               TempFrame[x,y] := FrmMain.ActiveData^.SHP.Data[spFrom.Value + FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[spFrom.Value + FrameCounter].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[spTo.Value - FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[spTo.Value - FrameCounter].FrameImage[x,y] := TempFrame[x,y];
            end;

         // Exchange Shadow frames
         AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,MaxFrames + FrameCounter,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spFrom.Value + FrameCounter,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spTo.Value - FrameCounter);
         SetLength(TempFrame,FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
         for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
            for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            begin
               TempFrame[x,y] := FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spFrom.Value + FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spFrom.Value + FrameCounter].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spTo.Value - FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spTo.Value - FrameCounter].FrameImage[x,y] := TempFrame[x,y];
            end;
      end;
   end
   else
   begin
      StartUndoReversedFrames(FrmMain.ActiveData^.UndoList,MaxFrames);
      // Now, we proceed with a loop to change pair of frames.
      for FrameCounter := 0 to MaxFrames-1 do
      begin
         AddToUndoReversedFrames(FrmMain.ActiveData^.UndoList,FrameCounter,spFrom.Value + FrameCounter,spTo.Value - FrameCounter);
         SetLength(TempFrame,FrmMain.ActiveData^.SHP.Header.Width,FrmMain.ActiveData^.SHP.Header.Height);
         for x := 0 to FrmMain.ActiveData^.SHP.Header.Width-1 do
            for y := 0 to FrmMain.ActiveData^.SHP.Header.Height-1 do
            begin
               TempFrame[x,y] := FrmMain.ActiveData^.SHP.Data[spFrom.Value + FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[spFrom.Value + FrameCounter].FrameImage[x,y] := FrmMain.ActiveData^.SHP.Data[spTo.Value - FrameCounter].FrameImage[x,y];
               FrmMain.ActiveData^.SHP.Data[spTo.Value - FrameCounter].FrameImage[x,y] := TempFrame[x,y];
            end;
      end;
   end;
   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(FrmMain.ActiveData^.UndoList);
   close;
end;

procedure TFrmReverseFrames.CbShadowClick(Sender: TObject);
begin
   if CbShadow.Checked then
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages div 2
   else
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   if spTo.Value >= spTo.MaxValue then
      spTo.Value := spTo.MaxValue;
end;

procedure TFrmReverseFrames.BtToOneClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MinValue;
end;

procedure TFrmReverseFrames.BtToEndClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MaxValue;
end;

procedure TFrmReverseFrames.FormShow(Sender: TObject);
begin
   // Setting up the default values on the spin edits
   spFrom.Value := FrmMain.ActiveForm^.FrameIndex;
   spTo.Value := FrmMain.ActiveForm^.FrameIndex;
   spFrom.Increment := 1;
   spTo.Increment := 1;
   spFrom.MinValue := 1;
   spFrom.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   spTo.MinValue := 1;
   spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   PLastFocus := @spFrom;
   // Set focus on From
   spFrom.SetFocus;
end;

procedure TFrmReverseFrames.spFromClick(Sender: TObject);
begin
   PLastFocus := @spFrom;
end;

procedure TFrmReverseFrames.spToClick(Sender: TObject);
begin
   PLastFocus := @spTo;
end;

end.
