program xf_chunk_L;
uses Graph,Tommys,Crt,Cadburys;

procedure finder;
var r:char; x,y:integer;
begin
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
begin

 assign(f,'place51.avd'); reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a1,12080);
 end;

 close(f);
 bit:=getpixel(0,0);
 setvisualpage(1); setactivepage(1);
 finder;
 setvisualpage(0); setactivepage(0);
end;

procedure loadtemp;
var
 a0:byte absolute $A000:800;
 bit:byte;
 f:file;
begin

 assign(f,'chunkbi4.avd'); reset(f,1);
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
 assign(f,'chunk51.avd');
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

begin
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
 loadtemp;
 setwritemode(xorput);

 num_chunks:=9;

 open_chunk;

 grab(346,119,404,154,539,116,ch_EGA,true ,false); {1 fire }
 grab(435,119,490,154,541,116,ch_EGA,true ,false); {2 fire }
 grab(435,119,490,154,541,116,ch_BGI,true ,true ); {3 natural fire }

 grab(300, 58,315, 68,258, 95,ch_EGA,true ,false); {6 Duck's head 2 }
 grab(246, 52,259, 62,258, 95,ch_EGA,true ,false); {5 Duck blinks 1 }

 grab(300, 58,315, 68,258, 95,ch_BGI,true ,true ); {4 Duck's head 1 }
 grab(262, 52,278, 62,257, 95,ch_EGA,true ,false); {7 Duck blinks 2 }

 grab(333, 58,347, 68,258, 95,ch_EGA,true ,false); {8 Duck's head 3 }
 grab(250, 63,265, 73,258, 95,ch_EGA,true ,false); {9 Duck blinks 3 }

 close_chunk;
end.