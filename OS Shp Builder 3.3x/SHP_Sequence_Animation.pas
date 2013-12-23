unit SHP_Sequence_Animation;

interface
 // BS Animation Sequence File Format
 // TAnim Header
 // -- TAnim Records

type
   Tanimheader = record
      //amount : byte;
      frame_total, anims: cardinal;
   end;

   Tanimtype = record
      StartFrame, Count, Count2: cardinal;
      special: string[10];
   end;

   Tanimrecord = record
      Anim:      Tanimtype;
      Anim_Name: string[20];
   end;



   TAnimations = array of TAnimRecord;

 // BS Animation Sequence Data File Format
 // TAnimData Header
 // -- TAnimData Records

type
   TAnimHeaderData = record
      Anims: cardinal;
   end;

   TAnimDataType = record
      StartFrame, Count, Count2: cardinal;
      Special: string[10];
      Special_Editable, Count2_Editable: boolean;
   end;

   TAnimDataRecord = record
      Anim:      TAnimDataType;
      Anim_Name: string[20];
   end;

   TAnimationsData = array of TAnimDataRecord;


// BS Animation Sequence File Procedure/Functions
procedure SaveASF(Filename: string; Animations: TAnimations;
   AnimationHeader: Tanimheader);
procedure LoadASF(Filename: string; var Animations: TAnimations;
   var AnimationHeader: Tanimheader);

// BS Animation Sequence Data File Procedure/Functions
procedure SaveASDF(Filename: string; Animations: TAnimationsData;
   AnimationHeader: TanimheaderData);
procedure LoadASDF(Filename: string; var Animations: TAnimationsData;
   var AnimationHeader: TanimheaderData);

implementation

// BS Animation Sequence File Procedure/Functions
procedure SaveASF(Filename: string; Animations: TAnimations;
   AnimationHeader: Tanimheader);
var
   f: file;
   Written, Writtent, x: integer;
begin
   Writtent := 0;

   AssignFile(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   BlockWrite(F, AnimationHeader, Sizeof(Tanimheader), Written); // Write Header
   Writtent := Writtent + Written;

   for x := 1 to AnimationHeader.anims do
   begin
      BlockWrite(F, Animations[x], Sizeof(TAnimRecord), Written);
      Writtent := Writtent + Written;
   end;

   CloseFile(F);

end;

procedure LoadASF(Filename: string; var Animations: TAnimations;
   var AnimationHeader: Tanimheader);
var
   f:    file;
   Read, x: integer;
   Anim: array of char;
begin

   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?


   BlockRead(F, AnimationHeader, Sizeof(Tanimheader)); // Read Header

   setlength(Animations, AnimationHeader.anims + 1);

   for x := 1 to AnimationHeader.anims do // Load Image Animations
      BlockRead(F, Animations[x], Sizeof(TAnimRecord));

   CloseFile(F);

end;

// BS Animation Sequence Data File Procedure/Functions
procedure SaveASDF(Filename: string; Animations: TAnimationsData;
   AnimationHeader: TanimheaderData);
var
   f: file;
   Written, Writtent, x: integer;
begin
   Writtent := 0;

   AssignFile(F, Filename);  // Open file
   Rewrite(F, 1); // Goto first byte?

   BlockWrite(F, AnimationHeader, Sizeof(TanimheaderData), Written); // Write Header
   Writtent := Writtent + Written;

   for x := 1 to AnimationHeader.anims do
   begin
      BlockWrite(F, Animations[x], Sizeof(TAnimDataRecord), Written);
      Writtent := Writtent + Written;
   end;

   CloseFile(F);

end;

procedure LoadASDF(Filename: string; var Animations: TAnimationsData;
   var AnimationHeader: TanimheaderData);
var
   f:    file;
   Read, x: integer;
   Anim: array of char;
begin

   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?


   BlockRead(F, AnimationHeader, Sizeof(TanimheaderData)); // Read Header

   setlength(Animations, AnimationHeader.anims + 1);

   for x := 1 to AnimationHeader.anims do // Load Image Animations
      BlockRead(F, Animations[x], Sizeof(TAnimDataRecord));

   CloseFile(F);

end;

end.
