program golden;
{$I c:\sleep5\DSMI.INC},  Graph,Crt;

const song : string[255] =
  'Golden slumbers kiss your eyes/Smiles awake you when you rise/'+
  'Sleep, pretty Baron, do not cry/And I will sing a lullaby.%Care you '+
  'know not, therefore sleep/While I o''er you watch do keep;/Sleep now, '+
  'du Lustie, do not cry/And I will leave the castle.*Bye!';

  scardcount=13;

      soundcards:array[0..scardcount-1] of integer =
        (1,2,6,3,4,5,8,9,10,7,7,7,7);

  holding : array[1..5] of byte =
    ( 24, { 0 : 24 }
      64, { 1 : 00 }
     128, { 2 : 00 }
     152, { 2 : 24 }
     170);{ 2 : 42 }

var
  gd,gm:integer;
  fv:byte;
 skellern:^word;
 s,o:word;
 firstverse:boolean;
 nexthangon:word;

 nomusic:boolean;

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

function here:byte;
begin
  here:=(ampgetpattern mod 3)*64+ampgetrow;
end;

procedure hold(amount:word);
begin
  skellern^:=0;
  repeat until skellern^>=amount;
end;

procedure hangon(forwhat:word);
begin
  if nomusic then
    hold(40)
  else
    repeat
        if keypressed then halt;
    until here>=holding[forwhat];
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
  for e:=1 to paramcount do answer:=paramstr(e);

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
    module:=ampLoadMOD('golden.mod',0);
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

 val(paramstr(2),s,e); if e<>0 then halt;
 val(paramstr(3),o,e); if e<>0 then halt;
 skellern:=ptr(s,o+1);

  gd:=3; gm:=0; initgraph(gd,gm,'');

  if not nomusic then repeat until ampgetrow>=10;

  setcolor(9);
  for gd:=0 to 320 do
  begin
    rectangle(320-gd,100-gd div 2,320+gd,100+gd div 2);
  end;


  gd:=50; gm:=20;
  firstverse:=true;

  hangon(1); nexthangon:=2;
  for fv:=1 to 255 do
  begin
    case song[fv] of
      '/': begin
              gd:=50;
              inc(gm,15);
              hangon(nexthangon);
              inc(nexthangon);
           end;

      '%': begin
              gd:=50;
              inc(gm,35);
              if nomusic then
                hold(15)
              else
                repeat until ampgetpattern>2;
              nexthangon:=2;
              hangon(1);
           end;

      '*': begin
              inc(gd,24);
              hangon(5);
           end;

          else begin
                  setcolor(1); outtextxy(gd+1,gm+1,song[fv]);
                  setcolor(0); outtextxy( gd , gm ,song[fv]);
                  inc(gd,12);
               end;
    end;
    if song[fv]=' ' then hold(1);
    if keypressed then halt;
  end;

  if nomusic then
    hold(25)
  else
    repeat until ampgetmodulestatus<>MD_Playing;

  setcolor(0);
  for gd:=320 downto 0 do rectangle(320-gd,100-gd div 2,320+gd,100+gd div 2);
end.