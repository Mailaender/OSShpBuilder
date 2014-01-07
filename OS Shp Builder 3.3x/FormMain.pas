unit FormMain;

{$DEFINE _BETA}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, Buttons,shp_file,shp_engine,palette,
  Shp_Engine_Image, Spin, math, ComCtrls,clipbrd, ImgList, ToolWin,MouseUtil,
  ExtDlgs, Undo_Redo, ShellApi, SHP_Engine_CCMs,SHP_Engine_Resize,SHP_Shadows,
  SHP_Frame,SHP_Image,SHP_Image_Save_Load,FormSHPImage,Colour_list,OS_SHP_Tools,
  SHP_DataMatrix,FormCanvasResize,SHP_Canvas,CommunityLinks,SHP_Image_Effects,
  FormRange,FormFrameSplitter, OSExtDlgs, SHP_RA_File, FormGifOptions, Registry,
  FormCopyFrames,FormReverseFrames,FormMoveFrames,FormDeleteFrames, FormQuickNewSHP,
  FormSpriteSheetExport, ClassGIFCacheManager, ClassGIFCache, FormExportFramesAsImage,
  FormMirrorSHP, FormInstall, XPMan;

Const
   SHP_BUILDER_VER = '3.38';
{$IFDEF _BETA}
   SHP_BUILDER_BETA_VER = '2 (z6.6)';
   SHP_BUILDER_INTERNAL_VERSION = '3.37.99.002.z6.6.1';
{$ENDIF}
   SHP_BUILDER_TITLE = ' Open Source SHP Builder';
   SHP_BUILDER_BY = 'Banshee & Stucuk';
   SHP_BUILDER_CONTRIBUTORS = 'PaD, VK and Zaaz';
   CONFIG_KEY = '2.1'; // Version of Config File Format
   VIEWMENU_MINIMUM = 7;

type
   TDrawMode = (dmDraw,dmLine,dmFlood,dmDropper,dmRectangle,dmRectangle_Fill,dmErase,dmdarkenlighten,dmselect,dmselectmove,dmElipse,dmElipse_Fill,dmCrash,dmLightCrash,dmBigCrash,dmBigLightCrash,dmDirty,dmSnow,dmFloodGradient,dmFloodBlur);

   TSitesList = array of packed record
      SiteName : string;
      SiteUrl : string;
   end;

   TPalettePreferenceData_T = record
      Filename : string[255];
   end;

   TPalettePreferenceData = record
      GameSpecific : boolean;
      // TD specifics
      TDPalette : TPalettePreferenceData_T;
      // RA1 specifics
      RA1UnitPalette: TPalettePreferenceData_T;
      RA1BuildingPalette : TPalettePreferenceData_T;
      RA1AnimationPalette : TPalettePreferenceData_T;
      RA1BuildingAnimationPalette : TPalettePreferenceData_T;
      RA1CameoPalette : TPalettePreferenceData_T;
      RA1TemperatePalette : TPalettePreferenceData_T;
      RA1SnowPalette : TPalettePreferenceData_T;
      RA1InteriorPalette : TPalettePreferenceData_T;
      // TS specifics
      TSUnitPalette : TPalettePreferenceData_T;
      TSBuildingPalette : TPalettePreferenceData_T;
      TSAnimationPalette : TPalettePreferenceData_T;
      TSBuildingAnimationPalette : TPalettePreferenceData_T;
      TSCameoPalette : TPalettePreferenceData_T;
      TSIsoTemPalette : TPalettePreferenceData_T;
      TSIsoSnowPalette : TPalettePreferenceData_T;
      // RA2 specifics
      RA2UnitPalette : TPalettePreferenceData_T;
      RA2BuildingPalette : TPalettePreferenceData_T;
      RA2AnimationPalette : TPalettePreferenceData_T;
      RA2BuildingAnimationPalette : TPalettePreferenceData_T;
      RA2CameoPalette : TPalettePreferenceData_T;
      RA2IsoTemPalette : TPalettePreferenceData_T;
      RA2IsoSnowPalette : TPalettePreferenceData_T;
      RA2IsoUrbPalette : TPalettePreferenceData_T;
      RA2IsoDesPalette : TPalettePreferenceData_T;
      RA2IsoLunPalette : TPalettePreferenceData_T;
      RA2IsoNewUrbPalette : TPalettePreferenceData_T;
   end;

   TFileAssociationsPreferenceData = record
      Associate : boolean;
      ImageIndex : byte;
   end;

   TPaletteSchemes = array of packed record
      Filename : string;
      ImageIndex : Shortint;
   end;


   TSchemeData = array[0..255] of byte;
   TColourSchemes = array of packed record
      Name,Filename,By,Website : string;
      Data : TSchemeData;
   end;


   //---------------------------------------------
   // Applicaton Constants - Path, Filenames
   //---------------------------------------------
   TAppConstants = record
      AppDir : string;
      ImageDir : string;// '\Images\'
      PaletteDir : string;// '\Palettes\' 
      DefaultPaletteFilename : string;// .pal
      CommLinksFilename : string;// .ini
      SequenceFilename : string;// .asdf
      PreferencesFilename :string;// .dat
   end;


   //---------------------------------------------
   // Additional Options/Preferences
   //---------------------------------------------
   TOtherOptionsData = record
      AutoSelectSHPType: boolean;
      LastPalettePath: string;
      BackgroundColorEnabled : boolean;
      ApplySelOnFrameChanging : boolean;
   end;


   //---------------------------------------------
   // Pointer - Form SHP Frames (chained cells)
   //---------------------------------------------
   TSHPImages = ^typeshpimages;
   typeshpimages = record
      Frm : TFrmSHPImage;
      Next : TSHPImages;
   end;


   //---------------------------------------------
   // Form Main
   //---------------------------------------------
   TSHPBuilderFrmMain = class(TForm)
      MainMenu1: TMainMenu;
      File1: TMenuItem;
      New1: TMenuItem;
      Open1: TMenuItem;
      Save1: TMenuItem;
      SaveAs1: TMenuItem;
      Exit1: TMenuItem;
      N1: TMenuItem;
      LeftPanel: TPanel;
      lblPalette: TLabel;
      ToolPanel: TPanel;
      FramePanel: TPanel;
      SpbLine: TSpeedButton;
      SpbFramedRectangle: TSpeedButton;
      SpbErase: TSpeedButton;
      SpbDraw: TSpeedButton;
      SpbDarkenLighten: TSpeedButton;
      SpbColorSelector: TSpeedButton;
      SpbFloodFill: TSpeedButton;
      SpbReplaceColor: TSpeedButton;
      SpbSelect: TSpeedButton;
      OpenSHPDialog: TOpenDialog;
      SaveSHPDialog: TSaveDialog;
      Current_Frame: TSpinEdit;
      Label1: TLabel;
      Label2: TLabel;
      lbl_total_frames: TLabel;
      pnlPalette: TPanel;
      lblActiveColour: TLabel;
      pnlActiveColour: TPanel;
      Palette1: TMenuItem;
      Load1: TMenuItem;
      OpenPaletteDialog: TOpenDialog;
      StatusBar1: TStatusBar;
      Help1: TMenuItem;
      About1: TMenuItem;
      ZoomPanel: TPanel;
      Label3: TLabel;
      Zoom_Factor: TSpinEdit;
      PalettePanel: TPanel;
      cnvPalette: TPaintBox;
      ools1: TMenuItem;
      Preview1: TMenuItem;
      urnToCameoMode1: TMenuItem;
      N3: TMenuItem;
      AutoShadows1: TMenuItem;
      Edit1: TMenuItem;
      Copy1: TMenuItem;
      PasteFrame1: TMenuItem;
      Undo1: TMenuItem;
      Redo1: TMenuItem;
      N5: TMenuItem;
      iberianSun1: TMenuItem;
      RedAlert21: TMenuItem;
      LoadPaletteScheme: TMenuItem;
      Blank2: TMenuItem;
      N6: TMenuItem;
      Preferences1: TMenuItem;
      pnlbump: TPanel;
      SpbLighten: TSpeedButton;
      SpbDarken: TSpeedButton;
      SpbDarkenLightenSettings: TSpeedButton;
      ImageList: TImageList;
      panelToolBar: TPanel;
      ToolBar1: TToolBar;
      TbSeparator1: TToolButton;
      TbNewFile: TToolButton;
      TbOpenFile: TToolButton;
      TbSaveFile: TToolButton;
      TbSeparator2: TToolButton;
      TbUndo: TToolButton;
      TbRedo: TToolButton;
      TbSeparator4: TToolButton;
      TbPreferences: TToolButton;
      TbSeparator5: TToolButton;
      TbHelp: TToolButton;
      Options1: TMenuItem;
      Help2: TMenuItem;
      N4: TMenuItem;
      InsertFrame1: TMenuItem;
      DeleteFrame1: TMenuItem;
      N7: TMenuItem;
      N9: TMenuItem;
      Resize1: TMenuItem;
      lblBrush: TLabel;
      BrushPanel: TPanel;
      ToolAdvOption1: TSpeedButton;
      ToolAdvOption2: TSpeedButton;
      ToolAdvOption3: TSpeedButton;
      ToolAdvOption4: TSpeedButton;
      ToolAdvOption5: TSpeedButton;
      Import1: TMenuItem;
      test1: TMenuItem;
      Export1: TMenuItem;
      N10: TMenuItem;
      SHPBMPs1: TMenuItem;
      SavePictureDialog: TSavePictureDialog;
      TbShowCenter: TToolButton;
      TbSeperator3: TToolButton;
      FixShadows1: TMenuItem;
      FrameImage1: TMenuItem;
      ImageFrame1: TMenuItem;
      ImageSHP1: TMenuItem;
      Copy2: TMenuItem;
      Cut1: TMenuItem;
      Sequence1: TMenuItem;
      YurisRevenge1: TMenuItem;
      blank1: TMenuItem;
      Custom1: TMenuItem;
      Effects1: TMenuItem;
      AntiAlias1: TMenuItem;
      ools2: TMenuItem;
      Fixes1: TMenuItem;
      CameoGenerator1: TMenuItem;
      Shortcuts1: TMenuItem;
      Draw1: TMenuItem;
      Line1: TMenuItem;
      Erase1: TMenuItem;
      Rectangle1: TMenuItem;
      FilledRectangle1: TMenuItem;
      Select1: TMenuItem;
      Dropper1: TMenuItem;
      Fill1: TMenuItem;
      ColourReplace1: TMenuItem;
      CloseFile1: TMenuItem;
      N11: TMenuItem;
      OpenPictureDialog: TOpenPictureDialog;
      BatchConversion1: TMenuItem;
      blank3: TMenuItem;
      Scripts1: TMenuItem;
      PalPack11: TMenuItem;
      About2: TMenuItem;
      N2: TMenuItem;
      Allied1: TMenuItem;
      Soviet1: TMenuItem;
      Yuri1: TMenuItem;
      Brick1: TMenuItem;
      Grayscale1: TMenuItem;
      Blank4: TMenuItem;
      Blank5: TMenuItem;
      blank6: TMenuItem;
      blank7: TMenuItem;
      nlank1: TMenuItem;
      Remap1: TMenuItem;
      blank8: TMenuItem;
      Brown11: TMenuItem;
      Brown21: TMenuItem;
      blank9: TMenuItem;
      blank10: TMenuItem;
      Blue1: TMenuItem;
      Green1: TMenuItem;
      nounlight1: TMenuItem;
      blank11: TMenuItem;
      blank12: TMenuItem;
      blank13: TMenuItem;
      Red1: TMenuItem;
      Yellow1: TMenuItem;
      Custom11: TMenuItem;
      blank15: TMenuItem;
      blank16: TMenuItem;
      blank17: TMenuItem;
      ConversionRange1: TMenuItem;
      WholeFrame1: TMenuItem;
      SAOnly1: TMenuItem;
      FrameRange1: TMenuItem;
      AllFrames1: TMenuItem;
      CurrentOnly1: TMenuItem;
      CustomTS1: TMenuItem;
      CustomRA21: TMenuItem;
      CustomYR1: TMenuItem;
      blank18: TMenuItem;
      blank19: TMenuItem;
      blank20: TMenuItem;
      CustomSchemes1: TMenuItem;
      N12: TMenuItem;
      SpbElipse: TSpeedButton;
      SideColours: TImageList;
      Canvas1: TMenuItem;
      CloseAll1: TMenuItem;
      N13: TMenuItem;
      View1: TMenuItem;
      Elipse1: TMenuItem;
      FilledElipse1: TMenuItem;
      NewWindow1: TMenuItem;
      N8: TMenuItem;
      ile1: TMenuItem;
      Cascade1: TMenuItem;
      ArrangeIcons1: TMenuItem;
      N14: TMenuItem;
      OpenRecent1: TMenuItem;
      SHPTypeSeparator: TMenuItem;
      SaveAll1: TMenuItem;
      ShowCenter1: TMenuItem;
      CloseWindow1: TMenuItem;
      N16: TMenuItem;
      GetSupport1: TMenuItem;
      ReportBugs1: TMenuItem;
      utorials1: TMenuItem;
      Comm1: TMenuItem;
      ProjectPerfectMod1: TMenuItem;
      CnCSourceForUpdates1: TMenuItem;
      N17: TMenuItem;
      Bevel1: TBevel;
      SpbBuildingTools: TSpeedButton;
      ToolAdvOption6: TSpeedButton;
      Mean3x31: TMenuItem;
      Mean5x51: TMenuItem;
      Mean7x71: TMenuItem;
      SmoothMedian1: TMenuItem;
      Median3x31: TMenuItem;
      Median5x51: TMenuItem;
      Median7x71: TMenuItem;
      Sharpen1: TMenuItem;
      UnsharpMasking1: TMenuItem;
      ShapeningBallanced1: TMenuItem;
      ShapeningUmballanced1: TMenuItem;
      Settings1: TMenuItem;
      N18: TMenuItem;
      Range1: TMenuItem;
      Background1: TMenuItem;
      CurrentFrame1: TMenuItem;
      AllFrames2: TMenuItem;
      FromTo1: TMenuItem;
      Ignore01: TMenuItem;
      Consider0as0001: TMenuItem;
      WriteOnBackground1: TMenuItem;
      AffectedArea1: TMenuItem;
      SelectedArea1: TMenuItem;
      WholeFrame2: TMenuItem;
      FromTo2: TMenuItem;
      MeanCross1: TMenuItem;
      MedianCross1: TMenuItem;
      Arithmetics1: TMenuItem;
      Exponential1: TMenuItem;
      Logarithmize1: TMenuItem;
      SmoothConservative1: TMenuItem;
      ConservativeSmooth1: TMenuItem;
      N3DLooking1: TMenuItem;
      ButtonizeWeak1: TMenuItem;
      ColourSettings1: TMenuItem;
      Dontuse216and2392551: TMenuItem;
      RedToRemapable1: TMenuItem;
      Miscelaneous1: TMenuItem;
      MessItUp1: TMenuItem;
      exturize1: TMenuItem;
      IcedTexturizer1: TMenuItem;
      BasicTexturizer1: TMenuItem;
      WhiteTexturizer1: TMenuItem;
      ButtonizeStrong1: TMenuItem;
      ButtonizeVeryStrong1: TMenuItem;
      XDepth1: TMenuItem;
      UnFocus1: TMenuItem;
      Underline1: TMenuItem;
      PetroglyphSobel1: TMenuItem;
      StonifyPrewitt1: TMenuItem;
      RockIt1: TMenuItem;
      PeakColourControl1: TMenuItem;
      EnabledPercentualCorrection1: TMenuItem;
      EnabledAvarageCorrection1: TMenuItem;
      EnabledRemovePeakPixels1: TMenuItem;
      Disabled1: TMenuItem;
      BuildingTools1: TMenuItem;
      Crash1: TMenuItem;
      CrashLight1: TMenuItem;
      BigCrash1: TMenuItem;
      BigLightCrash1: TMenuItem;
      Dirty1: TMenuItem;
      Snowy1: TMenuItem;
      LogarithmLighting1: TMenuItem;
      TbPreviewWindow: TToolButton;
      pnlBackGroundColour: TPanel;
      lblBackGroundColour: TLabel;
      ToogleBackgroundColourMenuItem: TMenuItem;
      TbShowGrid: TToolButton;
      GridPopup: TPopupMenu;
      ShowNone1: TMenuItem;
      SGrids1: TMenuItem;
      RA2Grids1: TMenuItem;
      FrameSplitter1: TMenuItem;
      iberianDawn1: TMenuItem;
      RedAlert11: TMenuItem;
      LoadPaletteScheme1: TMenuItem;
      LoadPaletteScheme2: TMenuItem;
      iberianDawn2: TMenuItem;
      blank14: TMenuItem;
      RedAlert12: TMenuItem;
      blank21: TMenuItem;
      N19: TMenuItem;
      SHPType1: TMenuItem;
      SHPTypeMenuTD: TMenuItem;
      SHPTypeMenuRA1: TMenuItem;
      SHPTypeMenuTS: TMenuItem;
      SHPTypeMenuRA2: TMenuItem;
      SHPTypeTDUnit: TMenuItem;
      SHPTypeTDBuilding: TMenuItem;
      SHPTypeTDBuildAnim: TMenuItem;
      SHPTypeTDAnimation: TMenuItem;
      SHPTypeTDCameo: TMenuItem;
      SHPTypeTDDesert: TMenuItem;
      SHPTypeTDWinter: TMenuItem;
      SHPTypeRA1Unit: TMenuItem;
      SHPTypeRA1Building: TMenuItem;
      SHPTypeRA1BuildAnim: TMenuItem;
      SHPTypeRA1Animation: TMenuItem;
      SHPTypeRA1Cameo: TMenuItem;
      SHPTypeRA1Temperate: TMenuItem;
      SHPTypeRA1Snow: TMenuItem;
      SHPTypeRA1Interior: TMenuItem;
      SHPTypeTSUnit: TMenuItem;
      SHPTypeTSBuilding: TMenuItem;
      SHPTypeTSBuildAnim: TMenuItem;
      SHPTypeTSAnimation: TMenuItem;
      SHPTypeTSCameo: TMenuItem;
      SHPTypeTSTemperate: TMenuItem;
      SHPTypeTSSnow: TMenuItem;
      SHPTypeRA2Unit: TMenuItem;
      SHPTypeRA2Building: TMenuItem;
      SHPTypeRA2BuildAnim: TMenuItem;
      SHPTypeRA2Animation: TMenuItem;
      SHPTypeRA2Cameo: TMenuItem;
      SHPTypeRA2Temperate: TMenuItem;
      SHPTypeRA2Snow: TMenuItem;
      SHPTypeRA2Urban: TMenuItem;
      SHPTypeRA2Desert: TMenuItem;
      SHPTypeRA2Lunar: TMenuItem;
      SHPTypeRA2NewUrban: TMenuItem;
      ConvertShadowsRA2TS1: TMenuItem;
      ConvertShadowsTSRA21: TMenuItem;
      SHPTypeTDNone: TMenuItem;
      SHPTypeRA1None: TMenuItem;
      SHPTypeTSNone: TMenuItem;
      SHPTypeRA2None: TMenuItem;
      PolygonMean1: TMenuItem;
      SquareDepth1: TMenuItem;
      MeanSquared3x31: TMenuItem;
      MeanSquared5x51: TMenuItem;
      MeanSquared7x71: TMenuItem;
      MeanXored1: TMenuItem;
      LogarithmDarkening1: TMenuItem;
      N15: TMenuItem;
      MassFrameOperations1: TMenuItem;
      CopyFrames1: TMenuItem;
      MoveFrames1: TMenuItem;
      ReverseFrames1: TMenuItem;
      DeleteFrames1: TMenuItem;
      PasteAsANewSHP1: TMenuItem;
      Paste1: TMenuItem;
      AsANewFrame1: TMenuItem;
      RemoveUselessShadowPixels1: TMenuItem;
      SpriteSheet1: TMenuItem;
      FillwithGradient1: TMenuItem;
      FramesImage1: TMenuItem;
      ImageRotation1: TMenuItem;
      Mirror1: TMenuItem;
      FlipFrames1: TMenuItem;
      N20: TMenuItem;
      PreviewBrush1: TMenuItem;
      AutoSelectSHPType1: TMenuItem;
      XPManifest: TXPManifest;
      UpdateOSSHPBuilder1: TMenuItem;
      N21: TMenuItem;
      pnlSeparator3: TPanel;
      pnlSeparator1: TPanel;
      pnlSeparator4: TPanel;
      pnlSeparator2: TPanel;
    menuItemUninstall: TMenuItem;
    cbShowBackground: TCheckBox;
    Panel1: TPanel;
    pnlBackground: TPanel;
      procedure UpdateOSSHPBuilder1Click(Sender: TObject);
      procedure AutoSelectSHPType1Click(Sender: TObject);
      procedure PreviewBrush1Click(Sender: TObject);
      procedure FlipFrames1Click(Sender: TObject);
      procedure Mirror1Click(Sender: TObject);
      procedure FramesImage1Click(Sender: TObject);
      procedure Interpreter(var Msg : string);
      procedure AddTocolourList(colour:byte);
      Procedure SetPalette(_Filename:string);
      Procedure SaveConfig(_Filename:string);
      Procedure LoadConfig(_Filename:string);
      Procedure LoadASHP(_Filename :string);
      procedure hidepanels;
      Procedure PaletteLoaded(_Filename: string);
      function LoadPalettesMenu : integer;
      procedure updateGame(ID : integer);
      procedure SetIsEditable(Value : boolean);
      procedure Exit1Click(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure Open1Click(Sender: TObject);
      procedure SaveAs1Click(Sender: TObject);
      procedure cnvPalettePaint(Sender: TObject);
      procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure Load1Click(Sender: TObject);
      procedure About1Click(Sender: TObject);
      procedure New1Click(Sender: TObject);
      procedure Save1Click(Sender: TObject);
      procedure SpbDrawClick(Sender: TObject);
      procedure SpbColorSelectorClick(Sender: TObject);
      procedure Preview1Click(Sender: TObject);
      procedure urnToCameoMode1Click(Sender: TObject);
      procedure SpbLineClick(Sender: TObject);
      procedure SpbFloodFillClick(Sender: TObject);
      procedure SpbEraseClick(Sender: TObject);
      procedure Copy1Click(Sender: TObject);
      procedure PasteFrame1Click(Sender: TObject);
      procedure SpbReplaceColorClick(Sender: TObject);
      procedure LoadPaletteSchemeClick(Sender: TObject);
      procedure SpbDarkenLightenClick(Sender: TObject);
      procedure SpbLightenClick(Sender: TObject);
      procedure SpbDarkenClick(Sender: TObject);
      procedure SpbDarkenLightenSettingsClick(Sender: TObject);
      procedure Preferences1Click(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure InsertFrame1Click(Sender: TObject);
      procedure DeleteFrame1Click(Sender: TObject);
      procedure AutoShadows1Click(Sender: TObject);
      procedure Resize1Click(Sender: TObject);
      procedure ToolAdvOption1_Click(Sender: TObject);
      procedure ToolAdvOption2_Click(Sender: TObject);
      procedure ToolAdvOption3_Click(Sender: TObject);
      procedure ToolAdvOption4_Click(Sender: TObject);
      procedure ToolAdvOption5_Click(Sender: TObject);
      procedure test1Click(Sender: TObject);
      procedure SHPBMPs1Click(Sender: TObject);
      procedure TbShowCenterClick(Sender: TObject);
      procedure FixShadows1Click(Sender: TObject);
      procedure FrameImage1Click(Sender: TObject);
      procedure SpbSelectClick(Sender: TObject);
      procedure ImageSHP1Click(Sender: TObject);
      procedure Copy2Click(Sender: TObject);
      procedure Cut1Click(Sender: TObject);
      procedure Sequence1Click(Sender: TObject);
      procedure Undo1Click(Sender: TObject);
      procedure AntiAlias1Click(Sender: TObject);
      procedure CameoGenerator1Click(Sender: TObject);
      procedure Draw1Click(Sender: TObject);
      procedure Line1Click(Sender: TObject);
      procedure Erase1Click(Sender: TObject);
      procedure Rectangle1Click(Sender: TObject);
      procedure FilledRectangle1Click(Sender: TObject);
      procedure Select1Click(Sender: TObject);
      procedure Dropper1Click(Sender: TObject);
      procedure Fill1Click(Sender: TObject);
      procedure ColourReplace1Click(Sender: TObject);
      procedure Help2Click(Sender: TObject);
      procedure CloseFile1Click(Sender: TObject);
      procedure BatchConversion1Click(Sender: TObject);
      function AddSchemeToMenu(const DirName : string; var Counter : Integer; var RelatedMenuItem : TMenuItem): Integer;
      function LoadCScheme : integer;
      procedure Blank3Click(Sender: TObject);
      procedure About2Click(Sender: TObject);
      procedure AllFrames1Click(Sender: TObject);
      procedure WholeFrame1Click(Sender: TObject);
      procedure SAOnly1Click(Sender: TObject);
      procedure CurrentOnly1Click(Sender: TObject);
      procedure ShowSelectionOptions;
      procedure ShowLineOptions;
      procedure ShowDropperOptions;
      procedure ShowFloodOptions;
      procedure ShowBrushOptions;
      procedure ShowSquareOptions;
      procedure ShowEllipseOptions;
      procedure ShowDamagerOptions;
      procedure SpbFramedRectangleClick(Sender: TObject);
      procedure SpbElipseClick(Sender: TObject);
      function GenerateNewWindow(Data : TSHPImageData): boolean;
      procedure CloseClientWindow;
      procedure CloseAllForms(var Form : TSHPImageForm);
      procedure CloseAllSHPs(var Data : TSHPImageData);
      procedure Zoom_FactorChange(Sender: TObject);
      procedure Current_FrameChange(Sender: TObject);
      procedure SetFrameNumber;
      procedure Zoom_FactorDblClick(Sender: TObject);
      procedure Canvas1Click(Sender: TObject);
      procedure CloseAll1Click(Sender: TObject);
      procedure NewWindow1Click(Sender: TObject);
      procedure Elipse1Click(Sender: TObject);
      procedure FilledElipse1Click(Sender: TObject);
      procedure ArrangeIcons1Click(Sender: TObject);
      procedure Cascade1Click(Sender: TObject);
      procedure ile1Click(Sender: TObject);
      procedure AddNewWindowMenu(const Form:TFrmSHPImage; const Filename:string);
      procedure RemoveNewWindowMenu(const Form:TFrmSHPImage);
      procedure WindowItemClicked(Sender : TObject);
      procedure MakeTheRecentFiles;
      procedure OpenRecentClicked(Sender : TObject);
      procedure UpdateOpenRecentLinks(const Filename : string);
      procedure UpdateRecentList(const position : word);
      procedure AddToRecentList(const Name : string);
      procedure SetMaxOpenFiles(NewValue : word);
      procedure OpenHyperlink(HyperLink: PChar);
      procedure SaveAll1Click(Sender: TObject);
      procedure ShowCenter1Click(Sender: TObject);
      procedure CloseWindow1Click(Sender: TObject);
      procedure GetSupport1Click(Sender: TObject);
      procedure ReportBugs1Click(Sender: TObject);
      procedure utorials1Click(Sender: TObject);
      procedure ProjectPerfectMod1Click(Sender: TObject);
      procedure CnCSourceForUpdates1Click(Sender: TObject);
      procedure LoadSite(Sender : TObject);
      procedure CopyData(var Msg: TMessage); message WM_COPYDATA;
      procedure SpbBuildingToolsClick(Sender: TObject);
      procedure CurrentFrame1Click(Sender: TObject);
      procedure AllFrames2Click(Sender: TObject);
      procedure FromTo1Click(Sender: TObject);
      procedure SelectedArea1Click(Sender: TObject);
      procedure WholeFrame2Click(Sender: TObject);
      procedure Ignore01Click(Sender: TObject);
      procedure Consider0as0001Click(Sender: TObject);
      procedure WriteOnBackground1Click(Sender: TObject);
      procedure Mean3x31Click(Sender: TObject);
      procedure Mean5x51Click(Sender: TObject);
      procedure Mean7x71Click(Sender: TObject);
      procedure Median3x31Click(Sender: TObject);
      procedure Median5x51Click(Sender: TObject);
      procedure Median7x71Click(Sender: TObject);
      procedure UnsharpMasking1Click(Sender: TObject);
      procedure ShapeningBallanced1Click(Sender: TObject);
      procedure ShapeningUmballanced1Click(Sender: TObject);
      procedure FromTo2Click(Sender: TObject);
      procedure GetFastSettings(const SHP:TSHP; var FirstFrame,LastFrame,minx,maxx,miny,maxy : word; CurrentFrame,AllFrames,SelectedArea:boolean);
      procedure GetBackgroundSettings(var Palette:TPalette; var TempColour:TColor; var Bg : smallint; Ignore0,Consider0as1: boolean; alg:byte);
      procedure GetPeakMode(var mode : byte);
      procedure MeanCross1Click(Sender: TObject);
      procedure MedianCross1Click(Sender: TObject);
      procedure Exponential1Click(Sender: TObject);
      procedure Logarithmize1Click(Sender: TObject);
      procedure ConservativeSmooth1Click(Sender: TObject);
      procedure ButtonizeWeak1Click(Sender: TObject);
      procedure Dontuse216and2392551Click(Sender: TObject);
      procedure MessItUp1Click(Sender: TObject);
      procedure IcedTexturizer1Click(Sender: TObject);
      procedure WhiteTexturizer1Click(Sender: TObject);
      procedure BasicTexturizer1Click(Sender: TObject);
      procedure ButtonizeStrong1Click(Sender: TObject);
      procedure ButtonizeVeryStrong1Click(Sender: TObject);
      procedure XDepth1Click(Sender: TObject);
      procedure UnFocus1Click(Sender: TObject);
      procedure Underline1Click(Sender: TObject);
      procedure PetroglyphSobel1Click(Sender: TObject);
      procedure StonifyPrewitt1Click(Sender: TObject);
      procedure RockIt1Click(Sender: TObject);
      procedure EnabledPercentualCorrection1Click(Sender: TObject);
      procedure EnabledAvarageCorrection1Click(Sender: TObject);
      procedure EnabledRemovePeakPixels1Click(Sender: TObject);
      procedure Disabled1Click(Sender: TObject);
      procedure ToolAdvOption6_Click(Sender: TObject);
      procedure Crash1Click(Sender: TObject);
      procedure CrashLight1Click(Sender: TObject);
      procedure BigCrash1Click(Sender: TObject);
      procedure BigLightCrash1Click(Sender: TObject);
      procedure Dirty1Click(Sender: TObject);
      procedure Snowy1Click(Sender: TObject);
      procedure LogarithmLighting1Click(Sender: TObject);
      procedure TbPreviewWindowClick(Sender: TObject);
      procedure ToogleBackgroundColourMenuItemClick(Sender: TObject);
      procedure ShowNone1Click(Sender: TObject);
      procedure SGrids1Click(Sender: TObject);
      procedure RA2Grids1Click(Sender: TObject);
      procedure FrameSplitter1Click(Sender: TObject);
      procedure ConvertShadowsRA2TS1Click(Sender: TObject);
      procedure ConvertShadowsTSRA21Click(Sender: TObject);
      procedure SHPTypeMenuTDClick(Sender: TObject);
      procedure SHPTypeMenuRA1Click(Sender: TObject);
      procedure SHPTypeMenuTSClick(Sender: TObject);
      procedure SHPTypeMenuRA2Click(Sender: TObject);
      procedure SHPTypeTDUnitClick(Sender: TObject);
      procedure SHPTypeTDBuildingClick(Sender: TObject);
      procedure SHPTypeTDBuildAnimClick(Sender: TObject);
      procedure SHPTypeTDAnimationClick(Sender: TObject);
      procedure SHPTypeTDCameoClick(Sender: TObject);
      procedure SHPTypeTDDesertClick(Sender: TObject);
      procedure SHPTypeTDWinterClick(Sender: TObject);
      procedure SHPTypeRA1UnitClick(Sender: TObject);
      procedure SHPTypeRA1BuildingClick(Sender: TObject);
      procedure SHPTypeRA1BuildAnimClick(Sender: TObject);
      procedure SHPTypeRA1AnimationClick(Sender: TObject);
      procedure SHPTypeRA1CameoClick(Sender: TObject);
      procedure SHPTypeRA1TemperateClick(Sender: TObject);
      procedure SHPTypeRA1SnowClick(Sender: TObject);
      procedure SHPTypeRA1InteriorClick(Sender: TObject);
      procedure SHPTypeTSUnitClick(Sender: TObject);
      procedure SHPTypeTSBuildingClick(Sender: TObject);
      procedure SHPTypeTSBuildAnimClick(Sender: TObject);
      procedure SHPTypeTSAnimationClick(Sender: TObject);
      procedure SHPTypeTSCameoClick(Sender: TObject);
      procedure SHPTypeTSTemperateClick(Sender: TObject);
      procedure SHPTypeTSSnowClick(Sender: TObject);
      procedure SHPTypeRA2UnitClick(Sender: TObject);
      procedure SHPTypeRA2BuildingClick(Sender: TObject);
      procedure SHPTypeRA2BuildAnimClick(Sender: TObject);
      procedure SHPTypeRA2AnimationClick(Sender: TObject);
      procedure SHPTypeRA2CameoClick(Sender: TObject);
      procedure SHPTypeRA2TemperateClick(Sender: TObject);
      procedure SHPTypeRA2SnowClick(Sender: TObject);
      procedure SHPTypeRA2UrbanClick(Sender: TObject);
      procedure SHPTypeRA2DesertClick(Sender: TObject);
      procedure SHPTypeRA2LunarClick(Sender: TObject);
      procedure SHPTypeRA2NewUrbanClick(Sender: TObject);
      procedure PolygonMean1Click(Sender: TObject);
      procedure SquareDepth1Click(Sender: TObject);
      procedure MeanSquared3x31Click(Sender: TObject);
      procedure MeanSquared5x51Click(Sender: TObject);
      procedure MeanSquared7x71Click(Sender: TObject);
      procedure MeanXored1Click(Sender: TObject);
      procedure LogarithmDarkening1Click(Sender: TObject);
      procedure CopyFrames1Click(Sender: TObject);
      procedure ReverseFrames1Click(Sender: TObject);
      procedure MoveFrames1Click(Sender: TObject);
      procedure DeleteFrames1Click(Sender: TObject);
      procedure PasteAsANewSHP1Click(Sender: TObject);
      procedure AsANewFrame1Click(Sender: TObject);
      procedure RemoveUselessShadowPixels1Click(Sender: TObject);
      procedure SpriteSheet1Click(Sender: TObject);
      procedure FillwithGradient1Click(Sender: TObject);
      procedure ExportSHPAsImages(StartFrame, EndFrame : integer);
      function GetPaletteFileName(const filename, game: string): string;
      function BlockReadString(var _F: File) : string;
      procedure BlockWriteString(var _F: File; const _MyString: string);
    procedure TbShowGridClick(Sender: TObject);
    procedure lblBackGroundColourDblClick(Sender: TObject);
    procedure menuItemUninstallClick(Sender: TObject);
    procedure cbShowBackgroundClick(Sender: TObject);
   private
      { Private declarations }
      ColourSchemes : TColourSchemes;
      OpenFilesList : array of string[255];
      FileToBeOpened : string; // intercomunication purpouses
      OpenDir : string[255];
      OpenPaletteDir : string[255];
      SaveDir : string[255];      
      ExportDir : string[255];

      LastSelectedGridType : byte; // 0 : TS, 1 : RA2

      procedure LoadConfig1(var F:file);
      procedure LoadConfig2(var F:file);
      procedure LoadConfig3(var F:file);
      procedure LoadConfig4(var F:file);
      procedure LoadConfig5(var F:file);
      procedure LoadConfig6(var F:file);
      procedure LoadConfig7(var F:file);
      procedure LoadConfig8(var F:file);
      procedure LoadConfig9(var F:file);
      procedure InitPreferences;
      procedure VerifyPreferenceData;
   public
      { Public declarations }
      ImportDir : string[255];
      
      AppConstants : TAppConstants;
      ActiveForm : ^TFrmSHPImage;
      ActiveData : TSHPImageData;
      TotalImages : word;
      DrawMode : TDrawMode;
      Brush_Type : integer;
      isEditable:boolean;
      TempView : TObjectData;// Tool Preview
      TempViewLength : integer;
      PreviewBrush: boolean;
      DarkenLighten_B : boolean;
      DarkenLighten_N : byte;
      PaletteSchemes : TPaletteSchemes;
      PaletteSchemes_No : Integer;
      PalettePreferenceData : TPalettePreferenceData;
      FileAssociationsPreferenceData : TFileAssociationsPreferenceData;
      OtherOptionsData: TOtherOptionsData;
      Colour_list: array of record
         colour : byte;
         count : byte;
      end;
      Colour_list_no : byte;
      ColourMatch : array of TColourMatch;
      alg : byte;
      savemode : byte;
      loadmode: byte;
      DefultCursor : integer;
      CurrentPaletteID : string;
      MaxOpenFiles : word;
      SiteList : TSitesList;
      CurrentSHPType : ^TMenuItem;
      GIFCacheManager : CGIFCacheManager;
      SelectionPosition : TPoint2D;

      function IsInstalled : boolean;
      function RunInstaller : boolean;

      procedure RefreshBackgroundUIComponents;
      procedure RefreshGridUIComponents;
      procedure UpdateFrameUIComponents;

      procedure SetBackgroundColorEnabled(enabled : boolean);
      procedure SetShowBackground(value : boolean);
      procedure ResetTempView;

      procedure InitializePalettePreferences();
      function GetCaption : string;
      function GetVersion(var VersionText : string): string;
      Procedure RefreshAll;
      procedure UndoUpdate(var UndoList :TUndoRedo);
      procedure RunAProgram (const theProgram, itsParameters, defaultDirectory : string);
      function RunAsAdmin(const _Filename: string; const _Parameters: string): Boolean;
      
   end;

var
   FrmMain: TSHPBuilderFrmMain;

implementation

uses FormAbout, FormNew, FormPreview, FormReplaceColour,
  FormDarkenLightenTool, FormPreferences, FormAutoShadows, FormResize,
  FormImportImageAsSHP, FormSequence, FormCameoGenerator,
  FormBatchConversion, FormPalettePackAbout, FormSelectDirectory, FormUninstall;

{$R *.dfm}


//---------------------------------------------
// Interpretates comunications from other SHP Builder windows
// Check SHP Builder project source (PostMessage commands)
//---------------------------------------------
procedure TSHPBuilderFrmMain.CopyData(var Msg: TMessage);
var
   cd: ^TCOPYDATASTRUCT;
   p: pchar;
begin
    cd:=Pointer(msg.lParam);
    msg.result:=0;
    if cd^.dwData=(12345234) then begin
      try
     // showmessage('hi');
        p:=cd^.lpData;
     // showmessage(p);
       p := pchar(copy(p,2,length(p)));
        if Fileexists(p) then
        LoadASHP(p);

        { process data }
        msg.result:=-1;
      except
      end;
    end;
end;


// **********************************************
// ******* Basic OS SHP Builder Functions *******
// **********************************************


//---------------------------------------------
// Run Program
//---------------------------------------------
procedure TSHPBuilderFrmMain.RunAProgram (const theProgram, itsParameters, defaultDirectory : string);
var
   rslt     : integer;
   msg      : string;
begin
   rslt := ShellExecute (0, 'open', pChar (theProgram), pChar (itsParameters), pChar (defaultDirectory), sw_ShowNormal);
   if rslt <= 32 then
   begin
      case rslt of
         0,
         se_err_OOM :             msg := 'Out of memory/resources';
         error_File_Not_Found :   msg := 'File "' + theProgram + '" not found';
         error_Path_Not_Found :   msg := 'Path not found';
         error_Bad_Format :       msg := 'Damaged or invalid exe';
         se_err_AccessDenied :    msg := 'Access denied';
         se_err_NoAssoc,
         se_err_AssocIncomplete : msg := 'Filename association invalid';
         se_err_DDEBusy,
         se_err_DDEFail,
         se_err_DDETimeOut :      msg := 'DDE error';
         se_err_Share :        msg := 'Sharing violation';
         else                    msg := 'no text';
      end; // of case
      raise Exception.Create ('ShellExecute error #' + IntToStr (rslt) + ': ' + msg);
   end;
end;


//---------------------------------------------
// See Step 3: Redesign for UAC Compatibility (UAC):
// http://msdn.microsoft.com/en-us/library/bb756922.aspx
// Code adapted from: http://stackoverflow.com/questions/923350/delphi-prompt-for-uac-elevation-when-needed 
//---------------------------------------------
function TSHPBuilderFrmMain.RunAsAdmin(const _Filename: string; const _Parameters: string): Boolean;
var
   sei: TShellExecuteInfo;
begin
   ZeroMemory(@sei, SizeOf(sei));
   sei.cbSize := SizeOf(TShellExecuteInfo);
   sei.Wnd := 0;
   sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
   sei.lpVerb := PChar('runas');
   sei.lpFile := PChar(_Filename); // PAnsiChar;
   if _Parameters <> '' then
    	sei.lpParameters := PChar(_Parameters); // PAnsiChar;
   sei.nShow := SW_SHOWNORMAL; //Integer;

   Result := ShellExecuteEx(@sei);
end;


//---------------------------------------------
// Get Form Caption
//---------------------------------------------
function TSHPBuilderFrmMain.GetCaption : string;
begin
   {$IFDEF _BETA}
   Result := SHP_BUILDER_TITLE + ' ' + SHP_BUILDER_VER  + ' Beta ' + SHP_BUILDER_BETA_VER;
   {$ELSE}
   Result := SHP_BUILDER_TITLE + ' ' + SHP_BUILDER_VER;
   {$ENDIF}
end;


//---------------------------------------------
// Get Form Version
//---------------------------------------------
function TSHPBuilderFrmMain.GetVersion(var VersionText : string): string;
begin
   {$IFDEF _BETA}
   Result := VersionText + SHP_BUILDER_VER + ' Beta ' + SHP_BUILDER_BETA_VER + ' (ID: ' + SHP_BUILDER_INTERNAL_VERSION + ')';
   {$ELSE}
   Result := VersionText + SHP_BUILDER_VER;
   {$ENDIF}
end;


//---------------------------------------------
// Initialize Palette Preferences
//---------------------------------------------
procedure TSHPBuilderFrmMain.InitializePalettePreferences();
begin
   PalettePreferenceData.GameSpecific := true;
   PalettePreferenceData.TDPalette.Filename := GetPaletteFileName('temperat.pal','TD');
   PalettePreferenceData.RA1UnitPalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1BuildingPalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1AnimationPalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1BuildingAnimationPalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1CameoPalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1TemperatePalette.Filename := GetPaletteFileName('temperat.pal','RA1');
   PalettePreferenceData.RA1SnowPalette.Filename := GetPaletteFileName('snow.pal','RA1');
   PalettePreferenceData.RA1InteriorPalette.Filename := GetPaletteFileName('interior.pal','RA1');
   PalettePreferenceData.TSUnitPalette.Filename := GetPaletteFileName('unittem.pal','TS');
   PalettePreferenceData.TSBuildingPalette.Filename := GetPaletteFileName('unittem.pal','TS');
   PalettePreferenceData.TSAnimationPalette.Filename := GetPaletteFileName('anim.pal','TS');
   PalettePreferenceData.TSBuildingAnimationPalette.Filename := GetPaletteFileName('unittem.pal','TS');
   PalettePreferenceData.TSCameoPalette.Filename := GetPaletteFileName('cameo.pal','TS');
   PalettePreferenceData.TSIsoTemPalette.Filename := GetPaletteFileName('isotem.pal','TS');
   PalettePreferenceData.TSIsoSnowPalette.Filename := GetPaletteFileName('isosno.pal','TS');
   PalettePreferenceData.RA2UnitPalette.Filename := GetPaletteFileName('unittem.pal','RA2');
   PalettePreferenceData.RA2BuildingPalette.Filename := GetPaletteFileName('unittem.pal','RA2');
   PalettePreferenceData.RA2AnimationPalette.Filename := GetPaletteFileName('anim.pal','RA2');
   PalettePreferenceData.RA2BuildingAnimationPalette.Filename := GetPaletteFileName('unittem.pal','RA2');
   PalettePreferenceData.RA2CameoPalette.Filename := GetPaletteFileName('cameo.pal','RA2');
   PalettePreferenceData.RA2IsoTemPalette.Filename := GetPaletteFileName('isotem.pal','RA2');
   PalettePreferenceData.RA2IsoSnowPalette.Filename := GetPaletteFileName('isosno.pal','RA2');
   PalettePreferenceData.RA2IsoUrbPalette.Filename := GetPaletteFileName('isourb.pal','RA2');
   PalettePreferenceData.RA2IsoDesPalette.Filename := GetPaletteFileName('isodes.pal','YR');
   PalettePreferenceData.RA2IsoLunPalette.Filename := GetPaletteFileName('isolun.pal','YR');
   PalettePreferenceData.RA2IsoNewUrbPalette.Filename := GetPaletteFileName('isoubn.pal','YR');
end;


//---------------------------------------------
// Get Palette Filename
//---------------------------------------------
function TSHPBuilderFrmMain.GetPaletteFileName(const filename, game: string): string;
var
   Form: TFrmRepairAssistant;
begin
   Result := ExtractFileDir(ParamStr(0)) + '\Palettes\' + game + '\' + filename;
   if not FileExists(Result) then
   begin
      Form := TFrmRepairAssistant.Create(self);
      Form.ShowModal;
      Form.Release;
   end;
end;


//---------------------------------------------
// Get Parameter
//---------------------------------------------
function GetParam(var word: string; var start : integer):string;
var
   i : integer;
begin
   i := start;
   Result := '';
   while i < Length(word) do
   begin
      if word[i] <> ' ' then
         Result := Result + word[i]
      else
         exit;
      inc(i);
   end;
end;


//---------------------------------------------
// Interpret Messages
//---------------------------------------------
procedure TSHPBuilderFrmMain.Interpreter(var Msg : string);
var
   Param : string;
   Settings : array of string;
   counter : integer;
   Height,Width : integer;
   Bitmap : TBitmap;
begin
   // Here we interpret the messages given to the program.
   if Length(Msg) < 1 then exit;

   if Msg[1] <> '-' then
   begin
      if fileexists(Msg) then
      begin
         LoadASHP(Msg);
      end;
   end
   else
   begin
      counter := 2;
      Param := LowerCase(GetParam(Msg,counter));
      if CompareStr(Param,'clipboard') = 0 then
      begin
         // Get settings.
         SetLength(Settings,2);
         inc(counter);
         Settings[0] := GetParam(Msg,counter);
         inc(counter);
         Settings[1] := GetParam(Msg,counter);
         // Now, we transform it in SHP.
         if Clipboard.HasFormat(CF_BITMAP) then
         begin
            Bitmap := TBitmap.Create;
            Width := StrToIntDef(Settings[0],0);
            Height := StrToIntDef(Settings[1],0);
            Bitmap.Assign(Clipboard);
            if (Width <> 0) and (Height <> 0) and ((Width <> Bitmap.Width) or (Height <> Bitmap.Height)) then
            begin
               Bitmap.Width := Width;
               Bitmap.Height := Height;
               Clipboard.Assign(Bitmap);
            end;
            PasteAsANewSHP1Click(nil);
            Bitmap.Free;
         end;
      end
      else if CompareStr(Param,'uninstall') = 0 then
      begin
         // uninstall code should go here.
      end;
   end;
end;


//---------------------------------------------
// Label Background Color Double Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.lblBackGroundColourDblClick(Sender: TObject);
begin
   ToogleBackgroundColourMenuItemClick(nil); 
end;


//-------------------------------------------
// Run Installer
// RETURNS:
//    - TRUE  : IF install not aborted and required files exists.
//    - FALSE : Otherwise.
//-------------------------------------------
function TSHPBuilderFrmMain.RunInstaller;
var
   FrmInstall: TFrmRepairAssistant;
begin
   Result := false;
   FrmInstall := TFrmRepairAssistant.Create(FrmMain);
   FrmInstall.ShowModal;
   FrmInstall.Release;

   Result := (not FrmInstall.ForceClose) and (fileexists(AppConstants.DefaultPaletteFilename))
end;


//-------------------------------------------
// Determine if Application is correctly installed.
//-------------------------------------------
function TSHPBuilderFrmMain.IsInstalled;
var
   msg : string;
begin
   Result := false;
   msg := '';

   if not fileexists(AppConstants.DefaultPaletteFilename) then
      msg := msg + AppConstants.DefaultPaletteFilename + #13#10;

   if not fileexists(AppConstants.SequenceFilename) then
      msg := msg + AppConstants.SequenceFilename + #13#10;

   if not fileexists(AppConstants.CommLinksFilename) then
      msg := msg + AppConstants.CommLinksFilename + #13#10;

   if msg = '' then
      Result := true
   else
      ShowMessage('Missing files:' + #13#10 + msg + 'The installer will now run.' );
end;


//---------------------------------------------
// Form Show
//---------------------------------------------
procedure TSHPBuilderFrmMain.FormShow(Sender: TObject);
var
   temp : string;
   x : integer;
   Reg: TRegistry;
   LatestVersion: string;
   F : file;
begin
   // Set default values to prevent issues with different Operational Systems
   MainData := nil;
   ActiveData := nil;
   ActiveForm := nil;
   SelectionPosition.X := 0;
   SelectionPosition.Y := 0;
   LastSelectedGridType := 0; // TS

   // Removes palette flickering.
   cnvPalette.ControlStyle := cnvPalette.ControlStyle + [csopaque];

   // Init. Application Constants
   AppConstants.AppDir := extractfiledir(ParamStr(0));
   AppConstants.ImageDir := AppConstants.AppDir + '\Images\';
   AppConstants.PaletteDir := AppConstants.AppDir + '\Palettes';
   AppConstants.DefaultPaletteFilename := AppConstants.PaletteDir + '\TS\unittem.pal';
   AppConstants.PreferencesFilename := AppConstants.AppDir + '\SHP_BUILDER.dat';
   AppConstants.SequenceFilename := AppConstants.AppDir + '\SequenceGenerator.asdf';
   AppConstants.CommLinksFilename := AppConstants.AppDir + '\commlist.ini';

   // Verify installation
   if(not IsInstalled) then
      if (not RunInstaller) then
      begin
         Application.Terminate;
         Exit;
      end;

   // Init. form
   TotalImages := 1;
   AddNewSHPDataItem;
   SetisEditable(False);
   Application.HintHidePause := 1000 * 60;
   PaletteSchemes_No := LoadPalettesMenu;
   LoadCScheme;
   SetLength(SiteList,0);


   // TODO: instead of running the installer, 
   // avoid loading the additional commlinks.
   if (not LoadCommunityLinks) then
   begin
      AssignFile(F, AppConstants.CommLinksFilename);
      Erase(F);
      if (not RunInstaller) then
      begin
         Application.Terminate;
         Exit;
      end;
   end;


   // Init. configuration
   InitPreferences;

   // Load Configuration
   if FileExists( AppConstants.PreferencesFilename ) then
      LoadConfig( AppConstants.PreferencesFilename )
   else
      Preferences1Click(Sender);

   // Set Last Palette Filename
   if (not OtherOptionsData.AutoSelectSHPType) and FileExists(OtherOptionsData.LastPalettePath) then
      SetPalette(OtherOptionsData.LastPalettePath);


   // Set Background Color Enabled
   ToogleBackgroundColourMenuItem.Checked := OtherOptionsData.BackgroundColorEnabled;

   Reg := TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   if (Reg.OpenKey('Software\CnC Tools\OS SHP Builder\',true)) then
   begin
      LatestVersion := Reg.ReadString('Version');
      {$IFNDEF _BETA}
      if SHP_BUILDER_VER > LatestVersion then
      {$ELSE}
      if SHP_BUILDER_INTERNAL_VERSION > LatestVersion then
      {$ENDIF}
      begin
         Reg.WriteString('Path',ParamStr(0));
         Reg.WriteString('Version',SHP_BUILDER_VER);
      end;
      Reg.CloseKey;
   end;
   Reg.Free;


   MakeTheRecentFiles;
   CurrentSHPType := nil;

   if Not LoadMouseCursors  then
      close;

   Caption := getCaption;


   // Set default active tool
   DrawMode := dmDropper;
   SpbColorSelector.Down := true;
   ShowDropperOptions;


   TempViewLength := 0;
   DarkenLighten_N := 1;
   Brush_Type := 0;
   PreviewBrush1.Checked := PreviewBrush;
   AutoSelectSHPType1.Checked := OtherOptionsData.AutoSelectSHPType;


   // Process additional messages/parameters
   temp := '';
   if ParamCount > 0 then
      for x := 1 to ParamCount do
         if temp = '' then
            temp := ParamStr(x)
         else
            temp := temp + ' ' + ParamStr(x);


    Interpreter(temp);
    // Init. Gif manager
    GIFCacheManager := CGIFCacheManager.Create;
end;


//---------------------------------------------
// Block Read String
//---------------------------------------------
function TSHPBuilderFrmMain.BlockReadString(var _F: File) :  string;
var
   i: integer;
   Buffer: array[0..254] of char;
begin
   BlockRead(_F,Buffer,255 * Sizeof(char));
   i := 0;
   Result := '';
   while Buffer[i] <> #0 do
   begin
      Result := Result + Buffer[i];
      inc(i);
   end;
end;


//---------------------------------------------
// Block Write String
//---------------------------------------------
procedure TSHPBuilderFrmMain.BlockWriteString(var _F: File; const _MyString: string);
var
   i: integer;
   Buffer: array[0..254] of char;
begin
   i := 0;

   while (i < 255) and (i < Length(_MyString)) do
   begin
      Buffer[i] := _MyString[i + 1];
      inc(i);
   end;
   

   while i < 255 do
   begin
      Buffer[i] := #0;
      inc(i);
   end;

   Buffer[254] := #0;

   BlockWrite(_F, Buffer, 255 * Sizeof(char));
end;


//---------------------------------------------
// Save Configuration File 
//---------------------------------------------
Procedure TSHPBuilderFrmMain.SaveConfig(_Filename:string);
var
   f : file;
   key : string[10];
   count : word;
begin
   // Set default values if necessary.
   if not FileExists(OtherOptionsData.LastPalettePath) then
      OtherOptionsData.LastPalettePath := AppConstants.DefaultPaletteFilename;

   // Open file
   AssignFile(F,_Filename);
   Rewrite(F,1);

   try
      // Save values
      Key := CONFIG_KEY;
      Blockwrite(F,Key,SizeOf(Key));
      Blockwrite(F,FileAssociationsPreferenceData,Sizeof(FileAssociationsPreferenceData));
      Blockwrite(F,PalettePreferenceData,Sizeof(PalettePreferenceData));
      Blockwrite(F,alg,Sizeof(alg));
      Blockwrite(F,savemode,Sizeof(savemode));
      Blockwrite(F,loadmode,Sizeof(loadmode));
      Blockwrite(F,MaxOpenFiles,sizeof(MaxOpenFiles));
      if MaxOpenFiles > 0 then
         for count := 0 to (MaxOpenFiles - 1) do
            BlockWriteString(F, OpenFilesList[count]);
      BlockWriteString(F, OpenDir ); 
      BlockWriteString(F, SaveDir ); 
      BlockWriteString(F, ImportDir);
      BlockWriteString(F, ExportDir);
      Blockwrite(F,PreviewBrush,sizeof(boolean));
      Blockwrite(F,OtherOptionsData.AutoSelectSHPType,sizeof(boolean));
      BlockWriteString(F, OtherOptionsData.LastPalettePath); 
      Blockwrite(F,OtherOptionsData.BackgroundColorEnabled,sizeof(boolean));
      BlockWrite(F, OtherOptionsData.ApplySelOnFrameChanging, SizeOf(boolean));
      BlockWriteString(F, OpenPaletteDir); 
   except
      Erase(F);
      ShowMessage('Error: unable to save the configuration file. Your preferences wont be saved. :(');
   end;

   CloseFile(F);
end;


//---------------------------------------------
// Load Configuration File
//---------------------------------------------
Procedure TSHPBuilderFrmMain.LoadConfig(_Filename:string);
var
   f : file;
   key : string[10];
begin
   // Open file.
   AssignFile(F,_Filename);
   Reset(F,1);

   // Read config.
   try
   if not EOF(F) then
   begin
      BlockRead(F,Key,SizeOf(Key));
      if (Key = '1.0') or (Key = '1.1') then
         LoadConfig1(F)
      else if( Key = '1.3') or (Key = '1.4') then
         LoadConfig2(F)
      else if( Key = '1.5') then
         LoadConfig3(F)
      else if( Key = '1.6') then
         LoadConfig4(F)
      else if( Key = '1.7') then
         LoadConfig5(F)
      else if( Key = '1.8') then
         LoadConfig6(F)
      else if( Key = '1.9') then
         LoadConfig7(F)
      else if( Key = '2.0') then
         LoadConfig8(F)
      else // ....... 2.1
         LoadConfig9(F);
   end;
   except
      Preferences1Click(nil);
   end;

   // Close file.
   CloseFile(F);

   // Verify filenames
   VerifyPreferenceData;
end;


//-------------------------------------------
// Verify Preference Data 
// * Palette filenames
//-------------------------------------------
procedure TSHPBuilderFrmMain.VerifyPreferenceData;
begin
   if (not fileexists(OtherOptionsData.LastPalettePath)) then
      OtherOptionsData.LastPalettePath := AppConstants.DefaultPaletteFilename;

   if(not fileexists(PalettePreferenceData.TDPalette.FileName)) then
      PalettePreferenceData.TDPalette.Filename := GetPaletteFileName('temperat.pal','TD');

   if(not fileexists(PalettePreferenceData.RA1UnitPalette.FileName)) then
      PalettePreferenceData.RA1UnitPalette.Filename := GetPaletteFileName('temperat.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1BuildingPalette.FileName)) then
      PalettePreferenceData.RA1BuildingPalette.Filename := GetPaletteFileName('temperat.pal','RA1');

      if(not fileexists(PalettePreferenceData.RA1AnimationPalette.FileName)) then
      PalettePreferenceData.RA1AnimationPalette.Filename := GetPaletteFileName('temperat.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1BuildingAnimationPalette.FileName)) then
      PalettePreferenceData.RA1BuildingAnimationPalette.Filename := GetPaletteFileName('temperat.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1CameoPalette.FileName)) then
      PalettePreferenceData.RA1CameoPalette.Filename := GetPaletteFileName('temperat.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1TemperatePalette.FileName)) then
      PalettePreferenceData.RA1TemperatePalette.Filename := GetPaletteFileName('temperat.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1SnowPalette.FileName)) then
      PalettePreferenceData.RA1SnowPalette.Filename := GetPaletteFileName('snow.pal','RA1');

   if(not fileexists(PalettePreferenceData.RA1InteriorPalette.FileName)) then
      PalettePreferenceData.RA1InteriorPalette.Filename := GetPaletteFileName('interior.pal','RA1');

   if(not fileexists(PalettePreferenceData.TSUnitPalette.FileName)) then
      PalettePreferenceData.TSUnitPalette.Filename := GetPaletteFileName('unittem.pal','TS');

   if(not fileexists(PalettePreferenceData.TSBuildingPalette.FileName)) then
      PalettePreferenceData.TSBuildingPalette.Filename := GetPaletteFileName('unittem.pal','TS');

   if(not fileexists(PalettePreferenceData.TSAnimationPalette.FileName)) then
      PalettePreferenceData.TSAnimationPalette.Filename := GetPaletteFileName('anim.pal','TS');

   if(not fileexists(PalettePreferenceData.TSBuildingAnimationPalette.FileName)) then                                                              
      PalettePreferenceData.TSBuildingAnimationPalette.Filename := GetPaletteFileName('unittem.pal','TS');
   
      if(not fileexists(PalettePreferenceData.TSCameoPalette.FileName)) then
   PalettePreferenceData.TSCameoPalette.Filename := GetPaletteFileName('cameo.pal','TS');

   if(not fileexists(PalettePreferenceData.TSIsoTemPalette.FileName)) then
   PalettePreferenceData.TSIsoTemPalette.Filename := GetPaletteFileName('isotem.pal','TS');

   if(not fileexists(PalettePreferenceData.TSIsoSnowPalette.FileName)) then
   PalettePreferenceData.TSIsoSnowPalette.Filename := GetPaletteFileName('isosno.pal','TS');

   if(not fileexists(PalettePreferenceData.RA2UnitPalette.FileName)) then
   PalettePreferenceData.RA2UnitPalette.Filename := GetPaletteFileName('unittem.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2BuildingPalette.FileName)) then
   PalettePreferenceData.RA2BuildingPalette.Filename := GetPaletteFileName('unittem.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2AnimationPalette.FileName)) then
   PalettePreferenceData.RA2AnimationPalette.Filename := GetPaletteFileName('anim.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2BuildingAnimationPalette.FileName)) then
   PalettePreferenceData.RA2BuildingAnimationPalette.Filename := GetPaletteFileName('unittem.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2CameoPalette.FileName)) then
   PalettePreferenceData.RA2CameoPalette.Filename := GetPaletteFileName('cameo.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2IsoTemPalette.FileName)) then
   PalettePreferenceData.RA2IsoTemPalette.Filename := GetPaletteFileName('isotem.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2IsoSnowPalette.FileName)) then
   PalettePreferenceData.RA2IsoSnowPalette.Filename := GetPaletteFileName('isosno.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2IsoUrbPalette.FileName)) then
   PalettePreferenceData.RA2IsoUrbPalette.Filename := GetPaletteFileName('isourb.pal','RA2');

   if(not fileexists(PalettePreferenceData.RA2IsoDesPalette.FileName)) then
   PalettePreferenceData.RA2IsoDesPalette.Filename := GetPaletteFileName('isodes.pal','YR');

   if(not fileexists(PalettePreferenceData.RA2IsoLunPalette.FileName)) then
   PalettePreferenceData.RA2IsoLunPalette.Filename := GetPaletteFileName('isolun.pal','YR');

   if(not fileexists(PalettePreferenceData.RA2IsoNewUrbPalette.FileName)) then
   PalettePreferenceData.RA2IsoNewUrbPalette.Filename := GetPaletteFileName('isoubn.pal','YR');
end;


//---------------------------------------------
// Initialize preferences with default values.
//---------------------------------------------
procedure TSHPBuilderFrmMain.InitPreferences;
begin
   Alg := DEFAULT_ALG;
   InitializePalettePreferences();
   MaxOpenFiles := 5;
   SetLength(OpenFilesList,MaxOpenFiles);
   OpenFilesList[0] := '';
   OpenFilesList[1] := '';
   OpenFilesList[2] := '';
   OpenFilesList[3] := '';
   OpenFilesList[4] := '';
   OpenDir := AppConstants.PaletteDir;
   OpenPaletteDir := AppConstants.PaletteDir;
   SaveDir := AppConstants.PaletteDir;
   ImportDir := OpenDir;
   ExportDir := OpenDir;
   PreviewBrush := true;
   OtherOptionsData.AutoSelectSHPType := true;
   OtherOptionsData.LastPalettePath := '';
   OtherOptionsData.BackgroundColorEnabled := true;
   OtherOptionsData.ApplySelOnFrameChanging := false;
end;


//---------------------------------------------
// Load Configuration File - Version 2.1
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig9(var F: file);
begin
   LoadConfig8(F);
   OpenPaletteDir := BlockReadString(F);
end;

//---------------------------------------------
// Load Configuration File - Version 2.0
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig8(var F: file);
begin
   LoadConfig7(F);
   BlockRead(F, OtherOptionsData.ApplySelOnFrameChanging, Sizeof(Boolean));
end;


//---------------------------------------------
// Load Configuration File - Version 1.9
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig7(var F: file);
begin
   LoadConfig6(F);
   BlockRead(F,OtherOptionsData.BackgroundColorEnabled,Sizeof(Boolean));
end;


//---------------------------------------------
// Load Configuration File - Version 1.8
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig6(var F: file);
begin
   LoadConfig5(F);
   OtherOptionsData.LastPalettePath := BlockReadString(F);
end;


//---------------------------------------------
// Load Configuration File - Version 1.7
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig5(var F: file);
begin
   LoadConfig4(F);
   BlockRead(F,OtherOptionsData.AutoSelectSHPType,Sizeof(Boolean));
end;


//---------------------------------------------
// Load Configuration File - Version 1.6
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig4(var F: file);
var
  count : word;
begin
   BlockRead(F,FileAssociationsPreferenceData,Sizeof(FileAssociationsPreferenceData));
   BlockRead(F,PalettePreferenceData,Sizeof(PalettePreferenceData));
   BlockRead(F,alg,Sizeof(alg));
   BlockRead(F,savemode,Sizeof(SaveMode));
   BlockRead(F,loadmode,Sizeof(LoadMode));
   BlockRead(F,MaxOpenFiles,Sizeof(MaxOpenFiles));
   SetLength(OpenFilesList,MaxOpenFiles);
   if MaxOpenFiles > 0 then
      for count := 0 to (MaxOpenFiles - 1) do
         OpenFilesList[count] := BlockReadString(F);
   OpenDir := BlockReadString(F);
   SaveDir := BlockReadString(F);
   ImportDir := BlockReadString(F);
   ExportDir := BlockReadString(F);
   BlockRead(F, PreviewBrush,Sizeof(Boolean));
end;


//---------------------------------------------
// Load Configuration File - Version 1.5
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig3(var F: file);
var
   count : word;
begin
   LoadConfig2(F);

   BlockRead(F, OpenDir, 255 * Sizeof(char));
   BlockRead(F, SaveDir, 255 * Sizeof(char));
   BlockRead(F, ImportDir, 255 * Sizeof(char));
   BlockRead(F, ExportDir, 255 * Sizeof(char));
end;


//---------------------------------------------
// Load Configuration File - Version 1.3, 1.4
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig2(var F: file);
var
   count : word;
begin
   BlockRead(F,FileAssociationsPreferenceData,Sizeof(FileAssociationsPreferenceData));
   InitializePalettePreferences();
   BlockRead(F,PalettePreferenceData.GameSpecific,Sizeof(boolean));
   BlockRead(F,PalettePreferenceData.TSUnitPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSBuildingPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSAnimationPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSCameoPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,alg,Sizeof(alg));
   BlockRead(F,savemode,Sizeof(savemode));
   BlockRead(F,loadmode,Sizeof(loadmode));
   BlockRead(F,MaxOpenFiles,Sizeof(MaxOpenFiles));
   SetLength(OpenFilesList,MaxOpenFiles);
   if MaxOpenFiles > 0 then
      for count := 0 to (MaxOpenFiles-1) do
         BlockRead(F,OpenFilesList[count],255 * Sizeof(char));
end;


//---------------------------------------------
// Load Configuration File - Version 1.1, 1.0
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadConfig1(var F: file);
begin
   BlockRead(F,FileAssociationsPreferenceData,Sizeof(FileAssociationsPreferenceData));
   InitializePalettePreferences();
   BlockRead(F,PalettePreferenceData.GameSpecific,Sizeof(boolean));
   BlockRead(F,PalettePreferenceData.TSUnitPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSBuildingPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSAnimationPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,PalettePreferenceData.TSCameoPalette.Filename,Sizeof(TPalettePreferenceData_T));
   BlockRead(F,alg,Sizeof(alg));
   savemode := 0;
   loadmode := 0;
end;


//---------------------------------------------
// Enable/disable Editing.
//---------------------------------------------
procedure TSHPBuilderFrmMain.SetIsEditable(Value : boolean);
begin
   isEditable := Value;

   cnvPalette.Repaint;
   if MainData <> nil then
   begin
      if MainData^.Next <> nil then
         ActiveForm^.SetActiveColour(ActiveForm^.ActiveColour)
      else
      begin
         pnlActiveColour.Color := MainData^.Shadow_Match[16].Original;
         pnlBackGroundColour.Color := MainData^.Shadow_Match[0].Original;
         lblActiveColour.Caption := '-';
         lblBackGroundColour.Caption := '-';
         StatusBar1.Panels[0].Text := '';
         StatusBar1.Panels[1].Text := '';
         StatusBar1.Panels[2].Text := '';
         StatusBar1.Panels[3].Text := '';
      end;
   end;

   cbShowBackground.Enabled := isEditable;

   Save1.enabled := isEditable;
   SaveAs1.enabled := isEditable;
   SaveAll1.Enabled := isEditable;

   SpbDraw.enabled := isEditable;
   // TODO: enable tools
   SpbLine.enabled := false;
   SpbFramedRectangle.enabled := false;
   SpbErase.enabled := false;
   SpbDarkenLighten.enabled := false;
   SpbColorSelector.enabled := isEditable;
   SpbFloodFill.enabled := isEditable;
   SpbElipse.enabled := false;
   SpbReplaceColor.enabled := isEditable;
   SpbSelect.enabled := isEditable;
   SpbBuildingTools.enabled := false;

   ToolAdvOption1.Enabled := isEditable;
   ToolAdvOption2.Enabled := isEditable;
   ToolAdvOption3.Enabled := isEditable;
   ToolAdvOption4.Enabled := isEditable;
   ToolAdvOption5.Enabled := isEditable;
   ToolAdvOption6.Enabled := isEditable;


   TbSaveFile.enabled := isEditable;
   TbShowCenter.enabled := isEditable;
   TbPreviewWindow.enabled := isEditable;
   TbShowGrid.enabled := isEditable;

   ools1.Visible := isEditable;
   Undo1.Visible := isEditable;
   Redo1.Visible := isEditable;
   MassFrameOperations1.Visible := isEditable;
   Copy1.Visible := isEditable;
   Copy2.Visible := isEditable;
   Cut1.Visible := isEditable;
   PasteFrame1.Visible := isEditable;
   AsANewFrame1.Visible := isEditable;
   InsertFrame1.Visible := isEditable;
   DeleteFrame1.Visible := isEditable;
   Canvas1.Visible := isEditable;
   Resize1.Visible := isEditable;

   View1.Visible := IsEditable;
   Scripts1.Visible := isEditable;

   Export1.enabled := isEditable;
   CloseWindow1.Enabled := IsEditable;
   CloseFile1.enabled := isEditable;
   CloseAll1.Enabled := isEditable;

   SHPTypeSeparator.Visible := isEditable;
   SHPType1.Visible := isEditable;
   urnToCameoMode1.Visible := isEditable;

   Zoom_Factor.Enabled := isEditable;
   Current_Frame.Enabled := isEditable;

   Autoshadows1.Enabled := false;

   lblBackGroundColour.Enabled := isEditable;
end;


//---------------------------------------------
// Load SHP
//---------------------------------------------
Procedure TSHPBuilderFrmMain.LoadASHP(_Filename :string);
var
   Sender : tobject; //Fake Sender Varible
   Data : TSHPImageData;
   CorruptedData,SafeGuard : TSHPImageData;
begin
   OpenDir := ExtractFileDir(_Filename);
   SetIsEditable(false);

   try
      AddNewSHPDataItem(Data,TotalImages,_Filename);
   except
      ShowMessage('Warning:' + SHP_BUILDER_TITLE + ' ' + SHP_BUILDER_VER + ' is unable to open this file.');
      //  3.3: Code To Stabilize the program when loading fails

      // Reset Pointers
      SafeGuard := MainData;
      CorruptedData := MainData;

      // Corrupted Data will search for the last element that
      // was created. Since the loading failed, the Data is
      // corrupted. SafeGuard will get the valid SHP before
      // Corrupted Data.
      while CorruptedData^.Next <> nil do
      begin
         SafeGuard := CorruptedData;
         CorruptedData := CorruptedData^.Next;
      end;
      // Removing Traces of corrupted data.
      SafeGuard^.Next := nil;
      if CorruptedData <> MainData then
         Dispose(CorruptedData);

      // Fix ActiveForm and ActiveData and SetIsEditable.
      ActiveData := SafeGuard;
      if SafeGuard^.Form = nil then
         ActiveForm := nil
      else
      begin
         ActiveForm := SafeGuard^.Form^.Item.Address;
         SetIsEditable(true); // it still has something loaded
      end;

      // 3.35: Bug fix
      if ActiveForm <> nil then
         ActiveForm^.BringToFront;
      // Skip the rest of the function. Bye bye.
      exit;
   end;
   if GenerateNewWindow(Data) then
   begin
      UpdateOpenRecentLinks(_Filename);
      LoadNewSHPImageSettings(Data,ActiveForm^);
   end;
end;


//---------------------------------------------
// Update State of UI Components related to UndoList
//---------------------------------------------
procedure TSHPBuilderFrmMain.UndoUpdate(var UndoList:TUndoRedo);
var
Value : boolean;
begin
    Value := GetUndoStatus(UndoList);
    Undo1.Enabled := Value;
    TbUndo.Enabled := Value;
end;


//---------------------------------------------
// Get Fast Settings
//---------------------------------------------
procedure TSHPBuilderFrmMain.GetFastSettings(const SHP:TSHP; var FirstFrame,LastFrame,minx,maxx,miny,maxy : word; CurrentFrame,AllFrames,SelectedArea:boolean);
var
   FrmRange: TFrmRange;
begin
   // Get range
   if CurrentFrame then
   begin
      FirstFrame :=  Current_Frame.Value;
      LastFrame := FirstFrame;
   end
   else if AllFrames then
   begin
      FirstFrame :=  1;
      LastFrame := SHP.Header.NumImages;
   end
   else
   begin
      FrmRange := TFrmRange.Create(Application);
      FrmRange.Current := Current_Frame.Value;
      FrmRange.Final := SHP.Header.NumImages;
      FrmRange.ShowModal;
      FirstFrame := StrToIntDef(FrmRange.SpBegin.Text,1);
      LastFrame := StrToIntDef(FrmRange.SpEnd.Text,FrmRange.Final);
      FrmRange.Release;
   end;

   // Get Region
   if (SelectedArea) and (ActiveForm^.Selection.Width > 0) then
   begin
      minx := FrmMain.ActiveForm^.Selection.X;
      maxx := FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width;
      miny := FrmMain.ActiveForm^.Selection.Y;
      maxy := FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height;
   end
   else
   begin
      minx := 0;
      maxx := SHP.Header.Width-1;
      miny := 0;
      maxy := SHP.Header.Height-1;
   end;
end;




//---------------------------------------------
// Get BackgroundSettings
//---------------------------------------------
procedure TSHPBuilderFrmMain.GetBackgroundSettings(var Palette:TPalette; var TempColour:TColor; var Bg : smallint; Ignore0,Consider0as1: boolean; alg:byte);
begin
   // Get background
   TempColour := Palette[0];
   if Ignore0 then
   begin
      Bg := 0;
   end
   else if Consider0as1 then
   begin
      Bg := -1;
      Palette[0] := RGB(0,0,0);
   end
   else
   begin
      Bg := -2;
   end;

   // Get alg (lazy way, sorry Stu)
   if FrmMain.alg = 0 then
      alg := 4
   else
      alg := FrmMain.alg;
end;


//---------------------------------------------
// Get Peak Mode
//---------------------------------------------
procedure TSHPBuilderFrmMain.GetPeakMode(var mode : byte);
begin
   if EnabledPercentualCorrection1.checked then
      mode := 3
   else if EnabledAvarageCorrection1.Checked then
      mode := 2
   else if EnabledRemovePeakPixels1.Checked then
      mode := 1
   else
      mode := 0;
end;


// **********************************************************
// ******** Multiples Documents Interface Procedures ********
// **********************************************************


//---------------------------------------------
// Generate new SHP Form
//---------------------------------------------
function TSHPBuilderFrmMain.GenerateNewWindow(Data : TSHPImageData): Boolean;
var
   CurrentForm,NewForm: TSHPImageForm;
begin
   // New MultiDocuments Engine Code Starts Here:
   // ----------------------------------------------

   Result := false;
   try
      New(NewForm);
   except
      ShowMessage('Out of Memory! Aborting!');
      exit;
   end;
   CurrentForm := Data^.Form;
   if CurrentForm = nil then
   begin
      Data^.Form := NewForm;
   end
   else
   begin
      while (CurrentForm^.Next <> nil) do
         CurrentForm := CurrentForm^.Next;
      CurrentForm^.Next := NewForm;
   end;

   inc(TotalImages);
   NewForm^.Item := TFrmSHPImage.Create(self);
   NewForm^.Item.Data := Data;
   NewForm^.Item.Address := Addr(NewForm^.Item);
   NewForm^.Next := nil;
   ActiveData := Data;
   ActiveForm := NewForm^.item.Address;
   NewForm^.Item.Show;
   NewForm^.Item.Cascade;
   NewForm^.Item.SetFocus;
   Result := true;
end;


//---------------------------------------------
// Refresh All Forms
//---------------------------------------------
Procedure TSHPBuilderFrmMain.RefreshAll;
var
   Sender : TObject;
   Data : TSHPImageData;
   Image : TSHPImageForm;
begin
   if not IsEditable then exit; // nothing to refresh

   // Refresh All Views
   Data := ActiveData;
   Image := Data^.Form;

   while Image <> nil do
   begin
      if Image.Item <> nil then
         Image^.Item.RefreshImage;
      Image := Image^.Next;
   end;

   if Data^.Preview <> nil then
      Data^.Preview.TrackBar1Change(Sender);
end;


//---------------------------------------------
// Close Client Window
//---------------------------------------------
procedure TSHPBuilderFrmMain.CloseClientWindow;
var
   Data,s : TSHPImageData;
   PreviousForm,CurrentForm : TSHPImageForm;
   FrmPreview : ^TFrmPreview;
begin
   // Resuming the close code from FrmSHPImage.Close();

   // Grab Data Value
   Data := ActiveData;

   // Locate Current Form:
   CurrentForm := Data^.Form;
   PreviousForm := nil;
   while ((CurrentForm <> nil) and (CurrentForm^.Item.Address <> ActiveForm)) do
   begin
      PreviousForm := CurrentForm;
      CurrentForm := CurrentForm^.Next;
   end;

   // Form not located
   if CurrentForm = nil then
   begin
      messagebox(0,pchar(SHP_BUILDER_TITLE + ' Error: < Houston! We have a problem!'),SHP_BUILDER_TITLE + ' MDI Error',0);
      exit;
   end;

   // Unlink the Form
   if PreviousForm = nil then
   begin
      // Main form.
      if CurrentForm = Data^.Form then
      begin
         // Unlink
         Data^.Form := Data^.Form^.Next;

         // The following code will avoid access violations
         // related to Form Preview:
         if Data^.Preview <> nil then
         begin
            Data^.Preview^.UpdateTimer.Enabled := false;
            Data^.Preview^.AnimationTimer.Enabled := false;
         end;

         // Now it will be safer to eliminate the form.
         Dispose(@CurrentForm.Item);

         if Data^.Form = nil then
         begin
            // Eliminate form preview
            if Data^.Preview <> nil then
               Data^.Preview^.Close;

            // Seek for Data to unlink it.
            s := MainData;
            while ((s <> nil) and (s^.Next <> Data)) do
               s := s^.Next;
            if s <> nil then
               s^.Next := Data^.Next;

            // Eliminate Data
            Dispose(Data);

            // Now check if there are other forms opened.
            if MainData^.Next <> nil then
            begin
               // Seeks another MDIChild to be active.
               ActiveData := MainData^.Next;
               while ActiveData^.Next <> nil do
               begin
                  ActiveData := ActiveData^.Next;
               end;
               If ActiveData^.Form <> nil then
                  if ActiveData^.Form^.Item <> nil then
                     ActiveForm := ActiveData^.Form^.Item.Address;
               SetIsEditable(true);
            end
            else
            begin
               // Back to initial state.
               ActiveData := MainData;
               ActiveForm := nil;
               SetIsEditable(false);
            end;
         end
         else
         begin
            // Re-activate Form Preview:
            if Data^.Preview <> nil then
            begin
               Data^.Preview^.UpdateTimer.Enabled := true;
               Data^.Preview^.AnimationTimer.Enabled := true;
            end;
            // 3.36: Re-activate everything else.
            SetIsEditable(true);
         end;
      end;
   end
   else
   begin
      PreviousForm^.Next := CurrentForm^.Next;
      ActiveForm := PreviousForm^.Item.Address;
      Dispose(CurrentForm);
      if MainData^.Next <> nil then
         SetIsEditable(true);
   end;
end;


//---------------------------------------------
// Close All Forms
//---------------------------------------------
procedure TSHPBuilderFrmMain.CloseAllForms(var Form : TSHPImageForm);
begin
   if Form <> nil then
   begin
      CloseAllForms(Form^.Next);
      Dispose(Form);
   end;
end;


//---------------------------------------------
// CLose All SHPs and their respective form.
//---------------------------------------------
procedure TSHPBuilderFrmMain.CloseAllSHPs(var Data : TSHPImageData);
var
   a : TSHPImageForm;
begin
   if Data <> nil then
   begin
      CloseAllSHPs(Data^.Next);
      a := Data.Form;
      CloseAllForms(a);
      dispose(Data);
   end;
end;


//---------------------------------------------
// Form Close
//---------------------------------------------
procedure TSHPBuilderFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Fileexists( AppConstants.DefaultPaletteFilename ) then
   begin
      SaveConfig( AppConstants.PreferencesFilename );
      CloseAllSHPs(MainData);
      GIFCacheManager.Free;
   end;
   Action := caFree;
end;


// ****************************************
// ********* File Menu Procedures *********
// ****************************************


procedure TSHPBuilderFrmMain.New1Click(Sender: TObject);
var
   TotalFrames,SHP_Width, SHP_Height,Game,SHPType : integer;
   Editable : boolean;
   FrmNew: TFrmNew;
   Data : TSHPImageData;
   Answer : longint;
begin
   Editable := isEditable;
   SetIsEditable(False);

   FrmNew := TFrmNew.Create(Application);
   {FrmNew.txtFrames.text := '100';
   FrmNew.txtwidth.text := '100';
   FrmNew.txtheight.text := '100'; }
   FrmNew.showmodal;

   if FrmNew.changed then
   begin
      TotalFrames := StrToIntDef(FrmNew.txtFrames.text,0);
      SHP_Width := StrtoIntDef(FrmNew.txtwidth.text,0);
      SHP_Height := StrToIntDef(FrmNew.txtheight.text,0);
      Game := FrmNew.CbxGame.ItemIndex;
      SHPType := FrmNew.CbxType.ItemIndex;
      FrmNew.Release;

      // RA2 Cameo CheckUp:
      if ((Game = 3) and (SHPType = 5) and ((TotalFrames <> 1) or (SHP_Width <> 60) or (SHP_Height <> 48))) then
      begin
         Answer := MessageBox(0,'RA2 Cameos are usually 60x48 with 1 frame. Are you sure you want to continue with these settings that you have choosen? Select "No" to use the cameo default settings and "Yes" to keep the current settings.','New Cameo Warning',MB_YESNO);
         if (Answer = IDNO) then
         begin
            SHP_Width := 60;
            SHP_Height := 48;
            TotalFrames := 1;
         end;
      end;

      // Other Cameo CheckUp:
      if ((Game <> 3) and (SHPType = 5) and ((TotalFrames <> 1) or (SHP_Width <> 64) or (SHP_Height <> 48))) then
      begin
         Answer := MessageBox(0,'Non-RA2 Cameos are usually 64x48 with 1 frame. Are you sure you want to continue with these settings that you have choosen?  Select "No" to use the cameo default settings and "Yes" to keep the current settings.','New Cameo Warning',MB_YESNO);
         if (Answer = IDNO) then
         begin
            SHP_Width := 64;
            SHP_Height := 48;
            TotalFrames := 1;
         end;
      end;

      if (((TotalFrames > 0) and (SHP_Width > 0)) and (SHP_Height > 0)) then
      begin
         if not AddNewSHPDataItem(Data,TotalImages,TotalFrames,SHP_Width,SHP_Height,Game,SHPType) then
         begin
            SetIsEditable(Editable);
            exit;
         end;
         if GenerateNewWindow(Data) then
            LoadNewSHPImageSettings(Data,ActiveForm^)
         else
         begin
            ClearUpData(Data);
            ShowMessage('MDI Error: Out of Memory!');
         end;
      end
      else
         Showmessage('Error: Invalid Dimensions'); // Will catch non numeric numbers in the boxes
   end
   else
      SetIsEditable(Editable);
end;


//---------------------------------------------
// Open SHP Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Open1Click(Sender: TObject);
begin
   OpenSHPDialog.InitialDir := OpenDir;
   if OpenSHPDialog.Execute then
   begin
      LoadASHP(OpenSHPDialog.FileName);
   end;
end;


//---------------------------------------------
// Save SHP Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Save1Click(Sender: TObject);
var
   SHPTD : C_SHPTD;
begin
   if not isEditable then exit;

   if ActiveData^.Filename = '' then
      SaveAs1Click(Sender)
   else
   begin
      SaveDir := extractfiledir(ActiveData^.Filename);
      UpdateOpenRecentLinks(ActiveData^.Filename);

      if (ActiveData^.SHP.SHPGame = sgTS) or (ActiveData^.SHP.SHPGame = sgRA2) then
      begin
         CompressFrameImages(ActiveData^.SHP);
         FindSHPRadarColors(ActiveData^.SHP,ActiveData^.SHPPalette);

         case (savemode) of
            0: // AutoDetect compression (recommended)
               SaveSHP(ActiveData^.Filename,ActiveData^.SHP);
            1: // Force compression 3
               SaveSHPCompressed(ActiveData^.Filename,ActiveData^.SHP);
            2: // No compression 3 (old style)
               SaveSHPUncompressed(ActiveData^.Filename,ActiveData^.SHP);
            3:
               SaveSHPHalfCompression(ActiveData^.Filename,ActiveData^.SHP);
            else
               SaveSHP(ActiveData^.Filename,ActiveData^.SHP);
         end;
      end
      else // Game is Tiberian Dawn or Red Alert 1
      begin
         SHPTD := C_SHPTD.Create;
         SHPTD.saveSHP(ActiveData^.SHP,ActiveData^.Filename);
         SHPTD.Free;
      end;

      // Update LastUndo. So, it finds out that the file wasn't
      // modified since last save.
      ActiveData^.LastUndo := ActiveData^.UndoList.Num;
   end;

end;

procedure TSHPBuilderFrmMain.SaveAs1Click(Sender: TObject);
var
   Form : TSHPImageForm;
   item : TMenuItem;
   x : word;
   Game : TSHPGame;
begin
   if not isEditable then exit;

   if (ActiveData^.SHP.SHPGame = sgTS) or (ActiveData^.SHP.SHPGame = sgRA2) then
   begin
      SaveSHPDialog.FilterIndex := 1
   end
   else
      SaveSHPDialog.FilterIndex := 4;

   SaveSHPDialog.InitialDir := SaveDir;
   if SaveSHPDialog.Execute then
   begin
      ActiveData^.Filename := SaveSHPDialog.FileName;
      // 3.35: New saving system, to support or force TD save.
      Game := ActiveData^.SHP.SHPGame;
      if (SaveSHPDialog.FilterIndex = 1) and (Game <> sgRA2) then
         Game := sgTS
      else if (SaveSHPDialog.FilterIndex = 4) and (Game <> sgRA1) then
         Game := sgTD;
      ActiveData^.SHP.SHPGame := Game;
      Save1Click(Sender);

      Form := ActiveData^.Form;
      while Form <> nil do
      begin
         // Update Window Caption
         if Form^.Item <> nil then
            Form^.Item.Caption := '[ ' + IntToStr(Form^.Item.Zoom) + ' : 1 ] ' + extractfilename(ActiveData^.Filename) + ' (' + IntToStr(Form^.Item.FrameIndex) + '/' + IntToStr(ActiveData^.SHP.Header.NumImages) + ')';
         // Update View Menu
         x := VIEWMENU_MINIMUM;
         while x <= View1.Count do
         begin
            item := View1.Items[x];
            if item.Tag = Integer(Form^.Item.Address) then
            begin
               item.Caption := extractfilename(ActiveData^.Filename);
               break;
            end;
            inc(x);
         end;
         Form := Form^.Next;
      end;
   end;
end;

procedure TSHPBuilderFrmMain.SaveAll1Click(Sender: TObject);
var
   CurrentSHP,OriginalSHP : TSHPImageData;
begin
   // Reset variables
   CurrentSHP := MainData^.Next;
   OriginalSHP := ActiveData;
   // Check for all SHPs.
   while CurrentSHP <> nil do
   begin
      ActiveData := CurrentSHP;
      Save1Click(Sender);
      CurrentSHP := CurrentSHP^.Next;
   end;
   ActiveData := OriginalSHP;
end;

procedure TSHPBuilderFrmMain.CloseWindow1Click(Sender: TObject);
begin
   ActiveForm^.Close;
end;

procedure TSHPBuilderFrmMain.CloseFile1Click(Sender: TObject);
var
   Form : TSHPImageForm;
   CurrentData : TSHPImageData;
begin
   // LockDown the program for safety of the user
   FrmMain.Enabled := false;
   SetIsEditable(false);
   // 3.31: Make sure that ActiveData won't change.
   CurrentData := ActiveData;

   // Start search and close operation
   while ActiveForm <> nil do
   begin
      // Close form.
      ActiveForm^.Enabled := false;
      ActiveForm^.Close;
      ActiveForm := nil;
      // 3.31: Fix for the Close Fix: Lock ActiveData
      ActiveData := CurrentData;
      // Seek for another form to close
      if ActiveData^.Form <> nil then
      begin
         Form := ActiveData^.Form;
         if Form^.Item <> nil then
         begin
             while Form^.Next <> nil do
                Form := Form^.Next;
             ActiveForm := @Form^.item;
         end;
      end;
   end;

   if MainData^.Next <> nil then
   begin
      ActiveData := MainData^.Next;
      ActiveForm := ActiveData^.Form^.Item.Address;
      SetIsEditable(true);
   end;
   FrmMain.Enabled := true;
end;

procedure TSHPBuilderFrmMain.CloseAll1Click(Sender: TObject);
var
   Data : TSHPImageData;
   a : TSHPImageForm;
begin
   FrmMain.Enabled := false;
   SetIsEditable(false);
   while ActiveForm <> nil do
   begin
      // Close form.
      ActiveForm^.Enabled := false;
      ActiveForm^.Close;
      ActiveForm := nil;
      // Seek for another form to close
      if MainData^.Next <> nil then
      begin
         Data := MainData^.Next; // reset
         while Data <> nil do
         begin
            if Data^.Form <> nil then
            begin
               a := Data^.Form;
               if a^.Item <> nil then
               begin
                  while a^.Next <> nil do
                     a := a^.Next;
                  ActiveForm := @a^.item;
               end;
            end;
            Data := Data^.Next; // Increment
         end;
      end;
      if (ActiveForm = nil) then
      begin
         ActiveData := MainData;
      end
      else
      begin
         ActiveData := ActiveForm^.Data;
      end;
   end;
   FrmMain.Enabled := true;
end;

procedure TSHPBuilderFrmMain.BatchConversion1Click(Sender: TObject);
var
   FrmBatchConversion: TFrmBatchConversion;
begin
   FrmBatchConversion := TFrmBatchConversion.Create(Application);
   FrmBatchConversion.showmodal;
   FrmBatchConversion.Release;
end;

procedure TSHPBuilderFrmMain.ImageSHP1Click(Sender: TObject);
var
   FrmImportImageAsSHP: TFrmImportImageAsSHP;
begin
   FrmImportImageAsSHP := TFrmImportImageAsSHP.Create(Application);
   FrmImportImageAsSHP.mode := 0;
   FrmImportImageAsSHP.ShowModal;
   FrmImportImageAsSHP.Release;
end;

procedure TSHPBuilderFrmMain.SHPBMPs1Click(Sender: TObject);
begin
   ExportSHPAsImages(1,ActiveData^.SHP.Header.NumImages);
end;

procedure TSHPBuilderFrmMain.ExportSHPAsImages(StartFrame, EndFrame : integer);
var
   Bitmap : TBitmap;
   x,FrameLength : integer;
   filename,dir,ext,temp : string;
   Data :TSHPImageData;
   BmpArray : array of TBitmap;
   FrmGifOptions : TFrmGifOptions;
   ColourPalette : TPalette;
begin
   if not isEditable then exit;

   Data := ActiveData;

   SavePictureDialog.InitialDir := ExportDir;
   if SavePictureDialog.Execute then
   begin
      dir := ExtractFileDir(SavePictureDialog.FileName);
      ExportDir := dir;
      filename := copy(extractfilename(SavePictureDialog.FileName),0,length(extractfilename(SavePictureDialog.FileName))-length(ExtractFileExt(SavePictureDialog.FileName)));
      ext := extractfileext(SavePictureDialog.FileName);

      // 3.35: GIF support
      if CompareStr(ansilowercase(ext),'.gif') = 0 then
      begin  // GIF special treatment.
         FrmGifOptions := TFrmGifOptions.Create(self);
         FrmGifOptions.ShowModal;
         if FrmGifOptions.Changed then
         begin
            // Get ammount of frames and build bitmap array
            GetPaletteForGif(Data^.SHPPalette,ColourPalette);
            if FrmGifOptions.Shadows.ItemIndex <> 0 then
               if EndFrame >= (ActiveData^.SHP.Header.NumImages div 2) then
                  EndFrame := (ActiveData^.SHP.Header.NumImages div 2)-1;
            // Get memory for the bitmap array.
            SetLength(BmpArray,EndFrame - StartFrame + 1);
            // Build the bitmap array
            FrameLength := CreateBmpArray(BmpArray,Data^.SHP,FrmGifOptions.Shadows.ItemIndex,True,StartFrame,EndFrame,Data^.Shadow_Match,ColourPalette,FrmGifOptions.Zoom_Factor.Value);
            // Update bitmap array size
            SetLength(BmpArray,FrameLength);
            // Now, save the stuff
            SaveBMPToGIFImageFile(BmpArray,SavePictureDialog.FileName,FrmGifOptions.LoopType.ItemIndex = 1,FrmGifOptions.CbUseTransparency.Checked,ColourPalette);
            // Finally, get rid of the stuff.
            for x := Low(BmpArray) to High(BmpArray) do
            begin
               BmpArray[x].Free;
            end;
         end
         else
         begin
            FrmGifOptions.Release;
            exit;
         end;
         FrmGifOptions.Release;
      end
      else
      begin
         Bitmap := TBitmap.Create;

         if not (copy(dir,length(dir),1) = '\') then
            filename := '\' + filename + ' ';

         for x := StartFrame to EndFrame do
         begin
            Bitmap := GetBMPOfFrameImage(Data^.SHP,X,Data^.SHPPalette);
            temp := inttostr(x-StartFrame);

            if length(temp) < 4 then
            repeat
               temp := '0' + temp;
            until length(temp) = 4;

            SaveImageFileFromBMP(Dir+filename+temp+ext,Bitmap);
         end;
         Bitmap.Free;
      end;
      Messagebox(0,'Mission Accomplished!','SHP -> Images',0);
   end;
end;

procedure TSHPBuilderFrmMain.FrameImage1Click(Sender: TObject);
var
   Bitmap : TBitmap;
   filename,dir,ext,temp : string;
   Data :TSHPImageData;
begin
   if not isEditable then exit;

   SavePictureDialog.InitialDir := ExportDir;
   if SavePictureDialog.Execute then
   begin
      dir := ExtractFileDir(SavePictureDialog.FileName);
      ExportDir := dir;
      filename := copy(extractfilename(SavePictureDialog.FileName),0,length(extractfilename(SavePictureDialog.FileName))-length(ExtractFileExt(SavePictureDialog.FileName)));
      ext := extractfileext(SavePictureDialog.FileName);

      if not (copy(dir,length(dir),1) = '\') then
         filename := '\' + filename + ' ';

      Bitmap := GetBMPOfFrameImage(ActiveData^.SHP, ActiveForm^.FrameIndex, ActiveData^.SHPPalette);

      temp := inttostr(ActiveForm^.FrameIndex - 1);

      if length(temp) < 4 then
      repeat
         temp := '0' + temp;
      until length(temp) = 4;

      SaveImageFileFromBMP(Dir+filename+temp+ext,Bitmap);


      Bitmap.Free;
      Messagebox(0,'Mission Accomplished!','Frame -> Image',0);
   end;
end;

// 3.36: Export Frames -> Images
procedure TSHPBuilderFrmMain.FramesImage1Click(Sender: TObject);
var
   FrmExport : TFrmExportFramesAsImage;
begin
   FrmExport := TFrmExportFramesAsImage.Create(self);
   FrmExport.ShowModal;
   FrmExport.Release;
end;

// 3.36: Export Image -> Sprite Sheet
procedure TSHPBuilderFrmMain.SpriteSheet1Click(Sender: TObject);
var
   FrmSpriteSheetExport : TFrmSpriteSheetExport;
   Data : TSHPImageData;
   filename,dir,ext : string;
   TempBitmap,FinalBitmap : TBitmap;
   x,y,frame,maxframe,maxx : integer;
begin
   if not isEditable then exit;

   // Open Frame Splitter
   FrmSpriteSheetExport := TFrmSpriteSheetExport.Create(Application);
   FrmSpriteSheetExport.SpeFrameStartNum.MaxValue := ActiveData^.SHP.Header.NumImages;
   FrmSpriteSheetExport.SpeFrameEndNum.MaxValue := ActiveData^.SHP.Header.NumImages;
   FrmSpriteSheetExport.InitialWidth := ActiveData^.SHP.Header.Width;
   FrmSpriteSheetExport.InitialHeight := ActiveData^.SHP.Header.Height;
   FrmSpriteSheetExport.SpeFrameStartNum.Value := 1;
   FrmSpriteSheetExport.SpeFrameEndNum.Value := ActiveData^.SHP.Header.NumImages;
   FrmSpriteSheetExport.SpeVertical.MaxValue := ActiveData^.SHP.Header.NumImages;
   FrmSpriteSheetExport.EdWidth.Text := IntToStr(FrmSpriteSheetExport.InitialWidth);
   FrmSpriteSheetExport.EdHeight.Text := IntToStr(FrmSpriteSheetExport.InitialHeight);
   FrmSpriteSheetExport.ShowModal;

   // Check if it was changed
   if FrmSpriteSheetExport.Changed then
   begin
      SetIsEditable(false);
      // --  Show save picture dialog
      SavePictureDialog.InitialDir := ExportDir;
      if SavePictureDialog.Execute then
      begin
         dir := ExtractFileDir(SavePictureDialog.FileName);
         ExportDir := dir;
         filename := copy(extractfilename(SavePictureDialog.FileName),0,length(extractfilename(SavePictureDialog.FileName))-length(ExtractFileExt(SavePictureDialog.FileName)));
         ext := extractfileext(SavePictureDialog.FileName);

         if not (copy(dir,length(dir),1) = '\') then
            filename := '\' + filename;
         // -- Generate a new Bitmap File.
         FinalBitmap := TBitmap.Create;
         FinalBitmap.Width := StrToIntDef(FrmSpriteSheetExport.EdWidth.Text,0);
         FinalBitmap.Height := StrToIntDef(FrmSpriteSheetExport.EdHeight.Text,0);
         frame := Min(FrmSpriteSheetExport.SpeFrameStartNum.Value,FrmSpriteSheetExport.SpeFrameEndNum.Value);
         maxframe := Max(FrmSpriteSheetExport.SpeFrameStartNum.Value,FrmSpriteSheetExport.SpeFrameEndNum.Value);
         maxx := (maxframe - frame + 1) div FrmSpriteSheetExport.SpeVertical.Value;
         // -- Loop time
         if FrmSpriteSheetExport.ComboOrder.ItemIndex = 0 then
         begin // -- Horizontal order
            y := 0;
            while (y < FrmSpriteSheetExport.SpeVertical.Value) and (frame <= maxframe) do
            begin
               x := 0;
               while (x < maxx) and (frame <= maxframe) do
               begin
                  TempBitmap := GetBMPOfFrameImage(ActiveData^.SHP,frame,ActiveData^.SHPPalette);

                  FinalBitmap.Canvas.Draw(x * ActiveData^.SHP.Header.Width,y * ActiveData^.SHP.Header.Height,TempBitmap);

                  TempBitmap.Free;
                  inc(frame);
                  inc(x);
               end;
               inc(y);
            end;
         end
         else // -- Vertical order.
         begin
            x := 0;
            while (x < maxx) and (frame <= maxframe) do
            begin
               y := 0;
               while (y < FrmSpriteSheetExport.SpeVertical.Value) and (frame <= maxframe) do
               begin
                  TempBitmap := GetBMPOfFrameImage(ActiveData^.SHP,frame,ActiveData^.SHPPalette);

                  FinalBitmap.Canvas.Draw(x * ActiveData^.SHP.Header.Width,y * ActiveData^.SHP.Header.Height,TempBitmap);

                  TempBitmap.Free;
                  inc(frame);
                  inc(y);
               end;
               inc(x);
            end;
         end;
         SaveImageFileFromBMP(Dir+filename+ext,FinalBitmap);
         FinalBitmap.Free;
      end;
   end;
   SetIsEditable(true);
   FrmSpriteSheetExport.Release;
end;

procedure TSHPBuilderFrmMain.Exit1Click(Sender: TObject);
begin
   Close;
end;

// **************************************************
// ************** Edit Menu Procedures **************
// **************************************************


//---------------------------------------------
// Undo Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Undo1Click(Sender: TObject);
var
   NewImage : TSHPImageForm;
   changed : boolean;
begin
   if not isEditable then exit;
   // Setting Default Value (avoids confusion)
   changed := false;

   UndoAction(ActiveData^.SHP, ActiveData^.UndoList, changed);
   ActiveData^.LastUndo := -1;
   // 3.4: Avoids crash if the frame the user was browsing
   // disappears.
   NewImage := ActiveData^.Form;
   while NewImage <> nil do
   begin
      if NewImage^.Item.FrameIndex > ActiveData^.SHP.Header.NumImages then
         NewImage^.Item.SetFrameIndex(ActiveData^.SHP.Header.NumImages);
      NewImage := NewImage^.Next;
   end;
   Current_Frame.Value := ActiveForm^.FrameIndex;

   if changed then
   begin
      NewImage := ActiveData^.Form;
      FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(ActiveData^.SHP.Header.Height);
      while NewImage <> nil do
      begin
         NewImage^.Item.ResizePaintArea(NewImage^.Item.Image1,NewImage^.Item.PaintAreaPanel);
         NewImage := NewImage^.Next;
      end;
   end;
   ActiveForm^.SetShadowMode(ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   UndoUpdate(ActiveData^.UndoList);

   RefreshAll;
end;

// 3.36: Imported from 3.4, mass frames operations
procedure TSHPBuilderFrmMain.CopyFrames1Click(Sender: TObject);
var
   FrmCopyFrames: TFrmCopyFrames;
begin
   FrmCopyFrames := TFrmCopyFrames.Create(FrmMain);
   FrmCopyFrames.ShowModal;
   FrmCopyFrames.Release;
end;

procedure TSHPBuilderFrmMain.ReverseFrames1Click(Sender: TObject);
var
   FrmReverseFrames : TFrmReverseFrames;
begin
   FrmReverseFrames := TFrmReverseFrames.Create(FrmMain);
   FrmReverseFrames.ShowModal;
   FrmReverseFrames.Release;
end;

procedure TSHPBuilderFrmMain.MoveFrames1Click(Sender: TObject);
var
   FrmMoveFrames : TFrmMoveFrames;
begin
   FrmMoveFrames := TFrmMoveFrames.Create(FrmMain);
   FrmMoveFrames.ShowModal;
   FrmMoveFrames.Release;
end;

procedure TSHPBuilderFrmMain.DeleteFrames1Click(Sender: TObject);
var
   FrmDeleteFrames : TFrmDeleteFrames;
begin
   FrmDeleteFrames := TFrmDeleteFrames.Create(FrmMain);
   FrmDeleteFrames.ShowModal;
   FrmDeleteFrames.Release;
end;


//---------------------------------------------
// Copy Selection Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Copy2Click(Sender: TObject);
var
   x, y : integer;
   Bitmap : TBitmap;
   Data : TSHPImageData;
begin
   if not isEditable then Exit;
   Data := ActiveData;

   if not ActiveForm^.Selection.HasData then
   begin
      Copy1Click(sender); // No Selection made, copy entire frame
      exit;
   end;

   // Copy Selection to Clipboard
   Bitmap := TBitmap.Create;

   Bitmap.Width := ActiveForm^.Selection.Width;
   Bitmap.Height := ActiveForm^.Selection.Height;

   for x := 0 to Bitmap.Width - 1 do
      for y := 0 to Bitmap.Height - 1 do
         Bitmap.Canvas.Pixels[x, y] := Data^.SHPPalette[
                  ActiveForm^.Selection.Layer[x, y]
               ];

   SelectionPosition.X := 0;
   SelectionPosition.Y := 0;

   Clipboard.Clear;
   Clipboard.Assign(Bitmap);

   Bitmap.Free;
end;


//---------------------------------------------
// Cut Selection Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Cut1Click(Sender: TObject);
var
   x, y : integer;
   Data : TSHPImageData;
begin
   if not isEditable then Exit;
   Data := ActiveData;

   
   if not ActiveForm^.Selection.HasData then begin
      // Copy entire frame
      Copy1Click(sender);
   end
   else begin

      // Copy Selection
      Copy2Click(Sender);

      // Cut Selection
      ActiveForm^.CutSelection;
      ActiveForm^.RefreshImage; 
   end;
end;


//---------------------------------------------
// Copy Frame Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Copy1Click(Sender: TObject);
var
   Data : TSHPImageData;
begin
   Clipboard.Clear;
   if MDIChildCount <> 0 then
      Data := ActiveData
   else
      Data := MainData;
   Clipboard.Assign(GetBMPOfFrameImage(Data^.SHP, ActiveForm^.FrameIndex, Data^.SHPPalette));
end;


//---------------------------------------------
// Paste As Selection Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.PasteFrame1Click(Sender: TObject);
var
   Bitmap : TBitmap;
   x, y : integer;
   Data : TSHPImageData;
   NewImage : TSHPImageForm;
begin
   if not iseditable then Exit;
   if Not Clipboard.HasFormat(CF_BITMAP) then Exit; // No Bitmaps In Clipboard...

   // TODO: check Photoshop Clipboard format for image with transparency
   Data := ActiveData;
   Bitmap := TBitmap.Create;
   Bitmap.PixelFormat := pf32bit;
   Bitmap.Assign(Clipboard);

   // Prompt Resize
   if (Bitmap.Width > Data^.SHP.Header.Width) or (Bitmap.Height > Data^.SHP.Header.Height) then
   begin
      if MessageBox(Application.Handle,'Do you want to change the size of your image to fit the clipboard image?','Change Size?',mb_YesNo) = IDYES then
      begin
         AddToUndo(Data^.UndoList,Data^.SHP);
         Resize_SHP(Data^.SHP,max(Bitmap.Width,Data^.SHP.Header.Width),max(Bitmap.Height,Data^.SHP.Header.Height));

         // Resize window.
         NewImage := ActiveData^.Form;
         FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(ActiveData^.SHP.Header.Height);
         while NewImage <> nil do
         begin
            NewImage^.Item.ResizePaintArea(NewImage^.Item.Image1,NewImage^.Item.PaintAreaPanel);
            NewImage := NewImage^.Next;
         end;
         UndoUpdate(ActiveData^.UndoList);
      end;
   end;

   // Paste Selection **does not apply it to the frame
   ActiveForm^.PasteSelection(Bitmap, alg, SelectionPosition);

   // Select Selection Tool
   DrawMode := dmselect;
   TempViewLength := 0;
   ActiveForm^.Image1.Cursor := CrArrow;
   SpbSelect.Down := true;
   ShowSelectionOptions;
   ActiveForm^.RefreshImage;// TODO: remove refresh if unnecessary

   Bitmap.Free;
   RefreshAll;
   UndoUpdate(Data^.UndoList);
end;


//---------------------------------------------
// Paste As New SHP Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.PasteAsANewSHP1Click(Sender: TObject);
var
   Bitmap : TBitmap;
   x,y : integer;
   talg : byte;
   List,Last:listed_colour;
   Data : TSHPImageData;
   NewImage : TSHPImageForm;
   FrmQuickNewSHP : TFrmQuickNewSHP;
   Game,SHPType : Integer;
begin
   if Not Clipboard.HasFormat(CF_BITMAP) then
   begin
      ShowMessage('Your clipboard does not have a valid image');
      Exit; // No Bitmaps In Clipboard...
   end;

   FrmQuickNewSHP := TFrmQuickNewSHP.Create(Application);
   FrmQuickNewSHP.ShowModal;
   if FrmQuickNewSHP.changed then
   begin
      // Generate Bitmap
      Bitmap := TBitmap.Create;
      Bitmap.Assign(Clipboard);

      // Lock other windows and 99% of the other SHP Builder processes.
      SetIsEditable(False);

      // Get form settings.
      Game := FrmQuickNewSHP.CbxGame.ItemIndex;
      SHPType := FrmQuickNewSHP.CbxType.ItemIndex;

      // Make a new SHP here.
      AddNewSHPDataItem(Data, TotalImages, 1, Bitmap.Width, Bitmap.Height, Game, SHPType);
      if GenerateNewWindow(Data) then
         LoadNewSHPImageSettings(Data,ActiveForm^)
      else
      begin
         ClearUpData(Data);
         ShowMessage('MDI Error: Out of Memory To Create Window');
         exit;
      end;

      // Prepare palette for conversion
      talg := alg;
      GenerateColourList(Data^.SHPPalette,List,Last,Data^.SHPPalette[0],false,false,false);

      // Here we are keeping the obsolette auto select, for
      // those who still have it.
      if talg = 0 then
         talg := AutoSelectALG_Progress(Bitmap,Data^.SHPPalette,List,Last);

      // Here we convert the picture.
      For x := 0 to Bitmap.Width-1 do
         For y := 0 to Bitmap.Height-1 do
         begin
            Data^.SHP.Data[1].FrameImage[x,y] := LoadPixel(Bitmap,List,Last,talg,x,y);
         end;

      // Remove Trash
      ClearColourList(List,Last);
      Bitmap.Free;
      // Unlock form.
      SetIsEditable(True);
      // Refresh Image
      ActiveForm^.RefreshImage;
   end;
   // Eliminate more trash.
   FrmQuickNewSHP.Release;
end;


//---------------------------------------------
// Paste As New Frame Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.AsANewFrame1Click(Sender: TObject);
var
   Bitmap : TBitmap;
   x,y : integer;
   talg : byte;
   List,Last:listed_colour;
   Data : TSHPImageData;
   NewImage : TSHPImageForm;
begin
   if not iseditable then Exit;
   if Not Clipboard.HasFormat(CF_BITMAP) then Exit; // No Bitmaps In Clipboard...

   Data := ActiveData;

   Bitmap := TBitmap.Create;

   Bitmap.Assign(Clipboard);

   talg := alg;
   GenerateColourList(Data^.SHPPalette,List,Last,Data^.SHPPalette[0],false,false,false);

   if talg = 0 then
      talg := AutoSelectALG_Progress(Bitmap,Data^.SHPPalette,List,Last);

   // Here we add a new frame in the end.
   inc(ActiveData^.SHP.Header.NumImages);
   SetLength(ActiveData^.SHP.Data,ActiveData^.SHP.Header.NumImages+1);
   SetLength(ActiveData^.SHP.Data[ActiveData^.SHP.Header.NumImages].FrameImage,ActiveData^.SHP.Header.Width,ActiveData^.SHP.Header.Height);
   SetLength(ActiveData^.SHP.Data[ActiveData^.SHP.Header.NumImages].Databuffer,ActiveData^.SHP.Header.Width * ActiveData^.SHP.Header.Height+1);
   Current_Frame.MaxValue := ActiveData^.SHP.Header.NumImages;
   Current_Frame.Value := Current_Frame.MaxValue;

   // 3.36: We'll give a new treatment to the imported bitmaps here.

   // First of all, if the bitmap is bigger, the user will be
   // asked to resize its SHP.
   if (Bitmap.Width > Data^.SHP.Header.Width) or (Bitmap.Height > Data^.SHP.Header.Height) then
   begin
      // We ask the user if (s)he wants to resize the SHP to the Bitmap's size.
      if MessageBox(Application.Handle,'Do you want to change the size of your image to fit the clipboard image?','Change Size?',mb_YesNo) = IDYES then
      begin
         // Here we add the code to resize it.
         AddToUndo(Data^.UndoList,Data^.SHP);
         Resize_SHP(Data^.SHP,max(Bitmap.Width,Data^.SHP.Header.Width),max(Bitmap.Height,Data^.SHP.Header.Height));

         // Resize window.
         NewImage := ActiveData^.Form;
         FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(ActiveData^.SHP.Header.Height);
         while NewImage <> nil do
         begin
            NewImage^.Item.ResizePaintArea(NewImage^.Item.Image1,NewImage^.Item.PaintAreaPanel);
            NewImage := NewImage^.Next;
         end;
         UndoUpdate(ActiveData^.UndoList);
      end;
   end;

   // 3.3: Added paste to Undo.
   AddToUndoBlankFrame(ActiveData^.UndoList,ActiveData^.SHP.Header.NumImages);
   For x := 0 to min(Bitmap.Width-1,Data^.SHP.Header.Width-1) do
      For y := 0 to min(Bitmap.Height-1,Data^.SHP.Header.Height-1) do
      begin
         Data^.SHP.Data[ActiveData^.SHP.Header.NumImages].FrameImage[x,y] := LoadPixel(Bitmap,List,Last,talg,x,y);
      end;

   // Remove Trash
   ClearColourList(List,Last);

   Current_Frame.Value := ActiveData^.SHP.Header.NumImages+1;
   Current_FrameChange(nil);

   Bitmap.Free;
   ActiveForm^.RefreshImage;
   UndoUpdate(Data^.UndoList);
end;


//---------------------------------------------
// Insert Frame Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.InsertFrame1Click(Sender: TObject);
var
   Data: TSHPImageData;
begin
   if not IsEditable then exit; // This will be removed if we do a Paste as New SHP option

   Data := ActiveData;
   if ActiveForm^.ShadowMode then
   begin
      AddToUndoBlankFrame(Data^.UndoList,ActiveForm^.FrameIndex,GetOposite(Data^.SHP,ActiveForm^.FrameIndex));
      Insertblankframe_shadow(Data^.SHP,ActiveForm^.FrameIndex);
   end
   else
   begin
      AddToUndoBlankFrame(Data^.UndoList,ActiveForm^.FrameIndex);
      Insertblankframe(Data^.SHP,ActiveForm^.FrameIndex);
   end;

   ActiveForm^.SetShadowMode(ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set
   UndoUpdate(Data^.UndoList);
end;


//---------------------------------------------
// Delete Frame Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.DeleteFrame1Click(Sender: TObject);
var
   Data: TSHPImageData;
   Form : TSHPImageForm;
begin
   if not IsEditable then exit;

   Data := ActiveData;
   if ActiveForm^.ShadowMode then
   begin
      if Data^.SHP.Header.NumImages <= 2 then
      begin
         // Just clean the frames.
         GenerateNewUndoItem(Data^.UndoList);
         ClearFrameImage(Data^.UndoList,Data^.SHP,ActiveForm^.FrameIndex);
         ClearFrameImage(Data^.UndoList,Data^.SHP,GetOposite(Data^.SHP,ActiveForm^.FrameIndex));
         NewUndoItemValidation(Data^.UndoList);
      end
      else
      begin
         AddToUndoRemovedFrame(Data^.UndoList,Data^.SHP,ActiveForm^.FrameIndex,GetOposite(Data^.SHP,ActiveForm^.FrameIndex));
         deleteframe_shadow(Data^.SHP,ActiveForm^.FrameIndex);
      end;
   end
   else
   begin
      if Data^.SHP.Header.NumImages <= 1 then
      begin
         // Just clean the frames.
         GenerateNewUndoItem(Data^.UndoList);
         ClearFrameImage(Data^.UndoList,Data^.SHP,ActiveForm^.FrameIndex);
         NewUndoItemValidation(Data^.UndoList);
      end
      else
      begin
         AddToUndoRemovedFrame(Data^.UndoList,Data^.SHP,ActiveForm^.FrameIndex);
         deleteframe(Data^.SHP,ActiveForm^.FrameIndex);
      end;
   end;

   // 3.35: Fix for deleting the last frame
   Form := ActiveData^.Form;
   // check all opened forms to make sure none of them will
   // try to access a non-existing frame.
   while Form <> nil do
   begin
      // Only affects forms displaying the last frame.
      if Form^.Item.FrameIndex > ActiveData^.SHP.Header.NumImages then
      begin
         // if it tries to access a non-existing form, it will
         // set a valid frame for it.
         Form^.Item.SetFrameIndex(ActiveData^.SHP.Header.NumImages);
         Form^.Item.RefreshImage;
      end;
      Form := Form^.Next;
   end;

   // 3.4: Helps to reduce problem with frame change.
   Current_Frame.Value := ActiveForm^.FrameIndex;

   ActiveForm^.SetShadowMode(ActiveForm^.ShadowMode); // Fakes a shadow change so frame lengths are set

   UndoUpdate(Data^.UndoList);
end;


//---------------------------------------------
// Canvas Resize Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Canvas1Click(Sender: TObject);
var
   FrmCanvasResize : TFrmCanvasResize;
   xb,xe,yb,ye:integer;
   FrameIndex : Word;
   NewImage : TSHPImageForm;
begin
   FrmCanvasResize := TFrmCanvasResize.Create(FrmMain);
   FrmCanvasResize.FrameImage := ActiveData^.SHP.Data[Current_Frame.Value].FrameImage;
   FrmCanvasResize.SHPPalette := ActiveData^.SHPPalette;
   FrmCanvasResize.Height := ActiveData^.SHP.Header.Height;
   FrmCanvasResize.Width := ActiveData^.SHP.Header.Width;
   FrmCanvasResize.LockSize := false;
   FrmCanvasResize.ShowModal;
   if FrmCanvasResize.changed then
   begin
      xb := StrToIntDef(FrmCanvasResize.SpinL.text,0);
      xe := StrToIntDef(FrmCanvasResize.SpinR.Text,0);
      yb := StrToIntDef(FrmCanvasResize.SpinT.Text,0);
      ye := StrToIntDef(FrmCanvasResize.SpinB.Text,0);

      if (((xb <> 0) or (xe <> 0)) or ((yb <> 0) or (ye <> 0))) then
      begin
         AddToUndo(ActiveData^.UndoList,ActiveData^.SHP);
         For FrameIndex := 1 to ActiveData^.SHP.Header.NumImages do
            CanvasResize(ActiveData^.SHP.Data[FrameIndex].FrameImage,FrmCanvasResize.Width,FrmCanvasResize.Height,-xb,-yb,xe,ye,0);

         ActiveData^.SHP.Header.Width := FrmCanvasResize.Width + xe + xb;
         ActiveData^.SHP.Header.Height := FrmCanvasResize.Height + ye + yb;

         NewImage := ActiveData^.Form;
         FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(ActiveData^.SHP.Header.Height);
         while NewImage <> nil do
         begin
            NewImage^.Item.ResizePaintArea(NewImage^.Item.Image1,NewImage^.Item.PaintAreaPanel);
            NewImage := NewImage^.Next;
         end;
         RefreshAll;
         UndoUpdate(ActiveData^.UndoList);
      end;
   end;
   FrmCanvasResize.Release;
end;


//---------------------------------------------
// Resize Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Resize1Click(Sender: TObject);
var
  FrmResize: TFrmResize;
  h,w : Integer;
  NewImage : TSHPImageForm;
begin
   if not isEditable then exit;

   FrmResize := TFrmResize.Create(Application);
   FrmResize.Data := ActiveData;
   FrmResize.showmodal;
   if FrmResize.changed then
   begin
      w := StrToIntDef(FrmResize.speWidth.text,0);
      h := StrToIntDef(FrmResize.speHeight.Text,0);

      if ((w > 0) and (h > 0)) then
      begin
         AddToUndo(ActiveData^.UndoList,ActiveData^.SHP);
         if FrmResize.rbBlocky.Checked then
            Resize_Frames_Blocky(ActiveData^.SHP,w,h)
         else
            Resize_Frames_MSPaint(ActiveData^.SHP,ActiveData^.SHPPalette,w,h);
      end
      else
      begin
         MessageBox(0,'Error: Only positive and non-null numbers may be entered','Resize Error',0);
         exit;
      end;
      FrmResize.Release;

      NewImage := ActiveData^.Form;
      while NewImage <> nil do
      begin
         FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(ActiveData^.SHP.Header.Height);
         NewImage^.Item.ResizePaintArea(NewImage^.Item.Image1,NewImage^.Item.PaintAreaPanel);
         NewImage := NewImage^.Next;
      end;
      RefreshAll;
      UndoUpdate(ActiveData^.UndoList);
   end;
end;


// *************************************************
// *********** Palette Canvas Procedures ***********
// *************************************************

procedure SplitColour(raw: TColor; var red, green, blue: Byte);
begin
   red := (raw and $00FF0000) shr 16;
   green := (raw and $0000FF00) shr 8;
   blue := raw and $000000FF;
end;


//---------------------------------------------
// Canvas Palette Paint
//---------------------------------------------
procedure TSHPBuilderFrmMain.cnvPalettePaint(Sender: TObject);
var
   colwidth, rowheight: Real;
   i, j, idx: Integer;
   r: TRect;
   red, green, blue, mixcol,SColour: Byte;
begin
   if ActiveData = nil then exit;

   CurrentPaletteID := ActiveData^.SHPPaletteFilename;
   //lblPalette.Caption := extractfilename(ActiveData^.SHPPaletteFilename);
   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   idx := 0;

   if (isEditable) then // split to avoid access violation
      if MainData^.Next <> nil then
      begin
         if IsShadow(ActiveData^.SHP,ActiveForm^.FrameIndex) and (ActiveForm^.ShadowMode) then
         begin
            SColour := ActiveForm^.ShadowColour;
            ActiveData^.PaletteMax := 2;
         end
         else
         begin
            SColour := ActiveForm^.ActiveColour;
            ActiveData^.PaletteMax := 256;
         end;
      end
      else
      begin
         SColour := 16;
         ActiveData^.PaletteMax := 256;
      end;

   for i := 0 to 8 do
   begin
      r.Left := Trunc(i * colwidth);
      r.Right := Ceil(r.Left + colwidth);
      for j := 0 to 31 do
      begin
         r.Top := Trunc(j * rowheight);
         r.Bottom := Ceil(r.Top + rowheight);
         if Idx < ActiveData^.PaletteMax then
            with cnvPalette.Canvas do
            begin
               if isEditable then
                  Brush.Color := ActiveData^.SHPPalette[idx]
               else
                  Brush.Color := ActiveData^.Shadow_Match[idx].Original;

               if (Idx = SColour) then
               begin // the current pen
                  SplitColour(ActiveData^.SHPPalette[idx],red,green,blue);
                  mixcol := (red + green + blue);
                  Pen.Color := RGB(128 + mixcol,255 - mixcol, mixcol);
                  //Pen.Mode := pmNotXOR;
                  Rectangle(r.Left,r.Top,r.Right,r.Bottom);
                  MoveTo(r.Left,r.Top);
                  LineTo(r.Right,r.Bottom);
                  MoveTo(r.Right,r.Top);
                  LineTo(r.Left,r.Bottom);
               end
               else
                  FillRect(r);
            end;
         Inc(Idx);
      end;
   end;
end;


//---------------------------------------------
// Canvas Palette Mouse Button Up
//---------------------------------------------
procedure TSHPBuilderFrmMain.cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   colwidth, rowheight: Real;
   i, j, idx: Integer;
begin
   If not isEditable then exit;

   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   i := Trunc(X / colwidth);
   j := Trunc(Y / rowheight);
   idx := (i * 32) + j;
   if idx < ActiveData^.PaletteMax then
      if Button = mbLeft then
      begin
         if IsShadow(ActiveData^.SHP,ActiveForm^.FrameIndex) and (ActiveForm^.ShadowMode) then
         begin
            if idx <> ActiveForm^.ShadowColour then
               ActiveForm^.SetShadowColour(idx);
         end
         else if idx <> ActiveForm^.ActiveColour then
            ActiveForm^.SetActiveColour(idx);
      end
      else
      begin
         if idx <> ActiveForm^.BackGroundColour then
            ActiveForm^.SetBackGroundColour(idx);
      end;
end;


//---------------------------------------------
// Toogle Background Colour MenuItem Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToogleBackgroundColourMenuItemClick(Sender: TObject);
begin
   ToogleBackgroundColourMenuItem.Checked := not ToogleBackgroundColourMenuItem.Checked;
   SetBackgroundColorEnabled(ToogleBackgroundColourMenuItem.Checked);
end;


//---------------------------------------------
// Enable/disable SHP BackgroundColor
//---------------------------------------------
procedure TSHPBuilderFrmMain.SetBackgroundColorEnabled(enabled : boolean);
begin
   if (ActiveForm <> nil) then
      ActiveForm^.SetBackgroundColorEnabled(enabled);

   OtherOptionsData.BackgroundColorEnabled := enabled;
   RefreshBackgroundUIComponents;
end;


//---------------------------------------------
// Show/hide background
//---------------------------------------------
procedure TSHPBuilderFrmMain.SetShowBackground(value : boolean);
begin
   if (ActiveForm <> nil) then
      ActiveForm^.SetShowBackground(value);
end;


///---------------------------------------------
// Reset TempView.
//---------------------------------------------
procedure TSHPBuilderFrmMain.ResetTempView;
begin
   SetLength(TempView, 0);
   TempViewLength := 0;
end;


//---------------------------------------------
// Preview Brush MenuItem Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.PreviewBrush1Click(Sender: TObject);
begin
   PreviewBrush := not PreviewBrush;
   PreviewBrush1.Checked := PreviewBrush;
end;


//---------------------------------------------
// On Palette Loaded
//---------------------------------------------
Procedure TSHPBuilderFrmMain.PaletteLoaded(_Filename: string);
begin
   lblPalette.caption := ExtractFilename(_Filename);
   if self.MDIChildCount <> 0 then
      Current_FrameChange(nil);

   if isEditable then
   begin
      // Background of the ActiveForm
      ActiveForm^.PaintAreaPanel.Color := ActiveData^.SHPPalette[0];

      if ActiveData^.Preview <> nil then
      begin
         ActiveData^.Preview.UpdatePalette(ActiveData^.SHPPalette);
         ActiveData^.Preview.TrackBar1Change(nil);
      end;

      ActiveForm^.SetBackGroundColour(ActiveForm^.BackGroundColour);
      if IsShadow(ActiveData^.SHP,ActiveForm^.FrameIndex) then
         ActiveForm^.SetShadowColour(ActiveForm^.ShadowColour)
      else
         ActiveForm^.SetActiveColour(ActiveForm^.ActiveColour);
   end
   else
      // It also repaints when it is Editable, at SetActive/ShadowColour
      cnvPalette.Repaint;
end;


//---------------------------------------------
// Refresh SHP Background Colour UI Components
//---------------------------------------------
procedure TSHPBuilderFrmMain.RefreshBackgroundUIComponents;
var
  Data : TSHPImageData;
  enabled : boolean;
  cBackground :  TColor;
begin
   enabled := false;
   cBackground := clGray;

   if (ActiveForm <> nil) then
   begin
      Data := ActiveForm^.Data;
      enabled := ActiveForm^.BackgroundColorEnabled;

      if ActiveForm^.BackgroundColorEnabled then
      begin
         lblBackGroundColour.Caption := IntToStr(ActiveForm^.BackGroundColour) + ' (0x' + IntToHex(ActiveForm^.BackGroundColour,3) + ')';
         cBackground := Data^.SHPPalette[ActiveForm^.BackGroundColour];
      end
      else      
      begin
         lblBackGroundColour.Caption := '< OFF >';
         cBackground := clGray;
      end;
      cbShowBackground.Checked := ActiveForm^.ShowBackground;
   end;
   
   pnlBackGroundColour.Color := cBackground;
   pnlBackGroundColour.Enabled := enabled;
   ToogleBackgroundColourMenuItem.Checked := enabled;

end;


//---------------------------------------------
// Set/Load Palette for active SHP Context.
//---------------------------------------------
Procedure TSHPBuilderFrmMain.SetPalette(_Filename:string);
begin
   if ActiveData <> nil then
   begin
      if FileExists(_Filename) then
      begin
         LoadAPaletteFromFile(_Filename,ActiveData^.SHPPalette); // Makes it JASC Compatible
         GenerateShadowCache(ActiveData);
         ActiveData^.SHPPaletteFilename := _Filename;
         PaletteLoaded(_Filename);
         OtherOptionsData.LastPalettePath := _Filename;
         if ActiveForm <> nil then
            ActiveForm^.RefreshImage;
      end;
   end;
end;


//---------------------------------------------
// Load Palette MenuItem Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.Load1Click(Sender: TObject);
begin
   OpenPaletteDialog.InitialDir := OpenPaletteDir;
   if OpenPaletteDialog.Execute then
   begin
      OpenPaletteDir := ExtractFileDir(OpenPaletteDialog.FileName);

      SetPalette(OpenPaletteDialog.FileName);
      if ActiveForm <> nil then
         ActiveForm^.ResizePaintArea(ActiveForm^.Image1,ActiveForm^.PaintAreaPanel);
   end;
end;


//---------------------------------------------
// Load Palette MenuItems
//---------------------------------------------
function TSHPBuilderFrmMain.LoadPalettesMenu : integer;
var
   f: TSearchRec;
   path: String;
   Filename : string;
   item: TMenuItem;
   c,t : integer;
begin
   // prepare
   c := 0;

   // 3.35 Adition: Support for TD and RA1 palettes.
   // Now Load TD Palettes
   SetLength(PaletteSchemes,c);
   iberianDawn1.Visible := false;
   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\TD\','*.pal');
   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\TD\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);

      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := 24;

      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      iberianDawn1.Insert(c,item);
      iberianDawn1.visible := true;

   until FindNext(f) <> 0;
   FindClose(f);

   t := c;

   // Now Load RA1 Palettes
   SetLength(PaletteSchemes,c+1);
   RedAlert11.Visible := false;

   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\RA1\','*.pal');
   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\RA1\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);

      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := 23;

      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      RedAlert11.Insert(c-t,item);
      RedAlert11.visible := true;

   until FindNext(f) <> 0;
   FindClose(f);

   t := c;
   // --- End of 3.35 adition.

   // Now Load TS Palettes
   SetLength(PaletteSchemes,c+1);
   iberianSun1.Visible := false;
   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\TS\','*.pal');
   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\TS\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);
      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := 0;
      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      iberianSun1.Insert(c-t,item);
      iberianSun1.visible := true;

   until FindNext(f) <> 0;
      FindClose(f);

   t := c;

   // Now Load RA2 Palettes

   SetLength(PaletteSchemes,c+1);
   RedAlert21.Visible := false;
   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\RA2\','*.pal');

   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\RA2\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);
      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := 2;
      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      RedAlert21.Insert(c-t,item);
      RedAlert21.visible := true;

   until FindNext(f) <> 0;
      FindClose(f);

   t := c;

   // Now Load YR Palettes
   SetLength(PaletteSchemes,c+1);
   YurisRevenge1.Visible := false;

   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\YR\','*.pal');

   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\YR\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);

      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := 3;

      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      YurisRevenge1.Insert(c-t,item);
      YurisRevenge1.visible := true;

   until FindNext(f) <> 0;
      FindClose(f);

   t := c;

   // Now Load User's Palettes
   SetLength(PaletteSchemes,c+1);
   Custom1.Visible := false;

   path := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\User\','*.pal');

   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFileDir(ParamStr(0))+'\Palettes\User\',f.Name);
      inc(c);
      SetLength(PaletteSchemes,c+1);
      PaletteSchemes[c].FileName := Filename;
      PaletteSchemes[c].ImageIndex := -1;
      item := TMenuItem.Create(Owner);
      item.Caption := extractfilename(PaletteSchemes[c].FileName);
      item.Tag := c; // so we know which it is
      item.OnClick := LoadPaletteSchemeClick;

      Custom1.Insert(c-t,item);
      Custom1.visible := true;

   until FindNext(f) <> 0;
      FindClose(f);

   Result := c;
end;


//---------------------------------------------
// Update Active SHP Gametype
//---------------------------------------------
procedure TSHPBuilderFrmMain.updateGame(ID : integer);
begin
   case (ID) of
   0: ActiveData^.SHP.SHPGame := sgTS;
   2: ActiveData^.SHP.SHPGame := sgRA2;
   3: ActiveData^.SHP.SHPGame := sgRA2;
   23: ActiveData^.SHP.SHPGame := sgRA1;
   24: ActiveData^.SHP.SHPGame := sgTD;
   end;

   if ActiveForm <> nil then
   begin
      ActiveForm^.UpdateSHPTypeFromGame;
      ActiveForm^.WriteSHPType;
      ActiveForm^.UpdateSHPTypeMenu;
   end;
end;


//---------------------------------------------
// Load Default Palette MenuItem Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.LoadPaletteSchemeClick(Sender: TObject);
begin
   SetPalette(PaletteSchemes[TMenuItem(Sender).Tag].FileName);

   // Update SHP GameType according to the selected palette.
   if PaletteSchemes[TMenuItem(Sender).Tag].ImageIndex <> -1 then
   begin
      if OtherOptionsData.AutoSelectSHPType then
      begin
         UpdateGame(PaletteSchemes[TMenuItem(Sender).Tag].ImageIndex);
      end;
   end;
end;

// **************************************************
// ************** View Menu Procedures **************
// **************************************************

procedure TSHPBuilderFrmMain.NewWindow1Click(Sender: TObject);
begin
   if ActiveData <> nil then 
   begin
      SetIsEditable(False);
      if GenerateNewWindow(ActiveData) then
      begin
         LoadNewSHPImageSettings(ActiveData,ActiveForm^);
      end
      else
      begin
         ShowMessage('MDI Error: Could not create window due to low memory!');
      end;
      SetIsEditable(True);
   end;
end;

procedure TSHPBuilderFrmMain.Preview1Click(Sender: TObject);
var
   FrmPreview : TFrmPreview;
begin
   if not isEditable then exit;

   if Preview1.Checked then
   begin
      if ActiveData^.Preview <> nil then
         ActiveData^.Preview^.Close;
      Preview1.Checked := false;
      TbPreviewWindow.Down := false;
   end
   else
   begin
      if ActiveData^.Preview = nil then
      begin
         New(ActiveData^.Preview);
         ActiveData^.Preview^ := TFrmPreview.Create(self);
         ActiveData^.Preview^.Data := ActiveData;
         ActiveData^.Preview^.ActiveForm := ActiveForm;
         ActiveData^.Preview^.Parent := self;
         ActiveData^.Preview^.Show;
      end;
      Preview1.Checked := true;
      TbPreviewWindow.Down := true;
   end;
end;

procedure TSHPBuilderFrmMain.ArrangeIcons1Click(Sender: TObject);
begin
   ArrangeIcons;
end;

procedure TSHPBuilderFrmMain.Cascade1Click(Sender: TObject);
begin
   Cascade;
end;


//---------------------------------------------
// Checkbox Show Background Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.cbShowBackgroundClick(Sender: TObject);
begin
   SetShowBackground(cbShowBackground.Checked);
end;


//---------------------------------------------
// Button Show Center Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowCenter1Click(Sender: TObject);
begin
   TbShowCenterClick(Sender);
end;


//---------------------------------------------
// Button Show Center Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.TbShowCenterClick(Sender: TObject);
begin
   ActiveForm^.ShowCenter := not ActiveForm^.ShowCenter;
   TbShowCenter.Down := ActiveForm^.ShowCenter;

   ActiveForm^.RefreshImage;
end;

procedure TSHPBuilderFrmMain.TbPreviewWindowClick(Sender: TObject);
begin
   Preview1Click(Sender);
end;

procedure TSHPBuilderFrmMain.ile1Click(Sender: TObject);
begin
   Tile;
end;


// ********************************************************** //
// * Procedures To Access A Editing Window At The View Menu * //
// ********************************************************** //

procedure TSHPBuilderFrmMain.AddNewWindowMenu(const Form:TFrmSHPImage; const Filename:string);
var
   Item:TMenuItem;
begin
   // This part adds a new window in the View menu.
   Item := TMenuItem.Create(Owner);
   Item.Caption := extractfilename(Filename);
   // The line below give us the address of the window that
   // we want to activate. Sacred data.
   Item.Tag := Integer(Form.Address);
   Item.OnClick := WindowItemClicked;
   Item.Visible := true;

   View1.Insert(View1.Count,item);
end;

procedure TSHPBuilderFrmMain.WindowItemClicked(Sender : TObject);
var
   Form : ^TFrmSHPImage;
begin
   Form := Pointer(TMenuItem(Sender).Tag);
   Form^.FormActivate(nil);
end;


procedure TSHPBuilderFrmMain.RemoveNewWindowMenu(const Form:TFrmSHPImage);
var
   count:integer;
begin
   // Gets the max ammount of objects on the view menu.
   count := View1.Count -1;

   // Searchs for the window to be removed.
   while ((count > VIEWMENU_MINIMUM) and (View1.Items[count].Tag <> Integer(Form.Address))) do
      dec(count);

   if count = (VIEWMENU_MINIMUM - 1) then
   begin
      Showmessage('Error! Window Menu Item does not exist! It can not be removed. Please report this bug at OS SHP Builder Bug Reporting forum');
      exit;
   end;

   View1.Delete(count);
end;

// ****************************************************
// ******** Tools Procedures And Stuff Related ********
// ****************************************************

// Edge Test Stuff:
procedure TSHPBuilderFrmMain.AddTocolourList(colour:byte);
var
   x : byte;
begin
   if Colour_list_no > 0 then
      for x := 1 to Colour_list_no do
         if colour = Colour_list[x].colour then
         begin
            Colour_list[x].count := Colour_list[x].count+1;
            exit;
         end;

   Colour_list_no := Colour_list_no+1;
   SetLength(Colour_list,Colour_list_no+1);
   Colour_list[Colour_list_no].colour := colour;
   Colour_list[Colour_list_no].count := 1;
end;

procedure TSHPBuilderFrmMain.test1Click(Sender: TObject);
var
   x,y,z : integer;
   max,maxc,p : integer;
   FrameImage : array of array of Byte;
   Data : TSHPImageData;
begin
   if not isEditable then exit;

   Data := ActiveData;

   Setlength(FrameImage,Data^.SHP.Header.Width,Data^.SHP.Header.Height);

   for x := 0 to Data^.SHP.Header.Width-1 do
   for y := 0 to Data^.SHP.Header.Height-1 do
   if Data^.SHP.Data[Current_Frame.Value].FrameImage[x,y] > 0 then
   begin
      Colour_list_no := 0;
      SetLength(Colour_list,0);

      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x-1,y-1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y-1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x+1,y-1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x-1,y]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x-1,y+1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y+1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x+1,y+1]);
      AddTocolourList(Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x+1,y]);

      max := -1;
      maxc := -1;
      p := 0;

      if Colour_list_no > 0 then
         for z := 1 to Colour_list_no do
            if Colour_list[z].count > max then
            begin
               max := Colour_list[z].count;
               maxc := z;
               if Colour_list[z].colour = 0 then
                  p := Colour_list[z].count;
            end;

      if p > 2 then
         FrameImage[x,y] := Colour_list[maxc].colour
      else
         FrameImage[x,y] := Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y];
   end
   else
      FrameImage[x,y] := Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y];

   for x := 0 to Data^.SHP.Header.Width-1 do
      for y := 0 to Data^.SHP.Header.Height-1 do
         Data^.SHP.Data[ActiveForm^.FrameIndex].FrameImage[x,y] := FrameImage[x,y];

   ActiveForm^.RefreshImage;
end;

// AntiAlias
procedure TSHPBuilderFrmMain.AntiAlias1Click(Sender: TObject);
var
   Bitmap : TBitmap;
   talg : byte;
   List,Last:listed_colour;
   Data : TSHPImageData;
begin
   if not isEditable then exit;
   Data := ActiveData;

   AddToUndo(Data^.UndoList,Data^.SHP,ActiveForm^.FrameIndex);
   UndoUpdate(Data^.UndoList);

   Bitmap := GetBMPOfFrameImage(Data^.SHP,ActiveForm^.FrameIndex, Data^.SHPPalette);
   GenerateColourList(Data^.SHPPalette,List,Last,Bitmap.canvas.pixels[0,0],false,false,false);

   if alg = 0 then
      talg := AutoSelectALG_Progress(Bitmap,Data^.SHPPalette,List,Last)
   else
      talg := alg;

   SetFrameImageFrmBMP2NoBG(Data^.SHP, ActiveForm^.FrameIndex, Data^.SHPPalette,AntiAlias_S2(Bitmap,Bitmap.canvas.pixels[0,0]),Bitmap.canvas.pixels[0,0],talg,true,false);
   Bitmap.Free; 
   RefreshAll;
end;

// Working Stuff

// Effects
// ;;;;;;;;;;;;;;;;;;

// Range options:
procedure TSHPBuilderFrmMain.CurrentFrame1Click(Sender: TObject);
begin
   CurrentFrame1.Checked := true;
   AllFrames2.Checked := false;
   FromTo1.Checked := false;
end;

procedure TSHPBuilderFrmMain.AllFrames2Click(Sender: TObject);
begin
   CurrentFrame1.Checked := false;
   AllFrames2.Checked := true;
   FromTo1.Checked := false;
end;

procedure TSHPBuilderFrmMain.FromTo1Click(Sender: TObject);
begin
   CurrentFrame1.Checked := false;
   AllFrames2.Checked := false;
   FromTo1.Checked := true;
end;

// Region options:
procedure TSHPBuilderFrmMain.SelectedArea1Click(Sender: TObject);
begin
   SelectedArea1.Checked := true;
   WholeFrame2.Checked := false;
end;

procedure TSHPBuilderFrmMain.WholeFrame2Click(Sender: TObject);
begin
   SelectedArea1.Checked := false;
   WholeFrame2.Checked := true;
end;

// Background options:
procedure TSHPBuilderFrmMain.Ignore01Click(Sender: TObject);
begin
   Ignore01.Checked := true;
   Consider0as0001.Checked := false;
   WriteOnBackground1.Checked := false;
end;

procedure TSHPBuilderFrmMain.Consider0as0001Click(Sender: TObject);
begin
   Ignore01.Checked := false;
   Consider0as0001.Checked := true;
   WriteOnBackground1.Checked := false;
end;

// Colour Settings
procedure TSHPBuilderFrmMain.WriteOnBackground1Click(Sender: TObject);
begin
   Ignore01.Checked := false;
   Consider0as0001.Checked := false;
   WriteOnBackground1.Checked := true;
end;

procedure TSHPBuilderFrmMain.AutoSelectSHPType1Click(Sender: TObject);
begin
   AutoSelectSHPType1.Checked := not AutoSelectSHPType1.Checked;
   OtherOptionsData.AutoSelectSHPType := AutoSelectSHPType1.Checked;
end;

procedure TSHPBuilderFrmMain.Dontuse216and2392551Click(Sender: TObject);
begin
   DontUse216and2392551.Checked := not DontUse216and2392551.Checked;
end;

// Peak Colour Control
procedure TSHPBuilderFrmMain.EnabledPercentualCorrection1Click(Sender: TObject);
begin
   EnabledPercentualCorrection1.Checked := true;
   EnabledAvarageCorrection1.Checked := false;
   EnabledRemovePeakPixels1.Checked := false;
   Disabled1.Checked := false;
end;

procedure TSHPBuilderFrmMain.EnabledAvarageCorrection1Click(Sender: TObject);
begin
   EnabledPercentualCorrection1.Checked := false;
   EnabledAvarageCorrection1.Checked := true;
   EnabledRemovePeakPixels1.Checked := false;
   Disabled1.Checked := false;
end;

procedure TSHPBuilderFrmMain.EnabledRemovePeakPixels1Click(Sender: TObject);
begin
   EnabledPercentualCorrection1.Checked := false;
   EnabledAvarageCorrection1.Checked := false;
   EnabledRemovePeakPixels1.Checked := true;
   Disabled1.Checked := false;
end;

procedure TSHPBuilderFrmMain.Disabled1Click(Sender: TObject);
begin
   EnabledPercentualCorrection1.Checked := false;
   EnabledAvarageCorrection1.Checked := false;
   EnabledRemovePeakPixels1.Checked := false;
   Disabled1.Checked := true;
end;

// *******************************************
// ****** Serius stuff: Image Effects ********
// *******************************************

procedure TSHPBuilderFrmMain.ConservativeSmooth1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      ConservativeSmoothing(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MeanCross1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      MeanCross(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Mean3x31Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      Mean(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,1,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Mean5x51Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);
   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Mean(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,2,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Mean7x71Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);


   GenerateNewUndoItem(ActiveData^.UndoList);
   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Mean(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,3,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MeanSquared3x31Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      MeanSquared(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,1,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MeanSquared5x51Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      MeanSquared(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,2,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MeanSquared7x71Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      MeanSquared(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,3,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MeanXored1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   // Now the main procedures
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := FirstFrame to LastFrame do
      MeanXor(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,1,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MedianCross1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      MedianCross(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.menuItemUninstallClick(Sender: TObject);
var
   Form: TFrmUninstall;
begin
   Form := TFrmUninstall.Create(self);
   Form.ShowModal;
   Form.Release;
end;

procedure TSHPBuilderFrmMain.Median3x31Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Median(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,1,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Median5x51Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Median(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,2,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Median7x71Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Median(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,3,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.UnsharpMasking1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
   begin
      SetLength(Matrix,ActiveData^.SHP.Header.Width+1,ActiveData^.SHP.Header.Height+1);
      UnsharpMasking(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg);
      ConvertMatrixToFrameImage(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);
   end;

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.ShapeningBallanced1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      SharpeningBallanced(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.ShapeningUmballanced1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      SharpeningUmballanced(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.UndoList);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Exponential1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
   begin
      SetLength(Matrix,ActiveData^.SHP.Header.Width+1,ActiveData^.SHP.Header.Height+1);
      Exponential(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg);
      ConvertMatrixToFrameImage(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);
   end;

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Logarithmize1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
   begin
      SetLength(Matrix,ActiveData^.SHP.Header.Width+1,ActiveData^.SHP.Header.Height+1);
      Logarithm(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg);
      ConvertMatrixToFrameImage(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);
   end;

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.LogarithmLighting1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
   begin
      SetLength(Matrix,ActiveData^.SHP.Header.Width+1,ActiveData^.SHP.Header.Height+1);
      LogarithmLighting(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg);
      ConvertMatrixToFrameImage(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);
   end;

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.LogarithmDarkening1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
   begin
      SetLength(Matrix,ActiveData^.SHP.Header.Width+1,ActiveData^.SHP.Header.Height+1);
      LogarithmDarkening(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg);
      ConvertMatrixToFrameImage(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.UndoList);
   end;

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.ButtonizeWeak1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      ButtonizeWeak(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.ButtonizeStrong1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      ButtonizeStrong(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.ButtonizeVeryStrong1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      ButtonizeVeryStrong(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.BasicTexturizer1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      BasicTexturizer(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.IcedTexturizer1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      IcedTexturizer(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.WhiteTexturizer1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      WhiteTexturizer(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.PetroglyphSobel1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Petroglyph(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.StonifyPrewitt1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Stonify(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.RockIt1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Rocker(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.MessItUp1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      MessItUp(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.XDepth1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      X_Depth(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.UnFocus1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      UnFocus(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.Underline1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Underline(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.PolygonMean1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      PolyMean(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,2,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;

procedure TSHPBuilderFrmMain.SquareDepth1Click(Sender: TObject);
var
   Frame,FirstFrame,LastFrame,minx,maxx,miny,maxy:word;
   Bg:smallint;
   alg,mode : byte;
   colourtemp: Tcolor;
   Matrix : TRGBFrame;
begin
   // Get range, region and background settings
   GetFastSettings(ActiveData^.SHP,FirstFrame,LastFrame,minx,maxx,miny,maxy,CurrentFrame1.Checked,AllFrames2.Checked,SelectedArea1.Checked);
   GetBackgroundSettings(ActiveData^.SHPPalette,colourtemp,Bg,Ignore01.Checked,Consider0as0001.Checked,alg);
   GetPeakMode(mode);

   GenerateNewUndoItem(ActiveData^.UndoList);

   // Now the main procedures
   for Frame := FirstFrame to LastFrame do
      Square_Depth(ActiveData^.SHP,ActiveData^.SHPPalette,Frame,minx,maxx,miny,maxy,Matrix,Bg,DontUse216and2392551.Checked,RedToRemapable1.Checked,alg,mode,ActiveData^.Undolist);

   // Finish it.
   NewUndoItemValidation(ActiveData^.UndoList);
   FrmMain.UndoUpdate(ActiveData^.UndoList);
   ActiveData^.SHPPalette[0] := colourtemp;
   FrmMain.RefreshAll;
end;


// *************************************
// Image Rotation     *****************************
// ********************************************

procedure TSHPBuilderFrmMain.Mirror1Click(Sender: TObject);
var
   Form : TFrmMirrorSHP;
begin
   Form := TFrmMirrorSHP.Create(self);
   Form.OpType := C_SHPFX_MIRROR;
   Form.ShowModal;
   Form.Release;
end;


procedure TSHPBuilderFrmMain.FlipFrames1Click(Sender: TObject);
var
   Form : TFrmMirrorSHP;
begin
   Form := TFrmMirrorSHP.Create(self);
   Form.OpType := C_SHPFX_FLIP;
   Form.ShowModal;
   Form.Release;
end;

// *************************************
// Fixes     *****************************
// ********************************************
procedure TSHPBuilderFrmMain.FixShadows1Click(Sender: TObject);
var
   bgcolour : byte;
   x,xx,yy : integer;
begin
   if not isEditable then exit;

   if not ActiveForm^.ShadowMode then
   begin
      MessageBox(0,'Error Shadows are OFF','Fix Shadow Error',0);
      exit;
   end;

   if ActiveData^.SHP.SHPGame <> sgTS then
   begin
      MessageBox(0,'Skipping: Fix Shadows is only recommended for TS!','Fix Shadow Error',0);
      exit;
   end;

   BGColour := ActiveData^.SHP.Data[(ActiveData^.SHP.Header.NumImages div 2)+1].FrameImage[0,0];

   GenerateNewUndoItem(ActiveData^.UndoList);
   for x := (ActiveData^.SHP.Header.NumImages div 2)+1 to ActiveData^.SHP.Header.NumImages do
   begin
      for xx := 0 to ActiveData^.SHP.Header.Width-1 do
      for yy := 0 to ActiveData^.SHP.Header.Height-1 do
         if ActiveData^.SHP.Data[x].FrameImage[xx,yy] = BGColour then
            ActiveData^.SHP.Data[x].FrameImage[xx,yy] := 0
         else
         begin
            AddToUndoMultiFrames(ActiveData^.UndoList,x,xx,yy,ActiveData^.SHP.Data[x].FrameImage[xx,yy]);
            ActiveData^.SHP.Data[x].FrameImage[xx,yy] := 1;
         end;
   end;
   NewUndoItemValidation(ActiveData^.UndoList);
   UndoUpdate(ActiveData^.UndoList);
   RefreshAll;

   Messagebox(0,'Shadows Fixed','Fix Shadow',0);
end;

// 3.36: Remove shadow pixels from painted pixels. 
procedure TSHPBuilderFrmMain.RemoveUselessShadowPixels1Click(Sender: TObject);
var
   Frame : integer;
   MidFrame : integer;
   x,y : integer;
begin
   // Initial validation;
   if not IsEditable then exit;
   if ActiveData = nil then exit;
   if not ((ActiveData^.SHP.Header.NumImages mod 2 = 0) and (ActiveData^.SHP.Header.NumImages > 0)) then exit;
   if ActiveForm = nil then exit;
   if not ActiveForm^.ShadowMode then exit;

   // Now, let's start with the stuff.
   MidFrame := ActiveData^.SHP.Header.NumImages div 2;
   GenerateNewUndoItem(ActiveData^.UndoList);
   for Frame := 1 to MidFrame do
   begin
      for x := 0 to ActiveData^.SHP.Header.Width - 1 do
         for y := 0 to ActiveData^.SHP.Header.Height - 1 do
         begin
            if (ActiveData^.SHP.Data[Frame].FrameImage[x,y] <> 0) and (ActiveData^.SHP.Data[MidFrame + Frame].FrameImage[x,y] <> 0) then
            begin
               AddToUndoMultiFrames(ActiveData^.UndoList,Frame,x,y,ActiveData^.SHP.Data[MidFrame + Frame].FrameImage[x,y]);
               ActiveData^.SHP.Data[MidFrame + Frame].FrameImage[x,y] := 0;
            end;
         end;
   end;
   NewUndoItemValidation(ActiveData^.UndoList);
   UndoUpdate(ActiveData^.UndoList);
   RefreshAll;

   Messagebox(0,'Useless Shadow Pixels Have Been Terminated. We have killed every zig! Survive, make your time.','All your base are belong to us',0);
end;

procedure TSHPBuilderFrmMain.AutoShadows1Click(Sender: TObject);
var
   FrmAutoShadows: TFrmAutoShadows;
begin
   if not isEditable then exit;

   FrmAutoShadows := TFrmAutoShadows.Create(Application);
   FrmAutoShadows.Data := ActiveData;
   FrmAutoShadows.ShowModal;
   FrmAutoShadows.BitmapOriginal.Free;
   FrmAutoShadows.BitmapRotated.Free;
   FrmAutoShadows.Release;
end;

procedure TSHPBuilderFrmMain.CameoGenerator1Click(Sender: TObject);
var
  FrmCameoGenerator: TFrmCameoGenerator;
begin
   if not isEditable then exit;

   FrmCameoGenerator := TFrmCameoGenerator.Create(Application);
   FrmCameoGenerator.Data := ActiveData;
   FrmCameoGenerator.ShowModal;
   FrmCameoGenerator.Release;
end;

procedure TSHPBuilderFrmMain.Sequence1Click(Sender: TObject);
var
   FrmSequence: TFrmSequence;
begin
   if not isEditable then exit;

   FrmSequence := TFrmSequence.Create(Application);
   FrmSequence.Data := ActiveData;
   FrmSequence.showmodal;
   FrmSequence.Release;
end;

// 3.34: Frame Splitter.
procedure TSHPBuilderFrmMain.FrameSplitter1Click(Sender: TObject);
var
   FrmFrameSplitter : TFrmFrameSplitter;
   Data : TSHPImageData;
begin
   // Open Frame Splitter
   FrmFrameSplitter := TFrmFrameSplitter.Create(Application);
   FrmFrameSplitter.SpeFrameNum.MaxValue := ActiveData^.SHP.Header.NumImages;
   FrmFrameSplitter.InitialWidth := ActiveData^.SHP.Header.Width;
   FrmFrameSplitter.InitialHeight := ActiveData^.SHP.Header.Height;
   FrmFrameSplitter.SpeFrameNum.Value := ActiveForm^.FrameIndex;
   FrmFrameSplitter.SpeHorizontal.MaxValue := FrmFrameSplitter.InitialWidth;
   FrmFrameSplitter.SpeVertical.MaxValue := FrmFrameSplitter.InitialHeight;
   FrmFrameSplitter.EdWidth.Text := IntToStr(FrmFrameSplitter.InitialWidth);
   FrmFrameSplitter.EdHeight.Text := IntToStr(FrmFrameSplitter.InitialHeight);
   FrmFrameSplitter.ShowModal;

   // Check if it was changed
   if FrmFrameSplitter.Changed then
   begin
   // -- Do necessary changes
   // -- Generate a new SHP file.
      SetIsEditable(False);
      if AddNewSHPDataItem(Data,ActiveData,TotalImages,FrmFrameSplitter.SpeFrameNum.Value,FrmFrameSplitter.SpeHorizontal.Value,FrmFrameSplitter.SpeVertical.Value,FrmFrameSplitter.ComboOrder.ItemIndex,StrToInt(FrmFrameSplitter.EdWidth.Text),StrToInt(FrmFrameSplitter.EdHeight.Text)) then
      begin
         if GenerateNewWindow(Data) then
            LoadNewSHPImageSettings(Data,ActiveForm^)
         else
         begin
            ClearUpData(Data);
            ShowMessage('MDI Error! Out of memory to create new window!');
         end;
      end
      else
      begin
         ShowMessage('Error! New SHP could not be created due to lack of memory!');
      end;
      SetIsEditable(True);
   // -- Note: No Undo Item will be generated, since it creates a new SHP
   end;

   FrmFrameSplitter.Release;
end;

// 3.35: Imported from 3.4:: Convert Shadows (RA2 -> TS)
procedure TSHPBuilderFrmMain.ConvertShadowsRA2TS1Click(Sender: TObject);
var
   Frame,Shadow : word;
   x,y: longword;
begin
   // Basic Check Up
   if not isEditable then exit;
   if not ActiveForm^.ShadowMode then
   begin
      MessageBox(0,'Error! Shadows are OFF','Convert Shadow Error',0);
      exit;
   end;

   // Start New Undo
   GenerateNewUndoItem(ActiveData^.UndoList);
   // For cache purposes:
   Shadow := (ActiveData^.SHP.Header.NumImages div 2);
   // scan all non-shadow frames
   For Frame := 1 to (ActiveData^.SHP.Header.NumImages div 2) do
   begin
      // Scan each pixel
      for x := 0 to (ActiveData^.SHP.Header.Width-1) do
      for y := 0 to (ActiveData^.SHP.Header.Height-1) do
      begin
         // Search for colour #12
         if ActiveData^.SHP.Data[Frame].FrameImage[x,y] = 12 then
         begin
            // Delete RA2 Shadow and Make TS shadow
            AddToUndoMultiFramesB(ActiveData^.UndoList,Frame,x,y,ActiveData^.SHP.Data[Frame].FrameImage[x,y]);
            ActiveData^.SHP.Data[Frame].FrameImage[x,y] := 0;
            AddToUndoMultiFramesB(ActiveData^.UndoList,Frame + Shadow,x,y,ActiveData^.SHP.Data[Frame + Shadow].FrameImage[x,y]);
            ActiveData^.SHP.Data[Frame + Shadow].FrameImage[x,y] := 1;
         end;
      end;
   end;
   NewUndoItemValidation(ActiveData^.UndoList);
   UndoUpdate(ActiveData^.UndoList);
   RefreshAll;
end;

// 3.35: Imported from 3.4:: Convert Shadows (TS -> RA2)
procedure TSHPBuilderFrmMain.ConvertShadowsTSRA21Click(Sender: TObject);
var
   Frame,Shadow : word;
   x,y: longword;
begin
   // Basic Check Up
   if not isEditable then exit;
   if not ActiveForm^.ShadowMode then
   begin
      MessageBox(0,'Error! Shadows are OFF','Convert Shadow Error',0);
      exit;
   end;

   // Start New Undo
   GenerateNewUndoItem(ActiveData^.UndoList);
   // For cache purposes:
   Shadow := (ActiveData^.SHP.Header.NumImages div 2);
   // scan all non-shadow frames
   For Frame := 1 to (ActiveData^.SHP.Header.NumImages div 2) do
   begin
      // Scan each pixel
      for x := 0 to (ActiveData^.SHP.Header.Width-1) do
      for y := 0 to (ActiveData^.SHP.Header.Height-1) do
      begin
         // Search for colour #1
         if ActiveData^.SHP.Data[Frame + Shadow].FrameImage[x,y] = 1 then
         begin
            // Delete TS Shadow and Make RA2 shadow
            AddToUndoMultiFramesB(ActiveData^.UndoList,Frame + Shadow,x,y,ActiveData^.SHP.Data[Frame + Shadow].FrameImage[x,y]);
            ActiveData^.SHP.Data[Frame + Shadow].FrameImage[x,y] := 0;
            // Only add a shadow in a non-painted pixel
            if ActiveData^.SHP.Data[Frame].FrameImage[x,y] = 0 then
            begin
               AddToUndoMultiFramesB(ActiveData^.UndoList,Frame,x,y,ActiveData^.SHP.Data[Frame].FrameImage[x,y]);
               ActiveData^.SHP.Data[Frame].FrameImage[x,y] := 12;
            end;
         end;
      end;
   end;
   NewUndoItemValidation(ActiveData^.UndoList);
   UndoUpdate(ActiveData^.UndoList);
   RefreshAll;
end;



// **************************************************
// ******* ShortCuts Procedures On Tools Menu *******
// **************************************************

procedure TSHPBuilderFrmMain.Draw1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbDrawClick(sender);
   SpbDraw.Down := true;
end;

procedure TSHPBuilderFrmMain.Line1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbLineClick(sender);
   SpbLine.Down := true;
end;

procedure TSHPBuilderFrmMain.Erase1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbEraseClick(sender);
   SpbErase.Down := true;
end;

procedure TSHPBuilderFrmMain.Rectangle1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbFramedRectangleClick(sender);
   ToolAdvOption1.Down := true;
   SpbFramedRectangle.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.FilledRectangle1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbFramedRectangleClick(sender);
   SpbFramedRectangle.Down := true;
   ToolAdvOption2.Down := true;
   ToolAdvOption2_Click(sender);
end;

procedure TSHPBuilderFrmMain.Elipse1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbElipseClick(sender);
   SpbElipse.Down := true;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.FilledElipse1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbElipseClick(sender);
   SpbElipse.Down := true;
   ToolAdvOption2.Down := true;
   ToolAdvOption2_Click(sender);
end;

procedure TSHPBuilderFrmMain.Select1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbSelectClick(sender);
   SpbSelect.Down := true;
end;

procedure TSHPBuilderFrmMain.Dropper1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbColorSelectorClick(sender);
   SpbColorSelector.Down := true;
end;

procedure TSHPBuilderFrmMain.Fill1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbFloodFillClick(sender);
   SpbFloodFill.Down := true;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.FillwithGradient1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbFloodFillClick(sender);
   SpbFloodFill.Down := true;
   ToolAdvOption2.Down := true;
   ToolAdvOption2_Click(sender);
end;

procedure TSHPBuilderFrmMain.ColourReplace1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbReplaceColorClick(sender);
end;

procedure TSHPBuilderFrmMain.Crash1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.CrashLight1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption2.Down := true;
   ToolAdvOption2_Click(sender);
end;

procedure TSHPBuilderFrmMain.BigCrash1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption3.Down := true;
   ToolAdvOption3_Click(sender);
end;

procedure TSHPBuilderFrmMain.BigLightCrash1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption4.Down := true;
   ToolAdvOption4_Click(sender);
end;

procedure TSHPBuilderFrmMain.Dirty1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption5.Down := true;
   ToolAdvOption5_Click(sender);
end;

procedure TSHPBuilderFrmMain.Snowy1Click(Sender: TObject);
begin
   if not isEditable then exit;
   SpbBuildingToolsClick(sender);
   SpbBuildingTools.Down := true;
   ToolAdvOption6.Down := true;
   ToolAdvOption6_Click(sender);
end;

// ************************************************************
// * Tools that are linked by the ShortCuts and Their Options *
// ************************************************************


procedure TSHPBuilderFrmMain.SpbDrawClick(Sender: TObject);
begin
   ShowBrushOptions;
   lblBrush.Caption := ' Brush';
   DrawMode := dmdraw;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbColorSelectorClick(Sender: TObject);
begin
   lblBrush.Caption := ' Dropper';
   ShowDropperOptions;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbFloodFillClick(Sender: TObject);
begin
   lblBrush.Caption := ' Flood';
   ShowFloodOptions;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbLineClick(Sender: TObject);
begin
   lblBrush.Caption := ' Line';
   ShowLineOptions;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbEraseClick(Sender: TObject);
begin
   lblBrush.Caption := ' Erase';
   DrawMode := dmErase;
   ShowBrushOptions;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbReplaceColorClick(Sender: TObject);
var
   frmReplaceColour: TfrmReplaceColour;
begin
   if not isEditable then exit;

   frmReplaceColour:=TfrmReplaceColour.Create(Self);
   frmReplaceColour.Data := ActiveData;
   with frmReplaceColour do begin
      ShowModal;
      Release;
   end;

   ActiveForm^.RefreshImage;
end;

procedure TSHPBuilderFrmMain.SpbDarkenLightenClick(Sender: TObject);
begin
   ShowBrushOptions;
   lblBrush.Caption := ' Darken Lighten Brush';
   pnlbump.visible := true;
   DrawMode := dmdarkenlighten;
   DarkenLighten_B := false;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbLightenClick(Sender: TObject);
begin
   DrawMode := dmdarkenlighten;
   DarkenLighten_B := false;
   hidepanels;
end;

procedure TSHPBuilderFrmMain.SpbDarkenClick(Sender: TObject);
begin
   DrawMode := dmdarkenlighten;
   DarkenLighten_B := true;
   hidepanels;
end;

procedure TSHPBuilderFrmMain.hidepanels;
begin
   pnlbump.visible := false;
end;

procedure TSHPBuilderFrmMain.SpbDarkenLightenSettingsClick(Sender: TObject);
var
   frmdarkenlightentool: Tfrmdarkenlightentool;
begin
   hidepanels;
   frmdarkenlightentool := Tfrmdarkenlightentool.Create(self);
   frmdarkenlightentool.showmodal;
   frmdarkenlightentool.Release;
end;

procedure TSHPBuilderFrmMain.SpbSelectClick(Sender: TObject);
begin
   lblBrush.Caption := ' Selection';
   ShowSelectionOptions;
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbFramedRectangleClick(Sender: TObject);
begin
   ShowSquareOptions;
   lblBrush.Caption := ' Square';
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbElipseClick(Sender: TObject);
begin
   ShowEllipseOptions;
   lblBrush.Caption := ' Elipse';
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;

procedure TSHPBuilderFrmMain.SpbBuildingToolsClick(Sender: TObject);
begin
   ShowDamagerOptions;
   lblBrush.Caption := ' Building Tools';
   HidePanels;
   ToolAdvOption1.Down := true;
   ToolAdvOption1_Click(sender);
end;


//---------------------------------------------
// Show Selection Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowSelectionOptions;
var 
   iconFilename : string;
   hintToolName : string;
begin
   hintToolName := 'Selection';

   if ToolAdvOption1.Hint <> hintToolName then
   begin
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := hintToolName;
      iconFilename := AppConstants.ImageDir + 'Selection_1.bmp';

      if  fileexists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      
      ToolAdvOption2.Visible := false;
      ToolAdvOption3.Visible := false;
      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Line Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowLineOptions;
var 
   iconFilename : string;
   hintToolName : string;
begin
   hintToolName := 'Straight Line';

   if ToolAdvOption1.Hint <> hintToolName then
   begin
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := hintToolName;
      iconFilename := AppConstants.ImageDir + 'Line_1.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption2.Visible := false;
      ToolAdvOption3.Visible := false;
      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Dropper Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowDropperOptions;
var 
   iconFilename : string;
   hintToolName : string;
begin
   hintToolName := 'Dropper';

   if ToolAdvOption1.Hint <> hintToolName then
   begin
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := hintToolName;
      iconFilename := AppConstants.ImageDir + 'Dropper_1.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption2.Visible := false;
      ToolAdvOption3.Visible := false;
      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Flood Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowFloodOptions;
var 
   toolHint : string;
   iconFilename : string;
begin
   toolHint := 'Flood Fill';

   if ToolAdvOption1.Hint <> toolHint then
   begin
      iconFilename := AppConstants.ImageDir + 'Flood_1.bmp';
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := toolHint;
      if  FileExists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Flood_2.bmp';
      ToolAdvOption2.Visible := true;
      ToolAdvOption2.Hint := 'Flood Fill With Gradient Effects';
      if  fileexists( iconFilename ) then
         ToolAdvOption2.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Flood_3.bmp';
      ToolAdvOption3.Visible := true;
      ToolAdvOption3.Hint := 'Flood Fill With Blur';
      if  fileexists( iconFilename ) then
         ToolAdvOption3.Glyph.LoadFromFile(iconFilename );

      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Brush Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowBrushOptions;
var
   toolHint, iconFilename : string;
begin
   toolHint := 'Dot';
   if ToolAdvOption1.Hint <> toolHint then
   begin
      iconFilename := AppConstants.ImageDir + 'Brush_1.bmp';
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := toolHint;
      if  FileExists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption2.Visible := true;
      ToolAdvOption2.Hint := 'Cross';
      iconFilename := AppConstants.ImageDir + 'Brush_2.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption2.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption3.Visible := true;
      ToolAdvOption3.Hint := 'Mini-Square';
      iconFilename := AppConstants.ImageDir + 'Brush_3.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption3.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption4.Visible := true;
      ToolAdvOption4.Hint := 'Big Dot';
      iconFilename := AppConstants.ImageDir + 'Brush_4.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption4.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption5.Visible := true;
      ToolAdvOption5.Hint := 'Spray';
      iconFilename := AppConstants.ImageDir + 'Brush_5.bmp';
      if  fileexists( iconFilename ) then
         ToolAdvOption5.Glyph.LoadFromFile( iconFilename );

      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Rectangle Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowSquareOptions;
var
   toolHint, iconFilename : string;
begin
   toolHint := 'Framed Rectangle';
   if ToolAdvOption1.Hint <> toolHint then
   begin
      iconFilename := AppConstants.ImageDir + 'Rect_1.bmp';
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := toolHint;
      if  FileExists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Rect_2.bmp';
      ToolAdvOption2.Visible := true;
      ToolAdvOption2.Hint := 'Filled Rectangle';
      if  FileExists( iconFilename ) then
         ToolAdvOption2.Glyph.LoadFromFile( iconFilename );


      ToolAdvOption3.Visible := false;
      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Ellipse Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowEllipseOptions;
var
   toolHint, iconFilename : string;
begin
   toolHint := 'Frame Ellipse';
   if ToolAdvOption1.Hint <> toolHint then
   begin
      iconFilename := AppConstants.ImageDir + 'Elipse_1.bmp';
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := toolHint;
      if  FileExists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Elipse_2.bmp';
      ToolAdvOption2.Visible := true;
      ToolAdvOption2.Hint := 'Filled Ellipse';
      if  FileExists( iconFilename ) then
         ToolAdvOption2.Glyph.LoadFromFile( iconFilename );


      ToolAdvOption3.Visible := false;
      ToolAdvOption4.Visible := false;
      ToolAdvOption5.Visible := false;
      ToolAdvOption6.Visible := false;
   end;
end;


//---------------------------------------------
// Show Damager Options
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowDamagerOptions;
var
   toolHint, iconFilename : string;
begin
   toolHint := 'Small Crash';
   if ToolAdvOption1.Hint <> toolHint then
   begin
      iconFilename := AppConstants.ImageDir + 'Crash_1.bmp';
      ToolAdvOption1.Visible := true;
      ToolAdvOption1.Hint := toolHint;
      if  FileExists( iconFilename ) then
         ToolAdvOption1.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Crash_L1.bmp';
      ToolAdvOption2.Visible := true;
      ToolAdvOption2.Hint := 'Small Light Crash';
      if  FileExists( iconFilename ) then
         ToolAdvOption2.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Crash_B1.bmp';
      ToolAdvOption3.Visible := true;
      ToolAdvOption3.Hint := 'Big Crash';
      if  FileExists( iconFilename ) then
         ToolAdvOption3.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Crash_BL1.bmp';
      ToolAdvOption4.Visible := true;
      ToolAdvOption4.Hint := 'Big Light Crash';
      if  FileExists( iconFilename ) then
         ToolAdvOption4.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Crash_D1.bmp';
      ToolAdvOption5.Visible := true;
      ToolAdvOption5.Hint := 'Dirty';
      if  FileExists( iconFilename ) then
         ToolAdvOption5.Glyph.LoadFromFile( iconFilename );

      iconFilename := AppConstants.ImageDir + 'Snow_1.bmp';
      ToolAdvOption6.Visible := true;
      ToolAdvOption6.Hint := 'Snow';
      if  FileExists( iconFilename ) then
         ToolAdvOption6.Glyph.LoadFromFile( iconFilename );
   end;
end;


//---------------------------------------------
// Tool Advanced Option 1 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption1_Click(Sender: TObject);
begin

   // PEN, ERASER,  Darken/Lighten.
   if (SpbDraw.Down or SpbErase.Down) or SpbDarkenLighten.Down then
   begin 
      Brush_Type := 0;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Selection.Visible := false;
      ActiveForm^.Image1.Cursor := MouseDraw;
   end
   // LINE
   else if SpbLine.Down then
   begin 
      DrawMode := dmLine;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Selection.Visible := false;
      ActiveForm^.Image1.Cursor := MouseLine;
   end
   // FLOOD FILL
   else if SpbFloodFill.Down then
   begin  
      DrawMode := dmflood;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Selection.Visible := false;
      ActiveForm^.Image1.Cursor := MouseFill;
   end
   // DROPPER
   else if SpbColorSelector.Down then
   begin
      DrawMode := dmdropper;
      ActiveForm^.Selection.Visible := false;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseDropper;
   end
   // SELECTION
   else if SpbSelect.Down then
   begin
      DrawMode := dmselect;
      TempViewLength := 0;
      ActiveForm^.Selection.Visible := true;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := CrArrow;
   end
   // RECTANGLE
   else if SpbFramedRectangle.Down then
   begin
      Drawmode := dmRectangle;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;

      ActiveForm^.Selection.Visible := false;
   end
   // ELLIPSE
   else if SpbElipse.Down then
   begin
      Drawmode := dmElipse;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;

      ActiveForm^.Selection.Visible := false;
   end
   // DAMAGER
   else if SpbBuildingTools.Down then
   begin
      Drawmode := dmCrash;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;

      ActiveForm^.Selection.Visible := false;
   end;
end;


//---------------------------------------------
// Tool Advanced Option 2 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption2_Click(Sender: TObject);
begin
   if (SpbDraw.Down or SpbErase.Down) or SpbDarkenLighten.Down then
   begin
      Brush_Type := 1;
      ActiveForm^.Selection.Visible := false;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseBrush;
   end
   else if SpbFloodFill.Down then
   begin  
      DrawMode := dmFloodGradient;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Selection.Visible := false;
      ActiveForm^.Image1.Cursor := MouseFill;
   end
   else if SpbFramedRectangle.Down then
   begin 
      ActiveForm^.Selection.Visible := false;
      Drawmode := dmRectangle_Fill;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
   end
   else if SpbElipse.Down then
   begin 
      ActiveForm^.Selection.Visible := false;
      Drawmode := dmElipse_Fill;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
   end
   else if SpbBuildingTools.Down then
   begin 
      Drawmode := dmLightCrash;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
      ActiveForm^.Selection.Visible := false;
   end;
end;


//---------------------------------------------
// Tool Advanced Option 3 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption3_Click(Sender: TObject);
begin
   if (SpbDraw.Down or SpbErase.Down) or SpbDarkenLighten.Down then
   begin
      Brush_Type := 2;
      ActiveForm^.Selection.Visible := false;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseBrush;
   end
   else if SpbBuildingTools.Down then
   begin 
      Drawmode := dmBigCrash;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
      ActiveForm^.Selection.Visible := false;
   end
   else if SpbFloodFill.Down then
   begin  
      DrawMode := dmFloodBlur;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Selection.Visible := false;
      ActiveForm^.Image1.Cursor := MouseFill;
   end
end;


//---------------------------------------------
// Tool Advanced Option 4 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption4_Click(Sender: TObject);
begin
   if (SpbDraw.Down or SpbErase.Down) or SpbDarkenLighten.Down then
   begin
      Brush_Type := 3;
      ActiveForm^.Image1.Cursor := MouseBrush;
   end
   else if SpbBuildingTools.Down then
   begin 
      Drawmode := dmBigLightCrash;
      TempViewLength := 0; 
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
      ActiveForm^.Selection.Visible := false;
   end;
end;


//---------------------------------------------
// Tool Advanced Option 5 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption5_Click(Sender: TObject);
begin
   if (SpbDraw.Down or SpbErase.Down) or SpbDarkenLighten.Down then
   begin
      Brush_Type := 4;
      ActiveForm^.Selection.Visible := false;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseSpray;
   end
   else if SpbBuildingTools.Down then
   begin
      Drawmode := dmDirty;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
      ActiveForm^.Selection.Visible := false;
   end;
end;


//---------------------------------------------
// Tool Advanced Option 6 Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ToolAdvOption6_Click(Sender: TObject);
begin
   if SpbBuildingTools.Down then
   begin
      Drawmode := dmSnow;
      TempViewLength := 0;
      ActiveForm^.RefreshImage;
      ActiveForm^.Image1.Cursor := MouseLine;
      ActiveForm^.Selection.Visible := false;
   end;
end;


// ******************************************************
// ************** Colour Scheme Procedures **************
// ******************************************************

procedure firstlastword(const words : string; var first,rest : string);
var
   x,w : integer;
   seps : array[0..50] of string;
   endofword : boolean;
   text : string;
begin
   text := words;
   seps[0] := ' ';
   seps[1] := '(';
   seps[2] := ')';
   seps[3] := '[';
   seps[4] := #09;
   seps[5] := ']';
   seps[6] := ':';
   seps[7] := '''';
   seps[8] := '"';
   seps[9] := '=';
   seps[10] := ',';
   seps[11] := ';';
   repeat
      w := 0;
      endofword:=false;
      for x := 1 to length(text) do
         if endofword=false then
            if (copy(text,x,1) <> seps[0]) and (copy(text,x,1) <> seps[1])and (copy(text,x,1) <> seps[2]) and (copy(text,x,1) <> seps[3]) and (copy(text,x,1) <> seps[4]) and (copy(text,x,1) <> seps[5]) and (copy(text,x,1) <> seps[6]) and (copy(text,x,1) <> seps[7]) and (copy(text,x,1) <> seps[8]) and (copy(text,x,1) <> seps[9]) and (copy(text,x,1) <> seps[10]) and (copy(text,x,1) <> seps[11]) then
               w := w + 1
            else
               endofword := true;

      if w = 0 then
         text := copy(text,2,length(text));
   until (w > 0) or (length(text) = 0);
   first := copy(text,1,w);
   rest := copy(text,w+1,length(text));
end;

procedure firstlastword2(const words : string; var first,rest : string);
var
   x,w : integer;
   seps : array[0..50] of string;
   endofword : boolean;
   text : string;
begin
   text := words;
   seps[0] := #09;
   seps[1] := ';';
   seps[2] := '=';
   repeat
      w := 0;
      endofword:=false;
      for x := 1 to length(text) do
         if endofword=false then
            if (copy(text,x,1) <> seps[0]) and (copy(text,x,1) <> seps[1]) and (copy(text,x,1) <> seps[2]) then
               w := w + 1
            else
               endofword := true;

      if w = 0 then
         text := copy(text,2,length(text));
   until (w > 0) or (length(text) = 0);
   first := copy(text,1,w);
   rest := copy(text,w+1,length(text));
end;

function searchcscheme(s : tstringlist; f : string) : string;
var
   x : integer;
   first,rest : string;
begin
   result := '!ERROR!';

   for x := 0 to s.Count-1 do
      if ansilowercase(copy(s.Strings[x],1,length(f))) = ansilowercase(f) then
      begin
         firstlastword(s.Strings[x],first,rest);
         if f = 'name=' then
            firstlastword2(rest,first,rest)
         else
            firstlastword(rest,first,rest);
         result := first;
      end;
end;

function TSHPBuilderFrmMain.AddSchemeToMenu(const DirName : string; var Counter : Integer; var RelatedMenuItem : TMenuItem): Integer;
var
   f: TSearchRec;
   path: String;
   Filename : string;
   item, item2: TMenuItem;
   x : integer;
   s : TStringList;
   gametype : string;
   Split : string;
begin
   path := Concat(ExtractFilePath(ParamStr(0))+'\cscheme\' + DirName + '\','*.cscheme');

   // Declaring item2
   item2 := TMenuItem.Create(Owner);
   item2.Caption := '-';

   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := Concat(ExtractFilePath(ParamStr(0))+'\cscheme\' + DirName + '\',f.Name);
      inc(Counter);
      inc(result);
      SetLength(ColourSchemes,Counter+1);
      // Setting StringList (s):
      ColourSchemes[Counter].FileName := Filename;
      s := TStringList.Create;
      s.LoadFromFile(Filename);
      // Unknown code... Stu added this one here.
      Split := searchcscheme(s,'split=');
      // Setup the menu:
      item := TMenuItem.Create(Owner);
      item.Caption := searchcscheme(s,'name=');
      item.Tag := Counter; // so we know which it is
      item.OnClick := Blank3Click;
      item.ImageIndex := strtoint(searchcscheme(s,'imageindex='));
      // Now, we check for each gametype.
      gametype := searchcscheme(s,'gametype=');
      if gametype = '1' then
      begin
         if split = 'true' then
            CustomTS1.Insert(CustomTS1.Count-1,item2);
         CustomTS1.Insert(CustomTS1.Count-1,item);
         CustomTS1.visible := true;
      end
      else if gametype = '2' then
      begin
         if split = 'true' then
            CustomRA21.Insert(CustomRA21.Count-1,item2);
         CustomRA21.Insert(CustomRA21.Count-1,item);
         CustomRA21.visible := true;
      end
      else if gametype = '3' then
      begin
         if split = 'true' then
            CustomYR1.Insert(CustomYR1.Count-1,item2);
         CustomYR1.Insert(CustomYR1.Count-1,item);
         CustomYR1.visible := true;
      end
      else if gametype = '4' then
      begin
         if split = 'true' then
            Allied1.Insert(Allied1.Count-1,item2);
         Allied1.Insert(Allied1.Count-1,item);
         Allied1.visible := true;
      end
      else if gametype = '5' then
      begin
         if split = 'true' then
            Soviet1.Insert(Soviet1.Count-1,item2);
         Soviet1.Insert(Soviet1.Count-1,item);
         Soviet1.visible := true;
      end
      else if gametype = '6' then
      begin
         if split = 'true' then
            Yuri1.Insert(Yuri1.Count-1,item2);
         Yuri1.Insert(Yuri1.Count-1,item);
         Yuri1.visible := true;
      end
      else if gametype = '7' then
      begin
         if split = 'true' then
            Brick1.Insert(Brick1.Count-1,item2);
         Brick1.Insert(Brick1.Count-1,item);
         Brick1.visible := true;
      end
      else if gametype = '8' then
      begin
         if split = 'true' then
            Grayscale1.Insert(Grayscale1.Count-1,item2);
         Grayscale1.Insert(Grayscale1.Count-1,item);
         Grayscale1.visible := true;
      end
      else if gametype = '9' then
      begin
         if split = 'true' then
            Remap1.Insert(Remap1.Count-1,item2);
         Remap1.Insert(Remap1.Count-1,item);
         Remap1.visible := true;
      end
      else if gametype = '10' then
      begin
         if split = 'true' then
            Brown11.Insert(Brown11.Count-1,item2);
         Brown11.Insert(Brown11.Count-1,item);
         Brown11.visible := true;
      end
      else if gametype = '11' then
      begin
         if split = 'true' then
            Brown21.Insert(Brown21.Count-1,item2);
         Brown21.Insert(Brown21.Count-1,item);
         Brown21.visible := true;
      end
      else if gametype = '12' then
      begin
         if split = 'true' then
            Blue1.Insert(Blue1.Count-1,item2);
         Blue1.Insert(Blue1.Count-1,item);
         Blue1.visible := true;
      end
      else if gametype = '13' then
      begin
         if split = 'true' then
            Green1.Insert(Green1.Count-1,item2);
         Green1.Insert(Green1.Count-1,item);
         Green1.visible := true;
      end
      else if gametype = '14' then
      begin
         if split = 'true' then
            nounlight1.Insert(nounlight1.Count-1,item2);
         nounlight1.Insert(nounlight1.Count-1,item);
         nounlight1.visible := true;
      end
      else if gametype = '15' then
      begin
         if split = 'true' then
            Red1.Insert(Red1.Count-1,item2);
         Red1.Insert(Red1.Count-1,item);
         Red1.visible := true;
      end
      else if gametype = '16' then
      begin
         if split = 'true' then
            Yellow1.Insert(Yellow1.Count-1,item2);
         Yellow1.Insert(Yellow1.Count-1,item);
         Yellow1.visible := true;
      end
      else if (gametype = '17') or (gametype = '0') then
      begin
         if split = 'true' then
            Custom11.Insert(Custom11.Count-1,item2);
         Custom11.Insert(Custom11.Count-1,item);
         Custom11.visible := true;
      end
      else if gametype = '18' then
      begin
         if split = 'true' then
            iberianDawn2.Insert(iberianDawn2.Count-1,item2);
         iberianDawn2.Insert(iberianDawn2.Count-1,item);
         iberianDawn2.visible := true;
      end
      else if gametype = '19' then
      begin
         if split = 'true' then
            RedAlert12.Insert(RedAlert12.Count-1,item2);
         RedAlert12.Insert(RedAlert12.Count-1,item);
         RedAlert12.visible := true;
      end;

      RelatedMenuItem.Visible := true;
   until FindNext(f) <> 0;
   FindClose(f);
end;

function TSHPBuilderFrmMain.LoadCScheme : integer;
var
   c : integer;
begin
   // prepare
   c := 0;
   SetLength(ColourSchemes,0);

   ///////////////////////////////////////////////////////
   // Let's Start With:
   // :: Pal Pack 1 ::
   ///////////////////////////////////////////////////////
   PalPack11.Visible := false;
   CustomSchemes1.Visible := false;
   Result := Result + AddSchemeToMenu('PalPack1',c,PalPack11);

   ///////////////////////////////////////////////////////
   // Incomming With:
   // :: Pal Pack 2 ::
   ///////////////////////////////////////////////////////
   Result := Result + AddSchemeToMenu('PalPack2',c,PalPack11);

   // Custom
   Result := Result + AddSchemeToMenu('Custom',c,CustomSchemes1);
   Result := c;
end;

procedure TSHPBuilderFrmMain.Blank3Click(Sender: TObject);
var
   x,y,z,temp : integer;
   s : tstringlist;
   minx,maxx,miny,maxy,minz,maxz : smallint;
   Data : TSHPImageData;
   FrmRange : TFrmRange;
begin
   if ActiveData = nil then exit;
   Data := ActiveData;

   if AllFrames1.Checked then
   begin
      minz := 1;
      maxz := Data^.SHP.Header.NumImages;
   end
   else if CurrentOnly1.Checked then
   begin
      minz := ActiveForm^.FrameIndex;
      maxz := ActiveForm^.FrameIndex;
   end
   else
   begin
      FrmRange := TFrmRange.Create(Application);
      FrmRange.Current := Current_Frame.Value;
      FrmRange.Final := ActiveData^.SHP.Header.NumImages;
      FrmRange.ShowModal;
      minz := StrToIntDef(FrmRange.SpBegin.Text,1);
      maxz := StrToIntDef(FrmRange.SpEnd.Text,FrmRange.Final);
      FrmRange.Release;
   end;

   if WholeFrame1.Checked or (ActiveForm^.Selection.Width < 1) then
   begin
      minx := 0;
      miny := 0;
      maxx := Data^.SHP.Header.Width - 1;
      maxy := Data^.SHP.Header.Height - 1;
   end
   else
   begin
      minx := ActiveForm^.Selection.X;
      maxx := ActiveForm^.Selection.X + ActiveForm^.Selection.Width;
      miny := ActiveForm^.Selection.Y;
      maxy := ActiveForm^.Selection.Y + ActiveForm^.Selection.Height;
   end;

   s := TStringList.Create;
   s.LoadFromFile(ColourSchemes[Tmenuitem(Sender).Tag].Filename);

   for x := 0 to 255 do
   begin
      temp := StrToIntDef(searchcscheme(s,inttostr(x)+'='),-1);
      if temp <> -1 then
      begin
         ColourSchemes[Tmenuitem(Sender).Tag].Data[x] := temp;
      end
      else
      begin
         ColourSchemes[Tmenuitem(Sender).Tag].Data[x] := x;
      end;
   end;
   GenerateNewUndoItem(Data^.UndoList);

   for z := minz to maxz do
      for x := minx to maxx do
         for y := miny to maxy do
            if (Data^.SHP.Data[z].FrameImage[x,y] <> ColourSchemes[Tmenuitem(Sender).Tag].Data[Data^.SHP.Data[z].FrameImage[x,y]]) then
            begin
               AddToUndoMultiFrames(Data^.UndoList,z,x,y,Data^.SHP.Data[z].FrameImage[x,y]);
               Data^.SHP.Data[z].FrameImage[x,y] := ColourSchemes[Tmenuitem(Sender).Tag].Data[Data^.SHP.Data[z].FrameImage[x,y]];
            end;

   NewUndoItemValidation(Data^.UndoList);
   UndoUpdate(Data^.UndoList);
   RefreshAll;
end;

procedure TSHPBuilderFrmMain.About2Click(Sender: TObject);
var
   FrmPalettePackAbout: TFrmPalettePackAbout;
begin
   FrmPalettePackAbout := TFrmPalettePackAbout.Create(Application);
   FrmPalettePackAbout.showmodal;
   FrmPalettePackAbout.Release;
end;

procedure TSHPBuilderFrmMain.AllFrames1Click(Sender: TObject);
begin
   CurrentOnly1.Checked := false;
   AllFrames1.Checked := true;
   FromTo2.Checked := false;
end;

procedure TSHPBuilderFrmMain.WholeFrame1Click(Sender: TObject);
begin
   SAOnly1.Checked := false;
   WholeFrame1.Checked := true;
end;

procedure TSHPBuilderFrmMain.SAOnly1Click(Sender: TObject);
begin
   SAOnly1.Checked := true;
   WholeFrame1.Checked := false;
end;

procedure TSHPBuilderFrmMain.CurrentOnly1Click(Sender: TObject);
begin
   CurrentOnly1.Checked := true;
   AllFrames1.Checked := false;
   FromTo2.Checked := false;
end;

procedure TSHPBuilderFrmMain.FromTo2Click(Sender: TObject);
begin
   SAOnly1.Checked := false;
   WholeFrame1.Checked := false;
   FromTo2.Checked := true;
end;

// *****************************************************
// ************** Options Menu Procedures **************
// *****************************************************

procedure TSHPBuilderFrmMain.Preferences1Click(Sender: TObject);
var
   FrmPreferences: TFrmPreferences;
begin
   FrmPreferences := TFrmPreferences.Create(Application);
   FrmPreferences.showmodal;
   FrmPreferences.Release;
end;

procedure TSHPBuilderFrmMain.urnToCameoMode1Click(Sender: TObject);
var
   Data : TSHPImageData;
begin
   if not isEditable then exit;

   Data := ActiveData;

   if Data^.SHP.Header.NumImages < 2 then
      ActiveForm^.SetShadowMode(false)
   else
      ActiveForm^.SetShadowMode(not urnToCameoMode1.Checked);
end;

// ****************************************************
// *************** Help Menu Procedures ***************
// ****************************************************


procedure TSHPBuilderFrmMain.ProjectPerfectMod1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/'));
end;

procedure TSHPBuilderFrmMain.CnCSourceForUpdates1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.cnc-source.com/'));
end;

procedure TSHPBuilderFrmMain.Help2Click(Sender: TObject);
begin
   if not fileexists(extractfiledir(paramstr(0))+'/os_shp_builder_help.chm') then
   begin
      showmessage('Help File os_shp_builder_help.chm has not been found.');
      exit;
   end;
   RunAProgram('os_shp_builder_help.chm','',extractfiledir(paramstr(0)));
end;

procedure TSHPBuilderFrmMain.GetSupport1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/forum/viewforum.php?f=122'));
end;

procedure TSHPBuilderFrmMain.ReportBugs1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/forum/viewforum.php?f=125'));
end;

procedure TSHPBuilderFrmMain.utorials1Click(Sender: TObject);
begin
   OpenHyperlink(PChar('http://www.ppmsite.com/forum/viewforum.php?f=124'));
end;

procedure TSHPBuilderFrmMain.About1Click(Sender: TObject);
var
   FrmAbout: TFrmAbout;
begin
   FrmAbout := TFrmAbout.Create(Application);
   FrmAbout.showmodal;
   FrmAbout.Release;
end;

procedure TSHPBuilderFrmMain.UpdateOSSHPBuilder1Click(Sender: TObject);
var
   Form: TFrmRepairAssistant;
begin
   Form := TFrmRepairAssistant.Create(self);
   Form.SetAutoUpdateMode;
   Form.ShowModal;
   Form.Release;
end;

// *******************************************************
// ********************** Zoom Part **********************
// *******************************************************


procedure TSHPBuilderFrmMain.Zoom_FactorChange(Sender: TObject);
begin
   if not FrmMain.isEditable then exit;

   if (Zoom_Factor.Value <= Zoom_Factor.MaxValue) and (Zoom_Factor.Value >= Zoom_Factor.MinValue) then
   begin
      ActiveForm^.Zoom := Zoom_Factor.Value;
      if (ActiveData^.Filename = '') then
         ActiveForm^.Caption := '[ ' + IntToStr(ActiveForm^.Zoom) + ' : 1 ] ' + 'Untitled ' + IntToStr(ActiveData^.ID) + ' (' + IntToStr(ActiveForm^.FrameIndex) + '/' + IntToStr(ActiveData^.SHP.Header.NumImages) + ')'
      else
         ActiveForm^.Caption := '[ ' + IntToStr(ActiveForm^.Zoom) + ' : 1 ] ' + extractfilename(ActiveData^.Filename) + ' (' + IntToStr(ActiveForm^.FrameIndex) + '/' + IntToStr(ActiveData^.SHP.Header.NumImages) + ')';

      ActiveForm^.ResizePaintArea(ActiveForm^.Image1,ActiveForm^.PaintAreaPanel);

      ActiveForm^.RefreshImage;
   end;
end;


//---------------------------------------------
// UpDownFrameIndex Value Changed
//---------------------------------------------
procedure TSHPBuilderFrmMain.Current_FrameChange(Sender: TObject);
var
   isShadowFrame : boolean;
   v : integer;
begin
   if (((not FrmMain.isEditable) or (Current_Frame.Text = '')) or (Current_Frame.Text = '-')) then exit;
   if ( Current_Frame.value = ActiveForm^.FrameIndex) then exit;
   v := Current_Frame.value;

   if v > ActiveData^.SHP.Header.NumImages then
      v := 1;

   if v < 1 then
      v := ActiveData^.SHP.Header.NumImages;

   ActiveForm^.SetFrameIndex(v);
end;


//---------------------------------------------
// Update Frame UI Components
//---------------------------------------------
procedure TSHPBuilderFrmMain.UpdateFrameUIComponents;
var
   isShadowFrame : boolean;
begin
   FrmMain.Current_Frame.Value := ActiveForm^.FrameIndex;
   isShadowFrame := IsShadow(ActiveData^.SHP, ActiveForm^.FrameIndex);
   if (isShadowFrame) and (ActiveData^.PaletteMax <> 2) and (ActiveForm^.ShadowMode) then
   begin
      StatusBar1.Panels[0].Text := 'Shadow Frame';
      ActiveForm^.SetShadowColour(ActiveForm^.ShadowColour);
   end
   else if (Not(isShadowFrame) or not ActiveForm^.ShadowMode) and (ActiveData^.PaletteMax <> 256) then
   begin
      StatusBar1.Panels[0].Text := 'Owner Frame';
      ActiveForm^.SetActiveColour(ActiveForm^.ActiveColour);
   end;

   // Clear Canvas Palette
   with cnvPalette.Canvas do
   begin
      Brush.Color := FrmMain.Color;
      FillRect(ClientRect);
   end;
   // Invalidate
   cnvPalette.Invalidate;

end;


procedure TSHPBuilderFrmMain.SetFrameNumber;
begin
   lbl_total_frames.Caption := inttostr(ActiveData^.SHP.Header.NumImages);
   if ActiveData^.SHP.Header.NumImages = 1 then
   begin
      MoveFrames1.Enabled := false;
      ReverseFrames1.Enabled := false;
      DeleteFrames1.Enabled := false;
   end
   else
   begin
      MoveFrames1.Enabled := true;
      ReverseFrames1.Enabled := true;
      DeleteFrames1.Enabled := true;
   end;
end;


procedure TSHPBuilderFrmMain.Zoom_FactorDblClick(Sender: TObject);
begin
   // Do nothing...
end;

// ******************************************* //
// ******** Procedures to the Re-open ******** //
// ******************************************* //

procedure TSHPBuilderFrmMain.MakeTheRecentFiles;
var
   Item:TMenuItem;
   count: word;
begin
   // Does it really has to be done?
   if MaxOpenFiles > 0 then
   begin
      // Should Open Recent be visible? Does it has an item?
      if (OpenFilesList[0] <> '') then
      begin
         OpenRecent1.Visible := true;
         // Now we start making the list
         count := 0;
         while (count < MaxOpenFiles) do
         begin
            // We verify if we have to add the item

            // Note: done after the while, so it doesnt check
            // OpenFilesList[MaxOpenFiles] which is Access Violation
            if (OpenFilesList[count] <> '') then
            begin
               Item := TMenuItem.Create(Owner);
               Item.Caption := OpenFilesList[count];
               // The line below give us the location of the
               // filename in the OpenFilesList.
               Item.Tag := count;
               Item.OnClick := OpenRecentClicked;
               Item.Visible := true;

               OpenRecent1.Insert(OpenRecent1.Count,Item);
               inc(count);
            end
            else // don't add anything anymore
               count := MaxOpenFiles;
         end;
      end;
   end;
end;

procedure TSHPBuilderFrmMain.OpenRecentClicked(Sender : TObject);
begin
   if fileexists(OpenFilesList[TMenuItem(Sender).Tag]) then
      LoadASHP(OpenFilesList[TMenuItem(Sender).Tag])
   else
      ShowMessage('The file ' + OpenFilesList[TMenuItem(Sender).Tag] + ' does not exists anymore');
end;

procedure TSHPBuilderFrmMain.UpdateOpenRecentLinks(const Filename : string);
var
   count : word;
begin
   // Check if the filename exists:
   count := 0;
   while count < MaxOpenFiles do
   begin
      // if Filename exists, we just put it in the top of the list
      if Filename = OpenFilesList[count] then
      begin
         UpdateRecentList(count);
         exit; // end loop.
      end;
      inc(count);
   end;
   if MaxOpenFiles > 0 then
      AddToRecentList(Filename);
end;

procedure TSHPBuilderFrmMain.UpdateRecentList(const position : word);
var
   count : word;
   name : string;
begin
   if (position = 0) then exit; // nothing to update.
   // Name gets the name of the current position to be promoted
   name := OpenFilesList[position];
   count := position;
   // Nudge list down.
   while count > 0 do
   begin
      OpenFilesList[count] := OpenFilesList[count-1];
      OpenRecent1.Items[count].Caption := OpenFilesList[count];
      dec(count);
   end;
   // Now, add the top element.
   OpenFilesList[0] := name;
   OpenRecent1.Items[0].Caption := name;
end;

procedure TSHPBuilderFrmMain.AddToRecentList(const Name : string);
var
   count : word;
   Item : TMenuItem;
begin
   OpenRecent1.Visible := true;
   count := OpenRecent1.Count;
   // If the ammount of elements isn't the max allowed,
   // add a new one
   if count < MaxOpenFiles then
   begin
      // add the element in the end
      Item := TMenuItem.Create(Owner);
      Item.Caption := OpenFilesList[count]; // temp value
      Item.Tag := count;
      Item.OnClick := OpenRecentClicked;
      Item.Visible := true;

      OpenRecent1.Insert(OpenRecent1.Count,Item);
   end
   else
      dec(count);
   // Nudge list down.
   while count > 0 do
   begin
      OpenFilesList[count] := OpenFilesList[count-1];
      OpenRecent1.Items[count].Caption := OpenFilesList[count];
      dec(count);
   end;
   // Now, add the top element.
   OpenFilesList[0] := Name;
   OpenRecent1.Items[0].Caption := Name;
end;

procedure TSHPBuilderFrmMain.SetMaxOpenFiles(NewValue : word);
var
   count : integer;
begin
   // Update MaxOpenFiles
   MaxOpenFiles := NewValue;

   // Resize the OpenFilesList
   SetLength(OpenFilesList,MaxOpenFiles);

   // Remove links if the size shrinks.
   if NewValue < OpenRecent1.Count then
   begin
       count := OpenRecent1.Count-1;
       while count >= NewValue do
       begin
          OpenRecent1.Delete(count);
          dec(count);
       end;
   end;

   if NewValue = 0 then
      OpenRecent1.Visible := false;
end;

// *************************************************** //
// ******** Procedures to the Open HyperLinks ******** //
// *************************************************** //

// Note: Cloned from Voxel Section Editor III, made by Stucuk

procedure TSHPBuilderFrmMain.LoadSite(Sender : TObject);
begin
   OpenHyperlink(PChar(FrmMain.SiteList[TMenuItem(Sender).Tag].SiteUrl));
end;

procedure TSHPBuilderFrmMain.OpenHyperlink(HyperLink: PChar);
begin
   ShellExecute(Application.Handle,nil,HyperLink,'','',SW_SHOWNORMAL);
end;


//---------------------------------------------
// Refresh Grid UI Components
// TODO : rework this method.
//---------------------------------------------
procedure TSHPBuilderFrmMain.RefreshGridUIComponents;
begin
   if ActiveForm^.CellWidth = 60 then begin
      // RA2
      LastSelectedGridType := 1;
      TbShowGrid.ImageIndex := 2;
   end
   else begin
      // TS by default
      LastSelectedGridType := 0;
      TbShowGrid.ImageIndex := 0;
   end;

   if not ActiveForm^.ShowGrid then begin
      // No grid
      TbShowGrid.ImageIndex := 22;
   end;
end;

//---------------------------------------------
// DropDownList Show Grid Button Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.TbShowGridClick(Sender: TObject);
begin
   if (ActiveForm^.ShowGrid) then begin
      ShowNone1Click(nil);
   end
   else begin
      if LastSelectedGridType = 0 then 
         SGrids1Click(nil)
      else
         RA2Grids1Click(nil);
  end;
end;


//---------------------------------------------
// DropDownList Show Grid None Button Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.ShowNone1Click(Sender: TObject);
begin
   // Doesn't show grid.
   ActiveForm^.ShowGrid := false;
   TbShowGrid.ImageIndex := 22;
   ActiveForm^.RefreshImage;
end;


//---------------------------------------------
// DropDownList Show Grid TS Button Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.SGrids1Click(Sender: TObject);
begin
   // Show TS Grid;
   ActiveForm^.ShowGrid := true;
   ActiveForm^.CellWidth := 48;
   ActiveForm^.CellHeight := 25;
   LastSelectedGridType := 0;
   TbShowGrid.ImageIndex := 0;
   ActiveForm^.RefreshImage;
end;


//---------------------------------------------
// DropDownList Show Grid RA2 Button Click
//---------------------------------------------
procedure TSHPBuilderFrmMain.RA2Grids1Click(Sender: TObject);
begin
   // Show RA2 Grid;
   ActiveForm^.ShowGrid := true;
   ActiveForm^.CellWidth := 60;
   ActiveForm^.CellHeight := 31;
   LastSelectedGridType := 1;
   TbShowGrid.ImageIndex := 2;
   ActiveForm^.RefreshImage;
end;

// 3.35: SHP Type Menu :: Games.
procedure TSHPBuilderFrmMain.SHPTypeMenuTDClick(Sender: TObject);
begin
{
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveForm^.UpdateSHPTypeFromGame;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
}
end;

procedure TSHPBuilderFrmMain.SHPTypeMenuRA1Click(Sender: TObject);
begin
{
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveForm^.UpdateSHPTypeFromGame;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
}
end;

procedure TSHPBuilderFrmMain.SHPTypeMenuTSClick(Sender: TObject);
begin
{
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveForm^.UpdateSHPTypeFromGame;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
}
end;

procedure TSHPBuilderFrmMain.SHPTypeMenuRA2Click(Sender: TObject);
begin
{
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveForm^.UpdateSHPTypeFromGame;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
}
end;

// 3.35: SHP Type Menu :: Types.
//  Tiberian Dawn
procedure TSHPBuilderFrmMain.SHPTypeTDUnitClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stUnit;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDBuildingClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stBuilding;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDBuildAnimClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stBuildAnim;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDAnimationClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stAnimation;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDCameoClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stCameo;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDDesertClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stDes;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTDWinterClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTD;
   ActiveData^.SHP.SHPType := stWin;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

// Red Alert 1:
procedure TSHPBuilderFrmMain.SHPTypeRA1UnitClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stUnit;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1BuildingClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stBuilding;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1BuildAnimClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stBuildAnim;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1AnimationClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stAnimation;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1CameoClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stCameo;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1TemperateClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stTem;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1SnowClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stSno;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA1InteriorClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA1;
   ActiveData^.SHP.SHPType := stInt;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

// Tiberian Sun:
procedure TSHPBuilderFrmMain.SHPTypeTSUnitClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stUnit;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSBuildingClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stBuilding;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSBuildAnimClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stBuildAnim;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSAnimationClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stAnimation;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSCameoClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stCameo;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSTemperateClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stTem;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeTSSnowClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgTS;
   ActiveData^.SHP.SHPType := stSno;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

// Red Alert 2:
procedure TSHPBuilderFrmMain.SHPTypeRA2UnitClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stUnit;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2BuildingClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stBuilding;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2BuildAnimClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stBuildAnim;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2AnimationClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stAnimation;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2CameoClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stCameo;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2TemperateClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stTem;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2SnowClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stSno;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2UrbanClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stUrb;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2DesertClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stDes;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2LunarClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stLun;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

procedure TSHPBuilderFrmMain.SHPTypeRA2NewUrbanClick(Sender: TObject);
begin
   if ActiveData = nil then exit;

   ActiveData^.SHP.SHPGame := sgRA2;
   ActiveData^.SHP.SHPType := stNewUrb;
   ActiveForm^.UpdateSHPTypeMenu;
   ActiveForm^.WriteSHPType;
end;

end.
