program sezeditor;
{$M 65520,0,655360}
uses Crt,Graph;

const
 marker = #27;
 game = 'Avalot';

type
 fonttype = array[#0..#255,0..15] of byte;

 markertype = record
               length:word;
               offset:longint;
               checksum:byte;
              end;

 sezheader = record
              initials:array[1..2] of char; { should be "TT" }
              gamecode:word;
              revision:word; { as 3- or 4-digit code (eg v1.00 = 100) }
              chains:longint; { number of scroll chains }
              size:longint; { total size of all chains }
             end;

var
 buffer,was:array[0..1999] of char;
 bufpos,bufsize:word;
 chainnum:longint;
 nickname:string[40];
 junk:array[1..255] of char;
 temp:string;
 r:char;
 font:fonttype;
 cpos:integer;
 sezhead:sezheader;
 f,tempf:file;
 nicknames:text;

function sumup:byte;
var fv:word; total:byte;
begin;
 total:=0;
 for fv:=0 to bufsize-1 do
 begin;
  inc(total,ord(was[fv]));
 end;
 sumup:=total;
end;

function findname(which:longint):string;
var x:string; q:string[10];
begin;
 str(which,q);
 reset(nicknames);
 repeat readln(nicknames,x) until x='{go}';
 repeat
  readln(nicknames,x)
 until pos(q,x)>0;
 if eof(nicknames) then
 begin;
  findname:='noname';
 end else
 begin;
  delete(x,1,3); { lose "{__" }
  delete(x,pos(' ',x),255); { lose all chars after first space }
  findname:=x;
 end;
 close(nicknames);
end;

procedure cursor;
var fv:byte;
begin;
 for fv:=12 to 15 do
  mem[$A000:cpos+fv*80]:=not(mem[$A000:cpos+fv*80]);
end;

procedure xy;
begin;
 cpos:=(bufpos div 80)*1280+(bufpos mod 80);
end;

procedure show;
var fv,orig,y:word;
begin;
 for fv:=0 to 1999 do
  if buffer[fv]<>was[fv] then
  begin;
   orig:=(fv div 80)*1280+(fv mod 80);
   for y:=0 to 15 do
    mem[$A000:orig+y*80]:=byte(font[buffer[fv],y]);
  end;
 xy;
 move(buffer,was,sizeof(buffer));
end;

procedure sizeup;
begin;
 repeat
  case buffer[bufsize] of
   marker: exit; { we've found it OK! }
   #0: dec(bufsize);
   else inc(bufsize);
  end;
 until false;
end;

procedure graphics;
var
 gd,gm:integer;
 fontfile:file of fonttype;
begin;
 gd:=3; gm:=1; initgraph(gd,gm,'');
 assign(fontfile,'c:\thomas\lanche.fnt');
 reset(fontfile); read(fontfile,font); close(fontfile);
end;

procedure edit_it;
  procedure legit(r:char);
  begin; { it's a legit keystroke }
   move(buffer[bufpos],buffer[bufpos+1],1999-bufpos);
   buffer[bufpos]:=r;
   inc(bufpos); show;
  end;
var fv:byte;
begin;
 for fv:=1 to bufsize do dec(buffer[fv],byte(177*bufsize));
 fillchar(was,sizeof(was),#0); show;
 repeat
  cursor; r:=readkey; cursor;
  case r of
   #0: case readkey of { extd keystrokes }
        'K': if bufpos>0    then begin; dec(bufpos); xy; end; { Left }
        'M': if bufpos<bufsize then begin; inc(bufpos); xy; end; { Right }
        'H': if bufpos>80   then begin; dec(bufpos,80); xy; end; { Up }
        'P': if bufpos<bufsize-79 then begin; inc(bufpos,80); xy; end; { Down }
        'G': begin; bufpos:=0; xy; end; { Home }
        'O': begin; bufpos:=bufsize; xy; end; { End }
        'S': begin; { Del }
              move(buffer[bufpos+1],buffer[bufpos],1999-bufpos); show;
             end;
        'A': legit(#239); { copyright symbol }
       end;
   #8: if bufpos>0 then begin; { backspace }
        dec(bufpos);
        move(buffer[bufpos+1],buffer[bufpos],1999-bufpos);
        show;
       end;
   #27: begin;
         for fv:=1 to bufsize do inc(buffer[fv],byte(177*bufsize));
         restorecrtmode;
         exit;
        end; { end of editing }
  else legit(r);
  end;
  sizeup;
 until false;
end;

procedure saveit(ourchain:longint; oldsize,newsize:word);
var
 buffer:array[1..17777] of byte;
 numread,numwritten,total:word;
 check:char;
 fv:word;
 m:markertype;
 sizechange:integer; { so's it can be +ve or -ve }
 wheresit:longint; { "offset" value for "ourchain" }
begin;
 assign(tempf,'sez.tmp');
 { OK, here goes... }
 sezhead.size:=sezhead.size-oldsize+newsize; { adjust our size }
 sizechange:=newsize-oldsize; { +ve if bigger, -ve if smaller, 0 if same }
 textattr:=27;

 rewrite(tempf,1); reset(f,1);
 seek(f,255+sizeof(sezhead)); { bypass the junk & sezhead (they're in RAM) }

 blockwrite(tempf,junk,255); { move the junk... }
 blockwrite(tempf,sezhead,sizeof(sezhead)); { and the header to new files }

 { Now to move the markers }
 writeln('Moving markers...');
 for fv:=1 to sezhead.chains do
 begin;
  write(fv,#13);
  blockread(f,m,sizeof(m));
  if fv=ourchain then { Right, this one's ours! }
  with m do begin;
   wheresit:=offset; { recorded for later }
   length:=newsize-1;
   checksum:=sumup;
  end else
   if fv>ourchain then
   begin; { After ours- its offset will have to be changed... }
    m.offset:=m.offset+sizechange;
   end; { Otherwise, before ours- leave it well alone }
  blockwrite(tempf,m,sizeof(m));
 end;
 writeln('Done OK.');

 { Right, that's the markers done... thank goodness... now it's just the
   chains themselves! }

 total:=0;

 writeln('Updating the chains...');
 while total<=wheresit do
 begin;
  blockread(f,buffer,1,numread);
  blockwrite(tempf,buffer,numread,numwritten);
  write('.');
  inc(total,numwritten);
 end;
 writeln; writeln('Updating our chain...');
 { We're now in the right place (at last...) }
 for fv:=0 to (bufsize-1) do inc(was[fv],3+177*fv*(bufsize-1)); { scramble "was" }
 blockwrite(tempf,was,newsize); { "was" contains what the values *were* }
 seek(f,filepos(f)+oldsize);
 writeln; writeln('Copying everything else...');
 while not eof(f) do { high-speed copy }
 begin;
  blockread(f,buffer,17777,numread);
  blockwrite(tempf,buffer,numread);
  write('.');
 end;
 writeln;

 { Closedown }
 close(f); close(tempf);
 erase(f); rename(tempf,game+'.SEZ');
end;

procedure particular;
var origsize:word;
begin;
 bufsize:=0;
 write('Which one? (? for a list)'); readln(chainnum);
 if (chainnum<0) or (chainnum>sezhead.chains) then
 begin;
  writeln('Don''t be silly!'); exit;
 end;

 origsize:=0{bufsize}; bufpos:=0; cpos:=0; nickname:=findname(chainnum);
 fillchar(buffer,sizeof(buffer),#0);
 buffer[0]:=marker;
 repeat
  textattr:=30; writeln;
  writeln('SEZ EDITOR (c) 1992, Thomas Thurman.');
  writeln;
  writeln('Editing scrollchain no.',chainnum);
  writeln('Your text is ',bufsize,' bytes long.');
  writeln;
  writeln('Its nickname is "',nickname,'".');
  writeln;
  writeln('Enter a command:');
  writeln('  S) Save the text to disk,');
  writeln('  E) Edit this particular chain,');
  writeln('  N) change the Nickname,');
  writeln('  R) Revert text to the original,');
  writeln('Esc) Exit and do something else!');
  writeln;
  write('Your choice? ');
  r:=upcase(readkey); writeln(r);
  case r of
   'N': begin;
         writeln; write('New nickname (max 40 chars, Enter to cancel)?');
         readln(temp);
         if temp<>'' then nickname:=temp;
        end;
   'E': begin; setgraphmode(1); edit_it; end;
   'S': saveit(chainnum,origsize,bufsize);
   #27: exit;
  end;
 until false;
end;

procedure titles;
const
 title : string[7] = 'SEZedit';
var
 fv:byte; r:char;
begin;
 settextstyle(1,0,0);
 for fv:=7 downto 1 do
 begin;
  setcolor(fv*2);
  setusercharsize(8-fv,1,8-fv,1);
  outtextxy(fv*65,fv*40-30,title[fv]);
 end;
 setusercharsize(17,7,1,1); setcolor(green);
 outtextxy(300,10,'Thorsoft');
 outtextxy(10,310,'Press any key...');
 repeat r:=readkey until not keypressed;
 restorecrtmode; textattr:=30; clrscr;
end;

procedure addone; { Adds a new, empty chain to the end of the list. }
var
 fv:longint;
 m:markertype;
 buffer:array[1..17777] of byte;
 numread:word;
begin;
 assign(tempf,'sez.tmp');
 textattr:=27;
 rewrite(tempf,1); reset(f,1); { f = AVALOT.SEZ (original file) }
 seek(f,255+sizeof(sezhead));
 inc(sezhead.chains); { we're adding a new chain }

 blockwrite(tempf,junk,255); { move the junk }
 blockwrite(tempf,sezhead,sizeof(sezhead)); { move the header }

 { Now to move the markers }
 writeln('Moving markers...');
 for fv:=1 to sezhead.chains-1 do { -1 because we've added 1 to it }
 begin;
  write(fv,#10);
  blockread(f,m,sizeof(m));
  blockwrite(tempf,m,sizeof(m));
 end;
 writeln('Done OK.');
 { Now we add a new marker onto the end! }
 with m do
 begin;
  offset:=sezhead.size; { right onto the end }
  length:=0; { it's empty }
 end;
 blockwrite(tempf,m,sizeof(m)); { write it out to disk }

 { Copy everything else... including the #177 check char }
 writeln('Copying everything else over...');
 while not eof(f) do
 begin;
  blockread(f,buffer,17777,numread);
  blockwrite(tempf,buffer,numread);
  write('.');
 end;
 writeln;
 close(f); close(tempf);
 erase(f); rename(tempf,game+'.SEZ');
end;

procedure general;
var r:char;
begin;
 repeat
  textattr:=31;
  writeln; writeln(game+'.SEZ');
  writeln;
  writeln('No. of chains: ',sezhead.chains);
  writeln;
  writeln('Choose one of these:');
  writeln('  A) Add a new scrollchain');
  writeln('  E) Edit one');
  writeln('Esc) Exit');
  writeln;
  write('Your choice? ');
  r:=upcase(readkey); writeln(r);
  case r of
   'A': addone;
   'E': particular;
   #27: halt;
  end;
 until false;
end;

procedure loadit;
begin;
 reset(f,1);
 blockread(f,junk,255);
 blockread(f,sezhead,sizeof(sezhead));
 close(f);
end;

begin;
 assign(f,game+'.SEZ');
 assign(tempf,'sez.tmp');
 assign(nicknames,game+'.NIK');
 loadit;
 graphics;
 titles;
 general;
end.