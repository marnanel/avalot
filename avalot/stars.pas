program stars; { Demonstration of the Bigo II system. }
{$I c:\sleep5\DSMI.INC},Graph,Crt,Rodent,Tommys;
var gd,gm:integer;

type
 fonttype = array[#0..#255,0..15] of byte;

var
 reverse:boolean;
 spinnum:word;
 f:array[0..1] of fonttype;
 ff:file of fonttype;
 strip:array[0..7,0..15,0..79] of byte;
 across:byte;
 w:word; y:byte;
 charnum:byte;
 cfont:byte; { current font. 0=roman, 1=italic. }

 c:^char;

 nomusic:boolean;

const
 colours = 12; { Run Workout to see possible values of these two. }
 steps = 6; { 60,30,20,15,12,10,6,5,4,3,2,1 }
 gmtop = 360 div steps;

  scardcount=13;

      soundcards:array[0..scardcount-1] of integer =
        (1,2,6,3,4,5,8,9,10,7,7,7,7);

{$L credits.obj} procedure credits; external;

procedure bigo2(date:string);
var
 gd,gm:integer;
 c:byte;
 p:palettetype;
 f:file; pp:pointer; s:word;

begin
 getpalette(p);
 setvisualpage(1); setactivepage(0);
 assign(f,'logo.avd'); reset(f,1);
 for gd:=7 to 194 do
  blockread(f,mem[$A000:(gd*80)],53);
 close(f);
 s:=imagesize(0,7,415,194); getmem(pp,s); getimage(0,7,415,194,pp^);

 cleardevice;
 for gd:=1 to 64 do
 begin
  for gm:=0 to gmtop do
  begin
   c:=(c mod colours)+1;
(*   putpixel(trunc(sin(gm*steps*n)*gd*6)+320,
              trunc(cos(gm*steps*n)*gd*3)+175,c); *)
   if c>5 then continue;
   setcolor(c); arc(320,175,gm*steps,gm*steps+1,gd*6);
  end;
  if keypressed then begin closegraph; halt; end;
 end;
 settextstyle(0,0,1); setcolor(13);
 outtextxy(550,343,'(press any key)');

 putimage(112,0,pp^,orput); freemem(pp,s);
 resetmouse; setvisualpage(0);
end;

procedure nextchar; { Sets up charnum & cline for the next character. }
begin

 inc(c);
end;

procedure getchar;
begin
 repeat
  nextchar;

  case c^ of
   '@': begin cfont:=1; nextchar; end;
   '^': begin cfont:=0; nextchar; end;
   '%': if nomusic then
        begin
          closegraph; halt;      { End of text and no music => stop. }
        end
        else c:=addr(credits);   { End of test, but still playing => again. }
  end;

 until (c^<>#13) and (c^<>#10);

 for w:=0 to 7 do
  for y:=0 to 15 do
   move(strip[w,y,1],strip[w,y,0],79);

 for w:=0 to 7 do
  for y:=0 to 15 do
   strip[w,y,79]:=byte((strip[7,y,78] shl (w+1)))+
    f[cfont,c^,y] shr (7-w);

 across:=0;
end;

procedure scrolltext;
var
 c,w,y:byte;
begin
 inc(across);
 if across=8 then getchar;

 for y:=0 to 15 do
  for w:=0 to 1 do
  move(strip[across,y,0],mem[$A000:24000+(y*2+w)*80],80);
end;

procedure do_stuff;
begin
 case spinnum of
  50..110: begin
            setfillstyle(1,14);
            bar(0,315+(spinnum-50) div 3,640,315+(spinnum-50) div 3);
            bar(0,316-(spinnum-50) div 3,640,316-(spinnum-50) div 3);
            if spinnum>56 then
            begin
             setfillstyle(1,13);
             bar(0,315+(spinnum-56) div 3,640,315+(spinnum-56) div 3);
             bar(0,316-(spinnum-56) div 3,640,316-(spinnum-56) div 3);
            end;
          end;
  150..198: begin
             setfillstyle(1,0);
             bar(0,315+(spinnum-150) div 3,640,315+(spinnum-150) div 3);
             bar(0,316-(spinnum-150) div 3,640,316-(spinnum-150) div 3);
            end;
  200: scrolltext;
 end;
end;

procedure setcol(which,what:byte);
(*var dummy:byte;*)
begin
(* setpalette(which,what);
 asm
(*  mov dx,$3DA;
  in ax,dx;

  or ah,ah;

  mov dx,$3C0;
  mov al,which;
  out dx,al;

  mov dx,$3C0;
  mov al,what;
  out dx,al;
 end;
(* dummy:=port[$3DA];
 port[$3C0]:=which; port[$3C0]:=what;*)
end;

procedure bigo2go;
var
 p:palettetype; c:byte; lmo:boolean;
 altNow,altBefore:boolean;
begin
 for gd:=0 to 13 do p.colors[gd]:=0;

 setcol(13,24); { murk } setcol(14,38); { gold }
 setcol(15,egaWhite); { white- of course }
 p.colors[13]:=24; p.colors[14]:=38; p.colors[15]:=egaWhite;

 (***)
    
    p.colors[5]:=egaWhite;
    p.colors[4]:=egaLightcyan;
    p.colors[3]:=egaCyan;
    p.colors[2]:=egaLightblue;
    p.colors[1]:=egaBlue;

 (***)

 c:=1; p.size:=16; lmo:=false;
 setallpalette(p);

 repeat
(*  if reverse then
  begin
   dec(c); if c=0 then c:=colours;
  end else
  begin
   inc(c); if c>colours then c:=1;
  end;
  for gm:=1 to colours do
   case p.colors[gm] of
    egaWhite: begin p.colors[gm]:=egaLightcyan; setcol(gm,egaLightCyan); end;
    egaLightcyan: begin p.colors[gm]:=egaCyan; setcol(gm,egaCyan); end;
    egaCyan: begin p.colors[gm]:=egaLightblue; setcol(gm,egaLightblue); end;
    egaLightblue: begin p.colors[gm]:=egaBlue; setcol(gm,egaBlue); end;
    egaBlue: begin p.colors[gm]:=0; setcol(gm,0); end;
   end;
  p.colors[c]:=egaWhite; setcol(c,egaWhite);

  AltBefore:=AltNow; AltNow:=testkey(sAlt);*)

  if anymousekeypressed then lmo:=true;
  if keypressed then lmo:=true;
  if (not nomusic) and (ampGetModuleStatus <> MD_PLAYING) then lmo:=true;

 (* if (AltNow=True) and (AltBefore=False) then reverse:=not reverse;*)

  do_stuff;
  if spinnum<200 then inc(spinnum);
 until lmo;
end;

procedure parse_cline;
var e:integer;
begin
 if paramstr(1)<>'jsb' then
 begin
  writeln('Not a standalone program.'); halt(255);
 end;
end;

Function getSoundHardware(scard:PSoundcard):integer;
var sc,i,autosel,select : integer;
    ch                  : char;
    e                   : integer;
label again;

begin
again:
  sc:=detectGUS(scard);
  if sc<>0 then sc:=detectPAS(scard);
  if sc<>0 then sc:=detectAria(scard);
  if sc<>0 then sc:=detectSB(scard);

  { if no sound card found, zero scard }
  if sc<>0 then fillchar(scard^,sizeof(TSoundcard),0);

  autosel:=-1;
(*  if sc=0 then
    for i:=0 to scardcount-1 do
      if scard^.ID=soundcards[i].ID then begin
        { Set auto selection mark }
        autosel:=i+1;
        break;
      end;*)

  { Print the list of sound cards }

  val(paramstr(13),select,e);

  { Default entry? }
  if select=0 then select:=autosel;
  if select<>autosel then begin
    { clear all assumptions }
    sc:=-1;
    fillchar(scard^,sizeof(TSoundcard),0);
    scard^.ID:=soundcards[select-1]; { set correct ID }
  end;

  { Query I/O address }
  if scard^.id=ID_DAC then scard^.ioPort:=$378;

  { Read user input }
  val(paramstr(15),i,e);

  if i<>0 then scard^.ioPort:=i;
  if sc<>1 then { Not autodetected }
    case scard^.id of
      ID_SB16,
      ID_PAS16,
      ID_WSS,
      ID_ARIA,
      ID_GUS    : scard^.sampleSize:=2; { 16-bit card }
      ID_SBPRO,
      ID_PAS,
      ID_PASPLUS: scard^.stereo:=true;  { enable stereo }
      else begin
        scard^.sampleSize:=1;
        scard^.stereo:=false;
      end;
    end;

  if scard^.ID<>ID_DAC then begin
    val(paramstr(17),i,e);

    if i<>0 then scard^.dmaIRQ:=i;

    val(paramstr(16),i,e);

    if i<>0 then scard^.dmaChannel:=i;
  end else begin
    { Select correct DAC }
    scard^.maxRate:=44100;
    if select=11 then begin
      scard^.stereo:=true;
      scard^.dmaChannel:=1;   { Special 'mark' }
      scard^.maxRate:=60000;
    end else
    if select=12 then begin
      scard^.stereo:=true;
      scard^.dmaChannel:=2;
      scard^.maxRate:=60000;
      if scard^.ioPort=0 then scard^.ioPort:=$378;
    end else
    if select=13 then begin
      scard^.dmaChannel:=0;
      scard^.ioPort:=$42;     { Special 'mark' }
      scard^.maxRate:=44100;
    end;
  end;

(*    writeln('Your selection: ',select,' at ',scard^.ioPort,
            ' using IRQ ',scard^.dmaIRQ,' and DMA channel ',scard^.dmaChannel);
  readln;*)

  getSoundHardware:=0;
end;

var     scard   : TSoundcard;
        mcpstrc : TMCPstruct;
        dds     : TDDS;
        module  : PModule;
        sdi     : TSDI_init;
        e,
        bufsize : integer;
        ch      : char;
        v86,
        vdsOK   : boolean;
        a,rate,
        tempSeg : longint;
        answer  : string;
        temp    : pointer;
        flags   : word;
        curCh   : word;
        moduleVolume : byte;
        sample  : array[0..4] of TSampleInfo;
        volTable: array[0..31] of word;

begin
 parse_cline;

 nomusic:=paramstr(13)='0';

 if not nomusic then
 begin
    { Read sound card information }
    if getSoundHardware(@scard)=-1 then halt(1);


    { Initialize Timer Service }
    tsInit;
    atexit(@tsClose);
    if scard.ID=ID_GUS then begin
      { Initialize GUS player }
      {$IFNDEF DPMI}
      scard.extraField[2]:=1; { GUS DMA transfer does not work in V86 }
      {$ENDIF}
      gusInit(@scard);
      atexit(@gusClose);

      { Initialize GUS heap manager }
      gushmInit;

      { Init CDI }
      cdiInit;

      { Register GUS into CDI }
      cdiRegister(@CDI_GUS,0,31);

      { Add GUS event player engine into Timer Service }
      tsAddRoutine(@gusInterrupt,GUS_TIMER);
    end else begin
      { Initialize Virtual DMA Specification }
      {$IFNDEF DPMI}
      vdsOK:=vdsInit=0;
      {$ELSE}
      vdsOK:=false;
      {$ENDIF}

      fillchar(mcpstrc,sizeof(TMCPstruct),0);

      { Query for sampling rate }
      val(paramstr(14),a,e);
      if a>4000 then rate:=a else rate:=21000;

      { Query for quality }
      mcpstrc.options:=MCP_QUALITY;

      case scard.ID of
        ID_SB     : begin
                      sdi:=SDI_SB;
                      scard.maxRate:=22000;
                    end;
        ID_SBPRO  : begin
                      sdi:=SDI_SBPro;
                      scard.maxRate:=22000;
                    end;
        ID_PAS,
        ID_PASPLUS,
        ID_PAS16  : begin
                      sdi:=SDI_PAS;
                      scard.maxRate:=44100;
                    end;
        ID_SB16   : begin
                      sdi:=SDI_SB16;
                      scard.maxRate:=44100;
                    end;
        ID_ARIA   : begin
                      sdi:=SDI_ARIA;
                      scard.maxRate:=44100;
                    end;
        ID_WSS    : begin
                      sdi:=SDI_WSS;
                      scard.maxRate:=48000;
                    end;
        {$IFNDEF DPMI}
        ID_DAC    : sdi:=SDI_DAC; { Only available in real mode }
        {$ENDIF}
      end;

      mcpInitSoundDevice(sdi,@scard);
      a:=MCP_TABLESIZE;
      mcpstrc.reqSize:=0;

      { Calculate mixing buffer size }
      bufSize:=longint(2800*integer(scard.sampleSize) shl byte(scard.stereo))*
               longint(rate) div longint(22000);
      mcpstrc.reqSize:=0;
      if mcpstrc.options and MCP_QUALITY>0 then
        if scard.sampleSize=1 then inc(a,MCP_QUALITYSIZE) else
          a:=MCP_TABLESIZE16+MCP_QUALITYSIZE16;
      if longint(bufsize)+longint(a)>65500 then bufsize:=65500-a;

      {$IFDEF DPMI}
      dpmiVersion(byte(e),byte(e),byte(e),flags);
      v86:=(flags and 2)=0;
      {$ENDIF}

      { Allocate volume table + mixing buffer }
      {$IFDEF DPMI}

      { In the V86 mode, the buffer must be allocated below 1M }
      if v86 then begin
        tempSeg:=0;
        dpmiAllocDOS((a+bufSize) div 16+1,flags,word(tempSeg))
      end else begin
      {$ENDIF}
      getmem(temp,a+bufsize);
      if temp=nil then halt(2);
      {$IFDEF DPMI}
      tempSeg:=seg(temp^);
      end;
      {$ELSE}
      tempSeg:=seg(temp^)+ofs(temp^) div 16+1;
      {$ENDIF}
      mcpstrc.bufferSeg:=tempSeg;
      mcpstrc.bufferPhysical:=-1;

      if vdsOK and (scard.ID<>ID_DAC) then begin
        dds.size:=bufsize;
        dds.segment:=tempSeg;
        dds.offset:=0;

        { Lock DMA buffer if VDS present }
        if vdsLockDMA(@dds)=0 then mcpstrc.bufferPhysical:=dds.address;
      end;
      if mcpstrc.bufferPhysical=-1 then
        {$IFDEF DPMI}
        mcpstrc.bufferPhysical:=dpmiGetLinearAddr(tempSeg);
        {$ELSE}
        mcpstrc.bufferPhysical:=longint(tempSeg) shl 4;
        {$ENDIF}

      mcpstrc.buffersize:=bufsize;
      mcpstrc.samplingRate:=rate;
      { Initialize Multi Channel Player }
      if mcpInit(@mcpstrc)<>0 then halt(3);
      atexit(@mcpClose);

      { Initialize Channel Distributor }
      cdiInit;

      { Register MCP into CDI}
      cdiRegister(@CDI_MCP,0,31);
    end;

    { Try to initialize AMP }
    if ampInit(0)<>0 then halt(3);
    atexit(@ampClose);

    { Hook AMP player routine into Timer Service }
    tsAddRoutine(@ampInterrupt,AMP_TIMER);

    {$IFNDEF DPMI}
    { If using DAC, then adjust DAC timer }
    if scard.ID=ID_DAC then setDACTimer(tsGetTimerRate);
    {$ENDIF}

    if scard.ID<>ID_GUS then mcpStartVoice else gusStartVoice;

    { Load an example AMF }
    module:=ampLoadMOD('avalot2.mod',0);
    if module=nil then halt(4);

    { Is it MCP, Quality mode and 16-bit card? }
    if (scard.ID<>ID_GUS) and (mcpstrc.options and MCP_QUALITY>0)
       and (scard.sampleSize=2) then begin
      { Open module+2 channels with amplified volumetable (4.7 gain) }
      for a:=1 to 32 do volTable[a-1]:=a*150 div 32;
      cdiSetupChannels(0,module^.channelCount+2,@volTable);
    end else begin
      { Open module+2 channels with regular volumetable }
      cdiSetupChannels(0,module^.channelCount+2,nil);
    end;

    curCh:=module^.channelCount;
    moduleVolume:=64;

   (***) ampPlayModule(module,0);
 end;

 gd:=3; gm:=1; initgraph(gd,gm,'');
 assign(ff,'avalot.fnt'); reset(ff); read(ff,f[0]); close(ff);
 assign(ff,'avitalic.fnt'); reset(ff); read(ff,f[1]); close(ff);

 c:=addr(credits); dec(c);

 fillchar(strip,sizeof(strip),#0);
 reverse:=false; spinnum:=0; across:=7; charnum:=1; cfont:=0;
 bigo2('1189'); { 1189? 79? 2345? 1967? }
 bigo2go;

 if not nomusic then ampStopModule;
 closegraph;
end.