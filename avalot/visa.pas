{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 VISA             The new Sez handler. (Replaces Access.) }

unit Visa;

interface

procedure dixi(block:char; point:byte);

procedure talkto(whom:byte);

implementation

uses Gyro,Scrolls,Acci,Trip5,Lucerna;

const
 bubbling : boolean = false;
 report_dixi_errors : boolean = true;

var went_OK:boolean;

procedure unskrimble;
var fv:word;
begin
 for fv:=1 to bufsize do buffer[fv]:=char((not(ord(buffer[fv])-fv)) mod 256);
end;

procedure do_the_bubble;
begin
 inc(bufsize);
 buffer[bufsize]:=^B;
end;

procedure dixi(block:char; point:byte);
var
 indexfile,sezfile:file;
 idx_offset,sez_offset:word;
 error : boolean;
begin
 error:=false;

 assign(indexfile,'avalot.idx'); assign(sezfile,'avalot.sez');

 reset(indexfile,1);
 seek(indexfile,(ord(upcase(block))-65)*2);
 blockread(indexfile,idx_offset,2);
 if idx_offset=0 then error:=true;
 seek(indexfile,idx_offset+point*2);
 blockread(indexfile,sez_offset,2);
 if sez_offset=0 then error:=true;
 close(indexfile);

 went_OK:=not error;

 if error then
 begin
  if report_dixi_errors then
   display(^g+'Error accessing scroll '+block+strf(point));
  exit;
 end;

 reset(sezfile,1);
 seek(sezfile,sez_offset);
 blockread(sezfile,bufsize,2);
 blockread(sezfile,buffer,bufsize);
 close(sezfile);
 unskrimble;

 if bubbling then do_the_bubble;

 calldrivers;
end;

procedure speech(who:byte; subject:byte);
var
 indexfile,sezfile:file;
 idx_offset,sez_offset,next_idx_offset:word;
begin
 if subject=0 then
 begin { No subject. }
  bubbling:=true; report_dixi_errors:=false;
  dixi('s',who);
  bubbling:=false; report_dixi_errors:=true;
 end else
 begin { Subject given. }
  assign(indexfile,'converse.avd'); assign(sezfile,'avalot.sez');

  went_OK:=false; { Assume that until we know otherwise. }
  reset(indexfile,1);
  seek(indexfile,who*2-2);
  blockread(indexfile,idx_offset,2);
  blockread(indexfile,next_idx_offset,2);

  if (idx_offset=0) or
    ((((next_idx_offset-idx_offset) div 2)-1) < subject) then exit;

  seek(indexfile,idx_offset+subject*2);
  {$I-}
  blockread(indexfile,sez_offset,2);
  if (sez_offset=0) or (ioresult<>0) then exit;
  {$I+}
  close(indexfile);

  reset(sezfile,1);
  seek(sezfile,sez_offset);
  blockread(sezfile,bufsize,2);
  blockread(sezfile,buffer,bufsize);
  close(sezfile);

  unskrimble;
  do_the_bubble;

  calldrivers;
  went_OK:=true;
 end;
end;

procedure talkto(whom:byte);
var
 fv:byte;
 no_matches:boolean;
begin
 if person=pardon then
 begin
  person:=chr(subjnumber);
  subjnumber:=0;
 end;

 if subjnumber=0 then
 case chr(whom) of
  pSpludwick:

    if (dna.Lustie_is_asleep) and (not dna.obj[potion]) then
    begin
     dixi('q',68);
     dna.obj[potion]:=true;
     objectlist; points(3); exit;
    end else
    begin
     if dna.Talked_To_Crapulus then
      case dna.given2spludwick of { Spludwick - what does he need? }
         { 0 - let it through to use normal routine. }
         1..2: begin
                display('Can you get me '+
                 get_better(spludwick_order[dna.given2spludwick])+', please?'+
                  ^s'2'^b);
                exit;
               end;
         3: begin
             dixi('q',30); { need any help with the game? }
             exit;
            end;
       end
     else begin
           dixi('q',42); { Haven't talked to Crapulus. Go and talk to him. }
           exit;
          end;
    end;

  pIbythneth: if dna.GivenBadgeToIby then
              begin
               dixi('q',33); { Thanks a lot! }
               exit; { And leave the proc. }
              end; { Or... just continue, 'cos he hasn't got it. }
  pDogfood: if dna.WonNim then
            begin { We've won the game. }
             dixi('q',6); { "I'm Not Playing!" }
             exit; { Zap back. }
            end else dna.asked_Dogfood_about_Nim:=true;
  pAyles: if not dna.Ayles_is_awake then
          begin
           dixi('q',43); { He's fast asleep! }
           exit;
          end else
           if not dna.given_pen_to_ayles then
           begin
            dixi('q',44); { Can you get me a pen, Avvy? }
            exit;
           end;

  pJacques: begin dixi('q',43); exit end;
  pGeida: if dna.Geida_given_potion then
           dna.Geida_Follows:=true else
          begin
           dixi('u',17);
           exit;
          end;
  pSpurge: if not dna.sitting_in_pub then
           begin
            dixi('q',71); { Try going over and sitting down. }
            exit;
           end else
            with dna do
            begin
             if Spurge_Talk<5 then inc(Spurge_talk);
             if Spurge_Talk>1 then
             begin { no. 1 falls through }
              dixi('q',70+Spurge_Talk);
              exit;
             end;
            end;
 end else  { On a subject. Is there any reason to block it? }
   case chr(whom) of
     pAyles: if not dna.Ayles_is_awake then
          begin
           dixi('q',43); { He's fast asleep! }
           exit;
          end
   end;

 if whom>149 then dec(whom,149);

 no_matches:=true;
 for fv:=1 to numtr do
  if tr[fv].a.accinum=whom then
  begin
   display(^S+chr(fv+48)+^D);
   no_matches:=false;
   break;
  end;

 if no_matches then display(^S^S^D);

 speech(whom,subjnumber);
 if not went_OK then { File not found! }
  dixi('n',whom);

 if subjnumber=0 then
 case chr(whom+149) of
  pCrapulus:
     begin { Crapulus: get the badge - first time only }
      dna.obj[badge]:=true;
      objectlist;
      dixi('q',1); { Circular from Cardiff. }
      dna.talked_to_Crapulus:=true;

      whereis[pCrapulus]:=177; { Crapulus walks off. }

      tr[2].VanishIfStill:=true;
      tr[2].walkto(4); { Walks away. }

      points(2);
     end;

 end;
end;

end.
