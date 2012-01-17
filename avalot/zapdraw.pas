program zap_drawup;
uses Graph,Crt,Dos;

var
 f:file;
 bit:byte;
 a:byte absolute $A000:0;
 gd,gm:integer;

procedure graphmode(mode:integer);
var regs:registers;
begin;
 regs.ax:=(mode mod $100);
 intr($10,regs);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 assign(f,'d:avltzap.raw'); reset(f,1);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for gd:=0 to 199 do
   blockread(f,mem[$A000:gd*80],40); { 28000 }
 end;
 close(f);
 setwritemode(xorput);
 rectangle(  0,  0,  5,  8);
 rectangle(  0, 10, 27, 19);
end.