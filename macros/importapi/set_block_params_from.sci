function blk=set_block_params_from(blk,fromblk,modelica = %t)
  blk.model.evtin = fromblk.model.evtin;
  blk.model.evtout = fromblk.model.evtout;
  blk.model.in= fromblk.model.in;
  blk.model.out = fromblk.model.out;
  blk.model.in2= fromblk.model.in2;
  blk.model.out2 = fromblk.model.out2;

  blk.graphics.peout = fromblk.graphics.peout;
  blk.graphics.pein = fromblk.graphics.pein;
  blk.graphics.pin = fromblk.graphics.pin;
  blk.graphics.pout = fromblk.graphics.pout;
    
  blk.graphics.out_implicit = fromblk.graphics.out_implicit;
  blk.graphics.in_implicit = fromblk.graphics.in_implicit;

  if modelica then
    blk.graphics.out_implicit = strsubst(blk.graphics.out_implicit, 'E','I');
    blk.graphics.in_implicit = strsubst(blk.graphics.in_implicit, 'E','I');
  end
  blk.graphics.id = fromblk.graphics.id;
  blk.graphics.flip = fromblk.graphics.flip;
  blk.graphics.orig = fromblk.graphics.orig;
  blk.graphics.sz = fromblk.graphics.sz;
  blk.graphics.theta = fromblk.graphics.theta;

  if type(fromblk.graphics.gr_i,'short')=='l' && length(fromblk.graphics.gr_i) >=2 then
    color = fromblk.graphics.gr_i(2);
    if ~isempty(color) then blk = set_block_bg_color(blk,color);end
  end
endfunction

