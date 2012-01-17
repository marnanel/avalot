program screen2;
uses Crt;

const
 codes : string[4] = ' ﬂ‹€';

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
 assign(f,'TEXT3.SCR');
 rewrite(f); write(f,a); close(f);
end;

procedure centre(y:byte; z:string);
var fv:byte;
begin;
 for fv:=1 to length(z) do
 begin;
  gotoxy(39-length(z) div 2+fv,y);
  if z[fv]<>#32 then write(z[fv]);
 end;
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

procedure big_t;
var
 t:text;
 x:string;
 y:byte;
begin;
 assign(t,'c:\avalot\t.txt'); reset(t); y:=1;
 while not eof(t) do
 begin;
  readln(t,x);
  gotoxy(1,y); write(x); inc(y);
 end;
end;

begin;
 textattr:=4; clrscr;
 assign(f,'c:\thomas\ttsmall.fnt');
 reset(f); read(f,font); close(f);
 textattr:=4; line(19,4,'hanks');
 textattr:=6; line(23,8,'for');
 line(7,12,'playing'); inc(textattr,8);
 line(12,16,'Avalot.');
 textattr:=12; big_t;
 textattr:=8; gotoxy(40,2); write('(c) 1994, Mike, Mark and Thomas Thurman.');
 textattr:=11; gotoxy(50,10); write('* Goodbyte! *');
 textattr:=10; gotoxy(9,20); write(#16);
 textattr:=12; write(' If you''d like to see yet more of these games, then don''t forget to');
 gotoxy(12,21); write('register, or your'); clreol;
 gotoxy(12,22); write('for the rest of your life!');
 gotoxy(60,22); write('(Only joking!)');
 save;
end.
