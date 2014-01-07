unit SHP_DataMatrix;

interface

uses SHP_File, Palette, Undo_Redo, SHP_Engine, SHP_Image,
   FormPreview, FormSHPImage, SHP_Shadows, Menus, Dialogs,
   SHP_RA_File, Math, FormInstall;

type

   //---------------------------------------------
   // SHP Form cell for chained list
   //---------------------------------------------
   TSHPImageForm = ^tshpimageformitem;
   tshpimageformitem = record
      Item: TFrmSHPImage;
      Next: TSHPImageForm;
   end;


   //---------------------------------------------
   // SHP Context - Form, SHP, Palette, Undo, etc.
   //---------------------------------------------
   TSHPImageData = ^TSHPImageDataItem;
   TSHPImageDataItem = record
      ID:      word;
      SHP:     TSHP;
      SHPPalette: TPalette;
      SHPPaletteFilename: string;
      PaletteMax: word;
      UndoList: TUndoRedo;
      LastUndo: integer;
      Shadow_Match: TShadowMatch;
      Filename: string;
      Form:    TSHPImageForm;
      Preview: ^TFrmPreview;
      Next:    TSHPImageData;
   end;

// SHP Data Manipulation Procedures

procedure GenerateShadowCache(ID: word); overload;
procedure GenerateShadowCache(var Data: TSHPImageData); overload;
procedure GenerateShadowCache(var Shadow_Match: TShadowMatch; SHPPalette: TPalette); overload;

procedure SelectPalette(var Data : TSHPImageData);
procedure GetPaletteForSHP(const SHP: TSHP; var Filename: string);

procedure ClearUpData(var Data: TSHPImageData);

procedure AddNewSHPDataItem; overload;
function AddNewSHPDataItem(var Data: TSHPImageData; ID, Frames, Width, Height, Game, SHPType: word): Boolean; overload;
function AddNewSHPDataItem(var Data: TSHPImageData; ID: word; var SHP: TSHP; var SHPPalette: TPalette; pal_name: string; SHPGame, SHPType: word): Boolean; overload;
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID: word; Filename: string); overload;
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID, Width, Height: word; Game: TSHPGame); overload;
function AddNewSHPDataItem(var Data: TSHPImageData; const CurrentData: TSHPImageData; ID, ActiveFrame, HorizontalFrames, VerticalFrames, Order, Width, Height: integer): Boolean; overload;
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID, Frames, Width, Height: word; PaletteFilename: string); overload;


procedure LoadNewSHPImageSettings(var Data: TSHPImageData; var Form: TFrmSHPImage);


//=============================================
// Global Variables
//=============================================
var
   MainData: TSHPImageData;// First cell in the chained list of opened SHPs.


//=============================================
// Implementation
//=============================================
implementation
uses FormMain, SysUtils, Windows, Forms;


//---------------------------------------------
// Generate Shadow Cache 
// PARAM:
//    - ID : SHP Context ID 
//---------------------------------------------
procedure GenerateShadowCache(ID: word); overload;
var
   x: byte;
   p: TSHPImageData;
begin
   // search for address
   if MainData <> nil then
   begin
      p := MainData;
      while ((p^.Next <> nil) and (p^.ID <> ID)) do
         p := p^.Next;

      for x := 0 to 255 do
         p^.Shadow_Match[x].Original := colourtogray(p^.SHPPalette[x]);
   end;
end;


//---------------------------------------------
// Generate Shadow Cache
// PARAM:
//    - Data : SHP Context
//---------------------------------------------
procedure GenerateShadowCache(var Data: TSHPImageData); overload;
var
   x: byte;
begin
   if Data <> nil then
   begin
      for x := 0 to 255 do
         Data^.Shadow_Match[x].Original := colourtogray(Data^.SHPPalette[x]);
   end;
end;


//---------------------------------------------
// Generate Shadow Cache
//    - Shadow_Match : grayscale/shadow palette
//    - SHPPalette   : Base palette
//---------------------------------------------
procedure GenerateShadowCache(var Shadow_Match: TShadowMatch; SHPPalette: TPalette);
var
   x: byte;
begin
   for x := 0 to 255 do
      Shadow_Match[x].Original := colourtogray(SHPPalette[x]);
end;


//-------------------------------------------
// Select Palette for Shp Item.
//-------------------------------------------
procedure SelectPalette(var Data : TSHPImageData);
begin

   if  (not FrmMain.OtherOptionsData.AutoSelectSHPType) then
   begin
      Data^.SHPPaletteFilename := FrmMain.OtherOptionsData.LastPalettePath;
   end
   else
   begin
      if FrmMain.PalettePreferenceData.GameSpecific then
      begin
         GetPaletteForSHP(Data^.SHP, Data^.SHPPaletteFilename);
      end
      else
         Data^.SHPPaletteFilename := FrmMain.AppConstants.DefaultPaletteFilename;
   end;

   FrmMain.OtherOptionsData.LastPalettePath := Data^.SHPPaletteFilename;
end;


//---------------------------------------------
// 3.35 Inteligent Palette Detection
//---------------------------------------------
procedure GetPaletteForSHP(const SHP: TSHP; var Filename: string);
begin
   if SHP.SHPGame = sgTD then
   begin // Begins TD code here
      Filename := FrmMain.PalettePreferenceData.TDPalette.Filename;
   end
   else if SHP.SHPGame = sgRA1 then
   begin // Begins RA1 code here
      if SHP.SHPType = stUnit then
         Filename := FrmMain.PalettePreferenceData.RA1UnitPalette.Filename
      else if SHP.SHPType = stBuilding then
         Filename := FrmMain.PalettePreferenceData.RA1BuildingPalette.Filename
      else if SHP.SHPType = stBuildAnim then
         Filename := FrmMain.PalettePreferenceData.RA1BuildingAnimationPalette.Filename
      else if SHP.SHPType = stAnimation then
         Filename := FrmMain.PalettePreferenceData.RA1AnimationPalette.Filename
      else if SHP.SHPType = stCameo then
         Filename := FrmMain.PalettePreferenceData.RA1CameoPalette.Filename
      else if SHP.SHPType = stTem then
         Filename := FrmMain.PalettePreferenceData.RA1TemperatePalette.Filename
      else if SHP.SHPType = stSno then
         Filename := FrmMain.PalettePreferenceData.RA1SnowPalette.Filename
      else if SHP.SHPType = stInt then
         Filename := FrmMain.PalettePreferenceData.RA1InteriorPalette.Filename;
   end
   else if SHP.SHPGame = sgTS then
   begin // Begins TS code here
      if SHP.SHPType = stUnit then
         Filename := FrmMain.PalettePreferenceData.TSUnitPalette.Filename
      else if SHP.SHPType = stBuilding then
         Filename := FrmMain.PalettePreferenceData.TSBuildingPalette.Filename
      else if SHP.SHPType = stBuildAnim then
         Filename := FrmMain.PalettePreferenceData.TSBuildingAnimationPalette.Filename
      else if SHP.SHPType = stAnimation then
         Filename := FrmMain.PalettePreferenceData.TSAnimationPalette.Filename
      else if SHP.SHPType = stCameo then
         Filename := FrmMain.PalettePreferenceData.TSCameoPalette.Filename
      else if SHP.SHPType = stTem then
         Filename := FrmMain.PalettePreferenceData.TSIsoTemPalette.Filename
      else if SHP.SHPType = stSno then
         Filename := FrmMain.PalettePreferenceData.TSIsoSnowPalette.Filename;
   end
   else // RA2 code starts here
   begin
      if SHP.SHPType = stUnit then
         Filename := FrmMain.PalettePreferenceData.RA2UnitPalette.Filename
      else if SHP.SHPType = stBuilding then
         Filename := FrmMain.PalettePreferenceData.RA2BuildingPalette.Filename
      else if SHP.SHPType = stBuildAnim then
         Filename := FrmMain.PalettePreferenceData.RA2BuildingAnimationPalette.Filename
      else if SHP.SHPType = stAnimation then
         Filename := FrmMain.PalettePreferenceData.RA2AnimationPalette.Filename
      else if SHP.SHPType = stCameo then
         Filename := FrmMain.PalettePreferenceData.RA2CameoPalette.Filename
      else if SHP.SHPType = stTem then
         Filename := FrmMain.PalettePreferenceData.RA2IsoTemPalette.Filename
      else if SHP.SHPType = stSno then
         Filename := FrmMain.PalettePreferenceData.RA2IsoSnowPalette.Filename
      else if SHP.SHPType = stUrb then
         Filename := FrmMain.PalettePreferenceData.RA2IsoUrbPalette.Filename
      else if SHP.SHPType = stDes then
         Filename := FrmMain.PalettePreferenceData.RA2IsoDesPalette.Filename
      else if SHP.SHPType = stLun then
         Filename := FrmMain.PalettePreferenceData.RA2IsoLunPalette.Filename
      else if SHP.SHPType = stNewUrb then
         Filename := FrmMain.PalettePreferenceData.RA2IsoNewUrbPalette.Filename;
   end;
end;


//---------------------------------------------
// Clear Up SHP Context
//---------------------------------------------
procedure ClearUpData(var Data: TSHPImageData);
var
   a: TSHPImageData;
   counter : integer;
begin
   if MainData <> nil then
   begin
      a := MainData;
      while a^.Next <> Data do
         a := a^.Next;
      a^.Next := Data^.Next;
      for counter := Low(Data^.SHP.Data) to High(Data^.SHP.Data) do
      begin
         SetLength(Data^.SHP.Data[counter].FrameImage,0,0);
         SetLength(Data^.SHP.Data[counter].Databuffer,0);
      end;
      SetLength(Data^.SHP.Data,0);
      Dispose(Data);
   end;
end;


//---------------------------------------------
// Add Empty SHP Context 
//---------------------------------------------
procedure AddNewSHPDataItem; overload;
var
   FrmInstall: TFrmRepairAssistant;
begin
   new(MainData);
   MainData^.ID := 0;
   NewSHP(MainData^.SHP, 1, 1, 1);

   MainData^.SHPPaletteFilename := FrmMain.AppConstants.DefaultPaletteFilename;
   LoadPaletteFromFile(MainData^.SHPPaletteFilename, MainData^.SHPPalette);

   MainData^.PaletteMax := 256;
   ClearUndo(MainData^.UndoList);
   GenerateShadowCache(MainData);
   MainData^.Filename := '';
   MainData^.Form     := nil;
   MainData^.Preview  := nil;
   MainData^.Next     := nil;
   FrmMain.ActiveForm := nil;
   FrmMain.ActiveData := MainData;
end;


//---------------------------------------------
// Add New Item with nearly all default values.
// For File -> New
//---------------------------------------------
function AddNewSHPDataItem(var Data: TSHPImageData; ID, Frames, Width, Height, Game, SHPType: word): Boolean; overload;
const
   GameArray: array [0..3] of TSHPGame = (sgTD, sgRA1, sgTS, sgRA2);
   TDArray: array [1..7] of TSHPType = (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, stdes, stwin);
   RA1Array: array [1..8] of TSHPType = (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno, stint);
   TSArray: array [1..7] of TSHPType = (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno);
   RA2Array: array [1..11] of TSHPType = (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno, sturb, stdes, stlun, stnewurb);
var
   a: TSHPImageData;
   counter : integer;
begin
   Result := false;
   if MainData = nil then exit;

   // Initialize Data
   new(Data);
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Init. SHP with default values.
   Data^.ID := ID;
   try
      NewSHP(Data^.SHP, Frames, Width, Height)
   except // 3.36: Treatment for 'Out of memory', people!
      ShowMessage('Sorry, but your new document could not be created.');
      a^.Next := nil;
      for counter := Low(Data^.SHP.Data) to High(Data^.SHP.Data) do
      begin
         SetLength(Data^.SHP.Data[counter].FrameImage,0,0);
         SetLength(Data^.SHP.Data[counter].Databuffer,0);
      end;
      SetLength(Data^.SHP.Data,0);
      Dispose(Data);
      exit;
   end;

   // Set GameType
   Data^.SHP.SHPGame := GameArray[Game];
   if SHPType <> 0 then
   begin
      case (Game) of
         0: Data^.SHP.SHPType := TDArray[SHPType];
         1: Data^.SHP.SHPType := RA1Array[SHPType];
         2: Data^.SHP.SHPType := TSArray[SHPType];
         3: Data^.SHP.SHPType := RA2Array[SHPType];
      end;
   end;

   // Init. remaining values
   SelectPalette(Data);
   Data^.PaletteMax := 256;
   ClearUndo(Data^.UndoList);
   Data^.Filename := '';


   LoadPaletteFromFile(Data^.SHPPaletteFilename, Data^.SHPPalette);
   GenerateShadowCache(Data);
   Result := true;
end;


//---------------------------------------------
// File -> Import Image As SHP
//---------------------------------------------
function AddNewSHPDataItem(var Data: TSHPImageData; ID: word; var SHP: TSHP; var SHPPalette: TPalette; pal_name: string; SHPGame, SHPType: word): Boolean; overload;
const
   GameArray: array [0..3] of TSHPGame = (sgTD, sgRA1, sgTS, sgRA2);
   TDArray: array [1..7] of TSHPType =
      (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, stdes, stwin);
   RA1Array: array [1..8] of TSHPType =
      (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno, stint);
   TSArray: array [1..7] of TSHPType =
      (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno);
   RA2Array: array [1..11] of TSHPType =
      (stUnit, stBuilding, stBuildAnim, stAnimation, stCameo, sttem, stsno,
      sturb, stdes, stlun, stnewurb);
var
   a: TSHPImageData;
begin
   // Initialize Data
   Result := false;
   if MainData = nil then exit;

   try
      new(Data);
   except
      exit;
   end;
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Now, filling the new item with the default values:
   Data^.ID  := ID;
   Data^.SHP := SHP;
   Data^.SHPPalette := SHPPalette;
   Data^.SHPPaletteFilename := Pal_name;
   Data^.PaletteMax := 256;
   // Palette and SHP Type settings
   Data^.SHP.SHPGame := GameArray[SHPGame];
   if SHPType <> 0 then
   begin
      case (SHPGame) of
         0: Data^.SHP.SHPType := TDArray[SHPType];
         1: Data^.SHP.SHPType := RA1Array[SHPType];
         2: Data^.SHP.SHPType := TSArray[SHPType];
         3: Data^.SHP.SHPType := RA2Array[SHPType];
      end;
   end;

   ClearUndo(Data^.UndoList);
   Data^.Filename := '';

   GenerateShadowCache(Data);
   Result := true;
end;


//---------------------------------------------
// File -> Open
//---------------------------------------------
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID: word; Filename: string); overload;
var
   a:     TSHPImageData;
   isLoaded: boolean;
   SHPTD: C_SHPTD;
begin
   // Initialize Data
   if MainData = nil then exit;

   new(Data);
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Now, filling the new item with the default values:
   Data^.ID := ID;
   case FrmMain.loadmode of
      0: isLoaded := LoadSHP(Filename, Data^.SHP);
      1: isLoaded := LoadSHPSafe(Filename, Data^.SHP);
      2:
         try
            isLoaded := LoadSHP(Filename, Data^.SHP);
         except
            isLoaded := LoadSHPSafe(Filename, Data^.SHP);
         end;
      3: isLoaded := LoadSHPWithLog(Filename, Data^.SHP);
      4:
         try
            isLoaded := LoadSHPSupraFast(Filename, Data^.SHP);
         except
            isLoaded := LoadSHP(Filename, Data^.SHP);
         end;
      else
         isLoaded := LoadSHP(Filename, Data^.SHP);
   end;

   if not isLoaded then // It might be a RA1 SHP.
   begin
      SHPTD := C_SHPTD.Create;
      try
         SHPTD.Load(Filename);
      except // This should shut up any access violations...
         SHPTD.IsValid := False;
      end;
      if SHPTD.IsValid then
      begin
         Data^.SHP := SHPTD.getSHP;
      end
      else
      begin
         // This file isn't supported by the program
         raise EFileError.Create('File not supported by OS SHP Builder');
         exit;
      end;
   end
   else
      CreateFrameImages(Data^.SHP);

   
   // Init. remaining values.
   SelectPalette(Data);
   Data^.PaletteMax := 256;
   ClearUndo(Data^.UndoList);
   Data^.Filename := Filename;

   GenerateShadowCache(Data);
   LoadPaletteFromFile(Data^.SHPPaletteFilename, Data^.SHPPalette);
end;


//---------------------------------------------
// Cameo Generator
//---------------------------------------------
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID, Width, Height: word; Game: TSHPGame); overload;
var
   a: TSHPImageData;
begin
   // Initialize Data
   if MainData = nil then exit;

   new(Data);
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Now, filling the new item with the default values:
   Data^.ID := ID;
   NewSHP(Data^.SHP, 1, Width, Height);

   if (Width = 60) then
   begin
      if fileexists(extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal') then
      begin
         Data^.SHPPaletteFilename := extractfiledir(ParamStr(0)) + '\Palettes\RA2\cameo.pal';
         Data^.SHP.SHPGame := sgRA2;
      end
      else
         halt;
   end
   else
   begin
      case (Game) of
         sgTD:
         begin
            if fileexists(extractfiledir(ParamStr(0)) + '\Palettes\TD\temperat.pal') then
            begin
               Data^.SHPPaletteFilename := extractfiledir(ParamStr(0)) + '\Palettes\TD\temperat.pal';
               Data^.SHP.SHPGame := sgTD;
            end
            else
               halt;
         end;
         sgRA1:
         begin
            if fileexists(extractfiledir(ParamStr(0)) + '\Palettes\RA1\temperat.pal') then
            begin
               Data^.SHPPaletteFilename := extractfiledir(ParamStr(0)) + '\Palettes\RA1\temperat.pal';
               Data^.SHP.SHPGame := sgRA1;
            end
            else
               halt;
         end;
         sgTS:
         begin
            if fileexists(extractfiledir(ParamStr(0)) + '\Palettes\TS\cameo.pal') then
            begin
               Data^.SHPPaletteFilename := extractfiledir(ParamStr(0)) + '\Palettes\TS\cameo.pal';
               Data^.SHP.SHPGame := sgTS;
            end
            else
               halt;
         end; // end of TS
      end; // end of case
   end;

   Data^.SHP.SHPType := stCameo;
   Data^.PaletteMax := 256;
   ClearUndo(Data^.UndoList);
   Data^.Filename := '';

   LoadPaletteFromFile(Data^.SHPPaletteFilename, Data^.SHPPalette);
   GenerateShadowCache(Data);
end;


//---------------------------------------------
// For Copy Frames
//---------------------------------------------
procedure AddNewSHPDataItem(var Data: TSHPImageData; ID, Frames, Width, Height: word; PaletteFilename: string); overload;
var
   a: TSHPImageData;
begin
   // Initialize Data
   if MainData = nil then exit;

   new(Data);
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Now, filling the new item with the default values:
   Data^.ID := ID;
   NewSHP(Data^.SHP, Frames, Width, Height);
   Data^.SHPPaletteFilename := PaletteFileName;
   
   Data^.PaletteMax := 256;
   ClearUndo(Data^.UndoList);
   Data^.Filename := '';

   LoadPaletteFromFile(Data^.SHPPaletteFilename, Data^.SHPPalette);
   GenerateShadowCache(Data);
end;


//---------------------------------------------
// Frame Splitter
//---------------------------------------------
function AddNewSHPDataItem(var Data: TSHPImageData; const CurrentData: TSHPImageData; ID, ActiveFrame, HorizontalFrames, VerticalFrames, Order, Width, Height: integer): Boolean; overload;
var
   a: TSHPImageData;
   TotalFrames, CurrentFrame, HCount, VCount, CurrentX, X, CurrentY, Y: longword;
begin
   // Initialize Data
   Result := false;
   if MainData = nil then exit;

   try
      new(Data);
   except
      exit;
   end;
   a := MainData;
   while a^.Next <> nil do
      a := a^.Next;
   a^.Next := Data;
   Data^.Next    := nil;
   Data^.Form    := nil;
   Data^.Preview := nil;

   // Now, filling the new item with the default values:
   Data^.ID := ID;

   // Setup SHP
   TotalFrames := HorizontalFrames * VerticalFrames;
   try
      setlength(Data^.SHP.Data, TotalFrames + 1);
   except
      ClearUpData(Data);
      exit;
   end;
   Data^.SHP.Header.Width     := Width;
   Data^.SHP.Header.Height    := Height;
   Data^.SHP.Header.NumImages := TotalFrames;

   // Reset X and Y:
   CurrentY     := 0;
   CurrentX     := 0;
   CurrentFrame := 1;

   // generate frames
   if order = 0 then
   begin
      for VCount := 1 to VerticalFrames do
      begin
         CurrentX := 0;
         for HCount := 1 to HorizontalFrames do
         begin
            Data^.SHP.Data[CurrentFrame].Header_Image.cx := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.cy := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.x  := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.y  := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.compression := 1;
            Data^.SHP.Data[CurrentFrame].Header_Image.align[0] := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.align[1] := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.align[2] := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.offset := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.zero := 0;
            Data^.SHP.Data[CurrentFrame].Header_Image.RadarColor := 0;

            try
               SetLength(Data^.SHP.Data[CurrentFrame].FrameImage, Width, Height);
            except
               ClearUpData(Data);
               exit;
            end;
            for X := 0 to (Width - 1) do
            begin
               for Y := 0 to (Height - 1) do
               begin
                  Data^.SHP.Data[CurrentFrame].FrameImage[x, y] := CurrentData^.SHP.Data[ActiveFrame].FrameImage[CurrentX + x, CurrentY + y];
               end;
            end;
            Inc(CurrentFrame);
            Inc(CurrentX, Width);
         end;
         Inc(CurrentY, Height);
      end;
   end
   else
   begin
      for HCount := 1 to HorizontalFrames do
      begin
         CurrentY := 0;
         for VCount := 1 to VerticalFrames do
         begin
            try
               SetLength(Data^.SHP.Data[CurrentFrame].FrameImage, Width, Height);
            except
               ClearUpData(Data);
               exit;
            end;
            for X := 0 to (Width - 1) do
            begin
               for Y := 0 to (Height - 1) do
               begin
                  Data^.SHP.Data[CurrentFrame].FrameImage[x, y] := CurrentData^.SHP.Data[ActiveFrame].FrameImage[CurrentX + x, CurrentY + y];
               end;
            end;
            Inc(CurrentFrame);
            Inc(CurrentY, Height);
         end;
         Inc(CurrentX, Width);
      end;
   end;

   Data^.SHP.SHPType := CurrentData^.SHP.SHPType;
   Data^.SHPPaletteFilename := CurrentData^.SHPPaletteFilename;
   Data^.PaletteMax  := 256;
   
   ClearUndo(Data^.UndoList);
   Data^.Filename := '';

   GenerateShadowCache(Data);
   LoadPaletteFromFile(Data^.SHPPaletteFilename, Data^.SHPPalette);
   Result := true;
end;


//---------------------------------------------
// Load SHP Context Settings in Form Main and SHP
//---------------------------------------------
procedure LoadNewSHPImageSettings(var Data: TSHPImageData; var Form: TFrmSHPImage);
begin
   if Data = nil then exit;

   // This code avoids OutOfResources Errors on enourmous pictures:
   Form.ShowCenter := False;
   FrmMain.TbShowCenter.Down := False;

   // BackgroundColour
   FrmMain.SetBackgroundColorEnabled(FrmMain.OtherOptionsData.BackgroundColorEnabled);
   Form.SetBackGroundColour(0);

   // Status Bar Updates
   FrmMain.StatusBar1.Panels[0].Text := 'Owner Frame';
   FrmMain.StatusBar1.Panels[3].Text := 'Width: ' + IntToStr(Data^.SHP.Header.Width) + ' Height: ' + IntToStr(Data^.SHP.Header.Height);
   Form.WriteSHPType;
   Form.UpdateSHPTypeMenu;

   // Control Zoom:
   if Data^.SHP.Header.Width * Data^.SHP.Header.Height > 90000 then
   begin
      Form.Zoom := 1;
   end
   else if Data^.SHP.Header.Width * Data^.SHP.Header.Height > 2500 then
   begin
      Form.Zoom := 2;
   end
   else if Data^.SHP.Header.Width * Data^.SHP.Header.Height > 100 then
   begin
      Form.Zoom := 4;
   end
   else
   begin
      Form.Zoom := 8;
   end;

   // Calculate MaxZoom available.
   Form.MaxZoom := 32767 div max(Data^.SHP.Header.Height, Data^.SHP.Header.Width);
   FrmMain.Zoom_Factor.MaxValue := Form.MaxZoom;

   FrmMain.Zoom_Factor.Value := Form.Zoom;

   // PaintArea and Image Update
   Form.ResizePaintArea(Form.Image1, Form.PaintAreaPanel);
   Form.FrameIndex := 1;
   FrmMain.Current_Frame.Value := Form.FrameIndex;

   // Caption := SHP_BUILDER_TITLE + ' ' + SHP_BUILDER_VER +  ' - [Untitled.shp]';
   if (Data^.Filename = '') then
      Form.Caption := '[ ' + IntToStr(Form.Zoom) + ' : 1 ] ' + 'Untitled ' + IntToStr(Data^.ID) + ' (' + IntToStr(Form.FrameIndex) + '/' + IntToStr(Data^.SHP.Header.NumImages) + ')'
   else
      Form.Caption := '[ ' + IntToStr(Form.Zoom) + ' : 1 ] ' + extractfilename(Data^.Filename) + ' (' + IntToStr(Form.FrameIndex) + '/' + IntToStr(Data^.SHP.Header.NumImages) + ')';

   // Display Total Frames
   FrmMain.SetFrameNumber;

   // OS SHP Builder 3.33: Show Grids.
   FrmMain.ShowNone1Click(nil);

   // Shadow and Image Full Update
   Form.SetShadowMode(HasShadows(Data^.SHP));

   // I believe the line below is already ran by SetShadowMode
   // NewImage.Item.Current_FrameChange(Sender);

   FrmMain.SetIsEditable(True);
   FrmMain.UndoUpdate(Data^.UndoList);

   // Add a window menu item for this window:
   if Data^.Filename <> '' then
      FrmMain.AddNewWindowMenu(Form, Data^.Filename)
   else
      FrmMain.AddNewWindowMenu(Form, 'Untitled ' + IntToStr(Data^.ID));

   // 3.36: Preview check
   FrmMain.Preview1.Checked := false;
   FrmMain.TbPreviewWindow.Down := false;

   // The final stuff.
   FrmMain.lblPalette.Caption := ExtractFilename(Data^.SHPPaletteFilename);
   Data^.LastUndo  := 0;
end;


end.
