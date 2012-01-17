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

procedure load;
var
 f:file; gd,gm,sort,n:byte; p,q:pointer;
 xf:pointer;
begin;
 assign(f,'v:osprte'+sn+'.avd'); reset(f,1); seek(f,59);
 blockread(f,oa,sizeof(oa)); blockread(f,bigsize,2);
 copyaoa;

 getmem(xf,a.size);

 for sort:=0 to 1 do
 begin;
  mark(q); getmem(p,bigsize);
  blockread(f,p^,bigsize);
  putimage(0,0,p^,0); release(q); n:=1;

  if sort=0 then setfillstyle(1,15) else setfillstyle(1,0);
  bar(177,125,300,200);

  with a do
   for gm:=0 to (num div seq)-1 do { directions }
    for gd:=0 to seq-1 do { steps }
    begin;
     getmem(pic[n,sort],a.size); { grab the memory }
     getimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       (gm div 2)*(xl*6)+gd*xl+xl-1,(gm mod 2)*yl+yl-1,
       xf^);
     putimage(177,125,xf^,0);
     getimage(177,125,177+xl,125+yl,pic[n,sort]^); { grab the pic }
     inc(n);
   end;
 end;
 close(f);
 freemem(xf,a.size);
 cleardevice;
 with a do
  for gm:=0 to 1 do
   for gd:=1 to num do
    putimage(gd*15,gm*40,pic[gd,gm]^,0);
end;

procedure setup;
var gd,gm:integer;
begin;
 writeln('TRIP5XF (c) 1992, Thomas Thurman.'); writeln;
 write('Enter number of SPRITE*.AVD file to convert:'); readln(sn);
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
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
  size:=imagesize(0,0,xl,yl);
  soa:=sizeof(a);

  assign(out,'v:sprite'+sn+'.avd'); rewrite(out,1);
  blockwrite(out,trip5head,177);
  blockwrite(out,tripid,4);
  blockwrite(out,soa,2);
  blockwrite(out,a,soa);

  nxl:=xl; nyl:=yl;
  xw:=nxl div 8;
  if (nxl mod 8)>0 then inc(xw);

  for n:=1 to num do
  begin;
   putimage(  0,0,pic[n,0]^,0);
   getimage(  0,0,xl,yl,aa);
   for fv:=0 to nyl do
    blockwrite(out,aa[5+fv*xw*4],xw);

   putimage(100,0,pic[n,1]^,0);
   getimage(100,0,100+xl,yl,aa);
   putimage(100,100,aa,4);
(*   for ff:=1 to 4 do        { actually 2 to 5, but it doesn't matter here }
    for fv:=0 to nyl do*)
(*   for ff:=5 to size-2 do
    blockwrite(out,aa[ff],1);*)
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