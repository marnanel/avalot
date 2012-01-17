program clock;
uses Dos,Graph,Crt;
const xm=511; ym=184;
var
 gd,gm:integer;
 oh,om,(*os,*)h,m,s,s1:word; r:char;

procedure hand(ang,length:word; colour:byte);
var a:arccoordstype;
begin;
 if ang>900 then exit;
 setcolor(colour);
 arc(xm,ym,449-ang,450-ang,length);
 getarccoords(a);
 with a do line(xm,ym,xend,yend); { "With a do-line???!", Liz said }
end;

procedure chime;
var gd,gm,fv:integer;
begin;
 if oh>177 then exit; { too high- must be first time around }
 fv:=h div 30; if fv=0 then fv:=12;
 for gd:=1 to fv do
 begin;
  for gm:=1 to 3 do
  begin;
   sound(140-gm*30); delay(50-gm*3);
  end;
  nosound; if gd<>oh then delay(100);
 end;
end;

procedure plothands;
begin;
 hand(oh,17,brown);
 hand(h,17,yellow);
 hand(om*6,20,brown);
 hand(m*6,20,yellow);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 setfillstyle(1,6); bar(0,0,640,200); oh:=17717; om:=17717;
 repeat
  gettime(h,m,s,s1);
  h:=(h mod 12)*30+m div 2;
  if (oh<>h) then begin; plothands; chime; end;
  if (om<>m) then plothands;
  oh:=h; om:=m;
 until false;
end.