{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 SACKBLASTER-1    The temporary mod player. }

{ This is SackBlaster version 1.0, using Mark J. Cox's MODOBJ routines.
  When Cameron finishes his mod player I'll use his routines, DV. However,
  this will do for the time being. }

unit SackB1;

interface

uses Crt;

procedure sb_start(md:string);

procedure sb_stop;

procedure sb_link; { At the moment, this does nothing. }

implementation

{$L v:MOD-obj.OBJ} 	        { Link in Object file }
{$F+} 				{ force calls to be 'far'}

procedure modvolume(v1,v2,v3,v4:integer); external ; {Can do while playing}
procedure moddevice(var device:integer); external ;
procedure modsetup(var status:integer;device,mixspeed,pro,loop:integer;var str:string); external ;
procedure modstop; external ;
procedure modinit; external;
{$F-}

procedure sb_start(md:string);
var
 dev,mix,stat,pro,loop : integer;
begin
 modinit;
 dev:=7; { Sound Blaster }
 mix := 10000;   {use 10000 normally }
 pro := 0; {Leave at 0}
 loop :=4; {4 means mod will play forever}
 modvolume (255,255,255,255);    { Full volume }
 modsetup ( stat, dev, mix, pro, loop, md );
end;

procedure sb_stop;
begin;
 modstop;
end;

procedure sb_link; { At the moment, this does nothing. }
begin;
end;

end.
