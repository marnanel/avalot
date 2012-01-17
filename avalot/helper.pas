{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 HELPER           The help system unit. }

unit helper;

interface

uses Graph,Gyro;

procedure boot_help;

implementation

uses Crt,Lucerna,Pingo;

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
 highlight_was:byte;

procedure plot_button(y:integer; which:byte);
var
 f:file;
 p:pointer;
begin
 if y>200 then
  begin background(2); delay(10); background(0); exit end; { Silly buttons. }
 getmem(p,buttonsize);
 assign(f,'buttons.avd');
 reset(f,1);
 seek(f,which*buttonsize);
 blockread(f,p^,buttonsize);

 if y=-177 then
   putimage(229,5,p^,0)
 else
   putimage(470,y,p^,0);
 close(f);
 freemem(p,buttonsize);
end;

procedure getme(which:byte); { Help icons are 80x20 }
var
 x:string;
 f:file;
 y,fv:byte;
 offset:word;

  procedure chalk(y:byte; z:string);
  begin
   outtextxy(16,41+y*10,z);
  end;

  procedure getline(var x:string);
  var fz:byte;
  begin
   blockread(f,x[0],1);
   blockread(f,x[1],byte(x[0]));
   for fz:=1 to length(x) do
     x[fz]:=chr(ord(x[fz]) xor 177);
  end;

begin
 off;
 assign(f,'help.avd');
 y:=0;
 highlight_was:=177; { Forget where the highlight was. }
 reset(f,1);
 seek(f,which*2);
 blockread(f,offset,2);
 seek(f,offset);

 getline(x);
 setfillstyle(1,1); bar(0,0,640,200);
 setfillstyle(1,15); bar(8,40,450,200);
 settextjustify(2,2);
 blockread(f,fv,1);
 plot_button(-177,fv);

 setcolor(0); outtextxy(629,26,x);  { Plot the title. }
 setcolor(3); outtextxy(630,25,x);

 settextjustify(0,2); settextstyle(0,0,2);
 setcolor(0); outtextxy(549,1,'help!');
 setcolor(3); outtextxy(550,0,'help!');
 (***) settextstyle(0,0,1);

 repeat
  getline(x);
  if x='!' then break; { End of the help text is signalled with a !. }
  if x[1]='\' then
  begin
   setcolor(4);
   chalk(y,copy(x,2,255));
  end else
  begin
   setcolor(0);
   chalk(y,x);
  end;
  inc(y);
 until false;

 { We are now at the end of the text. Next we must read the icons. }

 y:=0; settextjustify(1,1); settextstyle(0,0,2);
 while not eof(f) do
 begin
  inc(y);
  blockread(f,buttons[y].trigger,1);
  if buttons[y].trigger=#177 then break;
  blockread(f,fv,1);
  if buttons[y].trigger<>#0 then plot_button(13+y*27,fv);
  blockread(f,buttons[y].whither,1); { this is the position to jump to }


  case buttons[y].trigger of
    'þ' : x:='Esc';
    'Ö' : x:=#24;
    'Ø' : x:=#25;
  else
   x:=buttons[y].trigger;
  end;
  setcolor(0); outtextxy(589,26+y*27,x);
  setcolor(3); outtextxy(590,25+y*27,x);

 end;

 settextjustify(0,2); settextstyle(0,0,1);
 close(f); on;
end;


function check_mouse:byte; { Returns clicked-on button, or 0 if none. }
  procedure light(which,colour:byte);
  begin
   if which=177 then exit; { Dummy value for "no button at all". }
   setcolor(colour); which:=which and 31;
   rectangle(466,11+which*27,555,35+which*27);
  end;
var h_is:byte;
begin
  check;

  if mrelease<>0 then
  begin { Clicked *somewhere*... }
     if (mx<470) or (mx>550) or (((my-13) mod 27)>20) then
       check_mouse:=0 else
     { Clicked on a button. }
       check_mouse:=((my-13) div 27);
  end else
  begin
    if (mx>470) and (mx<=550) and (((my-13) mod 27)<=20) then
    begin  { No click, so highlight. }
      h_is:=(my-13) div 27;
      if (h_is<1) or (h_is>6) then h_is:=177; { In case of silly values. }
    end else h_is:=177;

    if (h_is<>177) and (keystatus and 1>0) then inc(h_is,32);

    if (h_is<>highlight_was) then
    begin
      off;
      light(highlight_was,1);
      highlight_was:=h_is;
      if (buttons[h_is and 31].trigger<>#0) then
      begin
        if h_is>31 then light(h_is,11) else light(h_is,9);
      end;
      on;
    end;

    check_mouse:=0;
  end;
end;

procedure continue_help;
var
 r:char;
 fv:byte;
begin
 repeat
  while not keypressed do
  begin
   fv:=check_mouse;

   if (fv>0) then
    case buttons[fv].trigger of
     #0: {null};
     #254: exit;
     else begin
            dusk;
            getme(buttons[fv].whither);
            dawn;
            continue;
          end;
    end;

  end;
  r:=upcase(readkey);
  case r of
   #27 : exit;
   #0  : case readkey of
          #72,#73: r:='Ö';
          #80,#81: r:='Ø';
          #59: r:='H'; { Help on help }
          else continue;
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
var groi:byte;
begin
 dusk;
 off;
 OnCanDoPageSwap:=false; highlight_was:=177;
 copypage(3,1-cp); { Store old screen. } groi:=getpixel(0,0);

 { Set up mouse. }
 off_virtual;
 newpointer(2);
 setactivepage(3); setvisualpage(3);

 getme(0);
 dawn;

 newpointer(9); on;
 mousepage(3);

 continue_help;

 mousepage(cp);
 dusk; off;
 OnCanDoPageSwap:=true;
 copypage(1-cp,3); { Restore old screen. } groi:=getpixel(0,0);
 on_Virtual; dawn; fix_flashers;

 setvisualpage(cp);
 setactivepage(1-cp);
end;

end.