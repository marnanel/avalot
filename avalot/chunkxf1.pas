program xf_chunk_1;
uses Graph,Cadburys;

(*type
 flavourtype = (ch_EGA,ch_BGI);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                   natural:boolean;

                   memorise:boolean; { Hold it in memory? }
                  end;*)

const
 chunkheader : array[1..44] of char =
 'Chunk-type AVD file, for an Avvy game.'+#26+#177+#$30+#$01+#$75+#177;

(* arraysize = 12000;*)

var
(* offsets:array[1..30] of longint;*)
 num_chunks(*,this_chunk*):byte;
 gd,gm:integer;
(* f:file;*)
(* aa:array[0..arraysize] of byte;*)

procedure load;
var
 a0:byte absolute $A000:800;
 a1:byte absolute $A400:800;
 bit:byte;
 f:file;
begin;
 assign(f,'chunkbit.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080);
 end;
 close(f);

 assign(f,'place21.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a1,12080);
 end;

 close(f);
 bit:=getpixel(0,0);
end;

procedure open_chunk;
begin;
 assign(f,'chunk21.avd');
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
{
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
   move(aa[aapos],mem[$A400:yy*80],length);
(*   fillchar(mem[$A400:yy*80+x1],length,#177);*)
   inc(aapos,length);
  end;
 end;
 bit:=getpixel(0,0);

end;
}
(*procedure grab(x1,y1,x2,y2,realx,realy:integer; flav:flavourtype;
 mem,nat:boolean);
 { yes, I *do* know how to spell "really"! }
var
 s:word;
 p:pointer;
 ch:chunkblocktype;
begin;
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
  s:=4*((x2-x1+7) div 8)*(y2-y1+1);
  with ch do
  begin;
   size:=s;
   x:=x div 8;
   xl:=(xl+7) div 8;
   mgrab(x,y,x+xl,y+yl,s);
  end;
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
{ rectangle(x1,y1,x2,y2);}
end;*)

(*procedure grab(x1,y1,x2,y2,realx,realy:integer; flav:flavourtype;
 mem,nat:boolean);*)
 { yes, I *do* know how to spell "really"! }
{var
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
  with ch do { For BGI pictures. }{
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
end;}

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
 setwritemode(xorput);

 num_chunks:=7;

 open_chunk;

 grab( 98,10,181,41,247,82,ch_EGA,false,false); { Drawbridge... }
 grab(223,10,320,41,233,82,ch_EGA,false,false);
 grab(361,10,458,64,233,82,ch_EGA,false,false);

 grab( 11,10, 39,22,172,17,ch_BGI,true,true);
 grab( 11,38, 39,50,172,17,ch_EGA,true,false); { Flag. }
 grab( 11,24, 39,36,172,17,ch_EGA,true,false);
 grab( 11,10, 39,22,172,17,ch_EGA,true,false);
 close_chunk;
end.