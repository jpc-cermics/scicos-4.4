function x=mulf3v(x1,x2,x3)
// Copyright INRIA
// d�velopp� par EADS-CCR
  if isempty(x1) | isempty(x2) | isempty(x3) then
    x='0';
  else
    x=mulf3(x1,x2,x3);
  end
endfunction

