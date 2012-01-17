program pictemp;
uses Graph;

const
 picsize=966;

var
 gd,gm:integer;
 f:file;
 p:pointer;

procedure save;
var adf:string[40];  f:file; z:byte; c:array[1..2] of pointer;
nam,screenname:string;
const header : string =
 'This is a file from an Avvy game, and its contents are subject to '+
 'copyright.'+#13+#10+#13+#10+'Have fun!'+#26;
var
 a:byte absolute $A000:1200;
 bit:byte;
begin;
 nam:='d:thingtmp.avd';
 screenname:='Temp.';
 assign(f,nam);

     assign(f,nam); rewrite(f,1); blockwrite(f,header[1],146);
     blockwrite(f,screenname,31);
     for bit:=0 to 3 do
     begin;
      port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
      blockwrite(f,a,12080);
     end;
 close(f);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 assign(f,'thinks.avd');
 getmem(p,picsize);
 reset(f,1);
 seek(f,65);
 gd:=10; gm:=20;

 while gm<120 do
 begin;
  if not eof(f) then
   blockread(f,p^,picsize);
  putimage(gd,gm,p^,0);
  inc(gd,70);

  if gd=640 then
  begin;
   gd:=10; inc(gm,40);
  end;

 end;

 close(f); freemem(p,picsize);
 save;
end.