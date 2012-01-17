program transfer;
uses Graph;
var gd,gm:integer;
 z:byte;
 a:array[1..4] of pointer;
 f:file; s:word;
 check:string;
 x,y:integer;
procedure savesc;
var adf:string[40]; f:file; z:byte; c:array[1..2] of pointer; s:word;
nam:string[14]; screenname:string[30];
begin;
 nam:='v:avvymonk.avd';
 adf:='aved as a stuff file, so there! TJAT.'+#13+#10+#26;
 adf[0]:='S';
 screenname:='Avalot in a monk''s costume';
 assign(f,nam); { not scrambled }
 rewrite(f,1);
 blockwrite(f,adf,41);
 blockwrite(f,nam,13);
 blockwrite(f,screenname,31);
 s:=imagesize(0,0,Getmaxx,75);
 for z:=1 to 2 do
 begin;
  getmem(c[z],s);
  getimage(0,15+(z-1)*75,getmaxx,15+(z)*75,c[z]^);
  blockwrite(f,c[z]^,s);
  freemem(c[z],s);
 end;
end;
procedure loadscreen(nam:string);
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
 gd:=3; gm:=0;
 x:=0; y:=0;
 initgraph(gd,gm,'o:');
 loadscreen('v:legion.avd');
 while y<100 do
 begin;
  case Getpixel(x,y) of
   7: PutPixel(x,y,0);
   8: PutPixel(x,y,0);
   9: PutPixel(x,y,15);
  end;
  inc(x);
  if x>640 then begin; inc(y); x:=0; end;
 end;
 savesc;
end.