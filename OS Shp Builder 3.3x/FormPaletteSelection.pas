unit FormPaletteSelection;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, SHP_DataMatrix, Math, Palette;

type
   TFrmPaletteSelection = class(TForm)
      Panel1:     TPanel;
      cnvPalette: TPaintBox;
      procedure cnvPalettePaint(Sender: TObject);
      procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: integer);
      procedure SplitColour(raw: TColor; var red, green, blue: byte);
      procedure FormShow(Sender: TObject);
   private
      { Private declarations }
      PaletteMax: word;
   public
      { Public declarations }
      Palette: TPalette;
      Colour:  byte;
   end;

implementation

{$R *.dfm}

procedure TFrmPaletteSelection.SplitColour(raw: TColor; var red, green, blue: byte);
begin
   red   := (raw and $00FF0000) shr 16;
   green := (raw and $0000FF00) shr 8;
   blue  := raw and $000000FF;
end;

procedure TFrmPaletteSelection.cnvPalettePaint(Sender: TObject);
var
   colwidth, rowheight: real;
   i, j, idx: integer;
   r: TRect;
begin
   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   idx := 0;
   PaletteMax := 256;

   //     if IsShadow(Data^.SHP,FrmMain.Current_Frame.Value) then
   //     PaletteMax := 2;


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

               Brush.Color := Palette[idx];
               FillRect(r);
            end;
         Inc(Idx);
      end;
   end;
end;

procedure TFrmPaletteSelection.cnvPaletteMouseUp(Sender: TObject;
   Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
   colwidth, rowheight: real;
   i, j, idx: integer;
begin

   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   i   := Trunc(X / colwidth);
   j   := Trunc(Y / rowheight);
   idx := (i * 32) + j;
   if idx < PaletteMax then
   begin
      Colour := idx;
      Close;
   end;

end;

procedure TFrmPaletteSelection.FormShow(Sender: TObject);
begin
   cnvPalettePaint(Sender);
end;

end.
