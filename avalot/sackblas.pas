program SackBlaster; { This is a kludge-up of Cameron's DreamTracker code. }

uses    DOS, CRT;

type    channelrecord                       = record
                                                lastsample    : word;
                                                channelvolume : word;
                                                VUbar         : word;
                                                channelpos    : word;
                                                channelseg    : word;
                                                channelsize   : word;
                                                channelrep    : word;
                                                channelreplen : word;
                                                channelblip   : word;
                                                channelperiod : word;
                                                channelspeed  : word;
                                                effectcounter : word;
                                                effectoperand : word;
                                                portadest     : word;
                                                effecttype    : word;
                                                secondeffect  : word;
                                                channeltuning : word;
                                                vibratostuff  : word;
                                                arpeggiostuff : longint;
                                              end;


const   maxchannels                         = 3;
        maxsamples                          = 63;
        maxpatterns                         = 63;
        maxbeats                            = 63;
        patterntablesize                    = 127;
        ch                                  = 249;
        buffersize                          = 255;
        buffersegsize                       = 64;
        bufdiv                              = 2;
        channelstrucsize                    = sizeof(channelrecord);
        lastsample                          = 00;
        channelvolume                       = 02;
        VUbar                               = 04;
        channelpos                          = 06;
        channelseg                          = 08;
        channelsize                         = 10;
        channelrep                          = 12;
        channelreplen                       = 14;
        channelblip                         = 16;
        channelperiod                       = 18;
        channelspeed                        = 20;
        effectcounter                       = 22;
        effectoperand                       = 24;
        portadest                           = 26;
        vibratodepth                        = 26;
        effecttype                          = 28;
        portaspeed                          = 30;
        vibratospeed                        = 30;
        channeltuning                       = 32;
        vibratostuff                        = 34;
        arpeggiostuff                       = 36;
        nextthing                           = 40;
        Mixer                               = 01;
        Sequencer                           = 02;
        ResetSequencer                      = 04;
        RepeatSong                          = 08;
        NoJumping                           = 16;
{---------------------------------------------------------------------------}
{}      DetectHardware                      = -1;{                          }
{}      InternalSpeaker                     = 0; { working perfectly        }
{}      MonoDAC                             = 1; { works great              }
{}      StereoOn2DAC                        = 2; { works great              }
{}      StereoOn1DAC                        = 3; { untested                 }
{}      SoundBlaster                        = 4; { works great. Uses DMA    }
{ Ý }   SoundBlasterPro                     = 5; { Ý  currently unwritten  Ý}
{}      ProAudioSpectrum                    = 6; { works great. Uses DMA    }
{ Ý }   Adlib {will this be implemented?}   = 7; { Ý  currently unwritten  Ý}
{---------------------------------------------------------------------------}
        HardwareName                        : array[0..7] of string[17] =
                                              ('Internal Speaker ',
                                               'Mono DAC         ',
                                               'Stereo DAC       ',
                                               'Stereo-On-1 DAC  ',
                                               'Soundblaster     ',
                                               'Soundblaster PRO ',
                                               'ProAudio Spectrum',
                                               'Adlib            ');


var     channel                             : array[0..maxchannels] of channelrecord;
        patterntable                        : array[0..patterntablesize] of word;
        patternseg                          : array[0..maxpatterns] of word;
        songname                            : string[20];
        mainfreq, channeldata1, channeldata2: longint;
        time                                : longint;
        samplerate, musicticks, currentdiv  : word;
        currentpattern, patternsinsong, bufp: word;
        retracestilbeat, endofsong, status  : word;
        hwport, hwirq, hwdma, actualpattern : word;
        wavecontrol, bufstart, patternbeat  : word;
        dmabufferseg, dmabufferofs, patseg  : word;
        scopeptr, leftdata, rightdata       : word;
        tempo, freddict, hwport2            : word;
        TrackerHandler                      : word;
        monodata, samptest                  : byte;
        patterndata													: pointer;


var        sampledata                          : array[0..maxsamples] of pointer;
        samplename                          : array[0..maxsamples] of string[22];
        samplelength, samprep, sampreplen   : array[0..maxsamples] of word;
        defaultsamplevolume, samplevolume   : array[0..maxsamples] of word;
        sampleseg, sampletuning             : array[0..maxsamples] of word;
        saveint08,outputprocedure,saveint69 : procedure;
        dmabuffer   							          : pointer;
        timeconst                           : byte;
        samplenumber, timerticks, loopatend : word;
        noteperiod, bufptr, bufofs, called  : word;
        dmawritesinglemask, dmawritemode    : word;
        dmapagereg, dmaclear, dmaaddress    : word;
        dmalength, dmabufferlengthscale     : word;
        irqaddress, ackport, enableport     : word;
        dmabuffersize, effect, infobyte     : word;
        OPofs, OPseg, patternbaseseg        : word;
        patternnumber, repeatatend          : word;
        channelbuff, loaded                 : word;
        linbufptr, datareqhandler           : longint;

procedure PutAByteInTheBuffer; assembler;
asm
  xor dx,dx
  push es
  test status,mixer
  jz @2donechannel

  @0dochannel:
  cmp word ptr [offset channel+channelstrucsize*0+channelseg],0
  je @0donechannel
  les bx,[ds:offset channel+channelstrucsize*0+channelpos]
  cmp bx,[offset channel+channelstrucsize*0+channelsize]
  ja @0atend
  mov ax,[offset channel+channelstrucsize*0+channelspeed]
  add byte ptr [offset channel+channelstrucsize*0+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*0+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*0+channelvolume]
  add dl,ah
  mov [word ptr channeldata1+0],ax
  @0donechannel:

  @3dochannel:
  cmp word ptr [offset channel+channelstrucsize*3+channelseg],0
  je @3donechannel
  les bx,[ds:offset channel+channelstrucsize*3+channelpos]
  cmp bx,[offset channel+channelstrucsize*3+channelsize]
  ja @3atend
  mov ax,[offset channel+channelstrucsize*3+channelspeed]
  add byte ptr [offset channel+channelstrucsize*3+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*3+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*3+channelvolume]
  add dl,ah
  mov [word ptr channeldata1+6],ax
  @3donechannel:

  @1dochannel:
  cmp word ptr [offset channel+channelstrucsize*1+channelseg],0
  je @1donechannel
  les bx,[ds:offset channel+channelstrucsize*1+channelpos]
  cmp bx,[offset channel+channelstrucsize*1+channelsize]
  ja @1atend
  mov ax,[offset channel+channelstrucsize*1+channelspeed]
  add byte ptr [offset channel+channelstrucsize*1+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*1+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*1+channelvolume]
  add dh,ah
  mov [word ptr channeldata1+2],ax
  @1donechannel:

  @2dochannel:
  cmp word ptr [offset channel+channelstrucsize*2+channelseg],0
  je @2donechannel
  les bx,[ds:offset channel+channelstrucsize*2+channelpos]
  cmp bx,[offset channel+channelstrucsize*2+channelsize]
  ja @2atend
  mov ax,[offset channel+channelstrucsize*2+channelspeed]
  add byte ptr [offset channel+channelstrucsize*2+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*2+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*2+channelvolume]
  add dh,ah
  mov [word ptr channeldata1+4],ax
  @2donechannel:

  pop es
  mov [byte ptr ds:offset leftdata],dl
  mov [byte ptr ds:offset rightdata],dh
  add dl,dh
  mov monodata,dl
  test word ptr status,Sequencer
  jnz @sequencer
  retf
  @sequencer:
  cmp endofsong,1
  je @playnote
  mov ax,musicticks
  sub ax,samplerate
  js @wegotone
  mov musicticks,ax
  retf

  @0atend:
  mov ax,[offset channel+channelstrucsize*0+channelreplen]
  or ax,ax
  jnz @0dontbrutallymurderchannel
  mov word ptr [offset channel+channelstrucsize*0+channelseg],0
  mov [word ptr channeldata1+0],0
  jmp @0donechannel
  @0dontbrutallymurderchannel:
  mov bx,[offset channel+channelstrucsize*0+channelrep]
  add ax,bx
  mov [offset channel+channelstrucsize*0+channelsize],ax
  mov ax,[offset channel+channelstrucsize*0+channelspeed]
  add byte ptr [offset channel+channelstrucsize*0+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*0+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*0+channelvolume]
  add dl,ah
  jmp @0donechannel

  @3atend:
  mov ax,[offset channel+channelstrucsize*3+channelreplen]
  or ax,ax
  jnz @3dontbrutallymurderchannel
  mov word ptr [offset channel+channelstrucsize*3+channelseg],0
  mov [word ptr channeldata1+6],0
  jmp @3donechannel
  @3dontbrutallymurderchannel:
  mov bx,[offset channel+channelstrucsize*3+channelrep]
  add ax,bx
  mov [offset channel+channelstrucsize*3+channelsize],ax
  mov ax,[offset channel+channelstrucsize*3+channelspeed]
  add byte ptr [offset channel+channelstrucsize*3+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*3+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*3+channelvolume]
  add dl,ah
  mov [word ptr channeldata1+6],ax
  jmp @3donechannel

  @1atend:
  mov ax,[offset channel+channelstrucsize*1+channelreplen]
  or ax,ax
  jnz @1dontbrutallymurderchannel
  mov word ptr [offset channel+channelstrucsize*1+channelseg],0
  mov [word ptr channeldata1+2],0
  jmp @1donechannel
  @1dontbrutallymurderchannel:
  mov bx,[offset channel+channelstrucsize*1+channelrep]
  add ax,bx
  mov [offset channel+channelstrucsize*1+channelsize],ax
  mov ax,[offset channel+channelstrucsize*1+channelspeed]
  add byte ptr [offset channel+channelstrucsize*1+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*1+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*1+channelvolume]
  add dh,ah
  mov [word ptr channeldata1+2],ax
  jmp @1donechannel

  @2atend:
  mov ax,[offset channel+channelstrucsize*2+channelreplen]
  or ax,ax
  jnz @2dontbrutallymurderchannel
  mov word ptr [offset channel+channelstrucsize*2+channelseg],0
  mov [word ptr channeldata1+4],0
  jmp @2donechannel
  @2dontbrutallymurderchannel:
  mov bx,[offset channel+channelstrucsize*2+channelrep]
  add ax,bx
  mov [offset channel+channelstrucsize*2+channelsize],ax
  mov ax,[offset channel+channelstrucsize*2+channelspeed]
  add byte ptr [offset channel+channelstrucsize*2+channelblip],ah
  mov ah,0
  adc bx,ax
  mov [offset channel+channelstrucsize*2+channelpos],bx
  mov al,[es:bx]
  imul byte ptr [offset channel+channelstrucsize*2+channelvolume]
  add dh,ah
  mov [word ptr channeldata1+4],ax
  jmp @2donechannel

  @wegotone:
  clc
  inc word ptr [offset time]
  adc word ptr [offset+2],0
  add ax,23680
  mov musicticks,ax
  cmp retracestilbeat,0
  je @wegotanotherone
  dec retracestilbeat
  mov di,offset channel+channelstrucsize*0
  call @dofx
  mov di,offset channel+channelstrucsize*1
  call @dofx
  mov di,offset channel+channelstrucsize*2
  call @dofx
  mov di,offset channel+channelstrucsize*3
  call @dofx
  retf
  @wegotanotherone:
  mov ax,tempo
  dec ax
  mov word ptr retracestilbeat,ax
{-=ðÛ ok...we're gonna do a beat now! Ûð=-}
  mov si,patternbeat
  cmp si,1024

  jb @thispattern
  mov si,0
  mov patternbeat,si
  mov ax,currentpattern
  inc ax
  cmp ax,patternsinsong
  jg @atend
{-=ðÛ ok...we're now gonna find out wot pattern we're doing Ûð=-}
  mov currentpattern,ax
  shl ax,1
  mov di,ax
  mov ax,[offset patterntable+di]
  cmp ax,65535
  je @playnote
  mov actualpattern,ax
  mov cl,6 { <<< TT added this to run on the 8088. }
  shl ax,cl { <<< And changed this from shl ax,6. }
  add ax,patternbaseseg
  mov patseg,ax
  xor si,si
  mov patternbeat,0
  @thispattern:
  push es
  mov ax,patseg
  mov es,ax
  mov di,offset channel+channelstrucsize*0
  call @domusicX
  mov di,offset channel+channelstrucsize*1
  call @domusicX
  mov di,offset channel+channelstrucsize*2
  call @domusicX
  mov di,offset channel+channelstrucsize*3
  call @domusicX
  pop es
  retf

  @atend:
  test word ptr status,8
  jz @reallyatend
  mov word ptr currentpattern,0
  mov bx,[offset patterntable]
  shl bx,1
  mov bx,[offset patternseg+bx]
  mov patseg,bx
  mov word ptr patternbeat,0
  jmp @playnote
  @reallyatend:
  mov endofsong,1
  and status,13
  jmp @playnote

  @fxjumptable:
  dw @nofx              {no effect}
  dw @portup            {portamento up}
  dw @portdown          {portamento down}
  dw @volup             {volumeslide up}
  dw @voldown           {volumeslide down}
  dw @portavolup        {portamento+volumeslide up}
  dw @portavoldown      {portamento+volumeslide down}
  dw @arpeggiofx        {arpeggio}
  dw @vibratofx         {vibrato}
  dw @tremolofx         {tremolo}

  @nofx:
  retn

  @tremolofx:
  mov si,offset @vibratotable
  xor cx,cx
  mov cl,[di+vibratostuff]
  add si,cx
  add cx,[di+vibratospeed]
  and cx,63
  mov [di+vibratostuff],cl
  xor ax,ax
  mov al,byte ptr [cs:si]
  mov bx,[di+vibratodepth]
  mul bl
  xchg al,ah
  xor ah,ah
  test ax,31
  jnz @tnotzeroid
  retn
  @tnotzeroid:
  mov bx,[di+channelvolume]
  test cx,32
  jnz @taddit
  sub bx,ax
  jns @tokit
  mov bx,0
  jmp @tokit
  @taddit:
  add bx,ax
  cmp bx,64
  jbe @tokit
  mov bx,64
  @tokit:
  mov [di+channelvolume],bx
  retn

  @vibratofx:
  mov si,offset @vibratotable
  xor cx,cx
  mov cl,[di+vibratostuff]
  add si,cx
  add cx,[di+vibratospeed]
  and cx,63
  mov [di+vibratostuff],cl
  xor ax,ax
  mov al,byte ptr [cs:si]
  mov bx,[di+vibratodepth]
  mul bl
  xchg al,ah
  xor ah,ah
  test ax,31
  jnz @notzeroid
  retn
  @notzeroid:
  mov bx,[di+channelperiod]
  test cx,32
  jnz @addit
  sub bx,ax
  jmp @okit
  @addit:
  add bx,ax
  @okit:
  cmp bx,108
  jg @bigenough
  mov bx,108
  @bigenough:
  cmp bx,907
  jb @smallenough
  mov bx,907
  @smallenough:
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  retn

  @arpeggiofx:
  mov bx,[di+channelperiod]
  mov si,offset @periodtable0
  mov cx,36
  @seekloop:
  cmp [cs:si],bx
  je @seekfound
  add si,2
  loop @seekloop
  retn
  @seekfound:
  xor ax,ax
  mov al,byte ptr [di+arpeggiostuff]
  mov bx,di
  add bx,ax
  inc al
  and al,3
  mov byte ptr [di+arpeggiostuff],al
  mov al,byte ptr [bx+arpeggiostuff]
  add si,ax
  add si,ax
  mov ax,72 {bytes in a periodtable}
  mov bx,[di+channeltuning]
  mul bl
  add si,ax
  mov bx,[cs:si]
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  retn

  @portup:
  mov bx,[di+channelperiod]
  mov ax,[di+portaspeed]
  sub bx,ax
  cmp bx,[di+portadest]
  jg @nottoofastnowwedontwantanaccident
  mov bx,[di+portadest]
  @nottoofastnowwedontwantanaccident:
  mov [di+channelperiod],bx
  or bx,bx
  jz @jumppu
  test wavecontrol,1
  jz @puseekfound
  mov si,offset @periodtable0
  mov ax,72 {bytes in a periodtable}
  mov dx,[di+channeltuning]
  mul dl
  add si,ax
  mov cx,36
  @puseekloop:
  cmp [cs:si],bx
  je @puseekfound
  add si,2
  loop @puseekloop
  retn
  @puseekfound:
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  @jumppu:
  retn

  @portdown:
  mov bx,[di+channelperiod]
  mov ax,[di+portaspeed]
  add bx,ax
  cmp bx,[di+portadest]
  jb @nottooslownowwedontwantatrafficjam
  mov bx,[di+portadest]
  @nottooslownowwedontwantatrafficjam:
  mov [di+channelperiod],bx
  or bx,bx
  jz @jumppd
  test wavecontrol,1
  jz @pdseekfound
  mov si,offset @periodtable0
  mov ax,72 {bytes in a periodtable}
  mov dx,[di+channeltuning]
  mul dl
  add si,ax
  mov cx,36
  @pdseekloop:
  cmp [cs:si],bx
  je @pdseekfound
  add si,2
  loop @pdseekloop
  retn
  @pdseekfound:
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  @jumppd:
  retn

  @volup:
  mov ax,[di+channelvolume]
  mov bx,[di+effectoperand]
  add ax,bx
  cmp ax,64
  jb @vok1
  mov ax,64
  @vok1:
  mov [di+VUBar],ax
  mov [di+channelvolume],ax
  retn

  @voldown:
  mov ax,[di+channelvolume]
  mov bx,[di+effectoperand]
  sub ax,bx
  cmp ax,64
  jb @vok2
  mov ax,0
  @vok2:
  mov [di+VUBar],ax
  mov [di+channelvolume],ax
  retn

  @portavolup:
  mov bx,[di+portadest]
  cmp bx,[di+channelperiod]
  je @pvuskip
  jg @pvunotthatway
  call @portup
  jmp @pvuskip
  @pvunotthatway:
  call @portdown
  @pvuskip:
  mov ax,[di+channelvolume]
  mov bx,[di+effectoperand]
  add ax,bx
  cmp ax,64
  jb @pvok1
  mov ax,64
  @pvok1:
  mov [di+VUBar],ax
  mov [di+channelvolume],ax
  retn

  @portavoldown:
  mov bx,[di+portadest]
  cmp bx,[di+channelperiod]
  je @pvdskip
  jg @pvdnotthatway
  call @portup
  jmp @pvdskip
  @pvdnotthatway:
  call @portdown
  @pvdskip:
  mov ax,[di+channelvolume]
  mov bx,[di+effectoperand]
  sub ax,bx
  cmp ax,64
  jb @pvok2
  mov ax,0
  @pvok2:
  mov [di+VUBar],ax
  mov [di+channelvolume],ax
  retn

  @dofx:
  mov ax,[di+effectcounter]
  or ax,ax
  jnz @dofx2
  mov word ptr [di+effecttype],0
  retn
  @dofx2:
  mov bx,[di+effectcounter]
  dec bx
  mov [di+effectcounter],bx
  mov bx,[di+effecttype]
  and bx,$0f
  shl bx,1
  add bx,offset @fxjumptable
  mov ax,[cs:bx]
  push ax
  retn

  @commandjumptable:
  dw @playarpeggio           {0 = play with arpeggio}
  dw @pitchup                {1 = pitchbend up}
  dw @pitchdown              {2 = pitchbend down}
  dw @portamento             {3 = pitchbend towards note}
  dw @playvibrato            {4 = vibrato}
  dw @portavolume            {5 = continue last portamento+start volumeslide}
  dw @noeffect               {6 = continue last vibrato+start volumeslide}
  dw @playtremolo            {7 = tremolo}
  dw @noeffect               {8 = unused}
  dw @sampleoffset           {9 = play sample from offset infobyte*200}
  dw @volumeslide            {A = volumeslide up/down}
  dw @positionjump           {B = jump to new pattern}
  dw @volumeset              {C = set volume of current channel}
  dw @patternbreak           {D = terminate current pattern when beat done}
  dw @noeffect               {E = E-Commands}
  dw @setspeed               {F = Set tempo}

  @noeffect:
  retn

  @doarpeggio:
  mov infobyte,0
  @playarpeggio:
  mov si,samplenumber
  or si,si
  jz @settheperiod
  mov [di+lastsample],si
  dec si
  shl si,1
  mov ax,[di+channelvolume]
  cmp effect,$0c
  je @skipvol
  mov ax,[offset samplevolume+si]
  mov [di+channelvolume],ax
  @skipvol:
  mov [di+VUbar],ax
  mov ax,[offset sampleseg+si]
  mov [di+channelseg],ax
  mov ax,[offset samplelength+si]
  mov [di+channelsize],ax
  mov ax,[offset samprep+si]
  mov [di+channelrep],ax
  mov ax,[offset sampreplen+si]
  mov [di+channelreplen],ax
  mov word ptr [di+channelblip],0
  mov word ptr [di+channelpos],0
  mov bx,noteperiod
  or bx,bx
  jz @periodzero
  mov cx,36
  mov si,offset @periodtable0
  @seek:
  cmp [cs:si],bx
  je @wefounditwedid
  add si,2
  loop @seek
  jmp @ohwellforgetitthenreally
  @wefounditwedid:
  mov ax,72 {bytes in a periodtable}
  mov dx,[di+channeltuning]
  mul dl
  add si,ax
  mov bx,[cs:si]
  @ohwellforgetitthenreally:
  mov [di+channelperiod],bx
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  @periodzero:
  cmp infobyte,0
  xor ax,ax
  mov [di+arpeggiostuff],ax
  mov [di+arpeggiostuff+2],ax
  je @donearp
  mov ax,infobyte
  mov ah,al
  and ax,$f00f
  mov [di+arpeggiostuff+2],ax
  mov word ptr [di+effecttype],7
  mov ax,tempo
  mov [di+effectcounter],ax
  @donearp:
  retn
  @settheperiod:
  mov bx,noteperiod
  or bx,bx
  jz @donesetperiod
  mov bx,[di+lastsample]
  or bx,bx
  jz @wewilljustsettheperiod
  mov samplenumber,bx
  jmp @playarpeggio
  @wewilljustsettheperiod:
  mov cx,36
  mov si,offset @periodtable0
  @fseek:
  cmp [cs:si],bx
  je @wefoundit
  add si,2
  loop @fseek
  jmp @ohwellforgetitthen
  @wefoundit:
  mov ax,72 {bytes in a periodtable}
  mov dx,[di+channeltuning]
  mul dl
  add si,ax
  mov bx,[cs:si]
  @ohwellforgetitthen:
  or bx,bx
  jz @donesetperiod
  mov [di+channelperiod],bx
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  mov ax,[di+channelvolume]
  mov [di+VUBar],ax
  @donesetperiod:
  retn

  @pitchup:
  mov ax,tempo
  dec ax
  mov [di+effectcounter],ax
  mov ax,infobyte
  mov [di+portaspeed],ax
  mov word ptr [di+effecttype],1
  mov word ptr [di+portadest],108
  jmp @doarpeggio

  @pitchdown:
  mov ax,tempo
  dec ax
  mov [di+effectcounter],ax
  mov ax,infobyte
  mov [di+portaspeed],ax
  mov word ptr [di+effecttype],2
  mov word ptr [di+portadest],907
  jmp @doarpeggio

  @portamento:
  mov ax,tempo
  dec ax
  mov [di+effectcounter],ax
  mov ax,infobyte
  mov [di+portaspeed],ax
  mov ax,noteperiod
  cmp ax,[di+channelperiod]
  jb @wewannagoup
  cmp ax,907
  jb @wewannagodownok
  mov ax,907
  @wewannagodownok:
  mov word ptr [di+effecttype],2
  mov word ptr [di+portadest],ax
  retn
  @wewannagoup:
  cmp ax,108
  jg @wewannagoupok
  mov ax,108
  @wewannagoupok:
  mov word ptr [di+effecttype],1
  mov word ptr [di+portadest],ax
  retn

  @playvibrato:
  mov word ptr [di+effecttype],8
  mov ax,tempo
  dec ax
  mov word ptr [di+effectcounter],ax
  mov ax,infobyte
  or ax,ax
  jz @donevibrato
  mov bx,ax
  and ax,$00f0
  and bx,$000f
  shl bx,1
  mov cl,4; { <<< TT added this. }
  shr ax,cl; { <<< TT changed this. }
  mov word ptr [di+vibratospeed],ax
  mov word ptr [di+vibratodepth],bx
  @donevibrato:
  jmp @doarpeggio

  @playtremolo:
  mov word ptr [di+effecttype],9
  mov ax,tempo
  dec ax
  mov word ptr [di+effectcounter],ax
  mov ax,infobyte
  or ax,ax
  jz @donetremolo
  mov bx,ax
  and ax,$00f0
  and bx,$000f
  shl bx,1
  mov cl,4; { <<< TT changed this. }
  shr ax,cl; { <<< TT changed this. }
  mov word ptr [di+vibratospeed],ax
  mov word ptr [di+vibratodepth],bx
  @donetremolo:
  jmp @doarpeggio

  @portavolume:
  mov ax,tempo
  dec ax
  mov [di+effectcounter],ax
  mov ax,infobyte
  test ax,$00f0
  jz @slidedownporta
  test ax,$000f
  jnz @doarpeggio
  and ax,$00f0
  mov cl,4;
  shr ax,cl { <<< TT changed this. }
  mov [di+effectoperand],ax
  mov word ptr [di+effecttype],5
  jmp @doarpeggio
  @slidedownporta:
  and ax,$000f
  jz @doarpeggio
  mov [di+effectoperand],ax
  mov word ptr [di+effecttype],6
  jmp @doarpeggio

  @sampleoffset:
  cmp noteperiod,0
  je @donesofssmelly
  mov si,samplenumber
  or si,si
  jz @donesofssmelly
  dec si
  shl si,1
  cmp effect,$0c
  je @skipvol2
  mov ax,[offset samplevolume+si]
  mov [di+channelvolume],ax
  @skipvol2:
  mov [di+VUbar],ax
  mov ax,[offset sampleseg+si]
  mov [di+channelseg],ax
  mov ax,[offset samplelength+si]
  mov [di+channelsize],ax
  mov ax,[offset samprep+si]
  mov [di+channelrep],ax
  mov ax,[offset sampreplen+si]
  mov [di+channelreplen],ax
  xor ax,ax
  mov [di+channelblip],ax
  mov ax,infobyte
  mov bl,200
  mul bl
  mov [di+channelpos],ax
  mov bx,noteperiod
  mov [di+channelperiod],bx
  mov ax,[offset mainfreq]
  mov dx,[offset mainfreq+2]
  div bx
  xchg al,ah
  mov [di+channelspeed],ax
  retn
  @donesofssmelly:
  retn

  @volumeslide:
  mov ax,tempo
  dec ax
  mov [di+effectcounter],ax
  mov ax,infobyte
  test ax,$000f
  jnz @slidedown
  and ax,$00f0
  or ax,ax
  jz @doarpeggio
  mov cl,4
  shr ax,cl { <<< TT changed this. }
  mov [di+effectoperand],ax
  mov word ptr [di+effecttype],3
  jmp @doarpeggio
  @slidedown:
  and ax,$000f
  jz @doarpeggio
  mov [di+effectoperand],ax
  mov word ptr [di+effecttype],4
  jmp @doarpeggio

  @positionjump:
  test status,nojumping
  jnz @hopskipandjump
  mov ax,infobyte
  dec ax
  mov currentpattern,ax
  @hopskipandjump:
  mov patternbeat,1024
  jmp @doarpeggio

  @volumeset:
  mov ax,infobyte
  cmp ax,64
  jbe @volok2
  mov ax,64
  @volok2:
  mov [di+channelvolume],ax
  jmp @doarpeggio

  @patternbreak:
  mov patternbeat,1024
  jmp @doarpeggio

  @setspeed:
  mov ax,infobyte
  or ax,ax
  jz @skipdecspeed
  @skipdecspeed:
  mov tempo,ax
  mov retracestilbeat,ax
  jmp @doarpeggio

  @domusicX:
  mov si,patternbeat
  mov ah,es:[si]
  xor cx,cx
  mov cl,ah
  and cl,$F0
  and ah,$0F
  inc si
  mov al,es:[si]
  mov noteperiod,ax
  xor ax,ax
  inc si
  mov al,es:[si]
  mov bx,ax
  push cx
  mov cl,4
  shr al,cl
  pop cx
  or cl,al
  mov samplenumber,cx
  and bx,$0F
  mov effect,bx
  inc si
  mov al,es:[si]
  inc si
  mov infobyte,ax
  mov patternbeat,si
  shl bx,1
  add bx,offset @commandjumptable
  mov ax,[cs:bx]
  push ax
  retn

{-=ðÛ Sequencer section ends here, and periodtables and such start... Ûð=-}

  @periodtable0:
    {Tuning +0 - %0000}
    dw 856,808,762,720,678,640,604,570,538,508,480,453
    dw 428,404,381,360,339,320,302,285,269,254,240,226
    dw 214,202,190,180,170,160,151,143,135,127,120,113
    {Tuning +1 - %0001}
    dw 850,802,757,715,674,637,601,567,535,505,477,450
    dw 425,401,379,357,337,318,300,284,268,253,239,225
    dw 213,201,189,179,169,159,150,142,134,126,119,113
    {Tuning +2 - %0010}
    dw 844,796,752,709,670,632,597,563,532,502,474,447
    dw 422,398,376,355,335,316,298,282,266,251,237,224
    dw 211,199,188,177,167,158,149,141,133,125,118,112
    {Tuning +3 - %0011}
    dw 838,791,746,704,665,628,592,559,528,498,470,444
    dw 419,395,373,352,332,314,296,280,264,249,235,222
    dw 209,198,187,176,166,157,148,140,132,125,118,111
    {Tuning +4 - %0100}
    dw 832,785,741,699,660,623,588,555,524,495,467,441
    dw 416,392,370,350,330,312,294,278,262,247,233,220
    dw 208,196,185,175,165,156,147,139,131,124,117,110
    {Tuning +5 - %0101}
    dw 826,779,736,694,655,619,584,551,520,491,463,437
    dw 413,390,368,347,328,309,292,276,260,245,232,219
    dw 206,195,184,174,164,155,146,138,130,123,116,109
    {Tuning +6 - %0110}
    dw 820,774,730,689,651,614,580,547,516,487,460,434
    dw 410,387,365,345,325,307,290,274,258,244,230,217
    dw 205,193,183,172,163,154,145,137,129,122,115,109
    {Tuning +7 - %0111}
    dw 814,768,725,684,646,610,575,543,513,484,457,431
    dw 407,384,363,342,323,305,288,272,256,242,228,216
    dw 204,192,181,171,161,152,144,136,128,121,114,108
    {Tuning -8 - %1000}
    dw 907,856,808,762,720,678,640,604,570,538,508,480
    dw 453,428,404,381,360,339,320,302,285,269,254,240
    dw 226,214,202,190,180,170,160,151,143,135,127,120
    {Tuning -7 - %1001}
    dw 900,850,802,757,715,675,636,601,567,535,505,477
    dw 450,425,401,379,357,337,318,300,284,268,253,238
    dw 225,212,200,189,179,169,159,150,142,134,126,119
    {Tuning -6 - %1010}
    dw 894,844,796,752,709,670,632,597,563,532,502,474
    dw 447,422,398,376,355,335,316,298,282,266,251,237
    dw 223,211,199,188,177,167,158,149,141,133,125,118
    {Tuning -5 - %1011}
    dw 887,838,791,746,704,665,628,592,559,528,498,470
    dw 444,419,395,373,352,332,314,296,280,264,249,235
    dw 222,209,198,187,176,166,157,148,140,132,125,118
    {Tuning -4 - %1100}
    dw 881,832,785,741,699,660,623,588,555,524,494,467
    dw 441,416,392,370,350,330,312,294,278,262,247,233
    dw 220,208,196,185,175,165,156,147,139,131,123,117
    {Tuning -3 - %1101}
    dw 875,826,779,736,694,655,619,584,551,520,491,463
    dw 437,413,390,368,347,328,309,292,276,260,245,232
    dw 219,206,195,184,174,164,155,146,138,130,123,116
    {Tuning -2 - %1110}
    dw 868,820,774,730,689,651,614,580,547,516,487,460
    dw 434,410,387,365,345,325,307,290,274,258,244,230
    dw 217,205,193,183,172,163,154,145,137,129,122,115
    {Tuning -1 - %1111}
    dw 862,814,768,725,684,646,610,575,543,513,484,457
    dw 431,407,384,363,342,323,305,288,272,256,242,228
    dw 216,203,192,181,171,161,152,144,136,128,121,114

    @vibratotable:
    db   0, 24, 49, 74, 97,120,141,161,180,197,212,224,235,244,250,253
    db 255,253,250,244,235,224,212,197,180,161,141,120, 97, 74, 49, 24
    db   0, 24, 49, 74, 97,120,141,161,180,197,212,224,235,244,250,253
    db 255,253,250,244,235,224,212,197,180,161,141,120, 97, 74, 49, 24

  @playnote:
  @out:
end;

{
        Interrupt $69 handler functions:

        $00 : report presence and version of handler
              In  : AH=$00
              Out : AX=$4347, BX=(Version*256)
        $01 : initialise hardware
              In  : AH=$01, CX=buffersize, BX=samplerate, ES:DI->dmabuffer of length CX bytes
              Out : AX=hw irq number, BX=hw dma channel, DX=hw address
        $02 : set output volume, bass, treble
              In  : AH=$02, AL=Volume (0-255), BH=Treble (0-255), BL=Bass (0-255)
              Out : none
        $03 : play dmabuffer
              In  : AH=$03, BX=offset from start of buffer
              Out : none
        $04 : kill hardware
              In  : AH=$04
              Out : none
}

procedure SetDMAVariables; assembler;
asm
  mov bx,hwdma
  test bx,3
  jz @exit
  and bx,7
  shl bx,1
  mov ax,offset @exit
  push ax
  mov ax,word ptr [cs:bx+@jumptable]
  push ax
  retn

  @jumptable:
  dw @channel0
  dw @channel1
  dw @channel2
  dw @channel3
  dw @channel4
  dw @channel5
  dw @channel6
  dw @channel7

  @channel0:
  retn

  @channel1:
  mov dmawritesinglemask,$0a
  mov dmawritemode,$0b
  mov dmapagereg,$83
  mov dmaclear,$0c
  mov dmaaddress,$02
  mov dmalength,$03
  mov dmabufferlengthscale,0
  retn

  @channel2:
  mov dmawritesinglemask,$0a
  mov dmawritemode,$0b
  mov dmapagereg,$81
  mov dmaclear,$0c
  mov dmaaddress,$04
  mov dmalength,$05
  mov dmabufferlengthscale,0
  retn

  @channel3:
  mov dmawritesinglemask,$0a
  mov dmawritemode,$0b
  mov dmapagereg,$82
  mov dmaclear,$0c
  mov dmaaddress,$06
  mov dmalength,$07
  mov dmabufferlengthscale,0
  retn

  @channel4:
  retn

  @channel5:
  mov dmawritesinglemask,$d4
  mov dmawritemode,$d6
  mov dmapagereg,$8b
  mov dmaclear,$d8
  mov dmaaddress,$c4
  mov dmalength,$c6
  mov dmabufferlengthscale,1
  retn

  @channel6:
  mov dmawritesinglemask,$d4
  mov dmawritemode,$d6
  mov dmapagereg,$89
  mov dmaclear,$d8
  mov dmaaddress,$c8
  mov dmalength,$ca
  mov dmabufferlengthscale,1
  retn

  @channel7:
  mov dmawritesinglemask,$d4
  mov dmawritemode,$d6
  mov dmapagereg,$8a
  mov dmaclear,$d8
  mov dmaaddress,$cc
  mov dmalength,$ce
  mov dmabufferlengthscale,1
  retn

  @exit:
end;

procedure SetIRQVariables; assembler;
asm
  mov ax,hwirq
  test al,8
  jnz @highorderirq
  mov irqaddress,$08
  add irqaddress,ax
  mov cl,2
  shl irqaddress,cl
  mov ackport,$20
  mov enableport,$21
  jmp @exit
  @highorderirq:
  mov irqaddress,$70
  and ax,7
  add irqaddress,ax
  mov cl,2
  shl irqaddress,cl
  mov ackport,$a0
  mov enableport,$a1
  @exit:
end;


procedure MonoDMAOutput(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word); interrupt; assembler;
asm
  mov bx,bufstart
  mov dx,$0300
  int $69

  xor bufstart,(buffersize+1)
  mov ax,buffersize
  mov bufofs,0
  cld
  mov ax,dmabufferseg
  mov es,ax
  mov di,dmabufferofs
  add di,bufstart
  @loop:
  push di
  call far ptr PutAByteInTheBuffer
  pop di
  mov al,monodata
  xor al,$80
  stosb
  inc bufofs
  cmp bufofs,buffersize
  jbe @loop
  mov si,bufstart
  mov scopeptr,si
  mov al,$20
  mov dx,ackport
  out dx,al
end;

procedure StereoDMAOutput(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word); interrupt; assembler;
asm
  mov bx,bufstart
  mov dx,$0300
  int $69

  xor bufstart,(buffersize+1)
  mov ax,buffersize
  mov bufofs,0
  cld
  mov ax,dmabufferseg
  mov es,ax
  mov di,dmabufferofs
  add di,bufstart
  @loop:
  push es
  push di
  call far ptr PutAByteInTheBuffer
  pop di
  pop es
  mov ax,leftdata
  mov bx,rightdata
  sar al,1
  sar bl,1
  add al,bl
  xor al,$80
  stosb
  inc bufofs
  cmp bufofs,buffersize
  jbe @loop
  mov si,bufstart
  mov scopeptr,si
  mov al,$20
  mov dx,ackport
  out dx,al
end;

procedure ByteByByteOutput(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
interrupt; assembler;
asm
  test status,Mixer
  jz @out
  call far ptr PutAByteInTheBuffer

  mov ax,freddict
  mov bufstart,ax
  inc bufstart
  and bufstart,buffersize
  mov ax,dmabufferseg
  mov es,ax
  mov di,dmabufferofs
  add di,bufstart
  mov al,monodata
  xor al,$80
  stosb
  mov ax,bufstart
  mov freddict,ax
  mov bufstart,0

  push cs
  mov ax,offset @out
  push ax
  push opseg
  push opofs
  retf

  @out:
  mov ax,timerticks
  add ax,samplerate
  mov timerticks,ax
  jc @calloldhandler
  mov al,$20
  out $20,al
  jmp @exit

  @calloldhandler:
  leave
  pop es
  pop ds
  pop di
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  mov word ptr [cs:@tempstore],ax
  mov ax,word ptr [cs:@oldhandlerseg]
  push ax
  mov ax,word ptr [cs:@oldhandlerofs]
  push ax
  mov ax,word ptr [cs:@tempstore]
  retf

  @tempstore:
  dw $bead

  @outputofs:
  dw $feed
  @outputseg:
  dw $feed

  @oldhandlerofs:
  dw $dead
  @oldhandlerseg:
  dw $dead

  @exit:
end;

procedure ProAudioSpectrum_InterruptHandler(Flags, CS, IP, AX, BX, CX,
                                            DX, SI, DI, DS, ES, BP: Word);
                                            interrupt; assembler;
const     handlerversion                    = $100;
asm
  cli
  mov ax,dx
  cmp ah,$00
  je @reportpresence
  cmp ah,$01
  je @initialisehardware
  cmp ah,$02
  je @setvolume
  cmp ah,$03
  je @startplaying
  cmp ah,$04
  je @killhardware
  {if we've gotten here then it's an unrecognised command...ignore it...}
  jmp @exit

  @reportpresence:
  mov ax,$4347
  mov bx,handlerversion
  jmp @exit

  @irq3test:
  pusha
  mov dx,$b89
  in al,dx
  test al,$08
  jz @notirq3
  out dx,al
  mov hwirq,3
  xor bx,bx
  call @playbuffer
  @notirq3:
  mov al,$20
  out $20,al
  popa
  iret

  @irq5test:
  pusha
  mov dx,$b89
  in al,dx
  test al,$08
  jz @notirq5
  out dx,al
  mov hwirq,5
  xor bx,bx
  call @playbuffer
  @notirq5:
  mov al,$20
  out $20,al
  popa
  iret

  @irq6test:
  pusha
  mov dx,$b89
  in al,dx
  test al,$08
  jz @notirq6
  out dx,al
  mov hwirq,6
  xor bx,bx
  call @playbuffer
  @notirq6:
  mov al,$20
  out $20,al
  popa
  iret

  @irq7test:
  pusha
  mov dx,$b89
  in al,dx
  test al,$08
  jz @notirq7
  out dx,al
  mov hwirq,7
  xor bx,bx
  call @playbuffer
  @notirq7:
  mov al,$20
  out $20,al
  popa
  iret

  @saveirqvectors:
  dd $feedbbc1
  dd $beadbbc2
  dd $deadbbc3
  dd $beebbbc4

  @detectirqnumber: {DMA-variables MUST have been previously set}
  mov dx,$f88
  mov al,$80
  out dx,al
  mov hwirq,0
  cli
  in al,$21
  and al,$fc
  mov cl,al
  mov al,$fc
  out $21,al
  push es
  push $0000
  pop es
  mov bx,cs
  mov ax,[es:$002c]
  mov dx,[es:$002e]
  mov [cs:offset @saveirqvectors+$00],ax
  mov [cs:offset @saveirqvectors+$02],dx
  mov word ptr [es:$002c],offset @irq3test
  mov word ptr [es:$002e],bx
  mov ax,[es:$0034]
  mov dx,[es:$0036]
  mov [cs:offset @saveirqvectors+$04],ax
  mov [cs:offset @saveirqvectors+$06],dx
  mov word ptr [es:$0034],offset @irq5test
  mov word ptr [es:$0036],bx
  mov ax,[es:$0038]
  mov dx,[es:$003a]
  mov [cs:offset @saveirqvectors+$08],ax
  mov [cs:offset @saveirqvectors+$0a],dx
  mov word ptr [es:$0038],offset @irq6test
  mov word ptr [es:$003a],bx
  mov ax,[es:$003c]
  mov dx,[es:$003e]
  mov [cs:offset @saveirqvectors+$0c],ax
  mov [cs:offset @saveirqvectors+$0e],dx
  mov word ptr [es:$003c],offset @irq7test
  mov word ptr [es:$003e],bx
  mov al,cl
  and al,00010111b
  out $21,al
  sti
  {right...we've taken over the irqs...and enabled them...lets stir!}
  xor bx,bx
  call @playbuffer
  mov dx,$3da
  xor bx,bx
  @waitfordatareq:
  @wloop1:
  in al,dx
  test al,8
  jnz @wloop1
  @wloop2:
  in al,dx
  test al,8
  jz @wloop2
  inc bx
  cmp hwirq,0
  jne @allunitstorunway5
  cmp bx,70
  jb @waitfordatareq
  {WHAMMO! we've got a datareq coming in hot on runway [hwirq]}
  {engage crash-barriers...<whining of strained motors>}
  @allunitstorunway5:
  mov ax,[cs:offset @saveirqvectors+$00]
  mov dx,[cs:offset @saveirqvectors+$02]
  mov [es:$002c],ax
  mov [es:$002e],dx
  mov ax,[cs:offset @saveirqvectors+$04]
  mov dx,[cs:offset @saveirqvectors+$06]
  mov [es:$0034],ax
  mov [es:$0036],dx
  mov ax,[cs:offset @saveirqvectors+$08]
  mov dx,[cs:offset @saveirqvectors+$0a]
  mov [es:$0038],ax
  mov [es:$003a],dx
  mov ax,[cs:offset @saveirqvectors+$0c]
  mov dx,[cs:offset @saveirqvectors+$0e]
  mov [es:$003c],ax
  mov [es:$003e],dx
  {crash-barriers engaged. Ready FireCrews}
  mov bl,0
  mov si,hwirq
  or si,si
  jz @abortrescueattempt
  add si,$0008
  mov cl,2
  shl si,cl
  mov ax,[es:si+0]
  mov dx,[es:si+2]
  mov [cs:offset @saveirqvectors+0],ax
  mov [cs:offset @saveirqvectors+2],dx
  mov ax,[offset datareqhandler+0]
  mov dx,[offset datareqhandler+2]
  mov [es:si+0],ax
  mov [es:si+2],dx
  {FireCrews readied}
  mov bl,1
  @abortrescueattempt:
  mov al,cl
  mov cx,hwirq
  shl bl,cl
  not bl
  and al,bl
  out $21,al
  {it's down...the pilot's safe...this time...right folks...you can all go}
  {home now...the drama's over...}
  pop es
  retn

  @initialisehardware:
  mov dmabuffersize,cx
  mov dx,$0012
  mov ax,$34dc
  div bx
  mov bx,ax
  mov al,$36
  mov dx,$138b
  out dx,al
  mov ax,bx
  mov dx,$1388
  out dx,al
  xchg al,ah
  out dx,al
  mov al,$74
  mov dx,$138b
  out dx,al
  mov dx,$1389
  mov ax,cx
  inc ax
  out dx,al
  xchg al,ah
  out dx,al
  mov dx,$b8b
  in al,dx
  or al,$08
  out dx,al
  mov dx,$f8a
  mov al,$f9
  out dx,al
  mov dx,$b8a
  mov al,$e1
  out dx,al
  mov ax,es
  mov dx,ax
  rol dx,4
  and dx,$000f {get page of memory}
  mov cl,4
  shl ax,cl
  add di,ax
  adc dx,0
  mov word ptr [linbufptr+0],di
  mov word ptr [linbufptr+2],dx
  mov ax,dmabufferseg
  mov es,ax
  mov di,dmabufferofs
  mov cx,dmabuffersize
  mov ax,$8080
  shr cx,1
  cld
  rep stosw
  {lets go folks...time to go irqhunting...}
  mov hwdma,1
  mov ax,offset MonoDMAOutput
  mov dx,seg MonoDMAOutput
  mov word ptr [datareqhandler+0],ax
  mov word ptr [datareqhandler+2],dx
  call far ptr SetDMAVariables
  call @detectirqnumber
  call far ptr SetIRQVariables
  jmp @exit

  @setvolume:
  jmp @exit

  {@playbuffer. Entry  : BX=Offset from buffer pointed to by linbuffer.
                          Must be in the same page of memory.
                Exit   : none
                Trashes: AX, DX, flags}

  @playbuffer:
  mov dx,$b89
  in al,dx
  out dx,al

  mov ax,hwdma
  and ax,$0003
  or ax,$4
  mov dx,dmawritesinglemask
  out dx,al
  mov ax,$48
  or ax,hwdma
  mov dx,dmawritemode
  out dx,al
  mov ax,word ptr [linbufptr+2]
  mov dx,dmapagereg
  out dx,al
  mov dx,dmaclear
  out dx,al
  mov ax,word ptr [linbufptr+0]
  add ax,bx
  mov dx,dmaaddress
  out dx,al
  xchg al,ah
  out dx,al
  mov dx,dmalength
  mov ax,buffersize
  inc ax
  out dx,al
  xchg al,ah
  out dx,al
  mov dx,$f8a
  in al,dx
  or al,$80
  out dx,al
  mov ax,hwdma
  and ax,$0003
  mov dx,dmawritesinglemask
  out dx,al
  retn

  @startplaying:
  call @playbuffer
  jmp @exit

  @killhardware:
  mov dx,$b8a
  mov al,$21
  out dx,al
  mov dx,$f8a
  mov al,$19
  out dx,al
  mov dx,$b8b
  in al,dx
  and al,$f3
  out dx,al
  mov dx,$21
  in al,dx
  mov bl,al
  mov al,1
  mov cx,hwirq
  shl al,cl
  or al,bl
  and al,$fc
  out dx,al
  mov ax,hwdma
  and al,3
  or al,4
  mov dx,dmawritesinglemask
  out dx,al
  push es
  push $0000
  pop es
  mov si,hwirq
  add si,$0008
  shl si,2
  mov ax,[cs:offset @saveirqvectors+0]
  mov dx,[cs:offset @saveirqvectors+2]
  mov [es:si+0],ax
  mov [es:si+2],dx
  pop es
  jmp @exit

  @exit:
  sti
end;

procedure SoundBlaster_InterruptHandler(Flags, CS, IP, AX, BX, CX,
                                        DX, SI, DI, DS, ES, BP: Word);
                                        interrupt; assembler;
const     handlerversion                    = $100;
asm
  cli
  mov ax,dx
  cmp ah,$00
  je @reportpresence
  cmp ah,$01
  je @initialisehardware
  cmp ah,$02
  je @setvolume
  cmp ah,$03
  je @startplaying
  cmp ah,$04
  je @killhardware
  {if we've gotten here then it's an unrecognised command...ignore it...}
  jmp @exit

  @reportpresence:
  mov ax,$4347
  mov bx,handlerversion
  jmp @exit

  @irq2test:
  pusha
  mov hwirq,2
  xor bx,bx
  call @playbuffer
  mov al,$20
  out $20,al
  popa
  iret

  @irq3test:
  pusha
  mov hwirq,3
  xor bx,bx
  call @playbuffer
  mov al,$20
  out $20,al
  popa
  iret

  @irq5test:
  pusha
  mov hwirq,5
  xor bx,bx
  call @playbuffer
  mov al,$20
  out $20,al
  popa
  iret

  @irq7test:
  pusha
  mov hwirq,7
  xor bx,bx
  call @playbuffer
  mov al,$20
  out $20,al
  popa
  iret

  @saveirqvectors:
  dd $feedbbc1
  dd $beadbbc2
  dd $deadbbc3
  dd $beebbbc4

  @detectirqnumber: {DMA-variables MUST have been previously set}
  mov hwirq,0
  cli
  in al,$21
  and al,$fc
  mov cl,al
  mov al,$fc
  out $21,al
  push es
  push $0000
  pop es
  mov bx,cs
  mov ax,[es:$0028]
  mov dx,[es:$002a]
  mov [cs:offset @saveirqvectors+$00],ax
  mov [cs:offset @saveirqvectors+$02],dx
  mov word ptr [es:$0028],offset @irq2test
  mov word ptr [es:$002a],bx
  mov ax,[es:$002c]
  mov dx,[es:$002e]
  mov [cs:offset @saveirqvectors+$04],ax
  mov [cs:offset @saveirqvectors+$06],dx
  mov word ptr [es:$002c],offset @irq3test
  mov word ptr [es:$002e],bx
  mov ax,[es:$0034]
  mov dx,[es:$0036]
  mov [cs:offset @saveirqvectors+$08],ax
  mov [cs:offset @saveirqvectors+$0a],dx
  mov word ptr [es:$0034],offset @irq5test
  mov word ptr [es:$0036],bx
  mov ax,[es:$003c]
  mov dx,[es:$003e]
  mov [cs:offset @saveirqvectors+$0c],ax
  mov [cs:offset @saveirqvectors+$0e],dx
  mov word ptr [es:$003c],offset @irq7test
  mov word ptr [es:$003e],bx
  mov al,cl
  and al,01010000b
  out $21,al
  sti
  {right...we've taken over the irqs...and enabled them...lets stir!}
  xor bx,bx
  call @playbuffer
  mov ax,[es:$046c]
  add ax,20
  @waitfordatareq:
  @wloop1:
  cmp hwirq,0
  jne @allunitstorunway5
  mov dx,[es:$046c]
  cmp dx,ax
  jb @wloop1
  mov bx,70
  {WHAMMO! we've got a datareq coming in hot on runway [hwirq]}
  {engage crash-barriers...<whining of strained motors>}
  @allunitstorunway5:
  mov ax,[cs:offset @saveirqvectors+$00]
  mov dx,[cs:offset @saveirqvectors+$02]
  mov [es:$0028],ax
  mov [es:$002a],dx
  mov ax,[cs:offset @saveirqvectors+$04]
  mov dx,[cs:offset @saveirqvectors+$06]
  mov [es:$002c],ax
  mov [es:$002e],dx
  mov ax,[cs:offset @saveirqvectors+$08]
  mov dx,[cs:offset @saveirqvectors+$0a]
  mov [es:$0034],ax
  mov [es:$0036],dx
  mov ax,[cs:offset @saveirqvectors+$0c]
  mov dx,[cs:offset @saveirqvectors+$0e]
  mov [es:$003c],ax
  mov [es:$003e],dx
  {crash-barriers engaged. Ready FireCrews}
  mov bl,0
  mov si,hwirq
  or si,si
  jz @abortrescueattempt
  add si,$0008
  shl si,2
  mov ax,[es:si+0]
  mov dx,[es:si+2]
  mov [cs:offset @saveirqvectors+0],ax
  mov [cs:offset @saveirqvectors+2],dx
  mov ax,[offset datareqhandler+0]
  mov dx,[offset datareqhandler+2]
  mov [es:si+0],ax
  mov [es:si+2],dx
  {FireCrews readied}
  mov bl,1
  @abortrescueattempt:
  mov al,cl
  mov cx,hwirq
  shl bl,cl
  not bl
  and al,bl
  out $21,al
  {it's down...the pilot's safe...this time...right folks...you can all go}
  {home now...the drama's over...}
  pop es
  retn

  @initialisehardware:
  mov dmabuffersize,cx
  mov hwport,$220
  push di
  mov ax,es
  mov dx,ax
  rol dx,4
  and dx,$000f {get page of memory}
  shl ax,4
  add di,ax
  adc dx,0
  mov word ptr [linbufptr+0],di
  mov word ptr [linbufptr+2],dx
  pop di
  mov ax,$8080
  mov cx,((buffersize+1)*bufdiv) shr 1
  cld
  rep stosw
  {lets go folks...time to go irqhunting...}
  mov hwdma,1
  mov ax,offset MonoDMAOutput
  mov dx,seg MonoDMAOutput
  mov word ptr [datareqhandler+0],ax
  mov word ptr [datareqhandler+2],dx
  call far ptr SetDMAVariables
  call @detectirqnumber
  call far ptr SetIRQVariables
  jmp @exit

  @setvolume:
  jmp @exit

  {@playbuffer. Entry  : BX=Offset from buffer pointed to by linbuffer.
                          Must be in the same page of memory.
                Exit   : none
                Trashes: AX, DX, flags}

  @playbuffer:
  mov dx,hwport
  add dx,$000e
  in al,dx
  {if we're here, we need another dumpout of data to the dmac}
  {so do it...}
  mov ax,hwdma
  and ax,$0003
  or al,$04
  mov dx,dmawritesinglemask
  out dx,al
  mov al,$00
  mov dx,dmaclear
  out dx,al
  mov al,$49
  mov dx,dmawritemode
  out dx,al
  mov ax,[offset linbufptr]
  add ax,bx
  mov dx,dmaaddress
  out dx,al
  xchg al,ah
  out dx,al
  mov ax,[offset linbufptr+2]
  mov dx,dmapagereg
  out dx,al
  mov ax,buffersize
  mov dx,dmalength
  out dx,al
  xchg al,ah
  out dx,al
  mov ax,hwdma
  and ax,$0003
  mov dx,dmawritesinglemask
  out dx,al
  {right...we've set up the DMAC, now lets bugger about with the DSP}
  mov dx,hwport
  add dx,$000c
  @il1:
  in al,dx
  test al,$80
  jnz @il1
  mov al,$40
  out dx,al
  @il2:
  in al,dx
  test al,$80
  jnz @il2
  mov al,timeconst
  out dx,al
  @il3:
  in al,dx
  test al,$80
  jnz @il3
  mov al,$14
  out dx,al
  @il4:
  in al,dx
  test al,$80
  jnz @il4
  mov ax,buffersize
  out dx,al
  @il5:
  in al,dx
  test al,$80
  jnz @il5
  xchg al,ah
  out dx,al
  retn

  @startplaying:
  call @playbuffer
  jmp @exit

  @killhardware:
  mov dx,$21
  in al,dx
  mov bl,al
  mov al,1
  mov cx,hwirq
  shl al,cl
  or al,bl
  and al,$fc
  out dx,al
  mov ax,hwdma
  and al,3
  or al,4
  mov dx,dmawritesinglemask
  out dx,al
  jmp @exit

  @exit:
  sti
end;

procedure Beeper_InterruptHandler(Flags, CS, IP, AX, BX, CX,
                               DX, SI, DI, DS, ES, BP: Word);
                               interrupt; assembler;
const     handlerversion                    = $100;
asm
  cli
  mov ax,dx
  cmp ah,$00
  je @reportpresence
  cmp ah,$01
  je @initialisehardware
  cmp ah,$02
  je @setvolume
  cmp ah,$03
  je @startplaying
  cmp ah,$04
  je @killhardware
  {if we've gotten here then it's an unrecognised command...ignore it...}
  jmp @exit

  @reportpresence:
  mov ax,$4347
  mov bx,handlerversion
  jmp @exit

  @saveirqvectors:
  dd $feedbbc1

  @initialisehardware:
  mov dmabuffersize,cx
  mov dx,$0012
  mov ax,$34dc
  div bx
  mov bx,ax
  mov samptest,al
  cli
  mov al,$36
  mov dx,$43
  out dx,al
  mov dx,$40
  mov ax,bx
  out dx,al
  xchg al,ah
  out dx,al
  mov ax,$8080
  shr cx,1
  cld
  rep stosw
  {lets go folks...time to go irqhunting...}
  push es
  push $0000
  pop es
  mov bx,cs
  mov ax,[es:$0020]
  mov dx,[es:$0022]
  mov [cs:offset @saveirqvectors+$00],ax
  mov [cs:offset @saveirqvectors+$02],dx
  mov word ptr [es:$0020],offset ByteByByteOutput
  mov word ptr [es:$0022],bx
  mov opseg,cs
  mov opofs,offset @playbuffer
  pop es
  sti
  mov al,$B0
  out $43,al
  xor ax,ax
  out $42,al
  xchg al,ah
  jmp @round
  @round:
  out $42,al
  jmp @and
  @and:
  mov al,$90
  out $43,al
  jmp @roundthe
  @roundthe:
  xor al,ah
  out $42,al
  jmp @mulberrybush
  @mulberrybush:
  in al,$61
  or al,00000011b
  out $61,al
  jmp @exit

  @setvolume:
  jmp @exit

  @playbuffer:
  xor bx,bx
  xor ax,ax
  mov bl,monodata
  add bx,offset @BeeperTable
  mov al,[cs:bx]
  mul samptest
  xchg al,ah
  out $42,al
  retf

  @beepertable:
  db $81,$83,$85,$87,$89,$8B,$8D,$8F,$90,$92,$94,$96,$98,$9A,$9B,$9D
  db $9F,$A1,$A2,$A4,$A6,$A7,$A9,$AB,$AC,$AE,$AF,$B1,$B3,$B4,$B6,$B7
  db $B9,$BA,$BC,$BD,$BF,$C0,$C1,$C3,$C4,$C5,$C7,$C8,$C9,$CB,$CC,$CD
  db $CF,$D0,$D1,$D2,$D3,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
  db $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$E9,$EA,$EB,$EC,$ED,$ED
  db $EE,$EF,$F0,$F0,$F1,$F2,$F2,$F3,$F4,$F4,$F5,$F5,$F6,$F6,$F7,$F7
  db $F8,$F8,$F9,$F9,$FA,$FA,$FB,$FB,$FB,$FC,$FC,$FC,$FD,$FD,$FD,$FD
  db $FE,$FE,$FE,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
  db $03,$03,$03,$03,$04,$04,$04,$05,$05,$05,$06,$06,$07,$07,$08,$08
  db $09,$09,$0A,$0A,$0B,$0B,$0C,$0C,$0D,$0E,$0E,$0F,$10,$10,$11,$12
  db $13,$13,$14,$15,$16,$17,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
  db $21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2D,$2E,$2F,$30,$31
  db $33,$34,$35,$37,$38,$39,$3B,$3C,$3D,$3F,$40,$41,$43,$44,$46,$47
  db $49,$4A,$4C,$4D,$4F,$51,$52,$54,$55,$57,$59,$5A,$5C,$5E,$5F,$61
  db $63,$65,$66,$68,$6A,$6C,$6E,$70,$71,$73,$75,$77,$79,$7B,$7D,$7F

  @startplaying:
  jmp @exit

  @killhardware:
  mov dx,$43
  mov al,$36
  out dx,al
  mov dx,$40
  xor al,al
  out dx,al
  jmp @teat
  @teat:
  out dx,al
  push es
  push $0000
  pop es
  mov ax,[cs:offset @saveirqvectors+0]
  mov dx,[cs:offset @saveirqvectors+2]
  mov [es:$0020],ax
  mov [es:$0022],dx
  pop es
  jmp @exit

  @exit:
  sti
end;

function ProAudioSpectrum_Detect : word;
var      result                             : word;
begin
  asm
    mov ax,$bc00
    mov bx,$3f3f
    xor cx,cx
    xor dx,dx
    int $2f
    xor bx,cx
    xor bx,dx
    cmp bx,$4d56
    jne @nocard
    mov result,0
    jmp @out
    @nocard:
    mov result,1
    @out:
  end;
  ProAudioSpectrum_Detect:=result;
end;

function SoundBlaster_Detect : word;
var      result                             : word;
begin
  asm
    mov hwport,$220
    mov dx,hwport
    add dx,$0c
    mov al,1
    out dx,al
    mov cx,0
    @loop1:
    loop @loop1
    mov al,0
    out dx,al
    mov dx,hwport
    add dx,$0e
    mov cx,8000
    @loop2:
    in al,dx
    test al,$80
    jnz @terminateloop2
    loop @loop2
    jmp @failure
    @terminateloop2:
    mov dx,hwport
    add dx,$0a
    mov cx,8000
    @loop3:
    in al,dx
    cmp al,$aa
    je @terminateloop3
    loop @loop3
    jmp @failure
    @terminateloop3:
    mov dx,hwport
    add dx,$0c
    @loop4:
    in al,dx
    test al,$80
    jnz @loop4
    mov al,$d1
    out dx,al
    mov result,0
    jmp @out
    @failure:
    mov result,1
    @out:
  end;
  SoundBlaster_Detect:=result;
end;

function StereoOn1_Detect(var outport : word) : word;
var      loop, found                        : word;
begin
  loop:=0;
  found:=0;
  while (loop<=3) and (found=0) do
  begin
    outport:=memw[$0040:$0008+loop shl 1];
    port[outport]:=$80;
    if port[outport+1] and $80=$80 then found:=outport;
  end;
  if found=0 then StereoOn1_Detect:=$ffff else StereoOn1_Detect:=0;
end;

procedure PlaySample(channelnum, samplenumber, volume : byte; speed : word);
begin
  channel[channelnum].VUbar:=volume;
  channel[channelnum].channelseg:=0;
  channel[channelnum].channelsize:=samplelength[samplenumber];
  if speed>0 then
  begin
    channel[channelnum].channelspeed:=(((mainfreq div speed) and $ff00) shr 8)+(((mainfreq div speed) and $00ff) shl 8)
  end else channel[channelnum].channelspeed:=0;
  channel[channelnum].channelvolume:=volume;
  channel[channelnum].channelpos:=0;
  channel[channelnum].channelblip:=0;
  channel[channelnum].channelrep:=samprep[samplenumber];
  channel[channelnum].channelreplen:=sampreplen[samplenumber];
  channel[channelnum].channelseg:=sampleseg[samplenumber];
end;

procedure SetStatus(NewStatus : byte);
{whattoplay=0 0 0 0 d c b a (binary)
                    | | | \- mixer on
                    | | \--- sequencer on
                    | \----- reset sequencer to beginning of song
                    \------- repeat at end of song (1=yes)}
var       loop                              : word;
begin
  if loaded=0 then newstatus:=newstatus and 1;
  if NewStatus and 4=4 then
  begin
    retracestilbeat:=1;
    for loop:=0 to 3 do
      channel[loop].lastsample:=0;
    currentpattern:=0;
    actualpattern:=patterntable[0];
    patseg:=patternseg[actualpattern];
    patternbeat:=0;
    time:=0;
  end;
  Status:=NewStatus;
end;

function GetStatus : byte;
begin
  GetStatus:=Status;
end;

procedure InitialiseDataStructures;
var       loop                              : word;
          offset                            : word;
begin
  loaded:=0;
  patternnumber:=0;
  tempo:=6;
  bufptr:=0;
  bufofs:=0;
  bufstart:=0;
  currentdiv:=0;
  for loop:=0 to maxchannels do
  begin
    channel[loop].VUbar:=0;
    channel[loop].channelseg:=0;
    channel[loop].channelsize:=0;
    channel[loop].channelspeed:=0;
    channel[loop].channelvolume:=64;
    channel[loop].channelblip:=0;
    channel[loop].channelblip:=0;
    channel[loop].channelrep:=0;
    channel[loop].channelreplen:=0;
    channel[loop].effectcounter:=0;
    channel[loop].effectoperand:=0;
    channel[loop].effecttype:=0;
    channel[loop].lastsample:=0;
  end;
  for loop:=0 to maxpatterns do
    patterntable[loop]:=65535;
  for loop:=0 to maxsamples do
  begin
    sampledata[loop]:=nil;
    sampleseg[loop]:=0;
    samplelength[loop]:=0;
  end;
  musicticks:=0;
  SetStatus(0);
end;

procedure ReInitialiseDataStructures;
var       loop                              : word;
          offset                            : word;
begin
  patternnumber:=0;
  tempo:=6;
  bufptr:=0;
  bufofs:=0;
  bufstart:=0;
  currentdiv:=0;
  for loop:=0 to maxchannels do
  begin
    channel[loop].VUbar:=0;
    channel[loop].channelseg:=0;
    channel[loop].channelsize:=0;
    channel[loop].channelspeed:=0;
    channel[loop].channelvolume:=64;
    channel[loop].channelblip:=0;
    channel[loop].channelblip:=0;
    channel[loop].channelrep:=0;
    channel[loop].channelreplen:=0;
    channel[loop].effectcounter:=0;
    channel[loop].effectoperand:=0;
    channel[loop].effecttype:=0;
    channel[loop].lastsample:=0;
  end;
  musicticks:=0;
  SetStatus(0);
end;

procedure LoadModule(filename : string);
const     cutoff                            = 7;
var       handle, h2                        : file;
          buffer                            : array[0..1024] of byte;
          temppatterntable                  : array[0..128] of byte;
          loop, loop2, actualpatterns, nloop: word;
          qloop, sz, numsamples, dataofs    : word;
          asz, pos, filetype                : longint;
          scratch                           : pointer;
begin
  InitialiseDataStructures;
  loaded:=0;
  DOSError:=0;
  assign(handle, filename);
  reset(handle, 1);
  if DOSError=0 then
  begin
    loaded:=1;
    blockread(handle, buffer, 20);
    loop:=0;
    songname:='';
    while buffer[loop]<>0 do
    begin
      songname:=songname+chr(buffer[loop]);
      inc(loop);
    end;
    seek(handle, 1080);
    blockread(handle, filetype, 4);
    if (filetype=$2e4b2e4d) or (filetype=$34544c46) then
    begin
      numsamples:=30;
      dataofs:=950;
    end else
    begin
      numsamples:=14;
      dataofs:=470;
    end;
    for loop:=0 to numsamples do
    begin
      seek(handle, loop*30+20);
      blockread(handle, buffer, 22);
      loop2:=0;
      samplename[loop]:='';
      while buffer[loop2]<>0 do
      begin
        samplename[loop]:=samplename[loop]+chr(buffer[loop2]);
        inc(loop2);
      end;
      blockread(handle, buffer, 2);
      samplelength[loop]:=(buffer[0] shl 8+buffer[1]) shl 1;
      blockread(handle, buffer, 2);
      sampletuning[loop]:=buffer[0];
      defaultsamplevolume[loop]:=buffer[1];
      samplevolume[loop]:=buffer[1];
      if samplevolume[loop]>64 then samplevolume[loop]:=64;
      blockread(handle, buffer, 4);
      samprep[loop]:=(buffer[0] shl 8+buffer[1]) shl 1;
      sampreplen[loop]:=(buffer[2] shl 8+buffer[3]) shl 1;
    end;
    seek(handle, dataofs);
    blockread(handle, buffer, 2);
    patternsinsong:=buffer[0];
    blockread(handle, temppatterntable, 128);
    for loop:=0 to patternsinsong do
      patterntable[loop]:=temppatterntable[loop];
    for loop:=patternsinsong+1 to 127 do
      patterntable[loop]:=65535;
    blockread(handle, buffer, 4);
    actualpatterns:=0;
    for loop:=0 to 127 do
      if (patterntable[loop]>actualpatterns) and (patterntable[loop]<65535) then actualpatterns:=patterntable[loop];
    inc(actualpatterns);
    if actualpatterns=64 then sz:=65535 else sz:=1024*actualpatterns;
    GetMem(patterndata, sz);
    patternbaseseg:=seg(patterndata^);
    blockread(handle, patterndata^, sz);
    for loop:=0 to actualpatterns do
      patternseg[loop]:=seg(patterndata^)+64*loop;
    for loop:=0 to 30 do
    begin
      if samplelength[loop]>0 then
      begin
        getmem(sampledata[loop], samplelength[loop]);
        blockread(handle, sampledata[loop]^, samplelength[loop]);
        dec(samplelength[loop]);
        sampleseg[loop]:=seg(sampledata[loop]^);
        if sampreplen[loop]<=4 then sampreplen[loop]:=0;
        if sampreplen[loop]+samprep[loop]>samplelength[loop] then sampreplen[loop]:=samplelength[loop]-samprep[loop];
      end;
    end;
  end;
  sz:=filesize(handle)-filepos(handle);
  close(handle);
end;

procedure KillModule;
var       loop, actualpatterns              : word;
begin
  if loaded=1 then
  begin
    actualpatterns:=0;
    for loop:=0 to patternsinsong-1 do
      if patterntable[loop]>actualpatterns then actualpatterns:=patterntable[loop];
    inc(actualpatterns);
    FreeMem(patterndata, 1024*actualpatterns);
    for loop:=0 to 30 do
      if samplelength[loop]>0 then FreeMem(sampledata[loop], samplelength[loop]+1);
    InitialiseDataStructures;
  end;
end;

function validate1megboundary(p : pointer) : boolean;
var      s, o, a, b, r                      : word;
begin
  s:=seg(p^);
  o:=ofs(p^);
  asm
    mov di,o
    mov dx,s
    mov ax,s
    rol dx,4
    and dx,$000f {get page of memory}
    shl ax,4
    add di,ax
    adc dx,0
    add di,(buffersize+1)*bufdiv
    jc @bugger
    mov r,0
    jmp @exit
    @bugger:
    mov r,1
    @exit:
  end;
  if r=0 then validate1megboundary:=true else validate1megboundary:=false;
end;

procedure InitialiseHandler(playbackdevice : integer; port1, port2, playbackrate : word);
var       loop, found, scratchsize          : word;
          mf, fuckup                        : longint;
          i2, i3, i4, i5, i6, i7, scratch   : pointer;
          temp                              : byte;
begin
  InitialiseDataStructures;
  GetMem(dmabuffer, (buffersize+1)*bufdiv);
  scratchsize:=0;
  while validate1megboundary(dmabuffer)=false do
  begin
    freemem(dmabuffer, (buffersize+1)*bufdiv);
    if scratchsize<>0 then freemem(scratch, scratchsize);
    scratchsize:=scratchsize+128;
    getmem(scratch, scratchsize);
    getmem(dmabuffer, (buffersize+1)*bufdiv);
  end;
  if scratchsize<>0 then freemem(scratch, scratchsize);
  dmabufferseg:=seg(dmabuffer^);
  dmabufferofs:=ofs(dmabuffer^);
  SetStatus(0);
  samplerate:=(1193000 div playbackrate);
  timeconst:=256-(1000000 div playbackrate);
  fuckup:=samplerate;
  mf:=fuckup*$300;
  mainfreq:=mf;
  loop:=0;
  found:=0;
  while (loop<65535) and (found=0) do
  begin
    if meml[seg(@bytebybyteoutput^):ofs(@bytebybyteoutput^)+loop]=$deaddead
       then found:=ofs(@bytebybyteoutput^)+loop;
    inc(loop);
  end;
  if found=0 then
  begin
    Writeln('Serious error.  Replay code corrupt or modified.  Cannot continue.');
    halt(255);
  end;
  meml[seg(@bytebybyteoutput^):found]:=meml[$0000:$0020];
  memw[seg(@bytebybyteoutput^):found-2]:=DSeg;
  GetIntVec($69, @saveint69);
  if playbackdevice=-1 then
  begin
    if ProAudioSpectrum_Detect=0 then TrackerHandler:=ProAudioSpectrum else
    if SoundBlaster_Detect=0 then TrackerHandler:=SoundBlaster else
    if StereoOn1_Detect(port1)=0 then TrackerHandler:=StereoOn1DAC else
    TrackerHandler:=InternalSpeaker;
  end else TrackerHandler:=playbackdevice;
  case TrackerHandler of
    InternalSpeaker  : SetIntVec($69, @Beeper_InterruptHandler);
    SoundBlaster     : SetIntVec($69, @SoundBlaster_InterruptHandler);
    SoundBlasterPro  : SetIntVec($69, @SoundBlaster_InterruptHandler);
    ProAudioSpectrum : SetIntVec($69, @ProAudioSpectrum_InterruptHandler);
    Adlib            : SetIntVec($69, @Beeper_InterruptHandler);
  end;
  asm
    mov ax,dmabufferseg
    mov es,ax
    mov di,dmabufferofs
    mov cx,buffersize
    mov bx,playbackrate
    mov dx,$0100
    int $69
  end;
end;

procedure ShutdownHandler;
begin
  asm
    mov dx,$0400
    int $69
  end;
  SetIntVec($69, @saveint69);
end;

begin;

 writeln('SackBlaster - TT''s kludge of the DreamTracker mod code.');
(* InitialiseHandler(ProAudioSpectrum,0,0,22000);*)
(*InitialiseHandler(SoundBlaster,0,0,11000);*)
 InitialiseHandler(InternalSpeaker,0,0,11000);
 writeln('Handler initialised!');
 loadmodule('c:\pas\tbpro\little.mod');
 writeln('Little China loaded!');

(* loadmodule('v:golden.mod');
 writeln('Golden Slumbers loaded!');*)

(* loadmodule('d:noname.mod');
 writeln('Bang effect loaded!');*)

 SetStatus(Mixer);

 readln;

 playsample(0,0,63,177);
 writeln('First sample in the mod played at middle C at full volume.');

 readln;
 playsample(0,0,63,177);
 playsample(1,0,63,177);
 playsample(2,0,63,177);
 playsample(3,0,63,177);
 readln;

 write('Hit a key...'); readln;

(* SetStatus(Mixer or Sequencer or ResetSequencer);
 writeln('Mod playing!');*)

 write('Hit a key...'); readln;

 killmodule;
 writeln('Mod unloaded!');
 ShutDownHandler;
 writeln('Handler shut down!');
end.