unit FormPreferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Registry, jpeg, SHP_Sequence_Animation,
  Spin, XPMan;

const
   DEFAULT_ALG = 7;
   DEFAULT_LOAD = 0;
   DEFAULT_SAVE = 1;
   DEFAULT_OPENFILES = 5;

const
   PLOP_TDPALETTE = 0;
   PLOP_RA1UNIT = 1;
   PLOP_RA1BUILDANIM = 2;
   PLOP_RA1BUILDING = 3;
   PLOP_RA1ANIM = 4;
   PLOP_RA1CAMEO = 5;
   PLOP_RA1TEM = 6;
   PLOP_RA1SNO = 7;
   PLOP_RA1INT = 8;
   PLOP_TSUNIT = 9;
   PLOP_TSBUILDANIM = 10;
   PLOP_TSBUILDING = 11;
   PLOP_TSANIM = 12;
   PLOP_TSCAMEO = 13;
   PLOP_TSTEM = 14;
   PLOP_TSSNO = 15;
   PLOP_RA2UNIT = 16;
   PLOP_RA2BUILDANIM = 17;
   PLOP_RA2BUILDING = 18;
   PLOP_RA2ANIM = 19;
   PLOP_RA2CAMEO = 20;
   PLOP_RA2TEM = 21;
   PLOP_RA2SNO = 22;
   PLOP_RA2URB = 23;
   PLOP_RA2DES = 24;
   PLOP_RA2LUN = 25;
   PLOP_RA2UBN = 26;


type
   TFrmPreferences = class(TForm)
      GroupBox1: TGroupBox;
      Bevel1: TBevel;
    BtOK: TButton;
      Pref_List: TTreeView;
      PageControl1: TPageControl;
    TabFileAssociation: TTabSheet;
      AssociateCheck: TCheckBox;
      GroupBox3: TGroupBox;
      IconPrev: TImage;
      IconID: TTrackBar;
      BtnApply: TButton;
    TabPalette: TTabSheet;
      CheckBox1: TCheckBox;
      Label1: TLabel;
      IconList: TImageList;
      UnitPalette: TComboBoxEx;
      BuildingPalette: TComboBoxEx;
      AnimationPalette: TComboBoxEx;
      BuildAnimPalette: TComboBoxEx;
    TabCCM: TTabSheet;
      Label5: TLabel;
      RadioButton4: TRadioButton;
    TabAnims: TTabSheet;
    TabSHPBuilder: TTabSheet;
      Image1: TImage;
      Bevel2: TBevel;
      SettingsBox: TRichEdit;
    TabSequenceMaker: TTabSheet;
      RichEdit1: TRichEdit;
      Bevel3: TBevel;
      Image2: TImage;
      ASDFBox: TListBox;
      Button1: TButton;
      Button3: TButton;
      Button4: TButton;
      RadioButton6: TRadioButton;
      RadioButton7: TRadioButton;
      GroupBox2: TGroupBox;
      Load0: TRadioButton;
      Load1: TRadioButton;
      Load2: TRadioButton;
      GroupBox4: TGroupBox;
      Save0: TRadioButton;
      Save1: TRadioButton;
      Save2: TRadioButton;
      SpeMaxOpenFiles: TSpinEdit;
      Label6: TLabel;
      Label7: TLabel;
      Load3: TRadioButton;
      Load4: TRadioButton;
      btCancel: TButton;
      btReset: TButton;
    LbPalette1: TLabel;
    LbPalette2: TLabel;
    LbPalette3: TLabel;
    LbPalette4: TLabel;
    LbPalette5: TLabel;
      CameoPalette: TComboBoxEx;
      Terrain1Palette: TComboBoxEx;
      Terrain2Palette: TComboBoxEx;
    Terrain3Palette: TComboBoxEx;
    LbPalette6: TLabel;
    LbPalette7: TLabel;
    LbPalette8: TLabel;
      CbxGame: TComboBoxEx;
    ccmStructuralis: TRadioButton;
    Save3: TRadioButton;
    XPManifest: TXPManifest;
    cbApplySelOnFrameChanging: TCheckBox;
      procedure BtnApplyClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure IconIDChange(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure Pref_ListClick(Sender: TObject);
      procedure Pref_ListKeyDown(Sender: TObject; var Key: Word;
         Shift: TShiftState);
      procedure Pref_ListKeyPress(Sender: TObject; var Key: Char);
      procedure Pref_ListKeyUp(Sender: TObject; var Key: Word;
         Shift: TShiftState);
      procedure CheckBox1Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure ASDFBoxClick(Sender: TObject);
      procedure Button4Click(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure Button3Click(Sender: TObject);
      function GetFilenameFromNo(itemindex:cardinal): string;
      function GetComboBoxNo(filename:string; default : cardinal): cardinal;
      function GetComboBoxNoFromString(filename:string; default : string; game: string): cardinal;
      procedure btCancelClick(Sender: TObject);
      procedure btResetClick(Sender: TObject);
    procedure CbxGameChange(Sender: TObject);
    procedure UnitPaletteChange(Sender: TObject);
    procedure BuildingPaletteChange(Sender: TObject);
    procedure AnimationPaletteChange(Sender: TObject);
    procedure BuildAnimPaletteChange(Sender: TObject);
    procedure CameoPaletteChange(Sender: TObject);
    procedure Terrain1PaletteChange(Sender: TObject);
    procedure Terrain2PaletteChange(Sender: TObject);
    procedure Terrain3PaletteChange(Sender: TObject);
   private
      { Private declarations }
      TempPalettes : array [0..26] of longword;
   public
      { Public declarations }
      IconPath: String;
      AnimationHeader : TAnimHeaderData;
      AnimationsData : TAnimationsData;
      AnimationsData_no : Word;
      procedure ExtractIcon;
      procedure GetSettings;
   end;

implementation

uses FormMain, FormSequence, Shp_File, FormPreferences_Anim, SHP_DataMatrix,
     SHP_engine_CCMs;

{$R *.dfm}

procedure TFrmPreferences.ExtractIcon;
var
   sWinDir: String;
   iLength: Integer;
   {Res: TResourceStream; }
   MIcon: TIcon;
begin

   // Initialize Variable
   iLength := 255;
   setLength(sWinDir, iLength);
   iLength := GetWindowsDirectory(PChar(sWinDir), iLength);
   setLength(sWinDir, iLength);
   IconPath := sWinDir + '\OS_SHP_BUILDER'+inttostr(IconID.Position)+'.ico';

   MIcon := TIcon.Create;
   IconList.GetIcon(IconID.Position,MIcon);
   MIcon.SaveToFile(IconPath);
   MIcon.Free;
end;

procedure TFrmPreferences.GetSettings;
begin
   // AssociateCheck.Checked:=Config.Assoc;
   // IconID.Position:=Config.Icon;
   AssociateCheck.Checked := FrmMain.FileAssociationsPreferenceData.Associate;
   IconID.Position := FrmMain.FileAssociationsPreferenceData.ImageIndex;
   IconIDChange(Self);

   CheckBox1.Checked := FrmMain.PalettePreferenceData.GameSpecific;
   SpeMaxOpenFiles.Value := FrmMain.MaxOpenFiles;
   cbApplySelOnFrameChanging.Checked := FrmMain.OtherOptionsData.ApplySelOnFrameChanging;
end;

procedure TFrmPreferences.BtnApplyClick(Sender: TObject);
var
   Reg: TRegistry;
begin
   //Config.Icon:=IconID.Position;

   // Global Palette Settings Update:
   // 3.35: Updated with all types from TD, RA1, TS and RA2.
   FrmMain.PalettePreferenceData.TDPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TDPALETTE]);
   FrmMain.PalettePreferenceData.RA1UnitPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1UNIT]);
   FrmMain.PalettePreferenceData.RA1BuildingPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1BUILDING]);
   FrmMain.PalettePreferenceData.RA1BuildingAnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1BUILDANIM]);
   FrmMain.PalettePreferenceData.RA1AnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1ANIM]);
   FrmMain.PalettePreferenceData.RA1CameoPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1CAMEO]);
   FrmMain.PalettePreferenceData.RA1TemperatePalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1TEM]);
   FrmMain.PalettePreferenceData.RA1SnowPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1SNO]);
   FrmMain.PalettePreferenceData.RA1InteriorPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA1INT]);
   FrmMain.PalettePreferenceData.TSUnitPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSUNIT]);
   FrmMain.PalettePreferenceData.TSBuildingPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSBUILDING]);
   FrmMain.PalettePreferenceData.TSBuildingAnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSBUILDANIM]);
   FrmMain.PalettePreferenceData.TSAnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSANIM]);
   FrmMain.PalettePreferenceData.TSCameoPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSCAMEO]);
   FrmMain.PalettePreferenceData.TSIsoTemPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSTEM]);
   FrmMain.PalettePreferenceData.TSIsoSnowPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_TSSNO]);
   FrmMain.PalettePreferenceData.RA2UnitPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2UNIT]);
   FrmMain.PalettePreferenceData.RA2BuildingPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2BUILDING]);
   FrmMain.PalettePreferenceData.RA2BuildingAnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2BUILDANIM]);
   FrmMain.PalettePreferenceData.RA2AnimationPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2ANIM]);
   FrmMain.PalettePreferenceData.RA2CameoPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2CAMEO]);
   FrmMain.PalettePreferenceData.RA2IsoTemPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2TEM]);
   FrmMain.PalettePreferenceData.RA2IsoSnowPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2SNO]);
   FrmMain.PalettePreferenceData.RA2IsoUrbPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2URB]);
   FrmMain.PalettePreferenceData.RA2IsoDesPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2DES]);
   FrmMain.PalettePreferenceData.RA2IsoLunPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2LUN]);
   FrmMain.PalettePreferenceData.RA2IsoNewUrbPalette.Filename := GetFilenameFromNo(TempPalettes[PLOP_RA2UBN]);
   FrmMain.PalettePreferenceData.GameSpecific := CheckBox1.Checked;

   // Associate OS SHP Builder with .SHP? User decides.
   FrmMain.FileAssociationsPreferenceData.ImageIndex := IconID.Position;
   FrmMain.FileAssociationsPreferenceData.Associate := AssociateCheck.Checked;

   // CCM Settings Update:
   if RadioButton4.Checked = true then
      FrmMain.alg := 4
   else if RadioButton6.Checked = true then
      FrmMain.alg := 5
   else if RadioButton7.Checked = true then
      FrmMain.alg := Infurium
   else if ccmStructuralis.Checked = true then
      FrmMain.alg := 7;

   // Saving Settings Update:
   if Save0.Checked then
      FrmMain.savemode := 0
   else if Save1.Checked then
      FrmMain.savemode := 1
   else if Save2.Checked then
      FrmMain.savemode := 2
   else if Save3.Checked then
      FrmMain.savemode := 3;

   // Loading Settings Update:
   if Load0.Checked then
      FrmMain.loadmode := 0
   else if Load1.Checked then
      FrmMain.loadmode := 1
   else if Load2.Checked then
      FrmMain.loadmode := 2
   else if Load3.Checked then
      FrmMain.loadmode := 3
   else if Load4.Checked then
      FrmMain.loadmode := 4;

   // Max Open Files Update:
   if (StrToIntDef(SpeMaxOpenFiles.Text,FrmMain.MaxOpenFiles) <> FrmMain.MaxOpenFiles) then
      FrmMain.SetMaxOpenFiles(SpeMaxOpenFiles.Value);

   // Apply Selection on Frame Changing
   FrmMain.OtherOptionsData.ApplySelOnFrameChanging := cbApplySelOnFrameChanging.Checked;

   // Icon Registry part
   ExtractIcon;
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   if Reg.OpenKey('\OS_SHP_BUILDER\DefaultIcon\',true) then
      Reg.WriteString('',IconPath);
   Reg.CloseKey;
   Reg.Free;

   // Associate with .SHP: Registry part
   if AssociateCheck.Checked = true then
   begin
      // Config.Assoc:=True;
      Reg :=TRegistry.Create;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('\.shp\',true) then
         Reg.WriteString('','OS_SHP_BUILDER');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('\OS_SHP_BUILDER\shell\',true) then
         Reg.WriteString('','Open');
      if Reg.OpenKey('\OS_SHP_BUILDER\shell\open\command\',true) then
         Reg.WriteString('',ParamStr(0)+' %1');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.shp\',true) then
         Reg.WriteString('Application',ParamStr(0)+' "%1"');
      Reg.CloseKey;
      Reg.Free;
      Close;
   end
   else
   begin
      // Config.Assoc:=False;
      Reg :=TRegistry.Create;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if (Reg.KeyExists('.shp')) then
         Reg.DeleteKey('.shp');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.KeyExists('\OS_SHP_BUILDER\') then
         Reg.DeleteKey('\OS_SHP_BUILDER\');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.KeyExists('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.shp\') then
         Reg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.shp\');
      Reg.CloseKey;
      Reg.Free;
      Close;
   end;
end;

function TFrmPreferences.GetComboBoxNo(filename:string; default : cardinal): cardinal;
var
   f_name : string;
   x : integer;
begin
   f_name := copy(Filename,1,Length(Filename));
   result := default;
   for x := 1 to FrmMain.PaletteSchemes_no do
      if CompareStr(FrmMain.PaletteSchemes[x].Filename,f_name) = 0 then
         result := x-1;
end;

function TFrmPreferences.GetComboBoxNoFromString(filename:string; default : string; game: string): cardinal;
var
   f_name : string;
   x : integer;
begin
   f_name := copy(Filename,1,Length(Filename));
   result := 0;
   for x := 1 to FrmMain.PaletteSchemes_no do
      if FrmMain.PaletteSchemes[x].Filename = f_name then
      begin
         result := x-1;
         exit;
      end;
   // Try default;
   f_name := ExtractFileDir(ParamStr(0)) + '\Palettes\' + game + '\' + default;
   for x := 1 to FrmMain.PaletteSchemes_no do
      if CompareStr(FrmMain.PaletteSchemes[x].Filename,f_name) = 0 then
      begin
         result := x-1;
         exit;
      end;
end;

function TFrmPreferences.GetFilenameFromNo(itemindex:cardinal): string;
begin
   Result := FrmMain.PaletteSchemes[itemindex+1].Filename;
end;


procedure TFrmPreferences.FormShow(Sender: TObject);
var
   x : integer;
begin
   GetSettings;


   UnitPalette.Images := FrmMain.ImageList;
   BuildingPalette.Images := FrmMain.ImageList;
   BuildAnimPalette.Images := FrmMain.ImageList;
   AnimationPalette.Images := FrmMain.ImageList;
   CameoPalette.Images := FrmMain.ImageList;
   Terrain1Palette.Images := FrmMain.ImageList;
   Terrain2Palette.Images := FrmMain.ImageList;
   Terrain3Palette.Images := FrmMain.ImageList;

   for x := 1 to FrmMain.PaletteSchemes_no do
   begin
      UnitPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      UnitPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      BuildingPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      BuildingPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      AnimationPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      AnimationPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      BuildAnimPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      BuildAnimPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      CameoPalette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      CameoPalette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      Terrain1Palette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      Terrain1Palette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      Terrain2Palette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      Terrain2Palette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;

      Terrain3Palette.Items.Add(extractfilename(FrmMain.paletteschemes[x].filename));
      Terrain3Palette.ItemsEx.ComboItems[x-1].ImageIndex := FrmMain.paletteschemes[x].ImageIndex;
   end;

   TempPalettes[PLOP_TDPALETTE] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TDPalette.Filename,'temperat.pal','TD');
   TempPalettes[PLOP_RA1UNIT] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1UnitPalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1BUILDANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1BuildingAnimationPalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1BUILDING] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1BuildingPalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1ANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1AnimationPalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1CAMEO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1CameoPalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1TEM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1TemperatePalette.Filename,'temperat.pal','RA1');
   TempPalettes[PLOP_RA1SNO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1SnowPalette.Filename,'snow.pal','RA1');
   TempPalettes[PLOP_RA1INT] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA1InteriorPalette.Filename,'interior.pal','RA1');
   TempPalettes[PLOP_TSUNIT] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSUnitPalette.Filename,'unittem.pal','TS');
   TempPalettes[PLOP_TSBUILDANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSBuildingAnimationPalette.Filename,'unittem.pal','TS');
   TempPalettes[PLOP_TSBUILDING] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSBuildingPalette.Filename,'unittem.pal','TS');
   TempPalettes[PLOP_TSANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSAnimationPalette.Filename,'anim.pal','TS');
   TempPalettes[PLOP_TSCAMEO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSCameoPalette.Filename,'cameo.pal','TS');
   TempPalettes[PLOP_TSTEM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSIsoTemPalette.Filename,'isotem.pal','TS');
   TempPalettes[PLOP_TSSNO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.TSIsoSnowPalette.Filename,'isosno.pal','TS');
   TempPalettes[PLOP_RA2UNIT] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2UnitPalette.Filename,'unittem.pal','RA2');
   TempPalettes[PLOP_RA2BUILDANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2BuildingAnimationPalette.Filename,'unittem.pal','RA2');
   TempPalettes[PLOP_RA2BUILDING] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2BuildingPalette.Filename,'unittem.pal','RA2');
   TempPalettes[PLOP_RA2ANIM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2AnimationPalette.Filename,'anim.pal','RA2');
   TempPalettes[PLOP_RA2CAMEO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2CameoPalette.Filename,'cameo.pal','RA2');
   TempPalettes[PLOP_RA2TEM] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoTemPalette.Filename,'isotem.pal','RA2');
   TempPalettes[PLOP_RA2SNO] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoSnowPalette.Filename,'isosno.pal','RA2');
   TempPalettes[PLOP_RA2URB] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoUrbPalette.Filename,'isourb.pal','RA2');
   TempPalettes[PLOP_RA2DES] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoDesPalette.Filename,'isodes.pal','YR');
   TempPalettes[PLOP_RA2LUN] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoLunPalette.Filename,'isolun.pal','YR');
   TempPalettes[PLOP_RA2UBN] := GetComboBoxNoFromString(FrmMain.PalettePreferenceData.RA2IsoNewUrbPalette.Filename,'isoubn.pal','YR');

   CbxGame.ItemIndex := 0;
   CbxGameChange(sender);
   CheckBox1Click(sender);

   if FrmMain.alg = 0 then
      ccmStructuralis.Checked := true
   else if FrmMain.alg = 1 then
      ccmStructuralis.Checked := true
   else if FrmMain.alg = 2 then
      ccmStructuralis.Checked := true
   else if FrmMain.alg = 3 then
      ccmStructuralis.Checked := true
   else if FrmMain.alg = 4 then
      RadioButton4.Checked := true
   else if FrmMain.alg = 5 then
      RadioButton6.Checked := true
   else if FrmMain.alg = 7 then
      ccmStructuralis.Checked := true
   else if FrmMain.alg = Infurium then
      RadioButton7.Checked := true;


   case FrmMain.savemode of
     0: Save0.Checked := true;
     1: Save1.Checked := true;
     2: Save2.Checked := true;
     3: Save3.Checked := true
     else
     Save0.Checked := true;
   end;
   case FrmMain.loadmode of
     0: Load0.Checked := true;
     1: Load1.Checked := true;
     2: Load2.Checked := true;
     3: Load3.Checked := true;
     4: Load4.Checked := true
     else
     Load0.Checked := true;
   end;
   ASDFBox.Clear;

   AnimationsData_no := 0;
   LoadASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);
   AnimationsData_no := AnimationHeader.Anims;
   For x := 1 to AnimationsData_no do
      ASDFBox.Items.Add(AnimationsData[x].Anim_Name);
end;

procedure TFrmPreferences.IconIDChange(Sender: TObject);
var
   MIcon: TIcon;//Icon: TResourceStream;
begin
   // Icon := TResourceStream.Create(hInstance,'Icon_'+IntToStr(IconID.Position+1),RT_RCDATA);
   MIcon := TIcon.Create;
   IconList.GetIcon(IconID.Position,MIcon);
   IconPrev.Picture.Icon := MIcon;
   // Icon.Free;
   MIcon.Free;
end;

procedure TFrmPreferences.BtOKClick(Sender: TObject);
begin
   BtnApplyClick(Sender);
   Close;
end;

procedure TFrmPreferences.Pref_ListClick(Sender: TObject);
begin
   if pref_list.SelectionCount > 0 then
   begin
      if pref_list.Selected.Text = 'File Associations' then
         PageControl1.ActivePageIndex := 0
      else if pref_list.Selected.Text = 'Palette' then
         PageControl1.ActivePageIndex := 1
      else if pref_list.Selected.Text = 'Misc' then
         PageControl1.ActivePageIndex := 2
      else if pref_list.Selected.Text = 'Anims' then
         PageControl1.ActivePageIndex := 3
      else if pref_list.Selected.Text = 'SHP Builder' then
         PageControl1.ActivePageIndex := 4
      else if pref_list.Selected.Text = 'Sequence Maker' then
         PageControl1.ActivePageIndex := 5
      else if pref_list.Selected.Text = 'Loading & Saving' then
         PageControl1.ActivePageIndex := 6;

      GroupBox1.Caption := pref_list.Selected.Text;
   end;
end;

procedure TFrmPreferences.Pref_ListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyPress(Sender: TObject;
  var Key: Char);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.CheckBox1Click(Sender: TObject);
begin
   // Labels
   LbPalette1.Enabled := CheckBox1.Checked;
   LbPalette2.Enabled := CheckBox1.Checked;
   LbPalette3.Enabled := CheckBox1.Checked;
   LbPalette4.Enabled := CheckBox1.Checked;
   LbPalette5.Enabled := CheckBox1.Checked;
   LbPalette6.Enabled := CheckBox1.Checked;
   LbPalette7.Enabled := CheckBox1.Checked;
   LbPalette8.Enabled := CheckBox1.Checked;
   // Comboboxes
   UnitPalette.Enabled := CheckBox1.Checked;
   BuildingPalette.Enabled := CheckBox1.Checked;
   BuildAnimPalette.Enabled := CheckBox1.Checked;
   AnimationPalette.Enabled := CheckBox1.Checked;
   CameoPalette.Enabled := CheckBox1.Checked;
   Terrain1Palette.Enabled := CheckBox1.Checked;
   Terrain2Palette.Enabled := CheckBox1.Checked;
   Terrain3Palette.Enabled := CheckBox1.Checked;
   // CbxGame
   CbxGame.Enabled := CheckBox1.Checked;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
var
x : cardinal;
begin
   // Build the left tree view.
   for x := 0 to Pref_List.Items.Count-1 do
      if Pref_List.Items.Item[x].HasChildren = true then
         Pref_List.Items.Item[x].Expand(false);

   PageControl1.ActivePageIndex := 4;
   GroupBox1.Caption := 'SHP Builder';
end;

procedure TFrmPreferences.ASDFBoxClick(Sender: TObject);
begin
   // Dear God, WTF is Button 3 and 4? Sorry...
   if ASDFBox.SelCount > 0 then
   begin
      Button3.Enabled := False;
      Button4.Enabled := False;
   end
   else
   begin
      Button3.Enabled := True;
      Button4.Enabled := True;
   end;
end;

procedure TFrmPreferences.Button4Click(Sender: TObject);
var
   x,s : integer;
begin
   s := -1;

   for x := 0 to ASDFBox.Count-1 do
      if ASDFBox.Selected[x] then
         s := x;

   if s = -1 then
      exit; // nothing selected!!!

   dec(AnimationsData_no);

   if s+1 < AnimationsData_no then // if there is anything to move, move it!
      for x := s+1 to AnimationsData_no do
      begin
         AnimationsData[x].Anim_Name := AnimationsData[x+1].Anim_Name;
         AnimationsData[x].Anim.Count := AnimationsData[x+1].Anim.Count;
         AnimationsData[x].Anim.Count2 := AnimationsData[x+1].Anim.Count2;
         AnimationsData[x].Anim.StartFrame := AnimationsData[x+1].Anim.StartFrame;
         AnimationsData[x].Anim.special := AnimationsData[x+1].Anim.special;
      end;

   Setlength(AnimationsData,AnimationsData_no+1);

   ASDFBox.Clear;
   For x := 1 to AnimationsData_no do
      ASDFBox.Items.Add(AnimationsData[x].Anim_Name);

   AnimationHeader.Anims := AnimationsData_no;
   SaveASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);
end;

procedure TFrmPreferences.Button1Click(Sender: TObject);
var
   x : integer;
   FrmPreferences_Anim: TFrmPreferences_Anim;
begin
   FrmPreferences_Anim := TFrmPreferences_Anim.Create(self);
   FrmPreferences_Anim.Name.Text := '';
   FrmPreferences_Anim.StartFrame.Value := 0;
   FrmPreferences_Anim.Count.Value := 0;
   FrmPreferences_Anim.Count2.Value := 0;
   FrmPreferences_Anim.Special.Text := '';
   FrmPreferences_Anim.ShowModal;
   if FrmPreferences_Anim.OkP = false then
      exit; // canceled!

   inc(AnimationsData_no);
   setlength(AnimationsData,AnimationsData_no+1);

   AnimationsData[AnimationsData_no].Anim_Name := FrmPreferences_Anim.Name.Text;
   AnimationsData[AnimationsData_no].Anim.Count := FrmPreferences_Anim.Count.Value;
   AnimationsData[AnimationsData_no].Anim.Count2 := FrmPreferences_Anim.Count2.Value;
   AnimationsData[AnimationsData_no].Anim.StartFrame := FrmPreferences_Anim.StartFrame.Value;
   AnimationsData[AnimationsData_no].Anim.Special := FrmPreferences_Anim.Special.Text;

   ASDFBox.Clear;
   For x := 1 to AnimationsData_no do
      ASDFBox.Items.Add(AnimationsData[x].Anim_Name);

   AnimationHeader.Anims := AnimationsData_no;
   SaveASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);

   FrmPreferences_Anim.Release;
end;

procedure TFrmPreferences.Button3Click(Sender: TObject);
var
   x,s : integer;
   FrmPreferences_Anim: TFrmPreferences_Anim;
begin
   s := -1;

   for x := 0 to ASDFBox.Count-1 do
      if ASDFBox.Selected[x] then
         s := x;

   if s = -1 then
      exit; // nothing selected!!!

   inc(s);

   FrmPreferences_Anim := TFrmPreferences_Anim.Create(self);
   FrmPreferences_Anim.Name.Text := AnimationsData[s].Anim_Name;
   FrmPreferences_Anim.StartFrame.Value := AnimationsData[s].Anim.StartFrame;
   FrmPreferences_Anim.Count.Value := AnimationsData[s].Anim.Count;
   FrmPreferences_Anim.Count2.Value := AnimationsData[s].Anim.Count2;
   FrmPreferences_Anim.Special.Text := AnimationsData[s].Anim.Special;

   FrmPreferences_Anim.ShowModal;
   if FrmPreferences_Anim.OkP = false then
      exit; // cancled!

   AnimationsData[s].Anim_Name := FrmPreferences_Anim.Name.Text;
   AnimationsData[s].Anim.Count := FrmPreferences_Anim.Count.Value;
   AnimationsData[s].Anim.Count2 := FrmPreferences_Anim.Count2.Value;
   AnimationsData[s].Anim.StartFrame := FrmPreferences_Anim.StartFrame.Value;
   AnimationsData[s].Anim.Special := FrmPreferences_Anim.Special.Text;

   FrmPreferences_Anim.Release;
   SaveASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);
end;

procedure TFrmPreferences.btCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmPreferences.btResetClick(Sender: TObject);
begin
   RadioButton4.Checked := true;
   Save0.Checked := true;
   Load0.Checked := true;
   CheckBox1.Checked := true;
   CheckBox1Click(Sender);

   // Set Default palettes.
   TempPalettes[PLOP_TDPALETTE] := GetComboBoxNoFromString(' ','temperat.pal','TD');
   TempPalettes[PLOP_RA1UNIT] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1BUILDANIM] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1BUILDING] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1ANIM] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1CAMEO] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1TEM] := GetComboBoxNoFromString(' ','temperat.pal','RA1');
   TempPalettes[PLOP_RA1SNO] := GetComboBoxNoFromString(' ','snow.pal','RA1');
   TempPalettes[PLOP_RA1INT] := GetComboBoxNoFromString(' ','interior.pal','RA1');
   TempPalettes[PLOP_TSUNIT] := GetComboBoxNoFromString(' ','unittem.pal','TS');
   TempPalettes[PLOP_TSBUILDANIM] := GetComboBoxNoFromString(' ','unittem.pal','TS');
   TempPalettes[PLOP_TSBUILDING] := GetComboBoxNoFromString(' ','unittem.pal','TS');
   TempPalettes[PLOP_TSANIM] := GetComboBoxNoFromString(' ','anim.pal','TS');
   TempPalettes[PLOP_TSCAMEO] := GetComboBoxNoFromString(' ','cameo.pal','TS');
   TempPalettes[PLOP_TSTEM] := GetComboBoxNoFromString(' ','isotem.pal','TS');
   TempPalettes[PLOP_TSSNO] := GetComboBoxNoFromString(' ','isosno.pal','TS');
   TempPalettes[PLOP_RA2UNIT] := GetComboBoxNoFromString(' ','unittem.pal','RA2');
   TempPalettes[PLOP_RA2BUILDANIM] := GetComboBoxNoFromString(' ','unittem.pal','RA2');
   TempPalettes[PLOP_RA2BUILDING] := GetComboBoxNoFromString(' ','unittem.pal','RA2');
   TempPalettes[PLOP_RA2ANIM] := GetComboBoxNoFromString(' ','anim.pal','RA2');
   TempPalettes[PLOP_RA2CAMEO] := GetComboBoxNoFromString(' ','cameo.pal','RA2');
   TempPalettes[PLOP_RA2TEM] := GetComboBoxNoFromString(' ','isotem.pal','RA2');
   TempPalettes[PLOP_RA2SNO] := GetComboBoxNoFromString(' ','isosno.pal','RA2');
   TempPalettes[PLOP_RA2URB] := GetComboBoxNoFromString(' ','isourb.pal','RA2');
   TempPalettes[PLOP_RA2DES] := GetComboBoxNoFromString(' ','isodes.pal','YR');
   TempPalettes[PLOP_RA2LUN] := GetComboBoxNoFromString(' ','isolun.pal','YR');
   TempPalettes[PLOP_RA2UBN] := GetComboBoxNoFromString(' ','isoubn.pal','YR');
   CbxGameChange(sender);
end;

procedure TFrmPreferences.CbxGameChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      0:  // TD Code goes here.
      begin
         // Set Text of visible labels
         LbPalette1.Caption := 'TD Palette:';
         // Set value of visible comboboxes.
         UnitPalette.ItemIndex := TempPalettes[PLOP_TDPALETTE];
         // Show/Hide Pannels.
         LbPalette1.Visible := true;
         LbPalette2.Visible := false;
         LbPalette3.Visible := false;
         LbPalette4.Visible := false;
         LbPalette5.Visible := false;
         LbPalette6.Visible := false;
         LbPalette7.Visible := false;
         LbPalette8.Visible := false;
         UnitPalette.Visible := true;
         BuildingPalette.Visible := false;
         AnimationPalette.Visible := false;
         BuildAnimPalette.Visible := false;
         CameoPalette.Visible := false;
         Terrain1Palette.Visible := false;
         Terrain2Palette.Visible := false;
         Terrain3Palette.Visible := false;
      end;
      1: // RA1 Code goes here
      begin
         // Set Text of visible labels
         LbPalette1.Caption := 'Units:';
         LbPalette2.Caption := 'Buildings:';
         LbPalette3.Caption := 'Animations:';
         LbPalette4.Caption := 'Build Animations:';
         LbPalette5.Caption := 'Cameos:';
         LbPalette6.Caption := 'Temperate:';
         LbPalette7.Caption := 'Snow:';
         LbPalette8.Caption := 'Interior:';
         // Set value of visible comboboxes.
         UnitPalette.ItemIndex := TempPalettes[PLOP_RA1UNIT];
         BuildingPalette.ItemIndex := TempPalettes[PLOP_RA1BUILDING];
         AnimationPalette.ItemIndex := TempPalettes[PLOP_RA1ANIM];
         BuildAnimPalette.ItemIndex := TempPalettes[PLOP_RA1BUILDANIM];
         CameoPalette.ItemIndex := TempPalettes[PLOP_RA1CAMEO];
         Terrain1Palette.ItemIndex := TempPalettes[PLOP_RA1TEM];
         Terrain2Palette.ItemIndex := TempPalettes[PLOP_RA1SNO];
         Terrain3Palette.ItemIndex := TempPalettes[PLOP_RA1INT];
         // Show/Hide Pannels.
         LbPalette1.Visible := true;
         LbPalette2.Visible := true;
         LbPalette3.Visible := true;
         LbPalette4.Visible := true;
         LbPalette5.Visible := true;
         LbPalette6.Visible := true;
         LbPalette7.Visible := true;
         LbPalette8.Visible := true;
         UnitPalette.Visible := true;
         BuildingPalette.Visible := true;
         AnimationPalette.Visible := true;
         BuildAnimPalette.Visible := true;
         CameoPalette.Visible := true;
         Terrain1Palette.Visible := true;
         Terrain2Palette.Visible := true;
         Terrain3Palette.Visible := true;
      end;
      2: // TS code goes here
      begin
         // Set Text of visible labels
         LbPalette1.Caption := 'Units:';
         LbPalette2.Caption := 'Buildings:';
         LbPalette3.Caption := 'Animations:';
         LbPalette4.Caption := 'Build Animations:';
         LbPalette5.Caption := 'Cameos:';
         LbPalette6.Caption := 'Temperate:';
         LbPalette7.Caption := 'Snow:';
         // Set value of visible comboboxes.
         UnitPalette.ItemIndex := TempPalettes[PLOP_TSUNIT];
         BuildingPalette.ItemIndex := TempPalettes[PLOP_TSBUILDING];
         AnimationPalette.ItemIndex := TempPalettes[PLOP_TSANIM];
         BuildAnimPalette.ItemIndex := TempPalettes[PLOP_TSBUILDANIM];
         CameoPalette.ItemIndex := TempPalettes[PLOP_TSCAMEO];
         Terrain1Palette.ItemIndex := TempPalettes[PLOP_TSTEM];
         Terrain2Palette.ItemIndex := TempPalettes[PLOP_TSSNO];
         // Show/Hide Pannels.
         LbPalette1.Visible := true;
         LbPalette2.Visible := true;
         LbPalette3.Visible := true;
         LbPalette4.Visible := true;
         LbPalette5.Visible := true;
         LbPalette6.Visible := true;
         LbPalette7.Visible := true;
         LbPalette8.Visible := false;
         UnitPalette.Visible := true;
         BuildingPalette.Visible := true;
         AnimationPalette.Visible := true;
         BuildAnimPalette.Visible := true;
         CameoPalette.Visible := true;
         Terrain1Palette.Visible := true;
         Terrain2Palette.Visible := true;
         Terrain3Palette.Visible := false;
      end;
      3: // RA2 codes goes here
      begin
         // Set Text of visible labels
         LbPalette1.Caption := 'Units:';
         LbPalette2.Caption := 'Buildings:';
         LbPalette3.Caption := 'Animations:';
         LbPalette4.Caption := 'Build Animations:';
         LbPalette5.Caption := 'Cameos:';
         LbPalette6.Caption := 'Temperate:';
         LbPalette7.Caption := 'Snow:';
         LbPalette8.Caption := 'Urban:';
         // Set value of visible comboboxes.
         UnitPalette.ItemIndex := TempPalettes[PLOP_RA2UNIT];
         BuildingPalette.ItemIndex := TempPalettes[PLOP_RA2BUILDING];
         AnimationPalette.ItemIndex := TempPalettes[PLOP_RA2ANIM];
         BuildAnimPalette.ItemIndex := TempPalettes[PLOP_RA2BUILDANIM];
         CameoPalette.ItemIndex := TempPalettes[PLOP_RA2CAMEO];
         Terrain1Palette.ItemIndex := TempPalettes[PLOP_RA2TEM];
         Terrain2Palette.ItemIndex := TempPalettes[PLOP_RA2SNO];
         Terrain3Palette.ItemIndex := TempPalettes[PLOP_RA2URB];
         // Show/Hide Pannels.
         LbPalette1.Visible := true;
         LbPalette2.Visible := true;
         LbPalette3.Visible := true;
         LbPalette4.Visible := true;
         LbPalette5.Visible := true;
         LbPalette6.Visible := true;
         LbPalette7.Visible := true;
         LbPalette8.Visible := true;
         UnitPalette.Visible := true;
         BuildingPalette.Visible := true;
         AnimationPalette.Visible := true;
         BuildAnimPalette.Visible := true;
         CameoPalette.Visible := true;
         Terrain1Palette.Visible := true;
         Terrain2Palette.Visible := true;
         Terrain3Palette.Visible := true;
      end;
      4: // YR code goes here
      begin
         // Set Text of visible labels
         LbPalette1.Caption := 'Desert:';
         LbPalette2.Caption := 'Lunar:';
         LbPalette3.Caption := 'New Urban:';
         // Set value of visible comboboxes.
         UnitPalette.ItemIndex := TempPalettes[PLOP_RA2DES];
         BuildingPalette.ItemIndex := TempPalettes[PLOP_RA2LUN];
         AnimationPalette.ItemIndex := TempPalettes[PLOP_RA2UBN];
         // Show/Hide Pannels.
         LbPalette1.Visible := true;
         LbPalette2.Visible := true;
         LbPalette3.Visible := true;
         LbPalette4.Visible := false;
         LbPalette5.Visible := false;
         LbPalette6.Visible := false;
         LbPalette7.Visible := false;
         LbPalette8.Visible := false;
         UnitPalette.Visible := true;
         BuildingPalette.Visible := true;
         AnimationPalette.Visible := true;
         BuildAnimPalette.Visible := false;
         CameoPalette.Visible := false;
         Terrain1Palette.Visible := false;
         Terrain2Palette.Visible := false;
         Terrain3Palette.Visible := false;
      end;
   end;
end;

procedure TFrmPreferences.UnitPaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      0: TempPalettes[PLOP_TDPALETTE] := UnitPalette.ItemIndex;
      1: TempPalettes[PLOP_RA1UNIT] := UnitPalette.ItemIndex;
      2: TempPalettes[PLOP_TSUNIT] := UnitPalette.ItemIndex;
      3: TempPalettes[PLOP_RA2UNIT] := UnitPalette.ItemIndex;
      4: TempPalettes[PLOP_RA2DES] := UnitPalette.ItemIndex;
   end;
end;

procedure TFrmPreferences.BuildingPaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1BUILDING] := BuildingPalette.ItemIndex;
      2: TempPalettes[PLOP_TSBUILDING] := BuildingPalette.ItemIndex;
      3: TempPalettes[PLOP_RA2BUILDING] := BuildingPalette.ItemIndex;
      4: TempPalettes[PLOP_RA2LUN] := BuildingPalette.ItemIndex;
   end;
end;

procedure TFrmPreferences.AnimationPaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1ANIM] := AnimationPalette.ItemIndex;
      2: TempPalettes[PLOP_TSANIM] := AnimationPalette.ItemIndex;
      3: TempPalettes[PLOP_RA2ANIM] := AnimationPalette.ItemIndex;
      4: TempPalettes[PLOP_RA2UBN] := AnimationPalette.ItemIndex;
   end;
end;

procedure TFrmPreferences.BuildAnimPaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1BUILDANIM] := BuildAnimPalette.ItemIndex;
      2: TempPalettes[PLOP_TSBUILDANIM] := BuildAnimPalette.ItemIndex;
      3: TempPalettes[PLOP_RA2BUILDANIM] := BuildAnimPalette.ItemIndex;
   end;
end;

procedure TFrmPreferences.CameoPaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1CAMEO] := CameoPalette.ItemIndex;
      2: TempPalettes[PLOP_TSCAMEO] := CameoPalette.ItemIndex;
      3: TempPalettes[PLOP_RA2CAMEO] := CameoPalette.ItemIndex;
   end;
end;

procedure TFrmPreferences.Terrain1PaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1TEM] := Terrain1Palette.ItemIndex;
      2: TempPalettes[PLOP_TSTEM] := Terrain1Palette.ItemIndex;
      3: TempPalettes[PLOP_RA2TEM] := Terrain1Palette.ItemIndex;
   end;
end;

procedure TFrmPreferences.Terrain2PaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1SNO] := Terrain2Palette.ItemIndex;
      2: TempPalettes[PLOP_TSSNO] := Terrain2Palette.ItemIndex;
      3: TempPalettes[PLOP_RA2SNO] := Terrain2Palette.ItemIndex;
   end;
end;

procedure TFrmPreferences.Terrain3PaletteChange(Sender: TObject);
begin
   case (CbxGame.ItemIndex) of
      1: TempPalettes[PLOP_RA1INT] := Terrain3Palette.ItemIndex;
      3: TempPalettes[PLOP_RA2URB] := Terrain3Palette.ItemIndex;
   end;
end;

end.
