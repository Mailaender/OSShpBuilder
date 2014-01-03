unit FormReplaceColour;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,math, StdCtrls,shp_file,shp_engine,palette,
  Shp_Engine_Image, ComCtrls, SHP_Shadows, Spin, Undo_Redo,SHP_DataMatrix,
  CheckLst, SHP_ColourNumber_List,Colour_list,SHP_Engine_CCMs, XPMan;

type
  TfrmReplaceColour = class(TForm)
    Panel1: TPanel;
    cnvPalette: TPaintBox;
    PanC1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PanW1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    LabC01: TLabel;
    LabW01: TLabel;
    PanC2: TPanel;
    PanW2: TPanel;
    LabC02: TLabel;
    LabW02: TLabel;
    PanC3: TPanel;
    PanW3: TPanel;
    LabC03: TLabel;
    LabW03: TLabel;
    PanC4: TPanel;
    PanW4: TPanel;
    LabC04: TLabel;
    LabW04: TLabel;
    PanC5: TPanel;
    PanW5: TPanel;
    LabC05: TLabel;
    LabW05: TLabel;
    ApplyToAll: TCheckBox;
    ProgressBar1: TProgressBar;
    LabelL1: TLabel;
    LabelL2: TLabel;
    LabelL3: TLabel;
    SpeFrom: TSpinEdit;
    SpeTo: TSpinEdit;
    PanC6: TPanel;
    PanW6: TPanel;
    PanC7: TPanel;
    PanW7: TPanel;
    PanC8: TPanel;
    PanW8: TPanel;
    PanC9: TPanel;
    PanW9: TPanel;
    PanC10: TPanel;
    PanW10: TPanel;
    PanC11: TPanel;
    PanW11: TPanel;
    PanC12: TPanel;
    PanW12: TPanel;
    PanC13: TPanel;
    PanW13: TPanel;
    PanC14: TPanel;
    PanW14: TPanel;
    PanC15: TPanel;
    PanW15: TPanel;
    PanC16: TPanel;
    PanW16: TPanel;
    PanC17: TPanel;
    PanW17: TPanel;
    PanC18: TPanel;
    PanW18: TPanel;
    LabC06: TLabel;
    LabW06: TLabel;
    LabC07: TLabel;
    LabW07: TLabel;
    LabC08: TLabel;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    LabW08: TLabel;
    LabC09: TLabel;
    LabW09: TLabel;
    LabC10: TLabel;
    LabW10: TLabel;
    LabC11: TLabel;
    LabW11: TLabel;
    LabC12: TLabel;
    LabW12: TLabel;
    LabC13: TLabel;
    LabW13: TLabel;
    LabC14: TLabel;
    LabW14: TLabel;
    LabC15: TLabel;
    LabW15: TLabel;
    LabC17: TLabel;
    LabW17: TLabel;
    LabC18: TLabel;
    LabW18: TLabel;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    LabC16: TLabel;
    LabW16: TLabel;
    GroupBox1: TGroupBox;
    ropUSC: TRadioButton;
    rop24BCE: TRadioButton;
    ropPC: TRadioButton;
    TopLabel: TLabel;
    GroupBox2: TGroupBox;
    RRselectedonly: TCheckBox;
    USCGroup: TGroupBox;
    BCEGroup: TGroupBox;
    SpinRed: TSpinEdit;
    SpinGreen: TSpinEdit;
    SpinBlue: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CCMGroup: TGroupBox;
    CCM3DRGBColourPlus: TRadioButton;
    CCM3DRGBFD: TRadioButton;
    Panel2: TPanel;
    cnvPreview24B: TPaintBox;
    CTSGroup: TGroupBox;
    AddCTS: TButton;
    RemoveCTS: TButton;
    SpareColourPanel: TPanel;
    SpareColourLabel: TLabel;
    SpinCTS: TSpinEdit;
    Label3: TLabel;
    Label7: TLabel;
    ColoursToSpareList: TListBox;
    PCGroup: TGroupBox;
    Label8: TLabel;
    Button3: TButton;
    FilenameText: TEdit;
    OpenPalette: TOpenDialog;
    AutoProof: TCheckBox;
    CCMStructuralis: TRadioButton;
    XPManifest: TXPManifest;
    procedure cnvPalettePaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure lowerpannels;
    procedure PanW1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure ApplyToAllClick(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure CheckBox11Click(Sender: TObject);
    procedure CheckBox12Click(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
    procedure CheckBox14Click(Sender: TObject);
    procedure CheckBox15Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure CheckBox17Click(Sender: TObject);
    procedure CheckBox18Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ShowOrHide;
    procedure ropUSCClick(Sender: TObject);
    procedure rop24BCEClick(Sender: TObject);
    procedure ropPCClick(Sender: TObject);
    procedure SpinRedChange(Sender: TObject);
    procedure cnvPreview24BPaint(Sender: TObject);
    procedure AddCTSClick(Sender: TObject);
    procedure RemoveCTSClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    function IsAnyOptionChecked : Boolean;
    procedure FilenameTextChange(Sender: TObject);
    procedure Proof;
  private
    { Private declarations }
    procedure InitComponents;
  public
    { Public declarations }
    replacecolour : byte;
    PaletteMax : word;
    Data : TSHPImageData;
    Top:TColourID;
  end;

implementation

uses FormMain;


{$R *.dfm}

procedure TfrmReplaceColour.ShowOrHide;
begin
   USCGroup.Visible := ropUSC.Checked;
   BCEGroup.Visible := rop24BCE.Checked;
   Panel2.Visible := rop24BCE.Checked;
   CCMGroup.Visible := not ropUSC.Checked;
   CTSGroup.Visible := not ropUSC.Checked;
   PCGroup.Visible := ropPC.Checked;
end;


//---------------------------------------------
// Init Components
//---------------------------------------------
procedure TfrmReplaceColour.InitComponents;
begin
  PanC1.ParentBackground := false;
  PanW1.ParentBackground := false;
  PanC2.ParentBackground := false;
  PanW2.ParentBackground := false;
  PanC3.ParentBackground := false;
  PanW3.ParentBackground := false;
  PanC4.ParentBackground := false;
  PanW4.ParentBackground := false; 
  PanC5.ParentBackground := false;
  PanW5.ParentBackground := false;
  PanC6.ParentBackground := false;
  PanW6.ParentBackground := false;
  PanC7.ParentBackground := false;
  PanW7.ParentBackground := false;
  PanC8.ParentBackground := false;
  PanW8.ParentBackground := false;
  PanC9.ParentBackground := false;
  PanW9.ParentBackground := false;
  PanC10.ParentBackground := false;
  PanW10.ParentBackground := false;
  PanC11.ParentBackground := false;
  PanW11.ParentBackground := false;
  PanC12.ParentBackground := false;
  PanW12.ParentBackground := false;
  PanC13.ParentBackground := false;
  PanW13.ParentBackground := false;
  PanC14.ParentBackground := false;
  PanW14.ParentBackground := false;
  PanC15.ParentBackground := false;
  PanW15.ParentBackground := false;
  PanC16.ParentBackground := false;
  PanW16.ParentBackground := false;
  PanC17.ParentBackground := false;
  PanW17.ParentBackground := false;
  PanC18.ParentBackground := false;
  PanW18.ParentBackground := false;
end;


procedure TfrmReplaceColour.lowerpannels;
begin
   PanC1.BevelOuter := bvLowered; 
   PanW1.BevelOuter := bvLowered; 
   PanC2.BevelOuter := bvLowered; 
   PanW2.BevelOuter := bvLowered; 
   PanC3.BevelOuter := bvLowered; 
   PanW3.BevelOuter := bvLowered; 
   PanC4.BevelOuter := bvLowered; 
   PanW4.BevelOuter := bvLowered; 
   PanC5.BevelOuter := bvLowered; 
   PanW5.BevelOuter := bvLowered; 
   PanC6.BevelOuter := bvLowered; 
   PanW6.BevelOuter := bvLowered; 
   PanC7.BevelOuter := bvLowered; 
   PanW7.BevelOuter := bvLowered; 
   PanC8.BevelOuter := bvLowered; 
   PanW8.BevelOuter := bvLowered; 
   PanC9.BevelOuter := bvLowered; 
   PanW9.BevelOuter := bvLowered; 
   PanC10.BevelOuter := bvLowered;
   PanW10.BevelOuter := bvLowered;
   PanC11.BevelOuter := bvLowered;
   PanW11.BevelOuter := bvLowered;
   PanC12.BevelOuter := bvLowered;
   PanW12.BevelOuter := bvLowered;
   PanC13.BevelOuter := bvLowered;
   PanW13.BevelOuter := bvLowered;
   PanC14.BevelOuter := bvLowered;
   PanW14.BevelOuter := bvLowered;
   PanC15.BevelOuter := bvLowered;
   PanW15.BevelOuter := bvLowered;
   PanC16.BevelOuter := bvLowered;
   PanW16.BevelOuter := bvLowered;
   PanC17.BevelOuter := bvLowered;
   PanW17.BevelOuter := bvLowered;
   PanC18.BevelOuter := bvLowered;
   PanW18.BevelOuter := bvLowered;
end;

procedure SplitColour(raw: TColor; var red, green, blue: Byte);
begin
     red := (raw and $00FF0000) shr 16;
     green := (raw and $0000FF00) shr 8;
     blue := raw and $000000FF;
end;

function GetColour(const raw: TColor; red, green, blue: smallint):TColor;
var
   red1,green1,blue1:byte;
   c:smallint;
begin
     SplitColour(raw,blue1,green1,red1); // it was supposed to be red1,green1,blue1, but colours get messed up.
     // get red
     c := red1 + red;
     if c > 255 then
        red1:= 255
     else if c < 0 then
        red1:=0
     else
        red1 := c;
     // get green
     c := green1 + green;
     if c > 255 then
        green1:= 255
     else if c < 0 then
        green1:=0
     else
        green1 := c;
     // get blue
     c := blue1 + blue;
     if c > 255 then
        blue1:= 255
     else if c < 0 then
        blue1:=0
     else
        blue1 := c;
     // get colour
     result := RGB(red1,green1,blue1);
end;

procedure TfrmReplaceColour.cnvPalettePaint(Sender: TObject);
var colwidth, rowheight: Real;
    i, j, idx: Integer;
    r: TRect;
begin
     colwidth := cnvPalette.Width / 8;
     rowheight := cnvPalette.Height / 32;
     idx := 0;
     PaletteMax := 256;

//     if IsShadow(Data^.SHP,FrmMain.Current_Frame.Value) then
//     PaletteMax := 2;


     for i := 0 to 8 do begin
         r.Left := Trunc(i * colwidth);
         r.Right := Ceil(r.Left + colwidth);
         for j := 0 to 31 do begin
             r.Top := Trunc(j * rowheight);
             r.Bottom := Ceil(r.Top + rowheight);
             if Idx < PaletteMax then
             with cnvPalette.Canvas do begin

                  Brush.Color := Data^.SHPPalette[idx];
                  FillRect(r);
             end;
             Inc(Idx);
         end;
     end;
end;

procedure TfrmReplaceColour.Proof;
var
   x,y,xstart,xend,ystart,yend : integer;
   r : TRect;
begin
   // Replacement Range Settings:
   if (RRselectedonly.Checked) then
   begin
      xstart := FrmMain.ActiveForm^.Selection.X;
      xend :=  FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width - 1;
      ystart :=  FrmMain.ActiveForm^.Selection.Y;
      yend :=   FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height - 1;
   end
   else
   begin
      xstart := 0;
      ystart := 0;
      xend := Data^.SHP.Header.Width -1;
      yend := Data^.SHP.Header.Height -1;
   end;

   for y := 0 to (yend-ystart) do
   begin
      r.Top := Trunc(y * FrmMain.ActiveForm^.Zoom);
      r.Bottom := Ceil(r.Top + FrmMain.ActiveForm^.Zoom);
      for x:= 0 to (xend-xstart) do
      begin
         r.Left := Trunc(x * FrmMain.ActiveForm^.Zoom);
         r.Right := Ceil(r.Left + FrmMain.ActiveForm^.Zoom);
         if not IsColourInColourIDList(Top,Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+xstart,y+ystart]) then
         begin
         with FrmMain.ActiveForm^.Image1.Canvas do begin
            Brush.Color := GetColour(Data^.SHPPalette[Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+xstart,y+ystart]],strtointdef(SpinRed.Text,0),strtointdef(SpinGreen.Text,0),strtointdef(SpinBlue.Text,0));
            FillRect(r);
         end;
         end
         else
         with FrmMain.ActiveForm^.Image1.Canvas do begin
            Brush.Color := Data^.SHPPalette[Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+xstart,y+ystart]];
            FillRect(r);
         end;
      end;
   end;
end;


procedure TfrmReplaceColour.Button1Click(Sender: TObject);
var
   x,y,xstart,xend,ystart,yend,Frame,FS,FE : integer;
   count,ccm:byte;
   List,Last:listed_colour;
   colours: TCache;
   NewPalette:TPalette;
   HasRemaps: boolean;
begin

   // Detect Start and End
   if SpeFrom.Value <= SpeTo.Value then
   begin
      FS := SpeFrom.Value;
      FE := SpeTo.Value;
   end
   else
   begin
      FE := SpeFrom.Value;
      FS := SpeTo.Value;
   end;

   // Replacement Range Settings:
   if (RRselectedonly.Checked) then
   begin
      xstart := FrmMain.ActiveForm^.Selection.X;
      xend :=  FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width - 1;
      ystart :=  FrmMain.ActiveForm^.Selection.Y;
      yend :=   FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height - 1;
   end
   else
   begin
      xstart := 0;
      ystart := 0;
      xend := Data^.SHP.Header.Width -1;
      yend := Data^.SHP.Header.Height -1;
   end;

   // Progress Bar Reseting
   ProgressBar1.Position := FS;
   ProgressBar1.MAX := FE;
   ProgressBar1.Visible := true;

   // Normal Colour Replacement Code Goes Here
   if ropUSC.Checked then
   begin

      // Generate Cache
      for count := 0 to 255 do
         colours[count] := count;

      // Cache selected colours
      if CheckBox1.Checked then
         colours[strtoint(LabC01.caption)] := strtoint(LabW01.caption);
      if CheckBox2.Checked then
         colours[strtoint(LabC02.caption)] := strtoint(LabW02.caption);
      if CheckBox3.Checked then
         colours[strtoint(LabC03.caption)] := strtoint(LabW03.caption);
      if CheckBox4.Checked then
         colours[strtoint(LabC04.caption)] := strtoint(LabW04.caption);
      if CheckBox5.Checked then
         colours[strtoint(LabC05.caption)] := strtoint(LabW05.caption);
      if CheckBox6.Checked then
         colours[strtoint(LabC06.caption)] := strtoint(LabW06.caption);
      if CheckBox7.Checked then
         colours[strtoint(LabC07.caption)] := strtoint(LabW07.caption);
      if CheckBox8.Checked then
         colours[strtoint(LabC08.caption)] := strtoint(LabW08.caption);
      if CheckBox9.Checked then
         colours[strtoint(LabC09.caption)] := strtoint(LabW09.caption);
      if CheckBox10.Checked then
         colours[strtoint(LabC10.caption)] := strtoint(LabW10.caption);
      if CheckBox11.Checked then
         colours[strtoint(LabC11.caption)] := strtoint(LabW11.caption);
      if CheckBox12.Checked then
         colours[strtoint(LabC12.caption)] := strtoint(LabW12.caption);
      if CheckBox13.Checked then
         colours[strtoint(LabC13.caption)] := strtoint(LabW13.caption);
      if CheckBox14.Checked then
         colours[strtoint(LabC14.caption)] := strtoint(LabW14.caption);
      if CheckBox15.Checked then
         colours[strtoint(LabC15.caption)] := strtoint(LabW15.caption);
      if CheckBox16.Checked then
         colours[strtoint(LabC16.caption)] := strtoint(LabW16.caption);
      if CheckBox17.Checked then
         colours[strtoint(LabC17.caption)] := strtoint(LabW17.caption);
      if CheckBox18.Checked then
         colours[strtoint(LabC18.caption)] := strtoint(LabW18.caption);


   end // Color Replacement Code Ends Here.
   else if rop24BCE.Checked then
   begin
      // Generate Cache
      GenerateColourList(Data^.SHPPalette,List,Last,Data^.SHPPalette[0],true,false,false);

      // Set alg
      {if CCMAutoSelect.Checked then
         ccm := 4
      else if CCMRGBFirst.Checked then
         ccm := 1
      else if CCMRGBAdvDiff.Checked then
         ccm := 2
      else if CCMRGBDiff.Checked then
         ccm := 3
      else} if CCM3DRGBFD.Checked then
         ccm := 4
      else if CCM3DRGBColourPlus.Checked then
         ccm := 5
      else // if CCMStructuralis.Checked then
         ccm := 7;

      for count := 0 to 255 do
         if not IsColourInColourIDList(Top,count) then
            colours[count] := LoadPixel(List,Last,ccm,GetColour(Data^.SHPPalette[count],SpinRed.Value,SpinGreen.Value,SpinBlue.Value))
         else // colours to spare
            colours[count] := count;
   end
   else
   begin
      // Generate Cache
      GenerateColourList(Data^.SHPPalette,List,Last,Data^.SHPPalette[0],true,false,false);

      // Set alg
      {if CCMAutoSelect.Checked then
         ccm := 0
      else if CCMRGBFirst.Checked then
         ccm := 1
      else if CCMRGBAdvDiff.Checked then
         ccm := 2
      else if CCMRGBDiff.Checked then
         ccm := 3
      else} if CCM3DRGBFD.Checked then
         ccm := 4
      else if CCM3DRGBColourPlus.Checked then
         ccm := 5
      else // if CCMStructuralis.Checked then
         ccm := 7;

      if not fileexists(FilenameText.Text) then exit;
      LoadAnyPaletteFromFile(FilenameText.Text,NewPalette);
      if Data^.SHP.SHPType in [stUnit, stBuilding, sttem, stsno, sturb, stlun, stdes, stnewurb, stint, stwin] then
         HasRemaps := true
      else
         HasRemaps := false;

      if (Data^.SHP.SHPGame = sgTD) or (Data^.SHP.SHPGame = sgRA1) then
         GeneratePaletteCache(Data^.SHPPalette,NewPalette,colours,ccm,1,Data^.SHP.SHPGame,HasRemaps)
      else
         GeneratePaletteCache(Data^.SHPPalette,NewPalette,colours,ccm,2,Data^.SHP.SHPGame,HasRemaps);

      // colours to spare
      for count := 0 to 255 do
         if IsColourInColourIDList(Top,count) then
            colours[count] := count;
   end;

   GenerateNewUndoItem(Data^.UndoList);
   // Recolour Image
   for Frame := FS to FE do
   begin
      ProgressBar1.Position := Frame;
      //ProgressBar1.Refresh;
      for x := xstart to xend do
         for y := ystart to yend do
         begin
            if (Data^.SHP.Data[Frame].FrameImage[x,y] <> colours[Data^.SHP.Data[Frame].FrameImage[x,y]]) then
            begin
               AddToUndoMultiFrames(Data^.UndoList,Frame,x,y,Data^.SHP.Data[Frame].FrameImage[x,y]);
               Data^.SHP.Data[Frame].FrameImage[x,y] := colours[Data^.SHP.Data[Frame].FrameImage[x,y]];
            end;
         end;
   end;
   NewUndoItemValidation(Data^.UndoList);
   FrmMain.UndoUpdate(Data^.UndoList);
   FrmMain.RefreshAll;

   Close;
end;

procedure TfrmReplaceColour.FormShow(Sender: TObject);
var
   x:byte;
begin
  InitComponents;

  // Default Ranges
   SpeFrom.Value := FrmMain.ActiveForm^.FrameIndex;
   SpeTo.Value := FrmMain.ActiveForm^.FrameIndex;
   SpeTo.MaxValue := Data^.SHP.Header.NumImages;
   SpeFrom.MaxValue := SpeTo.MaxValue;
   // Colours...
   Button1.Enabled := false;
   PanC1.Color := Data^.SHPPalette[FrmMain.ActiveForm^.ActiveColour];
   replacecolour := FrmMain.ActiveForm^.ActiveColour;
   LabC01.caption := ''+inttostr(FrmMain.ActiveForm^.ActiveColour);
   PanW1.Color := Data^.SHPPalette[0];
   LabW01.caption := ''+inttostr(0);
   SpareColourPanel.Color := Data^.SHPPalette[0];
   SpareColourLabel.Caption := '#'+inttostr(0);
   // Apply To All Default Value
   ApplyToAll.Checked := false;
   // Default Instruction
   TopLabel.Caption := 'Select a colour form the left for the replace colour and then the replace with colour';
   // Selected Only?
   RRselectedonly.Checked := FrmMain.ActiveForm^.Selection.Width > 0;
   RRselectedonly.Enabled := RRselectedonly.Checked;

   // Speed Up 24 Bit Effects Preview.
   Panel2.DoubleBuffered := true;
   // 3.31: Paint Preview image
   cnvPreview24BPaint(nil);
   // Check CCMs.
   case (FrmMain.alg) of
     1: CCMStructuralis.Checked := true;
     2: CCMStructuralis.Checked := true;
     3: CCMStructuralis.Checked := true;
     4: CCM3DRGBFD.Checked := true;
     5: CCM3DRGBColourPlus.Checked := true;
     7: CCMStructuralis.Checked := true;
   else
      CCMStructuralis.Checked := true;
   end;
   // Default Colours To Spare Values
   InitializeColourID(Top);
   if not IsCameoPalette(Data^.SHPPaletteFilename) then
   begin
      ColoursToSpareList.Items.Add(IntToStr(0));
      AddColourID(Top,0);
   end;
   if IsUnitXPalette(Data^.SHPPaletteFilename) then
   begin
      if IsRA2Palette(Data^.SHPPaletteFilename) then
      begin
         ColoursToSpareList.Items.Add(IntToStr(12));
         AddColourID(Top,12);
      end;
      // Add remappables
      for x := 16 to 31 do
      begin
         ColoursToSpareList.Items.Add(IntToStr(x));
         AddColourID(Top,x);
      end;
   end
   else if (Data^.SHP.SHPGame = sgTD) and (Data^.SHP.SHPType <> stAnimation) and (Data^.SHP.SHPType <> stCameo) then
   begin
      // Add TD shadows.
      ColoursToSpareList.Items.Add(IntToStr(4));
      AddColourID(Top,4);
      // Add remappables
      for x := 176 to 191 do
      begin
         ColoursToSpareList.Items.Add(IntToStr(x));
         AddColourID(Top,x);
      end;
   end
   else if (Data^.SHP.SHPGame = sgRA1) and (Data^.SHP.SHPType <> stAnimation) and (Data^.SHP.SHPType <> stCameo) then
   begin
      // Add RA1 shadows.
      ColoursToSpareList.Items.Add(IntToStr(4));
      AddColourID(Top,4);
      // Add remappables
      for x := 80 to 95 do
      begin
         ColoursToSpareList.Items.Add(IntToStr(x));
         AddColourID(Top,x);
      end;
   end;

   ColoursToSpareList.ItemIndex := 0;
   // Add Initial Dir For Palettes
   OpenPalette.InitialDir := extractfiledir(ParamStr(0))+'\Palettes\';
end;

procedure TfrmReplaceColour.cnvPaletteMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var colwidth, rowheight: Real;
    i, j, idx: Integer;
begin
     if not ropUSC.Checked then
     begin
        colwidth := cnvPalette.Width / 8;
        rowheight := cnvPalette.Height / 32;
        i := Trunc(X / colwidth);
        j := Trunc(Y / rowheight);
        idx := (i * 32) + j;
        if idx < PaletteMax then
        begin
           SpareColourPanel.Color := Data^.SHPPalette[idx];
           SpareColourLabel.Caption := '#' + IntToStr(idx);
        end;
     end
     else
     begin
        colwidth := cnvPalette.Width / 8;
        rowheight := cnvPalette.Height / 32;
        i := Trunc(X / colwidth);
        j := Trunc(Y / rowheight);
        idx := (i * 32) + j;
        if idx < PaletteMax then
        begin
           if PanC1.BevelOuter = bvRaised then
              PanC1.Color := Data^.SHPPalette[idx];
           if PanW1.BevelOuter = bvRaised then
              PanW1.Color := Data^.SHPPalette[idx];
           if PanC2.BevelOuter = bvRaised then
              PanC2.Color := Data^.SHPPalette[idx];
           if PanW2.BevelOuter = bvRaised then
              PanW2.Color := Data^.SHPPalette[idx];
           if PanC3.BevelOuter = bvRaised then
              PanC3.Color := Data^.SHPPalette[idx];
           if PanW3.BevelOuter = bvRaised then
              PanW3.Color := Data^.SHPPalette[idx];
           if PanC4.BevelOuter = bvRaised then
              PanC4.Color := Data^.SHPPalette[idx];
           if PanW4.BevelOuter = bvRaised then
              PanW4.Color := Data^.SHPPalette[idx];
           if PanC5.BevelOuter = bvRaised then
              PanC5.Color := Data^.SHPPalette[idx];
           if PanW5.BevelOuter = bvRaised then
              PanW5.Color := Data^.SHPPalette[idx];
           if PanC6.BevelOuter = bvRaised then
              PanC6.Color := Data^.SHPPalette[idx];
           if PanW6.BevelOuter = bvRaised then
              PanW6.Color := Data^.SHPPalette[idx];
           if PanC7.BevelOuter = bvRaised then
              PanC7.Color := Data^.SHPPalette[idx];
           if PanW7.BevelOuter = bvRaised then
              PanW7.Color := Data^.SHPPalette[idx];
           if PanC8.BevelOuter = bvRaised then
              PanC8.Color := Data^.SHPPalette[idx];
           if PanW8.BevelOuter = bvRaised then
              PanW8.Color := Data^.SHPPalette[idx];
           if PanC9.BevelOuter = bvRaised then
              PanC9.Color := Data^.SHPPalette[idx];
           if PanW9.BevelOuter = bvRaised then
              PanW9.Color := Data^.SHPPalette[idx];
           if PanC10.BevelOuter = bvRaised then
              PanC10.Color := Data^.SHPPalette[idx];
           if PanW10.BevelOuter = bvRaised then
              PanW10.Color := Data^.SHPPalette[idx];
           if PanC11.BevelOuter = bvRaised then
              PanC11.Color := Data^.SHPPalette[idx];
           if PanW11.BevelOuter = bvRaised then
              PanW11.Color := Data^.SHPPalette[idx];
           if PanC12.BevelOuter = bvRaised then
              PanC12.Color := Data^.SHPPalette[idx];
           if PanW12.BevelOuter = bvRaised then
              PanW12.Color := Data^.SHPPalette[idx];
           if PanC13.BevelOuter = bvRaised then
              PanC13.Color := Data^.SHPPalette[idx];
           if PanW13.BevelOuter = bvRaised then
              PanW13.Color := Data^.SHPPalette[idx];
           if PanC14.BevelOuter = bvRaised then
              PanC14.Color := Data^.SHPPalette[idx];
           if PanW14.BevelOuter = bvRaised then
              PanW14.Color := Data^.SHPPalette[idx];
           if PanC15.BevelOuter = bvRaised then
              PanC15.Color := Data^.SHPPalette[idx];
           if PanW15.BevelOuter = bvRaised then
              PanW15.Color := Data^.SHPPalette[idx];
           if PanC16.BevelOuter = bvRaised then
              PanC16.Color := Data^.SHPPalette[idx];
           if PanW16.BevelOuter = bvRaised then
              PanW16.Color := Data^.SHPPalette[idx];
           if PanC17.BevelOuter = bvRaised then
              PanC17.Color := Data^.SHPPalette[idx];
           if PanW17.BevelOuter = bvRaised then
              PanW17.Color := Data^.SHPPalette[idx];
           if PanC18.BevelOuter = bvRaised then
              PanC18.Color := Data^.SHPPalette[idx];
           if PanW18.BevelOuter = bvRaised then
              PanW18.Color := Data^.SHPPalette[idx];
           replacecolour := idx;
        end;

        if PanC1.BevelOuter = bvRaised then
        begin
           LabC01.caption := ''+inttostr(replacecolour);
           if (LabW01.caption <> '') then
              CheckBox1.Checked := true;
        end
        else if PanW1.BevelOuter = bvRaised then
        begin
           LabW01.caption := ''+inttostr(replacecolour);
           if (LabC01.caption <> '') then
              CheckBox1.Checked := true;
        end
        else if PanC2.BevelOuter = bvRaised then
        begin
           LabC02.caption := ''+inttostr(replacecolour);
           if (LabW02.caption <> '') then
              CheckBox2.Checked := true;
        end
        else if PanW2.BevelOuter = bvRaised then
        begin
           LabW02.caption := ''+inttostr(replacecolour);
           if (LabC02.caption <> '') then
              CheckBox2.Checked := true;
        end
        else if PanC3.BevelOuter = bvRaised then
        begin
           LabC03.caption := ''+inttostr(replacecolour);
           if (LabW03.caption <> '') then
              CheckBox3.Checked := true;
        end
        else if PanW3.BevelOuter = bvRaised then
        begin
           LabW03.caption := ''+inttostr(replacecolour);
           if (LabC03.caption <> '') then
              CheckBox3.Checked := true;
        end
        else if PanC4.BevelOuter = bvRaised then
        begin
           LabC04.caption := ''+inttostr(replacecolour);
           if (LabW04.caption <> '') then
              CheckBox4.Checked := true;
        end
        else if PanW4.BevelOuter = bvRaised then
        begin
           LabW04.caption := ''+inttostr(replacecolour);
           if (LabC04.caption <> '') then
              CheckBox4.Checked := true;
        end
        else if PanC5.BevelOuter = bvRaised then
        begin
           LabC05.caption := ''+inttostr(replacecolour);
           if (LabW05.caption <> '') then
              CheckBox5.Checked := true;
        end
        else if PanW5.BevelOuter = bvRaised then
        begin
           LabW05.caption := ''+inttostr(replacecolour);
           if (LabC05.caption <> '') then
              CheckBox5.Checked := true;
        end
        else if PanC6.BevelOuter = bvRaised then
        begin
           LabC06.caption := ''+inttostr(replacecolour);
           if (LabW06.caption <> '') then
              CheckBox6.Checked := true;
        end
        else if PanW6.BevelOuter = bvRaised then
        begin
           LabW06.caption := ''+inttostr(replacecolour);
           if (LabC06.caption <> '') then
              CheckBox6.Checked := true;
        end
        else if PanC7.BevelOuter = bvRaised then
        begin
           LabC07.caption := ''+inttostr(replacecolour);
           if (LabW07.caption <> '') then
              CheckBox7.Checked := true;
        end
        else if PanW7.BevelOuter = bvRaised then
        begin
           LabW07.caption := ''+inttostr(replacecolour);
           if (LabC07.caption <> '') then
              CheckBox7.Checked := true;
        end
        else if PanC8.BevelOuter = bvRaised then
        begin
           LabC08.caption := ''+inttostr(replacecolour);
           if (LabW08.caption <> '') then
              CheckBox8.Checked := true;
        end
        else if PanW8.BevelOuter = bvRaised then
        begin
           LabW08.caption := ''+inttostr(replacecolour);
           if (LabC08.caption <> '') then
              CheckBox8.Checked := true;
        end
        else if PanC9.BevelOuter = bvRaised then
        begin
           LabC09.caption := ''+inttostr(replacecolour);
           if (LabW09.caption <> '') then
              CheckBox9.Checked := true;
        end
        else if PanW9.BevelOuter = bvRaised then
        begin
           LabW09.caption := ''+inttostr(replacecolour);
           if (LabC09.caption <> '') then
              CheckBox9.Checked := true;
        end
        else if PanC10.BevelOuter = bvRaised then
        begin
           LabC10.caption := ''+inttostr(replacecolour);
           if (LabW10.caption <> '') then
              CheckBox10.Checked := true;
        end
        else if PanW10.BevelOuter = bvRaised then
        begin
           LabW10.caption := ''+inttostr(replacecolour);
           if (LabC10.caption <> '') then
              CheckBox10.Checked := true;
        end
        else if PanC11.BevelOuter = bvRaised then
        begin
           LabC11.caption := ''+inttostr(replacecolour);
           if (LabW11.caption <> '') then
              CheckBox11.Checked := true;
        end
        else if PanW11.BevelOuter = bvRaised then
        begin
           LabW11.caption := ''+inttostr(replacecolour);
           if (LabC11.caption <> '') then
              CheckBox11.Checked := true;
        end
        else if PanC12.BevelOuter = bvRaised then
        begin
           LabC12.caption := ''+inttostr(replacecolour);
           if (LabW12.caption <> '') then
              CheckBox12.Checked := true;
        end
        else if PanW12.BevelOuter = bvRaised then
        begin
           LabW12.caption := ''+inttostr(replacecolour);
           if (LabC12.caption <> '') then
              CheckBox12.Checked := true;
        end
        else if PanC13.BevelOuter = bvRaised then
        begin
           LabC13.caption := ''+inttostr(replacecolour);
           if (LabW13.caption <> '') then
              CheckBox13.Checked := true;
        end
        else if PanW13.BevelOuter = bvRaised then
        begin
           LabW13.caption := ''+inttostr(replacecolour);
           if (LabC13.caption <> '') then
              CheckBox13.Checked := true;
        end
        else if PanC14.BevelOuter = bvRaised then
        begin
           LabC14.caption := ''+inttostr(replacecolour);
           if (LabW14.caption <> '') then
              CheckBox14.Checked := true;
        end
        else if PanW14.BevelOuter = bvRaised then
        begin
           LabW14.caption := ''+inttostr(replacecolour);
           if (LabC14.caption <> '') then
              CheckBox14.Checked := true;
        end
        else if PanC15.BevelOuter = bvRaised then
        begin
           LabC15.caption := ''+inttostr(replacecolour);
           if (LabW15.caption <> '') then
              CheckBox15.Checked := true;
        end
        else if PanW15.BevelOuter = bvRaised then
        begin
           LabW15.caption := ''+inttostr(replacecolour);
           if (LabC15.caption <> '') then
              CheckBox15.Checked := true;
        end
        else if PanC16.BevelOuter = bvRaised then
        begin
           LabC16.caption := ''+inttostr(replacecolour);
           if (LabW16.caption <> '') then
              CheckBox16.Checked := true;
        end
        else if PanW16.BevelOuter = bvRaised then
        begin
           LabW16.caption := ''+inttostr(replacecolour);
           if (LabC16.caption <> '') then
              CheckBox16.Checked := true;
        end
        else if PanC17.BevelOuter = bvRaised then
        begin
           LabC17.caption := ''+inttostr(replacecolour);
           if (LabW17.caption <> '') then
              CheckBox17.Checked := true;
        end
        else if PanW17.BevelOuter = bvRaised then
        begin
           LabW17.caption := ''+inttostr(replacecolour);
           if (LabC17.caption <> '') then
              CheckBox17.Checked := true;
        end
        else if PanC18.BevelOuter = bvRaised then
        begin
           LabC18.caption := ''+inttostr(replacecolour);
           if (LabW18.caption <> '') then
              CheckBox18.Checked := true;
        end
        else if PanW18.BevelOuter = bvRaised then
        begin
           LabW18.caption := ''+inttostr(replacecolour);
           if (LabC18.caption <> '') then
              CheckBox18.Checked := true;
        end;
     end;
end;

procedure TfrmReplaceColour.Button2Click(Sender: TObject);
begin
   close;
end;

procedure TfrmReplaceColour.PanW1Click(Sender: TObject);
begin
   lowerpannels;
   tpanel(sender).BevelOuter := bvRaised;
end;

procedure TfrmReplaceColour.CheckBox1Click(Sender: TObject);
begin
   if (LabC01.caption = '') or (LabW01.caption = '') then
      CheckBox1.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox2Click(Sender: TObject);
begin
   if (LabC02.caption = '') or (LabW02.caption = '') then
      CheckBox2.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox3Click(Sender: TObject);
begin
   if (LabC03.caption = '') or (LabW03.caption = '') then
      CheckBox3.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox4Click(Sender: TObject);
begin
   if (LabC04.caption = '') or (LabW04.caption = '') then
      CheckBox4.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox5Click(Sender: TObject);
begin
   if (LabC05.caption = '') or (LabW05.caption = '') then
      CheckBox5.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox6Click(Sender: TObject);
begin
   if (LabC06.caption = '') or (LabW06.caption = '') then
      CheckBox6.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox7Click(Sender: TObject);
begin
   if (LabC07.caption = '') or (LabW07.caption = '') then
      CheckBox7.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox8Click(Sender: TObject);
begin
   if (LabC08.caption = '') or (LabW08.caption = '') then
      CheckBox8.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox9Click(Sender: TObject);
begin
   if (LabC09.caption = '') or (LabW09.caption = '') then
      CheckBox9.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox10Click(Sender: TObject);
begin
   if (LabC10.caption = '') or (LabW10.caption = '') then
      CheckBox10.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox11Click(Sender: TObject);
begin
   if (LabC11.caption = '') or (LabW11.caption = '') then
      CheckBox11.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox12Click(Sender: TObject);
begin
   if (LabC12.caption = '') or (LabW12.caption = '') then
      CheckBox12.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox13Click(Sender: TObject);
begin
   if (LabC13.caption = '') or (LabW13.caption = '') then
      CheckBox13.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox14Click(Sender: TObject);
begin
   if (LabC14.caption = '') or (LabW14.caption = '') then
      CheckBox14.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox15Click(Sender: TObject);
begin
   if (LabC15.caption = '') or (LabW15.caption = '') then
      CheckBox15.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox16Click(Sender: TObject);
begin
   if (LabC16.caption = '') or (LabW16.caption = '') then
      CheckBox16.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox17Click(Sender: TObject);
begin
   if (LabC17.caption = '') or (LabW17.caption = '') then
      CheckBox17.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.CheckBox18Click(Sender: TObject);
begin
   if (LabC18.caption = '') or (LabW18.caption = '') then
      CheckBox18.Checked := false;
   Button1.Enabled := IsAnyOptionChecked;
end;

procedure TfrmReplaceColour.ApplyToAllClick(Sender: TObject);
begin
   if ApplyToAll.Checked then
   begin
      SpeFrom.Value := 1;
      SpeTo.Value := Data^.SHP.Header.NumImages;
   end;
end;

procedure TfrmReplaceColour.ropUSCClick(Sender: TObject);
begin
   ShowOrHide;
   TopLabel.Caption := 'Select a colour form the left for the replace colour and then the replace with colour';
   Button1.Enabled := IsAnyOptionChecked;
   RRselectedonly.Enabled := FrmMain.ActiveForm^.Selection.Width > 0;
   FrmMain.ActiveForm^.RefreshImage;
end;

procedure TfrmReplaceColour.rop24BCEClick(Sender: TObject);
begin
   ShowOrHide;
   TopLabel.Caption := 'Select an extra ammount for red, green and blue to override the current colours.';
   Button1.Enabled := true;
   RRselectedonly.Enabled := FrmMain.ActiveForm^.Selection.Width > 0;
   // 3.31: Paint Autoproof
   if AutoProof.Checked then
      Proof
   else
      FrmMain.ActiveForm^.RefreshImage;
   // 3.31: Paint Preview image
   cnvPreview24BPaint(nil);
end;

procedure TfrmReplaceColour.ropPCClick(Sender: TObject);
begin
   ShowOrHide;
   TopLabel.Caption := 'Select the palette that the current shp will be converted to.';
   if FilenameText.Text <> '' then
      Button1.Enabled := true
   else
      Button1.Enabled := false;
   RRselectedonly.Enabled := FrmMain.ActiveForm^.Selection.Width > 0;
   FrmMain.ActiveForm^.RefreshImage;
end;


function TfrmReplaceColour.IsAnyOptionChecked : Boolean;
begin
   Result := (CheckBox1.Checked) or (CheckBox2.Checked) or (CheckBox3.Checked) or (CheckBox4.Checked) or (CheckBox5.Checked) or (CheckBox6.Checked) or (CheckBox7.Checked) or (CheckBox8.Checked) or (CheckBox9.Checked) or (CheckBox10.Checked) or (CheckBox11.Checked) or (CheckBox12.Checked) or (CheckBox13.Checked) or (CheckBox14.Checked) or (CheckBox15.Checked) or (CheckBox16.Checked) or (CheckBox17.Checked) or (CheckBox18.Checked);
end;

procedure TfrmReplaceColour.SpinRedChange(Sender: TObject);
begin
   if (((SpinRed.Text <> '') and (SpinGreen.Text <> '')) and (SpinBlue.Text <> '')) then
   begin
      cnvPreview24BPaint(nil);
      if AutoProof.Checked then
         Proof;
   end;
end;

procedure TfrmReplaceColour.cnvPreview24BPaint(Sender: TObject);
var
   x,y,minx,miny,maxx,maxy : word;
   xmult,ymult:real;
   r: TRect;
begin
   if RRselectedonly.Checked then
   begin
      minx := FrmMain.ActiveForm^.Selection.X;
      maxx := FrmMain.ActiveForm^.Selection.X + FrmMain.ActiveForm^.Selection.Width - 1;
      miny := FrmMain.ActiveForm^.Selection.Y;
      maxy := FrmMain.ActiveForm^.Selection.Y + FrmMain.ActiveForm^.Selection.Height - 1;
   end
   else
   begin
      minx := 0;
      miny := 0;
      maxx := Data^.SHP.Header.Width -1;
      maxy := Data^.SHP.Header.Height -1;
   end;

   xmult := 1 / ((maxx - minx) / cnvPreview24B.Width);
   ymult := 1 / ((maxy - miny) / cnvPreview24B.Height);

   for y := 0 to (maxy-miny) do
   begin
      r.Top := Trunc(y * ymult);
      r.Bottom := Ceil(r.Top + ymult);
      for x:= 0 to (maxx-minx) do
      begin
         r.Left := Trunc(x * xmult);
         r.Right := Ceil(r.Left + xmult);
         if not IsColourInColourIDList(Top,Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+minx,y+miny]) then
         begin
         with cnvPreview24B.Canvas do begin
            Brush.Color := GetColour(Data^.SHPPalette[Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+minx,y+miny]],strtointdef(SpinRed.Text,0),strtointdef(SpinGreen.Text,0),strtointdef(SpinBlue.Text,0));
            FillRect(r);
         end;
         end
         else
         with cnvPreview24B.Canvas do begin
            Brush.Color := Data^.SHPPalette[Data^.SHP.Data[FrmMain.ActiveForm^.FrameIndex].FrameImage[x+minx,y+miny]];
            FillRect(r);
         end;
      end;
   end;
end;

function GetByteFromLabel(text:string):byte;
var
   x,res:byte;
begin
   res:=0;
   for x := 2 to length(text) do
   begin
      res := res + (strtointdef(text[x],0) * round(power(10,(length(text) - x))));
   end;
   result := res;
end;

procedure TfrmReplaceColour.AddCTSClick(Sender: TObject);
var
   start,x:byte;
   max:word;
begin
   start := GetByteFromLabel(SpareColourLabel.Caption);
   max := start +  SpinCTS.Value;
   if max > 255 then max := 255;
   for x:= start to max do
      if not IsColourInColourIDList(Top,x) then
      begin
         ColoursToSpareList.Items.Add(IntToStr(x));
         AddColourID(Top,x);
      end;
   ColoursToSpareList.ItemIndex := 0;
end;

procedure TfrmReplaceColour.RemoveCTSClick(Sender: TObject);
var
   x:byte;
   Index,max:word;
begin
   Index := ColoursToSpareList.ItemIndex;
   max := Index + SpinCTS.Value;
   if max > 255 then max := 255;
   if max > (ColoursToSpareList.Count - 1) then max := (ColoursToSpareList.Count - 1);
   for x:= max downto Index do
      if IsColourInColourIDList(Top,StrToInt(ColoursToSpareList.Items.Strings[x])) then
      begin
         RemoveColourID(Top,StrToInt(ColoursToSpareList.Items.Strings[x]));
         ColoursToSpareList.Items.Delete(x);
      end;
   ColoursToSpareList.ItemIndex := 0;
end;

procedure TfrmReplaceColour.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   ClearColourIDTree(Top);
end;

procedure TfrmReplaceColour.Button3Click(Sender: TObject);
begin
   if OpenPalette.Execute then
      FilenameText.Text := OpenPalette.FileName;
end;

procedure TfrmReplaceColour.FilenameTextChange(Sender: TObject);
begin
   Button1.Enabled := true;
end;

end.
