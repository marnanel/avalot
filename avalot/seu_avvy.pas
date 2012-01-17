program test;
uses Graph,Crt;

type
 adxtype = record
            name:string[12]; { name of character }
            comment:string[16]; { comment }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
            accinum:byte; { the number according to Acci (1=Avvy, etc.) }
           end;

var
 gd,gm:integer;
 sf:file;
 id:longint;
 soa:word;
 a:adxtype;
 xw:byte;
 mani:array[5..2053] of byte;
 sil:array[0..35,0..4] of byte;
 aa:array[1..16000] of byte;
 outfile:file;

procedure plotat(xx,yy:integer); { Does NOT cameo the picture!}
var soaa:word;
begin;
 move(mani,aa[5],sizeof(mani));
 with a do
 begin;
  aa[1]:=xl; aa[2]:=0; aa[3]:=yl; aa[4]:=0; { set up x&y codes }
 end;
 putimage(xx,yy,aa,0);
 soaa:=sizeof(mani);
 blockwrite(outfile,soaa,2);
 blockwrite(outfile,aa,sizeof(mani));
end;

const shouldid = -1317732048;

procedure explode(which:byte); { 0 is the first one! }
 { Each character takes five-quarters of (a.size-6) on disk. }
var
 fv,ff:byte; so1:word; { size of one }
begin;
 with a do
 begin;
  so1:=size-6; inc(so1,so1 div 4);
  seek(sf,183+soa+so1*which); { First is at 221 }
(*  where:=filepos(sf);*)
  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);

  for fv:=0 to yl do
   blockread(sf,sil[fv],xw);
  blockread(sf,mani,size-6);
  aa[size-1]:=0; aa[size]:=0; { footer }
 end;
 plotat(100,100);
 delay(100);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 assign(outfile,'notts.avd');
 reset(outfile,1);
 seek(outfile,filesize(outfile));

 assign(sf,'sprite0.avd');
 reset(sf,1);

 seek(sf,177);
 blockread(sf,id,4);
 blockread(sf,soa,2);
 blockread(sf,a,soa);

 explode(1);
 for gd:=6 to 11 do explode(gd);
 for gd:=18 to 23 do explode(gd);

 close(sf);
 close(outfile);
end.