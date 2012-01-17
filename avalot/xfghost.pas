program transfer_ghost;
uses Graph,Crt;

const
 chunkheader : array[1..44] of char =
 'Spooky file! Nearly a Chunk... (c) MT.'+#26+#177+#$30+#$01+#$75+#177;

 n = -1; { "No change" in new-whatever }

 aa = -2; { This is an aargh. }

 aargh_x_ofs = -177; aargh_y_ofs = 52;

type
 flavourtype = (ch_EGA,ch_BGI,ch_Natural,ch_Two,ch_One);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                  end;

var
 gd,gm,x,y:integer;
 f:file; bit:byte;
 a:byte absolute $A000:0;
 cc:palettetype;
 r:char; t:text;
 s:word; p:pointer;

 chunkfile:file;
 cb:chunkblocktype;

 A_p:pointer; A_s:word;

procedure open_chunk;
begin;
 assign(chunkfile,'v:spooky.avd');
 rewrite(chunkfile,1);
 blockwrite(chunkfile,chunkheader,sizeof(chunkheader));
end;

procedure close_chunk;
begin;
 close(chunkfile);
end;

procedure grab(x1,y1,x2,y2:integer; how:flavourtype; newx,newy:integer);
var
 p:pointer;
 s:word;
 y:integer;
 bit:byte;

begin;
{$IFNDEF DRYRUN}
 with cb do
 begin;
  flavour:=how;
  case newx of
   n: x:=x1;
   aa: x:=x1+aargh_x_ofs;
   else x:=newx;
  end;

  case newy of
   n: y:=y1;
   aa: y:=y1+aargh_y_ofs;
   else y:=newy;
  end;

  xl:=x2-x1;
  if how in [ch_EGA,ch_One,ch_Two] then xl:=((xl+7) div 8)*8;
  yl:=y2-y1;
 end;

 if how<>ch_Natural then
 begin;
  s:=imagesize(x1,y1,x2,y2);
  getmem(p,s);
  getimage(x1,y1,x2,y2,p^);
 end;

 rectangle(x1,y1,x2,y2);

 with cb do
  case how of
   ch_BGI: size:=s;
  end;

 blockwrite(chunkfile,cb,sizeof(cb));

 case how of
  ch_BGI: blockwrite(chunkfile,p^,s);
  ch_EGA: begin;
           setactivepage(1);
           cleardevice;
           putimage(0,0,p^,0);
           setactivepage(0);

           for bit:=0 to 3 do
            for y:=0 to cb.yl do
            begin;
             port[$3c4]:=2; port[$3ce]:=4;
             port[$3C5]:=1 shl bit; port[$3CF]:=bit;
             blockwrite(chunkfile,mem[$A400:y*80],cb.xl div 8);
           end;

           y:=getpixel(0,0);
          end;
  ch_Two: begin; { Same as EGA, but with only 2 planes. }
           setactivepage(1);
           cleardevice;
           putimage(0,0,p^,0);
           setactivepage(0);

           for bit:=2 to 3 do { << Bit to grab? }
            for y:=0 to cb.yl do
            begin;
             port[$3c4]:=2; port[$3ce]:=4;
             port[$3C5]:=1 shl bit; port[$3CF]:=bit;
             blockwrite(chunkfile,mem[$A400:y*80],cb.xl div 8);
           end;

           y:=getpixel(0,0);
          end;
  ch_One: begin; { ...but with only one plane! }
           setactivepage(1);
           cleardevice;
           putimage(0,0,p^,0);
           setactivepage(0);

           for bit:=3 to 3 do
            for y:=0 to cb.yl do
            begin;
             port[$3c4]:=2; port[$3ce]:=4;
             port[$3C5]:=1 shl bit; port[$3CF]:=bit;
             blockwrite(chunkfile,mem[$A400:y*80],cb.xl div 8);
           end;

           y:=getpixel(0,0);
          end;
 end;

 freemem(p,s); {$ENDIF}
 rectangle(x1,y1,x2,y2);

end;

begin;
{$IFNDEF DRYRUN}
 open_chunk;
{$ENDIF}

 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 assign(f,'c:\sleep4\colour.ptx'); reset(f,1);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,16000); { 28000 }
 end;
 close(f);

 setwritemode(xorput);

 { Grab the big ghost. }

 grab(  0,  0,160, 65,ch_Two,n,n); { First column, }
 grab(  0, 67,172,127,ch_Two,n,n);
 grab(  0,132,158,190,ch_Two,n,n);

 A_s:=imagesize(349,36,361,43); getmem(A_p,A_s);
 getimage(349,36,361,43,A_p^);
 setfillstyle(1,0); bar(349,36,361,43);

 grab(173, 66,347,124,ch_Two,n,n); { Second column. }
 grab(173,  6,352, 64,ch_Two,n,n);

 putimage(349,36,A_p^,0);

 { Grab Avvy's eyes and the exclamation mark. }

 grab(605, 10,620, 12,ch_BGI,n,n); { Eyes looking left }
 grab(622, 10,638, 12,ch_BGI,n,n); { Ditto looking right (eye eye, sir) }
 grab(611,  0,616,  5,ch_BGI,n,n); { ! }

 { Grab the cobweb. }

 grab(535, 25,639, 75,ch_One,n,0);
  { ^^^ Interesting point here: the ch_EGA save routine pads with black
    space to the RIGHT of the object. Since this cobweb needs to be right-
    justified, we must decrease x1 until xl is a multiple of 8. }

 { Grab Mark's signature. }

 grab(462, 61,525, 65,ch_EGA,576,195);

 { Grab the open door. }

 grab(180,132,294,180,ch_EGA,520,127);

 { Grab the bat. }

 grab(354,  0,474, 28,ch_BGI,n,n);
 grab(484,  0,526, 23,ch_BGI,n,n);
 grab(542,  2,564, 22,ch_BGI,n,n);

 { Grab the big fade-in face. }

 grab(350, 71,420,105,ch_EGA,n,n); { Top line. }
 grab(421, 71,491,105,ch_EGA,n,n);

 grab(350,107,419,141,ch_EGA,n,n); { Second line. }
 grab(421,107,490,141,ch_EGA,n,n);

 grab(350,143,420,177,ch_EGA,n,n); { Third line. }
 grab(422,143,489,177,ch_EGA,n,n);

 { Grab the "AARGH!" }

 grab(349, 36,361, 43,ch_BGI,aa,aa); { A }
 grab(366, 31,385, 46,ch_BGI,aa,aa); { Aa }
 grab(394, 34,415, 52,ch_BGI,aa,aa); { Aar }
 grab(428, 33,457, 57,ch_BGI,aa,aa); { Aarg }
 grab(471, 30,508, 59,ch_BGI,aa,aa); { Aargh }
 grab(524, 30,524, 58,ch_BGI,aa,aa); { Aargh! }

 for gd:=0 to 4 do
  grab(509, 76+gd*22,551, 96+gd*22,ch_BGI,n,n); { The big green eyes. }

 for gd:=5 downto 0 do
  grab(181+gd*34,186,214+gd*34,199,ch_BGI,n,n); { The red greldet. }

 for gd:=0 to 5 do
  grab(390+gd*34,186,423+gd*34,199,ch_BGI,n,n); { The blue greldet. }

{$IFNDEF DRYRUN}
 close_chunk;
{$ENDIF}
end.