unit FormRange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, XPMan;

type
  TFrmRange = class(TForm)
    SpBegin: TSpinEdit;
    SpEnd: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    XPManifest: TXPManifest;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpBeginEnter(Sender: TObject);
    procedure SpEndEnter(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    PLastFocus : ^TSpinEdit;
  public
    { Public declarations }
    Final,Current: word;
  end;

implementation

{$R *.dfm}

procedure TFrmRange.Button2Click(Sender: TObject);
begin
   SpBegin.Value := 1;
end;

procedure TFrmRange.Button3Click(Sender: TObject);
begin
   SpEnd.Value := Final;
end;

procedure TFrmRange.Button4Click(Sender: TObject);
begin
   PLastFocus^.Value := Current;
end;

procedure TFrmRange.FormCreate(Sender: TObject);
begin
   PLastFocus := @SpBegin;
   SpBegin.SetFocus;
   SpBegin.Value := Current;
   SpEnd.Value := Current;
end;

procedure TFrmRange.SpBeginEnter(Sender: TObject);
begin
   PLastFocus := @SpBegin;
end;

procedure TFrmRange.SpEndEnter(Sender: TObject);
begin
   PLastFocus := @SpEnd;
end;

procedure TFrmRange.Button1Click(Sender: TObject);
begin
   close;
end;

end.
