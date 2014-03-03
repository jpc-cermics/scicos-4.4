function blk = set_block_flip(blk,fl)
// fl is now a boolean 
  if type(fl,'short')== 'm' then fl=m2b(fl);end
  blk.graphics.flip=~fl;
endfunction
