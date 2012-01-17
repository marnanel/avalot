program screen4;
uses Crt;

const
 codes : string[4] = ' ÞÝÛ';

type
 fonttype = array[#0..#255,0..15] of byte;

var
 x,xx,y:byte;
 qq:string;
 f:file of fonttype;
 font:fonttype;
 code:byte;

procedure centre(y:byte; z:string);
var fv:byte;
begin;
 for fv:=1 to length(z) do
 begin;
  gotoxy(39-length(z) div 2+fv,y);
  if z[fv]<>#32 then write(z[fv]);
 end;
end;

procedure line(cy:byte; title:string);
begin;
 for y:=0 to 6 do
 begin;
  qq:='';
  for x:=1 to length(title) do
  begin;
   for xx:=3 downto 0 do
   begin;
    code:=byte(((1 shl (xx*2)) and font[title[x],y])>0)+
     byte(((1 shl (xx*2+1)) and font[title[x],y])>0)*2;
    qq:=qq+codes[code+1];
   end;
  end;
  centre(cy+y,qq);
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

procedure box(x1,y1,x2,y2:byte; z:string);
var fv:byte;
begin;
 gotoxy(x1,y1); write(z[1]); { tl }
 gotoxy(x2,y1); write(z[2]); { tr }
 gotoxy(x1,y2); write(z[3]); { bl }
 gotoxy(x2,y2); write(z[4]); { br }
 for fv:=y1+1 to y2-1 do
 begin;
  gotoxy(x1,fv); write(z[5]); { verticals }
  gotoxy(x2,fv); write(z[6]);
 end;
 gotoxy(x1+1,y1); for fv:=x1+1 to x2-1 do write(z[7]);
 gotoxy(x1+1,y2); for fv:=x1+1 to x2-1 do write(z[8]);
end;

begin;
 textattr:=26; clrscr;
 assign(f,'c:\thomas\ttsmall.fnt');
 reset(f); read(f,font); close(f);
 line(3,'CONGRATULATIONS!');
 textattr:=30; box(4,1,74,11,'É»È¼ººÍÍ');
 textattr:=33; box(6,2,72,10,'/\\/°°Üß');
 textattr:=30; centre(12,'Well done!');
 textattr:=27; centre(14,'You completed the game!');
end.