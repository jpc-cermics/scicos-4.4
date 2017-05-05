function blk = fill_super_block(blk,scs_m)
// we want the ports to have updated values 
  [scs_m,ok]=do_silent_eval(scs_m);
  blk.model.rpar=scs_m
  [ok,blk]=adjust_s_ports(blk);
  if ~ok then error("Error: adjust_s_ports failed"),end;
endfunction


