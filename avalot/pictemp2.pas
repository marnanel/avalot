program pictemp2; { Get 'em back! }
uses Graph;

const
 picsize=966;
 number_of_objects = 17;

 thinks_header : array[1..65] of char =
  'This is an Avalot file, which is subject to copyright. Have fun.'+^z;

var
 gd,gm:integer;
 f:file;
 p:pointer;
 noo:byte;

procedure load;
var
 a0:byte absolute $A000:1200;
 bit:byte;
 f:file;
begin;
 assign(f,'d:thingtmp.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f); bit:=getpixel(0,0);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 load; noo:=0;

 assign(f,'thinks.avd');
 getmem(p,picsize);
 rewrite(f,1);
 blockwrite(f,thinks_header,65);
 gd:=10; gm:=20;

 while noo<=number_of_objects do
 begin;
  getimage(gd,gm,gd+59,gm+29,p^);
  putimage(gd,gm,p^,notput);
  blockwrite(f,p^,picsize);
  inc(gd,70);

  if gd=640 then
  begin;
   gd:=10; inc(gm,40);
  end;

  inc(noo);
 end;

 close(f); freemem(p,picsize);
end.