program folktemp; { Get 'em back! }
uses Graph;

const
 picsize=966;
 number_of_objects = 19;

 thinks_header : array[1..65] of char =
  'This is an Avalot file, which is subject to copyright. Have fun.'+^z;

 order: array[0..19] of byte =
  ( 4, 19,  1, 18, 15,  9, 12, 13, 17, 10,  2,  6,  3,  5,  7, 14,
   16,

    0, 11,  8);

(*
 pAvalot=#150; pSpludwick=#151; pCrapulus=#152; pDrDuck=#153;
 pMalagauche=#154; pFriarTuck=#155; pRobinHood=#156; pCwytalot=#157;
 pduLustie=#158; pDuke=#159; pDogfood=#160; pTrader=#161;
 pIbythneth=#162; pAyles=#163; pPort=#164; pSpurge=#165;
 pJacques=#166;

 pArkata=#175; pGeida=#176; pWiseWoman=#178;
*)

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
 assign(f,'d:folk.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f); bit:=getpixel(0,0);
end;

procedure get_one;
begin;

 gd:=((order[noo] mod 9)*70+10);
 gm:=((order[noo] div 9)*40+20);

 getimage(gd,gm,gd+59,gm+29,p^);
 putimage(gd,gm,p^,notput);
 blockwrite(f,p^,picsize);

end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 load; noo:=0;

 assign(f,'folk.avd');
 getmem(p,picsize);
 rewrite(f,1);
 blockwrite(f,thinks_header,65);

 for noo:=0 to number_of_objects do
  get_one;

 close(f); freemem(p,picsize);
end.