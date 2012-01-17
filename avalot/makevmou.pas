program make_vmousecursors;
uses Graph,Squeak,Crt;
{$R+}

type
 mp = record { mouse-pointer }
       mask: array[0..1,0..15] of Word;
       Horzhotspot,verthotspot:integer;
      end;

 vmctype = record { Virtual Mouse Cursor }
            andpic,xorpic:pointer;
            backpic:array [0..1] of pointer;
            wherewas:array [0..1] of PointType;
            picnumber:byte;
            ofsx,ofsy:shortint;
           end;

const
 mps : array[1..9] of arrowtype =
(( Mask: { 1 - up-arrow }
     ((65151,64575,64575,63519,63519,61455,61455,57351,57351,49155,49155,64575,64575,64575,64575,64575),
      (0,384,384,960,960,2016,2016,4080,4080,8184,384,384,384,384,384,0));
   Horzhotspot: 8;
   Verthotspot: 0),

 ( Mask: { 2 - screwdriver }
     ((8191,4095,2047,34815,50175,61951,63743,64543,65039,65031,65027,65281,65408,65472,65505,65523),
      (0,24576,28672,12288,2048,1024,512,256,224,176,216,96,38,10,12,0));
   Horzhotspot: 0;
   Verthotspot: 0),

 ( Mask: { 3 - right-arrow }
     ((65535,65535,64639,64543,7,1,0,1,7,64543,64639,65535,65535,65535,65535,65535),
      (0,0,0,384,480,32760,32766,32760,480,384,0,0,0,0,0,0));
   Horzhotspot: 15;
   Verthotspot: 6),

 ( Mask: { 4 - fletch }
     ((255,511,1023,2047,1023,4607,14591,31871,65031,65283,65281,65280,65280,65409,65473,65511),
      (0,10240,20480,24576,26624,17408,512,256,128,88,32,86,72,20,16,0));
   Horzhotspot: 0;
   Verthotspot: 0),

 ( Mask: { 5 - hourglass }
     ((0,0,0,34785,50115,61455,61455,63519,63519,61839,61455,49155,32769,0,0,0),
      (0,32766,16386,12300,2064,1440,1440,576,576,1056,1440,3024,14316,16386,32766,0));
   Horzhotspot: 8;
   Verthotspot: 7),

 ( Mask: { 6 - TTHand }
     ((62463,57855,57855,57855,57471,49167,32769,0,0,0,0,32768,49152,57344,61441,61443),
      (3072,4608,4608,4608,4992,12912,21070,36937,36873,36865,32769,16385,8193,4097,2050,4092));
   Horzhotspot: 4;
   Verthotspot: 0),

 ( Mask: { 7- Mark's crosshairs }
     ((65535,65151,65151,65151,65151,0,65151,65151,65151,65151,65535,65535,65535,65535,65535,65535),
      (0,384,384,384,384,65535,384,384,384,384,0,0,0,0,0,0));
   Horzhotspot: 8;
   Verthotspot: 5),

 ( Mask: { 8- I-beam. }
     ((65535,65535,63631,63503,63503,65087,65087,65087,65087,65087,63503,63503,63631,65535,65535,65535),
      (0,0,0,864,128,128,128,128,128,128,128,864,0,0,0,0));
   Horzhotspot: 8;
   Verthotspot: 7),

 ( Mask: { 9- Question mark. }
     ((511,1023,2047,31,15,8199,32647,65415,63503,61471,61503,61695,63999,63999,61695,61695),
      (65024,33792,34816,34784,40976,57224,32840,72,1936,2080,2496,2304,1536,1536,2304,3840));
   Horzhotspot: 0;
   Verthotspot: 0));

 mouse_size = 134;

 mice_header : array[1..134] of char =
  'Mouse file copyright (c) 1993. I saw a mouse! Where? SQUEEAAAKK!!! Cheese '+ { 74 }
   'cheese cheese. Cheddar, Stilton, Double Gloucester. Squeak.'+#26; { 60 }

var
 gd,gm:integer;
 a:array[0..50,1..40] of word absolute $A000:0;
 fv:byte;
 vmc:vmctype;
 plot:byte; plx,ply:integer;

function swapbits(a:word):word;
begin;
 swapbits:=lo(a)*256+hi(a);
end;

procedure plot_vmc(xx,yy:integer; page:byte);
begin;
 with vmc do
 begin;
  xx:=xx+ofsx;
  yy:=yy+ofsy;

  getimage(xx,yy,xx+15,yy+15,backpic[page]^);
  putimage(xx,yy,andpic^,andput);
  putimage(xx,yy,xorpic^,xorput);
  with wherewas[page] do
  begin;
   x:=xx;
   y:=yy;
  end;
 end;
end;

procedure wipe_vmc(page:byte);
begin;
 with vmc do
  with wherewas[page] do
   if x<>maxint then
    putimage(x,y,backpic[page]^,0);
end;

procedure setup_vmc;
var fv:byte;
begin;
(* gd:=imagesize(0,0,15,15);*)

 with vmc do
 begin;
  getmem(andpic,mouse_size);
  getmem(xorpic,mouse_size);

  for fv:=0 to 1 do
  begin;
   getmem(backpic[fv],mouse_size);
   wherewas[fv].x:=maxint;
  end;
 end;
end;

procedure show_off_mouse;
begin;

 setcolor(14); settextstyle(0,0,2);

 for gm:=0 to 1 do
 begin;
  setactivepage(gm);
  setfillstyle(1,blue); bar(0,0,getmaxx,getmaxy);
  outtextxy(400,20,chr(48+gm));
 end;

 gd:=0;
 repeat
  setactivepage(gd);
  setvisualpage(1-gd);
  gd:=1-gd;

  delay(56);

  getbuttonstatus;
  wipe_vmc(gd);

  if plot>0 then
  begin;
   putpixel(plx,ply,red);
   dec(plot);
  end;

  plot_vmc(mx,my,gd);

  if (mkey=left) and (plot=0) then
  begin;
   plot:=2;
   plx:=mx;
   ply:=my;
  end;

 until mkey=right;

 for gm:=0 to 1 do
 begin;
  setactivepage(1-gm);
  wipe_vmc(gm);
 end;

 setvisualpage(0);
 setactivepage(0);
end;

procedure grab_cursor(n:byte);
begin;
 getimage(32*n-16, 0,32*n-1,15,vmc.andpic^);
 getimage(32*n-16,20,32*n-1,35,vmc.xorpic^);
end;

procedure save_mice;
var
 f:file;
 fv:byte;
begin;
 assign(f,'v:mice.avd');
 rewrite(f,1);

 blockwrite(f,mice_header,mouse_size);

 for fv:=1 to 9 do
  with vmc do
  begin;
   grab_cursor(fv);
   putimage(100,100,xorpic^,0);
   blockwrite(f,andpic^,mouse_size);
   blockwrite(f,xorpic^,mouse_size);
  end;

 close(f);
end;

procedure load_a_mouse(which:byte);
var f:file;
begin;
 assign(f,'v:mice.avd');
 reset(f,1);
 seek(f,mouse_size*2*(which-1)+134);

 with vmc do
 begin;
  blockread(f,andpic^,mouse_size);
  blockread(f,xorpic^,mouse_size);
  close(f);
  with mps[which] do
  begin;
   ofsx:=-Horzhotspot;
   ofsy:=-Verthotspot;

   setminmaxHorzcurspos(Horzhotspot,624+Horzhotspot);
   setminmaxVertcurspos(Verthotspot,199);
  end;
 end;

end;

procedure draw_mouse_cursors;
begin;
 for fv:=1 to 9 do
  for gm:=0 to 1 do
   for gd:=0 to 15 do
    a[gd+gm*20,fv*2]:=swapbits(mps[fv].mask[gm,gd]);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 resetmouse;
 setup_vmc;

 draw_mouse_cursors;


 save_mice;

(* grab_cursor(3);*)
(* load_a_mouse(4);
 setgraphicscursor(mps[4]);

 show_off_mouse;
 on; repeat getbuttonstatus until mkey=left; off;
 show_off_mouse;*)
end.
