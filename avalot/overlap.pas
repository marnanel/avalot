program overlaps;
uses Graph,Crt;
var
 gd,gm:integer;

procedure flash(x1,y1,x2,y2:integer);
begin;
 setcolor(14); rectangle(x1,y1,x2,y2);
 sound(x1+x2); delay(100); nosound; delay(500);
 setcolor( 9); rectangle(x1,y1,x2,y2); delay(500);
end;

function dropin(xc,yc,x1,y1,x2,y2:integer):boolean;
{ Dropin returns True if the point xc,yc falls within the 1-2 rectangle. }
begin;
 dropin:=((xc>=x1) and (xc<=x2) and (yc>=y1) and (yc<=y2));
end;

procedure test(x1,y1,x2,y2,x3,y3,x4,y4:integer);
begin;
 cleardevice;
 rectangle(x1,y1,x2,y2);
 rectangle(x3,y3,x4,y4);
 flash(x1,y1,x2,y2);
 flash(x3,y3,x4,y4);

 if dropin(x3,y3,x1,y1,x2,y2)
 or dropin(x3,y4,x1,y1,x2,y2)
 or dropin(x4,y3,x1,y1,x2,y2)
 or dropin(x4,y4,x1,y1,x2,y2) then
 begin; { Overlaps }
  flash(x1,y1,x4,y4);
 end else
 begin; { Doesn't overlap- flash 'em both again }
  flash(x3,y3,x4,y4); { backwards- why not...? }
  flash(x1,y1,x2,y2);
 end;
end;

begin;
 gd:=3; gm:=1; initgraph(gd,gm,''); setcolor(9);
 test(100,50,200,100,400,200,600,250);
 test(100,50,200,100,120, 70,220,120);
 test(100,50,200,100,150, 50,250,100);
end.