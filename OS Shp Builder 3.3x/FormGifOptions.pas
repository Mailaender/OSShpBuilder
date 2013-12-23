unit FormGifOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, XPMan;

type
  TFrmGifOptions = class(TForm)
    LoopType: TRadioGroup;
    BtOK: TButton;
    BtCancel: TButton;
    Shadows: TRadioGroup;
    GroupBox1: TGroupBox;
    Zoom_Factor: TSpinEdit;
    Transparency: TGroupBox;
    CbUseTransparency: TCheckBox;
    XPManifest: TXPManifest;
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

{$R *.dfm}

procedure TFrmGifOptions.BtOKClick(Sender: TObject);
begin
   Changed := True;
   Close;
end;

procedure TFrmGifOptions.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmGifOptions.FormShow(Sender: TObject);
begin
   Changed := False;
end;

end.
