program ttmenu_xf;
uses Graph,Tommys,Crt;
var
 gd,gm:integer;
 s:word; p:pointer;
 f:file of byte;
 bit:byte;

procedure load; { Load2, actually }
var
 a0:byte absolute $A000:800;
 a1:byte absolute $A000:17184;
 bit:byte;
 f:file; xx:string[2];
 was_Virtual:boolean;
begin
 assign(f,'v:ttmenu.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure finder;
var r:char; x,y:integer;
begin;
 setfillstyle(0,0); setcolor(14);
 x:=320; y:=100; setwritemode(xorput);
 repeat
  bar(0,0,200,10);
  outtextxy(0,0,strf(x)+','+strf(y));
  line(x-20,y,x+20,y); line(x,y-20,x,y+20);
  repeat until keypressed;
  line(x-20,y,x+20,y); line(x,y-20,x,y+20);
  case readkey of
   #13: exit;
   '8': dec(y,10);
   '4': dec(x,10);
   '6': inc(x,10);
   '2': inc(y,10);
    #0: case readkey of
         cUp: dec(y);
         cDown: inc(y);
         cLeft: dec(x);
         cRight: inc(x);
        end;
  end;
 until false;
end;

begin
 gd:=3; gm:=1; initgraph(gd,gm,'');
 load;
 finder;
 s:=imagesize(342,21,407,119);
 getmem(p,s);
 getimage(342,21,407,119,p^);
 putimage(342,21,p^,4);
 readln;
 putimage(264,120,p^,0);
 readln;
 freemem(p,s);

 s:=imagesize(264,12,329,217);
 getmem(p,s);
 getimage(264,21,329,218,p^);
 putimage(264,21,p^,4);
 putimage(0,0,p^,0);
 freemem(p,s);
 readln;

 s:=imagesize(180,103,188,135);
 getmem(p,s);
 getimage(180,103,188,135,p^);
 putimage(0,200,p^,0);
 readln;

 assign(f,'v:menu.avd');
 rewrite(f);

 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for gd:=0 to 196 do
   for gm:=0 to 8 do
   begin
    write(f,mem[$A000:gd*80+gm]);
    mem[$A000:gd*80+gm]:=not mem[$A000:gd*80+gm];
   end;

  for gd:=200 to 232 do
  begin
   write(f,mem[$A000:gd*80]);
   mem[$A000:gd*80]:=not mem[$A000:gd*80];
  end;
 end;

 close(f);
end.