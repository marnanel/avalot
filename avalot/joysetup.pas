program joysticksetup; { Avalot joystick setup routines. To be incorporated
                         into Setup2 whenever I get a chance. }
uses Joystick, { DBH's routines } Crt;

type
 JoySetup = record
             xmid,ymid,xmin,ymin,xmax,ymax:word;
             centre:byte; { Size of centre in tenths }
            end;

var
 js:joysetup;
 jf:file of joysetup;

function detect:boolean;
var
 x,y,xo,yo:word;
 count:byte;
begin;
 count:=0;
 if joystickpresent then
 begin;
  detect:=true;
  exit;
 end;
 readjoya(xo,yo);
 repeat
  if count<7 then inc(count); { Take advantage of "flutter" }
  if count=6 then
  begin;
   writeln('The Bios says you don''t have a joystick. However, it''s often wrong');
   writeln('about such matters. So, do you? If you do, move joystick A to');
   writeln('continue. If you don''t, press any key to cancel.');
  end;
  readjoya(x,y);
 until (keypressed) or (x<>xo) or (y<>yo);
 detect:=not keypressed;
end;

procedure display;
begin;
 with js do
 begin;
  gotoxy(20,10); write('X min: ',xmin,'  ');
  gotoxy(20,11); write('X max: ',xmax,'  ');
  gotoxy(20,12); write('Y min: ',ymin,'  ');
  gotoxy(20,13); write('Y max: ',ymax,'  ');
 end;
end;

procedure getmaxmin;
var x,y:word;
begin;
 writeln('Rotate the joystick around in a circle, as far from the centre as it');
 writeln('can get. Then click a button.');
 with js do
 begin;
  xmax:=0; xmin:=maxint;
  ymax:=0; ymin:=maxint;
 end;
 repeat
  readjoya(x,y);
  with js do
  begin;
   if x<xmin then xmin:=x;
   if y<ymin then ymin:=y;
   if x>xmax then xmax:=x;
   if y>ymax then ymax:=y;
   display;
  end;
 until (buttona1 or buttona2);
 repeat until not (buttona1 or buttona2);
 writeln;
 writeln('Thank you. Now please centre your joystick and hit a button.');
 repeat until (buttona1 or buttona2);
 with js do readjoya(xmid,ymid);
end;

begin;
 textattr:=2;
 clrscr;
 writeln('Avalot joystick setup routine- by TT. Thanks go to David B. Howorth.');
 writeln;
 if detect then writeln('You''ve got a joystick!') else exit;
 getmaxmin;
 repeat
  write('Centring factor? (3-9)');
  readln(js.centre);
 until js.centre in [1..9];
 assign(jf,'v:joytmp.dat');
 rewrite(jf); write(jf,js); close(jf); { write it all out to disk. }
end.