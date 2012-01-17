program thordir;
uses Crt,Graph,Dos,Rodent;
{$V-}

const
 more = ' (more) ';
 up = '-'+#24+more+#24;
 down = '+'+#25+more+#25;

 fletch : graphcursmasktype = { Mask 4 in Avalot }
     (mask:(
      (255,511,1023,2047,1023,4607,14591,31871,65031,65283,65281,65280,65280,65409,65473,65511),
      (0,10240,20480,24576,26624,17408,512,256,128,88,32,86,72,20,16,0));
   Horzhotspot: 0;
   Verthotspot: 0);

var
 cdir:string;
 info:array[0..2,1..18] of string[15];
 possible:array[0..2,1..100] of string[15];
 fv:byte;
 light,page:array[0..2] of byte;
 blank:array[0..2] of boolean;
 chtcode,where:byte;
 answer:string;

procedure split(x:string);
var fv:byte;
begin;
 x:=copy(x,4,255); if x='' then begin; blank[0]:=true; exit; end;
 x:=x+'\'; possible[0,1]:='b\'; fv:=2;
 while pos('\',x)<>0 do
 begin;
  possible[0,fv]:='b'+copy(x,1,pos('\',x)-1); inc(fv);
  x:=copy(x,pos('\',x)+1,255);
 end;
 possible[0,fv-1]:='';
end;

procedure block(x1,y1,x2,y2:integer; x:string);
begin;
 bar(x1,y1,x2,y2);
 setcolor( 9); outtextxy(x1+(x2-x1) div 2-1,y1+5,x);
 setcolor(15); outtextxy(x1+(x2-x1) div 2+1,y1+6,x);
end;

procedure message(x:string);
begin;
 block(5,189,640,200,x);
end;

procedure bigbar(x:byte);
begin;
 bar(15+210*x,36,210+210*x,187);
end;

procedure getem;

  procedure sub_getem(prefix:char; spec:string; attrib,infonum:byte);
  var s:searchrec; fv:byte;
  begin;
   fv:=0;
   findfirst(spec,attrib,s);
   while (doserror=0) and (fv<100) do
   begin;
    if ((s.attr and attrib)>0) and (s.name[1]<>'.') then
    begin; { circumvent inclusive searching! }
     inc(fv);
     possible[infonum,fv]:=prefix+s.name;
    end;
    findnext(s);
   end;
   if fv=0 then blank[infonum]:=true;
  end;

begin;
 message('Please wait... scanning directory...');
 sub_getem('a','*.asg',archive+hidden,1); { Scan for .ASG files }
 sub_getem('f','*.*',directory,2); { Scan for sub-directories }
end;

procedure minisc(var x:string); { Converts to lower-case }
var fv:byte;
begin;
 for fv:=1 to length(x) do
  if (x[fv]>='A') and (x[fv]<='Z') then inc(x[fv],32);
end;

procedure showall;
var fv,ff:byte;
begin;
 for fv:=0 to 2 do
 begin;
  bigbar(fv); { blank out anything else }
  if blank[fv] then
  begin; { nothing here at all }
(*   setcolor(14);
   outtextxy(113+210*fv,43,'(Nothing here!)'); *)
   setcolor(14); settextstyle(0,0,2);
   outtextxy(113+210*fv, 77,'Nothing');
   outtextxy(113+210*fv,100,'here!');
   settextstyle(0,0,1);
  end else
  begin; { something here- what? }
   setcolor(11);
   for ff:=0 to 15 do
   begin;
    info[fv,ff+2]:=possible[fv,page[fv]*15+ff+1]; minisc(info[fv,ff+2]);
   end;
   if page[fv]>0 then info[fv,1]:=up else info[fv,1]:='';
   if possible[fv,page[fv]*15+17]<>'' then
    info[fv,18]:=down else info[fv,18]:='';
   for ff:=1 to 18 do
   begin;
    outtextxy(113+210*fv,35+ff*8,copy(info[fv,ff],2,255));
   end;
  end;
 end;
 block(5,12,640,22,cdir);
end;

procedure changedir(x:string);
begin;

 chdir(x); getdir(0,cdir);
end;

procedure drawup;
var gd:integer;
begin;
 block( 15, 0,630,10,'Choose an .ASG file to load or save.');
 block( 15,24,210,34,'Looking back:');
 block(225,24,420,34,'Here:');
 block(435,24,630,34,'Looking forwards:');
 for gd:=0 to 2 do bigbar(gd); { just to tide us over the wait... }
 showall;
end;

procedure setup;
begin;
 settextjustify(1,1); setfillstyle(1,1);
 fillchar(blank,sizeof(blank),#0); fillchar( info,sizeof( info),#0);
 fillchar(possible,sizeof(possible),#0);
 fillchar( page,sizeof( page),#0);
 split(cdir); getem; drawup;
end;

procedure setup1;
var gd,gm:integer;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,''); answer:='';
 getdir(0,cdir); resetmouse; setgraphicscursor(fletch);
 fillchar(light,sizeof(light),#0);
 setup;
end;

procedure clickwait;
const
 msg : array[1..4] of string[30] =
  ('change to another drive.',
   'return to a lower directory.',
   'use the file named.',
   'enter a sub-directory.');
var oldcht:byte; { Click Here To... code }
begin;
 showmousecursor; oldcht:=177;
 repeat
  if mousey<38 then chtcode:=1 else
   case mousex of
    0..210: chtcode:=2;
    211..421: chtcode:=3;
    else chtcode:=4;
   end;
  if oldcht<>chtcode then
  begin;
   hidemousecursor; message('Click here to '+msg[chtcode]);
   showmousecursor; oldcht:=chtcode;
  end;
 until leftmousekeypressed;
 hidemousecursor; where:=((mousey-39) div 8)+1;
end;

procedure blip;
begin;
 sound(32); delay(3); nosound;
end;

procedure do_cht;
var r:char; fv:byte; x:string;
begin;
 if chtcode=1 then
 begin; { change drives }
  message('Enter the drive letter (e.g. A)...');
  r:=readkey;
  changedir(r+':'); setup;
 end else
 begin;
  x:=info[chtcode-2,where]; r:=x[1]; x:=copy(x,2,255);
  case r of
   'b': begin; { back some dirs }
         if x='\' then x:='';
         for fv:=where-1 downto 3 do
          x:=copy(info[0,fv],2,255)+'\'+x;
         changedir('\'+x);
         setup;
        end;
   'f': begin; { sub-directory }
         changedir(x);
         setup;
        end;
   '+': begin; { scroll one panel down }
         inc(page[chtcode-2]);
         drawup;
        end;
   '-': begin; { scroll one panel up }
         dec(page[chtcode-2]);
         drawup;
        end;
   'a': answer:=x;
  end;
 end;
end;

begin;
 setup1;
 repeat
  clickwait;
  do_cht;
 until answer<>'';
 if length(cdir)>3 then cdir:=cdir+'\';
 answer:=cdir+answer;
 closegraph;
 writeln('Routine completed.');
 writeln('Answer: ',answer);
 write('Hit Enter:'); readln;
end.

virgil
st translation virgil