function blk=set_block_params_from(blk,fromblk)
  
  blk.graphics.pein = fromblk.graphics.pein;
  blk.model.evtin = fromblk.model.evtin;
  blk.graphics.peout = fromblk.graphics.peout;
  blk.model.evtout = fromblk.model.evtout;
  
  blk.graphics.flip = fromblk.graphics.flip;
  blk.graphics.id = fromblk.graphics.id;

  blk.graphics.in_implicit = fromblk.graphics.in_implicit;
  blk.graphics.pin = fromblk.graphics.pin;
  blk.model.in
    
  blk.graphics.out_implicit = fromblk.graphics.out_implicit;
  blk.graphics.pout = fromblk.graphics.pout;
  blk.model.out = fromblk.model.out;

  blk.graphics.orig = fromblk.graphics.orig;
  blk.graphics.sz = fromblk.graphics.sz;
  blk.graphics.theta = fromblk.graphics.theta;

  if size(fromblk.graphics.gr_i,"*") >=2 then 
    color = fromblk.graphics.gr_i(2);
    blk = set_block_bg_color(blk,color);
  end

endfunction

