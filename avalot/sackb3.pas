{$M 16384,0,0}

program Demo; { to demonstrate the SBVoice Unit }
              { Copyright 1991 Amit K. Mathur, Windsor, Ontario }

uses SBVoice;

begin
if paramcount>0 then begin
    LoadVoice(paramstr(1),0,0);
    sb_Output(seg(soundfile),ofs(soundfile)+26);
    repeat
         write('Demo of the SBVoice Unit, Copyright 1991 by Amit K. Mathur --- ');
    until StatusWord=0;
end else
    writeln('Usage: DEMO [d:\path\]filename.voc');
end.
