unit FormQuickNewSHP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XPMan;

type
  TFrmQuickNewSHP = class(TForm)
    OK: TButton;
    Cancel: TButton;
    GroupBox1: TGroupBox;
    CbxGame: TComboBoxEx;
    Label4: TLabel;
    CbxType: TComboBoxEx;
    Label5: TLabel;
    XPManifest: TXPManifest;
    procedure OKClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure CbxGameChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

{$R *.dfm}
uses FormMain;

procedure TFrmQuickNewSHP.OKClick(Sender: TObject);
begin
   Changed := true;
   Close;
end;

procedure TFrmQuickNewSHP.CancelClick(Sender: TObject);
begin
   Changed := false;
   Close;
end;

procedure TFrmQuickNewSHP.CbxGameChange(Sender: TObject);
var
   Index: integer;
begin
   Index := CbxType.ItemIndex;
   case (CbxGame.ItemIndex) of
      0:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Desert)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Winter)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      1:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Interior)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      2:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
      3:
      begin
         CbxType.ItemsEx.Clear;
         CbxType.ItemsEx.AddItem('Any (Auto)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Unit', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Building Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Animation', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Cameo', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Temperate)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Snow)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Urban)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Desert)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (Lunar)', -1, -1, -1, -1, nil);
         CbxType.ItemsEx.AddItem('Overlay (New Urban)', -1, -1, -1, -1, nil);
         if Index < 8 then
            CbxType.ItemIndex := Index
         else
            CbxType.ItemIndex := 0;
      end;
   end;
end;


procedure TFrmQuickNewSHP.FormShow(Sender: TObject);
begin
   Changed := False;
   CbxGame.Images := FrmMain.ImageList;
   CbxGame.ItemIndex := 2;
   CbxType.ItemIndex := 0;
end;

end.
