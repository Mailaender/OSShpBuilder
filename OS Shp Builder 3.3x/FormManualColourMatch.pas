unit FormManualColourMatch;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, shp_file, shp_engine, palette, Shp_Engine_Image, StdCtrls, ExtCtrls, Math;

type
   TFrmManualColourMatch = class(TForm)
      Bevel1:     TBevel;
      Panel1:     TPanel;
      cnvPalette: TPaintBox;
      Button1:    TButton;
      Image1:     TImage;
      Panel2:     TPanel;
      Panel3:     TPanel;
      Label1:     TLabel;
      Label2:     TLabel;
      Button2:    TButton;
      Button3:    TButton;
      procedure Button1Click(Sender: TObject);
      procedure cnvPalettePaint(Sender: TObject);
      procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: integer);
      procedure FormShow(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure Button3Click(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      Colour:     byte;
      PaletteMax: integer;
      backdoor:   boolean;
   end;

var
   FrmManualColourMatch: TFrmManualColourMatch;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmManualColourMatch.Button1Click(Sender: TObject);
begin
   Close;
end;

procedure SplitColour(raw: TColor; var red, green, blue: byte);
begin
   red   := (raw and $00FF0000) shr 16;
   green := (raw and $0000FF00) shr 8;
   blue  := raw and $000000FF;
end;

procedure TFrmManualColourMatch.cnvPalettePaint(Sender: TObject);
var
   colwidth, rowheight: real;
   i, j, idx: integer;
   r: TRect;
   red, green, blue, mixcol, SColour: byte;
begin
   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   idx     := 0;
   PaletteMax := 256;
   SColour := Colour;

   if IsShadow(FrmMain.SHP, FrmMain.Current_Frame.Value) and (FrmMain.ShadowMode) then
   begin
      PaletteMax := 2;
   end;

   for i := 0 to 8 do
   begin
      r.Left  := Trunc(i * colwidth);
      r.Right := Ceil(r.Left + colwidth);
      for j := 0 to 31 do
      begin
         r.Top    := Trunc(j * rowheight);
         r.Bottom := Ceil(r.Top + rowheight);
         if Idx < PaletteMax then
            with cnvPalette.Canvas do
            begin

               Brush.Color := SHPPalette[idx];

               if (Idx = SColour) then
               begin // the current pen

                  SplitColour(SHPPalette[idx], red, green, blue);
                  mixcol    := (red + green + blue);
                  Pen.Color := RGB(128 + mixcol, 255 - mixcol, mixcol);
                  //Pen.Mode := pmNotXOR;
                  Rectangle(r.Left, r.Top, r.Right, r.Bottom);
                  MoveTo(r.Left, r.Top);
                  LineTo(r.Right, r.Bottom);
                  MoveTo(r.Right, r.Top);
                  LineTo(r.Left, r.Bottom);
               end
               else
                  FillRect(r);
            end;
         Inc(Idx);
      end;
   end;
end;

procedure TFrmManualColourMatch.cnvPaletteMouseUp(Sender: TObject;
   Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
   colwidth, rowheight: real;
   i, j, idx: integer;
begin
   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   i      := Trunc(X / colwidth);
   j      := Trunc(Y / rowheight);
   idx    := (i * 32) + j;
   Colour := idx;
   cnvPalettePaint(Sender);
   Panel3.Color := SHPPalette[Colour];
end;

procedure TFrmManualColourMatch.FormShow(Sender: TObject);
begin
   Panel3.Color := SHPPalette[Colour];
   backdoor     := False;
end;

procedure TFrmManualColourMatch.Button2Click(Sender: TObject);
var
   r, g, b: byte;
begin

   r := GetRValue(Panel2.Color) - GetRValue(Panel3.Color);
   g := GetGValue(Panel2.Color) - GetGValue(Panel3.Color);
   b := GetBValue(Panel2.Color) - GetBValue(Panel3.Color);

   if r < 0 then
      r := -r;
   if g < 0 then
      g := -g;
   if b < 0 then
      b := -b;

   ShowMessage(IntToStr(r) + ' ' + IntToStr(g) + ' ' + IntToStr(b));
end;

procedure TFrmManualColourMatch.Button3Click(Sender: TObject);
begin
   backdoor := True;
   Close;
end;

end.
