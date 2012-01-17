program zoomout_test;
uses Graph,Crt;
var
 gd,gm:integer;

procedure zoomout(x,y:integer);
var
 x1,y1,x2,y2:integer;
 fv:byte;
begin;
 setcolor(white); setwritemode(xorput);
 setlinestyle(dottedln,0,1);

 for fv:=1 to 20 do
 begin;
  x1:=x-(x div 20)*fv;
  y1:=y-((y-10) div 20)*fv;
  x2:=x+(((639-x) div 20)*fv);
  y2:=y+(((161-y) div 20)*fv);

  rectangle(x1,y1,x2,y2);
  delay(17);
  rectangle(x1,y1,x2,y2);
 end;
end;

procedure zoomin(x,y:integer);
var
 x1,y1,x2,y2:integer;
 fv:byte;
begin;
 setcolor(white); setwritemode(xorput);
 setlinestyle(dottedln,0,1);

 for fv:=20 downto 1 do
 begin;
  x1:=x-(x div 20)*fv;
  y1:=y-((y-10) div 20)*fv;
  x2:=x+(((639-x) div 20)*fv);
  y2:=y+(((161-y) div 20)*fv);

  rectangle(x1,y1,x2,y2);
  delay(17);
  rectangle(x1,y1,x2,y2);
 end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 zoomout(177,77);
 zoomout(7,31);
 zoomout(577,124);
 zoomout(320,85);
 zoomin(177,77);
 zoomin(7,31);
 zoomin(577,124);
 zoomin(320,85);
end.