
function ok=exists_in_context(str)
  // user utility: this function can be used in 
  // 
  ok= exists('%scicos_context') && %scicos_context.iskey[str];
endfunction
