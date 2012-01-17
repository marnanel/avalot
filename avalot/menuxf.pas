program menu_xf;
uses Graph;
var gd,gm:integer;

procedure load; { Load2, actually }
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
begin
 assign(f,'maintemp.avd'); reset(f,1);
 { Compression method byte follows this... }
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure save;
var bit:byte; f:file;
begin
 assign(f,'v:mainmenu.avd');
 rewrite(f,1);
 for bit:=0 to 3 do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockwrite(f,mem[$A000:48*80],59*80);
  end;
 close(f);
end;

begin
 gd:=3; gm:=1; initgraph(gd,gm,'');
 load; { Between 48 and 107. }

 save;
end.