program stars; { Demonstration of the Bigo II system. }
uses Graph,Crt,Rodent,Tommys;
var gd,gm:integer;

type
 fonttype = array[#0..#255,0..15] of byte;

var
 reverse:boolean;
 spinnum:word;
 f:array[0..1] of fonttype;
 ff:file of fonttype;
 strip:array[0..7,0..15,0..79] of byte;
 across:byte;
 w:word; y:byte;
 charnum:byte;
 cfont:byte; { current font. 0=roman, 1=italic. }

 c:^char;

const
 colours = 12; { Run Workout to see possible values of these two. }
 steps = 6; { 60,30,20,15,12,10,6,5,4,3,2,1 }
 gmtop = 360 div steps;

{$L credits.obj} procedure credits; external;

procedure bigo2(date:string);
var
 gd,gm:integer;
 c:byte;
 p:palettetype;
 f:file; pp:pointer; s:word;

begin
 getpalette(p);
 setvisualpage(1); setactivepage(0);
 assign(f,'logo.avd'); reset(f,1);
 for gd:=7 to 194 do
  blockread(f,mem[$A000:(gd*80)],53);
 close(f);
 s:=imagesize(0,7,415,194); getmem(pp,s); getimage(0,7,415,194,pp^);

 cleardevice;
 for gd:=1 to 64 do
 begin
  for gm:=0 to gmtop do
  begin
   c:=(c mod colours)+1;
(*   putpixel(trunc(sin(gm*steps*n)*gd*6)+320,
              trunc(cos(gm*steps*n)*gd*3)+175,c); *)
   if c>5 then continue;
   setcolor(c); arc(320,175,gm*steps,gm*steps+1,gd*6);
  end;
  if keypressed then begin closegraph; halt; end;
 end;
 settextstyle(0,0,1); setcolor(13);
 outtextxy(550,343,'(press any key)');

 putimage(112,0,pp^,orput); freemem(pp,s);
 resetmouse; setvisualpage(0);
end;

procedure nextchar; { Sets up charnum & cline for the next character. }
begin

 inc(c);
end;

procedure getchar;
begin
 repeat
  nextchar;

  case c^ of
   '@': begin cfont:=1; nextchar; end;
   '^': begin cfont:=0; nextchar; end;
   '%': begin closegraph; halt end;
  end;

 until (c^<>#13) and (c^<>#10);

 for w:=0 to 7 do
  for y:=0 to 15 do
   move(strip[w,y,1],strip[w,y,0],79);

 for w:=0 to 7 do
  for y:=0 to 15 do
   strip[w,y,79]:=byte((strip[7,y,78] shl (w+1)))+
    f[cfont,c^,y] shr (7-w);

 across:=0;
end;

procedure scrolltext;
var
 c,w,y:byte;
begin
 inc(across);
 if across=8 then getchar;

 for y:=0 to 15 do
  for w:=0 to 1 do
  move(strip[across,y,0],mem[$A000:24000+(y*2+w)*80],80);
end;

procedure do_stuff;
begin
 case spinnum of
  50..110: begin
            setfillstyle(1,14);
            bar(0,315+(spinnum-50) div 3,640,315+(spinnum-50) div 3);
            bar(0,316-(spinnum-50) div 3,640,316-(spinnum-50) div 3);
            if spinnum>56 then
            begin
             setfillstyle(1,13);
             bar(0,315+(spinnum-56) div 3,640,315+(spinnum-56) div 3);
             bar(0,316-(spinnum-56) div 3,640,316-(spinnum-56) div 3);
            end;
          end;
  150..198: begin
             setfillstyle(1,0);
             bar(0,315+(spinnum-150) div 3,640,315+(spinnum-150) div 3);
             bar(0,316-(spinnum-150) div 3,640,316-(spinnum-150) div 3);
            end;
  200: scrolltext;
 end;
end;

procedure setcol(which,what:byte);
(*var dummy:byte;*)
begin
(* setpalette(which,what);
 asm
(*  mov dx,$3DA;
  in ax,dx;

  or ah,ah;

  mov dx,$3C0;
  mov al,which;
  out dx,al;

  mov dx,$3C0;
  mov al,what;
  out dx,al;
 end;
(* dummy:=port[$3DA];
 port[$3C0]:=which; port[$3C0]:=what;*)
end;

procedure bigo2go;
var
 p:palettetype; c:byte; lmo:boolean;
 altNow,altBefore:boolean;
begin
 for gd:=0 to 13 do p.colors[gd]:=0;

 setcol(13,24); { murk } setcol(14,38); { gold }
 setcol(15,egaWhite); { white- of course }
 p.colors[13]:=24; p.colors[14]:=38; p.colors[15]:=egaWhite;

 (***)
    
    p.colors[5]:=egaWhite;
    p.colors[4]:=egaLightcyan;
    p.colors[3]:=egaCyan;
    p.colors[2]:=egaLightblue;
    p.colors[1]:=egaBlue;

 (***)

 c:=1; p.size:=16; lmo:=false;
 setallpalette(p);

 repeat
(*  if reverse then
  begin
   dec(c); if c=0 then c:=colours;
  end else
  begin
   inc(c); if c>colours then c:=1;
  end;
  for gm:=1 to colours do
   case p.colors[gm] of
    egaWhite: begin p.colors[gm]:=egaLightcyan; setcol(gm,egaLightCyan); end;
    egaLightcyan: begin p.colors[gm]:=egaCyan; setcol(gm,egaCyan); end;
    egaCyan: begin p.colors[gm]:=egaLightblue; setcol(gm,egaLightblue); end;
    egaLightblue: begin p.colors[gm]:=egaBlue; setcol(gm,egaBlue); end;
    egaBlue: begin p.colors[gm]:=0; setcol(gm,0); end;
   end;
  p.colors[c]:=egaWhite; setcol(c,egaWhite);

  AltBefore:=AltNow; AltNow:=testkey(sAlt);*)

  if anymousekeypressed then lmo:=true;
  if keypressed then lmo:=true;

 (* if (AltNow=True) and (AltBefore=False) then reverse:=not reverse;*)

  do_stuff;
  if spinnum<200 then inc(spinnum);
 until lmo;
end;

procedure parse_cline;
var e:integer;
begin
 if paramstr(1)<>'jsb' then
 begin
  writeln('Not a standalone program.'); halt(255);
 end;
end;

begin
 parse_cline;

 gd:=3; gm:=1; initgraph(gd,gm,'');
 assign(ff,'avalot.fnt'); reset(ff); read(ff,f[0]); close(ff);
 assign(ff,'avitalic.fnt'); reset(ff); read(ff,f[1]); close(ff);

 c:=addr(credits); dec(c);

 fillchar(strip,sizeof(strip),#0);
 reverse:=false; spinnum:=0; across:=7; charnum:=1; cfont:=0;
 bigo2('1189'); { 1189? 79? 2345? 1967? }
 bigo2go;
end.