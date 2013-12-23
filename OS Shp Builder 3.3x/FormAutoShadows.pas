unit FormAutoShadows;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OSExtDlgs, StdCtrls, ExtCtrls, Spin,shp_file,shp_engine,palette,
  Shp_Engine_Image, ComCtrls, SHP_Engine_CCMs, SHP_Shadows, SHP_Image,
  SHP_Frame, SHP_DataMatrix,SHP_Engine_Resize, XPMan;

  CONST
    MaxPixelCount   =  32768;
    TSShadowColour = 1;
    RA2ShadowColour = 12;

  TYPE
    pRGBArray  =  ^TRGBArray;
    TRGBArray  =  ARRAY[0..MaxPixelCount-1] OF TRGBTriple;

type
  TFrmAutoShadows = class(TForm)
    ImageOriginal: TImage;
    ImageRotated: TImage;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    Bevel2: TBevel;
    ProgressBar1: TProgressBar;
    GroupBox1: TGroupBox;
    SpinEditThetaDegrees: TSpinEdit;
    GroupBox2: TGroupBox;
    SetTSShadowColour: TRadioButton;
    SetRA2ShadowColour: TRadioButton;
    GroupBox3: TGroupBox;
    SetFirstFrames: TRadioButton;
    SetLastFrames: TRadioButton;
    Label2: TLabel;
    SpinEditMagnifyShadow: TSpinEdit;
    Label4: TLabel;
    Label1: TLabel;
    XPManifest: TXPManifest;
    procedure LoadPreviewFrameData;
    procedure SpinEditRotate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SetTSShadowColourClick(Sender: TObject);
    procedure SetRA2ShadowColourClick(Sender: TObject);
    Procedure FindCoordinates(var Px,Py : Integer; Frame : Integer);
  private
    { Private declarations }
    shadowcolour : byte;
  public
    Ox,Oy : integer;
    Tx,Ty : integer; {Translation coordinates}
    Data : TSHPImageData;
    BitmapOriginal:  TBitmap;
    BitmapRotated :  TBitmap;
    PROCEDURE RotateBitmap;
    PROCEDURE RotateBitmap_frameimage(frame:integer);
  end;

implementation
{$R *.DFM}

USES
  Undo_Redo, FormMain;


// Rotate image by angle[degrees] specified in spinbox
procedure TFrmAutoShadows.SpinEditRotate(Sender: TObject);
begin
   RotateBitmap;
end;


procedure TFrmAutoShadows.FormCreate(Sender: TObject);
begin
  BitmapOriginal := TBitmap.Create;
  BitmapRotated  := TBitmap.Create;
  shadowcolour := 1;
end;

//Procedure By Thomas Kowalski
procedure SpiegelnHorizontal(Bitmap:TBitmap);
var i,j,w :  INTEGER;
    RowIn :  pRGBArray;
    RowOut:  pRGBArray;

begin
    w := bitmap.width*sizeof(TRGBTriple);
    Getmem(rowin,w);
    for j := 0 to Bitmap.Height-1 do begin
      move(Bitmap.Scanline[j]^,rowin^,w);
      rowout := Bitmap.Scanline[j];
      for i := 0 to Bitmap.Width-1 do rowout[i] := rowin[Bitmap.Width-1-i];
    end;
    bitmap.Assign(bitmap);
    Freemem(rowin);
end;

// Procedure by Earl F. Glynn and Optimized by John O'Harrow
PROCEDURE TFrmAutoShadows.RotateBitmap;
const
  Black : RGBTriple = (rgbtBlue:0; rgbtGreen:0; rgbtRed:0);
VAR
  i, j           :  Word;
  BW, BH         :  Word;
  iOriginal      :  Integer;
  iPrime         :  Integer;
  iPrimeRotated  :  Integer;
  jOriginal      :  Integer;
  jPrime         :  Integer;
  jPrimeRotated  :  Integer;
  RowOriginal    :  pRGBArray;
  RowRotated     :  pRGBArray;
  sinTheta       :  Double;
  cosTheta       :  Double;
  Theta          :  Double; // radians
  POriginalStart :  Pointer;
  POriginal      :  Pointer;
  ScanlineBytes  :  Integer;
  iRot, jRot     :  Integer;
  jPrimeSinTheta :  Double;
  jPrimeCosTheta :  Double;
  Multiplier : Real;
  ThetaDegreesValue: smallint;
  MagnifyShadowValue: smallint;
begin
   // Prevent wrong user values.
  ThetaDegreesValue := StrToIntDef(SpinEditThetaDegrees.Text,0);
  MagnifyShadowValue := StrToIntDef(SpinEditMagnifyShadow.Text,0);

  // This affect the size of the shadows
  Multiplier := 1 / MagnifyShadowValue;

  // The size of BitmapRotated is the same as BitmapOriginal.  PixelFormat
  // must also match since 24-bit GBR triplets are assumed in ScanLine.

//  BitmapOriginal := GetBMPOfFrameImage_ShadowColour(FrmMain.SHP,1,SHPPalette);
  BitmapRotated.Width  := BitmapOriginal.Width;
  BitmapRotated.Height := BitmapOriginal.Height;
  BitmapRotated.PixelFormat := BitmapOriginal.PixelFormat; //Copy PixelFormat

  BitmapRotated.Canvas.Brush.Color := Data^.SHPPalette[0];
  BitmapRotated.Canvas.FillRect(Rect(0,0,BitmapRotated.Width,BitmapRotated.Height));
  // Convert degrees to radians.  Use minus sign to force clockwise rotation.
  Theta := -(ThetaDegreesValue) * PI / 180;
  sinTheta := SIN(Theta);
  cosTheta := COS(Theta);

  //Get Size of each ScanLine (Allow for DWORD Alignment and DIB Orientation)
  ScanlineBytes := Integer(BitmapOriginal.Scanline[1])
                 - Integer(BitmapOriginal.Scanline[0]);

  BW := BitmapOriginal.Width  - 1; //Prevent Repeated Calls to TBitMap.Width
  BH := BitmapOriginal.Height - 1; //Prevent Repeated Calls to TBitMap.Height
  iRot := (2 * Ox) + Tx + 1; //Simplify Calculation within Inner Loop
  jRot := (2 * Oy) + Ty + 1; //Simplify Calculation within Outer Loop

  //Remove all calls to Scanline method from within loops by using local pointers

  RowRotated     := BitmapRotated.ScanLine[BH]; //Last BitmapRotated Scanline
  POriginalStart := BitmapOriginal.ScanLine[0]; //First BitmapOriginal Scanline
  // Step through each row of rotated image.
  for j := BH downto 0 do
    begin
      // Assume the bitmap has an even number of pixels in both dimensions and
      // the axis of rotation is to be the exact middle of the image -- so this
      // axis of rotation is not at the middle of any pixel.

      // The transformation (i,j) to (iPrime, jPrime) puts the center of each
      // pixel at odd-numbered coordinates.  The left and right sides of each
      // pixel (as well as the top and bottom) then have even-numbered coordinates.

      // The point (Ox, Oy) identifies the axis of rotation.

      // For a 640 x 480 pixel image, the center point is (320, 240).  Pixels
      // numbered (index i) 0..319 are left of this point along the "X" axis and
      // pixels numbered 320..639 are right of this point.  Likewise, vertically
      // pixels are numbered (index j) 0..239 above the axis of rotation and
      // 240..479 below the axis of rotation.

      // The subtraction (i, j) - (Ox, Oy) moves the axis of
      // rotation from (i, j) to (Ox, Oy), which is the
      // center of the bitmap in this implementation.
      jPrime := (2 * j) - jRot;
      jPrimeSinTheta := jPrime * sinTheta; //Simplify Calculation within Loop
      jPrimeCosTheta := jPrime * cosTheta; //Simplify Calculation within Loop
      POriginal := POriginalStart; //Pointer to First BitmapOriginal Scanline
      for i := BW downto 0 do
        begin
          // Rotate (iPrime, jPrime) to location of desired pixel
          // Transform back to pixel coordinates of image, including translation
          // of origin from axis of rotation to origin of image.
          // Make sure (iOriginal, jOriginal) is in BitmapOriginal.  If not,
          // assign blue color to corner points.
          iPrime := (2 * i) - iRot;
          iPrimeRotated := ROUND(iPrime * cosTheta - jPrimeSinTheta);
          iOriginal := round(multiplier * (iPrimeRotated - 1));
          iOriginal := round(iOriginal shr 2) + Ox + Tx;
          if (iOriginal >= 0) and (iOriginal <= BW) then
            begin //Only Calaculate jPrimeRotated and jOriginal if Necessary
              jPrimeRotated := ROUND(iPrime * sinTheta + jPrimeCosTheta);
              jOriginal := round(multiplier * (jPrimeRotated - 1));
              jOriginal := round(jOriginal shr 2) + Oy + Ty;
              if (jOriginal >= 0) and (jOriginal <= BH) then
                begin
                     // Assign pixel from rotated space to current pixel in BitmapRotated
                     RowOriginal   := Pointer(Integer(POriginal) + (jOriginal * ScanLineBytes));
                     RowRotated[i] := RowOriginal[iOriginal];
                end;
              end;
        end;
      Dec(Integer(RowRotated), ScanLineBytes); //Move Pointer to Previous BitmapRotated Scanline
    end;
  ImageRotated.Picture.Graphic := BitmapRotated;
//  AssignBitmapToImage(Bitmap,ImageRotated);
  DrawFrameImage(Data^.SHP,Data^.Shadow_Match,1,1,false,false,false,Data^.SHPPalette,ImageRotated);
end; {RotateBitmap}

// Procedure by Earl F. Glynn and Optimized by John O'Harrow, Modifyed for FrameImage
PROCEDURE TFrmAutoShadows.RotateBitmap_frameimage(frame:integer);
const
  Black : RGBTriple = (rgbtBlue:0; rgbtGreen:0; rgbtRed:0);
VAR
  i, j           :  Word;
  BW, BH         :  Word;
  iOriginal      :  Integer;
  iPrime         :  Integer;
  iPrimeRotated  :  Integer;
  jOriginal      :  Integer;
  jPrime         :  Integer;
  jPrimeRotated  :  Integer;
  RowOriginal    :  pRGBArray;
  RowRotated     :  pRGBArray;
  sinTheta       :  Double;
  cosTheta       :  Double;
  Theta          :  Double; // radians
  POriginalStart :  Pointer;
  POriginal      :  Pointer;
  ScanlineBytes  :  Integer;
  iRot, jRot     :  Integer;
  jPrimeSinTheta :  Double;
  jPrimeCosTheta :  Double;
  Multiplier : Real;
  ThetaDegreesValue: smallint;
  MagnifyShadowValue: smallint;
begin
   // Prevent wrong user values.
  ThetaDegreesValue := StrToIntDef(SpinEditThetaDegrees.Text,0);
  MagnifyShadowValue := StrToIntDef(SpinEditMagnifyShadow.Text,0);

  // This affects the size of the shadow
  Multiplier := (MagnifyShadowValue) / 100;

  // The size of BitmapRotated is the same as BitmapOriginal.  PixelFormat
  // must also match since 24-bit GBR triplets are assumed in ScanLine.
  BitmapOriginal := GetBMPOfFrameImage_ShadowColour(Data^.SHP,Frame,Data^.SHPPalette,shadowcolour);
  BitmapOriginal.PixelFormat := pf24bit;   // force to 24 bits
  SpiegelnHorizontal(BitmapOriginal);
  BitmapRotated.Width  := BitmapOriginal.Width;
  BitmapRotated.Height := BitmapOriginal.Height;
  BitmapRotated.PixelFormat := BitmapOriginal.PixelFormat; //Copy PixelFormat

  BitmapRotated.Canvas.Brush.Color := Data^.SHPPalette[0];
  BitmapRotated.Canvas.FillRect(Rect(0,0,BitmapRotated.Width,BitmapRotated.Height));
  BitmapRotated.Canvas.Brush.Color := Data^.SHPPalette[shadowcolour];
  // Convert degrees to radians.  Use minus sign to force clockwise rotation.
  Theta := -(ThetaDegreesValue) * PI / 180;
  sinTheta := SIN(Theta);
  cosTheta := COS(Theta);

  //Get Size of each ScanLine (Allow for DWORD Alignment and DIB Orientation)
  ScanlineBytes := Integer(BitmapOriginal.Scanline[1])
                 - Integer(BitmapOriginal.Scanline[0]);

  BW := BitmapOriginal.Width  - 1; //Prevent Repeated Calls to TBitMap.Width
  BH := BitmapOriginal.Height - 1; //Prevent Repeated Calls to TBitMap.Height
  iRot := (2 * Ox) + Tx + 1; //Simplify Calculation within Inner Loop
  jRot := (2 * Oy) + Ty + 1; //Simplify Calculation within Outer Loop

  //Remove all calls to Scanline method from within loops by using local pointers

  RowRotated     := BitmapRotated.ScanLine[BH]; //Last BitmapRotated Scanline
  POriginalStart := BitmapOriginal.ScanLine[0]; //First BitmapOriginal Scanline
  // Step through each row of rotated image.
  for j := BH downto 0 do
  begin
     // Assume the bitmap has an even number of pixels in both dimensions and
     // the axis of rotation is to be the exact middle of the image -- so this
     // axis of rotation is not at the middle of any pixel.

     // The transformation (i,j) to (iPrime, jPrime) puts the center of each
     // pixel at odd-numbered coordinates.  The left and right sides of each
     // pixel (as well as the top and bottom) then have even-numbered coordinates.

     // The point (Ox, Oy) identifies the axis of rotation.

     // For a 640 x 480 pixel image, the center point is (320, 240).  Pixels
     // numbered (index i) 0..319 are left of this point along the "X" axis and
     // pixels numbered 320..639 are right of this point.  Likewise, vertically
     // pixels are numbered (index j) 0..239 above the axis of rotation and
     // 240..479 below the axis of rotation.

     // The subtraction (i, j) - (Ox, Oy) moves the axis of
     // rotation from (i, j) to (Ox, Oy), which is the
     // center of the bitmap in this implementation.
     jPrime := (2 * j) - jRot;
     jPrimeSinTheta := jPrime * sinTheta; //Simplify Calculation within Loop
     jPrimeCosTheta := jPrime * cosTheta; //Simplify Calculation within Loop
     POriginal := POriginalStart; //Pointer to First BitmapOriginal Scanline
     for i := BW downto 0 do
     begin
        // Rotate (iPrime, jPrime) to location of desired pixel
        // Transform back to pixel coordinates of image, including translation
        // of origin from axis of rotation to origin of image.
        // Make sure (iOriginal, jOriginal) is in BitmapOriginal.  If not,
        // assign blue color to corner points.
        iPrime := (2 * i) - iRot;
          iPrimeRotated := ROUND(iPrime * cosTheta - jPrimeSinTheta);
          iOriginal := round(Multiplier * ((iPrimeRotated - 1) shr 2)) + Ox + Tx;
          if (iOriginal >= 0) and (iOriginal <= BW) then
            begin //Only Calaculate jPrimeRotated and jOriginal if Necessary
              jPrimeRotated := ROUND(iPrime * sinTheta + jPrimeCosTheta);
              jOriginal := round(Multiplier * ((jPrimeRotated - 1) shr 2)) + Oy + Ty;
           if (jOriginal >= 0) and (jOriginal <= BH) then
           begin
              // Assign pixel from rotated space to current pixel in BitmapRotated
              RowOriginal   := Pointer(Integer(POriginal) + (jOriginal * ScanLineBytes));
              RowRotated[i] := RowOriginal[iOriginal];
           end;
        end;
     end;
     Dec(Integer(RowRotated), ScanLineBytes); //Move Pointer to Previous BitmapRotated Scanline
  end;
  if SetFirstFrames.Checked then
     SetFrameImageFrmBMPForAutoShadows(Data^.SHP,Frame,Data^.SHPPalette,BitmapRotated,shadowcolour)
  else
     SetFrameImageFrmBMPForAutoShadows(Data^.SHP,GetShadowFromOposite(Data^.SHP,Frame),Data^.SHPPalette,BitmapRotated,shadowcolour);

end; {RotateBitmap}

procedure TFrmAutoShadows.LoadPreviewFrameData;
begin

    BitmapOriginal.Free;

    BitmapOriginal := GetBMPOfFrameImage_ShadowColour(Data^.SHP,1,Data^.SHPPalette,shadowcolour);

    FindCoordinates(Tx,Ty,1);

    if   BitmapOriginal.PixelFormat <> pf24bit
    then BitmapOriginal.PixelFormat := pf24bit;   // force to 24 bits
    SpiegelnHorizontal(BitmapOriginal);
    DrawFrameImage(Data^.SHP,Data^.Shadow_Match,1,1,true,false,true,Data^.SHPPalette,ImageOriginal);
//    AssignBitmapToImage(Bitmap,ImageOriginal);

    Ox := BitmapOriginal.Width  div 2;
    Oy := BitmapOriginal.Height div 2;

    // Rotate and display the image
    RotateBitmap;
end;

procedure TFrmAutoShadows.FormShow(Sender: TObject);
begin
   SetTSShadowColourClick(sender);
end;

procedure TFrmAutoShadows.Button1Click(Sender: TObject);
var
x : integer;
begin
ProgressBar1.Visible := true;
ProgressBar1.Max := Data^.SHP.Header.NumImages div 2-1;
ProgressBar1.Position := 0;

if SetLastFrames.Checked then
   AddToUndo(Data^.UndoList,Data^.SHP,((Data^.SHP.Header.NumImages div 2) + 1),Data^.SHP.Header.NumImages)
else
   AddToUndo(Data^.UndoList,Data^.SHP,1,(Data^.SHP.Header.NumImages div 2));

// Hack to avoid colour problems.
Data^.SHPPalette[shadowcolour] := RGB(255,255,255);
Data^.SHPPalette[0] := RGB(0,0,0);

for x := 1 to Data^.SHP.Header.NumImages div 2 do
begin
FindCoordinates(Tx,Ty,x);
RotateBitmap_frameimage(x);
ProgressBar1.Position := x-1;
end;

ProgressBar1.Visible := false;
FrmMain.UndoUpdate(Data^.UndoList);

LoadPaletteFromFile(Data^.SHPPaletteFilename,Data^.SHPPalette);

close;
end;

procedure TFrmAutoShadows.Button2Click(Sender: TObject);
begin
close;
end;

procedure TFrmAutoShadows.SetTSShadowColourClick(Sender: TObject);
begin
   shadowcolour := TSShadowColour;
   LoadPreviewFrameData;
end;

procedure TFrmAutoShadows.SetRA2ShadowColourClick(Sender: TObject);
begin
   shadowcolour := RA2ShadowColour;
   LoadPreviewFrameData;
end;

Procedure TFrmAutoShadows.FindCoordinates(var Px,Py : Integer; Frame : Integer);
var
   x,y : integer;
   Lx,Ly,Rx,Ry : Integer; // Left and Right coordinates
begin
   y := (Data^.SHP.Header.Height-1) div 2;
   x := (Data^.SHP.Header.Width-1) div 2;
   Rx := 0;
   Ry := 0;

   // Detect the bottom left of the picture
   // Find the left from the center.
   while (Data^.SHP.Data[Frame].FrameImage[x,y] <> 0) and (x >= 0) do
   begin
      dec(x);
   end;
   inc(x);

   // Find the bottom from the previous left
   y := Data^.SHP.Header.Height-1;
   while (Data^.SHP.Data[Frame].FrameImage[x,y] = 0) and (y >= 0) do
   begin
      dec(y);
   end;

   // Find the bottom left from the bottom.
   while (Data^.SHP.Data[Frame].FrameImage[x,y] <> 0) and (x >= 0) do
   begin
      dec(x);
   end;

   Lx := x;
   Ly := y;

   // Reset x and y
   y := Data^.SHP.Header.Height-1;
   x := Data^.SHP.Header.Width-1;

   // Detect the bottom right of the picture
   while ((Rx = 0) or (Ry = 0)) and (y >= 0) do
   begin
      while x >= 0 do
      begin
         if Data^.SHP.Data[Frame].FrameImage[x,y] <> 0 then
         begin
            Rx := x;
            Ry := y;
            break;
         end;
         dec(x);
      end;
      x := Data^.SHP.Header.Width-1;
      dec(y);
   end;

   Px := Rx - Lx;
   Py := Ry - Ly;
end;


end.
