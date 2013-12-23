unit FormPreferences_Anim;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, StdCtrls, Spin, XPMan;

type
   TFrmPreferences_Anim = class(TForm)
      Label1:  TLabel;
      Name:    TEdit;
      Label2:  TLabel;
      Label3:  TLabel;
      Count:   TSpinEdit;
      Count2:  TSpinEdit;
      Label4:  TLabel;
      Label5:  TLabel;
      StartFrame: TSpinEdit;
      Special: TEdit;
      Button1: TButton;
      Button2: TButton;
      Bevel1:  TBevel;
    XPManifest: TXPManifest;
      procedure Button1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      OkP: boolean;
   end;

implementation

{$R *.dfm}

procedure TFrmPreferences_Anim.Button1Click(Sender: TObject);
begin
   OkP := False;
   Close;
end;

procedure TFrmPreferences_Anim.Button2Click(Sender: TObject);
begin
   OkP := True;
   Close;
end;

procedure TFrmPreferences_Anim.FormShow(Sender: TObject);
begin
   OkP := False;
end;

end.
