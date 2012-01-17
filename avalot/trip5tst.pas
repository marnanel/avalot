program trippancy5test;
uses Graph,Crt;
{$R+}

type
 adxtype = record
            name:string[12]; { name of character }
            comment:string[16]; { comment }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

var
 gd,gm:integer;
 inf:file;
 a:adxtype;
 aa:array[1..16000] of byte;
 mani:array[5..2053] of byte;
 sil:array[0..35,0..4] of byte;
 xw:byte;

procedure filesetup;
const idshould = -1317732048;
var
 id:longint;
 soa:word;
begin;
 assign(inf,'v:sprite2.avd');
 reset(inf,1);
 seek(inf,177);
 blockread(inf,id,4);
 if id<>idshould then
 begin;
  write(#7);
  close(inf);
  halt;
 end;

 blockread(inf,soa,2);
 blockread(inf,a,soa);
end;

procedure loadpic;
var fv,ff:byte;
begin;
 with a do
 begin;
  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);

(*  aa[1]:=xl; aa[2]:=0; aa[3]:=yl; aa[4]:=0;*)
   { The putimage x&y codes are words but xl & yl are bytes, hence the #0s. }
(*  seek(inf,filepos(inf)+xw*(yl+1));*)
  for fv:=0 to yl do
   blockread(inf,sil[fv],xw);
  blockread(inf,mani,size-6);
(*    blockread(inf,aa[5+fv*xw*4+xw*ff],xw);*)
  aa[size-1]:=0; aa[size]:=0; { footer }
 end;
(* putimage(0,0,aa,0);*)
end;

procedure plotone(xx,yy:integer);
var
 s:word;
 ofs,fv:word;
 x,y,z:byte;
begin;
 with a do
 begin;
  s:=imagesize(x,y,xx+xl,yy+yl);
  getimage(xx,yy,xx+xl,yy+yl,aa); { Now loaded into our local buffer. }

  { Now we've got to modify it! }

  for x:=0 to 3 do
   for y:=0 to 35 do
    for z:=0 to 4 do
    begin;
     ofs:=5+y*xw*4+xw*x+z;
     aa[ofs]:=aa[ofs] and sil[y,z];
    end;

 { mov ax,5   ; AX = ofs
   mov bx,xw  ; wherever we get xw from
   mov cx,x   ; ditto
   mov dx,y   ; ditto
   mul cx,bx  ; x*xw
   mul dx,bx  ; y*yw
   add ax,cx  ; now add 'em all up
   add ax,dx  ; ...
   mov bx,z   ; get z (we don't need x any more)
   mov cx,syz ; get silyz (where from??!)
   add ax,bx  ; add on the last part of the addition
   and ax,cx  ; AND ax with cx. That's it! }

(*
  for x:=1 to 4 do
  begin;
   for y:=0 to 35 do
    for z:=0 to 4 do
    begin;
     ofs:=5+y*xw*4+xw*x+z;
     aa[ofs]:=aa[ofs] xor pic[x,y,z];
    end;
  end;
*)

  for fv:=5 to size-2 do
   aa[fv]:=aa[fv] xor mani[fv];

  { Now.. let's try pasting it back again! }

  putimage(xx,yy,aa,0);
 end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 initgraph(gd,gm,'');
 setfillstyle(6,1); bar(0,0,640,200);
 filesetup;
 for gd:=1 to 9 do loadpic;
 repeat
  plotone(random(500),random(150));
 until keypressed;
 plotone(0,0);
 close(inf);
end.