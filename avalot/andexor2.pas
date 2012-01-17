program andexor2; { Trippancy IV - original file }
uses Graph;
const
 taboo=cyan;

type
 adxtype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of all the pictures }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;


var
 gd,gm:integer;
 adx:adxtype;
 adxpic:array[0..1] of pointer; { the pictures themselves }
 f:file; x:string; n:byte; side2:integer; bigsize:word;

procedure load(n:string);
var z:byte;
 a:array[1..4] of pointer;
 f:file; s:word;
 xxx:string[40];
 check:string;

begin;
 assign(f,n);
 reset(f,1);
 blockread(f,xxx,41);
 blockread(f,check,13);
 blockread(f,check,31);
 s:=imagesize(0,0,Getmaxx,75);
 for z:=1 to 2 do
 begin;
  getmem(a[z],s);
  blockread(f,a[z]^,s);
  putimage(0,15+(z-1)*75,a[z]^,0);
  freemem(a[z],s);
 end;
 close(f);
end;

procedure silhouette;
var x,y,c:byte;
begin;
 setvisualpage(1); setactivepage(1); setfillstyle(1,15);
 with adx do
 begin;
  for gm:=0 to 3 do
   for gd:=1 to 6 do
   begin; { 26,15 }
    side2:=xl*6;
    for y:=1 to yl do
     for x:=1 to xl do
     begin;
      setactivepage(0);
      c:=getpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y);
      setactivepage(1);
      if c=taboo then
       putpixel((gm div 2)*side2+gd*xl+x,20+(gm mod 2)*yl+y,15);
     end;
   end;
  bigsize:=imagesize(xl+1,21,xl*13,20+yl*2);
  getmem(adxpic[0],bigsize);
  getimage(xl+1,21,xl*13,20+yl*2,adxpic[0]^);
  putimage(xl+1,21,adxpic[0]^,notput);
 end;
end;

procedure standard;
var x,y,c:byte;
begin;
 setvisualpage(2); setactivepage(2);
 with adx do
 begin;
  for gm:=0 to 3 do
   for gd:=1 to 6 do
   begin; { 26,15 }
    for y:=1 to yl do
     for x:=1 to xl do
     begin;
      setactivepage(0);
      c:=getpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y);
      setactivepage(2);
      if c<>taboo then
       putpixel((gm div 2)*side2+gd*xl+x,20+(gm mod 2)*yl+y,c);
     end;
(*    getmem(adxpic[gm*6+gd,1],adx.size);
    getimage((gm div 2)*side2+gd*xl+x,20+(gm mod 2)*yl+y,
       (gm div 2)*side2+gd*xl*2+x,20+(gm mod 2)*yl*2+y,
       adxpic[gm*6+gd,1]^); *)
  end;
  getmem(adxpic[1],bigsize);
  getimage(xl+1,21,xl*13,20+yl*2,adxpic[1]^);
  putimage(xl+1,21,adxpic[1]^,notput);
 end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,''); fillchar(adxpic,sizeof(adxpic),#177);
 load('v:avalots.avd');
 with adx do
 begin;
  name:='Avalot';
  num:=24; seq:=6;
  xl:=33; yl:=35; { 35,40 }
  fgc:=yellow; bgc:=red;

  size:=imagesize(40,20,40+xl,60+yl);
 end;
 silhouette;
 standard;
 x:='Sprite file for Avvy - Trippancy IV. Subject to copyright.'+#26;
 assign(f,'v:sprite1.avd');
 rewrite(f,1);
 blockwrite(f,x[1],59);
 blockwrite(f,adx,sizeof(adx));
 blockwrite(f,bigsize,2);
 for gm:=0 to 1 do
 begin;
  putimage(0,0,adxpic[gm]^,0);
  blockwrite(f,adxpic[gm]^,bigsize); { next image }
 end;
 close(f);
 closegraph;
end.