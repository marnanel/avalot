{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 CELER            The unit for updating the screen pics. }

unit Celer;

interface

uses Closing,Incline,Gyro;

type
 flavourtype = (ch_EGA,ch_BGI);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                   natural:boolean;

                   memorise:boolean; { Hold it in memory? }
                  end;

 memotype = record
             x,y:integer;
             xl,yl:integer;
             flavour:flavourtype;
             size:word;
            end;

var
 offsets:array[1..40] of longint;
 num_chunks:byte;
 memos:array[1..40] of memotype;
 memory:array[1..40] of pointer;

   procedure pics_link;

   procedure load_chunks(xx:string);

   procedure forget_chunks;

   procedure show_one(which:byte);

   procedure show_one_at(which:byte; xxx,yyy:integer);

implementation

uses Graph,Trip5,Lucerna,Crt;

var f:file; { Private variable- not accessible from elsewhere. }

const on_disk = -1; { Value of memos[fv].x when it's not in memory. }

procedure pics_link;
var xx:byte;
begin
 if ddmnow then exit; { No animation when the menus are up. }

 with dna do
  case room of

   r__OutsideArgentPub: begin
    if (roomtime mod 12)=0 then
     show_one(1+(roomtime div 12) mod 4)
   end;

   r__BrummieRoad: if (roomtime mod 2)=0 then
    show_one(1+(roomtime div 2) mod 4);

   r__Bridge: if (roomtime mod 2)=0 then
    show_one(4+(roomtime div 2) mod 4);

   r__Yours: if (not Avvy_is_awake) and ((roomtime mod 4)=0) then
              show_one(1+(roomtime div 12) mod 2);

   r__ArgentPub: begin
                  if ((roomtime mod 7)=1) and (dna.malagauche<>177) then
                  begin { Malagauche cycle }
                   inc(dna.malagauche);
                   case dna.malagauche of
                    1,11,21: show_one(12); { Looks forwards. }
                    8,18,28,32: show_one(11); { Looks at you. }
                    30: show_one(13); { Winks. }
                    33: dna.malagauche:=0;
                   end;
                  end;

                  case (roomtime mod 200) of
                   179,197: show_one(5); { Dogfood's drinking cycle }
                   182,194: show_one(6);
                   185: show_one(7);
                   199: dna.DogfoodPos:=177; { Impossible value for this. }
                   0..178: begin { Normally. }
                            case bearing(2) of{ Bearing of Avvy from Dogfood. }
                              1.. 90,358..360: xx:=3;
                              293..357: xx:=2;
                              271..292: xx:=4;
                            end;
                            if xx<>dna.DogfoodPos then { Only if it's changed.}
                            begin
                             show_one(xx);
                             dna.DogfoodPos:=xx;
                            end;
                           end;
                  end;
                 end;

   r__WestHall: if (roomtime mod 3)=0 then
                 case ((roomtime div 3) mod 6) of
                  4: show_one(1);
                  1,3,5: show_one(2);
                  0,2: show_one(3);
                 end;
   r__LustiesRoom: if not (dna.Lustie_is_asleep) then begin
                    if (roomtime mod 45)>42 then xx:=4 { du Lustie blinks }
                    else
                    case bearing(2) of{ Bearing of Avvy from du Lustie. }
                      0.. 45,315..360: xx:=1; { Middle. }
                       45..180: xx:=2; { Left. }
                      181..314: xx:=3; { Right. }
                    end;
                    if xx<>dna.DogfoodPos then { Only if it's changed.}
                    begin
                     show_one(xx);
                     dna.DogfoodPos:=xx; { We use DogfoodPos here too- why not? }
                    end;
                   end;

   r__AylesOffice: if (not dna.Ayles_is_awake) and (roomtime mod 14=0) then
                   begin
                    case ((roomtime div 14) mod 2) of
                     0: show_one(1); { Frame 2: EGA. }
                     1: show_one(3); { Frame 1: Natural. }
                    end;
                   end;

   r__Robins: if dna.tied_up then
               case (roomtime mod 54) of
                20: show_one(4); { Frame 4: Avalot blinks. }
                23: show_one(2); { Frame 1: Back to normal. }
               end;

   r__NottsPub: begin
                 case bearing(5) of { Bearing of Avvy from Port. }
                   0.. 45,315..360: xx:=2; { Middle. }
                    45..180: xx:=6; { Left. }
                   181..314: xx:=8; { Right. }
                 end;

                 if (roomtime mod 60)>57 then dec(xx); { Blinks }

                 if xx<>dna.DogfoodPos then { Only if it's changed.}
                 begin
                  show_one(xx);
                  dna.DogfoodPos:=xx; { We use DogfoodPos here too- why not? }
                 end;

                 case (roomtime mod 50) of
                  45 : show_one(9); { Spurge blinks }
                  49 : show_one(10);
                 end;
                end;

   r__Ducks: begin
              if (roomtime mod 3)=0 then { The fire flickers }
               show_one(1+(roomtime div 3) mod 3);

              case bearing(2) of{ Bearing of Avvy from Duck. }
                0.. 45,315..360: xx:=4; { Middle. }
                 45..180: xx:=6; { Left. }
                181..314: xx:=8; { Right. }
              end;

              if (roomtime mod 45)>42 then inc(xx); { Duck blinks }

              if xx<>dna.DogfoodPos then { Only if it's changed.}
              begin
               show_one(xx);
               dna.DogfoodPos:=xx; { We use DogfoodPos here too- why not? }
              end;
             end;

  end;

 if (dna.ringing_bells) and (flagset('B')) then
   { They're ringing the bells. }
  case roomtime mod 4 of
   1: with dna do
      begin
       if nextbell<5 then nextbell:=12;
       dec(nextbell);
       note(notes[nextbell]);
      end;
   2: nosound;
  end;

end;

procedure load_chunks(xx:string);
var
 ch:chunkblocktype;
 fv:byte;
begin
 {$I-}
 assign(f,'chunk'+xx+'.avd'); { strf is done for us by Lucerna. }
 reset(f,1);
 if ioresult<>0 then exit; { no Chunk file. }
 seek(f,44);
 blockread(f,num_chunks,1);
 blockread(f,offsets,num_chunks*4);

 for fv:=1 to num_chunks do
 begin
  seek(f,offsets[fv]);
  blockread(f,ch,sizeof(ch));
  with ch do
  begin
   if memorise then
   begin

    with memos[fv] do
    begin
     x:=ch.x; xl:=ch.xl;
     y:=ch.y; yl:=ch.yl;
     flavour:=ch.flavour;
     size:=ch.size;
    end;

    getmem(memory[fv],size);

    if natural then
    begin
     getimage(x*8,y,(x+xl)*8,y+yl,memory[fv]^)
    end else
     blockread(f,memory[fv]^,size);
   end else memos[fv].x:=on_disk;
  end;
 end;

 close(f);
 {$I+}
end;

procedure forget_chunks;
var fv:byte;
begin
 for fv:=1 to num_chunks do
  if memos[fv].x>on_disk then
   freemem(memory[fv],memos[fv].size);
 fillchar(memos,sizeof(memos),#255); { x=-1, => on disk. }
end;

procedure mdrop(x,y,xl,yl:integer; p:pointer); assembler;
asm
  push ds;      { Strictly speaking, we shouldn't modify DS, so we'll save it.}
  push bp;      { Nor BP! }


  { DI holds the offset on this page. It starts at the top left-hand corner. }
  { (It should equal ch.y*80+ch.x. }

  mov ax,y;
  mov dl,80;
  mul dl; { Line offset now calculated. }
  mov di,ax; { Move it into DI. }
  mov ax,x;
  add di,ax; { Full offset now calculated. }

  mov bx,yl; { No. of times to repeat lineloop. }
  inc bx;        { "loop" doesn't execute the zeroth time. }
  mov bh,bl;     { Put it into BH. }

  { BP holds the length of the string to copy. It's equal to ch.xl.}

  mov ax,word(p);   { Data is held at DS:SI. }
  mov si,ax;
  mov ax,word(p+2); { This will be moved over into ds in just a tick... }

  mov bp,xl;

  mov ds,ax;


  cld;          { We're allowed to hack around with the flags! }

  mov ax,$AC00; { Top of the first EGA page. }
  mov es,ax;    { Offset on this page is calculated below... }


{    port[$3c4]:=2; port[$3ce]:=4; }

  mov dx,$3c4;
  mov al,2;
  out dx,al;
  mov dx,$3ce;
  mov al,4;
  out dx,al;

  mov cx,4;  { This loop executes for 3, 2, 1, and 0. }
  mov bl,0;


 @mainloop:

    push di;
    push cx;

{    port[$3C5]:=1 shl bit; }
    mov dx,$3C5;
    mov al,1;
    mov cl,bl; { BL = bit. }
    shl al,cl;
    out dx,al;
{     port[$3CF]:=bit; }
    mov dx,$3CF;
    mov al,bl; { BL = bit. }
    out dx,al;

    xor ch,ch;
    mov cl,bh; { BH = ch.yl. }

   @lineloop:

     push cx;

     mov cx,bp;

     repz movsb; { Copy the data. }

     sub di,bp;
     add di,80;

     pop cx;

   loop @lineloop;

    inc bl; { One more on BL. }

    pop cx;
    pop di;

 loop @mainloop;

  pop bp;
  pop ds;       { Get DS back again. }

end;

procedure show_one(which:byte);
var
 ch:chunkblocktype;
 p:pointer;
 r:bytefield;
 fv:byte;
  procedure display_it(x,y,xl,yl:integer; flavour:flavourtype; p:pointer);
  begin
   with r do
   begin
    case flavour of
     ch_BGI : begin
               putimage(x*8,y,p^,0);
               x1:=x; y1:=y;
               x2:=x+xl+1; y2:=y+yl;
              end;
     ch_EGA : begin
               mdrop(x,y,xl,yl,p); blitfix;
               x1:=x; y1:=y; x2:=x+xl; y2:=y+yl;
              end;
    end;
  end;
 end;

begin
 setactivepage(3);

 with memos[which] do
 begin
  if x>on_disk then
  begin
   display_it(x,y,xl,yl,flavour,memory[which]);
  end else
  begin
   reset(f,1);
   seek(f,offsets[which]);
   blockread(f,ch,sizeof(ch));

   with ch do
   begin
    getmem(p,size);
    blockread(f,p^,size);

    display_it(x,y,xl,yl,flavour,p);
    freemem(p,size);

    close(f);
   end;

  end;

  setactivepage(1-cp);

  for fv:=0 to 1 do
   getset[fv].remember(r);
 end;

end;

procedure show_one_at(which:byte; xxx,yyy:integer);
var
 ch:chunkblocktype;
 p:pointer;
 r:bytefield;
 fv:byte;
  procedure display_it(xl,yl:integer; flavour:flavourtype; p:pointer);
  begin
   with r do
   begin
    case flavour of
     ch_BGI : begin
               putimage(xxx,yyy,p^,0);
               x1:=xxx; y1:=yyy;
               x2:=xxx+xl+1; y2:=yyy+yl;
              end;
     ch_EGA : begin
               mdrop(xxx div 8,yyy,xl,yl,p); blitfix;
               x1:=xxx div 8; y1:=yyy; x2:=(xxx div 8)+xl; y2:=yyy+yl;
              end;
    end;
  end;
 end;

begin
 setactivepage(3);

 with memos[which] do
 begin
  if x>on_disk then
  begin
   display_it(xl,yl,flavour,memory[which]);
  end else
  begin
   reset(f,1);
   seek(f,offsets[which]);
   blockread(f,ch,sizeof(ch));

   with ch do
   begin
    getmem(p,size);
    blockread(f,p^,size);

    display_it(xl,yl,flavour,p);
    freemem(p,size);

    close(f);
   end;

  end;

  setactivepage(1-cp);

  for fv:=0 to 1 do
   getset[fv].remember(r);
 end;
end;

begin
 num_chunks:=0;
end.