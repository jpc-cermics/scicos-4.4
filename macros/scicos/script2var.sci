function [H,ierr] = script2var(txt,Hin)
// evalates txt with env defined by hash table Hin 
// if the evaluation fails then Hin is returned 
// else a new hash table which contains Hin and the new 
// values due to the evaluation of txt is returned.
// In case of error lasterror() can be called 
// jpc Aug 2010 
  if nargin <= 1 then Hin=hash(1);end 
  ierr = 0 ;
  [ok,H]=execstr(txt,env=Hin, errcatch=%t);
  if ~ok then
    ierr = 1;
    H=Hin;
  end
endfunction 
