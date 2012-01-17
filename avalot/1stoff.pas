program first_off;
uses Crt,Dos;

var
 cols:array[1..7,1..3] of byte;
 fv:byte;

procedure adjust;
var
 r:registers;
begin;
 with r do
 begin;
  ax:=$1012;
  bx:=1;
  cx:=2;
  es:=seg(cols);
  dx:=ofs(cols);

 end;

 intr($10,r);
end;

begin;
 textattr:=0;
 clrscr;

 fillchar(cols,sizeof(cols),#0);
 adjust;

 gotoxy(29,10); textattr:=1; write('Thorsoft of Letchworth');
 gotoxy(36,12); textattr:=2; write('presents');

 for fv:=1 to 77 do
 begin;
  delay(77);
  if fv<64 then fillchar(cols[1],3,chr(fv));
  if fv>14 then fillchar(cols[2],3,chr(fv-14));
  adjust;
 end;

 delay(100);

 for fv:=63 downto 1 do
 begin;
  fillchar(cols,sizeof(cols),chr(fv));
  delay(37);
  adjust;
 end;

end.