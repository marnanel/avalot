{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 WAVER            Handles PCM playback. }

{ Heavily based on SBVoice, by Amit K. Mathur, Ontario, Canada. }

unit Waver;

interface

const
 SB_interrupt : word = $5;
 SB_IOport    : word = $220;

var

 SB_status    : word; { Status code. }

procedure Waver_start;

procedure Waver_stop;

procedure Waver_play(which:string);

procedure Waver_link;


implementation

var

 this_voc  : pointer; { This is the current .voc file. }
 this_size : word;    { Size of the current .voc file. }

procedure SBDriver; external; {$L v:ctvoice.obj}

function sb_init: integer; assembler;
asm
   push  bp
   mov   bx, 3
   call  far ptr SBDriver
   pop   bp
end;

procedure Waver_start;
begin;
 { sb_setinterruptnumber. This sets up the SB's IRQ number. }

 asm

   push  bp
   mov   bx,2
   mov   ax,SB_interrupt

   call  far ptr SBDriver

   pop   bp
 end;

 { sb_setIOaddress. This sets the SB up for the correct port. }

 asm
   push  bp
   mov   bx,1
   mov   ax,SB_IOport
   call  far ptr SBDriver
   pop   bp
 end;

 if sb_init<>0 then halt; { init error - fix this! }

 { sb_setstatusword. Tell the SB where our status word is. }

 asm
    push bp
    push di
    mov  bx,5
    mov  di,offset SB_status
    mov  ax,seg    SB_status
    mov  es,ax;
    call far ptr SBDriver
    pop  di
    pop  bp
 end;

 { sb_speaker. We always need it switched on (=1). }

 asm
    push  bp
    mov   bx,4
    mov   ax,1 { Always on. }
    call  far ptr SBDriver
    pop   bp
 end;

end;


procedure Waver_stop; { Switches the SB off at the end of the program. }
begin;
(*
 { sb_uninstall. }

 asm
   push  bp
   mov   bx,9
   call  far ptr SBDriver
   pop   bp
 end;

 { That's all! }

(* freemem(SBDriver,2500);*)

end;


procedure Waver_play(which:string); { Now THIS is FUN! Play "which" (voc.) }

var
 f  : file;

   procedure sb_output(sg,os:word); assembler;
   asm
       push bp
       push di
       mov  bx,6
       mov  di,os             { offset of voice  }
       mov  es,sg             { segment of voice }
       call far ptr SBDriver
       pop  di
       pop  bp
   end;

begin;
 assign(f,which);

 reset(f,1);
 this_size:=filesize(f); { Bypass .voc header. }

 getmem(this_voc,this_size);

 blockread(f,this_voc^,this_size);
 close(f);

 sb_output(seg(this_voc^),ofs(this_voc^)+26);
end;

procedure waver_link; { This gets called once every cycle. }
begin;
 if (SB_status=0) and (this_size>0) then
  { Stopped playing, and we were playing something before. }
 begin;
  freemem(this_voc,this_size);
  this_size:=0;
 end;
end;

begin;
 this_size:=0;
(* Waver_start;*)
end.