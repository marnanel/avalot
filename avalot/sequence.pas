{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 SEQUENCE         The sequencer. }

unit Sequence;

interface

const

 now_flip = 177;

 seq_length = 10;

var
 seq: array[1..seq_length] of byte;

procedure first_show(what:byte);

procedure then_show(what:byte);

procedure then_flip(where,ped:byte);

procedure start_to_close;

procedure start_to_open;

procedure call_sequencer;

implementation

uses Gyro, Timeout, Celer, Trip5;

procedure then_show(what:byte);
var fv:byte;
begin;
 for fv:=1 to seq_length do
  if seq[fv]=0 then
  begin;
   seq[fv]:=what;
   exit;
  end;
end;

procedure first_show(what:byte);
begin;
 { First, we need to blank out the entire array. }
 fillchar(seq,sizeof(seq),#0);

 { Then it's just the same as then_show. }
 then_show(what);

end;

procedure then_flip(where,ped:byte);
begin;
 then_show(now_flip);

 dna.flip_to_where:=where;
   dna.flip_to_ped:=ped;
end;

procedure start_to_close;
begin;
 lose_timer(reason_Sequencer);
 set_up_timer(7,PROCsequence,reason_Sequencer);
end;

procedure start_to_open;
begin;
 dna.User_moves_Avvy:=false; { They can't move. }
 stopwalking; { And they're not moving now. }
 start_to_close; { Apart from that, it's the same thing. }
end;

procedure call_sequencer;
 { This proc is called by Timeout when it's time to do another frame. }
 procedure shove_left;
 begin;
  move(seq[2],seq[1],seq_length-1); { Shift everything to the left. }
 end;
begin;
 case seq[1] of
  0: exit; { No more routines. }
  1..176: begin; { Show a frame. }
           show_one(seq[1]);
           shove_left;
          end;
  177: with dna do begin;
        user_moves_Avvy:=true;
        fliproom(flip_to_where,flip_to_ped); { 177 = Flip room. }
        if seq[1]=177 then shove_left;
       end;
 end;

 start_to_close; { Make sure this proc gets called again. }
end;

end.