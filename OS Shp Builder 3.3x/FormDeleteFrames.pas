unit FormDeleteFrames;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, SHP_File, Math, Undo_Redo, SHP_Frame, XPMan;

type
  TFrmDeleteFrames = class(TForm)
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


procedure TFrmDeleteFrames.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmDeleteFrames.BtOKClick(Sender: TObject);
var
   MaxFrames,FromValue,ToValue : Integer;
begin
   // We start with a check up to see if the values are valid:
   FromValue := spFrom.Value;
   ToValue := spTo.Value;
   spFrom.Value := Min(FromValue,ToValue);
   spTo.Value := Max(FromValue,ToValue);
   MaxFrames := spTo.Value - spFrom.Value + 1;
   // Check if it goes with shadows or not.
   if CbShadow.Checked then
   begin
      if (MaxFrames*2) = FrmMain.ActiveData^.SHP.Header.NumImages then
      begin
         ShowMessage('Error: An SHP must have one or more frames.');
         exit;
      end;
      AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,spFrom.Value,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spFrom.Value,MaxFrames);
      // Now exclude original content from ActiveData
      MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,(FrmMain.ActiveData^.SHP.Header.NumImages div 2) + spFrom.Value,MaxFrames);
      MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,spFrom.Value,MaxFrames);
   end
   else
   begin
      if MaxFrames = FrmMain.ActiveData^.SHP.Header.NumImages then
      begin
         ShowMessage('Error: An SHP must have one or more frames.');
         exit;
      end;
      AddToUndoRemovedFrames(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,spFrom.Value,MaxFrames);
      // Now exclude original content from ActiveData
      MoveSeveralFrameImagesDown(FrmMain.ActiveData^.SHP,spFrom.Value,MaxFrames);
   end;
   FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   FrmMain.UndoUpdate(FrmMain.ActiveData^.UndoList);
   close;
end;

procedure TFrmDeleteFrames.CbShadowClick(Sender: TObject);
begin
   if CbShadow.Checked then
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages div 2
   else
      spTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   if spTo.Value = spTo.MaxValue then
      spTo.Value := spTo.MaxValue;
end;

procedure TFrmDeleteFrames.BtToOneClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MinValue;
end;

procedure TFrmDeleteFrames.BtToEndClick(Sender: TObject);
begin
   PLastFocus^.Value := PLastFocus^.MaxValue;
end;

procedure TFrmDeleteFrames.FormShow(Sender: TObject);
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

procedure TFrmDeleteFrames.spFromClick(Sender: TObject);
begin
   PLastFocus := @spFrom;
end;

procedure TFrmDeleteFrames.spToClick(Sender: TObject);
begin
   PLastFocus := @spTo;
end;

end.
