program displayscr;
uses Crt;

const fn = 'text3.scr';

type atype = array[1..3840] of char;

var
 f:file of atype;
 fv,ff,fq,st:word;
 r:char;
 tl,bl:byte;
 q:atype;
 a:atype absolute $B800:0;

begin;
 textattr:=0; clrscr;
 assign(f,fn); reset(f); read(f,q); close(f);
 for fv:=1 to 40 do
 begin;
  if fv>36 then begin; tl:=1; bl:=24; end
   else begin; tl:=12-fv div 3; bl:=12+fv div 3; end;
  for fq:=tl to bl do
   for ff:=80-fv*2 to 80+fv*2 do
    a[fq*160-ff]:=q[fq*160-ff];
  delay(5);
 end;
 gotoxy(1,25); textattr:=31; clreol; gotoxy(1,24);
end.