unit FormFrameSplitter;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, Spin, XPMan;

type
   TFrmFrameSplitter = class(TForm)
      Label1:      TLabel;
      SpeFrameNum: TSpinEdit;
      Label2:      TLabel;
      SpeHorizontal: TSpinEdit;
      Label3:      TLabel;
      SpeVertical: TSpinEdit;
      EdWidth:     TEdit;
      EdHeight:    TEdit;
      Bevel1:      TBevel;
      Label4:      TLabel;
      ComboOrder:  TComboBox;
      Button1:     TButton;
      Button2:     TButton;
      Label5:      TLabel;
    XPManifest: TXPManifest;
      procedure SpeHorizontalChange(Sender: TObject);
      procedure SpeVerticalChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
   private
      { Private declarations }
   public
      InitialWidth, InitialHeight: integer;
      Changed: boolean;
      { Public declarations }
   end;

implementation

{$R *.dfm}

procedure TFrmFrameSplitter.SpeHorizontalChange(Sender: TObject);
begin
   EdWidth.Text := IntToStr(InitialWidth div StrToIntDef(SpeHorizontal.Text, 1));
end;

procedure TFrmFrameSplitter.SpeVerticalChange(Sender: TObject);
begin
   EdHeight.Text := IntToStr(InitialHeight div StrToIntDef(SpeVertical.Text, 1));
end;

procedure TFrmFrameSplitter.FormCreate(Sender: TObject);
begin
   changed := False;
end;

procedure TFrmFrameSplitter.Button1Click(Sender: TObject);
var
   Temp: integer;
begin
   Temp := StrToIntDef(SpeHorizontal.Text, 1);
   if (Temp > 0) and (Temp <= SpeHorizontal.MaxValue) then
   begin
      Temp := StrToIntDef(SpeVertical.Text, 1);
      if (Temp > 0) and (Temp <= SpeVertical.MaxValue) then
      begin
         Temp := StrToIntDef(SpeFrameNum.Text, 1);
         if (Temp > 0) and (Temp <= SpeFrameNum.MaxValue) then
         begin
            changed := True;
         end;
      end;
   end;
   Close;
end;

procedure TFrmFrameSplitter.Button2Click(Sender: TObject);
begin
   Close;
end;

end.
