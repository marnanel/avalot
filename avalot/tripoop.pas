program tripoop; { Trip Oop (Trippancy 4 Andexor }
uses Graph,Crt;

const
 up = 0;
 right = 1;
 down = 2;
 left = 3;

 numtr = 1; { current max no. of sprites }

type
 adxtype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

 triptype = object
             a:adxtype; { vital statistics }
             face,step:byte;
             x,y:integer; { current xy coords }
             ox,oy:integer; { last xy coords }
             tax,tay:integer; { "behind" taken at... }
             ix,iy:shortint; { amount to move sprite by, each step }
             pic:array[1..24,0..1] of pointer; { the pictures themselves }
             quick,visible,homing:boolean;
             behind:pointer; { what's behind you }
             hx,hy:integer; { homing x & y coords }

             constructor Init(spritenum:byte); { loads & sets up the sprite }
             procedure original; { just sets Quick to false }
             procedure andexor; { drops sprite onto screen 1 }
             procedure turn(whichway:byte); { turns him round }
             procedure appear(wx,wy:integer; wf:byte); { switches him on }
             procedure walk; { prepares for do_it, andexor, etc. }
             procedure do_it; { Actually copies the picture over }
             procedure getback; { gets background before sprite is drawn }
             procedure putback; { ...and wipes sprite from screen 1 }
             procedure walkto(xx,yy:integer); { home in on a point }
             procedure stophoming; { self-explanatory }
             procedure homestep; { calculates ix & iy for one homing step }
             procedure speed(xx,yy:shortint); { sets ix & iy, non-homing, etc }
             procedure halt; { Stops the sprite from moving }
            end;

var
 gd,gm:integer;
 tr:array[1..1] of triptype;

procedure copier(x1,y1,x2,y2,x3,y3,x4,y4:integer);

  function dropin(xc,yc,x1,y1,x2,y2:integer):boolean;
  { Dropin returns True if the point xc,yc falls within the 1-2 rectangle. }
  begin;
   dropin:=((xc>=x1) and (xc<=x2) and (yc>=y1) and (yc<=y2));
  end;

  procedure transfer(x1,y1,x2,y2:integer);
  var p,q:pointer; s:word;
  begin;
   s:=imagesize(x1,y1,x2,y2); setfillstyle(1,0);
   mark(q); getmem(p,s);
   setactivepage(1); getimage(x1,y1,x2,y2,p^);
   setactivepage(0); putimage(x1,y1,p^,copyput);
   setactivepage(1); release(q);
  end;

  function lesser(a,b:integer):integer;
  begin;
   if a<b then lesser:=a else lesser:=b;
  end;

  function greater(a,b:integer):integer;
  begin;
   if a>b then greater:=a else greater:=b;
  end;

begin;
 if dropin(x3,y3,x1,y1,x2,y2)
 or dropin(x3,y4,x1,y1,x2,y2)
 or dropin(x4,y3,x1,y1,x2,y2)
 or dropin(x4,y4,x1,y1,x2,y2) then
 begin; { Overlaps }
  transfer(lesser(x1,x3),lesser(y1,y3),greater(x2,x4),greater(y2,y4));
 end else
 begin; { Doesn't overlap- copy both of them seperately }
  transfer(x3,y3,x4,y4); { backwards- why not...? }
  transfer(x1,y1,x2,y2);
 end;
end;

procedure setup;
var gd,gm:integer;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 for gd:=0 to 1 do
 begin;
  setactivepage(gd);
  setfillstyle(9,1); bar(0,0,640,200);
 end;
 for gm:=1 to numtr do tr[gm].original;
end;

constructor triptype.Init(spritenum:byte);
var
 gd,gm:integer; s:word; f:file; xx:string[2]; p,q:pointer; bigsize:word;
 sort,n:byte;
begin;
 str(spritenum,xx); assign(f,'v:sprite'+xx+'.avd');
 reset(f,1); seek(f,59);
 blockread(f,a,sizeof(a)); blockread(f,bigsize,2);
 setvisualpage(3); setactivepage(3);
 for sort:=0 to 1 do
 begin;
  mark(q); getmem(p,bigsize);
  blockread(f,p^,bigsize);
  putimage(0,0,p^,0); release(q); n:=1;
  with a do
   for gm:=0 to (num div seq)-1 do { directions }
    for gd:=0 to seq-1 do { steps }
    begin;
     getmem(pic[n,sort],a.size); { grab the memory }
     getimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       (gm div 2)*(xl*6)+gd*xl+xl-1,(gm mod 2)*yl+yl-1,
       pic[n,sort]^); { grab the pic }
     putimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       pic[n,sort]^,notput); { test the pic }
     inc(n);
   end;
 end;
 close(f); setactivepage(0); setvisualpage(0);
 x:=0; y:=0; quick:=true; visible:=false; getmem(behind,a.size);
 homing:=false; ix:=0; iy:=0;
end;

procedure triptype.original;
begin;
 quick:=false;
end;

procedure triptype.getback;
begin;
 tax:=x; tay:=y;
 getimage(x,y,x+a.xl,y+a.yl,behind^);
end;

procedure triptype.andexor;
var picnum:byte; { Picnum, Picnic, what ye heck }
begin;
 picnum:=face*a.seq+step+1;
 putimage(x,y,pic[picnum,0]^,andput);
 putimage(x,y,pic[picnum,1]^,xorput);
end;

procedure triptype.turn(whichway:byte);
begin;
 face:=whichway; step:=0;
end;

procedure triptype.appear(wx,wy:integer; wf:byte);
begin;
 x:=wx; y:=wy; ox:=wx; oy:=wy; turn(wf); visible:=true;
end;

procedure triptype.walk;
begin;
 ox:=x; oy:=y;
 if homing then homestep;
 x:=x+ix; y:=y+iy;
 inc(step); if step=a.seq then step:=0; getback;
end;

procedure triptype.do_it;
begin;
 copier(ox,oy,ox+a.xl,oy+a.yl,x,y,x+a.xl,y+a.yl);
end;

procedure triptype.putback;
begin;
 putimage(tax,tay,behind^,0);
end;

procedure triptype.walkto(xx,yy:integer);
begin;
 speed(xx-x,yy-y); hx:=xx; hy:=yy; homing:=true;
end;

procedure triptype.stophoming;
begin;
 homing:=false;
end;

procedure triptype.homestep;
var temp:integer;
begin;
 if (hx=x) and (hy=y) then
 begin; { touching the target }
  homing:=false; exit;
 end;
 ix:=0; iy:=0;
 if hy<>y then
 begin;
  temp:=hy-y; if temp>4 then iy:=4 else if temp<-4 then iy:=-4 else iy:=temp;
 end;
 if hx<>x then
 begin;
  temp:=hx-x; if temp>4 then ix:=4 else if temp<-4 then ix:=-4 else ix:=temp;
 end;
end;

procedure triptype.speed(xx,yy:shortint);
begin;
 ix:=xx; iy:=yy;
 if (ix=0) and (iy=0) then exit; { no movement }
 if ix=0 then
 begin; { No horz movement }
  if iy<0 then turn(up) else turn(down);
 end else
 begin;
  if ix<0 then turn(left) else turn(right)
 end;
end;

procedure triptype.halt;
begin;
 ix:=0; iy:=0; homing:=false;
end;

procedure trip;
var fv:byte;
begin;
 for fv:=1 to numtr do
  with tr[fv] do
  begin;
   walk;
   if quick and visible then andexor;
   do_it;
   putback;
  end;
end;

begin;
 setup;
 with tr[1] do
 begin;
  init(1);
  appear(600,100,left);
  repeat
   (*
   speed(-5,0); repeat trip until keypressed or (x=  0);
   speed( 5,0); repeat trip until keypressed or (x=600);
   *)
   walkto( 10, 10); repeat trip until keypressed or not homing;
   walkto( 70,150); repeat trip until keypressed or not homing;
   walkto(600, 77); repeat trip until keypressed or not homing;
  until keypressed;
 end;
end.