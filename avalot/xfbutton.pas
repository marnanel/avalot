program xf_buttons;
uses Graph;
var
 x,y:integer;
 f,out:file;

procedure load; { Load2, actually }
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
 gd,gm:integer;
begin
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 assign(f,'d:butnraw.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure grab(x1,y1,x2,y2:integer); { s=930 }
var s:word; p:pointer;
begin
 s:=imagesize(x1,y1,x2,y2);
 getmem(p,s);
 getimage(x1,y1,x2,y2,p^);
 putimage(0,0,p^,0);
 blockwrite(out,p^,s);
 freemem(p,s);
 rectangle(x1,y1,x2,y2);
end;

begin
 assign(f,'d:butnraw.avd');
 assign(out,'v:buttons.avd'); rewrite(out,1);
 load;
 for x:=0 to 5 do
  for y:=0 to 3 do
  begin
   if not
    (((x=1) and (y=0))
  or ((x=4) and (y=2))
  or ((y=3) and (x>2) and (x<5))) then
     begin
      readln;
      grab(100+x*83,51+y*22,180+x*83,71+y*22);
     end;
  end;
 close(out);
end.
