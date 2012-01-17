program intro;
uses Dos,Graph,Crt;
 { This is a stand-alone program. }

const

 { 0, black, remains 0.
   Other numbers: the bits take precedence from the left.
    e.g. for 9 = 1001, => fourth bit.

    First 1 is in:

     Fourth bit: 63 (egaWhite)
      Third bit: 57 (egaLightBlue)
     Second bit: 7  (light grey)
      First bit: 1  (blue). }

 our_palette : palettetype =
                 (size:16;
                  colors: { sic }
 (  0,  1, 57, 57,  7,  7,  7,  7, 63, 63, 63, 63, 63, 63, 63, 63));

type
 fonttype = array[#0..#255,1..16] of byte;

var
 f : fonttype;
 next_line:array[0..39,1..16] of byte;

 next_bitline:byte;

 displaycounter:byte;

 cut_out:boolean;

 cut_out_time:word;

 x:array[1..117] of string[40];

 this_line:byte;

 skellern:^word;

{$L intro.obj}
procedure introduction; external;

procedure graphmode(mode:integer);
var regs:registers;
begin
 regs.ax:=mode;
 intr($10,regs);
end;

{ Firstly, port[$3C4]:=2; port[$3CF]:=4;,
  Then port[$3C5]:=1 shl bit; port[$3CF]:=bit;. }

procedure loadfont;
var ff:file of fonttype;
begin
 assign(ff,'avalot.fnt');
 reset(ff);
 read(ff,f);
 close(ff);
end;

procedure calc_next_line;
 { This proc sets up next_line. }
var
 L:string;
 fv,ff:byte;
 oddlen:boolean;
 start:byte;
 this:byte;
begin
 fillchar(next_line,sizeof(next_line),#0); { All blanks. }

 if this_line=117 then
 begin
  cut_out:=true;
  exit;
 end;

 L:=x[this_line];
 inc(this_line);

 start:=(20-length(L) div 2)-1;
 oddlen:=odd(length(L));

 for fv:=1 to length(L) do
  for ff:=1 to 16 do
  begin
   this:=f[L[fv],ff];
   if oddlen then
   begin { Odd, => 4 bits shift to the right. }
    inc(next_line[start+fv,ff],this shl 4);
    inc(next_line[start+fv-1,ff],this shr 4);
   end else
   begin { Even, => no bit shift. }
    next_line[start+fv,ff]:=this;
   end;
  end;
 next_bitline:=1;
end;

procedure display;
var fv,ff:byte;
begin

 if next_bitline = 17 then calc_next_line;

 if cut_out then
 begin
  dec(cut_out_time);
  exit;
 end;

 move(mem[$A000:40],mem[$A000:0],7960);
 for fv:=0 to 39 do
   mem[$A1F1:8+fv]:=next_line[fv,next_bitline];
 inc(next_bitline);

end;

procedure plot_a_star(x,y:integer);
var ofs:byte;
begin
 ofs:=x mod 8;
 x:=x div 8;
 inc(mem[$A000:x+y*40],128 shr ofs);
end;

procedure plot_some_stars(y:integer);
var fv,times:byte;
begin
 case random(7) of
  1: times:=1;
  2: times:=2;
  3: times:=3;
  else exit;
 end;

 for fv:=1 to times do
  plot_a_star(random(320),y);
end;

procedure starry_starry_night;
var
 y:integer;
 bit:byte;
begin
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;

 for bit:=0 to 2 do
 begin
  port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for y:=1 to 200 do
   plot_some_stars(y);
 end;
end;

procedure setupgraphics; { Fix this proc. This prog SHOULDN'T use the
 Graph unit. }
var gd,gm:integer;
begin
 gd:=3; gm:=1; initgraph(gd,gm,'');
end;

procedure shovestars;
begin
 move(mem[$A000:0],mem[$A000:40],7960);
 fillchar(mem[$A000:0],40,#0);
 plot_some_stars(0);
end;

procedure do_next_line;
var bit:byte;
begin
 port[$3c4]:=2; port[$3ce]:=4;

 for bit:=0 to 3 do
 begin
  port[$3C5]:=1 shl bit; port[$3CF]:=bit;

  case bit of
   0: if (displaycounter mod 10)=0 then shovestars;
   1: if (displaycounter mod 2)=0 then shovestars;
   2: shovestars;
   3: display; { The text. }
  end;
 end;

 if displaycounter=40 then displaycounter:=0;

end;

procedure load_text;
var
 fv:word;
 c:^char;
 thisline:byte;
begin

 c:=addr(introduction);
 thisline:=0;
 fillchar(x,sizeof(x),#0);

 for fv:=1 to 2456 do
 begin
  case c^ of
   #13: inc(thisline);
   #10: {nop};
   else x[thisline]:=x[thisline]+c^;
  end;

  inc(c);
 end;
end;

procedure check_params;
var s,o:word; e:integer;
begin
 if paramstr(1)<>'jsb' then halt;
 val(paramstr(2),s,e); if e<>0 then halt;
 val(paramstr(3),o,e); if e<>0 then halt;
 skellern:=ptr(s,o+1);
end;

begin

 check_params;

 setupgraphics;

 randseed:=177; checkbreak:=false;

 load_text;

 this_line:=1;

 graphmode($D);
 loadfont;

 next_bitline:=17;
 displaycounter:=0;

 cut_out_time:=333;

 setallpalette(our_palette);

 starry_starry_night;

 while (cut_out_time>0) and (not keypressed) do
 begin

  skellern^:=0;

  do_next_line;

  inc(displaycounter);

  repeat until skellern^>0;
 end;

 graphmode(3);
end.