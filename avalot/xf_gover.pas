program xf_game_over_etc;
uses Graph;

procedure load;
var a:byte absolute $A000:1200; bit:byte; f:file;
begin;
 assign(f,'avagame.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure gfx;
var gd,gm:integer;
begin
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
end;

procedure blit(x1,y1,x2,y2,x3,y3:integer);
var p,q:pointer; s:word;
begin
 mark(q);

 s:=imagesize(x1,y1,x2,y2);
 getmem(p,s);
 getimage(x1,y1,x2,y2,p^);
 putimage(x3,y3,p^,0);

 release(q);
end;

procedure copy_hammer;
begin
 blit(274,47,311,67,92,10);
end;

procedure do_text;
begin
 settextjustify(1,1); setcolor(0);
 settextstyle(2,0,4);
 setusercharsize(120,100,100,100);
 outtextxy(112,32,'Thorsoft of Letchworth presents');
 blit(3,30,218,31,4,30);
 blit(4,35,219,38,3,35);
end;

procedure dump_to_file(x1,y1,x2,y2:byte; fn:string);
var
 y,bit:byte;
 f:file;
begin
 assign(f,fn);
 rewrite(f,1);

 for y:=y1 to y2 do
  for bit:=0 to 3 do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockwrite(f,mem[$A000:y*80+x1],x2-x1);
  end;

 close(f);

end;

begin
 gfx;
 load;

 setfillstyle(1,7);
 bar(2,10,219,37);
 bar(0,0,1,200);
 bar(220,0,250, 88);
 bar(0,88,213,147);
 bar(622,88,640,147);
 copy_hammer;
 do_text;

 dump_to_file( 0,10,28,86,'about.avd');
 dump_to_file(26,88,78,147,'gameover.avd');
end.