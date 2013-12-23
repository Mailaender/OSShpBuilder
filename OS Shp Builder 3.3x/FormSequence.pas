unit FormSequence;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, Spin, shp_file,Shp_Engine,Shp_Image, palette,
  ExtDlgs, SHP_Image_Save_Load,SHP_Sequence_Animation,SHP_DataMatrix,
  OSExtDlgs, FormGifOptions, XPMan;
type
Tanims = record
        Ready,Guard,Walk,Idle1,Idle2,Prone,Crawl,Die1,Die2,Die3,Die4,Die5,
        FireUp,FireProne,Down,Up{,Deploy},Deployed,DeployedFire,Undeploy,
        Cheer,Panic,Paradrop,Fly,Hover,Tumble,FireFly : Tanimtype;
end;

const
AnimNames : array [1..26] of pchar = ('Ready','Guard','Prone','Down','Crawl','Walk',
        'Up','Idle1','Idle2','Die1','Die2','Die3','Die4','Die5',
        'FireUp','FireProne','Paradrop','Cheer','Panic','Deployed','DeployedFire','Undeploy',
        'Fly','Hover','Tumble','FireFly');

type
PAnimType = ^Tanimtype;
  TFrmSequence = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ScrollBox1: TScrollBox;
    Frame_Image_List: TImage;
    ScrollBox2: TScrollBox;
    Sequence_Image: TImage;
    Panel4: TPanel;
    Panel5: TPanel;
    SaveSequence1: TMenuItem;
    SaveSequencePictureDialog: TSavePictureDialog;
    SaveFrameListAsBMP1: TMenuItem;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    lblTools: TLabel;
    Panel7: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBoxEx1: TComboBoxEx;
    From_Frame: TSpinEdit;
    To_Frame: TSpinEdit;
    Button1: TButton;
    INI_Code: TRichEdit;
    Reset1: TMenuItem;
    N2: TMenuItem;
    Refresh_Timer: TTimer;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    Sequence1: TMenuItem;
    FrameList1: TMenuItem;
    Preview1: TMenuItem;
    SequenceTimer: TTimer;
    OpenASFDialog: TOpenDialog;
    SaveASFDialog: TSaveDialog;
    OpenAnimationSequence1: TMenuItem;
    SaveAnimationSequence1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Options1: TMenuItem;
    Label1: TLabel;
    Panel8: TPanel;
    Label2: TLabel;
    Count2Edit: TSpinEdit;
    Label6: TLabel;
    SpecialEdit: TEdit;
    Button2: TButton;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    XPManifest: TXPManifest;
    procedure ComboBoxEx1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure From_FrameChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveSequence1Click(Sender: TObject);
    procedure SaveFrameListAsBMP1Click(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure Refresh_TimerTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Preview1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SequenceTimerTimer(Sender: TObject);
    procedure SaveAnimationSequence1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OpenAnimationSequence1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure GetSequence3(Var Image : TBitmap; Const SHP:TSHP; Position,ImageWidth : Integer);
    procedure GetSequence4(Var Image : TBitmap; Const SHP:TSHP; StartFrame,EndFrame,Position,ImageWidth : Integer);
  private
    { Private declarations }
  public
    { Public declarations }
 //   Animations : Tanims;
    {Bitmap2}Frame_Bitmap,Sequence_Bitmap : TBitmap;
    Animations2: TAnimations;
    Animations2_no : cardinal;
    AnimationsData : TAnimationsData;
    AnimationsData_no : cardinal;
    Current_Animation :PAnimType;
    SequenceFrame : integer;
    Data : TSHPImageData;
    procedure BuildINI_Code;
    procedure BuildINI_Code_addLine(Name : string; StartFrame,Count,Count2 : integer; Special : String);
    procedure checkforanim(var anim : tanimtype; const num : integer);
    procedure checkforanim2(Name : string);
//    procedure setanim(var anim : tanimtype; const start,count,count2 : integer; special : string);
    procedure setanim2(start,count,count2 : integer);
    procedure GetSequence(Var Image : TImage; Const SHP:TSHP; StartFrame,EndFrame : Integer);
    procedure GetSequence2(Var Image : TBitmap; Const SHP:TSHP; StartFrame,EndFrame : Integer);
    function WorkOutEndFrame : integer;
    procedure setasdf(var anim : tanimtype; const start,count,count2 : integer; special : string);
    Procedure SetupAnimations;
    procedure SequenceSetup;
    procedure FrameSetup;
  end;

var
  FrmSequence: TFrmSequence;

implementation

uses FormMain, FormPreferences;

{$R *.dfm}

procedure TFrmSequence.checkforanim(var anim : tanimtype; const num : integer);
var
   faces : integer;
begin
   if ComboBoxEx1.ItemIndex = num then
   begin
      From_Frame.Value := anim.StartFrame;
      if (anim.count2 = 0) or (anim.count2 = 1) then
         faces := 1
      else if anim.count2 = 6 then
         faces := anim.count2 + 2
      else
         faces := anim.count2;
      To_Frame.Value := From_Frame.Value+((anim.Count)*faces)-1;
      Current_Animation := @Anim;
   end;
end;

procedure TFrmSequence.checkforanim2(name : string);
var
   faces,x : integer;
begin
   if Animations2_no = 0 then exit;

   for x := 1 to Animations2_no do
      if ansilowercase(ComboBoxEx1.Text) = ansilowercase(Animations2[x].Anim_Name) then
      begin
         From_Frame.Value := Animations2[x].anim.StartFrame;

         if (Animations2[x].anim.count2 = 0) or (Animations2[x].anim.count2 = 1) then
            faces := 1
         else if Animations2[x].anim.count2 = 6 then
            faces := Animations2[x].anim.count2 + 2
         else
            faces := Animations2[x].anim.count2;
         To_Frame.Value := From_Frame.Value+((Animations2[x].anim.Count)*faces)-1;

         Count2Edit.Value := Animations2[x].anim.Count2;
         SpecialEdit.Text := copy(Animations2[x].Anim.special,2,length(Animations2[x].Anim.special));

         Current_Animation := @Animations2[x].Anim;
      end;
end;

procedure TFrmSequence.setasdf(var anim : tanimtype; const start,count,count2 : integer; special : string);
begin
   inc(AnimationsData_no);
   Setlength(AnimationsData,AnimationsData_no+1);

   AnimationsData[AnimationsData_no].Anim_Name := AnimNames[AnimationsData_no];
   AnimationsData[AnimationsData_no].Anim.StartFrame := start;
   AnimationsData[AnimationsData_no].Anim.count := count;
   AnimationsData[AnimationsData_no].Anim.count2 := count2;
   AnimationsData[AnimationsData_no].Anim.special := special;
   AnimationsData[AnimationsData_no].Anim.Count2_Editable := false;
   AnimationsData[AnimationsData_no].Anim.Special_Editable := false;
end;

procedure TFrmSequence.setanim2(start,count,count2 : integer);
begin
   Current_Animation.StartFrame := start;
   Current_Animation.count := count;
   Current_Animation.count2 := count2;
end;

procedure TFrmSequence.ComboBoxEx1Change(Sender: TObject);
begin
   SequenceFrame := 0;
   checkforanim2(ComboBoxEx1.Text);

   if (NOT FrmMain.isEditable) or (NOT ScrollBox2.DoubleBuffered) then exit;
      if WorkOutEndFrame > Data^.SHP.Header.NumImages-1 then
         messagebox(0,'Error: Not enough frames for sequence','Frame Error',0)
      else if not Preview1.Checked then
      begin
         SequenceSetup;
      end;
   SequenceFrame := Current_Animation.StartFrame;
end;

function TFrmSequence.WorkOutEndFrame : integer;
var
   faces : cardinal;
begin
   if (Current_Animation.count2 = 0) or (Current_Animation.count2 = 1) then
      faces := 1
   else if Current_Animation.count2 = 6 then
      faces := Current_Animation.count2 + 2
   else
      faces := Current_Animation.count2;
   result := Current_Animation.StartFrame+((Current_Animation.Count)*faces)-1;
end;

Procedure TFrmSequence.SetupAnimations;
var
   x : integer;
begin
   Animations2_no := AnimationsData_no;
   setlength(Animations2,Animations2_no+1);

   for x := 1 to Animations2_no do
   begin
      Animations2[x].Anim.Count := AnimationsData[x].Anim.Count;
      Animations2[x].Anim.Count2 := AnimationsData[x].Anim.Count2;
      Animations2[x].Anim.StartFrame := AnimationsData[x].Anim.StartFrame;
      Animations2[x].Anim.special := AnimationsData[x].Anim.special;
      Animations2[x].Anim_Name := AnimationsData[x].Anim_Name;
   end;
end;

procedure TFrmSequence.FormCreate(Sender: TObject);
var
   AnimationHeader : TAnimHeaderData;
begin
   Animations2_no := 0;
   AnimationsData_no := 0;
   LoadASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);
   AnimationsData_no := AnimationHeader.Anims;

   SetupAnimations; // Reset Animations
   ComboBoxEx1.ItemIndex := 0;

   ScrollBox1.DoubleBuffered := true;
   ScrollBox2.DoubleBuffered := true;
   Sequence_Image.Picture.Bitmap.Canvas.Brush.Color := clBtnFace;
   Frame_Image_List.Picture.Bitmap.Canvas.Brush.Color := clBtnFace;

   Sequence_Bitmap := TBitmap.Create;
   Frame_Bitmap := TBitmap.Create;
end;

procedure TFrmSequence.Button1Click(Sender: TObject);
var
   frames: integer;
begin
   if (Current_Animation.Count2 = 1) or (Current_Animation.Count2 = 0) then
      frames := 1
   else if Current_Animation.Count2 = 6 then
      frames := Current_Animation.Count2+2
   else
      frames := Current_Animation.Count2;

   setanim2(From_Frame.Value,((To_Frame.Value-From_Frame.Value+1) div frames),Current_Animation.Count2);
   ComboBoxEx1Change(Sender); // Make it update
   BuildINI_Code; // Update INI Code
end;

procedure TFrmSequence.From_FrameChange(Sender: TObject);
begin
   To_Frame.MinValue := From_Frame.Value;
   To_Frame.Value := To_Frame.Value; // Makes it update its self and check the value is in the range.
end;

procedure TFrmSequence.FormShow(Sender: TObject);
begin
   // Set max values
   To_Frame.MaxValue := Data^.SHP.Header.NumImages-1;
   From_Frame.MaxValue := To_Frame.MaxValue;

   Refresh_Timer.Enabled := true;

   if Preview1.Checked then
      SequenceTimer.Enabled := true;
   SequenceFrame := 0;
end;

procedure TFrmSequence.GetSequence(Var Image : TImage; Const SHP:TSHP; StartFrame,EndFrame : Integer);
var
   c,cc,x,y,TextHeight : integer;
   Line : PRGB32Array;
   Bitmap,Bitmap2 : TBitmap;
begin
   Image.Picture.Bitmap.PixelFormat := pf32bit;
   TextHeight := 10 + Image.Picture.Bitmap.Canvas.TextHeight('TEST'); // note this means it works with any font the user uses as the defult system font
   Image.Picture.Bitmap.Canvas.Font.Color := clDefault; // Defult colour....

   Bitmap := TBitmap.Create;
   Bitmap.PixelFormat := pf32bit;
   Bitmap2 := TBitmap.Create;

   Bitmap2.Canvas.Brush.Color := clBtnFace;
   Bitmap2.Width := 0;
   Bitmap2.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   Bitmap2.Width := (SHP.Header.Width+3) * (EndFrame+1-StartFrame); // Starting Width
   Bitmap2.Height := SHP.Header.Height+TextHeight;  // Set Height

   Image.Picture.Bitmap.Canvas.Brush.Color := clBtnFace;
   Image.Picture.Bitmap.Width := 0;
   Image.Picture.Bitmap.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   CompressFrameImages(Data^.SHP); // Data gets compressed, should speed this up using the compressed data

   for c := StartFrame+1 to EndFrame +1 do
   begin
      StatusBar1.Panels[0].Text := 'Drawing '+inttostr(c-1) +' Of ' + inttostr(EndFrame);
      StatusBar1.Refresh;

      Bitmap.Canvas.Brush.Color := clBtnFace;
      Bitmap.Height := SHP.Header.Height+TextHeight;
      Bitmap.Width := SHP.Header.Width;

      Bitmap.Canvas.TextOut((SHP.Header.Width div 2)-(Image.Picture.Bitmap.Canvas.TextWidth(Inttostr(C-1)) div 2),5,inttostr(c-1));

      Bitmap.Canvas.Brush.Color := Data^.SHPPalette[0];
      Bitmap.Canvas.FillRect(rect(0,TextHeight,SHP.Header.Width-1,TextHeight +SHP.Header.Height-1));

      cc := -1;
      for y := 0 to SHP.Data[c].Header_Image.cy-1 do
      begin
         Line := Bitmap.Scanline[TextHeight+SHP.Data[c].Header_Image.y+y];
         for x := 0 to SHP.Data[c].Header_Image.cx-1 do
         begin
            inc(cc);
            if SHP.Data[c].Databuffer[cc] <> 0 then
               Line[SHP.Data[c].Header_Image.x+x] := ColourToTRGB32(Data^.SHPPalette[Data^.SHP.Data[c].Databuffer[cc]]);
         end;
      end;
      Bitmap2.Canvas.Draw((c-StartFrame-1) * (SHP.Header.Width+3),0,Bitmap);
   end;
   StatusBar1.Panels[0].Text := '';
end;

procedure TFrmSequence.GetSequence2(Var Image : TBitmap; Const SHP:TSHP; StartFrame,EndFrame : Integer);
var
   c,cc,x,y,TextHeight : integer;
   Line : PRGB32Array;
   Bitmap,Bitmap2 : TBitmap;
begin
   TextHeight := 10 + Image.Canvas.TextHeight('TEST'); // note this means it works with any font the user uses as the defult system font
   Image.Canvas.Font.Color := clDefault; // Defult colour....

   Bitmap := TBitmap.Create;
   Bitmap.PixelFormat := pf32bit;
   Bitmap2 := TBitmap.Create;

   Bitmap2.Canvas.Brush.Color := clBtnFace;
   Bitmap2.Width := 0;
   Bitmap2.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   Bitmap2.Width := (SHP.Header.Width+3) * (EndFrame+1-StartFrame); // Starting Width
   Bitmap2.Height := SHP.Header.Height+TextHeight;  // Set Height

   Image.Canvas.Brush.Color := clBtnFace;
   Image.Width := 0;
   Image.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   CompressFrameImages(Data^.SHP); // Data gets compressed, should speed this up using the compressed data

   for c := StartFrame+1 to EndFrame +1 do
   begin
      StatusBar1.Panels[0].Text := 'Drawing '+inttostr(c-1) +' Of ' + inttostr(EndFrame);
      StatusBar1.Refresh;

      Bitmap.Canvas.Brush.Color := clBtnFace;
      Bitmap.Height := SHP.Header.Height+TextHeight;
      Bitmap.Width := SHP.Header.Width;
      Bitmap.Canvas.TextOut((SHP.Header.Width div 2)-(Image.Canvas.TextWidth(Inttostr(C-1)) div 2),5,inttostr(c-1));
      Bitmap.Canvas.Brush.Color := Data^.SHPPalette[0];
      Bitmap.Canvas.FillRect(rect(0,TextHeight,SHP.Header.Width-1,TextHeight +SHP.Header.Height-1));

      cc := -1;
      for y := 0 to SHP.Data[c].Header_Image.cy-1 do
      begin
         Line := Bitmap.Scanline[TextHeight+SHP.Data[c].Header_Image.y+y];
         for x := 0 to SHP.Data[c].Header_Image.cx-1 do
         begin
            inc(cc);
            if SHP.Data[c].Databuffer[cc] <> 0 then
               Line[SHP.Data[c].Header_Image.x+x] := ColourToTRGB32(Data^.SHPPalette[SHP.Data[c].Databuffer[cc]]);
         end;
      end;
      Bitmap2.Canvas.Draw((c-StartFrame-1) * (SHP.Header.Width+3),0,Bitmap);
   end;
   Image.Assign(Bitmap2);
   StatusBar1.Panels[0].Text := '';
end;

Function RoundUP(No : single) : integer;
begin
   if Trunc(No) < No then
      Result := Trunc(No)+1
   else
      Result := Trunc(No);
end;

procedure TFrmSequence.GetSequence3(Var Image : TBitmap; Const SHP:TSHP; Position,ImageWidth : Integer);
var
   c,cc,x,y,TextHeight,S,E : integer;
   Line : PRGB32Array;
   Bitmap,Bitmap2 : TBitmap;
begin
   TextHeight := 10 + Image.Canvas.TextHeight('TEST'); // note this means it works with any font the user uses as the defult system font
   Image.Canvas.Font.Color := clDefault; // Defult colour....

   Bitmap := TBitmap.Create;
   Bitmap.PixelFormat := pf32bit;
   Bitmap2 := TBitmap.Create;

   Bitmap2.Canvas.Brush.Color := clBtnFace;
   Bitmap2.Width := 0;
   Bitmap2.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   Bitmap2.Width := ImageWidth; // Starting Width
   Bitmap2.Height := SHP.Header.Height+TextHeight;  // Set Height

   Image.Canvas.Brush.Color := clBtnFace;
   Image.Width := 0;
   Image.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   CompressFrameImages(Data^.SHP); // Data gets compressed, should speed this up using the compressed data

   s := Position;
   e := S+RoundUP(Width / (SHP.Header.Width+3));

   if e > SHP.Header.NumImages-1 then
      e := SHP.Header.NumImages-1;

   for c := S+1 to E+1 do// StartFrame+1 to EndFrame +1 do
   begin
      Bitmap.Canvas.Brush.Color := clBtnFace;
      Bitmap.Height := SHP.Header.Height+TextHeight;
      Bitmap.Width := SHP.Header.Width;
      Bitmap.Canvas.TextOut((SHP.Header.Width div 2)-(Image.Canvas.TextWidth(Inttostr(C-1)) div 2),5,inttostr(c-1));
      Bitmap.Canvas.Brush.Color := Data^.SHPPalette[0];
      Bitmap.Canvas.FillRect(rect(0,TextHeight,SHP.Header.Width-1,TextHeight +SHP.Header.Height-1));
      cc := -1;
      for y := 0 to SHP.Data[c].Header_Image.cy-1 do
      begin
         Line := Bitmap.Scanline[TextHeight+SHP.Data[c].Header_Image.y+y];
         for x := 0 to SHP.Data[c].Header_Image.cx-1 do
         begin
            inc(cc);
            if SHP.Data[c].Databuffer[cc] <> 0 then
               Line[SHP.Data[c].Header_Image.x+x] := ColourToTRGB32(Data^.SHPPalette[Data^.SHP.Data[c].Databuffer[cc]]);
         end;
      end;
      Bitmap2.Canvas.Draw((c-s-1) * (SHP.Header.Width+3),0,Bitmap);
   end;
   Image.Width := Bitmap2.Width;
   Image.Height := Bitmap2.Height;
   Image.Canvas.Draw(0,0,Bitmap2);
   Bitmap2.Free;
   Bitmap.Free;

   StatusBar1.Panels[0].Text := '';
end;

procedure TFrmSequence.GetSequence4(Var Image : TBitmap; Const SHP:TSHP; StartFrame,EndFrame,Position,ImageWidth : Integer);
var
   c,cc,x,y,TextHeight,S,E : integer;
   Line : PRGB32Array;
   Bitmap,Bitmap2 : TBitmap;
begin
   TextHeight := 10 + Image.Canvas.TextHeight('TEST'); // note this means it works with any font the user uses as the defult system font
   Image.Canvas.Font.Color := clDefault; // Defult colour....

   Bitmap := TBitmap.Create;
   Bitmap.PixelFormat := pf32bit;
   Bitmap2 := TBitmap.Create;

   Bitmap2.Canvas.Brush.Color := clBtnFace;
   Bitmap2.Width := 0;
   Bitmap2.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   Bitmap2.Width := ImageWidth; // Starting Width
   Bitmap2.Height := SHP.Header.Height+TextHeight;  // Set Height

   Image.Canvas.Brush.Color := clBtnFace;
   Image.Width := 0;
   Image.Height := 0; // When we reset the height and width, technicaly the background should b in clbtnface....
   CompressFrameImages(Data^.SHP); // Data gets compressed, should speed this up using the compressed data

   s := Position + StartFrame;

   e := S+RoundUP(Width / (SHP.Header.Width+3));

   if e > EndFrame then
      e := endframe;

   if e > SHP.Header.NumImages-1 then
      e := SHP.Header.NumImages-1;

   for c := S+1 to E+1 do// StartFrame+1 to EndFrame +1 do
   begin
      Bitmap.Canvas.Brush.Color := clBtnFace;
      Bitmap.Height := SHP.Header.Height+TextHeight;
      Bitmap.Width := SHP.Header.Width;
      Bitmap.Canvas.TextOut((SHP.Header.Width div 2)-(Image.Canvas.TextWidth(Inttostr(C-1)) div 2),5,inttostr(c-1));
      Bitmap.Canvas.Brush.Color := Data^.SHPPalette[0];
      Bitmap.Canvas.FillRect(rect(0,TextHeight,SHP.Header.Width-1,TextHeight +SHP.Header.Height-1));
      cc := -1;
      for y := 0 to SHP.Data[c].Header_Image.cy-1 do
      begin
         Line := Bitmap.Scanline[TextHeight+SHP.Data[c].Header_Image.y+y];
         for x := 0 to SHP.Data[c].Header_Image.cx-1 do
         begin
            inc(cc);
            if SHP.Data[c].Databuffer[cc] <> 0 then
               Line[SHP.Data[c].Header_Image.x+x] := ColourToTRGB32(Data^.SHPPalette[Data^.SHP.Data[c].Databuffer[cc]]);
         end;
      end;
      Bitmap2.Canvas.Draw((c-s-1) * (SHP.Header.Width+3),0,Bitmap);
   end;

   Image.Width := Bitmap2.Width;
   Image.Height := Bitmap2.Height;
   Image.Canvas.Draw(0,0,Bitmap2);
   Bitmap2.Free;
   Bitmap.Free;
   StatusBar1.Panels[0].Text := '';
end;

procedure TFrmSequence.SaveSequence1Click(Sender: TObject);
var
   BmpArray    : array of TBitmap;
   x,FrameLength : Integer;
   FrmGifOptions : TFrmGifOptions;
   ColourPalette : TPalette;
begin
   if SaveSequencePictureDialog.Execute then
   begin
      // If it's a GIF, it exports like FrmMain.
      if UpperCase(ExtractFileExt(SaveSequencePictureDialog.FileName)) = '.GIF' then
      begin
         FrmGifOptions := TFrmGifOptions.Create(self);
         FrmGifOptions.ShowModal;
         if FrmGifOptions.Changed then
         begin
            // Get memory for the bitmap array.
            SetLength(BmpArray,Data^.SHP.Header.NumImages);
            // Get ammount of frames and build bitmap array
            GetPaletteForGif(Data^.SHPPalette,ColourPalette);
            FrameLength := CreateBmpArray(BmpArray,Data^.SHP,FrmGifOptions.Shadows.ItemIndex,True,From_Frame.Value+1,To_Frame.Value+1,Data^.Shadow_Match,ColourPalette,FrmGifOptions.Zoom_Factor.Value);
            // Update bitmap array size
            SetLength(BmpArray,FrameLength);
            // Now, save the stuff
            SaveBMPToGIFImageFile(BmpArray,SaveSequencePictureDialog.FileName,FrmGifOptions.LoopType.ItemIndex = 1,FrmGifOptions.CbUseTransparency.Checked,ColourPalette);
            // Finally, get rid of the stuff.
            for x := 0 to High(BmpArray) do
            begin
               BmpArray[x].Free;
            end;
         end;
         FrmGifOptions.Release;
      end
      else
         SaveImageFileFromBMP(SaveSequencePictureDialog.FileName,Sequence_Image.Picture.Bitmap);
   end;
end;

procedure TFrmSequence.SaveFrameListAsBMP1Click(Sender: TObject);
var
   BmpArray    : array of TBitmap;
   x,FrameLength : Integer;
   FrmGifOptions : TFrmGifOptions;
   ColourPalette : TPalette;
begin
   if SaveSequencePictureDialog.Execute then
   begin
      if UpperCase(ExtractFileExt(SaveSequencePictureDialog.FileName)) = '.GIF' then
      begin
         FrmGifOptions := TFrmGifOptions.Create(self);
         FrmGifOptions.ShowModal;
         if FrmGifOptions.Changed then
         begin
            // Get memory for the bitmap array.
            SetLength(BmpArray,Data^.SHP.Header.NumImages);
            // Get ammount of frames and build bitmap array
            GetPaletteForGif(Data^.SHPPalette,ColourPalette);
            FrameLength := CreateBmpArray(BmpArray,Data^.SHP,FrmGifOptions.Shadows.ItemIndex,False,0,0,Data^.Shadow_Match,ColourPalette,FrmGifOptions.Zoom_Factor.Value);
            // Update bitmap array size
            SetLength(BmpArray,FrameLength);
            // Now, save the stuff
            SaveBMPToGIFImageFile(BmpArray,SaveSequencePictureDialog.FileName,FrmGifOptions.LoopType.ItemIndex = 1,FrmGifOptions.CbUseTransparency.Checked,ColourPalette);
            // Finally, get rid of the stuff.
            for x := 0 to High(BmpArray) do
            begin
               BmpArray[x].Free;
            end;
         end;
         FrmGifOptions.Release;
      end
      else
         SaveImageFileFromBMP(SaveSequencePictureDialog.FileName,Frame_Image_List.Picture.Bitmap);
   end;
end;

procedure TFrmSequence.BuildINI_Code_addLine(Name : string; StartFrame,Count,Count2 : integer; Special : String);
begin
   INI_Code.lines.Add(Name + '=' + inttostr(StartFrame)+ ',' +inttostr(Count)+ ',' +inttostr(Count2) + Special);
end;

procedure TFrmSequence.BuildINI_Code;
var
   x : integer;
begin
   INI_Code.lines.clear;
   for x := 1 to Animations2_no do
      BuildINI_Code_addLine(Animations2[x].Anim_Name,Animations2[x].Anim.StartFrame,Animations2[x].Anim.Count,Animations2[x].Anim.Count2,Animations2[x].Anim.special);
end;

procedure TFrmSequence.Reset1Click(Sender: TObject);
begin
   SetupAnimations; // Reset Animations
   FormShow(Sender);
end;

procedure TFrmSequence.Refresh_TimerTimer(Sender: TObject);
begin
   Refresh_Timer.Enabled := false;
   ComboBoxEx1Change(Sender); // Update image
   Frame_Image_List.Visible := true;
   FrameSetup;
   SequenceSetup;
   BuildINI_Code; // Update INI Code
end;

procedure TFrmSequence.Exit1Click(Sender: TObject);
begin
   close;
end;

procedure TFrmSequence.Copy1Click(Sender: TObject);
begin
   INI_Code.CopyToClipboard;
end;

procedure TFrmSequence.Preview1Click(Sender: TObject);
begin
   Preview1.Checked := not Preview1.checked;
   FrameList1.Checked := not Preview1.checked;

   SequenceTimer.Enabled := Preview1.Checked;

   if FrameList1.Checked then
   begin
      Sequence_Image.Picture.Bitmap.Canvas.Brush.Color := clBtnFace;
   end;
   SequenceSetup;
end;

procedure TFrmSequence.FormClose(Sender: TObject;
var
   Action: TCloseAction);
begin
   SequenceTimer.Enabled := false;
end;

procedure TFrmSequence.SequenceTimerTimer(Sender: TObject);
begin
   DrawFrameImage(Data^.SHP,Data^.Shadow_Match,SequenceFrame+1,1,true,false,true,Data^.SHPPalette,Sequence_Image);
   inc(SequenceFrame);

   if SequenceFrame > WorkOutEndFrame then
      SequenceFrame := Current_Animation.StartFrame;
end;

procedure TFrmSequence.SaveAnimationSequence1Click(Sender: TObject);
var
   AnimationHeader : TAnimHeader;
begin
   AnimationHeader.anims := Animations2_no;
   AnimationHeader.frame_total := Data^.SHP.Header.NumImages;

   if SaveASFDialog.Execute then
      SaveASF(SaveASFDialog.FileName,Animations2,AnimationHeader);
end;

procedure TFrmSequence.Options1Click(Sender: TObject);
begin
   FrmMain.Preferences1Click(sender);
end;

procedure TFrmSequence.Button2Click(Sender: TObject);
begin
   Current_Animation.Count2 := Count2Edit.Value;
   Current_Animation.special := ',' + SpecialEdit.Text;
   ComboBoxEx1Change(Sender); // Make it update
   BuildINI_Code; // Update INI Code
end;

procedure TFrmSequence.OpenAnimationSequence1Click(Sender: TObject);
var
   AnimationHeader : TAnimHeader;
   Animations : TAnimations;
   x,xx : integer;
begin
   if OpenASFDialog.Execute then
   begin
      LoadASF(OpenASFDialog.FileName,Animations,AnimationHeader);

      if AnimationHeader.frame_total > Data^.SHP.Header.NumImages then
      begin
         messagebox(0,'Error: SHP Has less frames then SHP the Animation Sequence File was made for','Animation Sequence File Loader',0);
         exit;
      end;
      SetupAnimations; // Reset Animations to Defult!

      for x := 1 to AnimationHeader.anims do
         for xx := 1 to Animations2_no do
            if ansilowercase(Animations2[xx].Anim_Name) = ansilowercase(Animations[x].Anim_Name) then
            begin
               Animations2[xx].Anim.Count := Animations[x].Anim.Count;
               Animations2[xx].Anim.Count2 := Animations[x].Anim.Count2;
               Animations2[xx].Anim.StartFrame := Animations[x].Anim.StartFrame;
               Animations2[xx].Anim.special := Animations[x].Anim.special;
               Animations2[xx].Anim_Name := Animations[x].Anim_Name;
            end;

      ComboBoxEx1.ItemIndex := 0;
      ComboBoxEx1Change(sender);
      BuildINI_Code;
   end;
end;

procedure TFrmSequence.FormDestroy(Sender: TObject);
var
   AnimationHeader : TAnimHeaderData;
begin
   AnimationHeader.Anims := AnimationsData_no;
   SaveASDF(extractfiledir(ParamStr(0)) + '\SequenceGenerator.asdf',AnimationsData,AnimationHeader);
end;

procedure TFrmSequence.FormResize(Sender: TObject);
begin
   FrameSetup;
   SequenceSetup;
end;

procedure TFrmSequence.ScrollBar1Change(Sender: TObject);
begin
   Frame_Image_List.Picture.Bitmap.Height := Frame_Bitmap.Height;
   Frame_Image_List.Picture.Bitmap.Width := ScrollBox1.Width;
   GetSequence3(Frame_Bitmap,Data^.SHP,ScrollBar1.Position,Frame_Image_List.Width);

   Frame_Image_List.Picture.Bitmap.Assign(Frame_Bitmap);//  Canvas.Draw(0,0,Frame_Bitmap);
   Frame_Image_List.Refresh;
end;

procedure TFrmSequence.ScrollBar2Change(Sender: TObject);
begin
   Sequence_Image.Picture.Bitmap.Height := Sequence_Bitmap.Height;
   Sequence_Image.Picture.Bitmap.Width := ScrollBox2.Width;
   GetSequence4(Sequence_Bitmap,Data^.SHP,Current_Animation.StartFrame,WorkOutEndFrame,ScrollBar2.Position,Sequence_Image.Width);

   Sequence_Image.Picture.Bitmap.Assign(Sequence_Bitmap);//  Canvas.Draw(0,0,Frame_Bitmap);
   Sequence_Image.Refresh;
end;

procedure TFrmSequence.SequenceSetup;
begin
   // Sets up and displays sequence
   ScrollBar2.LargeChange := 1;//ScrollBox2.Width;
   if (WorkOutEndFrame-Current_Animation.StartFrame) * (Data^.SHP.Header.Width +3) > ScrollBox2.Width then
   begin
      ScrollBar2.Max := WorkOutEndFrame-Current_Animation.StartFrame-1;
      ScrollBar2.Enabled := true;
   end
   else
   begin
      ScrollBar2.Max := 1;
      ScrollBar2.Enabled := false;
   end;

   if Preview1.Checked then
      ScrollBar2.Enabled := false;

   ScrollBar2Change(nil);
end;

procedure TFrmSequence.FrameSetup;
begin
   // Sets up and displays frame
   //ScrollBar1.LargeChange := ScrollBox1.Width;
   if Data^.SHP.Header.NumImages * (Data^.SHP.Header.Width +3) > ScrollBox1.Width then
   begin
      ScrollBar1.Max := Data^.SHP.Header.NumImages-1;//Frame_Bitmap.Width - ScrollBox1.Width;
      ScrollBar1.Enabled := true;
   end
   else
   begin
      ScrollBar1.Max := 1;
      ScrollBar1.Enabled := false;
   end;

   ScrollBar1Change(nil);
end;

end.
