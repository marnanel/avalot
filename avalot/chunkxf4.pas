program xf_chunk_4;
uses Graph,Tommys,Crt;

type
 flavourtype = (ch_EGA,ch_BGI);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                   natural:boolean;

                   memorise:boolean; { Hold it in memory? }
                  end;

 kind = (walled,unwalled);

const
 chunkheader : array[1..44] of char =
 'Chunk-type AVD file, for an Avvy game.'+#26+#177+#$30+#$01+#$75+#177;

 arraysize = 12000;

 w = walled; uw = unwalled;

var
 offsets:array[1..50] of longint;
 num_chunks,this_chunk:byte;
 gd,gm:integer;
 f:file;
 aa:array[0..arraysize] of byte;

procedure rdln;
var r:char;
begin EXIT;
 repeat r:=readkey until not keypressed;
end;

procedure load(k:kind);
var
 a1:byte absolute $A400:800;
 bit:byte;
 f:file;
begin

 if k=unwalled then assign(f,'place29.avd')
  else assign(f,'walled.avd');

 reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a1,12080);
 end;

 close(f);
 bit:=getpixel(0,0);
end;

procedure finder;
var r:char; x,y:integer;
begin EXIT;
 setfillstyle(0,0); setcolor(14);
 x:=320; y:=100; setwritemode(xorput);
 repeat
  bar(0,0,200,10);
  outtextxy(0,0,strf(x)+','+strf(y));
  line(x-20,y,x+20,y); line(x,y-20,x,y+20);
  repeat until keypressed;
  line(x-20,y,x+20,y); line(x,y-20,x,y+20);
  case readkey of
   #13: exit;
   '8': dec(y,10);
   '4': dec(x,10);
   '6': inc(x,10);
   '2': inc(y,10);
    #0: case readkey of
         cUp: dec(y);
         cDown: inc(y);
         cLeft: dec(x);
         cRight: inc(x);
        end;
  end;
 until false;
end;

procedure loadtemp(which:string);
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
begin

 assign(f,'corr'+which+'tmp.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);

 bit:=getpixel(0,0);

 finder;
end;

procedure open_chunk;
begin
 assign(f,'chunk29.avd');
 rewrite(f,1);
 blockwrite(f,chunkheader,sizeof(chunkheader));
 blockwrite(f,num_chunks,1);
 blockwrite(f,offsets,num_chunks*4);

 this_chunk:=0;
end;

procedure close_chunk;
begin
 seek(f,45);
 blockwrite(f,offsets,num_chunks*4); { make sure they're right! }
 close(f);
end;

procedure mgrab(x1,y1,x2,y2:integer; size:word);
var yy:integer; aapos:word; length,bit:byte;
begin
 if size>arraysize then
 begin
  restorecrtmode;
  writeln('*** SORRY! *** Increase the arraysize constant to be greater');
  writeln(' than ',size,'.');
  halt;
 end;

 aapos:=0;

 length:=x2-x1;

 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for yy:=y1 to y2 do
  begin
   move(mem[$A400:yy*80+x1],aa[aapos],length);
   inc(aapos,length);
  end;
 end;
 bit:=getpixel(0,0);

end;

procedure grab(x1,y1,x2,y2,realx,realy:integer; flav:flavourtype;
 mem,nat:boolean; k:kind);
 { yes, I *do* know how to spell "really"! }
var
 s:word;
 p:pointer;
 ch:chunkblocktype;
begin
(* rectangle(x1,y1,x2,y2); exit;*)
 inc(this_chunk);
 offsets[this_chunk]:=filepos(f);


 s:=imagesize(x1,y1,x2,y2);
 getmem(p,s);
 getimage(x1,y1,x2,y2,p^);

 with ch do
 begin
  flavour:=flav;
  x:=realx; y:=realy;

  xl:=x2-x1;
  yl:=y2-y1;
  size:=s;
  memorise:=mem;
  natural:=nat;
 end;

 load(k);

 setvisualpage(1);
 setactivepage(1);
 rdln;
 putimage(ch.x,ch.y,p^,0);

 if flav=ch_EGA then
 begin
  freemem(p,s);
  s:=4*(((x2 div 8)-(x1 div 8))+2)*(y2-y1+1);
  with ch do
  begin
   size:=s;
   x:=x div 8;
   xl:=((realx-ch.x*8)+(x2-x1)+7) div 8;
   mgrab(x,y,x+xl,y+yl,s);
  end;
 end else
  with ch do { For BGI pictures. }
  begin
   x:=x div 8;
   xl:=(xl+7) div 8;
   size:=imagesize(x*8,y,(x+xl)*8,y+yl);
  end;

 rdln;
 setvisualpage(0);
 setactivepage(0);

 blockwrite(f,ch,sizeof(ch));

 case flav of
  ch_EGA : if not nat then blockwrite(f,aa,s);
  ch_BGI : begin
            if not nat then blockwrite(f,p^,s);
            freemem(p,s);
           end;
 end;
(* rectangle(x1,y1,x2,y2);*)
end;

begin
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 setwritemode(xorput);

 loadtemp('2');

 num_chunks:=32;

 open_chunk;

 grab(  0, 11,100,104,260,41,ch_EGA,false,false,uw); {1 Geida's door. }
 grab(103, 12,203, 55,207,61,ch_EGA,false,false,uw); {2 "Ite mingite" sign. }
 grab(123, 59,185,103,254,90,ch_EGA,false,false,uw); {3 Normal N door (rt handle)}
 grab(227, 10,289, 56,254,88,ch_EGA,false,false,uw); {4 Normal N door (lt handle)}
 grab(207, 63,294,105,  9,47,ch_EGA,false,false, w); {5 Window in left wall. }
 grab(312, 10,416, 56,233,88,ch_EGA,false,false,uw); {6 North archway }
 grab(331, 78,384,101, 32,64,ch_EGA,false,false, w); {7 2 torches, L wall. }
 grab(607,142,621,157,233,88,ch_EGA,false,false,uw); {8 1 torch, N wall. }
 grab(417, 11,577, 59,311,61,ch_EGA,false,false,uw); {9 "The Wrong Way!" sign. }

 loadtemp('3');

 grab(  0, 11, 62, 63,557,108,ch_EGA,false,false, w); {10 Near right candle }
 grab( 64, 11,120, 63, 18,108,ch_EGA,false,false, w); {11 Near left candle }
 grab(122, 11,169, 55, 93,100,ch_EGA,false,false, w); {12 Far left candle }
 grab(171, 11,222, 52,500,100,ch_EGA,false,false, w); {13 Far right candle }
 grab( 32, 68, 84,104,285, 70,ch_EGA,false,false,uw); {14 Far window }
 grab(138, 65,190, 92,233, 88,ch_EGA,false,false,uw); {15 Baron du Lustie pic 1 }
 grab(244, 65,296, 92,103, 51,ch_EGA,false,false,uw); {16 Baron du Lustie pic 2 }
 grab(172, 54,280, 63,233, 88,ch_EGA,false,false,uw); {17 "Art Gallery" sign }
 grab(341, 18,402, 47,563, 48,ch_EGA,false,false, w); {18 Right wall torches }
 grab(528, 10,639,160,528, 10,ch_EGA,false,false,uw); {19 Right wall }
 grab(430, 50,526, 88,543, 50,ch_EGA,false,false, w); {20 Window in right wall }
 grab(451, 91,494,152,566, 91,ch_EGA,false,false, w); {21 Door in right wall }
 grab(238, 10,307, 14,484,156,ch_EGA,false,false, w); {22 Near wall door: right }
 grab(239, 16,300, 20,300,156,ch_EGA,false,false, w); {23 Near wall door: middle }
 grab(234, 22,306, 26,100,156,ch_EGA,false,false, w); {24 Near wall door: left }
 grab( 25,113, 87,156,254, 90,ch_EGA,false,false, w); {25 Far door opening stage 1 }
 grab(131,113,193,156,254, 90,ch_EGA,false,false, w); {26 Far door opening stage 2 }
 grab(237,113,299,156,254, 90,ch_EGA,false,false, w); {27 Far door opening stage 3 }

 loadtemp('4');

 grab(  0, 11,112,160,  0, 11,ch_EGA,false,false,uw); {28 Left wall }
 grab(144, 44,197, 76, 30, 44,ch_EGA,false,false, w); {29 Shield on L wall. }
 grab(149, 90,192,152, 35, 90,ch_EGA,false,false, w); {30 Door in L wall. }
 grab(463, 28,527, 43,252,100,ch_EGA,false,false, w); {31 Archway x 2 }
 grab(463, 79,527, 94,252,100,ch_EGA,false,false, w); {32 Archway x 3 }

 close_chunk;
end.