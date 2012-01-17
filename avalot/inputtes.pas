program inputtest;
uses Graph,Crt;
type
 fonttype = array[#0..#255,0..15] of byte;

var
 gd,gm:integer;
 font:fonttype;
 current:string[79];
 r:char;

procedure plottext;
var x,y:byte;
begin;
 for y:=0 to 7 do
 begin;
  for x:=1 to length(current) do
   mem[$A000:12880+y*80+x]:=font[current[x],y];
  fillchar(mem[$A000:12881+y*80+x],79-x,#0);
 end;
end;

procedure loadfont;
var f:file of fonttype;
begin;
 assign(f,'c:\thomas\ttsmall.fnt'); reset(f);
 read(f,font); close(f);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\turbo');
 loadfont;
 setfillstyle(1,6); bar(0,0,640,200);
 current:='';
 repeat
  r:=readkey;
  current:=current+r;
  plottext;
 until false;
end.