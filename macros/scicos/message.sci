function num=message(strings ,buttons)
//interface to message primitive to allow simple overloading for live demo 
// Copyright INRIA
  if nargin == 1 then 
    num=1; x_message(strings)  
  else 
    num=x_message(strings ,buttons)
  end 
endfunction
