function fname=choosefile(path,comm,errmess)
// choosefile - select a file through a filter
//%Syntax
//  fname=choosefile(path)
//  fname=choosefile()
//%Parameters
// path   : character string for selection rule.
// fname  :  character string : selected file name or empty matrix if none
//!
// Copyright INRIA
  
  if nargin <= 0 then path='./*';end 
  if nargin <= 1 then comm='Choose a file';end
  if nargin <= 2 then errmess=%t;end 
  lst=glob(path)
  if isempty(lst) && errmess then message('No such file exists'),end
  if prod(size(lst))>0 then
    n=x_choose(lst,comm,'Cancel')
    if n<>0 then
      fname=lst(n)
    else
      fname=[]
    end
  else
    fname=[]
  end
endfunction
