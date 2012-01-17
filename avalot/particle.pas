program particle;
uses Graph,Crt;
{$R+}

type
 fonttype = array[#0..#255,0..15] of byte;

 markertype = record
               length:word;
               offset:longint;
               checksum:byte;
              end;

var
 rawname:string;
 buffer,was:array[0..1999] of char;
 bufpos,bufsize:word;
 font:fonttype;
 cpos:integer;
 r:char;
 ok:boolean;

const
 marker = #27;

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
 gd:=3; gm:=1; initgraph(gd,gm,'c:\bp\bgi');
 assign(fontfile,'c:\thomas\lanche.fnt');
 reset(fontfile); read(fontfile,font); close(fontfile);
end;

procedure helpscreen;
var
 temp:array[0..1999] of char;
 l,fv:byte;
 r:char;
  procedure addon(b:char; st:string);
  begin;
   buffer[3+80*l]:=b; dec(b,64);
   buffer[5+80*l]:=b;
   move(st[1],buffer[7+80*l],length(st));
   inc(l);
  end;
begin;
 l:=0; move(buffer,temp,2000); fillchar(buffer,sizeof(buffer),#0);
 addon('B','Bubble');
 addon('C','Centre text');
 addon('D','Don''t add '^P' (at end)');
 addon('F','Italic Font');
 addon('G','Bell');
 addon('H','Not allocated (=backspace)');
 addon('I','Not allocated (=tab)');
 addon('L','Left-justify text');
 addon('K','Keyboard input');
 addon('M','Carriage return (same as '^m' key)');
 addon('P','Scroll (Paragraph break)');
 addon('Q','Yes/no scroll (question)');
 addon('R','Roman font');
 addon('S','Fix to sprite');
 addon('U','Money (in œsd format)');
 addon('V','View icon (number from ^S)');
 show; repeat r:=readkey until not keypressed;
 cleardevice;
 fillchar(was,sizeof(was),#0); move(temp,buffer,2000); show;
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
 bufpos:=0;
 fillchar(was,sizeof(was),#0); show;
 repeat
  cursor; r:=readkey; cursor;
  case r of
   #0: case readkey of { extd keystrokes }
        'K': if bufpos>0    then begin; dec(bufpos); xy; end; { Left }
        'M': if bufpos<bufsize then begin; inc(bufpos); xy; end; { Right }
        'H': if bufpos>80   then begin; dec(bufpos,80); xy; end; { Up }
        'P': if bufpos<bufsize-79 then begin; inc(bufpos,80); xy; end; { Down }
        's': if bufpos>10 then begin; dec(bufpos,10); xy; end;
        't': if bufpos<bufsize-10 then begin; inc(bufpos,10); xy; end;
        'G': begin; bufpos:=0; xy; end; { Home }
        'O': begin; bufpos:=bufsize; xy; end; { End }
        'S': if bufpos<bufsize then begin; { Del }
              move(buffer[bufpos+1],buffer[bufpos],1999-bufpos); show;
             end;
        ';': helpscreen;
        'A': legit(#239); { copyright symbol }
        'B': legit(#145); { uppercase AE }
        'C': legit(#146); { lowercase AE }
       end;
   #8: if bufpos>0 then begin; { backspace }
        dec(bufpos);
        move(buffer[bufpos+1],buffer[bufpos],1999-bufpos);
        show;
       end;
   #27: begin;
         restorecrtmode;
         exit;
        end; { end of editing }
  else legit(r);
  end;
  sizeup;
 until false;
end;

procedure loadit;
var f:file;
begin;
 if pos('.',rawname)=0 then rawname:=rawname+'.raw';
 fillchar(buffer,sizeof(buffer),#0);
 {$I-}
 assign(f,rawname);
 reset(f,1);
 if ioresult<>0 then
 begin;
  writeln(#7+'New file!'+#7);
  buffer[0]:=marker;
  exit;
 end;
 bufsize:=filesize(f);
 blockread(f,buffer,bufsize);
 close(f);
 while buffer[bufsize]=#0 do dec(bufsize);
 if buffer[bufsize]<>marker then
 begin; { add on a marker }
  inc(bufsize);
  buffer[bufsize]:=marker;
 end;
end;

procedure saveit;
var f:file;
begin;
 writeln('Saving ',rawname,', ',bufsize,' bytes...');
 assign(f,rawname); rewrite(f,1);
 blockwrite(f,buffer,bufsize);
 close(f);
end;

begin;
 write('Filename of .RAW file?'); readln(rawname);
 loadit;
 ok:=false;
 repeat
  graphics;
  edit_it;
  writeln('Now what?');
  writeln;
  writeln(' Filename: ',rawname);
  writeln(' Size of text: ',bufsize);
  writeln(' Cursor position: ',bufpos);
  writeln;
  writeln(' C) Cancel this & continue edit');
  writeln(' S) Save under current name');
  writeln(' A) Save under a different name');
  writeln(' X) Exit & lose all changes.');
  writeln;
  writeln('Pick one!');
  repeat r:=upcase(readkey) until r in ['C','S','A','X'];
  case r of
   'X': ok:=true;
   'S': begin; saveit; halt; end;
  end;
 until ok;
end.