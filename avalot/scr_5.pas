program screen5;
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
 assign(f,'TEXT5.SCR');
 rewrite(f); write(f,a); close(f);
end;

procedure line(cx,cy:byte; title:string);
begin;
 for y:=0 to 4 do
 begin;
  qq:='';
  for x:=1 to length(title) do
  begin;
   for xx:=7 downto 0 do
   begin;
    code:=byte(((1 shl xx) and font[title[x],y*2])>0)+
     byte(((1 shl xx) and font[title[x],y*2+1])>0)*2;
    qq:=qq+codes[code+1];
   end;
  end;
  gotoxy(cx,cy+y); write(qq);
 end;
end;

procedure uline;
var fv,ff:byte;
begin;
 for fv:=1 to 10 do
 begin;
  gotoxy(16-fv,21-fv); textattr:=fv;
  for ff:=1 to fv do write('ÄÍÍ-');
 end;
end;

begin;
 textattr:=0; clrscr;
 assign(f,'c:\thomas\ttsmall.fnt');
 reset(f); read(f,font); close(f);
 textattr:=11;
 line( 1, 3,'Two at');
 line( 3, 7,'once?!');
 textattr:=9; gotoxy(55,4); write(#4+#255);
 textattr:=3; write('You''re trying to run');
 gotoxy(54,5); write('two copies of Avalot');
 gotoxy(54,6); write('at once.');
 gotoxy(57,8); write('Although this '); textattr:=9; write('is');
 textattr:=3;
 gotoxy(54,9); write('usually possible, it''s');
 gotoxy(54,10); write('probably more sensible');
 gotoxy(54,11); write('to type ');
 textattr:=7; write('EXIT ');
 textattr:=3; write('now, which');
 gotoxy(54,12); write('should return you to the');
 gotoxy(54,13); write('first copy in memory.');

 textattr:=11; gotoxy(55,15); write('BUT:'); textattr:=9;
 gotoxy(40,16); write('If you want to run two copies anyway,');
 gotoxy(40,17); write('or you think that I''ve got it wrong,');
 gotoxy(40,18); write('(even computers can make mistakes!) then');
 gotoxy(40,19); write('try running the game again, but this time');
 gotoxy(40,20); write('use '); textattr:=7; write('/i ');
 textattr:=9; write('on the command line.');
 uline;

 save;
end.