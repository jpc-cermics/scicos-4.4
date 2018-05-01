function blk=set_block_exprs(blk,exprs)
  // this function is usefull for some
  // superblocks like CLOCK_f.
  // Such blocks are in fact super blocks
  // but we want to save them as blocks since
  // the internal contents is genrated by define.
  // But we need to keep the parameters which are
  // treated in a special way in each special block
  if blk.gui == 'CLOCK_f' || blk.gui == 'CLOCK_c' then
    blk.model.rpar.objs(2).graphics.exprs = exprs ;
  elseif or(blk.gui == ['ENDBLK','STEP_FUNCTION']) then
    blk.model.rpar.objs(1).graphics.exprs = exprs ;
  end
endfunction
