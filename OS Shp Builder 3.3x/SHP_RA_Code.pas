unit SHP_RA_Code;

 // The purpose of this file is to encode and decode SHP TD
 // files. We are using code from:

 // XCC Utilities, created by
 // Olaf Van Der Spek

interface

uses SHP_File, Dialogs, SysUtils;

// Function List:


//---------------------------------------------------------
// Auxiliary functions

function read_w(var Source: PByte): word;
function get_run_length(const Source: PByte; const s_end: PByte): integer;

procedure write_w(Data: word; var Dest: PByte);
procedure flush_copy(var Dest: PByte; const Source: PByte; var Copy_from: PByte);
procedure get_same(const Source: PByte; const r: PByte; const SourceEnd: PByte; var p: PByte; var cb_p: integer);
procedure new_get_same(const Source: PByte; const r: PByte; const SourceEnd: PByte; var p: PByte; var cb_p: integer);


//---------------------------------------------------------
// Auxiliary Format 40 encoding functions:

procedure write_v40(Data: byte; Counter: integer; var Dest: PByte);
procedure write40_c0(var Dest: PByte; Counter: integer; Data: integer);
procedure write40_c1(var Dest: PByte; Counter: integer; const Source: PByte);
procedure write40_c2(var Dest: PByte; Counter: integer);
procedure write40_c3(var Dest: PByte; Counter: integer; const Source: PByte);
procedure write40_c4(Dest: PByte; Counter: integer; Data: integer);
procedure write40_c5(var Dest: PByte; Counter: integer);
procedure write40_copy(var Dest: PByte; Counter: integer; var Source: PByte);
procedure write40_fill(var Dest: PByte; Counter: integer; Data: integer);
procedure write40_skip(var Dest: PByte; Counter: integer);


//---------------------------------------------------------
// Encode 40 functions

function encode40(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;
function encode40_y(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;
function encode40_z(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;


//---------------------------------------------------------
// Decode 40 functions

function Decode40(const Source: PByte; var Dest: PByte): integer;
function Decode40Tri(const Source: PByte; const XorDest: PByte; var Dest: PByte): integer;


//---------------------------------------------------------
// Auxiliary Format 80 encoding functions

procedure write_v80(Data: byte; Counter: integer; var Dest: PByte);
procedure write80_c0(var Dest: PByte; Counter: integer; p: integer);
procedure write80_c1(var Dest: PByte; Counter: integer; var Source: PByte);
procedure write80_c2(var Dest: PByte; Counter: integer; p: integer);
procedure write80_c3(var Dest: PByte; Counter: integer; Data: integer);
procedure write80_c4(var Dest: PByte; Counter: integer; p: integer);
procedure flush_c1(var Dest: PByte; const Source: PByte; var copy_from: PByte);


//---------------------------------------------------------
// Encode 80 functions

function encode80(const Source: PByte; var Dest: PByte; cb_s: integer): integer;
function encode80_y(const Source: PByte; var Dest: PByte; cb_s: integer): integer;


//---------------------------------------------------------
// Decode 80 functions

function decode80c(const image_in: TDatabuffer; var image_out: TDatabuffer; cb_in: integer): integer;
function decode80(const image_in: TDatabuffer; var image_out: TDatabuffer): integer;
function decode80r(const image_in: TDatabuffer; var image_out: TDatabuffer): integer;
function decode80d(const image_in: PByte; var image_out: PByte; cb_in: integer): integer;
function decode80p(const image_in: PByte; var image_out: PByte): integer;



implementation


//---------------------------------------------------------
// Read Word
//---------------------------------------------------------

function read_w(var Source: PByte): word;
begin
   Result := word(PWord(Source)^);
   Inc(Source, 2);
end;



//---------------------------------------------------------
// Write Word
//---------------------------------------------------------

procedure write_w(Data: word; var Dest: PByte);
begin
   Dest^ := Data and $ff;
   Inc(Dest);
   Dest^ := Data shr 8;
   Inc(Dest);
end;



//---------------------------------------------------------
// Write v40 - ???
//---------------------------------------------------------

procedure write_v40(Data: byte; Counter: integer; var Dest: PByte);
var
   c_write: integer;
begin
   if (Data = 0) then
   begin
      while (Counter <> 0) do
      begin
         if (Counter < $80) then
         begin
            Dest^ := $80 or Counter;
            Inc(Dest);
            Counter := 0;
         end
         else
         begin
            if (Counter < $8000) then
               c_write := counter
            else
               c_write := $7fff;
            Dest^ := $80;
            Inc(Dest);
            write_w(c_write, Dest);
            Dec(Counter, c_write);
         end;
      end;
   end
   else
   begin
      while (Counter <> 0) do
      begin
         if (Counter < $100) then
         begin
            Dest^ := $00;
            Inc(Dest);
            Dest^ := Counter;
            Inc(Dest);
            Counter := 0;
         end
         else
         begin
            if (Counter < $4000) then
               c_write := Counter
            else
               c_write := $3fff;
            Dest^ := $80;
            Inc(Dest);
            write_w($c000 or c_write, Dest);
            Dec(Counter, c_write);
         end;
         Dest^ := Data;
         Inc(Dest);
      end;
   end;
end;



//---------------------------------------------------------
// Write Fmt40 Command 0
//---------------------------------------------------------

procedure write40_c0(var Dest: PByte; Counter: integer; Data: integer);
begin
   Dest^ := 0;
   Inc(Dest);
   Dest^ := Counter;
   Inc(Dest);
   Dest^ := Data;
   Inc(Dest);
end;




//---------------------------------------------------------
// Write Fmt40 Command 1
//---------------------------------------------------------

procedure write40_c1(var Dest: PByte; Counter: integer; const Source: PByte);
begin
   Dest^ := Counter;
   Inc(Dest);
   Move(Source, Dest, Counter);
   Inc(Dest, Counter);
end;



//---------------------------------------------------------
// Write Fmt40 Command 2
//---------------------------------------------------------

procedure write40_c2(var Dest: PByte; Counter: integer);
begin
   Dest^ := $80;
   Inc(Dest);
   write_w(Counter, Dest);
end;



//---------------------------------------------------------
// Write Fmt40 Command 3
//---------------------------------------------------------

procedure write40_c3(var Dest: PByte; Counter: integer; const Source: PByte);
begin
   Dest^ := $80;
   Inc(Dest);
   write_w($8000 or Counter, Dest);
   Move(Source, Dest, Counter);
   Inc(Dest, Counter);
end;



//---------------------------------------------------------
// Write Fmt40 Command 4
//---------------------------------------------------------

procedure write40_c4(Dest: PByte; Counter: integer; Data: integer);
begin
   Dest^ := $80;
   Inc(Dest);
   write_w($c000 or Counter, Dest);
   Dest^ := Data;
   Inc(Dest);
end;



//---------------------------------------------------------
// Write Fmt40 Command 5
//---------------------------------------------------------

procedure write40_c5(var Dest: PByte; Counter: integer);
begin
   Dest^ := $80 or Counter;
   Inc(Dest);
end;



//---------------------------------------------------------
// Write Fmt40 Command Copy
//---------------------------------------------------------

procedure write40_copy(var Dest: PByte; Counter: integer; var Source: PByte);
var
   c_write: integer;
begin
   while (Counter <> 0) do
   begin
      if (Counter < $80) then
      begin
         write40_c1(Dest, Counter, Source);
         Counter := 0;
      end
      else
      begin
         if (Counter < $4000) then
            c_write := Counter
         else
            c_write := $3fff;
         write40_c3(Dest, c_write, Source);
         Inc(Source, c_write);
         Dec(Counter, c_write);
      end;
   end;
end;



//---------------------------------------------------------
// Write Fmt40 Command Fill
//---------------------------------------------------------

procedure write40_fill(var Dest: PByte; Counter: integer; Data: integer);
var
   c_write: integer;
begin
   while (Counter <> 0) do
   begin
      if (Counter < $100) then
      begin
         write40_c0(Dest, Counter, Data);
         Counter := 0;
      end
      else
      begin
         if (Counter < $4000) then
            c_write := Counter
         else
            c_write := $3fff;
         write40_c4(Dest, c_write, Data);
         Dec(Counter, c_write);
      end;
   end;
end;



//---------------------------------------------------------
// Write Fmt40 Command skip
//---------------------------------------------------------

procedure write40_skip(var Dest: PByte; Counter: integer);
var
   c_write: integer;
begin
   while (Counter <> 0) do
   begin
      if (Counter < $80) then
      begin
         write40_c5(Dest, Counter);
         Counter := 0;
      end
      else
      begin
         if (Counter < $8000) then
            c_write := Counter
         else
            c_write := $7fff;
         write40_c2(Dest, c_write);
         Dec(Counter, c_write);
      end;
   end;
end;



//---------------------------------------------------------
// Write Fmt40 Command Flush C1
//---------------------------------------------------------

procedure flush_copy(var Dest: PByte; const Source: PByte; var Copy_from: PByte);
begin
   if (copy_from <> nil) then
   begin
      write40_copy(Dest, integer(Source) - integer(Copy_from), Copy_from);
      copy_from := nil;
   end;
end;



//---------------------------------------------------------
// Get Run Length
//---------------------------------------------------------

function get_run_length(const Source: PByte; const s_end: PByte): integer;
var
   Counter, Data: integer;
   Current: PByte;
begin
   Counter := 1;
   Current := Source;
   Data    := Source^;
   Inc(Current);
   while (integer(Current) < integer(s_end)) and (Current^ = Data) do
   begin
      Inc(Current);
      Inc(Counter);
   end;
   Result := Counter;
end;



//---------------------------------------------------------
// Encode Fmt40
//---------------------------------------------------------

function encode40(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;
var
   s: PByte;
   a, s_end, r, w, copy_from: PByte; // These are just help pointers
   Size, Data, t: integer;
begin
   // full compression
   Getmem(s, cb_s);
   begin
      a    := s;
      Size := cb_s;
      while (size <> 0) do
      begin
         Dec(Size);
         a^ := LastSource^ xor Source^;
         Inc(a);
         Inc(LastSource);
         Inc(Source);
      end;
   end;
   s_end := s;
   Inc(s_end, cb_s);
   r := s;
   w := Dest;
   copy_from := nil;
   while (integer(r) < integer(s_end)) do
   begin
      Data := r^;
      t    := get_run_length(r, s_end);
      if (Data = 0) then
      begin
         flush_copy(w, r, Copy_from);
         write40_skip(w, t);
      end
      else if (t > 2) then
      begin
         flush_copy(w, r, Copy_from);
         write40_fill(w, t, Data);
      end
      else
      begin
         if (Copy_from = nil) then
            Copy_from := r;
      end;
      Inc(r, t);
   end;
   flush_copy(w, r, Copy_from);
   write40_c2(w, 0);
   FreeMem(s);
   Result := integer(w) - integer(Dest);
end;



//---------------------------------------------------------
// Encode Fmt40 Run Length Encoding
//---------------------------------------------------------

function encode40_y(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;
var
   last_r, r, w: PByte; // some help variables named by Olaf
   Counter:      integer;
   last, Data:   byte;
begin
   // run length encoding
   last_r := LastSource;
   r      := Source;
   w      := Dest;
   Counter := 0;
   last   := not (last_r^ xor r^);

   while (cb_s <> 0) do
   begin
      Dec(cb_s);
      Data := last_r^ xor r^;
      Inc(last_r);
      Inc(r);
      if (last = Data) then
         Inc(Counter)
      else
      begin
         write_v40(last, Counter, w);
         Counter := 1;
         last    := Data;
      end;

   end;
   write_v40(last, Counter, w);
   w^ := $80;
   Inc(w);
   write_w($0000, w);
   Result := integer(w) - integer(Dest);
end;



//---------------------------------------------------------
// Encode Fmt40 No Compression
//---------------------------------------------------------

function encode40_z(var LastSource: PByte; var Source: PByte; var Dest: PByte; cb_s: integer): integer;
var
   last_r, r, w: PByte;   // help variables named by Olaf
   c_write:      integer;
begin
   // no compression
   last_r := LastSource;
   r      := Source;
   w      := Dest;
   while (cb_s <> 0) do
   begin
      if (cb_s > $3fff) then
         c_write := $3fff
      else
         c_write := cb_s;
      Dec(cb_s, c_write);
      w^ := $80;
      Inc(w);
      w^ := c_write and $ff;
      Inc(w);
      w^ := $80 or c_write shr 8;
      Inc(w);
      while (c_write <> 0) do
      begin
         Dec(c_write);
         w^ := last_r^ xor r^;
         Inc(w);
         Inc(last_r);
         Inc(r);
      end;
   end;
   w^ := $80;
   Inc(w);
   w^ := $00;
   Inc(w);
   w^ := $00;
   Inc(w);
   Result := integer(w) - integer(Dest);
end;



//---------------------------------------------------------
// Decode Fmt40
//---------------------------------------------------------

function Decode40(const Source: PByte; var Dest: PByte): integer;
var
   SP:      PByte;
   DP:      PByte;
   Counter: integer;
   Code:    integer;
begin
  {
  0 fill 00000000 c v
  1 copy 0ccccccc
  2 skip 10000000 c 0ccccccc
  3 copy 10000000 c 10cccccc
  4 fill 10000000 c 11cccccc v
  5 skip 1ccccccc
  }

   SP := Source;
   DP := Dest;
   while True do
   begin
      Code := SP^;
      Inc(SP);
      if ((not Code) and $80) <> 0 then
      begin
         //bit 7 = 0
         if (Code = 0) then
         begin
            //command 0 (00000000 c v): fill
            Counter := SP^;
            Inc(SP);
            Code := SP^;
            Inc(SP);
            while (Counter > 0) do
            begin
               Dec(Counter);
               DP^ := DP^ xor Code;
               Inc(DP);
            end;
         end
         else
         begin
            //command 1 (0ccccccc): copy
            Counter := Code;
            while (Counter > 0) do
            begin
               Dec(Counter);
               DP^ := DP^ xor SP^;
               Inc(DP);
               Inc(SP);
            end;
         end;

      end
      else
      begin
         //bit 7 = 1
         Counter := Code and $7f;
         if (Counter = 0) then
         begin
            Counter := read_w(SP);
            Code    := Counter shr 8;
            if ((not code) and $80) <> 0 then
            begin
               //bit 7 = 0
               //command 2 (10000000 c 0ccccccc): skip
               if (Counter = 0) then
               begin
                  // end of image
                  Result := integer(DP) - integer(Dest);
                  exit;
               end;
               Inc(DP, Counter);
            end
            else
            begin
               //bit 7 = 1
               Counter := Counter and $3fff;
               if ((not Code) and $40) <> 0 then
               begin
                  //bit 6 = 0
                  //command 3 (10000000 c 10cccccc): copy
                  while (Counter > 0) do
                  begin
                     Dec(Counter);
                     DP^ := DP^ xor SP^;
                     Inc(DP);
                     Inc(SP);
                  end;
               end
               else
               begin
                  //bit 6 = 1
                  //command 4 (10000000 c 11cccccc v): fill
                  Code := SP^;
                  Inc(SP);
                  while (Counter > 0) do
                  begin
                     Dec(Counter);
                     DP^ := DP^ xor Code;
                     Inc(DP);
                  end;
               end;
            end;
         end
         else
         begin
            //command 5 (1ccccccc): skip
            Inc(DP, Counter);
         end;
      end;
   end;
end;


//---------------------------------------------------------
// Encode Fmt40 No Compression
//---------------------------------------------------------
// Decode 40 adapted by Banshee for OS SHP Builder needs.
// XCC copies the buffer while it decodes, OS SHP Builder has
// to emulate this effect with an extra buffer.

function Decode40Tri(const Source: PByte; const XorDest: PByte; var Dest: PByte): integer;
var
   SP:      PByte;
   XP:      PByte;
   DP:      PByte;
   Counter: integer;
   Code:    integer;
begin
  {
  0 fill 00000000 c v
  1 copy 0ccccccc
  2 skip 10000000 c 0ccccccc
  3 copy 10000000 c 10cccccc
  4 fill 10000000 c 11cccccc v
  5 skip 1ccccccc
  }

   SP := Source;
   XP := XorDest;
   DP := Dest;
   while True do
   begin
      Code := SP^;
      Inc(SP);
      if ((not Code) and $80) <> 0 then
      begin
         //bit 7 = 0
         if (Code = 0) then
         begin
            //command 0 (00000000 c v): fill
            Counter := SP^;
            Inc(SP);
            Code := SP^;
            Inc(SP);
            while (Counter > 0) do
            begin
               Dec(Counter);
               DP^ := XP^ xor Code;
               Inc(XP);
               Inc(DP);
            end;
         end
         else
         begin
            //command 1 (0ccccccc): copy
            Counter := Code;
            while (Counter > 0) do
            begin
               Dec(Counter);
               DP^ := XP^ xor SP^;
               Inc(XP);
               Inc(DP);
               Inc(SP);
            end;
         end;

      end
      else
      begin
         //bit 7 = 1
         Counter := Code and $7f;
         if (Counter = 0) then
         begin
            Counter := read_w(SP);
            Code    := Counter shr 8;
            if ((not code) and $80) <> 0 then
            begin
               //bit 7 = 0
               //command 2 (10000000 c 0ccccccc): skip
               if (Counter = 0) then
               begin
                  // end of image
                  Result := integer(DP) - integer(Dest);
                  exit;
               end;
               while Counter > 0 do
               begin
                  DP^ := XP^;
                  Inc(DP);
                  Inc(XP);
                  Dec(Counter);
               end;
            end
            else
            begin
               //bit 7 = 1
               Counter := Counter and $3fff;
               if ((not Code) and $40) <> 0 then
               begin
                  //bit 6 = 0
                  //command 3 (10000000 c 10cccccc): copy
                  while (Counter > 0) do
                  begin
                     Dec(Counter);
                     DP^ := XP^ xor SP^;
                     Inc(XP);
                     Inc(DP);
                     Inc(SP);
                  end;
               end
               else
               begin
                  //bit 6 = 1
                  //command 4 (10000000 c 11cccccc v): fill
                  Code := SP^;
                  Inc(SP);
                  while (Counter > 0) do
                  begin
                     Dec(Counter);
                     DP^ := XP^ xor Code;
                     Inc(XP);
                     Inc(DP);
                  end;
               end;
            end;
         end
         else
         begin
            //command 5 (1ccccccc): skip
            while Counter > 0 do
            begin
               DP^ := XP^;
               Inc(DP);
               Inc(XP);
               Dec(Counter);
            end;
         end;
      end;
   end;
end;



//---------------------------------------------------------
// Write v80 - ???
//---------------------------------------------------------

procedure write_v80(Data: byte; Counter: integer; var Dest: PByte);
begin
   if (Counter > 3) then
   begin
      Dest^ := $fe;
      Inc(Dest);
      write_w(Counter, Dest);
      Dest^ := Data;
      Inc(Dest);
   end
   else if (Counter > 0) then
   begin
      Dest^ := $80 or Counter;
      Inc(Dest);
      while (Counter > 0) do
      begin
         Dec(Counter);
         Dest^ := Data;
         Inc(Dest);
      end;
   end;
end;



//---------------------------------------------------------
// Find an exact sequence to the sequence starting at position 'p',
// that starts before 'p'.
// PARAMS:
//        - Source    : Source Pointer.
//        - r         : Start Position of Reference Sequence Pointer.
//        - SourceEnd : Source End Pointer.
//        - p         : Start Position of same sequence found Pointer.
//        - cb_p      : Sequence length.
//---------------------------------------------------------

procedure get_same(const Source: PByte; const r: PByte; const SourceEnd: PByte; var p: PByte; var cb_p: integer); assembler; register;
asm
   push  esi
   push  edi
   mov    eax, SourceEnd     // Prepare SourceEnd
   mov    ebx, Source        // Prepare Source
   xor    ecx, ecx           // Who is ecx? Gets 0.
   mov    edi, p             // Prepare p.
   mov[edi], ecx             // set p[0] = 0;
   dec    ebx
   @@next_s:   inc    ebx
   // This part is a loop. If Source doesnt reach 'r', go to @@next, otherwise, say bye bye.
   // Edx gets XORed at the process.
   xor    edx, edx   // EDX gets 0.
   mov    esi, r
   mov    edi, ebx
   cmp    edi, esi
   jnb    @@end
   @@next:     inc    edx   // EDX increases. (seems like a counter)
   cmp    esi, eax
   jnb    @@end_line // also a loop
   cmpsb
   je    @@next
   @@end_line: dec    edx
   cmp    edx, ecx
   jl    @@next_s
   mov    ecx, edx
   mov    edi, p
   mov[edi], ebx
   jmp    @@next_s
   @@end:      mov    edi, cb_p
   mov[edi], ecx
   pop    edi
   pop    esi
end;


 // Based on the purpose of the function above, this is the
 // Delphi version for OS SHP Builder written by Banshee
 // Special thanks for Olaf Van Der Spek for explaining the
 // purpose of his function above, but I'm not fully following
 // his logic.

 // Olaf van der Spek says:
 // The input is s <= r < s_end, output is p and cb_p
 // It searches for the longest string that starts < r that
 // matches the string that starts at r (and ends before s_end)


//---------------------------------------------------------
// Find an exact sequence to the sequence starting at position 'p',
// that starts before 'p'.
// PARAMS:
//        - Source    : Source Pointer.
//        - r         : Start Position of Reference Sequence Pointer.
//        - SourceEnd : Source End Pointer.
//        - p         : Start Position of same sequence found Pointer.
//        - cb_p      : Sequence length.
//---------------------------------------------------------

procedure new_get_same(const Source: PByte; const r: PByte; const SourceEnd: PByte; var p: PByte; var cb_p: integer);
var
   p1, p2, p1i, p2i: PByte;
   counter: integer;
begin
   p    := Source;
   p1   := Source;
   p2   := r;
   counter := 0;
   cb_p := 0;

   while ((integer(p1) + cb_p) < integer(r)) and ((integer(p2) + cb_p) < integer(SourceEnd)) do
   begin
      if p1^ = p2^ then
      begin // if equal
         p1i := p1;
         p2i := p2;
         Inc(p1i, cb_p);
         Inc(p2i, cb_p);
         // we have to confirm the candidate.
         Counter := cb_p;
         while (p1i^ = p2i^) and (Counter > 0) do
         begin
            Dec(Counter);
            Dec(p1i);
            Dec(p2i);
         end;
         if Counter = 0 then
         begin // we have a new record; We have to find the new record;
            p   := p1;
            p1i := p1;
            p2i := p2;
            Inc(cb_p);
            Inc(p1i, cb_p);
            Inc(p2i, cb_p);
            Counter := cb_p;
            while ((integer(p1i) < integer(r)) and (integer(p2i) <= integer(SourceEnd))) do
            begin
               if p1i^ = p2i^ then
               begin
                  Inc(Counter);
                  Inc(p1i);
                  Inc(p2i);
               end
               else
               begin
                  p2i := SourceEnd; // this ends loop.
                  Inc(p2i);
               end;
            end;
            cb_p := counter;
         end;
      end;
      counter := 0;
      Inc(p1);
   end;
end;



//---------------------------------------------------------
// Write Fmt80 Command 0
//---------------------------------------------------------

procedure write80_c0(var Dest: PByte; Counter: integer; p: integer);
begin
   Dest^ := (Counter - 3) shl 4 or p shr 8;
   Inc(Dest);
   Dest^ := p and $ff;
   Inc(Dest);
end;



//---------------------------------------------------------
// Write Fmt80 Command 1
//---------------------------------------------------------

procedure write80_c1(var Dest: PByte; Counter: integer; var Source: PByte);
var
   c_write: integer;
   i: integer; // copy counter.
begin
   repeat
      if Counter < $40 then
         c_write := Counter
      else
         c_write := $3f;
      Dest^ := $80 or c_write;
      Inc(Dest);
      i := c_write;
      while i > 0 do
      begin
         Dest^ := Source^;
         Inc(Source);
         Inc(Dest);
         Dec(i);
      end;
      Dec(Counter, c_write);
   until (Counter = 0);
end;



//---------------------------------------------------------
// Write Fmt80 Command 2
//---------------------------------------------------------

procedure write80_c2(var Dest: PByte; Counter: integer; p: integer);
begin
   Dest^ := $c0 or (Counter - 3);
   Inc(Dest);
   write_w(p, Dest);
end;



//---------------------------------------------------------
// Write Fmt80 Command 3
//---------------------------------------------------------

procedure write80_c3(var Dest: PByte; Counter: integer; Data: integer);
begin
   Dest^ := $fe;
   Inc(Dest);
   write_w(Counter, Dest);
   Dest^ := Data;
   Inc(Dest);
end;



//---------------------------------------------------------
// Write Fmt80 Command 4
//---------------------------------------------------------

procedure write80_c4(var Dest: PByte; Counter: integer; p: integer);
begin
   Dest^ := $ff;
   Inc(Dest);
   write_w(Counter, Dest);
   write_w(p, Dest);
end;



//---------------------------------------------------------
// Write Fmt80 Execute and reset Command 1
//---------------------------------------------------------

procedure flush_c1(var Dest: PByte; const Source: PByte; var copy_from: PByte);
begin
   if (copy_from <> nil) then
   begin
      write80_c1(Dest, integer(Source) - integer(copy_from), copy_from);
      copy_from := nil;
   end;
end;



//---------------------------------------------------------
// Encode Fmt80 Full Compression
//---------------------------------------------------------

function encode80(const Source: PByte; var Dest: PByte; cb_s: integer): integer;
var
   s_end, r, w, copy_from, p: PByte;
   cb_p, t:     integer;
   fake_source: PByte;
begin
   // full compression
   //   ShowMessage('New Frame');
   s_end := Source;
   Inc(s_end, cb_s);
   r := Source;
   w := Dest;
   copy_from := nil;
   fake_source := nil;
   while (integer(r) < integer(s_end)) do
   begin
      t := get_run_length(r, s_end);
      //      ShowMessage('Before Get Same: t = ' + IntToStr(t) + ': (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
      new_get_same(Source, r, s_end, p, cb_p);
      //      ShowMessage('After Get Same: cb_p = ' + IntToStr(cb_p) + ': (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
      if (t < cb_p) and (cb_p > 2) then
      begin
         flush_c1(w, r, copy_from);
         if ((cb_p - 3) < 8) and ((integer(r) - integer(p)) < $1000) then
         begin
            //            ShowMessage('Before Write 80 c0: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
            try
               write80_c0(w, cb_p, integer(r) - integer(p));
            except
               ShowMessage('I crashed at write80_c0: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(integer(r) - integer(Source)) + ', Written: ' + IntToStr(integer(w) - integer(Dest)) + ')');
            end;
         end
         else if ((cb_p - 3) < $3e) then
         begin
            //            ShowMessage('Before Write 80 c2: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
            try
               write80_c2(w, cb_p, integer(p) - integer(Source));
            except
               ShowMessage('I crashed at write80_c2: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(integer(r) - integer(Source)) + ', Written: ' + IntToStr(integer(w) - integer(Dest)) + ')');
            end;
         end
         else
         begin
            //            ShowMessage('Before Write 80 c4: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
            try
               write80_c4(w, cb_p, integer(p) - integer(Source));
            except
               ShowMessage('I crashed at write80_c4: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(integer(r) - integer(Source)) + ', Written: ' + IntToStr(integer(w) - integer(Dest)) + ')');
            end;
         end;
         Inc(r, cb_p);
      end
      else
      begin
         if (t < 3) then
         begin
            if (copy_from = nil) then
               copy_from := r;
         end
         else
         begin
            flush_c1(w, r, copy_from);
            //            ShowMessage('write80_c3: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
            try
               write80_c3(w, t, r^);
            except
               ShowMessage('I crashed at write80_c3: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(integer(r) - integer(Source)) + ', Written: ' + IntToStr(integer(w) - integer(Dest)) + ')');
            end;
         end;
         Inc(r, t);
      end;
   end;
   flush_c1(w, r, copy_from);
   //   ShowMessage('Write 80 c1: (Total: ' + IntToStr(cb_s) + ', Read: ' + IntToStr(Integer(r) - Integer(Source)) + ', Written: ' + IntToStr(Integer(w) - Integer(Dest)) + ')');
   w^ := $80;
   Inc(w);
   Result := integer(w) - integer(Dest);
   //   ShowMessage('End of Frame');
end;



//---------------------------------------------------------
// Encode Fmt80 Run Length Encoding
//---------------------------------------------------------

function encode80_y(const Source: PByte; var Dest: PByte; cb_s: integer): integer;
var
   r, w:    PByte;
   Counter: integer;
   last, Data: byte;
begin
   // run length encoding
   r    := Source;
   w    := Dest;
   Counter := 0;
   last := not r^;

   while (cb_s <> 0) do
   begin
      Dec(cb_s);
      Data := r^;
      Inc(r);
      if (last = Data) then
         Inc(Counter)
      else
      begin
         write_v80(last, Counter, w);
         Counter := 1;
         last    := Data;
      end;

   end;
   write_v80(last, Counter, w);
   w^ := $80;
   Inc(w);
   Result := integer(w) - integer(Dest);
end;


//---------------------------------------------------------
// Decode Fmt80 c ???
//---------------------------------------------------------

function decode80c(const image_in: TDatabuffer; var image_out: TDatabuffer; cb_in: integer): integer;
var
   copyp, readp, writep: PByte;
   code, Counter: integer;
begin
  {
  0 copy 0cccpppp p
  1 copy 10cccccc
  2 copy 11cccccc p p
  3 fill 11111110 c c v
  4 copy 11111111 c c p p
  }

   readp  := Addr(image_in);
   writep := Addr(image_out);
   while (True) do
   begin
      code := readp^;
      Inc(readp);
      if ((not code) and $80) <> 0 then
      begin
         //bit 7 = 0
         //command 0 (0cccpppp p): copy
         Counter := (code shr 4) + 3;
         integer(copyp) := integer(writep) - (((code and $f) shl 8) + readp^);
         Inc(readp);
         while (Counter <> 0) do
         begin
            Dec(Counter);
            writep^ := copyp^;
            Inc(writep);
            Inc(copyp);
         end;
      end
      else
      begin
         //bit 7 = 1
         Counter := code and $3f;
         if ((not code) and $40) <> 0 then
         begin
            //bit 6 = 0
            if (Counter = 0) then
               //end of image
               break;
            //command 1 (10cccccc): copy
            while (Counter <> 0) do
            begin
               Dec(Counter);
               writep^ := readp^;
               Inc(writep);
               Inc(readp);
            end;
         end
         else
         begin
            //bit 6 = 1
            if (Counter < $3e) then
            begin
               //command 2 (11cccccc p p): copy
               Inc(Counter, 3);
               copyp := Addr(image_out[read_w(readp)]);
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := copyp^;
                  Inc(writep);
                  Inc(copyp);
               end;
            end
            else
            if (Counter = $3e) then
            begin
               //command 3 (11111110 c c v): fill
               Counter := read_w(readp);
               code    := readp^;
               Inc(readp);
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := byte(code);
                  Inc(writep);
               end;
            end
            else
            begin
               //command 4 (copy 11111111 c c p p): copy
               Counter := read_w(readp);
               copyp   := Addr(image_out[read_w(readp)]);
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := copyp^;
                  Inc(writep);
                  Inc(copyp);
               end;
            end;
         end;
      end;
   end;
   //  assert(cb_in == readp - image_in);
   Result := integer(writep) - integer(Addr(image_out));
end;



//---------------------------------------------------------
// Decode Fmt80 d ???
//---------------------------------------------------------

function decode80d(const image_in: PByte; var image_out: PByte; cb_in: integer): integer;
var
   copyp, readp, writep: PByte;
   code, Counter: integer;
begin
  {
  0 copy 0cccpppp p
  1 copy 10cccccc
  2 copy 11cccccc p p
  3 fill 11111110 c c v
  4 copy 11111111 c c p p
  }

   readp  := image_in;
   writep := image_out;
   while (True) do
   begin
      code := readp^;
      Inc(readp);
      if ((not code) and $80) <> 0 then
      begin
         //bit 7 = 0
         //command 0 (0cccpppp p): copy
         Counter := (code shr 4) + 3;
         integer(copyp) := integer(writep) - (((code and $f) shl 8) + readp^);
         Inc(readp);
         while (Counter <> 0) do
         begin
            Dec(Counter);
            writep^ := copyp^;
            Inc(writep);
            Inc(copyp);
         end;
      end
      else
      begin
         //bit 7 = 1
         Counter := code and $3f;
         if ((not code) and $40) <> 0 then
         begin
            //bit 6 = 0
            if (Counter = 0) then
               //end of image
               break;
            //command 1 (10cccccc): copy
            while (Counter <> 0) do
            begin
               Dec(Counter);
               writep^ := readp^;
               Inc(writep);
               Inc(readp);
            end;
         end
         else
         begin
            //bit 6 = 1
            if (Counter < $3e) then
            begin
               //command 2 (11cccccc p p): copy
               Inc(Counter, 3);
               copyp := image_out;
               Inc(copyp, read_w(readp));
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := copyp^;
                  Inc(writep);
                  Inc(copyp);
               end;
            end
            else
            if (Counter = $3e) then
            begin
               //command 3 (11111110 c c v): fill
               Counter := read_w(readp);
               code    := readp^;
               Inc(readp);
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := byte(code);
                  Inc(writep);
               end;
            end
            else
            begin
               //command 4 (copy 11111111 c c p p): copy
               Counter := read_w(readp);
               copyp   := image_out;
               Inc(copyp, read_w(readp));
               while (Counter <> 0) do
               begin
                  Dec(Counter);
                  writep^ := copyp^;
                  Inc(writep);
                  Inc(copyp);
               end;
            end;
         end;
      end;
   end;
   //  assert(cb_in == readp - image_in);
   Result := integer(writep) - integer(image_out);
end;



//---------------------------------------------------------
// Decode Fmt80 - With ASM
//---------------------------------------------------------

function decode80(const image_in: TDatabuffer; var image_out: TDatabuffer): integer;
var
   cb_out: integer;
begin
  {
  0 copy 0cccpppp p
  1 copy 10cccccc
  2 copy 11cccccc p p
  3 fill 11111110 c c v
  4 copy 11111111 c c p p
  }

   asm
      push  esi
      push  edi
      mov    ax, ds
      mov    es, ax
      mov    esi, image_in
      mov    edi, image_out
      @next:
      xor    eax, eax
      lodsb
      mov    ecx, eax
      test  eax, $80
      jnz    @c1c
      shr    ecx, 4
      add    ecx, 3
      and    eax, $f
      shl    eax, 8
      lodsb
      mov    edx, esi
      mov    esi, edi
      sub    esi, eax
      jmp    @copy_from_destination
      @c1c:
      and    ecx, $3f
      test  eax, $40
      jnz    @c2c
      or    ecx, ecx
      jz    @end
      jmp    @copy_from_source
      @c2c:
      xor    eax, eax
      lodsw
      cmp    ecx, $3e
      je    @c3
      ja    @c4
      mov    edx, esi
      mov    esi, image_out
      add    esi, eax
      add    ecx, 3
      jmp    @copy_from_destination
      @c3:
      mov    ecx, eax
      lodsb
      rep    stosb
      jmp    @next
      @c4:
      mov    ecx, eax
      lodsw
      mov    edx, esi
      mov    esi, image_out
      add    esi, eax
      @copy_from_destination:
      rep    movsb
      mov    esi, edx
      jmp    @next
      @copy_from_source:
      rep    movsb
      jmp    @next
      @end:
      sub    edi, image_out
      mov    cb_out, edi
      pop    edi
      pop    esi
   end;
   Result := cb_out;
end;


//---------------------------------------------------------
// Decode Fmt80 p - With ASM
//---------------------------------------------------------

function decode80p(const image_in: PByte; var image_out: PByte): integer;
var
   cb_out: integer;
begin
  {
  0 copy 0cccpppp p
  1 copy 10cccccc
  2 copy 11cccccc p p
  3 fill 11111110 c c v
  4 copy 11111111 c c p p
  }

   asm
      push  esi
      push  edi
      mov    ax, ds
      mov    es, ax
      mov    esi, image_in
      mov    edi, image_out
      @next:
      xor    eax, eax
      lodsb
      mov    ecx, eax
      test  eax, $80
      jnz    @c1c
      shr    ecx, 4
      add    ecx, 3
      and    eax, $f
      shl    eax, 8
      lodsb
      mov    edx, esi
      mov    esi, edi
      sub    esi, eax
      jmp    @copy_from_destination
      @c1c:
      and    ecx, $3f
      test  eax, $40
      jnz    @c2c
      or    ecx, ecx
      jz    @end
      jmp    @copy_from_source
      @c2c:
      xor    eax, eax
      lodsw
      cmp    ecx, $3e
      je    @c3
      ja    @c4
      mov    edx, esi
      mov    esi, image_out
      add    esi, eax
      add    ecx, 3
      jmp    @copy_from_destination
      @c3:
      mov    ecx, eax
      lodsb
      rep    stosb
      jmp    @next
      @c4:
      mov    ecx, eax
      lodsw
      mov    edx, esi
      mov    esi, image_out
      add    esi, eax
      @copy_from_destination:
      rep    movsb
      mov    esi, edx
      jmp    @next
      @copy_from_source:
      rep    movsb
      jmp    @next
      @end:
      sub    edi, image_out
      mov    cb_out, edi
      pop    edi
      pop    esi
   end;
   Result := cb_out;
end;



//---------------------------------------------------------
// Decode Fmt80 r - With ASM
//---------------------------------------------------------

function decode80r(const image_in: TDatabuffer; var image_out: TDatabuffer): integer;
var
   cb_out: integer;
begin
  {
  0 copy 0cccpppp p
  1 copy 10cccccc
  2 copy 11cccccc p p
  3 fill 11111110 c c v
  4 copy 11111111 c c p p
  }

   asm
      push  esi
      push  edi
      mov    ax, ds
      mov    es, ax
      mov    esi, image_in
      mov    edi, image_out
      @next:
      xor    eax, eax
      lodsb
      mov    ecx, eax
      test  eax, $80
      jnz    @c1c
      shr    ecx, 4
      add    ecx, 3
      and    eax, $f
      shl    eax, 8
      lodsb
      mov    edx, esi
      mov    esi, edi
      sub    esi, eax
      jmp    @copy_from_destination
      @c1c:
      and    ecx, $3f
      test  eax, $40
      jnz    @c2c
      or    ecx, ecx
      jz    @end
      jmp    @copy_from_source
      @c2c:
      xor    eax, eax
      lodsw
      cmp    ecx, $3e
      je    @c3
      ja    @c4
      mov    edx, esi
      mov    esi, edi
      sub    esi, eax
      add    ecx, 3
      jmp    @copy_from_destination
      @c3:
      mov    ecx, eax
      lodsb
      rep    stosb
      jmp    @next
      @c4:
      mov    ecx, eax
      lodsw
      mov    edx, esi
      mov    esi, edi
      sub    esi, eax
      @copy_from_destination:
      rep    movsb
      mov    esi, edx
      jmp    @next
      @copy_from_source:
      rep    movsb
      jmp    @next
      @end:
      sub    edi, image_out
      mov    cb_out, edi
      pop    edi
      pop    esi
   end;
   Result := cb_out;
end;

end.
