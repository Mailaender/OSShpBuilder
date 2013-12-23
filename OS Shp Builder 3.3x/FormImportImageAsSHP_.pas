unit FormImportImageAsSHP;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, StdCtrls, ExtDlgs, FileCtrl, shp_file, shp_engine, palette,
   Shp_Engine_Image, ComCtrls, Math;

type
   TFrmImportImageAsSHP = class(TForm)
      Label1:      TLabel;
      Image_Location: TEdit;
      Button1:     TButton;
      Button2:     TButton;
      Button3:     TButton;
      Bevel1:      TBevel;
      OpenPictureDialog: TOpenPictureDialog;
      FileListBox: TFileListBox;
      ProgressBar: TProgressBar;
      Label2:      TLabel;
      RadioButton1: TRadioButton;
      RadioButton2: TRadioButton;
      OpenPictureDialog1: TOpenPictureDialog;
      bcColourEdit: TPanel;
      procedure Button3Click(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure SingleLoadImage;
      procedure MassLoadImage;
   private
      { Private declarations }
   public
      { Public declarations }
      bgcolour: Tcolor;
      mode:     integer;
   end;

var
   FrmImportImageAsSHP: TFrmImportImageAsSHP;

implementation

uses FormMain, FormPreview{, FormManualColourMatch};

{$R *.dfm}

procedure TFrmImportImageAsSHP.Button3Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmImportImageAsSHP.Button1Click(Sender: TObject);
begin
   if mode = 1 then
      if OpenPictureDialog.Execute then
         Image_Location.Text := OpenPictureDialog.FileName;

   if mode = 0 then
      if OpenPictureDialog1.Execute then
         Image_Location.Text := OpenPictureDialog1.FileName;
end;

function colourtogray(colour: cardinal): cardinal;
var
   temp: char;
begin
   temp   := char((GetBValue(colour) * 29 + GetGValue(colour) * 150 +
      GetRValue(colour) * 77) div 256);
   Result := RGB(Ord(temp), Ord(temp), Ord(temp));
end;

function GrayBitmap(var Bitmap: TBitmap; const x, y: integer): Tbitmap;
var
   Temp:   Tbitmap;
   xx, yy: integer;
begin
   Temp := TBitmap.Create;

   Temp.Width  := Bitmap.Width;
   Temp.Height := Bitmap.Height;

   for xx := 0 to Bitmap.Width - 1 do
      for yy := 0 to Bitmap.Height - 1 do
         if ((xx <> x) and (yy <> y)) or ((xx = x) and (yy = y)) then
            Temp.Canvas.Pixels[xx, yy] := Bitmap.Canvas.Pixels[xx, yy]
         else
            Temp.Canvas.Pixels[xx, yy] := colourtogray(Bitmap.Canvas.Pixels[xx, yy]);


   Result := Temp;
end;


procedure TFrmImportImageAsSHP.Button2Click(Sender: TObject);
begin
   //FrmManualColourMatch.backdoor := false;

   // If file doesnt exist, it gives an error message.
   if not fileexists(Image_Location.Text) then
   begin
      MessageBox(0, 'Error: No Image Location Specifyed', 'Import Error', 0);
      Exit;
   end;

   // this will convert the image.
   if (mode = 1) then
      MassLoadImage
   else
      SingleLoadImage;

   // Below is code copyed from FrmMain, File -> New

   // Locks FormMain until it's set to the new file
   FrmMain.SetIsEditable(False);
   FrmMain.Filename := '';
   // New file must have blank filename to be recognised as a new file

   FrmMain.Caption := FrmMain.GetCaption + ' - [Untitled.shp]';


   FrmMain.StatusBar1.Panels[3].Text :=
      'Width: ' + IntToStr(FrmMain.SHP.Header.Width) + ' Height: ' +
      IntToStr(FrmMain.SHP.Header.Height);

   FrmMain.SetShadowMode(HasShadows(FrmMain.SHP));

   FrmMain.lbl_total_frames.Caption := IntToStr(FrmMain.SHP.Header.NumImages);
   FrmPreview.TrackBar1.Position    := 1;

   if FrmMain.Shadowmode then
      FrmPreview.TrackBar1.Max := FrmMain.SHP.Header.NumImages div 2
   else
      FrmPreview.TrackBar1.Max := FrmMain.SHP.Header.NumImages;

   FrmMain.StatusBar1.Panels[1].Text := 'SHP Type: ' + GetSHPType(FrmMain.SHP);

   FrmMain.SetIsEditable(True);

   FrmMain.Current_Frame.Value := 1;
   FrmMain.Current_FrameChange(Sender);
   FrmPreview.TrackBar1Change(Sender);

   // if ProgressBar.Visible = true then
   ProgressBar.Visible := False;
   Close;

end;

procedure TFrmImportImageAsSHP.MassLoadImage;
var
   x:      integer;
   temp, filename: string;
   ImageList: TStringList;
   Bitmap: TBitmap;
begin

   ImageList := TStringList.Create;

   // these files all files in the dir image*.bmp (so, it gets 0000, to XXXX)
   FileListBox.Directory := ExtractFileDir(Image_Location.Text);
   FileListBox.mask      := copy(Image_Location.Text, 0, length(Image_Location.Text) -
      length('0000' + ExtractFileExt(Image_Location.Text))) + '*' +
      ExtractFileExt(Image_Location.Text);

   // removes the 0000 from filename, so, you can load 0000 to XXXX (check below)
   filename := copy(extractfilename(Image_Location.Text), 0, length(
      extractfilename(Image_Location.Text)) - length('0000' + ExtractFileExt(
      Image_Location.Text)));

   // this is probably a hack to avoid problems on loading
   // on root like C:\image 0000.bmp, D:\image 0000.bmp, etc...
   if not (copy(FileListBox.Directory, length(FileListBox.Directory), 1) = '\') then
      filename := '\' + filename;

   // create bitmap part...
   Bitmap := TBitmap.Create;
   Bitmap := GetBMPFromImageFile(Image_Location.Text);
   // Load first Frame so we can get width and height

   // auto gets background colour, by checking first element.
   // This is dangerous for cameos.
   bgcolour := Bitmap.Canvas.Pixels[0, 0];

   // initialize a new SHP file.
   NewSHP(FrmMain.SHP, FileListBox.Items.Count, Bitmap.Width, Bitmap.Height);
   ImageList.Clear;

   // Fixes prob with mask system finding wrong files.
   for x := 0 to FileListBox.Items.Count - 1 do
   begin
      temp := IntToStr(x);
      if length(temp) < 4 then
         repeat
            Temp := '0' + Temp;
         until length(temp) = 4;

      if fileexists(FileListBox.Directory + filename + temp + ExtractFileExt(
         Image_Location.Text)) then
         ImageList.Add(FileListBox.Directory + filename + temp + ExtractFileExt(
            Image_Location.Text));
   end;

   // Incase they were set wrong, reset them.
   FrmMain.SHP.Header.NumImages := ImageList.Count;
   SetLength(FrmMain.SHP.Data, FrmMain.SHP.Header.NumImages + 1);

   // shows and set Progress bar to user
   ProgressBar.Visible  := True;
   ProgressBar.Max      := ImageList.Count - 1;
   ProgressBar.Position := 0;

   // This is where we start loading frame by frame.
   for x := 0 to ImageList.Count - 1 do
   begin
      ProgressBar.Position := x;

      Bitmap := GetBMPFromImageFile(ImageList.Strings[x]);

      // Sets the algorythim to be used. 1 = Stu's (R, G, B)
      // and 2 = Banshee's (R + G + B)
      if RadioButton1.Checked then
         SetFrameImageFrmBMP2(FrmMain.SHP, x + 1, SHPPalette, Bitmap, BGColour, 1, False)
      else
         SetFrameImageFrmBMP2(FrmMain.SHP, x + 1, SHPPalette, Bitmap, BGColour, 2, False);
   end;
end;

procedure TFrmImportImageAsSHP.SingleLoadImage;
var
   Bitmap: TBitmap;
begin
   // create bitmap part...
   Bitmap := TBitmap.Create;
   Bitmap := GetBMPFromImageFile(Image_Location.Text);
   // Load first Frame so we can get width and height

   // auto gets background colour, by checking first
   // element. This is dangerous for cameos.
   bgcolour := Bitmap.Canvas.Pixels[0, 0];

   // Set SHP file and avoid access violations
   NewSHP(FrmMain.SHP, 1, Bitmap.Width, Bitmap.Height);
   SetLength(FrmMain.SHP.Data, FrmMain.SHP.Header.NumImages + 1);

   // Set algorithym to be used
   if RadioButton1.Checked then
      SetFrameImageFrmBMP2(FrmMain.SHP, 1, SHPPalette, Bitmap, BGColour, 1, False)
   else
      SetFrameImageFrmBMP2(FrmMain.SHP, 1, SHPPalette, Bitmap, BGColour, 2, False);
end;

procedure TFrmImportImageAsSHP.FormShow(Sender: TObject);
begin
   //Manual_Colour_Match.Checked := false;
   Image_Location.Text := '';
end;

end.
