unit FormSelectDirectoryInstall;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Grids, DirOutln, ExtCtrls, XPMan;

type
  TFrmSelectDirectoryInstall = class(TForm)
    Drive: TDriveComboBox;
    Label1: TLabel;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    Directory: TDirectoryListBox;
    XPManifest: TXPManifest;
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelectedDir: string;
    OK: boolean;
    procedure SetSelectedDirectory(const _Dir: string);
  end;

implementation

{$R *.dfm}

procedure TFrmSelectDirectoryInstall.BtCancelClick(Sender: TObject);
begin
   OK := false;
   close;
end;

procedure TFrmSelectDirectoryInstall.BtOKClick(Sender: TObject);
begin
   OK := true;
   SelectedDir := Directory.Directory;
   close;
end;

procedure TFrmSelectDirectoryInstall.SetSelectedDirectory(const _Dir: string);
begin
   SelectedDir := copy(_Dir,1,Length(_Dir));
   Directory.Directory := _Dir;
end;

end.
