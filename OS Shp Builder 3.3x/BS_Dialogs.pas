 // BS_Dialogs.PAS
 // By Banshee & Stucuk

unit BS_Dialogs;

interface

uses
   SysUtils, ExtCtrls, Forms, ComCtrls, StdCtrls, Dialogs;

var
   AProgressDialog: TForm;

procedure OpenProgressDialog(PDCaption: string; PDMax: integer);
procedure UpdateProgressDialog(Position: integer);
procedure CloseProgressDialog;


implementation

procedure OpenProgressDialog(PDCaption: string; PDMax: integer);
var
   AProgressBar: TProgressBar;
begin
   AProgressDialog := CreateMessageDialog('Progress', mtWarning, []);
   AProgressBar    := TProgressBar.Create(AProgressDialog);
   with AProgressDialog do
   begin
      Caption := PDCaption;
      Height  := 150;

      with AProgressBar do
      begin
         Name   := 'Progress';
         Parent := AProgressDialog;
         Max    := PDMax; //seconds
         Step   := 1;
         Top    := 100;
         Left   := 8;
         Width  := AProgressDialog.ClientWidth - 16;
      end;

      Show;
   end;
end;

procedure UpdateProgressDialog(Position: integer);
var
   aPB: TProgressBar;
begin
   with AProgressDialog do
      aPB := TProgressBar(FindComponent('Progress'));
   aPB.Position := Position;
   AProgressDialog.Caption := IntToStr(aPB.Max);
end;

procedure CloseProgressDialog;
begin
   AProgressDialog.Close;
   AProgressDialog.Free;
end;

end.
 