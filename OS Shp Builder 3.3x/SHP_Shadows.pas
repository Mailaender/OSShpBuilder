unit SHP_Shadows;

interface

uses
   SHP_File;

function IsShadow(SHP: TSHP; Frame: integer): boolean;
function GetOposite(var SHP: TSHP; const Frame: integer): integer;
function GetShadowOposite(SHP: TSHP; Frame: integer): integer;
function GetShadowFromOposite(SHP: TSHP; Frame: integer): integer;
function HasShadows(SHP: TSHP): boolean;

implementation

function IsShadow(SHP: TSHP; Frame: integer): boolean;
var
   shadow_start: integer;
begin
   Result := False;
   // Shadows start half way through the file +1 frame
   shadow_start := (SHP.Header.NumImages div 2) + 1;

   // Check to see if current frame is above or equal to the shadow start value
   if frame >= shadow_start then
      Result := True;

   if (SHP.SHPType = stCameo) or (SHP.SHPGame = sgTD) or (SHP.SHPGame = sgRA1) then
      // Check if it is not a unit/building/animation.
      Result := False; // Only Units/buildings/animations have shadows
end;

function GetShadowOposite(SHP: TSHP; Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (SHP.Header.NumImages div 2);

   if not IsShadow(SHP, Frame) then
      Result := 0 // Error;
   else
      Result := Frame - shadow_start;
end;

function GetShadowFromOposite(SHP: TSHP; Frame: integer): integer;
var
   shadow_start: integer;
begin
   // Shadows start half way through the file
   shadow_start := (SHP.Header.NumImages div 2);

   Result := Frame + shadow_start;
end;

function GetOposite(var SHP: TSHP; const Frame: integer): integer;
begin
   if IsShadow(SHP, Frame) then
      Result := GetShadowOposite(SHP, Frame)
   else
      Result := GetShadowFromOposite(SHP, Frame);
end;

function HasShadows(SHP: TSHP): boolean;
begin
   Result := True; // Assume True
   if (SHP.SHPType = stcameo) or (SHP.SHPType = sttem) or (SHP.SHPType = stsno) or
      (SHP.SHPType = stAnimation) then
      Result := False;
   if (SHP.SHPGame = sgTD) or (SHP.SHPGame = sgRA1) then
      Result := False;
end;

end.
