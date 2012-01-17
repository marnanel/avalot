{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 HELPER           The help system unit. }

unit helper;

interface

uses Graph,Gyro;

procedure boot_help;

implementation

uses Crt,Lucerna;

type buttontype= record
                  trigger:char;
                  whither:byte;
                 end;

const
 buttonsize = 930;

 toolbar=0; Nim=1; kbd=2; credits=3; joystick=4; troubleshooting=5; story=6;
 mainscreen=7; registering=8; sound=9; mouse=10; filer=11; back2game=12;
 helponhelp=13; pgdn=14; pgup=15;

var
 buttons:array[1..10] of buttontype;

procedure plot_button(y:integer; which:byte);
var
 f:file;
 p:pointer;
begin
 getmem(p,buttonsize);
 assign(f,'buttons.avd');
 reset(f,1);
 seek(f,which*buttonsize);
 blockread(f,p^,buttonsize);
 putimage(470,y,p^,0);
 close(f);
 freemem(p,buttonsize);
end;

procedure getme(which:byte); { Help icons are 80x20 }
var
 x:string;
 t:text;
 y,fv:byte;

  procedure chalk(y:byte; z:string);
  begin
   outtextxy(16,41+y*10,z);
  end;

begin
 str(which,x);
 assign(t,'h'+x+'.raw');
 y:=0;
 reset(t);

 readln(t,x);
 setfillstyle(1,1); bar(0,0,640,200);
 setfillstyle(1,15); bar(8,40,450,200);
 settextjustify(1,1); setcolor(14);
 outtextxy(320,15,x);
 settextjustify(0,2);
 setcolor(3); settextstyle(0,0,2);
 outtextxy(550,0,'help!');
 (***) setcolor(0); settextstyle(0,0,1);

 repeat
  readln(t,x);
  if x='!' then break; { End of the help text is signalled with a !. }
  chalk(y,x);
  inc(y);
 until false;

 { We are now at the end of the text. Next we must read the icons. }

 y:=0; settextjustify(1,1); setcolor(3);
 while not eof(t) do
 begin
  inc(y);
  readln(t,x); { Get the name of this button, and... }
  if x<>'-' then { (hyphen signals an empty button.) }
  begin
   readln(t,buttons[y].trigger);
   readln(t,fv); plot_button(13+y*27,fv);
   readln(t,buttons[y].whither); { this is the position to jump to }

   case buttons[y].trigger of
     '˛' : outtextxy(580,25+y*27,'Esc');
     '÷' : outtextxy(580,25+y*27,#24);
     'ÿ' : outtextxy(580,25+y*27,#25);
   else
    outtextxy(580,25+y*27,buttons[y].trigger);
   end;

  end else buttons[y].trigger:=#0;
 end;

 settextjustify(0,2);
 close(t);
end;

procedure continue_help;
var
 r:char;
 fv:byte;
begin
 repeat
  r:=upcase(readkey);
  case r of
   #27 : exit;
   #0  : case readkey of
          #72,#73: r:='÷';
          #80,#81: r:='ÿ';
          #59: r:='H'; { Help on help }
         end;
  end;

  for fv:=1 to 10 do
   with buttons[fv] do
    if trigger=r then
    begin
     dusk;
     getme(whither);
     dawn;
     break;
    end;

 until false;
end;

procedure boot_help;
begin
 setactivepage(2);

 getme(0);

 dusk;
 setvisualpage(2);
 dawn;

 continue_help;

 dusk;
 setvisualpage(cp);
 draw_also_lines;
 setactivepage(1-cp);
 dawn;
end;

end.