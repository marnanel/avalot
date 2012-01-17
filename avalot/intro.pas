program intro;
{$I c:\sleep5\DSMI.INC},Dos,Graph,Crt;
 { This is a stand-alone program. }

const

 { 0, black, remains 0.
   Other numbers: the bits take precedence from the left.
    e.g. for 9 = 1001, => fourth bit.

    First 1 is in:

     Fourth bit: 63 (egaWhite)
      Third bit: 57 (egaLightBlue)
     Second bit: 7  (light grey)
      First bit: 1  (blue). }

 our_palette : palettetype =
                 (size:16;
                  colors: { sic }
 (  0,  1, 57, 57,  7,  7,  7,  7, 63, 63, 63, 63, 63, 63, 63, 63));

   scardcount=13;

      soundcards:array[0..scardcount-1] of integer =
        (1,2,6,3,4,5,8,9,10,7,7,7,7);

type
 fonttype = array[#0..#255,1..16] of byte;

var
 f : fonttype;
 next_line:array[0..39,1..16] of byte;

 next_bitline:byte;

 displaycounter:byte;

 cut_out:boolean;

 cut_out_time:word;

 x:array[1..117] of string[40];

 this_line:byte;

 skellern:^word;
 nomusic:boolean;

{$L intro.obj}
procedure introduction; external;

procedure graphmode(mode:integer);
var regs:registers;
begin
 regs.ax:=mode;
 intr($10,regs);
end;

{ Firstly, port[$3C4]:=2; port[$3CF]:=4;,
  Then port[$3C5]:=1 shl bit; port[$3CF]:=bit;. }

procedure loadfont;
var ff:file of fonttype;
begin
 assign(ff,'avalot.fnt');
 reset(ff);
 read(ff,f);
 close(ff);
end;

procedure calc_next_line;
 { This proc sets up next_line. }
var
 L:string;
 fv,ff:byte;
 oddlen:boolean;
 start:byte;
 this:byte;
begin
 fillchar(next_line,sizeof(next_line),#0); { All blanks. }

 if this_line=117 then
 begin
  cut_out:=true;
  exit;
 end;

 L:=x[this_line];
 inc(this_line);

 start:=(20-length(L) div 2)-1;
 oddlen:=odd(length(L));

 for fv:=1 to length(L) do
  for ff:=1 to 16 do
  begin
   this:=f[L[fv],ff];
   if oddlen then
   begin { Odd, => 4 bits shift to the right. }
    inc(next_line[start+fv,ff],this shl 4);
    inc(next_line[start+fv-1,ff],this shr 4);
   end else
   begin { Even, => no bit shift. }
    next_line[start+fv,ff]:=this;
   end;
  end;
 next_bitline:=1;
end;

procedure display;
var fv,ff:byte;
begin

 if next_bitline = 17 then calc_next_line;

 if cut_out then
 begin
  if nomusic then
    dec(cut_out_time)
  else
   if ampGetModuleStatus <> MD_PLAYING then cut_out_time:=0;
  exit;
 end;

 move(mem[$A000:40],mem[$A000:0],7960);
 for fv:=0 to 39 do
   mem[$A1F1:8+fv]:=next_line[fv,next_bitline];
 inc(next_bitline);

end;

procedure plot_a_star(x,y:integer);
var ofs:byte;
begin
 ofs:=x mod 8;
 x:=x div 8;
 inc(mem[$A000:x+y*40],128 shr ofs);
end;

procedure plot_some_stars(y:integer);
var fv,times:byte;
begin
 case random(7) of
  1: times:=1;
  2: times:=2;
  3: times:=3;
  else exit;
 end;

 for fv:=1 to times do
  plot_a_star(random(320),y);
end;

procedure starry_starry_night;
var
 y:integer;
 bit:byte;
begin
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;

 for bit:=0 to 2 do
 begin
  port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  for y:=1 to 200 do
   plot_some_stars(y);
 end;
end;

procedure setupgraphics; { Fix this proc. This prog SHOULDN'T use the
 Graph unit. }
var gd,gm:integer;
begin
 gd:=3; gm:=1; initgraph(gd,gm,'');
end;

procedure shovestars;
begin
 move(mem[$A000:0],mem[$A000:40],7960);
 fillchar(mem[$A000:0],40,#0);
 plot_some_stars(0);
end;

procedure do_next_line;
var bit:byte;
begin
 port[$3c4]:=2; port[$3ce]:=4;

 for bit:=0 to 3 do
 begin
  port[$3C5]:=1 shl bit; port[$3CF]:=bit;

  case bit of
   0: if (displaycounter mod 10)=0 then shovestars;
   1: if (displaycounter mod 2)=0 then shovestars;
   2: shovestars;
   3: display; { The text. }
  end;
 end;

 if displaycounter=40 then displaycounter:=0;

end;

procedure load_text;
var
 fv:word;
 c:^char;
 thisline:byte;
begin

 c:=addr(introduction);
 thisline:=0;
 fillchar(x,sizeof(x),#0);

 for fv:=1 to 2456 do
 begin
  case c^ of
   #13: inc(thisline);
   #10: {nop};
   else x[thisline]:=x[thisline]+c^;
  end;

  inc(c);
 end;
end;

procedure check_params;
var s,o:word; e:integer;
begin
 if paramstr(1)<>'jsb' then halt;
 val(paramstr(2),s,e); if e<>0 then halt;
 val(paramstr(3),o,e); if e<>0 then halt;
 skellern:=ptr(s,o+1);
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

 check_params;

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
    module:=ampLoadMOD('glover.mod',0);
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

 setupgraphics;

 randseed:=177; checkbreak:=false;

 load_text;

 this_line:=1;

 graphmode($D);
 loadfont;

 next_bitline:=17;
 displaycounter:=0;

 cut_out_time:=333;

 setallpalette(our_palette);

 starry_starry_night;

 while (cut_out_time>0) and (not keypressed) do
 begin

  skellern^:=0;

  do_next_line;

  inc(displaycounter);

  repeat until skellern^>0;
 end;

 if not nomusic then ampStopModule;
 graphmode(3);
end.