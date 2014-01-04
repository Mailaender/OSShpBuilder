unit FormImportImageAsSHP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ExtDlgs, FileCtrl,shp_file,shp_engine,palette,
  Shp_Image_Save_Load, ComCtrls, math, Spin,Undo_Redo, SHP_Engine_CCMs,
  SHP_Engine_Resize, SHP_Shadows, SHP_Colour_Bank, Colour_list, SHP_DataMatrix,
  FormCanvasResize,SHP_Canvas, SHP_Frame, OSExtDlgs, FormInstall, XPMan;

Const
  cINFANTRY = 0;
  cBUILDING = 1;
  cISOBUILDING = 2;
  cBUILDANIM = 3;
  cANIMATION = 4;
  cCAMEO = 5;
  cHYBRID = 6;
  c1TEMPERATE = 0;
  c1SNOW = 1;
  c1URBAN = 2;
  c1DESERT = 3;
  c1LUNAR = 4;
  c1NEWURBAN = 5;

  // shp Game IndeX
  GIX_TD = 0;
  GIX_RA1 = 1;
  GIX_TS = 2;
  GIX_RA2 = 3;
  GIX_NONE = 4;

  // shp Type IndeX
  TIX_AUTO = 0;
  TIX_UNIT = 1; // Infantry also falls here
  TIX_BUILDING = 2;
  TIX_BUILDANIM = 3;
  TIX_ANIMATION = 4;
  TIX_CAMEO = 5;
  TIX_TEM = 6;
  TIX_SNO = 7; // TD Winter falls here
  TIX_URB = 8; // RA1 Interior falls here
  TIX_DES = 9;
  TIX_LUN = 10;
  TIX_UBN = 11;
type
  TDataList = array of pointer;

  TFrmImportImageAsSHP = class(TForm)
    BtOK: TButton;
    Button3: TButton;
    Bevel1: TBevel;
    OpenPictureDialog: TOpenPictureDialog;
    FileListBox: TFileListBox;
    ProgressBar: TProgressBar;
    OpenPictureDialog1: TOpenPictureDialog;
    ColorDialog1: TColorDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label1: TLabel;
    Button1: TButton;
    Image_Location: TEdit;
    cbMode: TCheckBox;
    Label8: TLabel;
    ColourConversionBox: TPanel;
    ccmInfurion: TRadioButton;
    ccmBanshee3: TRadioButton;
    ccmBanshee2: TRadioButton;
    Label9: TLabel;
    BackgroundOverrideBox: TPanel;
    bcNone: TRadioButton;
    bcAutoSelect: TRadioButton;
    bcCustom: TRadioButton;
    bcDefault: TRadioButton;
    bcColourEdit: TPanel;
    TabSheet4: TTabSheet;
    SplitShadowBox: TPanel;
    ssRedToRemap: TCheckBox;
    ssIgnoreLastColours: TCheckBox;
    ssShadow: TCheckBox;
    Label7: TLabel;
    ConversionOptimizeBox: TPanel;
    ocfStyle: TComboBox;
    ocfComboOptions: TComboBox;
    Label10: TLabel;
    ConversionRangeBox: TPanel;
    Label3: TLabel;
    crFrom: TSpinEdit;
    crTo: TSpinEdit;
    crCustomFrames: TRadioButton;
    crAllFrames: TRadioButton;
    Label11: TLabel;
    Label2: TLabel;
    ResizeOrCanvasBox: TPanel;
    rocResize: TRadioButton;
    rocMCCanvas: TRadioButton;
    FramesSize: TPanel;
    fszAuto: TRadioButton;
    fszCustom: TRadioButton;
    fszWidth: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    fszHeight: TSpinEdit;
    DitheringCheck: TCheckBox;
    Label6: TLabel;
    Panel1: TPanel;
    Label14: TLabel;
    LbTechPal: TLabel;
    CboxUseTech: TCheckBox;
    CbxPalette: TComboBoxEx;
    CbxTechPalette: TComboBoxEx;
    CbxOptGame: TComboBoxEx;
    Label15: TLabel;
    CbTarget: TComboBox;
    LbTargetFrame: TLabel;
    SpeTargetFrame: TSpinEdit;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ItsBox: TPanel;
    Label20: TLabel;
    itsAS00: TRadioButton;
    itsASTransparent: TRadioButton;
    ssSplitShadows: TCheckBox;
    SHPIDOptions: TPanel;
    Label12: TLabel;
    CbxSHPGame: TComboBoxEx;
    Label13: TLabel;
    CbxSHPType: TComboBoxEx;
    ccmStructuralis: TRadioButton;
    XPManifest: TXPManifest;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SingleLoadImage(var SHP : TSHP; var Start:colour_element; var List,Last:listed_colour; alg:byte);
    procedure MassLoadImage(var SHP : TSHP; var BStart:colour_element; var List,Last:listed_colour; alg:byte);
    procedure bcColourEditChange(Sender: TObject);
    procedure bcAutoSelectClick(Sender: TObject);
    procedure bcDefaultClick(Sender: TObject);
    procedure bcCustomClick(Sender: TObject);
    procedure bcNoneClick(Sender: TObject);
    procedure AutoSelectBackground; overload;
    procedure AutoSelectBackground2(const Bitmap:TBitmap);
    procedure ocfComboOptionsChange(Sender: TObject);
    procedure fszWidthExit(Sender: TObject);
    procedure fszHeightExit(Sender: TObject);
    procedure fszHeightChange(Sender: TObject);
    procedure fszAutoClick(Sender: TObject);
    procedure SetAutoSizes;
    procedure SetAutoSizes2(Bitmap:TBitmap);
    procedure ocfStyleChange(Sender: TObject);
    procedure CallForCanvas(var Bitmap:TBitmap; const Width,Height:Word);
    procedure cbModeClick(Sender: TObject);
    procedure CbxSHPGameChange(Sender: TObject);
    function GetComboBoxNoFromString(filename:string; default : string; game: string): cardinal;
    procedure CbxOptGameChange(Sender: TObject);
    procedure CboxUseTechClick(Sender: TObject);
    procedure BuildTargetCombo();
    procedure CbTargetChange(Sender: TObject);
    procedure crToChange(Sender: TObject);
    procedure crFromChange(Sender: TObject);
    procedure SpeTargetFrameChange(Sender: TObject);
    procedure itsAS00Click(Sender: TObject);
    procedure itsASTransparentClick(Sender: TObject);
  private
    { Private declarations }
    pal_dir : String[3];
    pal_prefix : String;
    pal_sufix : String[3];
    bgcolour : Tcolor;
    maxframes : integer;
    SHPPalette : TPalette;
    DataList : TDataList;
    Data_No : Integer;
    procedure AutoSelectBackground(const Filename : string; Frame : integer); overload;
  public
    { Public declarations }
    mode : integer;
  end;

implementation

uses FormMain, FormPreview{, FormManualColourMatch};

{$R *.dfm}

procedure TFrmImportImageAsSHP.Button3Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmImportImageAsSHP.Button1Click(Sender: TObject);
var
   x:integer;
   temp,ext,filename : string;
   ImageList : TStringList;
   Bitmap:TBitmap;
begin
   if cbMode.Checked then
   begin
      OpenPictureDialog.InitialDir := FrmMain.ImportDir;
      if OpenPictureDialog.Execute then
      begin
         if fileexists(OpenPictureDialog.FileName) then
         begin
            Image_Location.Text := OpenPictureDialog.FileName;

            ext := AnsiLowerCase(ExtractFileExt(Image_Location.Text));
            if CompareStr(ext,'.gif') = 0 then
            begin
               // GIF code here:
               maxframes := GetNumberOfFramesFromGif(Image_Location.Text);
               // Enable AutoSelect Background options.
               ItsBox.Enabled := true;
               itsASTransparent.Checked := true;
            end
            else
            begin
               // First Part:
               // The following code detects the max ammount of
               // frames

               // Creates the string list
               ImageList := TStringList.Create;

               // these files all files in the dir image*.bmp
               // (so, it gets 0000, to XXXX)
               FileListBox.Directory := ExtractFileDir(Image_Location.Text);
               FileListBox.mask := copy(Image_Location.Text,0,length(Image_Location.Text)- length('0000' +ExtractFileExt(Image_Location.Text)))+'*' + ExtractFileExt(Image_Location.Text);

               // removes the 0000 and extension from filename,
               // so, you can load 0000 to XXXX (check below)
               filename := copy(extractfilename(Image_Location.Text),0,length(extractfilename(Image_Location.Text))-length('0000'+ExtractFileExt(Image_Location.Text)));

               // this is probably a hack to avoid problems on loading
               // on root like C:\image 0000.bmp, D:\image 0000.bmp, etc...
               if not (copy(FileListBox.Directory,length(FileListBox.Directory),1) = '\') then
                  filename := '\' + filename;

               ImageList.Clear;

               // Fixes prob with mask system finding wrong files.
               For x := 0 to FileListBox.Items.Count-1 do
               begin
                  temp := inttostr(x);
                  if length(temp) < 4 then
                     repeat
                        Temp := '0' + Temp;
                     until length(temp) = 4;

                  if fileexists(FileListBox.Directory+filename+temp+ExtractFileExt(Image_Location.Text)) then
                     ImageList.Add(FileListBox.Directory+filename+temp+ExtractFileExt(Image_Location.Text));
               end;
               maxframes := ImageList.Count;
               // Check AutoSelect Background options.
               // Enable for PNG
               if CompareStr(ext,'.png') = 0 then
               begin
                  ItsBox.Enabled := true;
                  itsASTransparent.Checked := true;
               end
               else // Disable for others.
               begin
                  ItsBox.Enabled := false;
                  itsAS00.Checked := true;
               end;

            end;
            crFrom.MaxValue := maxframes-1;
            crTo.MaxValue := maxframes-1;

            // Second Part: Interface
            // Enable Options
            ConversionRangeBox.Enabled := true;
            CboxUseTech.Enabled := true;
            CboxUseTechClick(sender);

            // Code below selects all frames and adds the max
            // frame in the Conversion Range settings
            crTo.Value := maxframes - 1;
         end
         else // user put an invalid filename
         begin
            exit;
         end;
      end
      else // user press cancel
      begin
         exit;
      end;
   end
   else
   begin
      OpenPictureDialog1.InitialDir := FrmMain.ImportDir;
      if OpenPictureDialog1.Execute then
      begin
         if fileexists(OpenPictureDialog1.FileName) then
         begin
            Image_Location.Text := OpenPictureDialog1.FileName;

            // Code below adds the max frame in the Conversion
            // Range settings
            crTo.Value := 0;
            maxframes := 1;

            // Interface Stuff
            // Enable Options
            ConversionRangeBox.Enabled := false;
            CboxUseTech.Enabled := false;
            CboxUseTechClick(sender);
         end
         else // user places invalid file
         begin
            exit;
         end;
      end
      else // User press cancel
      begin
         exit;
      end;
   end;

   // For both modes:

   // Enable Options
   ConversionOptimizeBox.Enabled := true;
   ColourConversionBox.Enabled := true;
   ConversionOptimizeBox.Enabled := true;
   BackgroundOverrideBox.Enabled := true;
   bcColourEdit.Enabled := true;
   BtOK.Enabled := true;
   SplitShadowBox.Enabled := true;
   FramesSize.Enabled := true;
   ResizeOrCanvasBox.Enabled := true;
   CbxPalette.Enabled := true;
   CbTarget.Enabled := true;
   CbxSHPGame.Enabled := true;
   CbxSHPType.Enabled := true;
   SHPIDOptions.Enabled := true;
   CbxOptGame.Enabled := true;
   CbxOptGame.ItemIndex := GIX_NONE;

// Load first Frame so we check size and autoselect colour;
   Bitmap := GetBMPFromImageFile(Image_Location.Text);
   FrmMain.ImportDir := extractfiledir(Image_Location.Text);

// Code below runs 'AutoSelect' if that was used in the last time
   if bcAutoSelect.Checked then
      AutoSelectBackground2(Bitmap);

// Set default values for Frames Size
   SetAutoSizes2(Bitmap);

// Get rid of Bitmap:
   Bitmap.Free;

// Sets 'All frames' as default for conversion range
  crAllFrames.Checked := true;
  crFrom.Value := 0;
end;

function colourtogray(colour : cardinal): cardinal;
var
   temp : char;
begin
   temp := char((GetBValue(colour)*29 + GetGValue(colour)*150 + GetRValue(colour)*77) DIV 256);
   Result := RGB(ord(temp),ord(temp),ord(temp));
end;

Function GrayBitmap(var Bitmap:TBitmap; const x,y : integer) : Tbitmap;
var
   Temp : Tbitmap;
   xx,yy : integer;
begin
   Temp := TBitmap.Create;

   Temp.Width := Bitmap.Width;
   Temp.Height := Bitmap.Height;

   for xx := 0 to Bitmap.Width-1 do
   for yy := 0 to Bitmap.Height-1 do
   if ((xx <> x) and (yy <> y)) or ((xx = x) and (yy = y)) then
      Temp.Canvas.Pixels[xx,yy] := Bitmap.Canvas.Pixels[xx,yy]
   else
      Temp.Canvas.Pixels[xx,yy] := colourtogray(Bitmap.Canvas.Pixels[xx,yy]);

   Result := Temp;
end;


procedure TFrmImportImageAsSHP.BtOKClick(Sender: TObject);
var
   alg : integer;
   Bitmap : TBitmap;
   Start : colour_element;
   List,Last : listed_colour;
   Data : TSHPImageData;
   SHP : TSHP;
   MyData : TSHPImageData;
   OldFrames,Counter : longword;
   FrmInstall: TFrmRepairAssistant;
begin
   Bitmap := GetBMPFromImageFile(Image_Location.Text);  // Load for autoselect

{
   if fileexists(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename) then
      GetPaletteFromFile(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename,SHPPalette)
   else
   begin
      ShowMessage('Error! Palette not found! Please, restore it or reinstall ' + SHP_BUILDER_TITLE + '. The program will use unittem.pal from TS.');
      GetPaletteFromFile(extractfiledir(ParamStr(0))+'\Palettes\TS\unittem.pal',SHPPalette);
   end;
}
   // Set palette
   if not fileexists(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename) then
   begin
      FrmInstall := TFrmRepairAssistant.Create(self);
      FrmInstall.ShowModal;
      FrmInstall.Release;
      if not fileexists(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename) then
      begin
         Application.Terminate;
         exit;
      end;
   end;
   GetPaletteFromFile(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename,SHPPalette);

   // Prepare The Colour List and Colour Banks
   GenerateColourList(SHPPalette,List,Last,BGColour,bcNone.Checked,(ssShadow.Enabled and ssShadow.Checked),(ssIgnoreLastColours.Enabled and ssIgnoreLastColours.Checked),(ssRedToRemap.Enabled and ssRedToRemap.Checked));
   PrepareBank(Start,List,Last);

   // Set algorithm to be used
{   if ccmAutoSelect.Checked then
   begin
      alg := AutoSelectALG_Progress(ProgressBar,Bitmap,SHPPalette,List,Last);
      showmessage('Selected Colour Conversion Mode: ' + inttostr(alg)); //Enable to debug auto select
   end
   else if ccmStu.Checked then
      alg := 1
   else if ccmStu2.Checked then
      alg := 2
   else if ccmBanshee.Checked then
      alg := 3
   else} if ccmBanshee2.Checked then
      alg := 4
   else if ccmBanshee3.Checked then
      alg := 5
   else if ccmStructuralis.Checked then
      alg := 7
   else  // Infurium
      alg := Infurium;

   ProgressBar.Visible := false;

   Bitmap.Free;

   // If file doesnt exist, it gives an error message.
   if not fileexists(Image_Location.Text) then
   begin
      MessageBox(0,'Error: No Valid Image Location Specified','Import Error',0);
      Exit;
   end;

   // this will convert the image.
   if (cbMode.Checked) then
      MassLoadImage(SHP,Start,List,Last,alg)
   else
      SingleLoadImage(SHP,Start,List,Last,alg);

   // Remove the trash:
   ClearColourList(List,Last);
   ClearBank(Start);

   // Locks FormMain until it's set to the new file
   FrmMain.SetIsEditable(False);

   // Generate an SHP
   if (CbTarget.ItemIndex = Data_No) then
   begin // New SHP
      if AddNewSHPDataItem(Data,FrmMain.TotalImages,SHP,SHPPalette,FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename,CbxSHPGame.ItemIndex,CbxSHPType.ItemIndex) then
      begin
         // Generate New Window
         if FrmMain.GenerateNewWindow(Data) then
         begin
            // Set new palette (when it changes)
            //   FrmMain.SetPalette(extractfiledir(ParamStr(0))+'\Palettes\' + pal_dir + '\' + pal_prefix + pal_sufix + '.pal');
            FrmMain.lblPalette.Caption := ' Palette - '+ ExtractFileName(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename);

            LoadNewSHPImageSettings(Data,FrmMain.ActiveForm^);
         end
         else
         begin
            ClearUpData(Data);
            ShowMessage('MDI Error! Import failed to create window due to lack of memory.');
            if MainData^.Next <> nil then
               FrmMain.SetIsEditable(True);
            close;
         end;
      end
      else
      begin
         ShowMessage('Warning: Import failed due to lack of memory!');
         if MainData^.Next <> nil then
            FrmMain.SetIsEditable(True);
         close;
      end;
   end
   else // Existing SHP
   begin
      // We move up the SHP.Header.NumImages frames, starting from Target Frame
      // the source.
      MyData := DataList[CbTarget.ItemIndex];

      // First time, check up Split Shadows:
      // The user may change the ammount of frames in the interval
      if (ssSplitShadows.Enabled = true) and (ssSplitShadows.Checked = true) then
         if (SHP.Header.NumImages mod 2 <> 0) or (MyData^.SHP.Header.NumImages mod 2 <> 0) then
         begin
             ShowMessage('Notice: Split Shadows feature was disabled. It can only split shadows with even frames, no odds.');
             ssSplitShadows.Checked := false;
         end;
      // If Split shadows
      if (ssSplitShadows.Enabled = true) and (ssSplitShadows.Checked = true) then
      begin
         // Add Undo Item
         AddToUndoBlankFrame(MyData^.UndoList,speTargetFrame.Value,speTargetFrame.Value + SHP.Header.NumImages - 1,(MyData^.SHP.Header.NumImages div 2) + speTargetFrame.Value + SHP.Header.NumImages - 1);
         // Get OldFrames.
         OldFrames := MyData^.SHP.Header.NumImages;
         // Generate blank frames
         MoveSeveralFrameImagesUp(MyData^.SHP,speTargetFrame.Value,(SHP.Header.NumImages div 2));
         MoveSeveralFrameImagesUp(MyData^.SHP,(OldFrames div 2) + speTargetFrame.Value + (SHP.Header.NumImages div 2),(SHP.Header.NumImages div 2));

         // Paste buffer on blank frames
         For Counter := 0 to (SHP.Header.NumImages div 2)-1 do
         begin
            MyData^.SHP.Data[speTargetFrame.Value + Counter].FrameImage := copy(SHP.Data[Counter+1].FrameImage);
            MyData^.SHP.Data[(MyData^.SHP.Header.NumImages div 2) + speTargetFrame.Value + Counter].FrameImage := copy(SHP.Data[(SHP.Header.NumImages div 2) + Counter + 1].FrameImage);
         end;
      end
      else
      begin
         // Add Undo Item
         AddToUndoBlankFrame(MyData^.UndoList,speTargetFrame.Value,speTargetFrame.Value + SHP.Header.NumImages - 1,false);

         // Generate blank frames
         MoveSeveralFrameImagesUp(MyData^.SHP,speTargetFrame.Value,SHP.Header.NumImages);

         // Paste buffer on blank frames
         For Counter := 0 to SHP.Header.NumImages-1 do
         begin
            MyData^.SHP.Data[speTargetFrame.Value + Counter].FrameImage := copy(SHP.Data[Counter+1].FrameImage);
         end;
     end;
     // Moving pointers to selected data.
     FrmMain.ActiveData := MyData;
     FrmMain.ActiveForm := Addr(MyData^.Form^.Item);

      FrmMain.SetIsEditable(True);

      FrmMain.ActiveForm^.SetShadowMode(FrmMain.ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
      FrmMain.UndoUpdate(MyData^.UndoList);
   end;

   Close;
end;

procedure TFrmImportImageAsSHP.MassLoadImage(var SHP : TSHP; var BStart:colour_element; var List,Last:listed_colour; alg:byte);
var
   start,final,x: integer;
   ImageList : TStringList;
   ext,temp,filename : string;
   Bitmap : TBitmap;
begin
   // initialize a new SHP file.
   NewSHP(SHP,maxframes,fszWidth.Value,fszHeight.Value);

   // Creates the string list
   ImageList := TStringList.Create;
   ext := AnsiLowerCase(ExtractFileExt(Image_Location.Text));
   if CompareStr(ext,'.gif') <> 0 then
   begin
      // these files all files in the dir image*.bmp (so, it gets 0000, to XXXX)
      FileListBox.Directory := ExtractFileDir(Image_Location.Text);
      FileListBox.mask := copy(Image_Location.Text,0,length(Image_Location.Text)- length('0000' +ExtractFileExt(Image_Location.Text)))+'*' + ExtractFileExt(Image_Location.Text);

      // removes the 0000 and extension from filename, so, you can load 0000 to XXXX (check below)
      filename := copy(extractfilename(Image_Location.Text),0,length(extractfilename(Image_Location.Text))-length('0000'+ExtractFileExt(Image_Location.Text)));

      // this is probably a hack to avoid problems on loading
      // on root like C:\image 0000.bmp, D:\image 0000.bmp, etc...
      if not (copy(FileListBox.Directory,length(FileListBox.Directory),1) = '\') then
         filename := '\' + filename;

      // Clear ImageList to start re-check
      ImageList.Clear;

      // Fixes prob with mask system finding wrong files.
      For x := 0 to FileListBox.Items.Count-1 do
      begin
         temp := inttostr(x);
         if length(temp) < 4 then
         repeat
            Temp := '0' + Temp;
         until length(temp) = 4;

         if fileexists(FileListBox.Directory+filename+temp+ExtractFileExt(Image_Location.Text)) then
            ImageList.Add(FileListBox.Directory+filename+temp+ExtractFileExt(Image_Location.Text));
      end;
   end;

   // Check the conversion range
   if crCustomFrames.Checked then
   begin
      start := Min(crFrom.Value,crTo.Value);
      final := Max(crFrom.Value,crTo.Value);
   end
   else
   begin
      start := 0;
      if maxframes <> 0 then
         final := maxframes-1
      else
         final := 0;
   end;

   // shows and set Progress bar to user
   ProgressBar.Visible := true;
   ProgressBar.Max := final - start + 1;
   ProgressBar.Position := 0;

   // Incase they were set wrong, reset them.
   SHP.Header.NumImages := (final - start) + 1;
   SetLength(SHP.Data,SHP.Header.NumImages+1);

   // This is where we start loading frame by frame. First, non frames
   For x := start to (start + ((final - start) div 2)) do
   begin
      ProgressBar.Position := x - start;

      if CompareStr(ext,'.gif') <> 0 then
         Bitmap := GetBMPFromImageFile(ImageList.Strings[x])
      else
      begin
         Bitmap := GetBMPFromImageFile(Image_Location.Text,x);
         AutoSelectBackground(Image_Location.Text,x);
      end;
      // Now it checks if the bitmap picture fits the size
      // of the SHP.
      if (Bitmap.Width <> fszWidth.Value) or (Bitmap.Height <> fszHeight.Value) then
      begin
         if rocresize.Checked then
            Resize_Bitmap_Blocky(Bitmap,fszWidth.Value,fszHeight.Value)
         else
            CallForCanvas(Bitmap,fszWidth.Value,fszHeight.Value);
      end;

        // Checks for Hybrid palettes from Tech Buildings
       if CboxUseTech.Checked then
          if ((x - start) = 3) then
             if fileexists(FrmMain.paletteschemes[CbxTechPalette.ItemIndex+1].filename) then
             begin
                ClearColourList(List,Last);
                ClearBank(BStart);
                GetPaletteFromFile(FrmMain.paletteschemes[CbxTechPalette.ItemIndex+1].filename,SHPPalette);
                GenerateColourList(SHPPalette,List,Last,BGColour,bcNone.Checked,(ssShadow.Enabled and ssShadow.Checked),(ssIgnoreLastColours.Enabled and ssIgnoreLastColours.Checked),(ssRedToRemap.Enabled and ssRedToRemap.Checked));
                PrepareBank(BStart,List,Last);
             end
          else
             if fileexists(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename) then
             begin
                ClearColourList(List,Last);
                ClearBank(BStart);
                GetPaletteFromFile(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename,SHPPalette);
                GenerateColourList(SHPPalette,List,Last,BGColour,bcNone.Checked,(ssShadow.Enabled and ssShadow.Checked),(ssIgnoreLastColours.Enabled and ssIgnoreLastColours.Checked),(ssRedToRemap.Enabled and ssRedToRemap.Checked));
                PrepareBank(BStart,List,Last);
             end;
      // Load frame
      LoadFrameImageToSHP(SHP,(x - start) +1,Bitmap,List,Last,BStart,alg,DitheringCheck.Checked);
   end;
   // Import Shadow Part (if it really wants shadow)
   For x := (start + ((final - start) div 2)) + 1 to final do
   begin
      ProgressBar.Position := x - start;

      if CompareStr(ext,'.gif') <> 0 then
         Bitmap := GetBMPFromImageFile(ImageList.Strings[x])
      else
         Bitmap := GetBMPFromImageFile(Image_Location.Text,x);

      // Now it checks if the bitmap picture fits the size
      // of the SHP.
      if (Bitmap.Width <> fszWidth.Value) or (Bitmap.Height <> fszHeight.Value) then
      begin
         if rocresize.Checked then
            Resize_Bitmap_Blocky(Bitmap,fszWidth.Value,fszHeight.Value)
         else
         begin
            CallForCanvas(Bitmap,fszWidth.Value,fszHeight.Value);
         end;
      end;

        // Checks for Hybrid palettes from Tech Buildings
       if CboxUseTech.Checked then
          if ((x - start) = 7) then
            if fileexists(FrmMain.paletteschemes[CbxTechPalette.ItemIndex+1].filename) then
               GetPaletteFromFile(FrmMain.paletteschemes[CbxTechPalette.ItemIndex+1].filename,SHPPalette)
          else
             if fileexists(extractfiledir(ParamStr(0))+'\Palettes\RA2\unit' + pal_sufix + '.pal') then
                GetPaletteFromFile(extractfiledir(ParamStr(0))+'\Palettes\RA2\unit' + pal_sufix + '.pal',SHPPalette);

      // Load frame
       if not ssShadow.Checked then
          LoadFrameImageToSHP(SHP,(x - start) +1,Bitmap,List,Last,BStart,alg,DitheringCheck.Checked)
       else
          SetFrameImageFrmBMP2WithShadows(SHP,(x - start) + 1,Bitmap,BGColour);
   end;

   // Hybrid palettes always loads unittem.pal as default
   if CboxUseTech.Checked then
      GetPaletteFromFile(FrmMain.paletteschemes[CbxPalette.ItemIndex+1].filename,SHPPalette);
   // Free Btimap
   Bitmap.Free;
end;

procedure TFrmImportImageAsSHP.SingleLoadImage(var SHP : TSHP; var Start:colour_element; var List,Last:listed_colour; alg:byte);
type
   TRGBPixel = record
   r,g,b : Byte;
   end;
var
   Bitmap :TBitmap;
   x,y,xx,yy : integer;
   r,g,b : Byte;
   diff : Integer;
   Min,Max : TRGBPixel;
begin
   // Set SHP file and avoid access violations
   NewSHP(SHP,1,fszWidth.Value,fszHeight.Value);
   SetLength(SHP.Data,SHP.Header.NumImages+1);

   // Now it checks if the bitmap picture fits the size
   // of the SHP.
   Bitmap := GetBMPFromImageFile(Image_Location.Text);
   if (Bitmap.Width <> fszWidth.Value) or (Bitmap.Height <> fszHeight.Value) then
   begin
      if rocresize.Checked then
         Resize_Bitmap_Blocky(Bitmap,fszWidth.Value,fszHeight.Value)
      else
         CallForCanvas(Bitmap,fszWidth.Value,fszHeight.Value);
   end;

   // Set frame
   LoadFrameImageToSHP(SHP,1,Bitmap,List,Last,Start,alg,DitheringCheck.Checked);

  Bitmap.Free;
end;

procedure TFrmImportImageAsSHP.CallForCanvas(var Bitmap:TBitmap; const Width,Height:Word);
var
   FrmCanvasResize : TFrmCanvasResize;
   xb,xe,yb,ye:integer;
   w,h:word;
begin
   FrmCanvasResize := TFrmCanvasResize.Create(FrmMain);
   FrmCanvasResize.Bitmap := Bitmap;
   FrmCanvasResize.Height := Height;
   FrmCanvasResize.Width := Width;
   FrmCanvasResize.LockSize := true;
   FrmCanvasResize.ShowModal;
   if FrmCanvasResize.changed then
   begin
      xb := StrToIntDef(FrmCanvasResize.SpinL.text,0);
      xe := StrToIntDef(FrmCanvasResize.SpinR.Text,0);
      yb := StrToIntDef(FrmCanvasResize.SpinT.Text,0);
      ye := StrToIntDef(FrmCanvasResize.SpinB.Text,0);

      if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
      begin
         w := FrmCanvasResize.Bitmap.Width;
         h := FrmCanvasResize.Bitmap.Height;
         CanvasResize(Bitmap,w,h,-xb,-yb,xe,ye);
      end;
   end;
   FrmCanvasResize.Release;
end;



procedure TFrmImportImageAsSHP.FormShow(Sender: TObject);
var
   x : longword;
begin
   PageControl1.ActivePage := TabSheet1;
   PageControl1.TabIndex := 0;
   TabSheet1.Visible := true;

   //Manual_Colour_Match.Checked := false;
   Image_Location.Text := '';
   maxframes := 0;

   // Palette Checking
   if FileExists(FrmMain.ActiveData^.SHPPaletteFilename) then
      GetPaletteFromFile(FrmMain.ActiveData^.SHPPaletteFilename,SHPPalette)
   else
      GetPaletteFromFile(MainData^.SHPPaletteFilename,SHPPalette);

   // Disable Options
   ConversionOptimizeBox.Enabled := false;
   ConversionRangeBox.Enabled := false;
   ColourConversionBox.Enabled := false;
   ConversionOptimizeBox.Enabled := false;
   BackgroundOverrideBox.Enabled := false;
   bcColourEdit.Enabled := false;
   BtOK.Enabled := false;
   SplitShadowBox.Enabled := false;
   ResizeOrCanvasBox.Enabled := false;
   // 3.35: Aditions:
   CbxTechPalette.Enabled := false;
   LbTechPal.Enabled := false;
   CbxPalette.Enabled := false;
   CbTarget.Enabled := false;
   CbxOptGame.Enabled := false;
   CbxOptGame.ItemIndex := GIX_NONE;
   ItsBox.Enabled := false;
   itsAS00.Checked := true;

   // Check Box Mode settings
   cbMode.Checked := true;

   case (FrmMain.alg) of
      0: ccmStructuralis.Checked := true; // ccmAutoSelect.Checked := true;
      1: ccmStructuralis.Checked := true;
      2: ccmStructuralis.Checked := true;
      3: ccmStructuralis.Checked := true;
      4: ccmBanshee2.Checked := true;
      5: ccmBanshee3.Checked := true;
      7: ccmStructuralis.Checked := true;
      Infurium: ccmInfurion.Checked := true;
   else
      ccmStructuralis.Checked := true; // ccmAutoSelect.Checked := true;
   end;

   // 3.35: Fill Palettes:
   for x := 1 to FrmMain.PaletteSchemes_no do
   begin
      CbxPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      CbxPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      CbxTechPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      CbxTechPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;
   end;
   CbxPalette.ItemIndex := GetComboBoxNoFromString(FrmMain.ActiveData^.SHPPaletteFilename,'unittem.pal','ts');
   CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','isotem.pal','ra2');

   // 3.35: Update Game & Type at Extra Settings
   CbxSHPGame.ItemIndex := 2; // Default is TS.
   CbxSHPGameChange(sender);
   CbxSHPType.ItemIndex := 0; // Any (Auto);
   // Keep 'em disabled.
   SHPIDOptions.Enabled := false;

   // 3.35: Build target combobox.
   BuildTargetCombo;
   CbTarget.ItemIndex := Data_No;
   CbTargetChange(sender);
end;

// 3.35: This function gets the combo value from a palette.
// Copied from Preferences.
function TFrmImportImageAsSHP.GetComboBoxNoFromString(filename:string; default : string; game: string): cardinal;
var
   f_name : string;
   x : integer;
begin
   f_name := ansilowercase(filename);
   result := 0;
   for x := 1 to FrmMain.PaletteSchemes_no do
      if ansilowercase(FrmMain.PaletteSchemes[x].Filename) = f_name then
      begin
         result := x-1;
         exit;
      end;
   // Try default;
   f_name := ExtractFileDir(ParamStr(0)) + '\Palettes\' + game + '\' + default;
   f_name := ansilowercase(f_name);
   for x := 1 to FrmMain.PaletteSchemes_no do
      if ansilowercase(FrmMain.PaletteSchemes[x].Filename) = f_name then
      begin
         result := x-1;
         exit;
      end;
end;

// 3.35: Get all opened files. Code imported from 3.4 Beta
procedure TFrmImportImageAsSHP.BuildTargetCombo();
var
   MyData : TSHPImageData;
begin
   // Fill the Paste To File part:
   MyData := MainData^.Next;
   Data_No := 0;
   while MyData <> nil do
   begin
      // Add data option to user
      if MyData^.Filename <> '' then
         CbTarget.Items.Add(MyData^.Filename)
      else
         CbTarget.Items.Add('Untitled ' + inttostr(MyData^.ID));

      // Add data option to computer
      setlength(DataList,Data_No+1);
      DataList[Data_No] := MyData;
      inc(Data_No);

      // go to the next data
      MyData := MyData^.Next;
   end;

   // Now it adds a "New SHP" option
   CbTarget.Items.Add('New SHP File');
   setlength(DataList,Data_No+1);
   DataList[Data_No] := nil;
end;

procedure TFrmImportImageAsSHP.bcColourEditChange(Sender: TObject);
begin
   if ColorDialog1.Execute then
   begin
      bcColourEdit.Color := ColorDialog1.Color;
      // If you click at the colour, it auto-sets to custom
      // Leave it in that way.
      bcCustom.Checked := true;
      bgcolour := ColorDialog1.Color;
   end;
end;

procedure TFrmImportImageAsSHP.bcAutoSelectClick(Sender: TObject);
begin
   AutoSelectBackground;
   ssShadow.Enabled := true;
   ssIgnoreLastColours.Enabled := true;
end;

procedure TFrmImportImageAsSHP.bcDefaultClick(Sender: TObject);
var
   CustomPalette : TPalette;
begin
   if CbxOptGame.ItemIndex <> GIX_NONE then
   begin
      // Load Palette:
      if fileexists(extractfiledir(ParamStr(0))+'\Palettes\'+ pal_dir + '\' + pal_prefix + pal_sufix + '.pal') then
         GetPaletteFromFile(extractfiledir(ParamStr(0))+'\Palettes\'+ pal_dir + '\' + pal_prefix + pal_sufix + '.pal',CustomPalette);
      bgcolour := CustomPalette[0];
   end
   else
      bgcolour := SHPPalette[0];
   bcColourEdit.Color := bgcolour;
   ssShadow.Enabled := true;
   ssIgnoreLastColours.Enabled := true;
end;

procedure TFrmImportImageAsSHP.bcCustomClick(Sender: TObject);
begin
   bgcolour := ColorDialog1.Color;
   bcColourEdit.Color := bgcolour;
   ssShadow.Enabled := true;
   ssIgnoreLastColours.Enabled := true;
end;

procedure TFrmImportImageAsSHP.bcNoneClick(Sender: TObject);
begin
  bcColourEdit.Color := clSilver;
  ssShadow.Enabled := false;
  ssIgnoreLastColours.Enabled := false;
end;

procedure TFrmImportImageAsSHP.AutoSelectBackground(const Filename : string; Frame : integer);
var
   Bitmap: TBitmap;
begin
   if itsAS00.Checked then
   begin
      // create bitmap part...
      Bitmap := GetBMPFromImageFile(Filename,Frame); // Load first Frame so we can get width and height

      // auto gets background colour, by checking first element.
      bgcolour := Bitmap.Canvas.Pixels[0,0];
      Bitmap.Free;
   end
   else
   begin
      bgcolour := GetTransparentFromBMP(Filename,Frame);
   end;
end;

procedure TFrmImportImageAsSHP.AutoSelectBackground;
var
   Bitmap: TBitmap;
begin
   AutoSelectBackground(Image_Location.Text,0);
   bcColourEdit.Color := bgcolour;
end;

procedure TFrmImportImageAsSHP.AutoSelectBackground2(const Bitmap:TBitmap);
begin
   // auto gets background colour, by checking first element.
   bgcolour := Bitmap.Canvas.Pixels[0,0];
   bcColourEdit.Color := bgcolour;
end;

procedure TFrmImportImageAsSHP.CbxOptGameChange(Sender: TObject);
begin
   // First of all, enable and clean combo box.
   ocfComboOptions.Enabled := (CbxOptGame.ItemIndex <> GIX_NONE);
   ocfComboOptions.Clear;

   // enable and clean StyleBox
   ocfStyle.Enabled := (CbxOptGame.ItemIndex <> GIX_NONE);
   ocfStyle.Clear;

   if CbxOptGame.ItemIndex <> GIX_NONE then
   begin
      // Add the options.
      ocfComboOptions.Items.Add('Infantry');
      ocfComboOptions.Items.Add('Buildings');
      ocfComboOptions.Items.Add('Isometric Buildings, Overlay');
      ocfComboOptions.Items.Add('Building Animations');
      ocfComboOptions.Items.Add('Animations');
      ocfComboOptions.Items.Add('Cameos');
      if CbxOptGame.ItemIndex = GIX_RA2 then
         ocfComboOptions.Items.Add('Tech Buildings w/ Wreckage');

      ocfComboOptions.Show;
      ocfComboOptions.SetFocus;
      ocfComboOptions.ItemIndex := 0;

      // Add the options.
      ocfStyle.Items.Add('Temperate');
      if CbxOptGame.ItemIndex = GIX_TD then
      begin
         ocfStyle.Items.Add('Winter');
         // Add Palette Settings:
         pal_dir := 'TD';
         CbxSHPGame.ItemIndex := GIX_TD;
      end
      else
      begin
         ocfStyle.Items.Add('Snow');
         if CbxOptGame.ItemIndex = GIX_RA1 then
         begin
            ocfStyle.Items.Add('Interior');
            // Add Palette Settings:
            pal_dir := 'RA1';
            CbxSHPGame.ItemIndex := GIX_RA1;
         end
         else if CbxOptGame.ItemIndex = GIX_RA2 then
         begin
            ocfStyle.Items.Add('Urban');
            ocfStyle.Items.Add('Desert');
            ocfStyle.Items.Add('Lunar');
            ocfStyle.Items.Add('New Urban');
            // Add Palette Settings:
            pal_dir := 'RA2';
            CbxSHPGame.ItemIndex := GIX_RA2;
         end
         else //TS
         begin
            // Add Palette Settings:
            pal_dir := 'TS';
            CbxSHPGame.ItemIndex := GIX_TS;
         end;
         CbxSHPGameChange(Sender);
      end;
      // Adds default style settings:
   end;
   ocfComboOptionsChange(Sender);
end;

procedure TFrmImportImageAsSHP.ocfComboOptionsChange(Sender: TObject);
begin
   // This will load a pre-defined setting selected by the user.
   // Note: Some might look the same, but they can be customized
   // later, so leave it as it is.

   if (ocfComboOptions.ItemIndex = -1) then
     ocfComboOptions.Hint := 'Nothing selected.';

   // Infantry?
   if (ocfComboOptions.ItemIndex = cINFANTRY) then
   begin
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'unit';
      ocfStyle.Enabled := true;
      if ocfStyle.ItemIndex = -1 then
         ocfStyle.ItemIndex := c1Temperate;
      crFrom.Value := 0;
      if maxframes > 0 then
         crTo.Value := maxframes - 1
      else
         crTo.Value := 0;
      ssShadow.Checked := (CbxOptGame.ItemIndex = GIX_TS) and (maxframes mod 2 = 0);
      ssIgnoreLastColours.Checked := false;
      ssRedToRemap.Checked := false;
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'This optimizes the import for infantry units by loading unittem.pal and optimized settings for it.';
      CbxSHPType.ItemIndex := TIX_UNIT;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Temperate Buildings?
   else if (ocfComboOptions.ItemIndex = cBUILDING) then
   begin
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'unit';
      ocfStyle.Enabled := true;
      if ocfStyle.ItemIndex = -1 then
         ocfStyle.ItemIndex := c1Temperate;
      crFrom.Value := 0;
      if maxframes > 0 then
         crTo.Value := maxframes - 1
      else
         crTo.Value := 0;
      ssShadow.Checked := (CbxOptGame.ItemIndex = GIX_TS)  and (maxframes mod 2 = 0);
      ssIgnoreLastColours.Checked := true;
      ssRedToRemap.Checked := ((CbxOptGame.ItemIndex = GIX_TS) or (CbxOptGame.ItemIndex = GIX_RA2));
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'This optimizes the import for temperate buildings by loading unittem.pal and optimized settings for it.';
      CbxSHPType.ItemIndex := TIX_BUILDING;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Isometric Buildings? Overlay?
   else if (ocfComboOptions.ItemIndex = cISOBUILDING) then
   begin
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'iso';
      ocfStyle.Enabled := true;
      if ocfStyle.ItemIndex = -1 then
         ocfStyle.ItemIndex := c1Temperate;
      crFrom.Value := 0;
      if maxframes > 0 then
         crTo.Value := maxframes - 1
      else
         crTo.Value := 0;
      ssShadow.Checked := (CbxOptGame.ItemIndex = GIX_TS) and (maxframes mod 2 = 0);
      ssIgnoreLastColours.Checked := false;
      ssRedToRemap.Checked := false;
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'This optimizes the import for isometric buildings by loading isotem.pal and optimized settings for it.';
      CbxSHPType.ItemIndex := TIX_TEM;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Build Animations
   else if (ocfComboOptions.ItemIndex = cBUILDANIM) then
   begin
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'unit';
      ocfStyle.Enabled := true;
      if ocfStyle.ItemIndex = -1 then
         ocfStyle.ItemIndex := c1Temperate;
      crFrom.Value := 0;
      if maxframes > 0 then
         crTo.Value := maxframes - 1
      else
         crTo.Value := 0;
      ssShadow.Checked := (CbxOptGame.ItemIndex = GIX_TS) and (maxframes mod 2 = 0);
      ssIgnoreLastColours.Checked := true;
      ssRedToRemap.Checked := ((CbxOptGame.ItemIndex = GIX_TS) or (CbxOptGame.ItemIndex = GIX_RA2));
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'This optimizes the import for temperate buildings by loading unittem.pal and optimized settings for it.';
      CbxSHPType.ItemIndex := TIX_BUILDANIM;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Animations?
   else if (ocfComboOptions.ItemIndex = cANIMATION) then
   begin
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'anim';
      pal_sufix := '';
      ocfStyle.ItemIndex := -1;
      ocfStyle.Enabled := false;
      crFrom.Value := 0;
      if maxframes > 0 then
         crTo.Value := maxframes - 1
      else
         crTo.Value := 0;
      ssShadow.Checked := false;
      ssIgnoreLastColours.Checked := false;
      ssRedToRemap.Checked := false;
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'This optimizes the import for animations by loading anim.pal and optimized settings for it.';
      CbxSHPType.ItemIndex := TIX_ANIMATION;
      case (CbxOptGame.ItemIndex) of
         GIX_TD:
         begin
            pal_dir := 'TD';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
         GIX_RA1:
         begin
            pal_dir := 'RA1';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
         GIX_TS:
         begin
            pal_dir := 'TS';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','anim.pal',pal_dir);
         end;
         GIX_RA2:
         begin
            pal_dir := 'RA2';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','anim.pal',pal_dir);
         end;
      end;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Cameos?
   else if (ocfComboOptions.ItemIndex = cCAMEO) then
   begin
      pal_prefix := 'cameo';
      pal_sufix := '';
      ocfStyle.ItemIndex := -1;
      ocfStyle.Enabled := false;
      crFrom.Value := 0;
      crTo.Value := 0;
      ssShadow.Checked := false;
      ssIgnoreLastColours.Checked := false;
      ssRedToRemap.Checked := false;
      fszCustom.Checked := true;
      if CbxOptGame.ItemIndex = GIX_RA2 then
      begin
         bcColourEdit.Color := RGB(0,0,252);
         bcCustom.OnClick(Sender);
         fszWidth.Value := 60;
      end
      else
      begin
         bcNone.Checked := true;
         bcNone.OnClick(Sender);
         fszWidth.Value := 64;
      end;
      fszHeight.Value := 48;
      rocResize.Checked := true;
      CbxSHPType.ItemIndex := TIX_CAMEO;
      ocfComboOptions.Hint := 'This optimizes the import for cameos by getting only 1 frame, removing background colour that damages the cameo in game, loading cameo.pal and resizing it to 64x48 in case they are not at this size.';

      case (CbxOptGame.ItemIndex) of
         GIX_TD:
         begin
            pal_dir := 'TD';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
         GIX_RA1:
         begin
            pal_dir := 'RA1';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
         GIX_TS:
         begin
            pal_dir := 'TS';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','cameo.pal',pal_dir);
         end;
         GIX_RA2:
         begin
            pal_dir := 'RA2';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','cameo.pal',pal_dir);
         end;
      end;
      CboxUseTech.Checked := false;
      CboxUseTechClick(sender);
   end
   // Tech Buildings with Wreckage?
   else if (ocfComboOptions.ItemIndex = cHYBRID) then
   begin
      if maxframes >= 8 then
      begin
         crFrom.Value := 0;
         crTo.Value := 7;
      end;
      bcAutoSelect.Checked := true;
      bcAutoSelect.OnClick(Sender);
      pal_prefix := 'unit';
      ocfStyle.Enabled := true;
      if ocfStyle.ItemIndex = -1 then
         ocfStyle.ItemIndex := c1Temperate;
      bcDefault.Enabled := false;
      ssShadow.Enabled := true;
      ssShadow.Checked := false;
      ssIgnoreLastColours.Enabled := true;
      ssIgnoreLastColours.Checked := true;
      ssRedToRemap.Checked := false;
      fszAuto.OnClick(Sender);
      ocfComboOptions.Hint := 'It loads the first 3 frames and first 3 shadows of the tech building w/ isotem.pal and the 4th and 8th frame which is the wreckage w/ isotem.pal. Use this for 8 frames buildings only.';
      CbxSHPType.ItemIndex := TIX_BUILDING;
      CboxUseTech.Checked := CboxUseTech.Enabled;
      CboxUseTechClick(sender);
   end;
   ocfStyleChange(Sender);
end;

procedure TFrmImportImageAsSHP.fszWidthExit(Sender: TObject);
begin
   if (fszWidth.Text = '') then
      fszWidth.Value := 1;
end;

procedure TFrmImportImageAsSHP.fszHeightExit(Sender: TObject);
begin
   if (fszHeight.Text = '') then
      fszHeight.Value := 1;
end;

procedure TFrmImportImageAsSHP.fszHeightChange(Sender: TObject);
begin
   fszCustom.Checked := true;
end;

procedure TFrmImportImageAsSHP.SetAutoSizes;
var
   Bitmap:TBitmap;
begin
   // Load first Frame so we can get width and height
   Bitmap := GetBMPFromImageFile(Image_Location.Text);

   //Get Filling width and height with Bitmap values.
   fszWidth.Value := Bitmap.Width;
   fszHeight.Value := Bitmap.Height;
   Bitmap.Free;
end;

procedure TFrmImportImageAsSHP.SetAutoSizes2(Bitmap:TBitmap);
begin
   //Get Filling width and height with Bitmap values.
   fszWidth.Value := Bitmap.Width;
   fszHeight.Value := Bitmap.Height;
end;


procedure TFrmImportImageAsSHP.fszAutoClick(Sender: TObject);
begin
   SetAutoSizes;
   fszAuto.Checked := true;
end;

procedure TFrmImportImageAsSHP.ocfStyleChange(Sender: TObject);
begin
   if ocfStyle.ItemIndex = c1TEMPERATE then
   begin
      pal_sufix := 'tem';
      case (CbxOptGame.ItemIndex) of
         GIX_RA2:
         begin
            pal_dir := 'RA2';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + 'tem.pal',pal_dir);
            CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','isotem.pal',pal_dir);
         end;
         GIX_TS:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + 'tem.pal',pal_dir);
         end;
         GIX_RA1:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
         GIX_TD:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
         end;
      end;
   end
   else if ocfStyle.ItemIndex = c1SNOW then
   begin
      pal_sufix := 'sno';
      case (CbxOptGame.ItemIndex) of
         GIX_RA2:
         begin
            pal_dir := 'RA2';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + 'sno.pal',pal_dir);
            CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','isosno.pal',pal_dir);
         end;
         GIX_TS:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + 'sno.pal',pal_dir);
         end;
         GIX_RA1:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','snow.pal',pal_dir);
         end;
         GIX_TD:
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','temperat.pal',pal_dir);
            pal_sufix := 'win';
         end;
      end;
   end
   else if ocfStyle.ItemIndex = c1URBAN then
   begin
      pal_sufix := 'urb';
      case (CbxOptGame.ItemIndex) of
         GIX_RA2:
         begin
            pal_dir := 'RA2';
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + pal_sufix + '.pal',pal_dir);
            CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','iso' + pal_sufix + '.pal',pal_dir);
         end;
         GIX_RA1: // Interior
         begin
            CbxPalette.ItemIndex := GetComboBoxNoFromString(' ','interior.pal',pal_dir);
         end;
      end;
   end
   else if ocfStyle.ItemIndex = c1DESERT then
   begin
      pal_sufix := 'des';
      pal_dir := 'YR';
      CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + pal_sufix + '.pal',pal_dir);
      CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','iso' + pal_sufix + '.pal',pal_dir);
   end
   else if ocfStyle.ItemIndex = c1LUNAR then
   begin
      pal_sufix := 'lun';
      pal_dir := 'YR';
      CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + pal_sufix + '.pal',pal_dir);
      CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','iso' + pal_sufix + '.pal',pal_dir);
   end
   else if ocfStyle.ItemIndex = c1NEWURBAN then
   begin
      pal_sufix := 'ubn';
      pal_dir := 'YR';
      CbxPalette.ItemIndex := GetComboBoxNoFromString(' ',pal_prefix + pal_sufix + '.pal',pal_dir);
      CbxTechPalette.ItemIndex := GetComboBoxNoFromString(' ','iso' + pal_sufix + '.pal',pal_dir);
   end;
end;

procedure TFrmImportImageAsSHP.cbModeClick(Sender: TObject);
begin
// Reset Text
   Image_Location.Text := '';
end;


procedure TFrmImportImageAsSHP.CbxSHPGameChange(Sender: TObject);
var
   Index : Integer;
begin
   Index := CbxSHPType.ItemIndex;
   CbxSHPType.ItemsEx.Clear;
   case (CbxSHPGame.ItemIndex) of
      0:
      begin
         CbxSHPType.ItemsEx.AddItem('Any (Auto)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Unit',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Cameo',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Desert)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Winter)',-1,-1,-1,-1,nil);
      end;
      1:
      begin
         CbxSHPType.ItemsEx.Clear;
         CbxSHPType.ItemsEx.AddItem('Any (Auto)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Unit',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Cameo',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Temperate)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Snow)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Interior)',-1,-1,-1,-1,nil);
      end;
      2:
      begin
         CbxSHPType.ItemsEx.Clear;
         CbxSHPType.ItemsEx.AddItem('Any (Auto)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Unit',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Cameo',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Temperate)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Snow)',-1,-1,-1,-1,nil);
      end;
      3:
      begin
         CbxSHPType.ItemsEx.Clear;
         CbxSHPType.ItemsEx.AddItem('Any (Auto)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Unit',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Building Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Animation',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Cameo',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Temperate)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Snow)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Urban)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Desert)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (Lunar)',-1,-1,-1,-1,nil);
         CbxSHPType.ItemsEx.AddItem('Overlay (New Urban)',-1,-1,-1,-1,nil);
      end;
   end;
   if Index < 8 then
      CbxSHPType.ItemIndex := Index
   else
      CbxSHPType.ItemIndex := 0;
end;

procedure TFrmImportImageAsSHP.CboxUseTechClick(Sender: TObject);
begin
   CbxTechPalette.Enabled := CboxUseTech.Checked;
   lbTechPal.Enabled := CboxUseTech.Checked;
end;

// 3.35: Target Update.
procedure TFrmImportImageAsSHP.CbTargetChange(Sender: TObject);
var
   MyData : TSHPImageData;
begin
   // If 'New SHP'
   if CbTarget.ItemIndex = Data_No then
   begin
      LbTargetFrame.Enabled := false;
      SpeTargetFrame.Value := 1;
      SpeTargetFrame.MinValue := 1;
      SpeTargetFrame.MaxValue := 1;
      SpeTargetFrame.Enabled := false;
      FramesSize.Enabled := true;
      CbxSHPGame.Enabled := true;
      CbxSHPType.Enabled := true;
      CbxOptGame.Enabled := true;
      ocfComboOptions.Enabled := true;
      ocfStyle.Enabled := true;
      ssSplitShadows.Enabled := false;
      ssSplitShadows.Checked := false;
   end
   else
   begin
      LbTargetFrame.Enabled := true;
      SpeTargetFrame.Enabled := true;
      // Now, we need to ensure that some atributes will not
      // be altered.
      FramesSize.Enabled := false;
      fszCustom.Checked := true;
      MyData := DataList[CbTarget.ItemIndex];
      fszWidth.Value := MyData^.SHP.Header.Width;
      fszHeight.Value := MyData^.SHP.Header.Height;
      SpeTargetFrame.MinValue := 1;
      SpeTargetFrame.MaxValue := MyData^.SHP.Header.NumImages;
      SpeTargetFrame.Increment := 1;
      CbxSHPGame.Enabled := false;
      CbxSHPGame.ItemIndex := Integer(MyData^.SHP.SHPGame);
      CbxSHPType.Enabled := false;
      CbxOptGame.Enabled := false;
      ocfComboOptions.Enabled := false;
      ocfStyle.Enabled := false;
      ssSplitShadows.Enabled := (maxframes mod 2 = 0) and (MyData^.SHP.Header.NumImages mod 2 = 0);
      ssSplitShadows.Checked := false;
   end;
end;

procedure TFrmImportImageAsSHP.crFromChange(Sender: TObject);
begin
   crFrom.Value := StrToIntDef(crFrom.Text,0);
   crCustomFrames.Checked := true;
end;

procedure TFrmImportImageAsSHP.crToChange(Sender: TObject);
begin
   crTo.Value := StrToIntDef(crTo.Text,0);
   crCustomFrames.Checked := true;
end;

procedure TFrmImportImageAsSHP.SpeTargetFrameChange(Sender: TObject);
begin
   SpeTargetFrame.Value := StrToIntDef(SpeTargetFrame.Text,1);
end;

procedure TFrmImportImageAsSHP.itsAS00Click(Sender: TObject);
begin
   bcAutoSelectClick(Sender);
end;

procedure TFrmImportImageAsSHP.itsASTransparentClick(Sender: TObject);
begin
   bcAutoSelectClick(Sender);
end;

end.
