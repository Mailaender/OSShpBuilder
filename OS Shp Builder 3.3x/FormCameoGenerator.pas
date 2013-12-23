unit FormCameoGenerator;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ExtCtrls, StdCtrls, ImgList, palette, SHP_Cameo, Spin, SHP_file,
   jpeg, undo_redo, SHP_DataMatrix, ExtDlgs, SHP_Image_Save_Load, Colour_list,
   SHP_Engine_CCMs, SHP_Engine_Resize, FormPaletteSelection, Math,
   ComCtrls, SHP_ENGINE, SHP_IMAGE, SHP_Colour_Bank,
   OSExtDlgs, XPMan;

const
   cMaxRA2Index = 4;

type
   TFrmCameoGenerator = class(TForm)
      Bevel1:  TBevel;
      ImageList1: TImageList;
      Image1:  TImage;
      Bevel2:  TBevel;
      Ok:      TButton;
      OpenBGDialog: TOpenPictureDialog;
      PageControl1: TPageControl;
      TabSheet1: TTabSheet;
      TabSheet2: TTabSheet;
      Game:    TComboBox;
      Cameo_Text: TEdit;
      Label2:  TLabel;
      Label1:  TLabel;
      Cameo_Text2: TEdit;
      Label3:  TLabel;
      Text_Bar_Darkness: TSpinEdit;
      Buttonize_Darkness: TSpinEdit;
      Label4:  TLabel;
      Label5:  TLabel;
      Buttonize_Lightness: TSpinEdit;
      Frame:   TSpinEdit;
      Label6:  TLabel;
      SideCombo: TComboBoxEx;
      Label7:  TLabel;
      Use_Text: TCheckBox;
      Use_text_bar: TCheckBox;
      Buttonize: TCheckBox;
      AutoDV:  TCheckBox;
      Elite:   TCheckBox;
      CutShadow: TCheckBox;
      UseSA:   TCheckBox;
      Label8:  TLabel;
      Panel1:  TPanel;
      CameoInWindow: TRadioButton;
      CameoInFrame: TRadioButton;
      Label9:  TLabel;
      Panel2:  TPanel;
      UserCustomBmp: TRadioButton;
      SpecificPC: TRadioButton;
      RadioButton3: TRadioButton;
      bcColourEdit: TPanel;
      Button1: TButton;
      Label10: TLabel;
      Cancel:  TButton;
      Button2: TButton;
      CheckBox1: TCheckBox;
      Panel3:  TPanel;
      PreviewImage: TImage;
      Bevel3:  TBevel;
      CheckBox2: TCheckBox;
      ButtonizeType: TComboBox;
    XPManifest: TXPManifest;
      procedure CancelClick(Sender: TObject);
      procedure GameChange(Sender: TObject);
      procedure Cameo_TextChange(Sender: TObject);
      procedure FrameDblClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure GenerateCameo(var NewData: TSHPImageData);
      procedure GenerateCameo2(var SHP: TSHP; Palette: TPalette);
      procedure OkClick(Sender: TObject);
      procedure ReplaceBackground(var SHP: TSHP; const Bitmap: TBitmap;
         List, Last: listed_colour; alg: byte);
      procedure ReplaceWithColour(var SHP: TSHP; Colour: byte);
      procedure ConvertFrameToSHP(var OldData, NewData: TSHPImageData; Frame: word);
      procedure ConvertFrameToSHP2(var OldData, NewData: TSHP;
         OldPalette, NewPalette: TPalette; SHPPaletteFilename: string; Frame: word);
      procedure Button1Click(Sender: TObject);
      procedure bcColourEditClick(Sender: TObject);
      procedure GenerateBackground(var SHP: TSHP; Palette: TPalette);
      procedure Button2Click(Sender: TObject);
      procedure Cameo_Text2Change(Sender: TObject);
      procedure SideComboChange(Sender: TObject);
      procedure Text_Bar_DarknessChange(Sender: TObject);
      procedure Buttonize_DarknessChange(Sender: TObject);
      procedure Buttonize_LightnessChange(Sender: TObject);
      procedure FrameChange(Sender: TObject);
      procedure Use_TextClick(Sender: TObject);
      procedure Use_text_barClick(Sender: TObject);
      procedure ButtonizeClick(Sender: TObject);
      procedure AutoDVClick(Sender: TObject);
      procedure EliteClick(Sender: TObject);
      procedure CutShadowClick(Sender: TObject);
      procedure UseSAClick(Sender: TObject);
      procedure SpecificPCClick(Sender: TObject);
      procedure RadioButton3Click(Sender: TObject);
      procedure UserCustomBmpClick(Sender: TObject);
      procedure CheckBox1Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure CheckBox2Click(Sender: TObject);
      procedure ButtonizeTypeChange(Sender: TObject);
   private
      { Private declarations }
      BGFilename:     string;
      BGColourNumber: byte;
      CameoGame:      TSHPGame;
   public
      Data: TSHPImageData;
      { Public declarations }
   end;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmCameoGenerator.OkClick(Sender: TObject);
var
   NewData: TSHPImageData;
   Width:   byte;
begin
   if CameoInWindow.Checked then
   begin
      if CameoGame <> sgRA2 then
         Width := 64
      else
         Width := 60;
      AddNewSHPDataItem(NewData, FrmMain.TotalImages, Width, 48, CameoGame);
      ConvertFrameToSHP(Data, NewData, Frame.Value);
      GenerateBackground(NewData^.SHP, NewData^.SHPPalette);
      GenerateCameo(NewData);
      if FrmMain.GenerateNewWindow(NewData) then
         LoadNewSHPImageSettings(NewData, FrmMain.ActiveForm^)
      else
      begin
         ClearUpData(NewData);
         ShowMessage('MDI Error! Could not create cameo window due to lack of memory.');
         close;
      end;
   end
   else
   begin
      GenerateBackground(Data^.SHP, Data^.SHPPalette);
      GenerateCameo(Data);
   end;

   FrmMain.RefreshAll;
   Close;
end;

procedure TFrmCameoGenerator.GenerateBackground(var SHP: TSHP; Palette: TPalette);
var
   Bitmap: TBitmap;
   List, Last: listed_colour;
   alg: byte;
begin
   if UserCustomBmp.Checked and (BGFilename <> '') then
   begin
      if fileexists(BGFilename) then
      begin
         Bitmap := GetBMPFromImageFile(BGFilename);

         if (Bitmap.Height <> SHP.Header.Height) or
            (Bitmap.Width <> SHP.Header.Width) then
            Resize_Bitmap_Blocky(Bitmap, SHP.Header.Width, SHP.Header.Height);

         GenerateColourList(Palette, List, Last, Palette[0], True, False, False);
         if FrmMain.alg = 0 then
            alg := AutoSelectALG_Progress(Bitmap, Palette, List, Last)
         else
            alg := FrmMain.alg;

         ReplaceBackground(SHP, Bitmap, List, Last, alg);

         ClearColourList(List, Last);
      end;
   end
   else if SpecificPC.Checked then
   begin
      ReplaceWithColour(SHP, BGColourNumber);
   end;
end;

procedure TFrmCameoGenerator.GenerateCameo(var NewData: TSHPImageData);
var
   dv:    integer;
   tm:    boolean;
   List, Last: listed_colour;
   Start: Colour_element;
begin
   AddToUndo(NewData^.UndoList, NewData^.SHP, 1);
   FrmMain.UndoUpdate(NewData^.UndoList);

   dv := WorkOutTextBarDV(NewData^.SHP, NewData^.SHPPalette) - 51;
   dv := dv + 40;

   if dv < 0 then
      dv := 0;

   if AutoDV.Checked then
   begin
      Text_Bar_Darkness.Value := dv;
   end;

   if (Cameo_Text2.Enabled) and (length(Cameo_Text2.Text) > 0) then
      tm := True
   else
      tm := False;

   // Initializing conversion stuff (new CCM engine now applied)
   GenerateColourList(NewData^.SHPPalette, List, Last, NewData^.SHPPalette[0],
      False, False, False);
   PrepareBank(Start, List, Last);

   if Buttonize.Checked then
      if ButtonizeType.ItemIndex = 0 then // RA2 Blade Cameo (Following Blades tutorial)
      begin
         DrawCameoBar_DarkSide_Blade(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Darkness.Value, FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSide_Blade(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightTop_Blade(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 1 then // RA2 Cameo (Mix of sources)
      begin
         DrawCameoBar_DarkSides_s1(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Darkness.Value, FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSides_s1(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 2 then // RA2 Cameo (Ra2 WW1 Cameos as source)
      begin
         DrawCameoBar_DarkSides_s2(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Darkness.Value, FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSides_s2(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 3 then // RA2 Cameo (Using Kravvitz's Cameo's)
      begin
         DrawCameoBar_Kravvitz(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 4 then // RA2 Cameo (Using Kravvitz's Cameo's)
      begin
         DrawCameoBar_Kravvitz2(NewData^.SHP, NewData^.SHPPalette,
            Buttonize_Lightness.Value, FrmMain.alg, List, Last, Start);
      end;

   if tm = False then
   begin
      if Use_text_bar.Checked then
         DrawCameoBar_TextBar(NewData^.SHP, NewData^.SHPPalette,
            Text_Bar_Darkness.Value, FrmMain.alg, List, Last, Start);
      if Use_Text.Checked then
         DrawCameoText(NewData^.SHP, Cameo_Text.Text, ImageList1,
            FrmMain.alg, List, Last, Start);
   end
   else
   begin
      if Use_text_bar.Checked then
         DrawCameoBar_TextBar2(NewData^.SHP, NewData^.SHPPalette,
            Text_Bar_Darkness.Value, FrmMain.alg, List, Last, Start);
      if Use_Text.Checked then
      begin
         DrawCameoText(NewData^.SHP, Cameo_Text2.Text, ImageList1,
            FrmMain.alg, List, Last, Start);
         DrawCameoText2(NewData^.SHP, Cameo_Text.Text, ImageList1,
            FrmMain.alg, List, Last, Start);
      end;
   end;

   if Elite.Checked then
      DrawEliteIconRA2(NewData^.SHP, ImageList1, 37, FrmMain.alg, List, Last, Start);

   // 3.35: Final Bevel effects.
   if Buttonize.Checked then
      if (ButtonizeType.ItemIndex = 5) then
      begin
         DrawCameo_RA1Bevel(NewData^.SHP);
      end
      else if (ButtonizeType.ItemIndex = 6) then
      begin
         DrawCameo_TDBevel(NewData^.SHP);
      end;

   if CameoGame = sgRA2 then
      DrawCameo_Transparent(NewData^.SHP);
end;

procedure TFrmCameoGenerator.GenerateCameo2(var SHP: TSHP; Palette: TPalette);
var
   dv:    integer;
   tm:    boolean;
   List, Last: listed_colour;
   Start: Colour_element;
begin
   //AddToUndo(NewData^.UndoList,NewData^.SHP,1);
   //FrmMain.UndoUpdate(NewData^.UndoList);

   dv := WorkOutTextBarDV(SHP, Palette) - 51;
   dv := dv + 40;

   if dv < 0 then
      dv := 0;

   if AutoDV.Checked then
   begin
      Text_Bar_Darkness.Value := dv;
   end;

   if (Cameo_Text2.Enabled) and (length(Cameo_Text2.Text) > 0) then
      tm := True
   else
      tm := False;

   // Prepare colour conversion stuff
   GenerateColourList(Palette, List, Last, Palette[0], False, False, False);
   PrepareBank(Start, List, Last);

   if Buttonize.Checked then
      if ButtonizeType.ItemIndex = 0 then // RA2 Blade Cameo (Following Blades tutorial)
      begin
         DrawCameoBar_DarkSide_Blade(SHP, Palette, Buttonize_Darkness.Value,
            FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSide_Blade(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightTop_Blade(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 1 then // RA2 Cameo (Mix of sources)
      begin
         DrawCameoBar_DarkSides_s1(SHP, Palette, Buttonize_Darkness.Value,
            FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSides_s1(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 2 then // RA2 Cameo (Ra2 WW1 Cameos as source)
      begin
         DrawCameoBar_DarkSides_s2(SHP, Palette, Buttonize_Darkness.Value,
            FrmMain.alg, List, Last, Start);
         DrawCameoBar_LightSides_s2(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 3 then // RA2 Cameo (Using Kravvitz's Cameo's)
      begin
         DrawCameoBar_Kravvitz(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
      end
      else if ButtonizeType.ItemIndex = 4 then // RA2 Cameo (Using Kravvitz's Cameo's)
      begin
         DrawCameoBar_Kravvitz2(SHP, Palette, Buttonize_Lightness.Value,
            FrmMain.alg, List, Last, Start);
      end;

   if tm = False then
   begin
      if Use_text_bar.Checked then
         DrawCameoBar_TextBar(SHP, Palette, Text_Bar_Darkness.Value,
            FrmMain.alg, List, Last, Start);
      if Use_Text.Checked then
         DrawCameoText(SHP, Cameo_Text.Text, ImageList1, FrmMain.alg, List, Last, Start);
   end
   else
   begin
      if Use_text_bar.Checked then
         DrawCameoBar_TextBar2(SHP, Palette, Text_Bar_Darkness.Value,
            FrmMain.alg, List, Last, Start);
      if Use_Text.Checked then
      begin
         DrawCameoText(SHP, Cameo_Text2.Text, ImageList1, FrmMain.alg, List, Last, Start);
         DrawCameoText2(SHP, Cameo_Text.Text, ImageList1, FrmMain.alg, List, Last, Start);
      end;
   end;

   if Elite.Checked then
      DrawEliteIconRA2(SHP, ImageList1, 37, FrmMain.alg, List, Last, Start);

   if CameoGame = sgRA2 then
      DrawCameo_Transparent(SHP);

   // 3.35: Final Bevel effects.
   if Buttonize.Checked then
      if (ButtonizeType.ItemIndex = 5) then
      begin
         DrawCameo_RA1Bevel(SHP);
      end
      else if (ButtonizeType.ItemIndex = 6) then
      begin
         DrawCameo_TDBevel(SHP);
      end;

   // Remove the trash:
   ClearColourList(List, Last);
   ClearBank(Start);
end;

procedure TFrmCameoGenerator.CancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmCameoGenerator.GameChange(Sender: TObject);
var
   SHPPalette: TPalette;
begin
   // Default Values for different modes
   if Game.ItemIndex = 0 then
   begin
      CameoGame      := sgRA2;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := True;
      Buttonize_Darkness.Value := 40;
      Buttonize_Lightness.Value := 20;
      ButtonizeType.ItemIndex := 0;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Enabled := True;
      Use_Text.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Enabled := True;
      Elite.Enabled  := True;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove RA2 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 1 then
   begin
      CameoGame      := sgRA2;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := True;
      Buttonize_Darkness.Value := 15;
      Buttonize_Lightness.Value := 20;
      ButtonizeType.ItemIndex := 1;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Enabled := True;
      Use_Text.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Enabled := True;
      Elite.Enabled  := True;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove RA2 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 2 then
   begin
      CameoGame      := sgRA2;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := True;
      Buttonize_Darkness.Value := 15;
      Buttonize_Lightness.Value := 5;
      ButtonizeType.ItemIndex := 2;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Enabled := True;
      Use_Text.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Enabled := True;
      Elite.Enabled  := True;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove RA2 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 3 then
   begin
      CameoGame      := sgRA2;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := False;
      Buttonize_Lightness.Value := 30;
      ButtonizeType.ItemIndex := 3;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Enabled := True;
      Use_Text.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Enabled := True;
      Elite.Enabled  := True;
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
         SHPPalette);
      CutShadow.Caption := 'Remove RA2 Shadow';
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
   end
   else if Game.ItemIndex = 4 then
   begin
      CameoGame      := sgRA2;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := False;
      Buttonize_Lightness.Value := 30;
      ButtonizeType.ItemIndex := 4;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Enabled := True;
      Use_Text.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Enabled := True;
      Elite.Enabled  := True;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove RA2 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 5 then
   begin
      CameoGame      := sgTS;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := False;
      Buttonize_Lightness.Value := 30;
      Cameo_Text.Text := '';
      Cameo_Text.Enabled := False;
      Cameo_Text2.Text := '';
      Cameo_Text2.Enabled := False;
      Use_Text.Checked := False;
      Use_Text.Enabled := False;
      Use_Text_Bar.Checked := False;
      Use_Text_Bar.Enabled := False;
      AutoDV.Checked := False;
      AutoDV.Enabled := False;
      Elite.Checked  := False;
      Elite.Enabled  := False;
      Buttonize.Enabled := False;
      Buttonize.Checked := False;
      CutShadow.Caption := 'Remove RA2 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\TS\cameo.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 6 then
   begin
      CameoGame      := sgRA1;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := False;
      Buttonize_Lightness.Value := 30;
      ButtonizeType.ItemIndex := 5;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Checked := True;
      Use_Text.Enabled := True;
      Use_Text_Bar.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Checked := True;
      AutoDV.Enabled := True;
      Elite.Checked  := False;
      Elite.Enabled  := False;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove RA1 Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA1\temperat.pal',
         SHPPalette);
   end
   else if Game.ItemIndex = 7 then
   begin
      CameoGame      := sgTD;
      //Text_Bar_Darkness.Value := 40;
      Buttonize_Darkness.Enabled := False;
      Buttonize_Lightness.Value := 30;
      ButtonizeType.ItemIndex := 5;
      Cameo_Text.Enabled := True;
      Cameo_Text2.Enabled := True;
      Use_Text.Checked := True;
      Use_Text.Enabled := True;
      Use_Text_Bar.Checked := True;
      Use_Text_Bar.Enabled := True;
      AutoDV.Checked := True;
      AutoDV.Enabled := True;
      Elite.Checked  := False;
      Elite.Enabled  := False;
      Buttonize.Enabled := True;
      Buttonize.Checked := True;
      CutShadow.Caption := 'Remove TD Shadow';
      GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\TD\temperat.pal',
         SHPPalette);
   end;

   bcColourEdit.Color := SHPPalette[BGColourNumber];

   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Cameo_TextChange(Sender: TObject);
begin
   if length(Cameo_Text.Text) > 0 then
      Cameo_Text2.Enabled := True
   else
      Cameo_Text2.Enabled := False;

   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.FrameDblClick(Sender: TObject);
begin
   Frame.Value := Frame.MaxValue;
end;

procedure TFrmCameoGenerator.FormShow(Sender: TObject);
var
   SHPPalette: TPalette;
begin
   PageControl1.ActivePage := TabSheet1;
   if (Data^.SHP.Header.NumImages <> 1) or ((Data^.SHP.Header.Width <> 60) and
      (Data^.SHP.Header.Width <> 64)) or (Data^.SHP.Header.Height <> 48) then
   begin
      CameoInFrame.Enabled := False;
      CameoInWindow.Checked := True;
      Frame.MinValue := 1;
      Frame.MaxValue := Data^.SHP.Header.NumImages;
      Frame.Value    := FrmMain.ActiveForm^.FrameIndex;
   end
   else
   begin
      Frame.Enabled := False;
      Frame.Value   := 1;
   end;

   if (Data^.SHP.SHPType <> stUnit) and (Data^.SHP.SHPType <> stBuilding) then
   begin
      SideCombo.Visible := False;
      Label7.Visible    := False;
   end
   else
      CutShadow.Checked := True;

   if (Data^.SHP.SHPGame = sgTS) or (Data^.SHP.SHPGame = sgRA2) then
      SideCombo.ItemIndex := 1
   else
      SideCombo.ItemIndex := 0;
   Game.ItemIndex := 0;
   GameChange(Sender);
   BGFilename     := '';
   BGColourNumber := 4;
   GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal', SHPPalette);
   bcColourEdit.Color := SHPPalette[BGColourNumber];
   if (FrmMain.ActiveForm^.Selection.Width < 1) then
   begin
      UseSA.Enabled := False;
      UseSA.Checked := False;
   end
   else
   begin
      // 3.35: If select data is a dot, it will cause division by zero.
      if (FrmMain.ActiveForm^.Selection.Width > 1) and
         (FrmMain.ActiveForm^.Selection.Height > 1) then
         UseSA.Checked := True
      else
      begin
         UseSA.Enabled := False;
         UseSA.Checked := False;
      end;
   end;
end;

procedure TFrmCameoGenerator.ReplaceBackground(var SHP: TSHP;
   const Bitmap: TBitmap; List, Last: listed_colour; alg: byte);
var
   x, y: word;
begin
   for x := 0 to (SHP.Header.Width - 1) do
      for y := 0 to (SHP.Header.Height - 1) do
         if SHP.Data[1].FrameImage[x, y] = 0 then
            SHP.Data[1].FrameImage[x, y] := LoadPixel(Bitmap, List, Last, alg, x, y);
end;

procedure TFrmCameoGenerator.ReplaceWithColour(var SHP: TSHP; Colour: byte);
var
   x, y: word;
begin
   for x := 0 to (SHP.Header.Width - 1) do
      for y := 0 to (SHP.Header.Height - 1) do
         if SHP.Data[1].FrameImage[x, y] = 0 then
            SHP.Data[1].FrameImage[x, y] := Colour;
end;


procedure TFrmCameoGenerator.ConvertFrameToSHP(var OldData, NewData: TSHPImageData;
   Frame: word);
var
   FrameImage: TFrameImage;
   Cache: TCache;
   x, y: word;
   minx, maxx, miny, maxy: word;
begin
   if (not UseSA.Checked) or (FrmMain.ActiveForm^.Selection.Width < 1) then
   begin
      minx := 0;
      miny := 0;
      maxx := OldData^.SHP.Header.Width - 1;
      maxy := OldData^.SHP.Header.Height - 1;
   end
   else
   begin
      minx := FrmMain.ActiveForm^.Selection.X;
      maxx := FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width - 1;
      miny := FrmMain.ActiveForm^.Selection.Y;
      maxy := FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height - 1;
   end;

   SetLength(FrameImage, (maxx - minx) + 1, (maxy - miny) + 1);
   if (Data^.SHP.SHPType = stUnit) or (Data^.SHP.SHPType = stBuilding) then
      GeneratePaletteCache(OldData^.SHPPalette, NewData^.SHPPalette,
         Cache, FrmMain.alg, SideCombo.ItemIndex, CameoGame, true)
   else
      GeneratePaletteCache(OldData^.SHPPalette, NewData^.SHPPalette, Cache, FrmMain.alg);
   if CutShadow.Checked then
   begin
      if (CameoGame = sgTD) or (CameoGame = sgRA1) then
         Cache[4]  := 0
      else // RA2.
         Cache[12] := 0;
   end;
   for x := 0 to (maxx - minx) do
      for y := 0 to (maxy - miny) do
         FrameImage[x, y] := Cache[OldData^.SHP.Data[Frame].FrameImage[x +
            minx, y + miny]];

   if ((maxx - minx) <> NewData^.SHP.Header.Width) or
      ((maxy - miny) <> NewData^.SHP.Header.Height) then
   begin
      Resize_FrameImage_Blocky(FrameImage, (maxx - minx),
         (maxy - miny), NewData^.SHP.Header.Width, NewData^.SHP.Header.Height);
   end;

   NewData^.SHP.Data[1].FrameImage := FrameImage;
end;

procedure TFrmCameoGenerator.ConvertFrameToSHP2(var OldData, NewData: TSHP;
   OldPalette, NewPalette: TPalette; SHPPaletteFilename: string; Frame: word);
var
   FrameImage: TFrameImage;
   Cache: TCache;
   x, y: word;
   minx, maxx, miny, maxy: word;
begin
   if (not UseSA.Checked) or (FrmMain.ActiveForm^.Selection.Width < 1) then
   begin
      minx := 0;
      miny := 0;
      maxx := OldData.Header.Width - 1;
      maxy := OldData.Header.Height - 1;
   end
   else
   begin
      minx := FrmMain.ActiveForm^.Selection.X;
      maxx := FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width - 1;
      miny := FrmMain.ActiveForm^.Selection.Y;
      maxy := FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height - 1;
   end;

   SetLength(FrameImage, (maxx - minx) + 1, (maxy - miny) + 1);
   if (Data^.SHP.SHPType = stUnit) or (Data^.SHP.SHPType = stBuilding) then
      GeneratePaletteCache(OldPalette, NewPalette, Cache, FrmMain.alg,
         SideCombo.ItemIndex, CameoGame, true)
   else
      GeneratePaletteCache(OldPalette, NewPalette, Cache, FrmMain.alg);
   if CutShadow.Checked then
   begin
      if (CameoGame = sgTD) or (CameoGame = sgRA1) then
         Cache[4]  := 0
      else // RA2.
         Cache[12] := 0;
   end;
   for x := 0 to (maxx - minx) do
      for y := 0 to (maxy - miny) do
         FrameImage[x, y] := Cache[OldData.Data[Frame].FrameImage[x + minx, y + miny]];

   if ((maxx - minx) <> NewData.Header.Width) or ((maxy - miny) <>
      NewData.Header.Height) then
   begin
      Resize_FrameImage_Blocky(FrameImage, (maxx - minx),
         (maxy - miny), NewData.Header.Width, NewData.Header.Height);
   end;

   NewData.Data[1].FrameImage := FrameImage;
end;

procedure TFrmCameoGenerator.Button1Click(Sender: TObject);
begin
   if CameoGame = sgRA2 then
   begin
      if fileexists(extractfiledir(ParamStr(0)) + '\CameoBG\RA2\a1.bmp') then
         OpenBGDialog.InitialDir := extractfiledir(ParamStr(0)) + '\CameoBG\RA2\';
   end
   else if CameoGame = sgTS then
   begin
      if fileexists(extractfiledir(ParamStr(0)) + '\CameoBG\TS\smiffgig01.bmp') then
         OpenBGDialog.InitialDir := extractfiledir(ParamStr(0)) + '\CameoBG\TS\';
   end
   else if CameoGame = sgRA1 then
   begin
      if fileexists(extractfiledir(ParamStr(0)) +
         '\CameoBG\RA1\DeathRay2k_DirtRoad1.bmp') then
         OpenBGDialog.InitialDir := extractfiledir(ParamStr(0)) + '\CameoBG\RA1\';
   end
   else if CameoGame = sgTD then
   begin
      if fileexists(extractfiledir(ParamStr(0)) + '\CameoBG\TD\Carno01.bmp') then
         OpenBGDialog.InitialDir := extractfiledir(ParamStr(0)) + '\CameoBG\TD\';
   end;
   if OpenBGDialog.Execute then
      BGFilename := OpenBGDialog.FileName;

   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.bcColourEditClick(Sender: TObject);
var
   FrmPaletteSelection: TFrmPaletteSelection;
begin
   FrmPaletteSelection := TFrmPaletteSelection.Create(self);
   GetPaletteFromFile(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal',
      FrmPaletteSelection.Palette);
   FrmPaletteSelection.ShowModal;
   BGColourNumber     := FrmPaletteSelection.Colour;
   bcColourEdit.Color := FrmPaletteSelection.Palette[BGColourNumber];
   FrmPaletteSelection.Release;

   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Button2Click(Sender: TObject);
var
   SHP:   TSHP;
   SHPPalette: TPalette;
   Width: integer;
   Shadow_Match: TShadowMatch;
begin
   if not Checkbox2.Checked then
      exit;

   if CameoGame <> sgRA2 then
      Width := 64
   else
      Width := 60;

   NewSHP(SHP, 1, Width, 48);

   case (CameoGame) of
      sgRA2: LoadPaletteFromFile(
            FrmMain.PalettePreferenceData.RA2CameoPalette.Filename, SHPPalette);
      sgTS: LoadPaletteFromFile(
            FrmMain.PalettePreferenceData.TSCameoPalette.Filename, SHPPalette);
      sgRA1: LoadPaletteFromFile(
            FrmMain.PalettePreferenceData.RA1CameoPalette.Filename, SHPPalette);
      sgTD: LoadPaletteFromFile(FrmMain.PalettePreferenceData.TDPalette.Filename,
            SHPPalette);
   end;


   ConvertFrameToSHP2(Data^.SHP, SHP, Data^.SHPPalette, SHPPalette,
      Data^.SHPPaletteFilename, Frame.Value);
   GenerateBackground(SHP, SHPPalette);
   GenerateCameo2(SHP, SHPPalette);

   GenerateShadowCache(Shadow_Match, SHPPalette);

   DrawFrameImage(SHP, Data^.Shadow_Match, 1, 1, True, False, True, SHPPalette, PreviewImage);
end;

procedure TFrmCameoGenerator.Cameo_Text2Change(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.SideComboChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Text_Bar_DarknessChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Buttonize_DarknessChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Buttonize_LightnessChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.FrameChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Use_TextClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.Use_text_barClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.ButtonizeClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.AutoDVClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.EliteClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.CutShadowClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.UseSAClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.SpecificPCClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.RadioButton3Click(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.UserCustomBmpClick(Sender: TObject);
begin
   Button2Click(Sender);
end;

procedure TFrmCameoGenerator.CheckBox1Click(Sender: TObject);
begin
   PreviewImage.Stretch := CheckBox1.Checked;
end;

procedure TFrmCameoGenerator.FormCreate(Sender: TObject);
begin
   Panel3.DoubleBuffered := True;
end;

procedure TFrmCameoGenerator.CheckBox2Click(Sender: TObject);
begin
   if CheckBox2.Checked then
      Button2Click(Sender)
   else
   begin
      PreviewImage.Picture.Bitmap.Width  := 0;
      PreviewImage.Picture.Bitmap.Height := 0;
   end;
end;

procedure TFrmCameoGenerator.ButtonizeTypeChange(Sender: TObject);
begin
   Button2Click(Sender);
end;

end.
