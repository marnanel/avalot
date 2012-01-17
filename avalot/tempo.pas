program tempo;
uses Graph;

type
 flavourtype = (ch_EGA,ch_BGI,ch_Natural,ch_Two,ch_One);

 chunkblocktype = record
                   case boolean of
                    true: (flavour:flavourtype;
                           x,y:integer;
                           xl,yl:integer;
                           size:longint);
                    false: (all: array[1..14] of byte);
                  end;


var
 screennum:byte;
 f:file;

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure load;
var a:byte absolute $A000:1200; bit:byte;
begin;
 reset(f,1);
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12080);
 end;
 close(f);
 bit:=getpixel(0,0);
end;

procedure init;
var gd,gm:integer;
begin;
 writeln('*** Tempo file creater ***');
 write('Enter place*.avd number:');
 readln(screennum);
 gd:=3; gm:=0;
 initgraph(gd,gm,'c:\bp\bgi');
 assign(f,'place'+strf(screennum)+'.avd');
 load;
 setactivepage(1);
 setcolor(10);
 outtextxy(0,150,'CHUNK FILE: please don''t change these codes! ->');
 setactivepage(0);
end;

procedure choose;
var x1,y1,xl,yl:integer;
begin;

end;

begin;
 init;
 choose;
end.