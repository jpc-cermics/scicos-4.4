function blk = fill_super_block(blk,scs_m)
// we want the ports to have updated values 
  persistent(count=0);
  [scs_m,ok]=do_silent_eval(scs_m);
  if ~ok then
    count=count+1;
    if %f then 
      printf("warning: do_silent_eval_failed %d\n",count);
      printf("         this can be caused by a missing context at super block level\n");
      printf("         and it will work at top level\n");
    end
  end
  blk.model.rpar=scs_m;
  [ok,blk]=adjust_s_ports(blk);
  if ~ok then printf("Error: adjust_s_ports failed\n"),end;
endfunction


