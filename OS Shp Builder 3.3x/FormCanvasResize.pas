unit FormCanvasResize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, SHP_DataMatrix, Palette, SHP_File, OS_SHP_Tools,
  XPMan;

type
  TFrmCanvasResize = class(TForm)
    PaintAreaPanel: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinT: TSpinEdit;
    SpinB: TSpinEdit;
    SpinL: TSpinEdit;
    SpinR: TSpinEdit;
    Bevel1: TBevel;
    BtnOK: TButton;
    BtnCancel: TButton;
    XPManifest: TXPManifest;
    procedure SpinTChange(Sender: TObject);
    procedure SpinBChange(Sender: TObject);
    procedure SpinLChange(Sender: TObject);
    procedure SpinRChange(Sender: TObject);
    procedure Refresh_Image;
    procedure Refresh_Image_Bitmap;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    LockSize : boolean;
    FrameImage:TFrameImage;
    Bitmap:TBitmap;
    SHPPalette:TPalette;
    Width,Height:Word;
    xstart,ystart,xfinal,yfinal:integer;
    changed : boolean; // return
    Loop:boolean; //Avoid unlimited loop when importing files
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrmCanvasResize.SpinTChange(Sender: TObject);
begin
   if not loop then // avoid crash (unlimited loop) when
   begin            // Locksize is true
      loop := true;
      exit;
   end;
   if ((SpinT.Text = '') or (SpinT.Text = '-')) then exit;
   If LockSize then
   begin
      Loop := false;
      SpinB.Value := SpinT.Value + (Height - Bitmap.Height);
      Refresh_Image_Bitmap;
   end
   else
      Refresh_Image;
end;

procedure TFrmCanvasResize.SpinBChange(Sender: TObject);
begin
   if not loop then
   begin
      loop := true;
      exit;
   end;
   if ((SpinB.Text = '') or (SpinB.Text = '-')) then exit;
   If LockSize then
   begin
      Loop := false;
      SpinT.Value := SpinB.Value + (Height - Bitmap.Height);
      Refresh_Image_Bitmap;
   end
   else
      Refresh_Image;
end;

procedure TFrmCanvasResize.SpinLChange(Sender: TObject);
begin
   if not loop then
   begin
      loop := true;
      exit;
   end;
   if ((SpinL.Text = '') or (SpinL.Text = '-')) then exit;
   If LockSize then
   begin
      Loop := false;
      SpinR.Value := SpinL.Value + (Width - Bitmap.Width);
      Refresh_Image_Bitmap;
   end
   else
      Refresh_Image;
end;

procedure TFrmCanvasResize.SpinRChange(Sender: TObject);
begin
   if not loop then
   begin
      loop := true;
      exit;
   end;
   if ((SpinR.Text = '') or (SpinR.Text = '-')) then exit;
   If LockSize then
   begin
      Loop := false;
      SpinL.Value := SpinR.Value + (Width - Bitmap.Width);
      Refresh_Image_Bitmap;
   end
   else
      Refresh_Image;
end;

procedure TFrmCanvasResize.Refresh_Image;
var
   x,y,xbegin,xend,ybegin,yend: integer;
   xpos,ypos,default: integer;
   Final: TRect;
begin
   if self.Visible = false then exit; // ghosts doesnt need to view it.
   // Refresh Image
   Image1.Canvas.Brush.Color := SHPPalette[0];
   Image1.Canvas.FillRect(Rect(0,0,Image1.Width-1,Image1.Height-1));

   if xstart < 0 then
   begin
      xbegin := 0;
      xpos := -xstart;
   end
   else
   begin
      xbegin := xstart;
      xpos := 0
   end;

   if xfinal > Image1.Width then
      xend := Image1.Width
   else
      xend := xfinal;

   if ystart < 0 then
   begin
      ybegin := 0;
      ypos := -ystart;
   end
   else
   begin
      ybegin := ystart;
      ypos := 0;
   end;

   if yfinal > Image1.Height then
      yend := Image1.Height
   else
      yend := yfinal;

   dec(xend);
   dec(yend);
   default := ypos;
   // Post Image
   for x := xbegin to xend do
   begin
      for y := ybegin to yend do
      begin
         Image1.Canvas.Pixels[x,y] := SHPPalette[FrameImage[xpos,ypos]];
         inc(ypos);
      end;
      ypos := default;
      inc(xpos);
   end;

   // Post Selection Canvas
   // top horizontal line
   if (ybegin - SpinT.Value) > 0 then
      Final.Top := ybegin - SpinT.Value
   else
      Final.Top := 0;

   // bottom horizontal line
   if (yend + SpinB.Value+1) < Image1.Height then
      Final.Bottom := yend + SpinB.Value+1
   else
      Final.Bottom := Image1.Height-1;

   // left vertical line
   if (xbegin - SpinL.Value) > 0 then
      Final.Left := xbegin - SpinL.Value
   else
      Final.Left := 0;

   // right vertical line
   if (xend + SpinR.Value+1) < Image1.Width then
      Final.Right := xend + SpinR.Value+1
   else
      Final.Right := Image1.Width-1;

   Image1.Canvas.Brush.Color := OpositeColour(SHPPalette[0]);
   Image1.Canvas.DrawFocusRect(Final);
end;

procedure TFrmCanvasResize.Refresh_Image_Bitmap;
var
   x,y,xbegin,xend,ybegin,yend:word;
   xpos,ypos,default:word;
   Final:TRect;
begin
   if self.Visible = false then exit; // ghosts doesnt need to view it.
   // Refresh Image
   Image1.Canvas.Brush.Color := Bitmap.Canvas.Pixels[0,0];
   Image1.Canvas.FillRect(Rect(0,0,Image1.Width-1,Image1.Height-1));

   if xstart < 0 then
   begin
      xbegin := 0;
      xpos := -xstart;
   end
   else
   begin
      xbegin := xstart;
      xpos := 0
   end;

   if xfinal > Image1.Width then
      xend := Image1.Width
   else
      xend := xfinal;

   if ystart < 0 then
   begin
      ybegin := 0;
      ypos := -ystart;
   end
   else
   begin
      ybegin := ystart;
      ypos := 0;
   end;

   if yfinal > Image1.Height then
      yend := Image1.Height
   else
      yend := yfinal;

   default := ypos;
   // Post Image
   for x := xbegin to xend do
   begin
      for y := ybegin to yend do
      begin
         Image1.Canvas.Pixels[x,y] := Bitmap.Canvas.Pixels[xpos,ypos];
         inc(ypos);
      end;
      ypos := default;
      inc(xpos);
   end;

   // Post Selection Canvas
   // top horizontal line
   if (ybegin - SpinT.Value) > 0 then
      Final.Top := ybegin - SpinT.Value
   else
      Final.Top := 0;

   // bottom horizontal line
   if (yend + SpinB.Value+1) < Image1.Height then
      Final.Bottom := yend + SpinB.Value+1
   else
      Final.Bottom := Image1.Height-1;

   // left vertical line
   if (xbegin - SpinL.Value) > 0 then
      Final.Left := xbegin - SpinL.Value
   else
      Final.Left := 0;

   // right vertical line
   if (xend + SpinR.Value+1) < Image1.Width then
      Final.Right := xend + SpinR.Value+1
   else
      Final.Right := Image1.Width-1;

   Image1.Canvas.Brush.Color := OpositeColour(SHPPalette[0]);
   Image1.Canvas.DrawFocusRect(Final);
end;


procedure TFrmCanvasResize.FormShow(Sender: TObject);
begin
   if Locksize then
   begin
      // Calculate Image Position
      xstart := (Image1.Width  - Bitmap.Width) div 2;
      xfinal := (Image1.Width + Bitmap.Width) div 2;
      ystart := (Image1.Height - Bitmap.Height) div 2;
      yfinal := (Image1.Height + Bitmap.Height) div 2;

      SpinT.Value := abs(Height - Bitmap.Height) div 2;
      SpinL.Value := abs(Width - Bitmap.Width) div 2;

      Refresh_Image_Bitmap;
      BtnCancel.Enabled := false;
      changed := true; // always true to avoid headache!
   end
   else
   begin
      // Calculate Image Position
      xstart := (Image1.Width - Width) div 2;
      xfinal := (Image1.Width + Width) div 2;
      ystart := (Image1.Height - Height) div 2;
      yfinal := (Image1.Height + Height) div 2;

      Refresh_Image;
   end;
   Loop := true;
end;

procedure TFrmCanvasResize.BtnOKClick(Sender: TObject);
var
   xbegin,xend,ybegin,yend : integer;
begin
   // 3.3: Added code that prevents negative sizes ;).

   // Check for borders where the image is created...
   if xstart < 0 then
      xbegin := 0
   else
      xbegin := xstart;

   if xfinal > Image1.Width then
      xend := Image1.Width
   else
      xend := xfinal;

   if ystart < 0 then
      ybegin := 0
   else
      ybegin := ystart;

   if yfinal > Image1.Height then
      yend := Image1.Height
   else
      yend := yfinal;

   // Calculate if they bypass their limits
   if (ybegin - SpinT.Value) > (yend + SpinB.Value) then
      changed := false
   else if (xbegin - SpinL.Value) > (xend + SpinR.Value) then
      changed := false
   else
      changed := true;

   // Close.
   close;
end;

procedure TFrmCanvasResize.BtnCancelClick(Sender: TObject);
begin
   changed := false;
   close;
end;

procedure TFrmCanvasResize.FormCreate(Sender: TObject);
begin
   PaintAreaPanel.DoubleBuffered := true;
end;

end.
