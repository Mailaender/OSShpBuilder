unit FormDarkenLightenTool;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, XPMan;

type
   Tfrmdarkenlightentool = class(TForm)
      Label1:    TLabel;
      ComboBox1: TComboBox;
      Button1:   TButton;
      Button2:   TButton;
    XPManifest: TXPManifest;
      procedure Button1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

implementation

uses FormMain;

{$R *.dfm}

procedure Tfrmdarkenlightentool.Button1Click(Sender: TObject);
begin
   FrmMain.DarkenLighten_N := ComboBox1.ItemIndex + 1;
   Close;
end;

procedure Tfrmdarkenlightentool.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure Tfrmdarkenlightentool.FormShow(Sender: TObject);
begin
   ComboBox1.ItemIndex := FrmMain.DarkenLighten_N - 1;
end;

end.
