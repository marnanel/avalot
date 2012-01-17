program help;
uses Graph,Rodent,Crt;
type cursor = graphcursmasktype;
const
 vernum= 'v1ù00';
 copyright = '1992';
 questionmark : cursor =
 ( Mask:
     ((511,1023,2047,31,15,8199,32647,65415,63503,61471,61503,61695,63999,63999,61695,61695),
      (65024,33792,34816,34784,40976,57224,32840,72,1936,2080,2496,2304,1536,1536,2304,3840));
   Horzhotspot: 0;
   Verthotspot: 0);

 topics : array[1..7] of string[12] =
  ('Front page','Background','Toolbar','Menus',
   'Keyboard','Shareware','Exit Help');

 keys : array[1..6] of char = 'FBTMKS';

var
 page:byte;
 dp,dark:palettetype;
 r:char;
 lmo:boolean;

procedure hilight(x,y:integer; c1,c2:byte; z:string);
var w:string;
begin;
 w:=z; w[1]:=#32; setcolor(c1); outtextxy(x,y,w);
 w:=z; fillchar(w[2],length(z)-1,#32); setcolor(c2);
 outtextxy(x,y,w); outtextxy(x-1,y,w);
end;

procedure showpage(x:byte);
begin;
 if x=page then exit; { twit }
 if x=7 then begin; lmo:=true; exit; end;
 setallpalette(dark); hidemousecursor; settextjustify(1,1);
 if page<>177 then
 begin;
  setfillstyle(1,1);  bar(507,page*25+2,607,page*25+22);
  setfillstyle(1,9);  bar(500,page*25,600,page*25+20);
(*  setcolor(11); outtextxy(550,page*25+10,topics[page]);*)
  hilight(550,page*25+10,11,14,topics[page]);
 end;
 page:=x;
  setfillstyle(1,4);  bar(507,page*25+2,607,page*25+22);
  setfillstyle(1,12); bar(500,page*25,600,page*25+20);
(*  setcolor(14); outtextxy(550,page*25+10,topics[page]); *)
  hilight(550,page*25+10,14,15,topics[page]);
 setfillstyle(1,7); bar(0,27,470,189); settextjustify(0,2); setcolor(1);
 case page of
  1: begin; { Front page }
      setcolor(black);
      outtextxy( 10, 40,'Thorsoft of Letchworth presents');
      outtextxy(300, 80,vernum);
      outtextxy( 10, 90,'(c) '+copyright+', Mike, Mark and Thomas Thurman.');
      setcolor(red);
      outtextxy(100,129,'Finding your way around it...');
      setcolor(blue);
      outtextxy( 10,120,'You are now using the Help System.');
      outtextxy( 10,138,'Press the first letter of the topic that you want to');
      outtextxy( 10,147,'read (eg T for (T)oolbar), or click on its button (on');
      outtextxy( 10,156,'the right) using the mouse. Use "Exit Help" to quit.');
      outtextxy( 10,174,'(Fastest exit- just hit Esc!)');
     end;
  2: begin; { Background }
      setcolor(red);
      outtextxy(300, 30,'Remember this chap?');
      setcolor(blue);
      outtextxy( 10, 55,'Back in good old A.D. 79, there lived a Roman');
      outtextxy( 10, 64,'whose name was Denarius Avaricius Sextus, known');
      outtextxy( 10, 73,'to his friends as Avvy. His wife was called Arkata,');
      outtextxy( 10, 82,'and he had a slave named Crapulus. His grandson');
      outtextxy( 10, 91,'joined the army, was posted to Gaul, and liked it');
      outtextxy( 10,100,'so much that he stayed there, telling everyone the');
      outtextxy( 10,109,'one about the centurion and the Turkish bath. His');
      outtextxy( 10,118,'thirty-sixth male-line descendant accidentally');
      outtextxy( 10,127,'poisoned an old enemy of William of Normandy, and');
      outtextxy( 10,136,'to his great surprise came so much into Bill''s favour');
      outtextxy( 10,145,'that, after the Battle of Hastings a few years');
      outtextxy( 10,154,'later, he was made the lord of a small town in');
      outtextxy( 10,163,'Hertfordshire called Argent. It is his great-grandson');
      outtextxy( 10,172,'who stars in this game, back in good old A.D. 1189.');
     end;
  3: begin; { ? }
      outtextxy( 15, 30,'The Toolbar is there so that (along with the menus)');
      outtextxy( 15, 39,'you can perform a lot of the functions contained in');
      outtextxy( 15, 48,'the game, using the mouse.');
      Setcolor(Red);
      outtextxy( 15, 66,'COMPASS:');
      Setcolor(Blue);
      outtextxy( 90, 66,'Used to point Avvy in the right direction.');
      SetColor(Red);
      outtextxy( 15, 75,'THINKS:');
      Setcolor(Blue);
      outtextxy( 90, 75,'Shows the person/object you''re thinking of.');
      SetColor(Red);
      outtextxy( 15, 84,'SCORE:');
      Setcolor(Blue);
      outtextxy( 90, 84,'Shows how many points you''ve got.');
      SetColor(Red);
      outtextxy( 15, 93,'SPEED:');
      SetColor(Blue);
      outtextXY( 90, 93,'Adjusts the speed of the game.');
      Setcolor(Red);
      outtextxy( 15,102,'L.E.D.s:');
      Setcolor(Blue);
      outtextXY( 90,102,'Shows whether sound is on (toggle with <F2>),');
      outtextxy( 90,111,'the computer is ready, or there is an error.');
      SetColor(Red);
      outtextXY( 15,120,'CLOCK:');
      SetColor(Blue);
      outtextXY( 90,120,'Shows the time.');
      SetColor(Red);
      outtextxy( 15,129,'''OK'' box:');
      SetColor(Blue);
      outtextxy( 90,129,'Works the same as pressing <ENTER>.');
      SetColor(0);
      outtextxy( 15,147,'N.B. The game action is suspended while you are');
      outtextxy( 15,156,'using the toolbar.');
     end;
  4: begin; { menus }
      outtextxy( 15, 60,'To use the drop-down menus, either click on the bar');
      outtextxy( 15, 69,'at the top with the mouse, or press Alt and the first');
      outtextxy( 15, 78,'letter of the menu''s name (eg alt-A = (A)ction.) The '+#3);
      outtextxy( 15, 87,'menu is alt-H, for (H)eart.');
      outtextxy( 15,105,'When you have a menu, either click on the option you');
      outtextxy( 15,114,'want, or press its initial letter (eg O for "OS Shell").');
      outtextxy( 15,132,'To do something to, or with, an object or person, first');
      outtextxy( 15,141,'select them (or it) from the People or Things menu. Then');
      outtextxy( 15,150,'select whatever you wanted to do from the Use menu.');
      setcolor(red);
      outtextxy(15,177,'(OK, so it sounds complicated, but then it''s intuitive!)');
     end;
  5: begin; { Keyboard }
      outtextxy(15, 60,'The keyboard interface is even simpler than the mouse');
      outtextxy(15, 70,'interface! Just type what you want Avvy to do.');
      outtextxy(15, 80,'For example, to open a door, type in:');
      setcolor(red); outtextxy(100,95,'open door'); setcolor(blue);
      outtextxy(15,110,'And to look at Crapulus, type:');
      setcolor(red); outtextxy(100,125,'look at Crapulus');
      setcolor(blue); outtextxy(15,140,'(Don''t forget to press Enter after each command!)');
      outtextxy(15,160,'This is a traditional command-line parser interface,');
      outtextxy(15,170,'similar to the one in "Avaricius", only more advanced.');
     end;
  6: begin; { ? }
      outtextxy(15, 30,'This game is Shareware. Most programs are sold through');
      outtextxy(15, 40,'shops, and the authors prevent you from copying them.');
      outtextxy(15, 50,'Shareware is different. You may copy it and give it to');
      outtextxy(15, 60,'ANYBODY at all. You may post it on any BBS, give it to');
      outtextxy(15, 70,'friends, etc. If you like it, we ask you to pay us for');
      outtextxy(15, 80,'the software directly through the post. We''re relying');
      outtextxy(15, 90,'on you to register!');
      outtextxy(99,177,'{ ETC }');
     end;
  end;
 setallpalette(dp); showmousecursor;
end;

procedure helpsetup;
var gd,gm:integer;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi'); settextstyle(1,0,0); setcolor(11);
 getpalette(dp); dark.size:=dp.size; fillchar(dark.colors,dark.size,#0);
 setallpalette(dark); setusercharsize(3,1,8,10);
 for gm:=1 to 3 do outtextxy(gm,0,'Avalot- HELP!');
 resetmouse; setgraphicscursor(questionmark); showmousecursor;
 settextstyle(0,0,1); settextjustify(1,1);
 for gd:=2 to 7 do
 begin;
  setfillstyle(1,1);  bar(507,gd*25+2,607,gd*25+22);
  setfillstyle(1,9);  bar(500,gd*25,600,gd*25+20);
(*  setcolor(11); outtextxy(550,gd*25+10,topics[gd]); *)
  hilight(550,gd*25+10,11,14,topics[gd]);
 end;
 showmousecursor;
 page:=177; showpage(1); lmo:=false; setfillstyle(1,7);
 for gd:=1 to 3 do
 begin;
  bar( 10-gd*3,200-gd*3,490-gd*6,200-gd*3);
  bar(490-gd*6, 37-gd*3,491-gd*6,200-gd*3);
 end;
end;

begin;
 helpsetup;
 repeat
  repeat getbuttonstatus until (mkey=left) or keypressed;
  if keypressed then
  begin; { keyboard choice }
   r:=upcase(readkey);
   if pos(r,keys)>0 then showpage(pos(r,keys)) else
    if r=#0 then
    case readkey of { grab extd keystroke }
     'H': if page>1 then showpage(page-1);
     'P': if page<6 then showpage(page+1);
     'G','I': showpage(1);
     'O','Q': showpage(6);
    end else
     if r in [#27,'Q','X','E','H'] then lmo:=true; { quit }
  end
  else
  begin; { mouse choice }
   if (mousex>400) and (mousey>25) then
   begin;
    showpage(mousey div 25);
   end;
  end;
 until lmo;
end.