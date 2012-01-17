program convertmouse;
uses Graph,Binu,Crt;

type cursor { ...gogogoch } = record
                               mask: array[0..1,0..15] of Word;
                               Horzhotspot,verthotspot:integer;
                              end;
     precursor { ha ha } = array[0..1,0..15] of string[16];

const
 colours: array[0..3] of byte = (darkgray,blue,white,green);

var
 c_current:cursor;
 usepointer:boolean;
 cpc:precursor;
 hhs,vhs:byte;
 fn,desc:string;
 gd,gm:integer;

procedure recalc;
var a,b:byte;
begin;
 with c_current do
 begin;
  for a:=0 to 1 do
   for b:=0 to 15 do
    mask[a,b]:=bintoword(cpc[a,b]);
  horzhotspot:=hhs; verthotspot:=vhs;
 end;
end;

procedure load;
var t:text; x:string; a,b:byte;
begin;
 assign(t,fn);
 reset(t);
 repeat readln(t,x) until x='|'; { bypass junk }
 readln(t,desc);
 for a:=0 to 1 do
  for b:=0 to 15 do
   readln(t,cpc[a,b]);
 readln(t,hhs); readln(t,vhs);
 close(t); recalc;
end;

procedure display;
const
 o0 = ord('0'); o1 = ord('1');
var x,y,p1,p2:byte;
begin;
 for y:=0 to 15 do
 begin;
  for x:=1 to 16 do
  begin;
   case ord(cpc[0,y,x])*2+ord(cpc[1,y,x]) of
    o0*2+o0: begin; p1:= 0; p2:= 0; end; { p1= silhouette, p2= real }
    o0*2+o1: begin; p1:= 0; p2:=15; end;
    o1*2+o0: begin; p1:=15; p2:= 0; end;
    o1*2+o1: begin; p1:= 9; p2:= 9; end; { invalid- can't use this }
   end;
   putpixel(x-1,y,p1); putpixel(x+99,y,p2);
  end;
  writeln;
 end;
end;

begin;
 gd:=3; gm:=1; initgraph(gd,gm,'');
 fn:='d:screwdri.inc';
 load;
 display;
end.