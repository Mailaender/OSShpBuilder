unit Miscelaneous;

interface

procedure Partition(var Matrix: array of byte; start,final: integer; var i,j: integer);
procedure Quicksort(var Matrix: array of byte; start,final : integer);

implementation

procedure Partition(var Matrix: array of byte; start,final: integer; var i,j: integer);
var
   token : byte;
   temp : byte;
begin
   I := start;
   J := final;
   Token := Matrix[(start + final) div 2];
   while (I <= J) do
   begin
       while (Matrix[I] < Token) do
       begin
          inc(i);
       end;
       while (Matrix[J] > Token) do
       begin
          dec(j);
       end;
       if (I <= J) then
       begin
          temp := Matrix[i];
          Matrix[i] := Matrix[j];
          Matrix[j] := temp;
          inc(i);
          dec(j);
       end;
   end;
end;

procedure Quicksort(var Matrix: array of byte; start,final : integer);
var
   i,j:integer;
begin
   if Final > Start then
   begin
      Partition(Matrix,Start,Final,I,J);
      Quicksort(Matrix,Start,J);
      Quicksort(Matrix,I,Final);
   end;
end;

end.
