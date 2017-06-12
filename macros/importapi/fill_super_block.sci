function blk = fill_super_block(blk,scs_m)
// we want the ports to have updated values 
  persistent(count=0);
  [scs_m,ok]=do_silent_eval(scs_m);
  if ~ok then count=count+1;printf("do_silent_eval_failed %d\n",count);end 
  blk.model.rpar=scs_m
  [ok,blk]=adjust_s_ports(blk);
  if ~ok then printf("Error: adjust_s_ports failed\n"),end;
endfunction


