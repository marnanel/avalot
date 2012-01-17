program credits;
uses Graph,Crt;
{$R+}

type
 fonttype = array[#0..#255,0..15] of byte;

var
 gd,gm:integer;
 t:text;
 f:array[1..2] of fonttype;
 ff:file of fonttype;
 l:array[1..80] of byte;
 x:string[80];

procedure do_one(z:byte);
var
  a:byte absolute $A000:0;
 aa:byte absolute $A000:80;
 az:byte absolute $A000:27921;
begin;
 a:=getpixel(0,0);
 move(l,az,z);

 port[$3C5]:=8; port[$3CF]:=0;
 move(aa,a,27920);
end;

procedure background;
var y:byte;
begin;
 for y:=1 to 15 do
 begin;
  setcolor(y);
  outtextxy(17,y*12,'Jesus is Lord!');
 end;
end;

procedure scroll(z:string);
var
 x,y,lz:byte; c:char;
begin;
 fillchar(l,80,#0);
 if z='' then
  for y:=1 to 12 do do_one(0);
 c:=z[1]; delete(z,1,1);
 lz:=length(z);
 case c of
  '*': for y:=0 to 15 do
       begin;
        for x:=1 to lz do
         l[x]:=f[2,z[x],y];
        do_one(lz);
       end;
  '>': begin;
         inc(lz,7);
        for y:=0 to 13 do
        begin;
         for x:=1 to lz do
          l[x+7]:=f[1,z[x],y];
         do_one(lz); do_one(lz); { double-height characters }
        end;
       end;
 end;
end;

begin;
 gd:=3; gm:=1; initgraph(gd,gm,'');
 port[$3C4]:=2; port[$3CF]:=4;
 assign(ff,'avalot.fnt'); reset(ff); read(ff,f[1]); close(ff);
 assign(ff,'avitalic.fnt'); reset(ff); read(ff,f[2]); close(ff);
 assign(t,'credits.txt'); reset(t);
 background;
 for gd:=8 to 15 do setpalette(gd,62);
 repeat
  readln(t,x);
  scroll(x);
 until eof(t) or keypressed;
 close(t);
end.