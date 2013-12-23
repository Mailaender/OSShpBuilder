unit FormMirrorSHP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, math, SHP_Image_Effects, Undo_Redo, XPMan;

const
   C_SHPFX_MIRROR = 0;
   C_SHPFX_FLIP = 1;

type
   TFrmMirrorSHP = class(TForm)
      GbEscope: TGroupBox;
      RbAll: TRadioButton;
      RbRange: TRadioButton;
      LbFrom: TLabel;
      SpeFrom: TSpinEdit;
      SpeTo: TSpinEdit;
      LbTo: TLabel;
      Bevel: TBevel;
      BtOK: TButton;
      BtCancel: TButton;
      RbCurrent: TRadioButton;
    XPManifest: TXPManifest;
      procedure SpeToChange(Sender: TObject);
      procedure SpeFromChange(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure BtCancelClick(Sender: TObject);
   private
      { Private declarations }
      procedure ApplyChanges;
   public
      { Public declarations }
      OpType : byte;
   end;

implementation

{$R *.dfm}

uses FormMain;

procedure TFrmMirrorSHP.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmMirrorSHP.BtOKClick(Sender: TObject);
begin
   ApplyChanges;
   close;
end;

procedure TFrmMirrorSHP.FormCreate(Sender: TObject);
begin
   OpType := C_SHPFX_MIRROR;
end;

procedure TFrmMirrorSHP.FormShow(Sender: TObject);
begin
   if OpType = C_SHPFX_MIRROR then
   begin
      Caption := 'Mirror SHP';
      GbEscope.Caption := 'Mirror The Following Frames...';
   end
   else
   begin
      Caption := 'Flip SHP';
      GbEscope.Caption := 'Flip The Following Frames...';
   end;
   SpeTo.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
   SpeFrom.MaxValue := FrmMain.ActiveData^.SHP.Header.NumImages;
end;

procedure TFrmMirrorSHP.SpeFromChange(Sender: TObject);
begin
   RbRange.Checked := true;
   if SpeFrom.Value < 1 then
      SpeFrom.Value := 1;
   if SpeFrom.Value > FrmMain.ActiveData^.SHP.Header.NumImages then
      SpeFrom.Value := FrmMain.ActiveData^.SHP.Header.NumImages;
end;

procedure TFrmMirrorSHP.SpeToChange(Sender: TObject);
begin
   RbRange.Checked := true;
   if SpeTo.Value < 1 then
      SpeTo.Value := 1;
   if SpeTo.Value > FrmMain.ActiveData^.SHP.Header.NumImages then
      SpeTo.Value := FrmMain.ActiveData^.SHP.Header.NumImages;
end;

procedure TFrmMirrorSHP.ApplyChanges;
var
   i : integer;
   first,last : integer;
begin
   if rbAll.Checked then
   begin
      first := 1;
      last := FrmMain.ActiveData^.SHP.Header.NumImages;
   end
   else if RbRange.Checked then
   begin
      if (SpeFrom.Value >= 1) and (SpeFrom.Value <= FrmMain.ActiveData^.SHP.Header.NumImages) then
      begin
         if (SpeTo.Value >= 1) and (SpeTo.Value <= FrmMain.ActiveData^.SHP.Header.NumImages) then
         begin
            // Let's get the range.
            first := Min(SpeFrom.Value,SpeTo.Value);
            last := Max(SpeFrom.Value,SpeTo.Value);
         end
         else
            exit;
      end
      else
         exit;
   end
   else
   begin
      first := FrmMain.ActiveForm^.FrameIndex;
      last := FrmMain.ActiveForm^.FrameIndex;
   end;
   if OpType = C_SHPFX_MIRROR then
   begin
      AddToUndo(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,first,last);
      for i := first to last do
      begin
         MirrorFrame(FrmMain.ActiveData^.SHP.Data[i].FrameImage);
      end;
   end
   else
   begin
      AddToUndo(FrmMain.ActiveData^.UndoList,FrmMain.ActiveData^.SHP,first,last);
      for i := first to last do
      begin
         FlipFrame(FrmMain.ActiveData^.SHP.Data[i].FrameImage);
      end;
   end;
   FrmMain.UndoUpdate(FrmMain.ActiveData^.UndoList);
   FrmMain.RefreshAll;
end;

end.
