program xf_chunk_8;
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

const
 chunkheader : array[1..44] of char =
 'Chunk-type AVD file, for an Avvy game.'+#26+#177+#$30+#$01+#$75+#177;

 arraysize = 12000;

var
 offsets:array[1..30] of longint;
 num_chunks,this_chunk:byte;
 gd,gm:integer;
 f:file;
 aa:array[0..arraysize] of byte;

procedure finder;
var r:char; x,y:integer;
begin;
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

procedure load;
var
 a1:byte absolute $A400:800;
 bit:byte;
 f:file;
begin;

 assign(f,'place23.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a1,12080);
 end;

 close(f);
 bit:=getpixel(0,0);
 setvisualpage(1); setactivepage(1);
 finder;
 setvisualpage(0); setactivepage(0);
end;

procedure loadtemp(x:string);
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
begin;

 assign(f,x); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);

 bit:=getpixel(0,0);

 finder;
end;

procedure open_chunk;
begin;
 assign(f,'chunk23.avd');
 rewrite(f,1);
 blockwrite(f,chunkheader,sizeof(chunkheader));
 blockwrite(f,num_chunks,1);
 blockwrite(f,offsets,num_chunks*4);

 this_chunk:=0;
end;

procedure close_chunk;
begin;
 seek(f,45);
 blockwrite(f,offsets,num_chunks*4); { make sure they're right! }
 close(f);
end;

procedure mgrab(x1,y1,x2,y2:integer; size:word);
var yy:integer; aapos:word; length,bit:byte;
begin;
 if size>arraysize then
 begin;
  restorecrtmode;
  writeln('*** SORRY! *** Increase the arraysize constant to be greater');
  writeln(' than ',size,'.');
  halt;
 end;

 aapos:=0;

 length:=x2-x1;

 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for yy:=y1 to y2 do
  begin;
   move(mem[$A400:yy*80+x1],aa[aapos],length);
   inc(aapos,length);
  end;
 end;
 bit:=getpixel(0,0);

end;

procedure grab(x1,y1,x2,y2,realx,realy:integer; flav:flavourtype;
 mem,nat:boolean);
 { yes, I *do* know how to spell "really"! }
var
 s:word;
 p:pointer;
 ch:chunkblocktype;
begin;
(* rectangle(x1,y1,x2,y2); exit;*)
 inc(this_chunk);
 offsets[this_chunk]:=filepos(f);


 s:=imagesize(x1,y1,x2,y2);
 getmem(p,s);
 getimage(x1,y1,x2,y2,p^);

 with ch do
 begin;
  flavour:=flav;
  x:=realx; y:=realy;

  xl:=x2-x1;
  yl:=y2-y1;
  size:=s;
  memorise:=mem;
  natural:=nat;
 end;

 setvisualpage(1);
 setactivepage(1);
 readln;
 putimage(ch.x,ch.y,p^,0);

 if flav=ch_EGA then
 begin;
  freemem(p,s);
  s:=4*(((x2 div 8)-(x1 div 8))+2)*(y2-y1+1);
  with ch do
  begin;
   size:=s;
   x:=x div 8;
   xl:=(xl div 8)+2;
   mgrab(x,y,x+xl,y+yl,s);
  end;
 end else
  with ch do { For BGI pictures. }
  begin;
   x:=x div 8;
   xl:=(xl+7) div 8;
   size:=imagesize(x*8,y,(x+xl)*8,y+yl);
  end;

 readln;
 setvisualpage(0);
 setactivepage(0);

 blockwrite(f,ch,sizeof(ch));

 case flav of
  ch_EGA : if not nat then blockwrite(f,aa,s);
  ch_BGI : begin;
            if not nat then blockwrite(f,p^,s);
            freemem(p,s);
           end;
 end;
(* rectangle(x1,y1,x2,y2);*)
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
 loadtemp('chunkbi3.avd');
 setwritemode(xorput);

 num_chunks:=6;

 open_chunk;

 grab(226, 21,242, 29,348, 96,ch_BGI, true,true ); {1 Looking forwards. }
 grab(226, 21,242, 29,348, 96,ch_EGA, true,false); {2 Looking left. }
 grab(253, 21,269, 29,348, 96,ch_EGA, true,false); {3 Looking right. }
 grab(240, 11,256, 19,348, 96,ch_EGA, true,false); {4 Blinking. }

 loadtemp('chunkbi4.avd');

 grab( 48, 83,110,126,324, 96,ch_EGA,false,false); {5 Eyes shut... }
 grab(112, 83,173,126,325, 96,ch_EGA,false,false); {6 Asleep. }

 close_chunk;
end.