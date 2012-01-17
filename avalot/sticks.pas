{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 STICKS           The joystick handler. }

unit Sticks;

interface

uses Joystick, { David B. Howorth's joystick handling routines }
     Acci,     { for doing verbs with the buttons }
     Gyro;     { for solidarity }

function joyway:byte;
procedure joykeys;

implementation

type
 lmc = (l,m,r); { Left, middle & right }

var
 jf:file of joysetup;

function joyway:byte;
var
 x,y:word;
 xx,yy:lmc;

  function getlmc(n,max,min:word):lmc;
  begin;
   if n<min then getlmc:=l else
    if n>max then getlmc:=r else
     getlmc:=m;
  end;
begin;
 if not dna.user_moves_Avvy then exit;
 if use_joy_A then readjoya(x,y) else readjoyb(x,y);

 with js do
 begin;
  xx:=getlmc(x,cxmax,cxmin);
  yy:=getlmc(y,cymax,cymin);
 end;

 case xx of
  l: case yy of
      l: joyway:=ul;
      m: joyway:=left;
      r: joyway:=dl;
     end;
  m: case yy of
      l: joyway:=up;
      m: joyway:=stopped;
      r: joyway:=down;
     end;
  r: case yy of
      l: joyway:=ur;
      m: joyway:=right;
      r: joyway:=dr;
     end;
 end;
end;

procedure joykeys;
 { The 2 joystick keys may be reprogrammed. This parses them. }
var v:byte;
begin;
 if use_joy_A then
 begin
   v:=byte(buttona1); inc(v,byte(buttona2)*2);
 end else
 begin
   v:=byte(buttonb1); inc(v,byte(buttonb2)*2);
 end;

 case v of
  0: exit; { No buttons pressed. }
  1: opendoor; { Button 1 pressed: open door. }
(*  2: blip; { Button 2 pressed: nothing (joylock?). }*)
  2,3: lookaround; { Both buttons pressed: look around. }
 end;
end;

end. { No init code. }