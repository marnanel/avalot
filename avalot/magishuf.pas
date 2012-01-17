program shuffle3;
uses Dos,Crt;

const nextcode : word = 17717;

type
 big = array[1..8000] of word;
 circle = array[1..16401] of word;

var
 b:big;
 f:file of big;
 r:registers;
 gd:word;
 c:circle;
 fc:file of circle;

procedure melt(c:byte);
begin;
 for gd:=1 to 8000 do
 begin;
  mem[$A000:b[gd]]:=c;
  if (gd mod 17)=0 then delay(1);
 end;
end;

procedure magicirc(cc:byte);
begin;
 for gd:=1 to 16401 do
 begin;
  if c[gd]<>nextcode then
  begin;
   if odd(c[gd]) then mem[$A000:c[gd] div 2]:=cc;
  end else
   delay(1);
 end;
end;

begin;
 r.ax:=13; intr($10,r);
 assign(f,'d:shuffle.avd'); reset(f); read(f,b); close(f);
 assign(fc,'v:magic2.avd'); reset(fc); read(fc,c); close(fc);
(* repeat
  melt(170); magicirc(85);
  magicirc(170); melt(85);
  magicirc(170); magicirc(85);
  melt(170); melt(85);
 until keypressed;*)
 repeat
  melt(255); magicirc(0);
  magicirc(255); melt(0);
  magicirc(255); magicirc(0);
  melt(255); melt(0);
 until keypressed;
end.