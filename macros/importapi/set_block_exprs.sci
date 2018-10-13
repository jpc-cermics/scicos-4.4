function blk=set_block_exprs(blk,exprs)
  blk.graphics.exprs = exprs;
  scs_m=scicos_diagram();
  scs_m.objs(1)=blk;
  [scs_m,ok]=do_silent_eval(scs_m);
  blk = scs_m.objs(1);
endfunction
