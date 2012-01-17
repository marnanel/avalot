program preview_1;
uses Graph,Crt;

var
 fxpal:array[0..3] of palettetype;

procedure load;
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
begin

 assign(f,'preview2.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;

 close(f);
 bit:=getpixel(0,0);

 settextjustify(1,1);
 setcolor(3);
 outtextxy(320,166,'...This is a preview of things to come...');
 setcolor(14);
 outtextxy(320,176,'AVAROID');
 outtextxy(320,183,'(a space so dizzy)');
 setcolor(9);
 outtextxy(320,194,'the next Avvy adventure-- in 256 colours.');
 setcolor(7);
 outtextxy(590,195,'Any key...');
end;

procedure setup;
var
 gd,gm:integer;
 p:palettetype;
begin
 if paramstr(1)<>'jsb' then halt(255);
 gd:=3; gm:=0; initgraph(gd,gm,'');
 getpalette(fxpal[0]);

 fillchar(p.colors,sizeof(p.colors),#0); { Blank out the screen. }
 p.size:=16; setallpalette(p);
end;

procedure wait;
var w:word; r:char;
begin
 w:=0;
 repeat
  delay(1); inc(w);
 until keypressed or (w=15000);

 while keypressed do r:=readkey; { Keyboard sink. }
end;

procedure show(n:byte);
begin
 setallpalette(fxpal[n]);
 delay(55);
end;

function fades(x:shortint):shortint;
var r,g,b:byte;
begin
 r:=x div 16; x:=x mod 16;
 g:=x div 4;  b:=x mod 4;
 if r>0 then dec(r); if g>0 then dec(g); if b>0 then dec(b);
 fades:=(16*r+4*g+b);
{ fades:=x-1;}
end;

procedure dawn;
  procedure calc(n:byte);
  var fv:byte;
  begin
   fxpal[n]:=fxpal[n-1];

   for fv:=1 to fxpal[n].size-1 do
    fxpal[n].colors[fv]:=fades(fxpal[n].colors[fv]);
  end;
var
 fv:byte;
begin
 for fv:=1 to 3 do calc(fv);

 for fv:=3 downto 0 do show(fv);
end;

procedure dusk;
var fv:byte;
begin
 for fv:=1 to 3 do show(fv);
end;

begin
 setup;
 load;
 dawn;
 wait;
 dusk;
 closegraph;
end.