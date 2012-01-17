program test;
uses Graph;
var
 gd,gm:integer;
 a:byte absolute $A000:(15*80);
 bit:byte;
 f:file;

procedure load(nam:string);
var z:byte;
 a:array[1..4] of pointer;
 f:file; s:word;
 check:string;
begin;
 assign(f,nam);
 reset(f,1);
 blockread(f,check,41);
 blockread(f,check,13);
 blockread(f,check,31);
 s:=imagesize(0,0,Getmaxx,75);
 for z:=1 to 2 do
 begin;
  getmem(a[z],s);
  blockread(f,a[z]^,s);
  setactivepage(0);
  putimage(0,15+(z-1)*75,a[z]^,0);
  freemem(a[z],s);
 end;
 close(f);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 load('d:britain.avd');
 assign(f,'c:\sleep\test.ega'); rewrite(f,1);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockwrite(f,a,12000);
 end;
 close(f);
end.