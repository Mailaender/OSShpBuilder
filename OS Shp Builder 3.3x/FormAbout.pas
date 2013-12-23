unit FormAbout;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, jpeg, XPMan;

type
   TFrmAbout = class(TForm)
      Image1:  TImage;
      Bevel1:  TBevel;
      Bevel2:  TBevel;
      LbTitle: TLabel;
      LbEngineVersion: TLabel;
      LbEngineBy: TLabel;
      Ok:      TButton;
      Image2:  TImage;
      LbVersion: TLabel;
      Label5:  TLabel;
      LbMadeBy: TLabel;
      Label7:  TLabel;
      Label8:  TLabel;
      Label9:  TLabel;
      Label10: TLabel;
      LbContributors: TLabel;
      Label1:  TLabel;
      Label2:  TLabel;
      Label3:  TLabel;
    Label4: TLabel;
    XPManifest: TXPManifest;
      procedure OkClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

implementation

{$R *.dfm}

uses FormMain, SHP_Engine;

procedure TFrmAbout.OkClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmAbout.FormShow(Sender: TObject);
var
   temp: string;
begin
   LbTitle.Caption := SHP_BUILDER_TITLE;
   temp := LbVersion.Caption;
   LbVersion.Caption := FrmMain.GetVersion(temp);
   LbMadeBy.Caption := LbMadeBy.Caption + SHP_BUILDER_BY;
   LbContributors.Caption := LbContributors.Caption + SHP_BUILDER_CONTRIBUTORS;

   LbEngineVersion.Caption := LbEngineVersion.Caption + SHP_ENGINE_VER;
   LbEngineBy.Caption      := LbEngineBy.Caption + SHP_ENGINE_BY;
end;

end.
