program trip5xf;
uses Graph,Crt;

const
 crlf = #13+#10; eof = #26;
 trip5head : array[1..177] of char =
          'Sprite*.AVD  ...  data file for Trippancy Five'+crlf+crlf+
          '[Thorsoft relocatable fiveplane sprite image format]'+crlf+crlf+
          'Thomas Thurman was here.  ...  Have fun!'+crlf+crlf+eof+
          '±±±±±±± * G. I. E. D. ! * ';

 tripid : array[1..4] of char = #$30+#$01+#$75+#177;

 trip5foot : array[1..50] of char = crlf+crlf+
          ' and that''s it! Enjoy the game. '+#3+crlf+crlf+
             ^I^I^I^I^I^I^I+'tt';

type
 adxotype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

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
 sn:string[2];
 oa:adxotype;
 a:adxtype;
 pic:array[1..24,0..1] of pointer; { the pictures themselves }
 aa:array[1..16000] of byte;
 out:file;
 bigsize:integer;

procedure copyaoa;
begin;
 with a do
 begin;
  name:=oa.name;
  comment:='Transferred';
  num:=oa.num;
  xl:=oa.xl;
  yl:=oa.yl;
  seq:=oa.seq;
  size:=oa.size;
  fgc:=oa.fgc;
  bgc:=oa.bgc;
 end;
end;

procedure setup;
var gd,gm:integer;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
end;

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure save;
var
 sort,n:byte;
 fv,ff:word; r:char; xw:byte;
 nxl,nyl:byte;
 soa:word;
begin;
 cleardevice;
 with a do
 begin;
  xl:=45; yl:=10; num:=1; seq:=1;
  size:=imagesize(0,0,xl,yl);
  soa:=sizeof(a);

  assign(out,'v:sprite10.avd'); rewrite(out,1);
  blockwrite(out,trip5head,177);
  blockwrite(out,tripid,4);
  blockwrite(out,soa,2);
  blockwrite(out,a,soa);

  nxl:=xl; nyl:=yl;
  xw:=nxl div 8;
  if (nxl mod 8)>0 then inc(xw);

  for n:=1 to num do
  begin;
   getimage(  0,0,xl,yl,aa);
   for fv:=0 to nyl do
    blockwrite(out,aa[5+fv*xw*4],xw);

   getimage(100,0,100+xl,yl,aa);
   blockwrite(out,aa[5],size-6);
  end;
 end;
end;

begin;
 setup;
 save;

 blockwrite(out,trip5foot,50);
 close(out);
end.