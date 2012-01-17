program textpic;
uses Graph,Crt;
var
 gd,gm:integer;
 f:file;
 aa:array[1..16000] of byte;
 cols:array[0..27,0..35] of byte;
 t:text;
 x:string;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 fillchar(cols,sizeof(cols),#0);
 assign(f,'v:avvypic.ptx');
 reset(f,1);
 blockread(f,aa,filesize(f));
 close(f);
 putimage(0,0,aa,0);
 for gd:=0 to 27 do
  for gm:=0 to 34 do
   cols[gd,gm+1]:=getpixel(gd,gm);

 restorecrtmode;
(*
   asm
      mov ax,$1003
      mov bl,0
      int $10
   end;
*)
 for gm:=0 to 17 do
  for gd:=0 to 27 do
  begin;
   gotoxy(gd+1,gm+1);
   if (cols[gd,2*gm]=cols[gd,2*gm+1]) then
   begin;
    textattr:=cols[gd,2*gm]; write('Û');
   end else
    if (cols[gd,2*gm]>7) and (cols[gd,2*gm+1]<8) then
    begin;
     textattr:=cols[gd,2*gm]+cols[gd,2*gm+1]*16;
     write('ß')
    end else
    begin;
     textattr:=cols[gd,2*gm]*16+cols[gd,2*gm+1];
     if textattr>blink then dec(textattr,blink);
     write('Ü');
    end;
  end;
  gotoxy(23,5); textattr:=red; write('ß');

  assign(t,'v:avalot.txt'); reset(t);
  textattr:=9; gm:=2;
  repeat
   inc(gm);
   readln(t,x);
   gotoxy(30,gm);
   writeln(x);
  until eof(t);

  textattr:=7; gotoxy(35,2); write('Back in good old A.D. ');
  textattr:=15; write('1176'); textattr:=7; write('...');
  textattr:=9; gotoxy(40,4); write('Lord');
  gotoxy(67,9); write('d''Argent');
  textattr:=yellow;
  gotoxy(37,12); write('He''s back...');
  gotoxy(47,14); write('And this time,');
  gotoxy(52,15); write('he''s wearing tights...');
  textattr:=4;
  gotoxy(36,17); write('A Thorsoft of Letchworth game. * Requires EGA');
  gotoxy(38,18); write('and HD. * By Mike, Mark and Thomas Thurman.');
  gotoxy(40,19); write('Sfx archive- ');
  textattr:=9; write('Download ');
  textattr:=14; write('AVLT10.EXE');
  textattr:=9; write(' now!');
  gotoxy(1,1);
  readln;
end.