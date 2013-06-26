function [scs_m,ok]=evaluate_model(scs_m,context)
  ok=%t
  if nargin < 2 then context=hash(5);end
  [scs_m,ok] = do_silent_eval(scs_m, context)
endfunction
