function [H,ierr] = script2var(txt,Hin)
// evaluates the string matrix txt with environment defined 
// by hash table Hin if given or with environment %scicos_context 
// if only one argument is given
// if the evaluation fails then Hin is returned in H 
// else a new hash table which contains Hin and the new 
// values due to the evaluation of txt is returned.
// In case of error lasterror() can be called 
// jpc Aug 2010 
// 
  if nargin <= 1 then Hin = acquire('%scicos_context',def=hash(1));end
  if isempty(txt) then txt=m2s([]);end 
  ierr = 0 ;
  // protect the current window 
  I= winsid();
  if ~isempty(I) then cwin=xget('window');end 
  [ok,H]=execstr(txt,env=Hin, errcatch=%t);
  if ~isempty(I) then xset('window',cwin);end 
  if ~ok then ierr = 1; H=Hin; end
endfunction 
