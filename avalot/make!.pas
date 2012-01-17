program makeexclamationmarkfile; { Phew! }
uses Graph;
{$S-}
var
 gd,gm:integer;
 f:file;
 t:text;
 x:string;

function subpix(x,y:integer):boolean;
begin;
 subpix:=getpixel(x,y)=15;
end;

function pixel(x,y:integer):byte;
begin;
 pixel:=byte(
   subpix(x*4,y*2) or
   subpix(x*4+1,y*2) or
   subpix(x*4+2,y*2) or
   subpix(x*4+3,y*2)
   subpix(x*4,y*2+1) or
   subpix(x*4+1,y*2+1) or
   subpix(x*4+2,y*2+1) or
   subpix(x*4+3,y*2+1)
  )*15;
end;

begin;
 gd:=3; gm:=1; initgraph(gd,gm,'o:');
 assign(f,'v:logo.avd'); reset(f,1);
 for gd:=0 to 180 do
  blockread(f,mem[$A000:(gd*80)],53);
 close(f);
 for gd:=1 to 106 do
  for gm:=0 to 145 do
   putpixel(gd,gm+181,pixel(gd,gm));
 assign(t,'d:avalot.txt');
 rewrite(t);
 for gm:=1 to 36 do
 begin;
  x:='';
  for gd:=1 to 106 do
   case getpixel(gd,gm*2+181)*2+getpixel(gd,gm*2+182) of
     0: x:=x+' ';
    15: x:=x+'Ü';
    30: x:=x+'ß';
    45: x:=x+'Û';
   end;
  writeln(t,x);
 end;
 close(t);
end.