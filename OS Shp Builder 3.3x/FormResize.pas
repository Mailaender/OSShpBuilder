unit FormResize;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, ExtCtrls, Mask, Spin, SHP_DataMatrix, XPMan;

type
   TFrmResize = class(TForm)
      grpCurrentSize: TGroupBox;
      Label2:    TLabel;
      Label3:    TLabel;
      GroupBox1: TGroupBox;
      Label4:    TLabel;
      Label5:    TLabel;
      speWidth:  TSpinEdit;
      speHeight: TSpinEdit;
      spePercWidth: TSpinEdit;
      spePercHeight: TSpinEdit;
      btnOK:     TButton;
      btnCancel: TButton;
    GroupBox2: TGroupBox;
    chbMaintainRatio: TCheckBox;
    rbBlocky: TRadioButton;
    rbPaint: TRadioButton;
    cbSmartMode: TCheckBox;
    lblSHPTypeGame: TLabel;
    XPManifest: TXPManifest;
      procedure btnCancelClick(Sender: TObject);
      procedure btnOKClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure spePercHeightChange(Sender: TObject);
      procedure spePercWidthChange(Sender: TObject);
      procedure speHeightChange(Sender: TObject);
      procedure speWidthChange(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      changed: boolean; //has x,y or z changed at all? if not, no need to do anything
      Data:    TSHPImageData;
   end;

implementation

uses FormMain;

{$R *.DFM}

procedure TFrmResize.btnCancelClick(Sender: TObject);
begin
   changed := False;
   Close;
end;

procedure TFrmResize.btnOKClick(Sender: TObject);
begin
   changed := True;
   Close;
end;

procedure TFrmResize.FormShow(Sender: TObject);
begin
   changed := False;
   spePercHeight.Text := '100';
   spePercWidth.Text := '100';
   speWidth.Text := IntToStr(Data^.SHP.Header.Width);
   speHeight.Text := IntToStr(Data^.SHP.Header.Height);
   chbMaintainRatio.Checked := False;
end;

 // The codes below update the percetanges with the dimensions
 // while the user is editing the values and vice versa.
procedure TFrmResize.spePercHeightChange(Sender: TObject);
var
   tempvalue: integer;
begin
   tempvalue := -1;

   if (spePercHeight.Value > 0) and (Data^.SHP.Header.Height > 0) then
      tempvalue := round((Data^.SHP.Header.Height * spePercHeight.Value) div 100);

   speHeight.OnChange := nil;
   speHeight.Value    := tempvalue;
   speHeight.OnChange := speHeightChange;

   if chbMaintainRatio.Checked then
      spePercWidth.Value := spePercHeight.Value;
end;

procedure TFrmResize.spePercWidthChange(Sender: TObject);
var
   tempvalue: integer;
begin
   tempvalue := -1;

   if (spePercWidth.Value > 0) and (Data^.SHP.Header.Width > 0) then
      tempvalue := round((Data^.SHP.Header.Width * spePercWidth.Value) div 100);

   speWidth.OnChange := nil;
   speWidth.Value    := tempvalue;
   speWidth.OnChange := speWidthChange;

   if chbMaintainRatio.Checked then
      spePercHeight.Value := spePercWidth.Value;
end;

procedure TFrmResize.speHeightChange(Sender: TObject);
var
   tempvalue: integer;
begin
   tempvalue := -1;

   if (speHeight.Value > 0) and (Data^.SHP.Header.Height > 0) then
      tempvalue := round((speHeight.Value / Data^.SHP.Header.Height) * 100);

   spePercHeight.OnChange := nil;
   spePercHeight.Value    := tempvalue;
   spePercHeight.OnChange := spePercHeightChange;

   if chbMaintainRatio.Checked then
      spePercWidth.Value := spePercHeight.Value;
end;

procedure TFrmResize.speWidthChange(Sender: TObject);
var
   tempvalue: integer;
begin
   tempvalue := -1;

   if (speWidth.Value > 0) and (Data^.SHP.Header.Width > 0) then
      tempvalue := round((speWidth.Value / Data^.SHP.Header.Width) * 100);

   spePercWidth.OnChange := nil;
   spePercWidth.Value    := tempvalue;
   spePercWidth.OnChange := spePercWidthChange;

   if chbMaintainRatio.Checked then
      spePercHeight.Value := spePercWidth.Value;
end;

end.
