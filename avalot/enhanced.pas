unit enhanced;

{ This is the unit set up by Thomas with help from all the people on
  CIS:BPROGA to read the *enhanced* keyboard codes (as opposed to the
  readkey-type ones.) }

interface

var
 ShiftState : Byte ABSOLUTE $40:$17;
 atbios:boolean;
 inchar,extd:char;

procedure readkeye;

FUNCTION keypressede : Boolean;

implementation

uses Dos,Crt;

function isenh:boolean;
var
 StateFrom16 : Byte;
 r:registers;
BEGIN
  IsEnh := FALSE;
  with r do
  begin;
   ah:=$12;
   intr($16,r);
   statefrom16:=al;
  end;
  IF StateFrom16 <> ShiftState THEN Exit;
  ShiftState := ShiftState XOR $20;
  with r do
  begin;
   ah:=$12;
   intr($16,r);
   statefrom16:=al;
  end;
  IsEnh := StateFrom16 = ShiftState;
  ShiftState := ShiftState XOR $20;
END;

procedure readkeye;
  function fancystuff:word;
   inline( $B4/ $10/  { MOV AH,10 }
           $CD/ $16); { INT 16 }
  function notfancystuff:word;
   inline( $B4/ $00/  { MOV AH,0 }
           $CD/ $16); { INT 16 }
var
 r:registers; fs:word;
begin;
 if atbios then
  with r do fs:=fancystuff { We're using an AT }
  else fs:=notfancystuff; { ditto, an XT }
 inchar:=chr(lo(fs));
 extd:=chr(hi(fs));
end;

FUNCTION keypressede : Boolean;
 function fancystuff:boolean;
  inline( $B4/ $11/  { MOV AH,11 }
          $CD/ $16/  { INT 16 }
          $B8/ $00/ $00/ { MOV AX, 0000 }
          $74/ $01/  { JZ 0112 (or wherever- the next byte after $40, anyway) }
          $40);      { INC AX }
var r:registers;
begin;
 if atbios then
  with r do
   keypressede:=fancystuff { ATs get the fancy stuff }
  else keypressede:=keypressed; { XTs get the usual primitive... }
end;

begin;
 { determine bios type }
 atbios:=isenh;
end.