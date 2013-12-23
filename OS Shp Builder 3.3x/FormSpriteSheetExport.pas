unit FormSpriteSheetExport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, XPMan;

type
  TFrmSpriteSheetExport = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Button2: TButton;
    Button1: TButton;
    ComboOrder: TComboBox;
    SpeVertical: TSpinEdit;
    SpeFrameStartNum: TSpinEdit;
    EdWidth: TEdit;
    Label5: TLabel;
    EdHeight: TEdit;
    Label6: TLabel;
    SpeFrameEndNum: TSpinEdit;
    BtFirst: TButton;
    BtLast: TButton;
    XPManifest: TXPManifest;
    procedure SpeVerticalChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtFirstClick(Sender: TObject);
    procedure BtLastClick(Sender: TObject);
    procedure SpeFrameStartNumChange(Sender: TObject);
  private
    { Private declarations }
  public
      InitialWidth, InitialHeight: integer;
      Changed: boolean;
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrmSpriteSheetExport.SpeVerticalChange(Sender: TObject);
begin
   EdHeight.Text := IntToStr(InitialHeight * StrToIntDef(SpeVertical.Text, 1));
   EdWidth.Text := IntToStr((InitialWidth * abs(StrToIntDef(SpeFrameEndNum.Text,1) - StrToIntDef(SpeFrameStartNum.Text,1) + 1)) div StrToIntDef(SpeVertical.Text, 1));
end;

procedure TFrmSpriteSheetExport.FormCreate(Sender: TObject);
begin
   changed := false;
end;

procedure TFrmSpriteSheetExport.Button1Click(Sender: TObject);
var
   Temp: integer;
begin
   Temp := StrToIntDef(SpeVertical.Text, 1);
   if (Temp > 0) and (Temp <= SpeVertical.MaxValue) then
   begin
      Temp := StrToIntDef(SpeFrameStartNum.Text, 1);
      if (Temp > 0) and (Temp <= SpeFrameStartNum.MaxValue) then
      begin
         Temp := StrToIntDef(SpeFrameEndNum.Text, 1);
         if (Temp > 0) and (Temp <= SpeFrameEndNum.MaxValue) then
         begin
            changed := True;
         end;
      end;
   end;
   Close;
end;

procedure TFrmSpriteSheetExport.Button2Click(Sender: TObject);
begin
   close;
end;

procedure TFrmSpriteSheetExport.BtFirstClick(Sender: TObject);
begin
   SpeFrameStartNum.Value := 1;
end;

procedure TFrmSpriteSheetExport.BtLastClick(Sender: TObject);
begin
   SpeFrameEndNum.Value := SpeFrameEndNum.MaxValue;
end;

procedure TFrmSpriteSheetExport.SpeFrameStartNumChange(Sender: TObject);
begin
   SpeVertical.MaxValue := abs(StrToIntDef(SpeFrameEndNum.Text,1) - StrToIntDef(SpeFrameStartNum.Text,1)) + 1;
   if SpeVertical.Value > SpeVertical.MaxValue then
      SpeVertical.Value := SpeVertical.MaxValue;
end;

end.
