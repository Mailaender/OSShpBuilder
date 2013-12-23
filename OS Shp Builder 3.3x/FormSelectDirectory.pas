unit FormSelectDirectory;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ComCtrls, ShellCtrls;

type
   TFrmSelectDirectory = class(TForm)
      ShellTreeView1: TShellTreeView;
      Button1: TButton;
      procedure Button1Click(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   FrmSelectDirectory: TFrmSelectDirectory;

implementation

{$R *.dfm}

procedure TFrmSelectDirectory.Button1Click(Sender: TObject);
begin
   Close;
end;

end.
