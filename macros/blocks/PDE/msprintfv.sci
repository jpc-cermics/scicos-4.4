function x=msprintfv(x)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x) then
    x=[];
  else
    x=msprintf('%.16g\n',x);
  end
endfunction
