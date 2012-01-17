{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 ENID             Edna's manager. }

unit Enid; { Loads/ saves files. }

{$V-}

interface

uses Gyro;

procedure edna_save(name:string);

procedure edna_load(name:string);

procedure edna_reload; { From Bootstrap's storage. }

procedure dir(where:string);

procedure avvy_background;

procedure back_to_bootstrap(what:byte);

function there_was_a_problem:boolean;

implementation

uses Dos,Scrolls,Lucerna,Trip5,Timeout,Celer,Sequence,Fileunit,Basher;

const
 crlf = #13+#10;
 tab = ^I;
 eof = ^Z;

 ednafirst : array[1..177] of char =
  'This is an EDNA-based file, saved by a Thorsoft game. Good luck!'+ {64}
  crlf+eof+crlf+crlf+ {7}
  tab+'Glory to God in the highest,'+crlf+ {31}
  tab+'and on earth peace, goodwill toward men.'+ {42}
  crlf+tab+tab+tab+tab+ {6}
  'Luke 2:14.'+ {10}
  crlf+crlf+crlf+ { 6 }
  '1234567890'+crlf; {11}

 ednaID = 'TT'+#177+#48+#01+#117+#177+#153+#177;

 ttage = 18;
 ttwashere : array[1..16] of char = 'Thomas was here ';

var
 bug:boolean;

function expanddate(d,m:byte; y:word):string;
const months : array[1..12] of string[7] =
 ('Jan#','Febr#','March','April','May','June','July','August',
  'Septem*','Octo*','Novem*','Decem*');
var
 month:string[10];
 day:string[4];

procedure addon(x:string); begin dec(month[0]); month:=month+x; end;

begin
 month:=months[m];
 case month[length(month)] of
  '#': addon('uary');
  '*': addon('ber');
 end;

 day:=strf(d);

 if (d in [1..9,21..31]) then
  case (d mod 10) of
   1: day:=day+'st';
   2: day:=day+'nd';
   3: day:=day+'rd';
   else day:=day+'th';
  end;

 expanddate:=day+' '+month+' '+strf(y);
end;

procedure edna_save(name:string);
var
 f:file;
 eh:ednahead;
 groi:word;
 groi2,path:string;
 tempd,tempm:word;

   procedure show_bug(icon:char; str:string);
   begin display(^g^f^s+icon+^v^m+str+^m) end;

   function test_bug(what:byte):boolean;
   begin
    if what=0 then begin test_bug:=false; exit; end;
    case what of
     2: show_bug('7','Error in filename!');
     101: show_bug('6','Disk full!');
     150: show_bug('4','Disk is write-protected!');
     else show_bug('B','Saving error!');
    end;
    test_bug:=true;
   end;
begin
 if name='' then
 begin     { We were given no name. Do we have a default? }
  if Enid_Filename='' then
  begin    { No }
   filename_edit; { Request one. }
   exit;
  end else { Yes }
   name:=Enid_Filename;
 end;

 wait; { Put up hourglass pointer }

 fillchar(eh,sizeof(eh),#177); { Fill up the edhead }

 inc(dna.saves); { It's been saved one more time... }

 with eh do
 begin

  { Info about this program }

  id:=ednaid;  { Edna's signature }
  revision:=thisgamecode; { 2- second revision of .ASG format }
  game:='Lord Avalot d''Argent'; { Title of game }
  shortname:='Avalot';
  number:=2; { Second Avvy game }
  ver:=thisvercode; { Version 1.00 }
  verstr:=vernum; { ditto }
  filename:='AVALOT.EXE'; { program's filename }
  osbyte:=1; { Saved under DOS }
  os:='DOS';

  { Info on this particular game }

  fsplit(name,path,fn,groi2); { fn = filename of this game }
  getdate(y,tempM,tempD,groi); { Day, month & year when the game was saved }
  d:=tempD; m:=tempM;
  desc:=RoomName; { Description of game (same as in Avaricius!) }
  len:=sizeof(dna); { Length of DNA. }

  { Quick reference & miscellaneous }

  saves:=dna.saves; { no. of times this game has been saved }
  cash:=dna.pence; { contents of your wallet in numerical form }
  money:=lsd; { ditto in string form (eg 5/-, or 1 denarius)}
  points:=dna.score; { your score }

  name:=path+fn+'.ASG';
 end;

 assign(f,name);
 {$I-}
 rewrite(f,1);
 if test_bug(ioresult) then exit;

 blockwrite(f,ednafirst,177); if test_bug(ioresult) then exit;
 blockwrite(f,eh,sizeof(eh)); if test_bug(ioresult) then exit;
 blockwrite(f,dna,sizeof(dna)); if test_bug(ioresult) then exit;

 for groi:=1 to numtr do
  with tr[groi] do
   if quick then
   begin
    blockwrite(f,groi,1); if test_bug(ioresult) then exit;
    savedata(f); if test_bug(ioresult) then exit;
   end;

 groi:=177; blockwrite(f,groi,1);

 blockwrite(f,times,sizeof(times)); { Timeout.times: Timers. }

  if test_bug(ioresult) then exit;

 blockwrite(f,seq,sizeof(seq)); { Sequencer information. }

  if test_bug(ioresult) then exit;

 for groi:=1 to ttage do
  blockwrite(f,ttwashere[1],16);

  if test_bug(ioresult) then exit;

 close(f);
  if test_bug(ioresult) then exit;
 {$I+}

 display(^F+'Saved: '+^R+name+'.');
 enid_Filename:=name;
end;

procedure loaderror(x:string; icon:char);
begin
 if HoldTheDawn then
 begin
  HoldTheDawn:=false;
  dawn;
 end;
 display(^g+^f+^s+icon+^v+'Loading error:  '+^m^m^r+x);
 bug:=true;
end;

procedure edna_load(name:string);

type
 fourtype = array[1..4] of char;

const
 Avaricius_file : fourtype = 'Avvy';

var
 f:file;
 eh:ednahead;
 fv:byte;
 io:byte;
 path,fn,groi:string;
 id4:fourtype;

 len2load:word;

begin

 if name='' then
 begin                   { No filename specified, so let's call the filer. }
  name:=do_filer;
  if name='' then exit;  { STILL no filename, so they must have cancelled. }
 end;

 bug:=false;

 wait; { Put up hourglass pointer }

 fsplit(name,path,fn,groi);
 name:=path+fn+'.ASG';

 { Load the file into memory }

 {$I-}
 assign(f,name);
 reset(f,1);

 io:=ioresult;
 if io<>0 then
  case io of
   2: loaderror('File not found!','8');
   3: loaderror('Directory not found!','3');
   else loaderror('Error no.'+strf(io),'1');
  end;

 if bug then exit;

 seek(f,11); blockread(f,id4,4);
 if id4=Avaricius_file then
 begin
  loaderror('That''s an Avaricius file!','1');
  close(f);
  exit;
 end;

 seek(f,177); { bypass ednafirst }

 blockread(f,eh,sizeof(eh)); { load ednahead }

 { Check ednahead for errors }

 with eh do
 begin
  if (id<>ednaid) or (revision<>2) then loaderror('Not an EDNA file!','7') else
  if number<>2 then loaderror('That file was saved by '+shortname+'!','1');
 end;

 if bug then
 begin
  close(f);
  exit;
 end;

 len2load:=eh.len;

 if eh.len<>sizeof(dna) then
 begin
  if HoldTheDawn then
  begin
   HoldTheDawn:=false;
   dawn;
  end;
  display(^s'3'^v'Warning: '^c^m'EDNA size doesn''t match.'^l);
  if eh.len>sizeof(dna) then
   len2load:=sizeof(dna) { BIGGER than ours }
  else fillchar(dna,sizeof(dna),#0); { Otherwise, smaller. }
 end;

 blockread(f,dna,len2load);

 for fv:=1 to numtr do
  with tr[fv] do
  if quick then done; { Deallocate sprite }

 repeat
  blockread(f,fv,1);
  if fv<>177 then tr[fv].loaddata(f);
 until fv=177;

 blockread(f,times,sizeof(times)); { Timeout.times: Timers. }

 blockread(f,seq,sizeof(seq)); { Sequencer information. }

 close(f);

 seescroll:=true; { This prevents display of the new sprites before the
  new picture is loaded. }

 if HoldTheDawn then
 begin
  HoldTheDawn:=false;
  dawn;
 end;

 with eh do
  display(^F+'Loaded: '+^R+name+^c+^m^m+desc+^m^m+'saved on '+
   expanddate(d,m,y)+'.');

 forget_chunks;

 minor_redraw;

 whereis[pAvalot]:=dna.room;
(* showscore;*)
 alive:=true;

 objectlist;
{$I+}

 enid_Filename:=name;
end;

procedure dir(where:string);
 { OK, it worked in Avaricius, let's do it in Avalot! }
var
 s:searchrec;
 path,groi:string;
 count:byte;

  procedure showheader;
  begin
   display('Dir: '+path+^m^m^d);
  end;
begin
 if (where<>'') and (not(where[length(where)] in ['\',':'])) then
  where:=where+'\';
 fsplit(where,path,groi,groi);
 path:=path+'*.asg';
 count:=0;

 findfirst(path,anyfile,s);
 showheader;

 while doserror=0 do
 begin
  inc(count);
  if count=11 then
  begin
   display(^m^i'Press Enter...');
   showheader;
   count:=1;
  end;

  display(s.name+^m^d);

  findnext(s);
 end;

 if count=0 then
  display('No files found!')
 else display(^i'That''s all!');

end;

procedure avvy_background; { Not really a filing procedure,
 but it's only called just before edna_load, so I thought I'd put it
 in Enid instead of, say, Lucerna. }
begin
(* port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1; port[$3CF]:=1; { Blue. }*)

 asm
  mov dx,$3c4; mov al,2; out dx,al; { Set up the VGA to use the "blue" }
  mov dx,$3ce; mov al,4; out dx,al; { register. }
  mov dx,$3c5; mov al,1; out dx,al;
  mov dx,$3cf;           out dx,al;

  mov bx,$A000; call far ptr @drawup;
  mov bx,$A400; call far ptr @drawup;

  jmp @the_end;

 @drawup:

  mov es,bx; { The segment to copy it to... }
  mov di,$370;  { The offset (10 pixels down, plus 1 offset.) }

  mov cx,10;
  mov ax,$AA4A; call far ptr @sameline; { Print "AVVY" }
  mov ax,$AEAA; call far ptr @sameline;
  mov ax,$A4EA; call far ptr @sameline;
  mov ax,$44A4; call far ptr @sameline;

  mov cx,9;
  mov ax,$AAA4; call far ptr @sameline; { Print "YAVV" }
  mov ax,$AAEA; call far ptr @sameline;
  mov ax,$AA4E; call far ptr @sameline;
  mov ax,$444A; call far ptr @sameline;

  mov ax,$4AAA; call far ptr @sameline; { Print "VYAV" }
  mov ax,$AAAE; call far ptr @sameline;
  mov ax,$EAA4; call far ptr @sameline;
  mov ax,$A444; call far ptr @sameline;

  mov ax,$A4AA; call far ptr @sameline; { Print "VVYA" }
  mov ax,$EAAA; call far ptr @sameline;
  mov ax,$4EAA; call far ptr @sameline;
  mov ax,$4A44; call far ptr @sameline;

  ret;


  { Replicate the same line many times. }

  @sameline:
   { Requires:
      what to copy in AX,
      how many lines in CX, and
      original offset in DI. }
   push cx;
   push di;

   @samelineloop:

    push cx;
    mov cx,40; { No. of times to repeat it on one line. }

    repz stosw; { Fast word-copying }

    pop cx;

    add di,1200; { The next one will be 16 lines down. }

   loop @samelineloop;
   pop di;
   add di,80;
   pop cx;

   ret;

  @the_end:
 end;

 blitfix;
end;

procedure TO_sundry(var sund:sundry);
begin
 with sund do
 begin
  qEnid_Filename:=Enid_Filename;
  qsoundfx:=soundfx;
  qthinks:=thinks;
  qthinkthing:=thinkthing;
 end;
end;

procedure FROM_sundry(sund:sundry);
begin
 with sund do
 begin
  Enid_Filename:=qEnid_Filename;
  soundfx:=qsoundfx;
  thinks:=qthinks;
  thinkthing:=qthinkthing;
 end;
end;

procedure restore_dna;
var
 here,fv:word;
 sund:sundry;
begin
 move(mem[Storage_SEG:Storage_OFS+3],dna,sizeof(dna));
 move(mem[Storage_SEG:Storage_OFS+3+sizeof(dna)],times,sizeof(times));
 move(mem[Storage_SEG:Storage_OFS+3+sizeof(dna)+sizeof(times)],
                                                 seq,sizeof(seq));
 move(mem[Storage_SEG:Storage_OFS+3+sizeof(dna)+sizeof(times)+sizeof(seq)],
                                                 sund,sizeof(sund));
 FROM_Sundry(sund);

 here:=Storage_OFS+3+sizeof(dna)+sizeof(times)+sizeof(seq)+sizeof(sund);
 repeat
  fv:=mem[Storage_SEG:here]; inc(here);
  if fv<>177 then tr[fv].load_data_from_mem(here);
 until fv=177;
end;

procedure edna_reload;
begin

 restore_dna;

 seescroll:=true; { This prevents display of the new sprites before the
  new picture is loaded. }

 major_redraw;

 whereis[pAvalot]:=dna.room;

 alive:=true;

 objectlist;

 if HoldTheDawn then
 begin
  HoldTheDawn:=false;
  dawn;
 end;
end;

procedure back_to_bootstrap(what:byte);
var
 fv:byte;
 here:word;
 sund:sundry;
begin
 mem[Storage_SEG:Storage_OFS]:=what; { Save the operation code. }
 TO_Sundry(sund); { Save the sundry information. }

 { Save the DNA, times and sequencer info: }
 move(dna,mem[Storage_SEG:Storage_OFS+3],sizeof(dna));
 move(times,mem[Storage_SEG:Storage_OFS+3+sizeof(dna)],sizeof(times));
 move(seq,mem[Storage_SEG:Storage_OFS+3+sizeof(dna)+sizeof(times)],
                                                 sizeof(seq));
 move(sund,
   mem[Storage_SEG:Storage_OFS+3+sizeof(dna)+sizeof(times)+sizeof(seq)],
                                                     sizeof(sund));

 here:=Storage_OFS+3+sizeof(dna)+sizeof(times)+sizeof(seq)+sizeof(sund);

 for fv:=1 to numtr do
  with tr[fv] do
   if quick then
   begin
    mem[Storage_SEG:here]:=fv; inc(here);
    save_data_to_mem(here);
   end;
  mem[Storage_SEG:here]:=177;

 halt(77); { Code to return to the Bootstrap. }
end;

function there_was_a_problem:boolean;
begin
 there_was_a_problem:=bug;
end;

end.