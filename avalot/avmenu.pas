program menu;
uses Graph,Crt,Tommys;
type fonttype = array[#0..#255,0..15] of byte;

var
 font:fonttype;
 Storage_SEG,Storage_OFS:word;
 result:byte;
 registrant:string;

procedure icons;
var
 f:file;
 gd,gm:word; bit:byte;
 v:byte;
begin
 assign(f,'menu.avd');
 reset(f,1);

 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for gd:=70 to 266 do
   blockread(f,mem[$A000:gd*80+6],9);

  for gd:=0 to 32 do
  begin
    blockread(f,v,1);
   for gm:=0 to 5 do
    mem[$A000:73+((70+gd+gm*33)*80)]:=v; { 79 }
  end;

 end;
 close(f);

 bit:=getpixel(0,0);

 setfillstyle(1, 7); for gd:=0 to 5 do bar(114, 73+gd*33,583, 99+gd*33);
 setfillstyle(1,15); for gd:=0 to 5 do bar(114, 70+gd*33,583, 72+gd*33);
 setfillstyle(1, 8); for gd:=0 to 5 do bar(114,100+gd*33,583,102+gd*33);

end;

procedure load_regi_info;
var
 t:text;
 fv:byte;
 x:string;
 namelen,numlen:byte;
 namechk,numchk:string;
 reginum:string;

 function decode1(c:char):char;
 var b:byte;
 begin
   b:=ord(c)-32;
   decode1:=chr(( (b and $F) shl 3) + ((b and $70) shr 4));
 end;

 function decode2(c:char):char;
 begin
   decode2:=chr( (ord(c) and $F) shl 2 + $43);
 end;

 function checker(proper,check:string):boolean;
 var fv:byte; ok:boolean;
 begin
   ok:=true;
   for fv:=1 to length(proper) do
     if (ord(proper[fv]) and $F)<>((ord(check[fv])-$43) shr 2)
       then ok:=false;

   checker:=ok;
 end;

begin
  {$I-}
  assign(t,'register.dat'); reset(t);
  {$I+}

  if ioresult<>0 then
  begin
    registrant:='(Unregistered evaluation copy.)';
    exit;
  end;

  for fv:=1 to 53 do readln(t);
  readln(t,x);
  close(t);

  namelen:=107-ord(x[1]); numlen:=107-ord(x[2]);

  registrant:=copy(x,3,namelen);
  reginum:=copy(x,4+namelen,numlen);
  namechk:=copy(x,4+namelen+numlen,namelen);
  numchk:=copy(x,4+namelen+numlen+namelen,numlen);

  for fv:=1 to namelen do registrant[fv]:=decode1(registrant[fv]);
  for fv:=1 to numlen do reginum[fv]:=decode1(reginum[fv]);

  if (not checker(registrant,namechk)) or (not checker(reginum,numchk))
   then registrant:='?"!? ((.)'
  else
   registrant:=registrant+' ('+reginum+').';

end;

procedure flesh_colours; assembler;
asm
  mov ax,$1012;
  mov bx,21;                 { 21 = light pink (why?) }
  mov cx,1;
  mov dx,seg    @flesh;
  mov es,dx;
  mov dx,offset @flesh;
  int $10;

  mov dx,seg    @darkflesh;
  mov es,dx;
  mov dx,offset @darkflesh;
  mov bx,5;                 { 5 = dark pink. }
  int $10;

  jmp @TheEnd;

 @flesh:
  db 56,35,35;

 @darkflesh:
  db 43,22,22;

 @TheEnd:
end;

procedure setup;
var
 gd,gm:integer;
 ff:file of fonttype;
begin
 if paramstr(1)<>'jsb' then halt(255);
 checkbreak:=false;
 val(paramstr(2),Storage_SEG,gd);
 val(paramstr(3),Storage_OFS,gd);

 assign(ff,'avalot.fnt');
 reset(ff); read(ff,font); close(ff);

 gd:=3; gm:=1; initgraph(gd,gm,'');
 setvisualpage(1); 

 icons;
end;

procedure big(x,y:word; z:string; notted:boolean);
var fv,ff:byte; start,image:word; bit:byte;

  procedure generate(from:byte);
  var fv:byte;
  begin
   image:=0;
   for fv:=0 to 7 do
    inc(image,(from and (1 shl fv)) shl fv);

   inc(image,image shl 1);
   image:=hi(image)+lo(image)*256;
   if notted then image:=not image;
  end;
begin
 start:=x+y*80;

 for fv:=1 to length(z) do
 begin
  for ff:=1 to 12 do
  begin
   generate(font[z[fv],ff+1]);
   for bit:=0 to 2 do
   begin
    port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
    memW[$A000:start+   ff*160]:=image;
    memW[$A000:start+80+ff*160]:=image;
   end;
  end;
  inc(start,2);
 end;
 bit:=getpixel(0,0);
end;

procedure centre(y:integer; z:string);
begin
 big(40-(length(z)),y,z,false);
end;

procedure option(which:byte; what:string);
begin
 big(16,41+which*33,char(which+48)+')',true);
 big(24,41+which*33,what,true);
end;

procedure invert(x1,y1,x2,y2:integer);
var s:word; p:pointer;
begin
 s:=imagesize(x1,y1,x2,y2);
 getmem(p,s);
 getimage(x1,y1,x2,y2,p^);
 putimage(x1,y1,p^,4);
 sound(y1); delay(30);
 sound(600-y2); delay(20);
 nosound;  delay(200);
 putimage(x1,y1,p^,0);
 delay(250);
end;

procedure wait;
var x:word; r:char; pressed:boolean;
begin
 x:=0; pressed:=false;
 repeat
  setfillstyle(6,15); bar(x  ,330,x-1,337);
  setfillstyle(1, 0); bar(x-2,330,x-3,337);
  delay(40); inc(x);

  if keypressed then
  begin
   r:=readkey;
   if r=#0 then
   begin
    r:=readkey; { and...? }
   end else
   begin { Not an extended keystroke. }
    if r in ['1'..'6',cSpace,cEscape,cReturn] then pressed:=true;
   end;
  end;

 until (x=640) or pressed;

 if (r=cSpace) or (r=cReturn) then r:='1';
 if r=cEscape then r:='6';
 if pressed then
 begin
  result:=ord(r)-48;
  invert(48,37+result*33,114,69+result*33);
 end else result:=177;
end;

procedure show_up;
begin
 setvisualpage(0);
end;

procedure loadmenu;
var f:file; bit:byte;
begin
 assign(f,'mainmenu.avd');
 reset(f,1);
 for bit:=0 to 3 do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockread(f,mem[$A000:0],59*80);
  end;
 close(f);
 bit:=getpixel(0,0);
end;

begin
 setup;
 loadmenu;
 load_regi_info;
 option(1,'Play the game.');
 option(2,'Read the background.');
 option(3,'Preview... perhaps...');
 option(4,'View the documentation.');
 option(5,'Registration info.');
 option(6,'Exit back to DOS.');
 centre(275,registrant);
 centre(303,'Make your choice, or wait for the demo.');

 show_up;
 wait;
 mem[Storage_SEG:Storage_OFS]:=result;
 closegraph;
end.