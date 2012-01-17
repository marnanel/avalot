unit trip3; { Project Minstrel- Trippancy routines }

interface

uses Gyro;

 procedure loadtrip;

 procedure boundscheck(var x,y:integer; xm,ym:byte);

 procedure budge(who:byte; xx,yy:shortint; frame:byte); { Moving & animation controller }

 procedure tripkey(dir:char);

 procedure trippancy;

 procedure enter(what_handle:byte; xx,yy,lx,ly:integer; mmx,mmy,st:byte);

implementation

uses Graph,Crt;
{$S+}

const
 avvy = 1;
 test = 177;

type
 triprec = record
            handle:byte; { who is it? }
            x,y:integer; { current x&y }
            xm,ym:byte; { x&y margins }
            ix,iy:shortint; { inc x&y }
            stage:byte; { animation }
            xl,yl:integer; { x&y length }
            prime:boolean; { true on first move }
            alive:boolean; { true if it moves }
           end;

var
 tr:array[1..10] of triprec;
 tramt:byte;
 blue3:array[1..20000] of byte;
 pozzes:array[1..24] of word;

const
 up=1; right=2; down=3; left=4; ur=5; dr=6; dl=7; ul=8;

{                                                                              }
{       EGA Graphic Primitive for Turbo Pascal 3.01A, Version 01FEB86.         }
{       (C) 1986 by Kent Cedola, 2015 Meadow Lake Ct., Norfolk, VA, 23518      }
{                                                                              }
{       Description: Write a array of colors in a vertical line.  The current  }
{       merge setting is used to control the combining of bits.                }
{                                                                              }
 procedure GPWTCOL(var BUF; N: Integer); { Cedola }
 begin;
   inline
     ($1E/$A1/GDCUR_Y/$D1/$E0/$D1/$E0/$03/$06/GDCUR_Y/$05/$A000/$8E/$C0/$8B/$3E/
      GDCUR_X/$8B/$CF/$D1/$EF/$D1/$EF/$D1/$EF/$BA/$03CE/$8A/$26/GDMERGE/$B0/$03/
      $EF/$B8/$0205/$EF/$B0/$08/$EE/$42/$B0/$80/$80/$E1/$07/$D2/$C8/$EE/$8B/$4E/
      $04/$C5/$76/$06/$8A/$24/$46/$26/$8A/$1D/$26/$88/$25/$83/$C7/$50/$E2/$F2/
      $B0/$FF/$EE/$4A/$B8/>$05/$EF/$B8/>$03/$EF/$1F);
  end;


procedure loadtrip;
var inf:file;
begin;
 assign(inf,'t:avvy.trp'); reset(inf,1);
 seek(inf,$27);
 blockread(inf,pozzes,sizeof(pozzes));
 blockread(inf,blue3,sizeof(blue3)); close(inf);
end;

procedure enter(what_handle:byte; xx,yy,lx,ly:integer; mmx,mmy,st:byte);
begin;
 inc(tramt);
 with tr[tramt] do
 begin;
  handle:=what_handle;
  ix:=0; iy:=0;
  x:=xx; y:=yy;
  xl:=lx; yl:=ly;
  xm:=mmx; ym:=mmy; stage:=st;
  prime:=true; alive:=true;
 end;
end;

procedure plot(stage:byte; ox,oy:integer); { orig x & y. Page is always 1/UNSEEN. }
var x,y,len:byte; count:word;
begin;
 count:=pozzes[stage];
 repeat
  len:=blue3[count]; if len=177 then exit;
  x:=blue3[count+1]; y:=blue3[count+2]; inc(count,3);
  begin;
   gdcur_x:=x+ox; gdcur_y:=y+oy;
   { fiddle xy coords to match page 1 }
    inc(gdcur_y,205); { 203 } dec(gdcur_x,128); { 114 }
    if gdcur_x<0 then
     begin; inc(gdcur_x,640); dec(gdcur_y); end;
   gpwtcol(blue3[count],len); inc(count,len);
  end;
 until false;
end;

procedure trippancy;
var
 fv:byte; p,saved1,saved2:pointer; s:word; q:array[1..10] of pointer;
 allstill:boolean;
begin;
 if (cw<>177) or (not dropsOK) or keypressed then exit;

 { Do the Avvy Walk }

 case dna.rw of
     up: budge(avvy, 0,-3,anim*4-3);
   down: budge(avvy, 0, 3,anim*4-1);
  right: budge(avvy, 5, 0,anim*4-2);
   left: budge(avvy,-5, 0,anim*4  );
     ul: budge(avvy,-5,-3,anim*4  );
     dl: budge(avvy,-5, 3,anim*4  );
     ur: budge(avvy, 5,-3,anim*4-2);
     dr: budge(avvy, 5, 3,anim*4-2);
 end;

 for fv:=1 to tramt do with tr[fv] do boundscheck(x,y,xm,ym);

 allstill:=true;
 for fv:=1 to tramt do
  with tr[fv] do
   if ((alive) and (not ((ix=0) and (iy=0)))) or prime then allstill:=false;
 if allstill then exit;

 if dna.rw>0 then
 begin;
  inc(anim); if anim=7 then anim:=1;
 end;

 { Trippancy Step 1 - Grab moon array of unmargined sprites (phew) }
 mark(saved1);
 setactivepage(1); off;
 for fv:=1 to tramt do
  with tr[fv] do
  begin;
   s:=imagesize(x-xm,y-ym,x+xl+xm,y+yl+ym);
   getmem(q[fv],s); getimage(x-xm,y-ym,x+xl+xm,y+yl+ym,q[fv]^);
  end;
 { Step 2 - Plot sprites on 1/UNSEEN }
 for fv:=1 to tramt do
  with tr[fv] do
  begin;
   plot(stage,x,y);
  end;
 { Step 3 - Copy all eligible from 1/UNSEEN to 0/SEEN }
 mark(saved2);
 for fv:=1 to tramt do
  with tr[fv] do
   if ((alive) and (not ((ix=0) and (iy=0)))) or prime then
   begin;
    s:=imagesize(x-xm,y-ym,x+xl+xm,y+yl+ym);
    getmem(p,s);
    setactivepage(1); getimage(x-xm,y-ym,x+xl+xm,y+yl+ym,p^);
    setactivepage(0); putimage(x-xm,y-ym,p^,0);
    release(saved2); prime:=false;
   end;
 { Step 4 - Unplot sprites from 1/UNSEEN }
 setactivepage(1);
 for fv:=1 to tramt do
  with tr[fv] do
  begin;
   putimage(x-xm,y-ym,q[fv]^,0);
   if ix<>0 then x:=x+ix;
   if iy<>0 then y:=y+iy;
   ix:=0; iy:=0;
   if handle=avvy then with dna do begin; ux:=x; uy:=y; end;
  end;
 on; release(saved1);
 for fv:=1 to tramt do { synch xy coords of mouths }
  with tr[fv] do
   begin; mouths[fv].x:=x+20; mouths[fv].y:=y; end;

 setactivepage(0);
end;

procedure budge(who:byte; xx,yy:shortint; frame:byte); { Moving & animation controller }
var fv:byte;
begin;
 for fv:=1 to tramt do
  with tr[fv] do
   if handle=who then
   begin;
    ix:=xx; iy:=yy;
    stage:=frame;
   end;
end;

procedure tripkey(dir:char);
begin;
 if cw<>177 then exit;
 with dna do
 begin;
  case dir of
   'H': if rw<>up    then begin; rw:=up;    ww:=up;    end else rw:=0;
   'P': if rw<>down  then begin; rw:=down;  ww:=down;  end else rw:=0;
   'K': if rw<>left  then begin; rw:=left;  ww:=left;  end else rw:=0;
   'M': if rw<>right then begin; rw:=right; ww:=right; end else rw:=0;
   'I': if rw<>ur    then begin; rw:=ur;    ww:=right; end else rw:=0;
   'Q': if rw<>dr    then begin; rw:=dr;    ww:=right; end else rw:=0;
   'O': if rw<>dl    then begin; rw:=dl;    ww:=left;  end else rw:=0;
   'G': if rw<>ul    then begin; rw:=ul;    ww:=left;  end else rw:=0;
  end;
  if rw=0 then
  begin;
   ux:=ppos[0,0]; uy:=ppos[0,1]; dec(anim);
   if anim=0 then anim:=6;
  end;
 end;
end;

procedure boundscheck(var x,y:integer; xm,ym:byte);
begin;
 if y>127-ym then y:=127-ym; if y<ym+10 then y:=ym+10;
 if x<xm then x:=xm; if x>640-xm then x:=640-xm;
end;

begin; { init portion of Trip3 }
 tramt:=0;
end.