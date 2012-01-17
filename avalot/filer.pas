program avvyfiler;
uses Graph,Dos,Crt,Tommys,Lucerna;
{$V-}

type
 windowtype = record
               x1,y1,x2,y2:integer;
               title:string[20];
              end;

  ednahead = record { Edna header }
            { This header starts at byte offset 177 in the .ASG file. }
            ID:array[1..9] of char; { signature }
            revision:word; { EDNA revision, here 2 (1=dna256) }
            game:string[50]; { Long name, eg Lord Avalot D'Argent }
            shortname:string[15]; { Short name, eg Avalot }
            number:word; { Game's code number, here 2 }
            ver:word; { Version number as integer (eg 1.00 = 100) }
            verstr:string[5]; { Vernum as string (eg 1.00 = "1.00" }
            filename:string[12]; { Filename, eg AVALOT.EXE }
            osbyte:byte; { Saving OS (here 1=DOS. See below for others.}
            os:string[5]; { Saving OS (here 1=DOS. See below for others.}

            { Info on this particular game }

            fn:string[8]; { Filename (not extension ('cos that's .ASG)) }
            d,m:byte; { D, M, Y are the Day, Month & Year this game was... }
            y:word;  { ...saved on. }
            desc:string[40]; { Description of game (same as in Avaricius!) }
            len:word; { Length of DNA (it's not going to be above 65535!) }

            { Quick reference & miscellaneous }

            saves:word; { no. of times this game has been saved }
            cash:integer; { contents of your wallet in numerical form }
            money:string[20]; { ditto in string form (eg 5/-, or 1 denarius)}
            points:word; { your score }

            { DNA values follow, then footer (which is ignored) }
           end;

const
 border = 1; { size of border on shadowboxes }

 buttons : array[1..4] of string[7] = ('Okay','Wipe','Cancel','Info...');

 files = 3;
 dirs = 4;

 drlen = 15; { no. of drives on one line }

 threewins : array[1..4] of windowtype =
  ((x1:155; y1: 12; x2:630; y2: 22; title:'Name'),
   (x1: 15; y1: 25; x2:410; y2: 70; title:'Drives'),
   (x1: 15; y1: 83; x2:480; y2:179; title:'Files (*.ASG)'),
   (x1:490; y1: 83; x2:630; y2:179; title:'Subdirectories'));

 name_win = 1;
 drive_win = 2;
 file_win = 3;
 subdir_win = 4;

var
 lists:array[3..4,1..77] of string[12];
 descs:array[1..77] of string[40];
 nums,where,top:array[3..4] of byte;
 s:searchrec;
 loading:boolean;
 drives:string[26];
 current:pathstr;
 nowwin:byte;
 doing:string[17];

 filename:pathstr;
 filefound:boolean;

procedure shadow(x1,y1,x2,y2:integer; hc,sc:byte);
var fv:byte;
begin;
 for fv:=0 to border do
 begin;
  setfillstyle(1,hc);
  bar(x1+fv,y1+fv,x1+fv,y2-fv);
  bar(x1+fv,y1+fv,x2-fv,y1+fv);

  setfillstyle(1,sc);
  bar(x2-fv,y1+fv,x2-fv,y2-fv);
  bar(x1+fv,y2-fv,x2-fv,y2-fv);
 end;
end;

procedure shbox(x1,y1,x2,y2:integer; t:string);
const fc = 7;
begin;
 shadow(x1,y1,x2,y2,15,8);
 setfillstyle(1,fc);
 bar(x1+border+1,y1+border+1,x2-border-1,y2-border-1);
 setcolor(1); x1:=(x2-x1) div 2+x1; y1:=(y2-y1) div 2+y1;
 outtextxy(x1,y1,t);
 if length(t)>1 then
 begin;
  fillchar(t[2],length(t)-1,#32); t[1]:='_';
  outtextxy(x1-1,y1+1,t);
 end;
end;

procedure show_drives;
var fv:byte;
begin;
 settextjustify(1,1);
 for fv:=0 to length(drives)-1 do
  shbox((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,drives[fv+1]);
 setcolor(11);
 settextjustify(0,2);
end;

procedure box(x1,y1,x2,y2:integer; z:string);
begin;
 rectangle(x1,y1,x2,y2);
 outtextxy(x1+1,y1-10,z+':');
 outtextxy(x1,y1-9,'_');
end;

function lowstr(x:string):string;
var fv:byte;
begin;
 for fv:=1 to length(x) do
  if x[fv] in ['A'..'Z'] then inc(x[fv],32);
 lowstr:=x;
end;

function lowchar(x:char):char;
begin
 if x in ['A'..'Z'] then dec(x,32);
 lowchar:=x;
end;

procedure getcurrent;
begin;
 current:=lowstr(fexpand('*.asg'));
end;

procedure setup;
var
 gd,gm:integer;
 r:registers;
 floppies:byte;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 dusk;
 setfillstyle(1,1); bar(2,2,637,197); shadow(0,0,639,199,15,7);

 if loading then doing:='LOAD' else doing:='SAV';
 doing:=doing+'ING a file...';

 { Now... find all drives that exist. }
 drives:='';
 intr($11,r); floppies:=((r.ax shr 6) and $3)+1; { useful bit of code! }
 for gm:=1 to floppies do drives:=drives+chr(64+gm);
 { Winchesters, etc., can be found the easy way... }
 for gd:=3 to 26 do { C: to Z: }
  if disksize(gd)>-1 then drives:=drives+chr(64+gd);

 fillchar(where,sizeof(where),#1);
 fillchar(top,sizeof(top),#1);

 settextstyle(0,0,0);
 settextjustify(1,1);
 for gd:=1 to 2 do
  for gm:=0 to 1 do
   shbox(420+gm*110,gd*25,520+gm*110,gd*25+20,buttons[gm*2+gd]);
 shbox(15,182,350,196,'Help... (press f1)');
 settextjustify(0,2); setcolor(11);
 setcolor(15); outtextxy(15,5,'The Avvy Filer...');
 setcolor(11); outtextxy(317,3,'('+doing+')');
 outtextxy(357,185,'Copyright (c) 1993, Thomas Thurman.');

 { Draw the boxes and names }
 setcolor(3);
 for gm:=1 to 4 do
  with threewins[gm] do
   box(x1,y1,x2,y2,title);
 nowwin:=1; getcurrent;
end;

procedure QuickSort(WhichList:byte; Lo, Hi: Integer);

procedure Sort(l, r: Integer);
var
  i, j: integer;
  x, y: string[12];
begin
  i := l; j := r; x := lists[WhichList,(l+r) DIV 2];
  repeat
    while lists[WhichList,i] < x do i := i + 1;
    while x < lists[WhichList,j] do j := j - 1;
    if i <= j then
    begin
      y := lists[WhichList,i];
      lists[WhichList,i] := lists[WhichList,j];
      lists[WhichList,j] := y;
      i := i + 1; j := j - 1;
    end;
  until i > j;
  if l < j then Sort(l, j);
  if i < r then Sort(i, r);
end;

begin {QuickSort};
  Sort(Lo,Hi);
end;

procedure scandir;
var
 nix:pathstr;
 name:namestr;
 f:file;
 eh:ednahead;
 dna_type:array[1..4] of char;

begin;
 nums[files]:=0;
 findfirst('*.asg',archive+hidden+readonly,s);

 while doserror=0 do
 begin;
  fsplit(s.name,nix,name,nix);
  inc(nums[files]);
  lists[files,nums[files]]:=lowstr(name);

  assign(f,s.name);
  reset(f,1);
  seek(f,11);
  blockread(f,dna_type,4);

  if dna_type='Avvy' then
  begin; { A DNA256 file. }
   descs[nums[files]]:='* Saved by Avaricius!';
  end else
  begin; { EDNA-based files. }
   if dna_type='EDNA' then
   begin;
    seek(f,177);
    blockread(f,eh,sizeof(eh));

    with eh do
     if revision<>2 then
      descs[nums[files]]:='* Unknown EDNA type!'
     else
     begin;

      if number<>2 then
       descs[nums[files]]:='* Saved by '+shortname+'!'
      else
      begin; { Well... everything seems to have gone OK! }
       descs[nums[files]]:=eh.desc;
      end;
     end;
   end else
    descs[nums[files]]:='* Not an Avvy saved game!';
  end;
  close(f);
  findnext(s);
 end;
 nums[dirs]:=0; findfirst('*.*',directory,s);
 while doserror=0 do
 begin;
  if ((s.attr and directory)>0) and ((length(s.name))>1) then
  begin;
   inc(nums[dirs]);
   lists[dirs,nums[dirs]]:=lowstr(s.name);
  end;
  findnext(s);
 end;

 { Now sort 'em! }

 QuickSort ( dirs,1,nums[ dirs]);
 QuickSort (files,1,nums[files]);

 where[dirs]:=1; where[files]:=1;
   top[dirs]:=1; top[files]:=1;
end;

procedure show_file(x,y:integer; which:byte);
var
 z:string[58];
begin;
 fillchar(z[1],13,#32);
 z:=lists[files,which]+'.asg';
 z[0]:=#13; z:=z+descs[which];

 if descs[which,1]='*' then { Can't load these! }
  setcolor(red)
 else
  setcolor(lightcyan);

 outtextxy(x,y,z);
end;

procedure showfiles;
var fv:byte;
begin;
 if loading then setcolor(11) else setcolor(3);
 if nums[3]=0 then
 begin;
  outtextxy(22,86,'(None here!)');
  exit;
 end;
 for fv:=0 to 8 do
  if where[3]+fv<=nums[3] then
   show_file(19,87+fv*10,where[3]+fv);
end;

procedure showdirs;
var fv:byte;
begin;
 setcolor(11);
 for fv:=0 to 8 do
  if where[4]+fv<=nums[4] then
   outtextxy(497,87+fv*10,'['+lists[dirs,fv+where[4]]+']');
end;

procedure show;
var
 fv:byte;
 D: DirStr; N: NameStr; E: ExtStr;
begin;
 setfillstyle(1,1);
 for fv:=1 to 4 do
  if fv<>2 then
   with threewins[fv] do
    bar(x1+1,y1+1,x2-1,y2-1);
 showfiles;
 showdirs;
 setcolor(7); outtextxy(159,14,current);
end;

procedure blip;
begin;
 sound(177); delay(77); nosound;
end;

procedure invert(x1,y1,x2,y2:integer);
var p,restore:pointer; s:word;
begin;
 s:=imagesize(x1,y1,x2,y2);
 mark(restore); getmem(p,s);
 getimage(x1,y1,x2,y2,p^);
 putimage(x1,y1,p^,notput);
 release(restore);
end;

procedure changedrive(drive:char);
var fv:byte;
begin;
 fv:=pos(drive,drives);
 if fv=0 then begin; blip; exit; end;
 dec(fv);
 shadow((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,8,7);
 chdir(drive+':');
 getcurrent; scandir; show;
 shadow((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,15,8);
end;

procedure highlight(win,line:byte);
begin;
 case win of
  3: invert(16,75+line*10,479,85+line*10);
  4: invert(491,75+line*10,619,85+line*10);
 end;
end;

procedure repaint(whichwindow:byte);
begin
 setfillstyle(1,1);
 with threewins[whichwindow] do
  bar(x1+1,y1+1,x2-1,y2-1);
 case whichwindow of
  file_win: showfiles;
  subdir_win: showdirs;
 end;
 highlight(whichwindow,1);
 top[whichwindow]:=where[whichwindow];
end;

procedure fileblit(xpos,xlen,y1,y2:word; dir:shortint; ylen:word);
var fv:word; bit:byte;
begin;
 for bit:=0 to 3 do
 begin;
  fv:=0;
  while fv<ylen do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   move(mem[$A000:(y1+fv*dir)*80+xpos],mem[$A000:(y2+fv*dir)*80+xpos],xlen);
   inc(fv);
  end;
 end;
 bit:=getpixel(0,0);
end;

procedure seekthrough(whichlist:byte; var wherenow:byte; whatfor:char);
var startedat:byte;
begin
 startedat:=wherenow;
 repeat
  inc(wherenow);
  if wherenow>nums[whichlist] then wherenow:=1;
 until (startedat=wherenow) or (lists[whichlist,wherenow,1]=whatfor);
 repaint(whichlist);
end;

procedure gotohome(whichlist:byte);
begin
 where[whichlist]:=1;
 repaint(whichlist);
end;

procedure gotoend(whichlist:byte);
begin
 where[whichlist]:=nums[whichlist];
 repaint(whichlist);
end;

procedure pageup(whichlist:byte);
begin
 if where[whichlist]>9 then
 begin
  dec(where[whichlist],9);
  repaint(whichlist);
 end;
end;

procedure pagedown(whichlist:byte);
begin
 if where[whichlist]<nums[whichlist]-9 then
 begin
  inc(where[whichlist],9);
  repaint(whichlist);
 end;
end;

procedure subdirparse(r:string);
  procedure movehl(which:byte; howmuch:shortint);
  begin;
   highlight(4,where[4]-top[4]+1);
   if ((where[which]+howmuch)>0) and ((where[which]+howmuch)<=nums[4])
    then where[which]:=where[which]+howmuch;
   highlight(4,where[4]-top[4]+1);
  end;

  procedure change_dir;
  begin;
   dusk;
   {$I-} chdir(lists[4,where[4]]);
   {$I+}
   if ioresult<>0 then begin; dawn; blip; exit; end;
   where[4]:=1; top[4]:=1;
   getcurrent; scandir; show;
   highlight(4,1);
   dawn;
  end;

begin;
 case r[1] of
  cReturn: change_dir;

  #0: case r[2] of
       cUp: if where[4]-top[4]>0 then { Up }
             movehl(4,-1) { Within range }
            else if top[4]>1 then
            begin; { Outside range- must scroll }
             highlight(4,1);
             dec(top[4]); dec(where[4]);
             fileblit(61,18,166,176,-1,80);
             setfillstyle(1,1); bar(490,85,630,95); setcolor(11);
             outtextxy(497,87,'['+lists[dirs,where[4]]+']');
             highlight(4,1);
            end;
       cDown:
            if where[4]-top[4]<8 then { Down }
             movehl(4,1)
            else if top[4]+8<nums[4] then
            begin;
             highlight(4,9);
             inc(top[4]); inc(where[4]);
             fileblit(60,18,97,87,1,80);
             setfillstyle(1,1); bar(490,165,630,175); setcolor(11);
             outtextxy(497,167,'['+lists[dirs,where[4]]+']');
             highlight(4,9);
            end;
       cHome: gotohome(4);
       cEnd: gotoend(4);
       cPgUp: pageup(4);
       cPgDn: pagedown(4);
       c_aO: change_dir;
      end;
   else seekthrough(4,where[4],lowchar(r[1]));
 end;
end;

procedure fileinfo(which:byte);
 { This gives information on the file whose name is in lists[files,which]. }
var
 eh:ednahead;
 f:file;
 os:string[4];
 r:char;

 procedure display(y:integer; left,right:string);
 begin;
  y:=17+y*12;
  settextjustify(2,1); setcolor(11); outtextxy(315,y,left);
  settextjustify(0,1); setcolor(15); outtextxy(325,y,right);
 end;

begin;

 { Firstly, we must check whether or not it's an Avalot file. This is easily
   done, since the descriptions of all others always begin with a star. }

 if (descs[which,1]='*') or (descs[which,1]='(') then
 begin; { it is. }
  blip; { Naaaarghh! }
  exit;
 end;

 { Anyway... it wasn't. }

 assign(f,lists[files,which]+'.asg');
 reset(f,1);
 seek(f,177);
 blockread(f,eh,sizeof(eh));
 close(f);

 { We now hold its EDNA record. }

 setfillstyle(1,1); bar(2,2,637,197); { Interesting information coming up! }

 with eh do
 begin;
  display(2,'Saved by:', game);
  display(3,'version:', verstr);

(*  display(4,'under', os);*)

  display(6,'Saved on ',strf(d)+'-'+strf(m)+'-'+strf(y));

  display(9,'No. of times saved:',strf(saves));

  display(11,'Money:',money);
  display(12,'Score:',strf(points));
 end;

 shbox(500,177,650,200,'Press any key...');
 r:=readkey;

 setfillstyle(1,1); bar(2,2,637,197);
end;

procedure filer_help;
 { This gives general help. }
var
 r:char;
begin;
 outtextxy(100,100,'Just general help here.');
 shbox(500,177,650,200,'Press any key...');
 r:=readkey;

 setfillstyle(1,1); bar(2,2,637,197);
end;

procedure wipe;
 { This allows you to delete files. }
var
 r:char;
begin;
 outtextxy(100,100,'Are you sure you want to delete "foo.bar"?');
 shbox(500,177,650,200,'[Y/N]');
 r:=readkey;

 setfillstyle(1,1); bar(2,2,637,197);
end;

procedure filesparse(r:string);
  procedure movehl(which:byte; howmuch:shortint);
  begin;
   highlight(3,where[3]-top[3]+1);
   if ((where[which]+howmuch)>0) and ((where[which]+howmuch)<=nums[3])
    then where[which]:=where[which]+howmuch;
   highlight(3,where[3]-top[3]+1);
  end;

  function selected_file:boolean;
  begin;
   if descs[where[file_win],1]='*' then
   begin
    blip;
    selected_file:=false;
   end else
   begin
    filename:=lists[file_win,where[file_win]];
    filefound:=true;
    selected_file:=true;
   end;
  end;

begin;
 case r[1] of
  cReturn: if selected_file then exit;
  #0: case r[2] of
       cUp: if where[3]-top[3]>0 then { Up }
             movehl(3,-1) { Within range }
            else if top[3]>1 then
            begin; { Outside range- must scroll }
             highlight(3,1);
             dec(top[3]); dec(where[3]);
             fileblit(1,59,166,176,-1,80);
             setfillstyle(1,1); bar( 15,85,480,95);
             show_file( 19,87,where[3]);
             highlight(3,1);
            end;
       cDown: if where[3]-top[3]<8 then { Down }
             movehl(3,1)
            else if top[3]+8<nums[3] then
            begin;
             highlight(3,9);
             inc(top[3]); inc(where[3]);
             fileblit(1,59,97,87,1,80);
             setfillstyle(1,1); bar( 15,165,480,175);
             show_file( 19,167,where[3]);
             highlight(3,9);
            end;
       c_ai: fileinfo(where[3]); { alt-I: information. }
       c_ah,c_f1: filer_help; { alt-I: information. }
       cHome: gotohome(3);
       cEnd: gotoend(3);
       cPgUp: pageup(3);
       cPgDn: pagedown(3);
       c_aO: if selected_file then exit;
      end;
  else seekthrough(3,where[3],lowchar(r[1]));
 end;
end;

function playaround:string;
var r,r2:char;
  procedure changewin(i:byte);
  begin;
   case nowwin of
    3,4: highlight(nowwin,where[nowwin]-top[nowwin]+1);
   end;
   setcolor(3); with threewins[nowwin] do box(x1,y1,x2,y2,title);
   nowwin:=i;
   if nowwin<1 then nowwin:=4; if nowwin>4 then nowwin:=1;
   case nowwin of
    3,4: highlight(nowwin,where[nowwin]-top[nowwin]+1);
   end;
  end;
begin;
 filefound:=false; dawn;

 repeat
  setcolor(14); with threewins[nowwin] do box(x1,y1,x2,y2,title);
  r:=readkey;
  case r of
   cTab: changewin(nowwin+1);
   cEscape: begin;
             playaround:='';
             exit;
            end;
   #0: begin; { parse extd keystroke }
        r2:=readkey;
        case r2 of
         cs_tab: changewin(nowwin-1);
         c_aN: changewin(1);
         c_aD: changewin(2);
         c_aF: changewin(3);
         c_aS: changewin(4);
         c_aC: begin;
                playaround:='';
                exit;
               end;
         else
          case nowwin of
           3: filesparse(#0+r2);
           4: subdirparse(#0+r2);
          end;
         end;
        end;
  else
   begin; { Pass keystroke to current window }
    case nowwin of
     2: changedrive(upcase(r));
     4: subdirparse(r);
     3: filesparse(r);
     else blip;
    end;
   end;

  end;

  if filefound then
  begin;
   dusk;
   playaround:=filename;
   exit;
  end;
 until false;
end;

function do_filer:pathstr;
var p:pathstr;
begin;
 loading:=true;
 setup;
 scandir;
 show; show_drives;
 p:=playaround;
 if p<>'' then p:=fexpand(p+'.ASG');
 do_filer:=p;
end;

begin;
 filename:=do_filer;
 closegraph;
 if filename='' then
  writeln('*** CANCELLED! ***')
 else
  writeln('Selected: ',filename);
 readln;
end.
