{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 TRIP             The trippancy handler. (Trippancy 2) }

unit Trip;

interface

 procedure loadtrip;

 procedure plot(count:word; ox,oy:integer);

 procedure boundscheck;

 procedure budge;

 procedure tripkey(dir:char);

 procedure trippancy;

implementation

uses Graph,Gyro,Dos;

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

procedure plot(count:word; ox,oy:integer); { orig x & y. Page is always 1. }
var x,y,len:byte;
begin;
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

procedure boundscheck;
begin;
 if dna.uy>123 then dna.uy:=123;
 if dna.uy<10 then dna.uy:=10;
 if dna.ux<5 then dna.ux:=5;
 if dna.ux>600 then dna.ux:=600;
end;

procedure budge;
begin;
 if dna.rw in [up,ul,ur] then dec(dna.uy,3);
 if dna.rw in [down,dl,dr] then inc(dna.uy,3);
 if dna.rw in [left,ul,dl] then dec(dna.ux,5);
 if dna.rw in [right,ur,dr] then inc(dna.ux,5);

 boundscheck;

 if dna.rw>0 then
 begin;
  inc(anim); if anim=7 then anim:=1;
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

procedure trippancy;
begin;
 if (dna.rw=0) or (cw<>177) or (not dropsOK) then exit;
 r.ax:=11; intr($33,r);
 setactivepage(1); off;
 if ppos[0,1]<>-177 then
 begin;
  putimage(ppos[0,0],ppos[0,1],replace[0]^,0);
 end;

 getimage(dna.ux,dna.uy,dna.ux+xw,dna.uy+yw,replace[0]^);
 ppos[0,0]:=dna.ux; ppos[0,1]:=dna.uy;

 plot(pozzes[anim*4+dna.ww-4],dna.ux,dna.uy);

 with r do if (cx=0) and (dx=0) then on;
 getimage(dna.ux-margin,dna.uy-margin,dna.ux+xw+margin,dna.uy+yw+margin,copier^);
 setactivepage(0); off; putimage(dna.ux-margin,dna.uy-margin,copier^,0); on;

 with mouths[0] do begin; x:=dna.ux+20; y:=dna.uy; end;

 budge;
end;

end.