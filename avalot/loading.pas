program test;
uses Graph;
var
 gd,gm:integer;
 a:byte absolute $A000:1200;
 bit:byte;
 f:file;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 assign(f,'c:\sleep\test.ega'); reset(f,1);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12000);
 end;
 close(f);
end.