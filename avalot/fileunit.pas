unit fileunit; { v:filer.pas - "avvyfiler" - in unit form. }

     interface

function do_filer:string; { Result is filename, or "" if cancelled. }

     implementation

uses Graph,Dos,Crt,Tommys,Lucerna,Pingo,Gyro;
{$V-}

type
 windowtype = record
               x1,y1,x2,y2:integer;
               title:string[20];
              end;

const
 border = 1; { size of border on shadowboxes }

 buttons : array[1..4] of string = ('Okay','Wipe','Cancel','Info...');

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

 Filer_Page = 3;

var
 lists:array[3..4,1..77] of string[12];
 descs:array[1..77] of string[40];
 nums,where,top,thumb_pos,thumb_len:array[3..4] of byte;
 s:searchrec;
 loading:boolean;
 drives:string[26];
 current:pathstr;
 nowwin:byte;

 filename:pathstr;
 filefound:boolean;

 cancelled:boolean;

procedure shadow(x1,y1,x2,y2:integer; hc,sc:byte);
var fv:byte;
begin
 for fv:=0 to border do
 begin
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
begin
 shadow(x1,y1,x2,y2,15,8);
 setfillstyle(1,fc);
 bar(x1+border+1,y1+border+1,x2-border-1,y2-border-1);
 setcolor(1); x1:=(x2-x1) div 2+x1; y1:=(y2-y1) div 2+y1;
 outtextxy(x1,y1,t);
 if (t[1]<>'[') and (length(t)>1) then
 begin
  fillchar(t[2],length(t)-1,#32); t[1]:='_';
  outtextxy(x1-1,y1+1,t);
 end;
end;

procedure show_drives;
var fv:byte;
begin
 settextjustify(1,1);
 for fv:=0 to length(drives)-1 do
  shbox((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,drives[fv+1]);
 setcolor(11);
 settextjustify(0,2);
end;

function which_drive(x,y:integer):char;
begin
  x:=(x-25) div 25; y:=(y-32) div 19;

  which_drive:= drives[1+x+y*drlen];
end;

procedure box(x1,y1,x2,y2:integer; z:string);
begin
 rectangle(x1,y1,x2,y2);
 outtextxy(x1+1,y1-10,z+':');
 outtextxy(x1,y1-9,'_');
end;

function lowstr(x:string):string;
var fv:byte;
begin
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
begin
 current:=lowstr(fexpand('*.asg'));
end;

procedure firstsetup;
var
 gd,gm:integer;
 r:registers;
 floppies:byte;
begin
 { Now... find all drives that exist. }
 drives:='';
 intr($11,r); floppies:=((r.ax shr 6) and $3)+1; { useful bit of code! }
 for gm:=1 to floppies do drives:=drives+chr(64+gm);
 { Winchesters, etc., can be found the easy way... }
 for gd:=3 to 26 do { C: to Z: }
  if disksize(gd)>-1 then drives:=drives+chr(64+gd);

 fillchar(where,sizeof(where),#1);
 fillchar(top,sizeof(top),#1);

 { Set up mouse. }
 off_virtual;
 OnCanDoPageSwap:=false;
 newpointer(2);
end;

procedure draw_scroll_bar(which:byte);
begin
  setcolor(1);
  with threewins[which] do
  begin
    setfillstyle(1,7);
    bar(x2-7,y1+10,x2-1,y2-10);
    setfillstyle(1,3);
    bar(x2-7,y1+ 1,x2-1,y1+9);
    bar(x2-7,y2- 9,x2-1,y2-1);
    outtextxy(x2-7,y1+2,#24);
    outtextxy(x2-7,y2-8,#25);
  end;
end;

procedure setup;
var
 gd,gm:integer;
 r:registers;
 floppies:byte;
begin
 setactivepage(Filer_Page); setvisualpage(Filer_Page);
 setfillstyle(1,1); bar(2,2,637,197); shadow(0,0,639,199,15,7);

 settextstyle(0,0,0);
 settextjustify(1,1);
 for gd:=1 to 2 do
  for gm:=0 to 1 do
   shbox(420+gm*110,gd*25,520+gm*110,gd*25+20,buttons[gm*2+gd]);
 shbox(15,182,350,196,'Help... (press f1)');
 settextjustify(0,2); setcolor(11);
 setcolor(15); outtextxy(15,5,'The Avvy Filer...');
 setcolor(11); outtextxy(317,3,'Select a file to load.');
 outtextxy(357,185,'Copyright (c) 1993, Thomas Thurman.');

 { Draw the boxes and names }
 setcolor(3);
 for gm:=1 to 4 do
  with threewins[gm] do
   box(x1,y1,x2,y2,title);

 { Draw the scroll bars. }

 for gm:=3 to 4 do draw_scroll_bar(gm);
end;

procedure thumb(whichwin:byte);
var length,the_top:word;
begin
  if nums[whichwin]<9 then
  begin
    length:=76;
    the_top:=0;
  end else
  begin
    length:=trunc(76*(8/nums[whichwin]));
    the_top:=trunc((where[whichwin]/nums[whichwin])*(76-length));
  end;

  inc(the_top,93); { Top of both the scrollbars. }

  setfillstyle(1,7);
    with threewins[whichwin] do
      bar(x2-6,thumb_pos[whichwin],x2-3,thumb_pos[whichwin]+length);
  setfillstyle(1,1);
    with threewins[whichwin] do
      bar(x2-6,the_top,x2-3,the_top+length);

  thumb_pos[whichwin]:=the_top;
  thumb_len[whichwin]:=length;
end;

procedure QuickSort(WhichList:byte; Lo, Hi: Integer);

procedure Sort(l, r: Integer);
var
  i, j: integer;
  x, y: string[12];
  d:    string[40];
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

      d := descs[i];
      descs[i] := descs[j];
      descs[j] := d;

      i := i + 1; j := j - 1;
    end;
  until i > j;

(*  if j<1 then j:=1;
  if r<1 then r:=1;*)

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

begin
 nums[files]:=0;
 findfirst('*.asg',archive+hidden+readonly,s);

 while (doserror=0) and (nums[files]<77) do
 begin
  fsplit(s.name,nix,name,nix);
  inc(nums[files]);
  lists[files,nums[files]]:=lowstr(name);

  assign(f,s.name);
  reset(f,1);
  seek(f,11);
  blockread(f,dna_type,4);

  if dna_type='Avvy' then
  begin { A DNA256 file. }
   descs[nums[files]]:='* Saved by Avaricius!';
  end else
  begin { EDNA-based files. }
   if dna_type='EDNA' then
   begin
    seek(f,177);
    blockread(f,eh,sizeof(eh));

    with eh do
     if revision<>2 then
      descs[nums[files]]:='* Unknown EDNA type!'
     else
     begin

      if number<>2 then
       descs[nums[files]]:='% Saved by '+shortname+'!'
      else
      begin { Well... everything seems to have gone OK! }
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
 while (doserror=0) and (nums[dirs]<77) do
 begin
  if ((s.attr and directory)>0) and ((length(s.name))>1) then
  begin
   inc(nums[dirs]);
   lists[dirs,nums[dirs]]:=lowstr(s.name);
  end;
  findnext(s);
 end;

 { Now sort 'em! }

 if nums[dirs ]<>0 then QuickSort ( dirs,1,nums[ dirs]);
 if nums[files]<>0 then QuickSort (files,1,nums[files]);

 where[dirs]:=1; where[files]:=1;
   top[dirs]:=1; top[files]:=1;

 thumb_pos[3]:=93; thumb_pos[4]:=93;
end;

procedure show_file(x,y:integer; which:byte);
var
 z:string[58];
begin
 fillchar(z[1],13,#32);
 z:=lists[files,which]+'.asg';
 z[0]:=#13; z:=z+descs[which];

 if descs[which,1] in ['*','%'] then { Can't load these! }
  setcolor(red)
 else
  setcolor(lightcyan);

 outtextxy(x,y,z);
end;

procedure showfiles;
var fv:byte;
begin
 if loading then setcolor(11) else setcolor(3);
 if nums[3]=0 then
 begin
  outtextxy(22,86,'(None here!)');
  exit;
 end;
 for fv:=0 to 8 do
  if top[3]+fv<=nums[3] then
   show_file(19,87+fv*10,top[3]+fv);

 draw_scroll_bar(files);
end;

procedure showdirs;
var fv:byte;
begin
 setcolor(11);
 for fv:=0 to 8 do
  if top[4]+fv<=nums[4] then
   outtextxy(497,87+fv*10,'['+lists[dirs,fv+top[4]]+']');
 draw_scroll_bar(dirs);
end;

procedure show;
var
 fv:byte;
 D: DirStr; N: NameStr; E: ExtStr;
begin
 setfillstyle(1,1);
 for fv:=1 to 4 do
  if fv<>2 then
   with threewins[fv] do
    bar(x1+1,y1+1,x2-8,y2-1);
 showfiles;
 showdirs;
 setcolor(7); outtextxy(159,14,current);
 for fv:=3 to 4 do thumb(fv);
end;

procedure blip;
begin
 sound(177); delay(77); nosound;
end;

procedure invert(x1,y1,x2,y2:integer);
var p,restore:pointer; s:word;
begin
 s:=imagesize(x1,y1,x2,y2);
 mark(restore); getmem(p,s);
 getimage(x1,y1,x2,y2,p^);
 putimage(x1,y1,p^,notput);
 release(restore);
end;

procedure changedrive(drive:char);
var fv:byte;
begin
 fv:=pos(drive,drives);
 if fv=0 then begin blip; exit; end;
 off;
 dec(fv);
 shadow((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,8,7);
 chdir(drive+':');
 getcurrent; scandir; show;
 shadow((fv mod drlen)*25+25,(fv div drlen)*19+31,
   (fv mod drlen)*25+40,45+(fv div drlen)*19,15,8);
 on;
end;

procedure highlight(win,line:byte);
begin
 case win of
  3: invert(16,75+line*10,470,85+line*10);
  4: invert(491,75+line*10,620,85+line*10);
 end;
 thumb(win);
end;

procedure repaint(whichwindow:byte);
begin
 setfillstyle(1,1);
 with threewins[whichwindow] do
  bar(x1+1,y1+1,x2-8,y2-1);
 top[whichwindow]:=where[whichwindow];
 case whichwindow of
  file_win: showfiles;
  subdir_win: showdirs;
 end;
 thumb(whichwindow);
end;

procedure fileblit(xpos,xlen,y1,y2:word; dir:shortint; ylen:word);
var fv:word; bit:byte;
begin
 for bit:=0 to 3 do
 begin
  fv:=0;
  while fv<ylen do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   move(mem[$AC00:(y1+fv*dir)*80+xpos],mem[$AC00:(y2+fv*dir)*80+xpos],xlen);
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
 off;
 repaint(whichlist);
 on;
end;

procedure gotohome(whichlist:byte);
begin
 off;
 where[whichlist]:=1;
 repaint(whichlist);
 highlight(whichlist,1);
 on;
end;

procedure gotoend(whichlist:byte);
begin
 off;
 where[whichlist]:=nums[whichlist];
 repaint(whichlist);
 highlight(whichlist,1);
 on;
end;

procedure pageup(whichlist:byte);
begin
 off;
 if where[whichlist]>9 then
 begin
  dec(where[whichlist],9);
  repaint(whichlist);
  highlight(whichlist,1);
 end else gotohome(whichlist);
 on;
end;

procedure pagedown(whichlist:byte);
begin
 off;
 if where[whichlist]<nums[whichlist]-9 then
 begin
  inc(where[whichlist],9);
  repaint(whichlist);
  highlight(whichlist,1);
 end else gotoend(whichlist);
 on;
end;

procedure subdirparse(r:string);
  procedure movehl(which:byte; howmuch:shortint);
  begin
   off;
   highlight(4,where[4]-top[4]+1);
   if ((where[which]+howmuch)>0) and ((where[which]+howmuch)<=nums[4])
    then where[which]:=where[which]+howmuch;
   highlight(4,where[4]-top[4]+1);
   on;
  end;

  procedure change_dir;
  begin
   off; dusk;
   {$I-} chdir(lists[4,where[4]]);
   {$I+}
   if ioresult<>0 then begin dawn; blip; exit; end;
   where[4]:=1; top[4]:=1;
   getcurrent; scandir; show;
   highlight(4,1);
   dawn; on;
  end;

begin
 case r[1] of
  cReturn: change_dir;

  #0: case r[2] of
       cUp: if where[4]-top[4]>0 then { Up }
             movehl(4,-1) { Within range }
            else if top[4]>1 then
            begin { Outside range- must scroll }
              off;
              highlight(4,1);
              dec(top[4]); dec(where[4]);
              fileblit(61,17,166,176,-1,80);
              setfillstyle(1,1); bar(490,85,622,95); setcolor(11);
              outtextxy(497,87,'['+lists[dirs,where[4]]+']');
              highlight(4,1);
              on;
            end;
       cDown:
            if where[4]-top[4]<8 then { Down }
             movehl(4,1)
            else if top[4]+8<nums[4] then
            begin
              off;
              highlight(4,9);
              inc(top[4]); inc(where[4]);
              fileblit(60,17,97,87,1,80);
              setfillstyle(1,1); bar(490,165,622,175); setcolor(11);
              outtextxy(497,167,'['+lists[dirs,where[4]]+']');
              highlight(4,9);
              on;
            end;
       cHome: gotohome(4);
       cEnd: gotoend(4);
       cPgUp: pageup(4);
       cPgDn: pagedown(4);
       c_aO: change_dir;
      end;
   else begin
         off;
         seekthrough(4,where[4],lowchar(r[1]));
         highlight(4,1);
         on;
        end;
 end;
end;

procedure fileinfo(which:byte); forward;
procedure filer_help; forward;
procedure wipe(which:byte); forward;

procedure in_name_box(x:string);
begin
 off;
 setfillstyle(1,1); bar(156,13,629,21);
 setcolor(7); outtextxy(159,14,x);
 on;
end;

procedure filesparse(r:string);
  procedure movehl(which:byte; howmuch:shortint);
  begin
   off;
   highlight(3,where[3]-top[3]+1);
   if ((where[which]+howmuch)>0) and ((where[which]+howmuch)<=nums[3])
    then where[which]:=where[which]+howmuch;
   highlight(3,where[3]-top[3]+1);
   on;
  end;

  function selected_file:boolean;
  begin
   if (descs[where[file_win],1] in ['*','%']) or (nums[3]=0) then
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

begin
 case r[1] of
  cReturn: if selected_file then exit;
  #0: case r[2] of
       cUp: if where[3]-top[3]>0 then { Up }
             movehl(3,-1) { Within range }
            else if top[3]>1 then
            begin { Outside range- must scroll }
              off;
              highlight(3,1);
              dec(top[3]); dec(where[3]);
              fileblit(1,58,166,176,-1,80);
              setfillstyle(1,1); bar( 15,85,472,95);
              show_file( 19,87,where[3]);
              highlight(3,1);
              on;
            end;
       cDown: if where[3]-top[3]<8 then { Down }
             movehl(3,1)
            else if top[3]+8<nums[3] then
            begin
              off;
              highlight(3,9);
              inc(top[3]); inc(where[3]);
              fileblit(1,58,97,87,1,80);
              setfillstyle(1,1); bar( 15,165,472,175);
              show_file( 19,167,where[3]);
              highlight(3,9);
              on;
            end;
       c_ai: fileinfo(where[3]); { alt-I: information. }
       c_aw: wipe(where[3]);     { alt-W: wipe. }
       cHome: gotohome(3);
       cEnd: gotoend(3);
       cPgUp: pageup(3);
       cPgDn: pagedown(3);
       c_aO: if selected_file then exit;
      end;
  else begin
        off;
        seekthrough(3,where[3],lowchar(r[1]));
        highlight(3,1);
        on;
       end;
 end;
 in_name_box(lists[files,where[3]]+'.asg');
end;

procedure entername(r:char);
begin
 case r of
  #8: if filename[0]<>#0 then dec(filename[0]);
  #13: filefound:=true;
  #32:; { ignore spaces. }
  else
  begin
   if length(filename)<55 then filename:=filename+r;

   if length(filename)=1 then
   begin
    where[3]:=1;
    seekthrough(3,where[3],filename[1]);
   end;
  end;
 end;

 in_name_box(filename+'.asg');

end;

procedure changewin(i:byte);
begin
 off;
 case nowwin of
  3,4: highlight(nowwin,where[nowwin]-top[nowwin]+1);
 end;
 setcolor(3); with threewins[nowwin] do box(x1,y1,x2,y2,title);
 nowwin:=i;
 if nowwin<1 then nowwin:=4; if nowwin>4 then nowwin:=1;
 case nowwin of
  3,4: highlight(nowwin,where[nowwin]-top[nowwin]+1);
 end;
 on;
end;

procedure checkmouse;
var fv,new,waswin:byte;
  procedure relevant(x:string);
  begin
    setcolor(14); off; with threewins[nowwin] do box(x1,y1,x2,y2,title);
    on; if nowwin=3 then filesparse(x) else subdirparse(x);
  end;
begin
   check;
   if mrelease>0 then
   begin  { Where did they click? }
     for fv:=1 to 4 do
       with threewins[fv] do
         if (x1<=mx) and (x2>=mx) and (y1<=my) and (y2>=my) then
         begin
           waswin:=nowwin;

           if nowwin<>fv then
           begin
             changewin(fv);
             off;
             setcolor(14); with threewins[nowwin] do box(x1,y1,x2,y2,title);
             on;
           end;
           { Now... individual windows should do their own checkclicking. }

           case fv of
             { 1: no effect. }
             2: changedrive(which_drive(mx,my)); { Change drive w/mouse. }
             3,4: if my<175 then begin { Click on highlight users. }
                    if mx>threewins[nowwin].x2-9 then
                    begin { Scroll bar. }
                      if my<threewins[nowwin].y1+10 then
                        relevant(null+cUp) { scroll up }
                      else if my>threewins[nowwin].y2-10 then
                        relevant(null+cDown) { scroll down. }
                      else if my<thumb_pos[nowwin] then
                        relevant(null+cPgUp) { above thumb-- page up. }
                      else if my>thumb_pos[nowwin]+thumb_len[nowwin] then
                        relevant(null+cPgDn) { above thumb-- page up. }
                      else begin  { On the thumb. }
                        blip;
                      end;
                    end else
                    begin
                      new:=top[fv]+(my-75) div 10-1;

                      if (new=where[fv]) and (nowwin=waswin) then
                      begin { Double-clicked, --> "OK" }
  (*                     filefound:=true;
                       filename:=lists[fv,new];*)
                       if fv=3 then filesparse(#13) else subdirparse(#13);
                      end else
                      begin { Single-clicked, --> move highlight }
                        off;
                        highlight(fv,where[fv]-top[fv]+1);
                        if (new>0) and (new<=nums[fv]) then
                           where[fv]:=new;
                        highlight(fv,where[fv]-top[fv]+1);
                        on;
                      end;
                    end;
                  end;
           end;

           exit; { Since they've clicked in a window... }
         end;

         { Righto, they must have clicked on a button. Which? }

         case my of
            25.. 45: { Top row: Okay, Cancel. }
                     case mx of
                       420..520: case nowwin of
                                  1: entername(#13);
                                  3: filesparse(#13);
                                  4: subdirparse(#13);
                                  else blip;
                                 end;
                       530..630: cancelled:=true;
                     end;
            50.. 95: { Bottom row: Wipe, Info. }
                     case mx of
                       420..520: if nowwin=3 then wipe(where[3]) else blip;
                       530..630: if nowwin=3 then fileinfo(where[3]) else blip;
                     end;
           180..200: filer_help; { The "help" button. }
         end;
   end;
end;

function playaround:string;
var r,r2:char;
begin
 filefound:=false; dawn;

 repeat
  setcolor(14); off; with threewins[nowwin] do box(x1,y1,x2,y2,title); on;
  repeat checkmouse until keypressed or filefound or cancelled;
  if not (filefound or cancelled) then
  begin
    r:=readkey;
    case r of
     cTab: changewin(nowwin+1);
     cEscape: begin
               playaround:='';
               exit;
              end;
     #0: begin { parse extd keystroke }
          r2:=readkey;
          case r2 of
           cs_tab: changewin(nowwin-1);
           c_aN: changewin(1);
           c_aD: changewin(2);
           c_aF: changewin(3);
           c_aS: changewin(4);
           c_aC: cancelled:=false;
           c_ah,cf1: filer_help;         { alt-H: help. }
           else
            case nowwin of
             3: filesparse(#0+r2);
             4: subdirparse(#0+r2);
            end;
           end;
          end;
    else
     begin { Pass keystroke to current window }
      case nowwin of
       1: entername(r);
       2: changedrive(upcase(r));
       4: subdirparse(r);
       3: filesparse(r);
       else blip;
      end;
     end;
   end;

  end;

  if filefound then
  begin
   dusk;
   playaround:=filename;
   exit;
  end;

  if cancelled then
  begin
   dusk;
   playaround:='';
   exit;
  end;
 until false;
end;

procedure drawup;
begin
 off;
 loading:=true;
 setup;
 show; show_drives;
 on;
end;

procedure little_CLS;
begin
 setfillstyle(1,1); bar(2,2,637,197); { Interesting information coming up! }
end;

procedure wait_for_keypress_or_mouse_click;
var r:char;
begin
  repeat check until (mrelease>0) or keypressed;
  while keypressed do r:=readkey;
end;

procedure fileinfo(which:byte);
 { This gives information on the file whose name is in lists[files,which]. }
var
 eh:ednahead;
 f:file;
 os:string[4];

 procedure display(y:integer; left,right:string);
 begin
  y:=17+y*12;
  settextjustify(2,1); setcolor(11); outtextxy(315,y,left);
  settextjustify(0,1); setcolor(15); outtextxy(325,y,right);
 end;

begin

 { Firstly, we must check whether or not it's an Avalot file. This is easily
   done, since the descriptions of all others always begin with a star. }

 if (descs[which,1]='*') or (nums[3]=0) then
 begin { it is. }
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

 off;
 little_CLS; { Interesting information coming up! }

 with eh do
 begin
  display(0,'File:',fn);
  display(1,'Description:',desc);
  display(2,'Saved by:', game);
  display(3,'version:', verstr);

  display(4,'under', os);

  display(6,'Saved on:',strf(d)+'-'+strf(m)+'-'+strf(y));

  display(9,'No. of times saved:',strf(saves));

  display(11,'Money:',money);
  display(12,'Score:',strf(points));
 end;

 settextjustify(1,1);
 shbox(400,177,600,195,'[Press any key...]');
 settextjustify(0,2); on;
 wait_for_keypress_or_mouse_click;

 off; setfillstyle(1,1); bar(2,2,637,197);
 drawup;
 off; highlight(3,where[3]-top[3]+1); on;
end;

procedure filer_help;
 { Just some general help... }

begin
 off; little_CLS;

 setcolor(15);
 outtextxy(10, 10,'To change to a particular pane:');
 outtextxy(10, 50,'To choose a file:');
 outtextxy(10,100,'To change drives:');
 outtextxy(10,140,'Finally...');

 setcolor(14);
 outtextxy(20, 20,'Press Alt and the initial letter simultaneously.');
 outtextxy(20, 30,'(e.g. to change to the Name pane, press Alt-N.)');
 outtextxy(20, 60,'Either type its name in the Name pane or choose it');
 outtextxy(20, 70,'from the list in the Files pane. You may either use');
 outtextxy(20, 80,'a mouse or the keyboard to do this.');
 outtextxy(20,110,'Move into the Drives pane and press the letter of the');
 outtextxy(20,120,'drive you want.');
 outtextxy(20,150,'Either select OK to load the file, or Cancel to back out.');

 settextjustify(1,1);
 shbox(400,177,600,195,'[Press any key...]');
 settextjustify(0,2); on;
 wait_for_keypress_or_mouse_click;

 off; setfillstyle(1,1); bar(2,2,637,197);
 drawup; off;
 if nowwin in [3,4] then highlight(nowwin,where[nowwin]-top[nowwin]+1);
 on;
end;

procedure wipe(which:byte);
 { This wipes the file whose name is in lists[files,which]. }
var
 r:char;
 f:file;

begin
 off; little_CLS;

 settextjustify(1,1);
 outtextxy(320,100,'Are you sure you want to delete "'+
                        lists[files,which]+'.asg"?');
 shbox(400,177,600,195,'[Y/N]');

 repeat
  r:=upcase(readkey);
  if r='Y' then
  begin
   assign(f,lists[files,which]+'.asg'); {$I-} erase(f); {$I+}

   setcolor(14);
   if ioresult=0 then
   begin
     scandir;
     outtextxy(100,140,'Deleted.')
   end else
     outtextxy(100,140,'Not deleted (some problem...)');

   shbox(400,177,600,195,'[Press any key...]');
   on;
   wait_for_keypress_or_mouse_click; off;
  end;
 until r in ['Y','N'];

 settextjustify(0,2); setcolor(14);
 setfillstyle(1,1); bar(2,2,637,197);
 drawup;
 off; highlight(3,where[3]-top[3]+1); on;
end;

function do_filer:string;
var
 p:pathstr; groi:byte; original_directory:dirstr;
begin
 getdir(0,original_directory);
 dusk;
 OnCanDoPageSwap:=false; cancelled:=false;
 copypage(3,1-cp); { Store old screen. } groi:=getpixel(0,0);
 off;

 firstsetup;
 scandir;
 nowwin:=1; getcurrent;
 firstsetup; drawup;
 on;
 mousepage(Filer_Page);

 p:=playaround;
 if p<>'' then p:=fexpand(p+'.ASG');
 do_filer:=p;
 filename:='';

 mousepage(cp);
 dusk; off;
 OnCanDoPageSwap:=true;
 copypage(1-cp,3); { Restore old screen. } groi:=getpixel(0,0);
 on_Virtual; dawn; fix_flashers;

 setvisualpage(cp);
 setactivepage(1-cp);
 chdir(original_directory);

end;

end.