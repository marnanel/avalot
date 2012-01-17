program test_reload;
uses Graph;

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

var
 f:file;
 offset:longint;
 ch:chunkblocktype;
 gd,gm:integer;
 bit:byte;
 p:pointer;

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

  mov ax,$A000; { Top of the first EGA page. }
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

begin;
 assign(f,'chunk21.avd');
 reset(f,1);

 seek(f,49);
 blockread(f,offset,4);

 seek(f,offset);

 blockread(f,ch,sizeof(ch));

 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 getmem(p,ch.size);
 blockread(f,p^,ch.size);
(* putimage(0,0,p^,0);*)


(* with ch do
  for bit:=0 to 3 do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   for gm:=0 to yl do
    blockread(f,mem[$A000:gm*80],(ch.xl+7) div 8);
  end;*)

 with ch do
  mdrop(x,y,xl,yl,p);

 close(f);
end.