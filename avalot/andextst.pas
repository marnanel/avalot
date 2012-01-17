program andextest;
uses Graph;

type
 adxtype = array[1..24,0..1] of pointer;

var
 gd,gm:integer;
 s:word; f:file; n,anim,cp,t:byte;
 adx:array[0..0] of adxtype;
 back:array[0..1] of pointer;
 x:integer;
 ox:array[0..1] of integer;

procedure andex(x,y:integer; n,num:byte);
begin;
 putimage(x,y,adx[num,n,0]^,andput);
 putimage(x,y,adx[num,n,1]^,xorput);
end;

procedure loadadx(num:byte; x:string);
var n:byte;
begin;
 assign(f,x);
 reset(f,1); seek(f,59);
 blockread(f,n,1); { No. of images... }
 for gd:=1 to n do
  for gm:=0 to 1 do
  begin;
   blockread(f,s,2); { size of next image... }
   getmem(adx[num,gd,gm],s);
   blockread(f,adx[num,gd,gm]^,s); { next image }
  end;
 close(f);
end;

begin;
 loadadx(0,'d:sprite0.avd');
 loadadx(1,'d:sprite0.avd');
 gd:=3; gm:=0; initgraph(gd,gm,'');
 for gd:=0 to 1 do
 begin;
  setactivepage(gd); setfillstyle(6,1); bar(0,0,640,200);
  getmem(back[gd],s);
 end;
 x:=0; anim:=1; cp:=0; t:=2; setactivepage(0);
 repeat
  setactivepage(cp); setvisualpage(1-cp);
  for gm:=0 to 1 do
  begin;
   if t>0 then dec(t) else
    putimage(ox[cp],77,back[cp]^,copyput);
   getimage(x,77,x+31,77+35,back[cp]^);
   andex(x,177,anim+6,gm);
   ox[gm,cp]:=x; inc(x,5);
  end;
  inc(anim); if anim=7 then anim:=1;cp:=1-cp;
 until false;
end.