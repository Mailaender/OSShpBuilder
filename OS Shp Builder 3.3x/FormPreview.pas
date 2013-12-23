unit FormPreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls, shp_file,shp_engine,palette,
  Shp_Engine_Image, SHP_Image, XPMan;

type
  TFrmPreview = class(TForm)
    ControlPanel: TPanel;
    ImagePanel: TPanel;
    Image1: TImage;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    AnimationTimer: TTimer;
    Loop: TCheckBox;
    Magnification: TComboBoxEx;
    UpdateTimer: TTimer;
    Label4: TLabel;
    CbSideColour: TComboBoxEx;
    XPManifest: TXPManifest;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar1Change(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure MagnificationChange(Sender: TObject);
    procedure CbSideColourChange(Sender: TObject);
    procedure UpdatePalette(const NewPalette : TPalette);
//    procedure ResizePaintArea;
  private
    { Private declarations }
    Palette : TPalette;
  public
    { Public declarations }
    Data : Pointer;
    ActiveForm : Pointer;
  end;

implementation

uses FormMain,SHP_DataMatrix,FormSHPImage;

{$R *.dfm}

procedure TFrmPreview.SpeedButton1Click(Sender: TObject);
begin
   AnimationTimer.Enabled := true;
end;

procedure TFrmPreview.SpeedButton3Click(Sender: TObject);
begin
   AnimationTimer.Enabled := not AnimationTimer.Enabled;
end;

procedure TFrmPreview.SpeedButton2Click(Sender: TObject);
begin
   AnimationTimer.Enabled := false;
   TrackBar1.Position := 1;
   TrackBar1Change(Sender);
end;

procedure TFrmPreview.FormClose(Sender: TObject; var Action: TCloseAction);
var
   SHPData : TSHPImageData;
begin
   SpeedButton2Click(Sender);
   UpdateTimer.Enabled := false;

   // Grab Data
   SHPData := Data;

   // Update Preview Option in the menu
   if SHPData = FrmMain.ActiveData then
   begin
      FrmMain.Preview1.Checked := false;
      FrmMain.TbPreviewWindow.Down := false;
   end;
   // Unlink Preview
   SHPData^.Preview := nil;

   // Nuke Preview
   Action := caFree;
end;

procedure TFrmPreview.TrackBar1Change(Sender: TObject);
var
   SHPData : TSHPImageData;
begin
   if not FrmMain.isEditable then exit;

   SHPData := Data;

   ImagePanel.Color := SHPData^.SHPPalette[0];

   // Set image width n height
   image1.Picture.Bitmap.Width := SHPData^.SHP.Header.Width * (Magnification.ItemIndex+1);
   image1.Picture.Bitmap.Height := SHPData^.SHP.Header.Height * (Magnification.ItemIndex+1);
   if TrackBar1.Position <= SHPData^.SHP.Header.NumImages then
   begin
      if FrmMain.ActiveForm^.Shadowmode then
         DrawFrameImageWithShadow(SHPData^.SHP,TrackBar1.Position,(Magnification.ItemIndex+1),false,true,Palette,SHPData^.Shadow_Match,Image1)
      else
         DrawFrameImage(SHPData^.SHP,SHPData^.Shadow_Match,TrackBar1.Position,(Magnification.ItemIndex+1),true,false,true,Palette,Image1);

      Label1.Caption := 'Frame: ' + inttostr(TrackBar1.Position);
      Label2.Caption := 'Total Frames: ' + inttostr(SHPData^.SHP.Header.NumImages);
      Label3.Caption := 'Compression: ' + inttostr(SHPData^.SHP.Data[TrackBar1.Position].Header_Image.compression);
   end;
end;

procedure TFrmPreview.AnimationTimerTimer(Sender: TObject);
var
   Max : integer;
   SHPData : TSHPImageData;
   SHPActiveForm : ^TFrmSHPImage;
begin
   SHPData := Data;
   SHPActiveForm := ActiveForm;

   if SHPActiveForm.Shadowmode then
      Max := SHPData^.SHP.Header.NumImages div 2
   else
      Max := SHPData^.SHP.Header.NumImages;

   if TrackBar1.Position +1 <= Max then
      TrackBar1.Position := TrackBar1.Position +1
   else
   begin
      SpeedButton2Click(Sender);
      if Loop.Checked then
         SpeedButton1Click(Sender);
   end;
end;

procedure TFrmPreview.FormShow(Sender: TObject);
var
   SHPData : TSHPImageData;
   SHPActiveForm : ^TFrmSHPImage;
begin
   SHPData := Data;
   SHPActiveForm := ActiveForm;

   // 3.36: New remappable palette support.
   if IsSHPRemmapable(SHPData^.SHP.SHPType) then
   begin
      if (SHPData^.SHP.SHPGame = sgTS) or (SHPData^.SHP.SHPGame = sgRA2) then
         CbSideColour.ItemIndex := 1
      else
         CbSideColour.ItemIndex := 0;
   end;
   UpdatePalette(SHPData^.SHPPalette);

   // Other initialization basics.
   ImagePanel.DoubleBuffered := true;
   Magnification.ItemIndex := 0;
   Label1.Caption := 'Frame: ' + inttostr(1);
   Label3.Caption := 'Compression: ' + inttostr(SHPData^.SHP.Data[1].Header_Image.compression);
   if SHPActiveForm^.ShadowMode then
      TrackBar1.Max := SHPData^.SHP.Header.NumImages div 2
   else
      TrackBar1.Max := SHPData^.SHP.Header.NumImages;
   Label2.Caption := 'Total Frames: ' + inttostr(TrackBar1.Max);
// ResizePaintArea;

   UpdateTimer.Enabled := true;
   UpdateTimerTimer(sender);

   if Height < (ControlPanel.Height + 32 + SHPData^.SHP.Header.Height) then
      Height := ControlPanel.Height + 32 + SHPData^.SHP.Header.Height;

   if Width < (16 + SHPData^.SHP.Header.Width) then
      Width := 16 + SHPData^.SHP.Header.Width;
   TrackBar1.Position := 1;
   TrackBar1Change(Sender);
end;

procedure TFrmPreview.UpdateTimerTimer(Sender: TObject);
begin
   Image1.Width := Image1.Picture.Bitmap.Width; // * (Magnification.ItemIndex+1); // strtoint(copy(Magnification.Items.Strings[Magnification.ItemIndex],1,1));
   Image1.height:= Image1.Picture.Bitmap.height; // * (Magnification.ItemIndex+1);  // strtoint(copy(Magnification.Items.Strings[Magnification.ItemIndex],1,1));

   Image1.Left := (ImagePanel.Width div 2) - (Image1.Width div 2);
   Image1.top := (ImagePanel.Height div 2) - (Image1.Height div 2);
end;

procedure TFrmPreview.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
   if (NewHeight < 200) then
      NewHeight := 200;
   if (NewWidth < 339) then
      NewWidth := 339;
end;

procedure TFrmPreview.MagnificationChange(Sender: TObject);
begin
   TrackBar1Change(Sender);
end;

procedure TFrmPreview.CbSideColourChange(Sender: TObject);
var
   SHPData : TSHPImageData;
begin
   SHPData := Data;
   if IsSHPRemmapable(SHPData^.SHP.SHPType) then
   begin
      case (SHPData^.SHP.SHPGame) of
         sgTD: ChangeRemappableTD(Palette,CbSideColour.ItemIndex);
         sgRA1: ChangeRemappableRA1(Palette,CbSideColour.ItemIndex);
         else
            ChangeRemappable(Palette,CbSideColour.ItemIndex);
      end;
   end;
   TrackBar1Change(Sender);
end;

procedure TFrmPreview.UpdatePalette(const NewPalette : TPalette);
begin
   // Here we load the palette.
   CopyPalette(NewPalette,Palette);
   // Then, we update to the loaded side.
   CbSideColourChange(nil);
end;
end.
