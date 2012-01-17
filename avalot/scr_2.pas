program screen2;
uses Crt;

const
 codes : string[4] = ' ßÜÛ';

type
 fonttype = array[#0..#255,0..15] of byte;

var
 x,xx,y:byte;
 qq:string;
 f:file of fonttype;
 font:fonttype;
 code:byte;

procedure save;
type atype = array[1..3840] of byte;
var
 f:file of atype;
 fv:word;
 a:atype absolute $B800:0;
begin;
 assign(f,'TEXT2.SCR');
 rewrite(f); write(f,a); close(f);
end;

procedure centre(y:byte; z:string);
var fv:byte;
begin;
 for fv:=1 to length(z) do
 begin;
  gotoxy(39-length(z) div 2+fv,y);
  if odd(fv+y) then textattr:=2 else textattr:=cyan;
  if z[fv]<>#32 then write(z[fv]);
 end;
end;

procedure line(yy:byte; title:string);
const offset = 5;
begin;
 for y:=1 to 6 do
 begin;
  qq:='';
  for x:=1 to length(title) do
  begin;
   for xx:=7 downto 0 do
   begin;
    code:=byte(((1 shl xx) and font[title[x],y*2-offset])>0)+
     byte(((1 shl xx) and font[title[x],y*2+1-offset])>0)*2;
    qq:=qq+codes[code+1];
   end;
  end;
  centre(y+yy,qq);
 end;
end;

procedure chips;
var fv,x,y:byte;
begin;
 for fv:=0 to 1 do
 begin;
  textattr:=120;
  for y:=2 to 6 do
   begin;
    gotoxy(fv*67+3,y); write('     '); if fv=1 then write(' ');
   end;
  gotoxy(fv*67+4,4);
  if fv=0 then write('RAM') else write('CRAM');
  textattr:=7;
  for x:=0 to 1 do
   for y:=2 to 6 do
    begin; gotoxy(fv*67+2+x*(6+fv),y); write('ð'); end;
 end;
end;

begin;
 textattr:=0; clrscr;
 chips;
 assign(f,'c:\thomas\ttsmall.fnt');
 reset(f); read(f,font); close(f);
 line(0,'Out of');
 line(4,'memory!');
 centre(11,'Yes, RAM cram strikes again- Avvy has just run out of RAM (not the');
 centre(12,'hydraulic, woolly or village kinds.) Fortunately, there are a few things');
 centre(13,'you can do about this:');
 textattr:=3;
 for xx:=15 to 17 do
 begin;
  gotoxy(23,xx); write(#16);
 end;
 textattr:=2;
 gotoxy(25,15); write('Don''t run Avvy in a DOS shell.');
 gotoxy(25,16); write('If that fails, try un-installing your TSRs.');
 gotoxy(25,17); write('If you''ve got DOS 5ù0 or above, try using');
 gotoxy(28,18); textattr:=3; write('dos=high');
 textattr:=2; write(',');
 textattr:=3; write(' loadhigh');
 textattr:=2; write(' and');
 textattr:=3; write(' devicehigh');
 textattr:=2; write('.');
 gotoxy(28,19); write('See your DOS manual for details...');
 centre(23,'Sorry for any inconvenience...');
 save;
end.