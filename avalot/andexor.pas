program andexor; { Trippancy IV - original file }
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
           end;


var
 gd,gm:integer;
 adx:adxtype;
 adxpic:array[1..24,0..1] of pointer; { the pictures themselves }
 f:file; x:string; n:byte;

procedure load(nam:string);
var z:byte;
 a:array[1..4] of pointer;
 f:file; s:word;
 xxx:string[40];
 check:string;

begin;
 assign(f,nam);
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
 for gm:=0 to 3 do
  for gd:=1 to 6 do
  begin; { 26,15 }
(*   bar((gm div 2)*320+gd*40,20+(gm mod 2)*40,(gm div 2)*320+gd*40+35,(gm mod 2)*40+60); *)
   for y:=1 to adx.yl do
    for x:=1 to adx.xl do
    begin;
     setactivepage(0);
     c:=getpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y);
     setactivepage(1);
(*     if c<>taboo then putpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y,0); *)
     if c=taboo then putpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y,15);
    end;
   getmem(adxpic[gm*6+gd,0],adx.size);
   getimage((gm div 2)*320+gd*40+1,20+(gm mod 2)*40+1,
     (gm div 2)*320+gd*40+adx.xl,20+(gm mod 2)*40+adx.yl,
      adxpic[gm*6+gd,0]^);
  end;
end;

procedure standard;
var x,y,c:byte;
begin;
 setvisualpage(2); setactivepage(2);
 for gm:=0 to 3 do
  for gd:=1 to 6 do
  begin; { 26,15 }
   for y:=1 to adx.yl do
    for x:=1 to adx.xl do
    begin;
     setactivepage(0);
     c:=getpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y);
     setactivepage(2);
     if c<>taboo then putpixel((gm div 2)*320+gd*40+x,20+(gm mod 2)*40+y,c);
    end;
   getmem(adxpic[gm*6+gd,1],adx.size);
   getimage((gm div 2)*320+gd*40+1,20+(gm mod 2)*40+1,
     (gm div 2)*320+gd*40+adx.xl,20+(gm mod 2)*40+adx.yl,
      adxpic[gm*6+gd,1]^);
  end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,''); fillchar(adxpic,sizeof(adxpic),#177);
 load('v:avalots.avd');
(* getmem(adxpic[1,1,1],adx.size); getimage(40,20,75,60,adxpic[1,1,1]^);
 putimage(100,100,adxpic[1,1,1]^,0); *)
 with adx do
 begin;
  name:='Avalot';
  num:=24; seq:=6;
  xl:=32; yl:=35; { 35,40 }

  size:=imagesize(40,20,40+xl,60+yl);
 end;
 silhouette;
 standard;
 x:='Sprite file for Avvy - Trippancy IV. Subject to copyright.'+#26;
 assign(f,'v:sprite1.avd');
 rewrite(f,1);
 blockwrite(f,x[1],59);
 blockwrite(f,adx,sizeof(adx));
 for gd:=1 to adx.num do
  for gm:=0 to 1 do
   blockwrite(f,adxpic[gd,gm]^,adx.size); { next image }
 close(f);
 closegraph;
end.