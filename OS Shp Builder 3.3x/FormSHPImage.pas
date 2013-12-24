unit FormSHPImage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Spin, SHP_file, SHP_Shadows,
  SHP_Image, Palette, Undo_Redo, Mouse, math, XPMan, SHP_Engine_CCMs, Colour_list;

type
   TRGB32 = packed record
      R, G, B, A: byte;
   end;

   TColorArray = Array [0..MaxInt div SizeOf(TRGB32) - 1] of TRGB32;
   TScanline = ^TColorArray;
   TCell = array of array of integer;

   TFrmSHPImage = class(TForm)
      PaintAreaPanel: TPanel;
      Image1: TImage;
      ScrollBox1: TScrollBox;
      XPManifest: TXPManifest;
      procedure ResizePaintArea(var Image1 : TImage; var PaintAreaPannel: TPanel);
      procedure RefreshImage1;
      procedure SetShadowColour(Col: Integer);
      procedure SetActiveColour(Col: Integer);
      procedure SetBackGroundColour(Col: Integer);
      procedure UpdateSHPTypeFromGame;
      procedure UpdateSHPTypeMenu;
      procedure WriteSHPType;
      procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure SetShadowMode(Value : boolean);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormShow(Sender: TObject);
      procedure FormActivate(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure AutoGetCursor;
      procedure WorkOutImageClick(var SHP: TSHP; var X,Y : integer; var OutOfRange : boolean; zoom:byte);
      procedure Image1DblClick(Sender: TObject);
      procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   private
      { Private declarations }
      Click : integer;

      // Utilities
      function GetWorkingColorIndex : byte;
      function IsClickInsideSelection(var s : TSelection; x, y :integer) : boolean;

      // Drawing Methods
      procedure DrawSelection(var bmp : TBitmap);
      procedure DrawSelectedArea(var s : TSelection; var bmp : TBitmap);
      procedure DrawSelectionLayer(var s : TSelection; var  bmp : TBitmap);

      procedure DrawGrid(var  bmp : TBitmap; color : TRGB32);
      procedure DrawCross(var bmp : TBitmap; color : TRGB32);
      procedure DrawToolPreview(var bmp : TBitmap);

      procedure DrawFrameBackground(var bmp : TBitmap; color : TRGB32);
      procedure DrawFrame(var bmp : TBitmap);
      procedure DrawFrameVirtual(var SHP: TSHP; var Shadow_Match: TShadowMatch; FrameIndex: integer; grayscale : boolean; var Palette: TPalette; var bmp : TBitmap);
      procedure DrawShadowWithFrameVirtual(var SHP: TSHP; var Shadow_Match: TShadowMatch; FrameIndex: integer; var Palette: TPalette; var bmp : TBitmap);
   
      procedure DrawBitmapPixel(var bmp : TBitmap; x, y : integer; color : TColor);

      function GetOppositeRGB32(const color : TRGB32) : TRGB32;
      function ColorToRGB32(const color : TColor) : TRGB32;
      procedure InitCellShape(var cell : TCell);

      // Tool Methods
      procedure SelectColor(x, y : integer);
      procedure Flood(x, y : integer);
      procedure FloodGradient(x, y : integer);
      procedure FloodBlur(x, y : integer);

      // Tool Preview Methods
      procedure PreviewBrush(x, y : integer; colorIndex : byte);
      procedure PreviewStroke(x, y : integer; colorIndex : byte);


      // Selection Methods
      procedure SelectionOnMouseDown(x, y : integer);
      procedure SelectionOnMouseMove(x, y : integer);
      procedure SelectionOnMouseUp;
      procedure SelectionMoveOnMouseMove(x, y : integer);
      procedure SelectionMoveOnMouseUp;


      // Copy Methods
      procedure CopyLayerToFrame(var s : TSelection);
      procedure CopySelectionToLayer(var s : TSelection);
      procedure CopyPreviewToFrame;

   public
      { Public declarations }
      First, 
      Last, 
      LastPreview : TPoint2D;

      ActiveColour, 
      ShadowColour,
      BackGroundColour : byte;
      //DrawingColor : TColor;

      BackgroundEnabled: boolean;
      ShadowMode : boolean;
      show_center : boolean;
      ShowGrid : boolean;
      C : Boolean;
      
      Zoom : byte;
      MaxZoom : byte;
      FrameIndex : longword;
      GridSize : byte;
      alg : byte;// Algorithm for converting external bitmaps to Shp frame
      
      DefultCursor : integer;
      ID : word;
      Data : Pointer;
      Address : Pointer;

      // Selection 
      IsSelecting : boolean;
      Selection : TSelection;

      procedure ResetSelection;
      procedure CutSelection;
      procedure PasteSelection(var bmp : TBitmap; algorithm : byte; var selectionPosition : TPoint2D);
      procedure ApplySelection;

      procedure SelectNextFrame;
      procedure SelectPrecedingFrame;
      procedure SetFrameIndex(v : integer);
      procedure SetBackgroundEnabled(Value: boolean);
   end;

implementation

uses FormMain, FormPreview, OS_SHP_Tools, SHP_DataMatrix, shp_engine;


{$R *.dfm}
//---------------------------------------------
// Resize Paint Area
//---------------------------------------------
procedure TFrmSHPImage.ResizePaintArea(var Image1 : TImage; var PaintAreaPannel: TPanel);
var
   SHPData : TSHPImageData;
   width, height : word;
begin
   if Data = nil then exit;
   SHPData := Data;

   // Cache basic values
   width := (SHPData^.SHP.header.Width * Zoom);
   height := (SHPData^.SHP.header.Height * Zoom);

   if WindowState = WSNormal then
   begin
      ClientWidth := Width + 4;// + 4, why?
      ClientHeight := Height + 4;// why!?
   end;

   FormResize(nil);

   PaintAreaPanel.Width := Width;
   PaintAreaPanel.Height := Height;

   // Set image width n height
   Image1.Picture.Bitmap.Width := width;
   Image1.Picture.Bitmap.Height := height;

   Image1.Width := Width;
   Image1.Height := Height;
end;


//---------------------------------------------
// Convert TColor to TRGB32
// - NOTES -
// TRGB32 : R, G, B, A
// TColor : B, G, R, A
//---------------------------------------------
function TFrmSHPImage.ColorToRGB32(const color : TColor) : TRGB32;
var
   hexacolor : ^integer;
begin
   hexacolor := @color;
   Result.B := ( hexacolor^ and  $000000FF );
   Result.G := ( hexacolor^ and  $0000FF00 ) shr 8;
   Result.R := ( hexacolor^ and  $00FF0000 ) shr 16;
   Result.A := ( hexacolor^ and  $FF000000 ) shr 32;
end;

//---------------------------------------------
// Get Opposite RGB32 Color
//---------------------------------------------
function TFrmSHPImage.GetOppositeRGB32(const color : TRGB32) : TRGB32;
begin
   Result.B := 255 - color.B;
   Result.G := 255 - color.G;
   Result.R := 255 - color.R;
   Result.A := color.A;
end;


///---------------------------------------------
// Draw Bitmap Pixel with Scanline
//---------------------------------------------
procedure TFrmSHPImage.DrawBitmapPixel(var bmp : TBitmap; x, y : integer; color : TColor);
var
   line : TScanline;
begin
   if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawBmpPxl: Scanline: %d', [y]) );

   line := bmp.Scanline[y];
   line[x] := ColorToRGB32(color);
end;


//---------------------------------------------
// Draw Grid
// TODO: rework grid
//---------------------------------------------
procedure TFrmSHPImage.DrawGrid(var bmp : TBitmap; color : TRGB32);
var 
   cell : TCell;
   cellWidth, cellHeight : integer;
   x, y, i: integer;
   ShpContext : TSHPImageData;
   line : TScanline;
begin
   ShpContext := Data;

   cellWidth := 48;
   cellHeight := 25;
   InitCellShape(cell);

   for y := 0 to  cellHeight - 1 do begin
      line := bmp.Scanline[y];

      for i := 0 to 7 do begin
         x := cell[y, i];
         if x = -1 then
            Break;
         line[x] := color; 
      end;
   end;

end;


//---------------------------------------------
// Draw Cross (center)
//---------------------------------------------
procedure TFrmSHPImage.DrawCross(var bmp : TBitmap; color : TRGB32);
var
   x, y, max: integer;
   ShpContext : TSHPImageData;
   line : TScanline;
begin   
   ShpContext := Data;

   x := (bmp.Width div 2) - 1;
   if (bmp.Width mod 2 = 0) then
      max := x + 1
   else
   begin
      inc(x);
      max := x;
   end;

   // Draw vertical line
   for y := 0 to bmp.Height - 1 do begin
      if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawCrossV: Scanline: %d', [y]) );
      line := bmp.Scanline[y];

      line[x] := color;
      line[max] := color;
   end;

   y := (bmp.Height div 2) - 1;
   if ( bmp.Height mod 2 = 0) then
      max := y + 1
   else
   begin
      inc(y);
      max := y;
   end;

   // Draw horizontal line
   while( y <= max) do begin
      if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawCrossH: Scanline: %d', [y]) );
      line := bmp.Scanline[y];
      inc(y);

      for x := 0 to bmp.Width - 1 do begin
         line[x] := color;
      end;
   end;
end;


//---------------------------------------------
// Draw Frame
//---------------------------------------------
procedure TFrmSHPImage.DrawFrame(var bmp : TBitmap);
var
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;

   if IsShadow(ShpContext^.Shp, FrameIndex) and (ShadowMode) then begin
      DrawShadowWithFrameVirtual(ShpContext^.SHP, ShpContext^.Shadow_Match, FrameIndex, ShpContext^.SHPPalette, bmp)
   end
   else
      DrawFrameVirtual(ShpContext^.SHP, ShpContext^.Shadow_Match, FrameIndex, false, ShpContext^.SHPPalette, bmp);
end;


//---------------------------------------------
// Draw Frame Background
//---------------------------------------------
procedure TFrmSHPImage.DrawFrameBackground(var bmp : TBitmap; color : TRGB32);
var
   x, y:   word;
   line : TScanline;
begin 
   for y := 0 to bmp.Height - 1 do begin
      if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawFrameBG: Scanline: %d', [y]) );
      line := bmp.Scanline[y];

      for x := 0 to bmp.Width - 1 do 
         line[x] := color;
   end;   
end;


//---------------------------------------------
// Draw Frame Image
//---------------------------------------------
procedure TFrmSHPImage.DrawFrameVirtual(var SHP: TSHP; var Shadow_Match: TShadowMatch; FrameIndex: integer; grayscale : boolean; var Palette: TPalette; var bmp : TBitmap);
var
   x, y:   word;
   color : TColor;
   line : TScanline;
begin
   // DRAW
   for y := 0 to SHP.header.Height - 1 do begin
      if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawFrameImage: Scanline: %d', [y]) );
      line := bmp.Scanline[y];

      for x := 0 to SHP.header.Width - 1 do
      begin
         if Shp.Data[FrameIndex].FrameImage[x, y] <> TRANSPARENT then
         begin
            if grayscale then
               color := Shadow_Match[Shp.Data[FrameIndex].FrameImage[x, y]].Original
            else begin
               color := palette[Shp.Data[FrameIndex].FrameImage[x, y]];
            end;

            line[x] := ColorToRGB32(color);
         end;
      end;
   end;
end;


///---------------------------------------------
// Draw Shadow with Grayscale frame
//---------------------------------------------
procedure TFrmSHPImage.DrawShadowWithFrameVirtual(var SHP: TSHP; var Shadow_Match: TShadowMatch; FrameIndex: integer; var Palette: TPalette; var bmp : TBitmap);
begin
   DrawFrameVirtual(SHP, Shadow_Match,  FrameIndex, false, Palette, bmp );
   DrawFrameVirtual(SHP, Shadow_Match,  GetShadowOposite(SHP, FrameIndex), true, Palette, bmp );
end;


//---------------------------------------------
// Draw Tool Preview
//---------------------------------------------
procedure TFrmSHPImage.DrawToolPreview(var bmp : TBitmap);
var
   ShpContext : TSHPImageData;
   i : integer;
begin
   ShpContext := Data;
   
   for i := 0 to FrmMain.TempViewLength - 1 do
      DrawBitmapPixel(bmp, FrmMain.TempView[i].X, FrmMain.TempView[i].Y, FrmMain.TempView[i].Colour);
   
end;


//---------------------------------------------
// Draw Selection
//---------------------------------------------
procedure TFrmSHPImage.DrawSelection(var bmp : TBitmap);
begin
   if(Selection.Visible) then
   begin
      if (Selection.HasData) then
         DrawSelectedArea(Selection, bmp)
      else
         DrawSelectionLayer(Selection, bmp);
   end;
end;


//---------------------------------------------
// Draw Selection
//---------------------------------------------
procedure TFrmSHPImage.DrawSelectionLayer(var s : TSelection; var bmp : TBitmap);
var
   ShpContext : TSHPImageData;
   x, y, right, bottom: integer;
   line : TScanline;
begin
   
   ShpContext := Data;
   right := s.X + s.Width - 1;
   bottom := s.Y + s.Height - 1;


   for y := s.Y to bottom do
   begin
      if ( y < 0) or (y >= bmp.Height) then ShowMessage( Format('DrawFrameImage: Scanline: %d', [y]) );
      line := bmp.Scanline[y];

      for x := s.X to right do
      begin
         line[x] := ColorToRGB32( OpositeColour( ShpContext^.SHPPalette[ ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y] ]));
      end;
   end;
end;


//---------------------------------------------
// Draw Selected Area
//---------------------------------------------
procedure TFrmSHPImage.DrawSelectedArea(var s : TSelection; var bmp : TBitmap);
var
   ShpContext : TSHPImageData;
   line : TScanline;
   x, y, 
   xx, yy, 
   maxX, maxY : integer;
begin
   ShpContext := Data;

   for y := 0 to s.Height - 1 do begin
      yy := s.Y + y;
      if ( yy < 0) then continue;
      if ( yy >= ShpContext^.Shp.Header.Height ) then continue;
      if ( yy < 0) or (yy >= bmp.Height) then ShowMessage( Format('DrawSelectedArea: Scanline: %d', [y]) );
      line := bmp.Scanline[yy];
      
      for x := 0 to s.Width - 1 do begin
         xx := s.X + x;
         if ( xx < 0) then continue;
         if ( xx >= ShpContext^.Shp.Header.Width ) then continue;

         line[xx] := ColorToRGB32(OpositeColour( ShpContext^.SHPPalette[ s.Layer[x][y] ]  ));
      end;
   end;
end;


//---------------------------------------------
// Create Cell Shape (ts)
//---------------------------------------------
procedure TFrmSHPImage.InitCellShape(var cell : TCell);
var
   Width, Height,
   mid, bottom, sep, x, y, i : integer;
begin
   // 48 x 25 = (w x h)
   Width := 48;
   Height := 25;
   SetLength(cell, Height, 8);
   mid := round(Height / 2);
   bottom := Height - 1;

   cell[0][0] := 22;
   cell[0][1] := 23;
   cell[0][2] := 24;
   cell[0][3] := 25;
   cell[0][4] := -1;

   sep := 0;
   x := round(Width / 2) - 4;
   for y := 1 to mid - 1 do begin
      for i := 0 to 3 do
         cell[y, i] := x + i;
      for i := 0 to 3 do
         cell[y, i + 4] := x + 4 + i + sep;

      x := x - 2;
      sep := sep + 4;
   end;

   cell[mid][0] := 0;
   cell[mid][1] := 1;
   cell[mid][2] := 46;
   cell[mid][3] := 47;
   cell[mid][4] := -1;

   sep := Width - 8;
   x := 0;
   for y := mid + 1 to Height - 2 do begin
      for i := 0 to 3 do
         cell[y, i] := x + i;
      for i := 0 to 3 do
         cell[y, i + 4] := x + 4 + i + sep;

      x := x + 2;
      sep := sep - 4;
   end;

   cell[bottom][0] := 22;
   cell[bottom][1] := 23;
   cell[bottom][2] := 24;
   cell[bottom][3] := 25;
   cell[bottom][4] := -1;
end;



//---------------------------------------------
// Refresh Image (Frame)
//---------------------------------------------
procedure TFrmSHPImage.RefreshImage1;
var
   ShpContext : TSHPImageData;
   bmp : TBitmap;
   gridColor : TRGB32;
   bgColor : TRGB32;
begin
   if Data = nil then exit;
   ShpContext := Data;
   
   bmp := TBitmap.Create;
   bmp.Width := ShpContext^.SHP.Header.Width;
   bmp.Height := ShpContext^.SHP.Header.Height;
   bmp.PixelFormat := pf32bit;

   bgColor := ColorToRGB32( ShpContext^.ShpPalette[BackGroundColour] );
   gridColor := GetOppositeRGB32( bgColor );

   // DRAW BACKGROUND
   DrawFrameBackground(bmp, bgColor);
   

   // DRAW CROSS
   if show_center then
      DrawCross(bmp, gridColor);

   // DRAW GRID
   if ShowGrid then
      DrawGrid(bmp, gridColor);

   // DRAW FRAME
   DrawFrame(bmp);
   

   // DRAW TOOL PREVIEW
   if (FrmMain.PreviewBrush) and 
      (FrmMain.ActiveForm.Handle = Self.Handle) and // Why is this condition necessary ?
      (FrmMain.TempViewLength > 0) then 
      DrawToolPreview(bmp);

   // DRAW SELECTION
   if (FrmMain.DrawMode = dmselect) or (FrmMain.DrawMode = dmselectmove) then
      DrawSelection(bmp);
   

   //image1.Picture.Bitmap.Width := bmp.Width;
   //image1.Picture.Bitmap.Height := bmp.Height;
   image1.Picture.Bitmap.PixelFormat := pf32bit;
   image1.Canvas.CopyRect( 
      Bounds(0, 0, image1.Picture.Bitmap.Width, image1.Picture.Bitmap.Height), 
      bmp.Canvas, 
      Bounds(0, 0, bmp.Width, bmp.Height));
   bmp.Free;

   image1.Refresh;
end;


//---------------------------------------------
// Set Shadow Mode
//---------------------------------------------
procedure TFrmSHPImage.SetShadowMode(Value : boolean);
var
   SHPData : TSHPImageData;
begin
   // Get Data
   if Data = nil then exit;
   SHPData := Data;

   // Set shadow mode and menu interface
   Shadowmode := value;
   FrmMain.urnToCameoMode1.Checked := value;
   FrmMain.FixShadows1.Enabled := value;

   // Now, time for the status bar and preview window
   if Shadowmode = false then
   begin
      // It must make sure that the preview exists, to avoid
      // access violations.
      if SHPData^.Preview <> nil then
      begin
         SHPData^.Preview^.TrackBar1.Max := SHPData^.SHP.Header.NumImages;
         SHPData^.Preview^.TrackBar1Change(nil);
      end;
      FrmMain.StatusBar1.Panels[4].Text := 'Shadows Off';
   end
   else
   begin
      // It must make sure that the preview exists, to avoid
      // access violations.
      if SHPData^.Preview <> nil then
      begin
         SHPData^.Preview^.TrackBar1.Max := SHPData^.SHP.Header.NumImages div 2;
         SHPData^.Preview^.TrackBar1Change(nil);
      end;
      FrmMain.StatusBar1.Panels[4].Text := 'Shadows On';
   end;
   FrmMain.SetFrameNumber;

   // Refresh palette (turn 2 to 256 or 256 to 2)
   FrmMain.cnvPalette.Refresh;
   // and refresh the image.
   RefreshImage1;
end;


//---------------------------------------------
// Set Active Colour
//---------------------------------------------
procedure TFrmSHPImage.SetActiveColour(Col: Integer);
var
   SHPData: TSHPImageData;
begin
     if Data = nil then exit;
     SHPData := Data;
     ActiveColour := Col;
     FrmMain.pnlActiveColour.Color := SHPData^.SHPPalette[ActiveColour];
     FrmMain.lblActiveColour.Caption := IntToStr(ActiveColour) + ' (0x' + IntToHex(ActiveColour,3) + ')';
     FrmMain.cnvPalette.Repaint;
end;


//---------------------------------------------
// Set Background Color
//---------------------------------------------
procedure TFrmSHPImage.SetBackGroundColour(Col: Integer);
var
   SHPData: TSHPImageData;
begin
   if Data = nil then exit;
   SHPData := Data;
   BackGroundColour := Col;
   
   FrmMain.RefreshShpBackgroundUIComponents;
   FrmMain.cnvPalette.Repaint;
end;


//---------------------------------------------
// Enable/disable background colour.
//---------------------------------------------
procedure TFrmSHPImage.SetBackgroundEnabled(Value: boolean);
var
   SHPData: TSHPImageData;
begin
   BackgroundEnabled := Value;
end;


//---------------------------------------------
// Set Shadow Colour
//---------------------------------------------
procedure TFrmSHPImage.SetShadowColour(Col: Integer);
var
   SHPData : TSHPImageData;
begin
   if Data = nil then exit;
   SHPData := Data;
   if ShadowColour <> Col then
   begin
      if FrmMain.isEditable then
         FrmMain.pnlActiveColour.Color := SHPData^.SHPPalette[Col]
      else
         FrmMain.pnlActiveColour.Color := SHPData^.Shadow_Match[Col].Original;

      ShadowColour := Col;
      FrmMain.lblActiveColour.Caption := IntToStr(ShadowColour) + ' (0x' + IntToHex(ShadowColour,3) + ')';
      FrmMain.cnvPalette.Repaint;
   end;
end;


//---------------------------------------------
// Set Frame Index
// 1..FrameCount
//---------------------------------------------
procedure TFrmSHPImage.SetFrameIndex(v : integer);
var
   ShpContext : TSHPImageData;
   shpName : string;
begin
   ShpContext := Data;

   if (v > 0) and (v <= ShpContext^.Shp.Header.NumImages) and
      FrmMain.OtherOptionsData.ApplySelOnFrameChanging and 
      Selection.HasData and Selection.HasMoved then
      ApplySelection;

   ResetSelection;
   FrameIndex := v;
   RefreshImage1;


   // Update UI
   if (ShpContext^.Filename = '') then
      shpName := 'Untitled ' + IntToStr(ShpContext^.ID)
   else
      shpName := ExtractFilename(ShpContext^.Filename);

   Caption := '[ ' + IntToStr(Zoom) + ' : 1 ] ' 
               + shpName 
               + ' (' + IntToStr(FrameIndex) + '/' + IntToStr(ShpContext^.Shp.Header.NumImages) + ')';

   FrmMain.UpdateFrameUIComponents;
end;


//---------------------------------------------
// Is Click Inside Selection 
//---------------------------------------------
function TFrmSHPImage.IsClickInsideSelection(var s : TSelection; x, y :integer) : boolean;
var
   right, bottom : integer;
begin
   Result := false;
   right := s.X + s.Width;
   bottom := s.Y + s.Height;

   if ( x >= s.X ) and ( x <= right ) and ( y >= s.Y ) and ( y <= bottom ) then
      Result := true;
end;


//---------------------------------------------
// Copy Selected Data to Layer
//---------------------------------------------
procedure TFrmSHPImage.CopySelectionToLayer(var s : TSelection);
var
   x, y, right, bottom : integer;
   ShpContext : TSHPImageData;
begin
   SetLength( s.Layer, s.Width );
   ShpContext := Data;

   for x := 0 to s.Width - 1 do
      begin
      SetLength( s.Layer[x], s.Height );

      for y := 0 to s.Height - 1 do
         begin
         s.Layer[x][y] := ShpContext^.SHP.Data[FrameIndex].FrameImage[ s.X + x ][ s.Y + y];
         end;
      end;
end;


//---------------------------------------------
// Copy Selected Data to Frame
//---------------------------------------------
procedure TFrmSHPImage.CopyLayerToFrame(var s : TSelection);
var
   i, j, x, y, right, bottom : integer;
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;

   for i := 0 to s.Width - 1 do
   begin
      x := s.X + i;
      if (x < 0) or (x >= ShpContext^.SHP.Header.Width) then continue;

      for j := 0 to s.Height - 1 do
      begin
         y := s.Y + j;
         if (y < 0) or (y >= ShpContext^.SHP.Header.Height) then continue;
         if (not BackgroundEnabled) and (s.Layer[i, j] = BackGroundColour) then continue;

         ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y] := s.Layer[i, j];
      end;
   end;
end;


//---------------------------------------------
// Copy TempView to Frame.
//---------------------------------------------
procedure TFrmSHPImage.CopyPreviewToFrame;
var 
   i : integer;
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;
   // Add Undo
   AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrmMain.TempView, FrmMain.TempViewLength, 
      ShpContext^.SHP.Data[FrameIndex].FrameImage, FrameIndex);
   FrmMain.UndoUpdate(ShpContext^.UndoList);

   // Copy TempView
   for i := 0 to FrmMain.TempViewLength - 1 do begin
      ShpContext^.SHP.Data[FrameIndex].FrameImage[
                                          FrmMain.TempView[i].x,
                                          FrmMain.TempView[i].y
                                       ] := GetWorkingColorIndex;
   end;

   FrmMain.ResetTempView;
   RefreshImage1;
end;


//---------------------------------------------
// Reset Selection
//---------------------------------------------
procedure TFrmSHPImage.ResetSelection;
begin
   SetLength( Selection.Layer, 0);
   Selection.HasData := false;
   Selection.HasMoved := false;
   Selection.IsFromClipboard := false;
   Selection.X := 0;
   Selection.Y := 0;
   Selection.Width := 0;
   Selection.Height := 0;

   IsSelecting := false;
end;


//---------------------------------------------
// Cut Selection
//---------------------------------------------
procedure TFrmSHPImage.CutSelection;
var
   ShpContext : TSHPImageData;
   x, y, i, j : integer;
begin
   ShpContext := Data;

   if (Selection.HasMoved) then
      // CUT LAYER 
      ResetSelection
   else begin
      // CUT SELECTED AREA (frame)

      // Add Undo
      AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrameIndex, Selection);
      FrmMain.UndoUpdate(ShpContext^.UndoList);

      // Cut
      for i := 0 to Selection.Width - 1 do begin
         x := Selection.X + i;
         if (x < 0) or (x >= ShpContext^.SHP.Header.Width) then continue;

         for j := 0 to Selection.Height - 1 do begin
            y := Selection.Y + j;
            if (y < 0) or (y >= ShpContext^.SHP.Header.Height) then continue;

            ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y] := 0;
         end;
      end;
   end;
end;


//---------------------------------------------
// Paste Selection
//---------------------------------------------
procedure TFrmSHPImage.PasteSelection(var bmp : TBitmap; algorithm : byte; var selectionPosition : TPoint2D);
var
   ShpContext : TSHPImageData;
   line : TScanline;
   x, y : integer;
   First, Last : listed_colour;
begin
   ShpContext := Data;

   GenerateColourList(ShpContext^.ShpPalette, First, Last, ShpContext^.ShpPalette[0], false, false, false);
   if algorithm = 0 then
      algorithm := AutoSelectALG_Progress(bmp, ShpContext^.ShpPalette, First, Last);

   SetLength(Selection.Layer, bmp.Width, bmp.Height);
   for x := 0 to bmp.Width - 1 do
      for y := 0 to bmp.Height - 1 do
         Selection.Layer[x, y] :=  LoadPixel(bmp, First, Last, algorithm, x, y);

   ClearColourList(First, Last);

   // Set position
   if (selectionPosition.X >= ShpContext^.Shp.Header.Width) or
      (selectionPosition.Y >= ShpContext^.Shp.Header.Height) then
   begin
      Selection.X := 0;
      Selection.Y := 0;
   end
   else
   begin
      Selection.X := selectionPosition.X;
      Selection.Y := selectionPosition.Y;
   end;

   IsSelecting := false;
   Selection.HasData := true;
   Selection.HasMoved := true;
   Selection.Height := bmp.Height;
   Selection.Width := bmp.Width;
   Selection.Visible := true;
   Selection.IsFromClipboard := true;
end;




//---------------------------------------------
// Paste Selection
//---------------------------------------------
procedure TFrmSHPImage.ApplySelection;
var
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;

   AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrameIndex, Selection);
   FrmMain.UndoUpdate(ShpContext^.UndoList);
   CopyLayerToFrame(Selection);

   if Selection.IsFromClipboard then
   begin
      FrmMain.selectionPosition.X := Selection.X;
      FrmMain.selectionPosition.Y := Selection.Y;
   end;
end;


//---------------------------------------------
// Get Working Color
//---------------------------------------------
function TFrmSHPImage.GetWorkingColorIndex : byte;
begin
   // Left Button or No Button
   if (Click = 1) or (Click = 0) or (BackgroundEnabled) then
         Result := ActiveColour
   // Right Button
   else
      Result := BackGroundColour;
end;


//---------------------------------------------
// Dropper - Set SH/AC/BG Color(s)
//---------------------------------------------
procedure TFrmSHPImage.SelectColor(x, y : integer);
var
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;

   if IsShadow(ShpContext^.SHP, FrameIndex) and (shadowmode) then
      SetShadowColour(ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y])
   else if (Click = 1) then
      SetActiveColour(ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y])
   else
      SetBackGroundColour(ShpContext^.SHP.Data[FrameIndex].FrameImage[x, y]);
end;


//---------------------------------------------
// Do Flood - On frame
//---------------------------------------------
procedure TFrmSHPImage.Flood(x, y : integer);
var
   ShpContext : TSHPImageData;
   color : byte;
begin
   ShpContext := Data;

   // ADD TO UNDO
   AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrameIndex);
   FrmMain.UndoUpdate(ShpContext^.UndoList);

   // DETERMINE COLOR
   color := GetWorkingColorIndex;

   // FLOOD AND REFRESH
   FloodFillTool(ShpContext^.SHP, FrameIndex, x, y, color);
   FrmMain.RefreshAll;
end;


//---------------------------------------------
// Do Flood with Gradient - On frame
//---------------------------------------------
procedure TFrmSHPImage.FloodGradient(x, y : integer);
var
   ShpContext : TSHPImageData;
   color : byte;
begin
   ShpContext := Data;

   // ADD TO UNDO
   AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrameIndex);
   FrmMain.UndoUpdate(ShpContext^.UndoList);

   // DETERMINE COLOR
   color := GetWorkingColorIndex;

   // FLOOD AND REFRESH
   FloodFillGradientTool(ShpContext^.SHP, FrameIndex, x, y, ShpContext^.SHPPalette, color);
   FrmMain.RefreshAll;
end;


//---------------------------------------------
// Do Flood with Blur
//---------------------------------------------
procedure TFrmSHPImage.FloodBlur(x, y : integer);
var
   ShpContext : TSHPImageData;
   color : byte;
begin
   ShpContext := Data;

   // ADD TO UNDO
   AddToUndo(ShpContext^.UndoList, ShpContext^.SHP, FrameIndex);
   FrmMain.UndoUpdate(ShpContext^.UndoList);

   // DETERMINE COLOR
   color := GetWorkingColorIndex;

   // FLOOD AND REFRESH
   FloodFillWithBlur(ShpContext^.SHP, FrameIndex, x, y, ShpContext^.SHPPalette, color, FrmMain.alg);
   FrmMain.RefreshAll;
end;


//---------------------------------------------
// Selection Tool - OnMouseDown
//---------------------------------------------
procedure TFrmSHPImage.SelectionOnMouseDown(x, y : integer);
var
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;

   if (Click = 1) then
   begin
      if (Selection.HasData) then
      begin
         if IsClickInsideSelection(Selection, x, y) then
         begin
            // SELECTION START MOVING
            // USER CLICKED IN SELECTION AREA
            Last.X := x;
            Last.Y := y;
            
            FrmMain.drawmode := dmselectmove;
         end
         else
         begin
            // USER CLICKED OUTSIDE THE SELECTION AREA
            if(Selection.HasMoved) then
               ApplySelection;

            ResetSelection;
         end;        
      end;

      // SELECTION START SIZING               
      if (not Selection.HasData) then
      begin
         first.X := x;
         first.Y := y;
         Last.X := x;
         Last.Y := y;

         IsSelecting := true;
         Selection.X := x;
         Selection.Y := y;
         Selection.Width := 1;
         Selection.Height := 1;
      end;
   end
   else
   begin
      // MOUSE RIGHT BUTTON UP
      // CANCEL
      ResetSelection;

      FrmMain.drawmode := dmselect;
   end;

   RefreshImage1;
end;


//---------------------------------------------
// Selection Tool - OnMouseMove
//---------------------------------------------
procedure TFrmSHPImage.SelectionOnMouseMove(x, y : integer);
begin
   if (IsSelecting) and ((Last.X <> x) or (Last.Y <> y)) then
   begin
      // IF LAST VALUE CHANGED
      if(first.X > x) then
      begin
         Selection.X := x;
         Selection.Width := first.X - x + 1;
      end
      else
      begin
         Selection.X := first.X;
         Selection.Width := x - first.X + 1;
      end;
      
      if(first.Y > y) then
      begin
         Selection.Y := y;
         Selection.Height := first.Y - y + 1;
      end
      else
      begin
         Selection.Y := first.Y;
         Selection.Height := y - first.Y + 1;
      end;

      Last.X := x;
      Last.Y := y;
      RefreshImage1;
   end;
end;


//---------------------------------------------
// Selection Tool - OnMouseUp
//---------------------------------------------
procedure TFrmSHPImage.SelectionOnMouseUp;
begin
   if(Click = 1) then
   begin
      if IsSelecting then
      begin
         if (Selection.Width * Selection.Height > 1) then begin
            CopySelectionToLayer(Selection);
            Selection.HasData := true;
            IsSelecting := false;
         end
         else
            ResetSelection;
      end;
   end;
end;


//---------------------------------------------
// Selection Move Tool - OnMouseMove
//---------------------------------------------
procedure TFrmSHPImage.SelectionMoveOnMouseMove(x, y : integer);
var
   XDifference, YDifference : integer;
begin
   if Click = 1 then
   begin
      Selection.HasMoved := true;
      XDifference := x - Last.X;
      YDifference := y - Last.Y;

      Selection.X := Selection.X + XDifference;
      Selection.Y := Selection.Y + YDifference;

      Last.X := x;
      Last.Y := y;
      RefreshImage1;
   end;
end;


//---------------------------------------------
// Selection Move Tool - OnMouseUp
//---------------------------------------------
procedure TFrmSHPImage.SelectionMoveOnMouseUp;
begin
   if Click = 1 then
   begin
      // MOUSE LEFT BUTTON UP
      FrmMain.drawmode := dmselect;
   end;
end;


//---------------------------------------------
// Brush Tools - Preview in TempView
//---------------------------------------------
procedure TFrmSHPImage.PreviewBrush(x, y : integer; colorIndex : byte);
begin
   FrmMain.ResetTempView;
   PreviewStroke(x, y, colorIndex);
end;


//---------------------------------------------
// Pen Drawing - Preview in Tempview 
// 
//---------------------------------------------
procedure TFrmSHPImage.PreviewStroke(x, y : integer; colorIndex : byte);
var
   ShpContext : TSHPImageData;
begin
   ShpContext := Data;
   BrushTool(ShpContext^.SHP, FrmMain.TempView, FrmMain.TempViewLength, x, y, FrmMain.Brush_Type, 
      ShpContext^.SHPPalette[colorIndex]
      );
   RefreshImage1;   
end;


//---------------------------------------------
// Image Mouse Double Click
//---------------------------------------------
procedure TFrmSHPImage.Image1DblClick(Sender: TObject);
begin
   // ...
end;


//---------------------------------------------
// Image Mouse Down
//---------------------------------------------
procedure TFrmSHPImage.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   xx, yy : integer;
   OutOfRange : boolean;
   ShpContext : TSHPImageData;
begin
   if not FrmMain.isEditable then Exit;
   ShpContext := Data;

   // Force window to reactivate because MDI is dumb.
   SendMessage(Handle, WM_MDIACTIVATE, 0, Handle);

   // SET CLICK TYPE
   if (Button = mbLeft) then
      Click :=  1
   else if (Button = mbRight) then
      Click := 2
   else
      Click := 0;

   XX := X;
   YY := Y;
   WorkOutImageClick(ShpContext^.SHP, XX, YY, OutOfRange, zoom);


   if not OutOfRange then
   begin
      Case FrmMain.DrawMode of
         dmDropper : SelectColor(XX, YY);
         dmflood : Flood(XX, YY);
         dmFloodGradient : FloodGradient(XX, YY);
         dmFloodBlur : FloodBlur( XX, YY );
         //dmdarkenlighten : DarkenLightenOnMouseDown(XX, YY);
         dmselect : SelectionOnMouseDown( XX, YY);
      end;
   end;
end;


//---------------------------------------------
// Image Mouse Move
//---------------------------------------------
procedure TFrmSHPImage.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   OutOfRange : boolean;
   XX, YY : integer;
   ShpContext : TSHPImageData;
begin
   if not FrmMain.isEditable then Exit;
   ShpContext := Data;
   XX := X;
   YY := Y;
   WorkOutImageClick(ShpContext^.SHP, XX, YY, OutOfRange, Zoom);


   // DISPLAY MOUSE POSITION
   if not OutOfRange then
     FrmMain.StatusBar1.Panels[2].Text := 'X: ' + inttostr(XX) + ' Y: ' + inttostr(YY);


   // DETERMINE ACTION :
   if not OutOfRange then
   begin
      // no button pressed
      if Click = 0 then
      begin
         // TOOL PREVIEWING
         FrmMain.ResetTempView;

         case FrmMain.DrawMode of
            dmDraw : PreviewStroke(XX, YY, GetWorkingColorIndex);
            //dmErase : PreviewStroke(XX, YY);
            //dmCrash : PreviewCrash(XX, YY);
            //dmLightCrash : PreviewLightCrash(XX, YY);
            //dmBigCrash : PreviewBigCrash(XX, YY);
            //dmBigLightCrash : PreviewBigLightCrash(XX, YY);
            //dmDirty : PreviewDirty(XX, YY);
            //dmSnow : PreviewSnow(XX, YY);
         end; 
         
      end
      // button pressed
      else
      begin
         case FrmMain.DrawMode of
            dmdropper: SelectColor(XX, YY);
            dmDraw: PreviewStroke(XX, YY, GetWorkingColorIndex);
            //dmErase: EraseOnMouseMove(XX, YY);
            //dmline: LineOnMouseMove(XX, YY);
            //dmRectangle: RectangleOnMouseMove(XX, YY, Shift, false); // doFill = FALSE 
            //dmRectangle_Fill: RectangleOnMouseMove(XX, YY, Shift, true); // doFill = TRUE 
            //dmElipse: EllipseOnMouseMove(XX, YY, Shift, false); // doFill = FALSE 
            //dmElipse_Fill: EllipseOnMouseMove(XX, YY, Shift, true); // doFill = TRUE 
            dmselect: SelectionOnMouseMove(XX, YY);
            dmselectmove: SelectionMoveOnMouseMove(XX, YY);
         end; // end of case
      end;
   end;
end;


//---------------------------------------------
// Image Mouse Up
//---------------------------------------------
procedure TFrmSHPImage.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   xx,yy : integer;
   OutOfRange : boolean;
   ShpContext : TSHPImageData;
   Colour : byte;
begin
   if not FrmMain.isEditable then exit;

   // SET CLICK TYPE
   if (Button = mbLeft) then
      Click :=  1
   else if (Button = mbRight) then
      Click := 2
   else
      Click := 0;


   ShpContext := Data;
   XX := X;
   YY := Y;
   WorkOutImageClick(ShpContext^.SHP, XX, YY, OutOfRange, Zoom);

   case (FrmMain.DrawMode) of
      dmDraw : CopyPreviewToFrame;
      //dmCrash: Crash(ShpContext^.SHP, ShpContext^.SHPPalette, LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      //dmLightCrash: CrashLight(ShpContext^.SHP, ShpContext^.SHPPalette, LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      //dmBigCrash: CrashBig(ShpContext^.SHP, ShpContext^.SHPPalette, LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      //dmBigLightCrash: CrashBigLight(ShpContext^.SHP, ShpContext^.SHPPalette, LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      //dmDirty: Dirty(ShpContext^.SHP, ShpContext^.SHPPalette,LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      //dmSnow: Snow(ShpContext^.SHP, ShpContext^.SHPPalette,LastPreview.X, LastPreview.Y, FrameIndex, FrmMain.alg);
      dmselect : SelectionOnMouseUp;
      dmselectmove : SelectionMoveOnMouseUp;
   end;


   Click := 0;

   // REFRESH IMAGE AND PREVIEW (IF != NULL)
   FrmMain.RefreshAll;
end;


//---------------------------------------------
// Form Close
//---------------------------------------------
procedure TFrmSHPImage.FormClose(Sender: TObject; var Action: TCloseAction);
var
   x : TSHPImages;
begin
   // 3.36: Fix closure MDI problems if the window state is
   // not normal.
   WindowState := wsNormal;

   // 3.31: Lock program:
   FrmMain.SetIsEditable(false);
   self.Enabled := false;

   // Remove window menu item related to this editing window.
   FrmMain.RemoveNewWindowMenu(FrmMain.ActiveForm^);

   // Close window.
   FrmMain.CloseClientWindow;

   // final note: TotalImages doesnt drop, so the IDs will
   // always be unique
   action := caFree;
end;


//---------------------------------------------
// Auto Select Cursor for Image1
//---------------------------------------------
procedure TFrmSHPImage.AutoGetCursor;
begin
   if (FrmMain.SpbDraw.Down) or (FrmMain.SpbErase.Down) or (FrmMain.SpbDarkenLighten.Down) then
   begin
      if FrmMain.Brush_Type = 0 then
         Image1.Cursor := MouseDraw
      else if FrmMain.Brush_Type = 4 then
         Image1.Cursor := MouseSpray
      else
         Image1.Cursor := MouseBrush;
   end
   else if (FrmMain.SpbLine.Down) or (FrmMain.SpbFramedRectangle.Down) or (FrmMain.SpbElipse.Down) or (FrmMain.SpbBuildingTools.Down) then
   begin
      Image1.Cursor := MouseLine;
   end
   else if (FrmMain.SpbFloodFill.Down) then
   begin
      Image1.Cursor := MouseFill;
   end
   else if (FrmMain.SpbColorSelector.Down) then
   begin
      Image1.Cursor := MouseDropper;
   end
   else if (FrmMain.SpbSelect.Down) then
   begin
      Image1.Cursor := CrArrow;
   end
   else
      Image1.Cursor := MouseDraw;
end;


//---------------------------------------------
// Form Show
//---------------------------------------------
procedure TFrmSHPImage.FormShow(Sender: TObject);
begin
   ActiveColour := 16;
   ShadowColour := 1;
   SetActiveColour(ActiveColour);

   if FrmMain.ActiveForm = nil then
      AutoGetCursor
   else
      Image1.Cursor := FrmMain.ActiveForm^.Image1.Cursor;

   Zoom := 1; // default value
   FrameIndex := 1; // default value
end;


// 3.35: This function updates the second status bar area
// with SHP Type and Game.
procedure TFrmSHPImage.WriteSHPType;
begin
   FrmMain.StatusBar1.Panels[1].Text := 'SHP Type: ' + GetSHPType(TSHPImageData(Data)^.SHP) +  '(' + GetSHPGame(TSHPImageData(Data)^.SHP) + ')';
end;


// 3.35: This function will validate the SHP Type according to
// the new game selected by user.
procedure TFrmSHPImage.UpdateSHPTypeFromGame;
var
   SHPData : TSHPImageData;
begin
   // Helps to retrive SHP data.
   if Data = nil then exit;   
   SHPData := Data;

   // Check Game.
   case (SHPData^.SHP.SHPGame) of
      sgTD:
      begin // That's the conversion table for TD
         case (SHPData^.SHP.SHPType) of
            stTem: SHPData^.SHP.SHPType := stDes;
            stSno: SHPData^.SHP.SHPType := stWin;
            stInt: SHPData^.SHP.SHPType := stDes;
            stUrb: SHPData^.SHP.SHPType := stDes;
            stLun: SHPData^.SHP.SHPType := stWin;
            stNewUrb: SHPData^.SHP.SHPType := stDes;
         end;
      end;
      sgRA1:
      begin // That's the conversion table for RA1
         case (SHPData^.SHP.SHPType) of
            stDes: SHPData^.SHP.SHPType := stTem;
            stWin: SHPData^.SHP.SHPType := stSno;
            stUrb: SHPData^.SHP.SHPType := stInt;
            stLun: SHPData^.SHP.SHPType := stSno;
            stNewUrb: SHPData^.SHP.SHPType := stInt;
         end;
      end;
      sgTS:
      begin // That's the conversion table for TS
         case (SHPData^.SHP.SHPType) of
            stDes: SHPData^.SHP.SHPType := stTem;
            stWin: SHPData^.SHP.SHPType := stSno;
            stInt: SHPData^.SHP.SHPType := stTem;
            stUrb: SHPData^.SHP.SHPType := stTem;
            stLun: SHPData^.SHP.SHPType := stSno;
            stNewUrb: SHPData^.SHP.SHPType := stTem;
         end;
      end;
      sgRA2:
      begin // RA2 doesn't support is Interior.
         if SHPData^.SHP.SHPType = stInt then
            SHPData^.SHP.SHPType := stUrb;
      end;
   end;
end;


// 3.35: This function updates the Options -> SHP Type menu.
procedure TFrmSHPImage.UpdateSHPTypeMenu;
var
   SHPData : TSHPImageData;
begin
   // Helps to retrive SHP data.
   if Data = nil then exit;
   SHPData := Data;

   // Uncheck the old selected type.
   if FrmMain.CurrentSHPType <> nil then
      FrmMain.CurrentSHPType^.checked := false;

   FrmMain.SHPTypeMenuTD.Checked := false;
   FrmMain.SHPTypeTDNone.Checked := true;
   FrmMain.SHPTypeMenuRA1.Checked := false;
   FrmMain.SHPTypeRA1None.Checked := true;
   FrmMain.SHPTypeMenuTS.Checked := false;
   FrmMain.SHPTypeTSNone.Checked := true;
   FrmMain.SHPTypeMenuRA2.Checked := false;
   FrmMain.SHPTypeRA2None.Checked := true;
   FrmMain.FixShadows1.Enabled := false;

   // We determine the menu item by checking game and type.
   case (SHPData^.SHP.SHPGame) of
      sgTD:
      begin // If the game is Tiberian Dawn:
         FrmMain.SHPTypeMenuTD.Checked := true;
         FrmMain.SHPTypeTDNone.Checked := false;
         FrmMain.RedToRemapable1.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDUnit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDBuilding;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDBuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDAnimation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDCameo;
            stDes: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDDesert;
            stWin: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTDWinter;
         end; // end of TD Type case.
      end; // End of TD
      sgRA1:
      begin // If the game is Red Alert 1:
         FrmMain.SHPTypeMenuRA1.Checked := true;
         FrmMain.SHPTypeRA1None.Checked := false;
         FrmMain.RedToRemapable1.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Unit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Building;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1BuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Animation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Cameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Temperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Snow;
            stInt: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA1Interior;
         end; // end of RA1 Type case.
      end; // End of RA1
      sgTS:
      begin // If the game is Tiberian Sun
         FrmMain.SHPTypeMenuTS.Checked := true;
         FrmMain.SHPTypeTSNone.Checked := false;
         FrmMain.FixShadows1.Enabled := true;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSUnit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSBuilding;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSBuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSAnimation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSCameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSTemperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeTSSnow;
         end; // end of TS Type case.
      end; // End of TS
      sgRA2:
      begin // If the game is Red Alert 2
         FrmMain.SHPTypeMenuRA2.Checked := true;
         FrmMain.SHPTypeRA2None.Checked := false;
         case (SHPData^.SHP.SHPType) of
            stUnit: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Unit;
            stBuilding: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Building;
            stBuildAnim: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2BuildAnim;
            stAnimation: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Animation;
            stCameo: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Cameo;
            stTem: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Temperate;
            stSno: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Snow;
            stUrb: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Urban;
            stDes: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Desert;
            stLun: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2Lunar;
            stNewUrb: FrmMain.CurrentSHPType := @FrmMain.SHPTypeRA2NewUrban;
         end; // end of TS Type case.
      end; // End of TS
   end; // end of case.

   FrmMain.CurrentSHPType^.Checked := true;
end;


//---------------------------------------------
// Form Activate
//---------------------------------------------
procedure TFrmSHPImage.FormActivate(Sender: TObject);
begin
   // Update ActiveData & ActiveForm
   if not FrmMain.isEditable then exit;
   if FrmMain.ActiveForm <> nil then
      Image1.Cursor := FrmMain.ActiveForm^.Image1.Cursor;
   FrmMain.ActiveForm := Address;
   FrmMain.ActiveData := Data;
   SetFocus;
   BringToFront;

   // Update Zoom and Frame
   FrmMain.Zoom_Factor.MaxValue := MaxZoom;
   FrmMain.Zoom_Factor.Value := Zoom;
   FrmMain.Current_Frame.Value := FrameIndex;
   if caption = '' then exit;

   // Update Palette
   if FrmMain.ActiveData^.Filename <> FrmMain.CurrentPaletteID then
      FrmMain.cnvPalette.Repaint;

   // Update Active/Shadow Colours
   SetShadowMode(shadowmode);
   if IsShadow(FrmMain.ActiveData^.SHP, FrameIndex) then
   begin
      FrmMain.lblActiveColour.Caption := IntToStr(ShadowColour) + ' (0x' + IntToHex(ShadowColour,3) + ')';
      FrmMain.pnlActiveColour.Color := FrmMain.ActiveData^.SHPPalette[ShadowColour];
   end
   else
   begin
      FrmMain.pnlActiveColour.Color := FrmMain.ActiveData^.SHPPalette[ActiveColour];
      FrmMain.lblActiveColour.Caption := IntToStr(ActiveColour) + ' (0x' + IntToHex(ActiveColour,3) + ')';
   end;

   // Refresh Background UI Components
   FrmMain.RefreshShpBackgroundUIComponents;

   // Update Undo
   FrmMain.UndoUpdate(FrmMain.ActiveData^.UndoList);
   FrmMain.TbShowCenter.Down := self.show_center;

   // Update Preview Button
   if FrmMain.ActiveData^.Preview = nil then
   begin
      FrmMain.Preview1.Checked := false;
      FrmMain.TbPreviewWindow.Down := false;
   end
   else
   begin
      FrmMain.Preview1.Checked := true;
      FrmMain.TbPreviewWindow.Down := true;
   end;

   // Update StatusBar
   WriteSHPType;
   UpdateSHPTypeMenu;
   FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + inttostr(FrmMain.ActiveData^.SHP.Header.Width) + ' Height: ' + inttostr(FrmMain.ActiveData^.SHP.Header.Height);
end;


//---------------------------------------------
// Form Resize
//---------------------------------------------
procedure TFrmSHPImage.FormResize(Sender: TObject);
var
   SHPData: TSHPImageData;
   width, height : word;
begin

   if C or (Data = nil) then
   begin
      C := False;
      ScrollBox1.HorzScrollBar.Visible := false;
      ScrollBox1.VertScrollBar.Visible := false;
      ScrollBox1.HorzScrollBar.Range := 0;
      ScrollBox1.VertScrollBar.Range := 0;
      Exit;
   end;

   SHPData := Data;

   // Cache basic values
   width := SHPData^.SHP.header.Width * Zoom;
   height := SHPData^.SHP.header.Height * Zoom;

   if ClientWidth < Width then
   begin
      ScrollBox1.HorzScrollBar.Visible := true;
      ScrollBox1.HorzScrollBar.Range := Width;
   end
   else
      ScrollBox1.HorzScrollBar.Visible := false;

   if ClientHeight < Height then
   begin
      ScrollBox1.VertScrollBar.Visible := true;
      ScrollBox1.VertScrollBar.Range := Height;
   end
   else
      ScrollBox1.VertScrollBar.Visible := false;
end;


//---------------------------------------------
// Form Create
//---------------------------------------------
procedure TFrmSHPImage.FormCreate(Sender: TObject);
begin
   C := True;
   Width := 0;
   Height := 0;
   PaintAreaPanel.Width := 0;
   PaintAreaPanel.Height := 0;

   ScrollBox1.DoubleBuffered := true;
   PaintAreaPanel.DoubleBuffered := true;

   Selection.HasData := false;
   Selection.HasMoved := false;
   IsSelecting := false;
   Selection.Visible := true;
   Selection.IsFromClipboard := false;
end;


//---------------------------------------------
// Key Down 
//---------------------------------------------
procedure TFrmSHPImage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   ShpContext : TSHPImageData;
   newFrameIndex : integer;
begin
   if not FrmMain.isEditable then Exit;
   ShpContext := Data;

   // ENTER
   if Key = VK_RETURN then begin
      if FrmMain.DrawMode = dmselect then
      begin
         if Selection.HasData and Selection.HasMoved then
            ApplySelection;

         ResetSelection;
         RefreshImage1;
      end;
   end
   // DELETE
   else if Key = VK_DELETE then begin
      if FrmMain.DrawMode = dmselect then
      begin
         if (Selection.Width > 0) and (not IsSelecting) then
            CutSelection;

         ResetSelection;
         RefreshImage1;
      end; 
   end
   // LEFT ARROW KEY
   else if Key = VK_LEFT then begin
      SelectPrecedingFrame;
   end
   else if Key = VK_RIGHT then begin
      SelectNextFrame;
   end;
end;


//---------------------------------------------
// Select next frame
//---------------------------------------------
procedure TFrmSHPImage.SelectNextFrame;
var
   ShpContext : TSHPImageData;
   newFrameIndex : integer;
   frameCount : integer;
begin
   ShpContext := Data;
   frameCount := ShpContext^.Shp.Header.NumImages;
   if (frameCount < 2) then exit;

   newFrameIndex := FrameIndex + 1;
   if (newFrameIndex > frameCount ) then 
      newFrameIndex := 1;
   SetFrameIndex(newFrameIndex);
end;


//---------------------------------------------
// Select preceding frame
//---------------------------------------------
procedure TFrmSHPImage.SelectPrecedingFrame;
var
   ShpContext : TSHPImageData;
   newFrameIndex : integer;
   frameCount : integer;
begin
   ShpContext := Data;
   frameCount := ShpContext^.Shp.Header.NumImages;
   if (frameCount < 2) then exit;

   newFrameIndex := FrameIndex - 1;
   if (newFrameIndex < 1 ) then 
      newFrameIndex := ShpContext^.Shp.Header.NumImages;
   SetFrameIndex(newFrameIndex);
end;


//---------------------------------------------
// Determine in-range pixel position clicked
//---------------------------------------------
Procedure TFrmSHPImage.WorkOutImageClick(var SHP: TSHP; var X,Y : integer; var OutOfRange : boolean; zoom:byte);
begin
   OutOfRange := true; // Assume True

   x := (x div zoom);
   y := (y div zoom);

   if not ((x >= shp.Header.Width) or (y >= shp.Header.Height) or (x < 0) or (y < 0)) then
      OutOfRange := false;
end;


end.
