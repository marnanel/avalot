program testenhanced;
uses Enhanced;
begin;
 repeat
  readkeye;
  case inchar of
   #0: write('['+extd+']');
   #224: write('<'+extd+'>');
   else write(inchar);
  end;
 until inchar=#27;
end.