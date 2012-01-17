program ints; { Avalot interrupt handler }
uses Dos;
{$F+}
var
 r:registers;
 old1B:procedure;

 quicko:boolean;

procedure new1B; interrupt;
begin;
 quicko:=true;
end;

begin;
 getintvec($1B,@old1B);
 setintvec($1B,addr(new1B));
 quicko:=false;
 repeat until quicko;
 setintvec($1B,@old1B);
(*  r.ah:=$02; intr($16,r);
  writeln(r.al and 12); { Only checks Ctrl and Alt. Both on = 12. }
 until false;*)
end.