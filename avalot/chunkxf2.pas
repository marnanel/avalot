program xf_chunk_2;
uses Graph;

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

 arraysize = 32000;

var
 offsets:array[1..30] of longint;
 num_chunks,this_chunk:byte;
 gd,gm:integer;
 f:file;
 aa:array[0..arraysize] of byte;

procedure load;
var
 a0:byte absolute $A000:800;
 a1:byte absolute $A400:800;
 bit:byte;
 f:file;
begin;

 assign(f,'place9.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a1,12080);
 end;

 close(f);
 bit:=getpixel(0,0);
end;

procedure load_temp(which:string);
var
 a0:byte absolute $A000:800;
 a1:byte absolute $A400:800;
 bit:byte;
 f:file;
begin;
 assign(f,which); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure open_chunk;
begin;
 assign(f,'chunk9.avd');
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

procedure grab(x1,y1,x2,y2:integer; realx, realy:integer; mem,nat:boolean);
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
  if nat then
   flavour:=ch_BGI
  else flavour:=ch_EGA; { At the moment, Celer can't handle natural ch_EGAs. }
  x:=realx;
  y:=realy;

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

 freemem(p,s);
 with ch do
 begin;
  if flavour=ch_BGI then s:=imagesize(x*8,y,(x+xl)*8,y+yl)
   else s:=4*((x2-x1+7) div 8)*(y2-y1+1);
  size:=s;
  x:=x div 8;
  xl:=(xl+7) div 8;
  mgrab(x,y,x+xl,y+yl,s);
 end;

 readln;
 setvisualpage(0);
 setactivepage(0);

 blockwrite(f,ch,sizeof(ch));

 if not nat then blockwrite(f,aa,s);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
 load_temp('d:chunkbit.avd');
 setwritemode(xorput);

 num_chunks:=7;

 open_chunk;

 grab( 78, 78,232,102,212, 10,true,false); { 154 across }
 grab(235, 78,389,102,212, 10,true,false);
 grab(392, 78,546,102,212, 10,true,false);
 grab(392, 78,546,102,212, 10,true,true);

 load_temp('d:chunkbi3.avd');

 grab(437, 51,475, 78,147,120,false,false); { 5 = door half-open. }
 grab(397, 51,435, 78,147,120,false,false); { 6 = door open. }
 grab(397, 51,435, 78,147,120,true,true);   { 7 = door shut. }

 close_chunk;
end.