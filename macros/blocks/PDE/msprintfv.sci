function x=msprintfv(x)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x) then
    x=m2s([]);
  else
    x=sprintf('%.16g',x(:));
  end
endfunction
