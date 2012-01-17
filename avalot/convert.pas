program test;
uses Graph;
var
 gd,gm:integer;
 fn1,fn2:string;
 desc:string[30];

procedure loadscreen(nam:string);
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

procedure load2(name:string);
var
 a:byte absolute $A000:1200;
 bit:byte;
 f:file;
begin;
 assign(f,name); reset(f,1); seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12080);
 end;
 close(f);
end;

procedure save2(name:string);
const header : string =
 'This is a file from an Avvy game, and its contents are subject to '+
 'copyright.'+#13+#10+#13+#10+'Have fun!'+#26;
var
 a:byte absolute $A000:1200;
 bit:byte;
 f:file;
begin;
 assign(f,name); rewrite(f,1); blockwrite(f,header[1],146); { really 90 }
 blockwrite(f,desc,31);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockwrite(f,a,12080);
 end;
 close(f);
end;

begin;
 write('Filename?'); readln(fn1);
 write('New name?'); readln(fn2);
 write('Describe?'); readln(desc);
 gd:=3; gm:=0; initgraph(gd,gm,'');
 loadscreen(fn1);
 save2(fn2);
 closegraph;
end.