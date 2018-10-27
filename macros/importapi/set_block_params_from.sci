function blk=set_block_params_from(blk,fromblk,modelica = %t)

  // Ce qui suit est trop compliqué
  // On veut juste heriter de graphics.pin et graphics.pout de fromblk -> blk
  
  if modelica then
    // This could be wrong if all the in/out ports of blk are not I
    // this should be properly set at define part 
    blk.graphics.out_implicit = smat_create(1,size(blk.model.out,'*'),"I");
    blk.graphics.in_implicit = smat_create(1,size(blk.model.in,'*'),"I");
  end
  // XXX This could be removed if all the modelica blocks never set empty stuff
  if isempty(blk.model.in2) then blk.model.in2= ones(size(blk.model.in,'*'),1);end
  if isempty(blk.model.out2) then blk.model.out2= ones(size(blk.model.out,'*'),1);end
  if isempty(blk.model.intyp) then blk.model.intyp= ones(size(blk.model.in,'*'),1);end
  if isempty(blk.model.outtyp) then blk.model.outtyp= ones(size(blk.model.out,'*'),1);end
    
  [model, graphics, ok]=set_io(fromblk.model, fromblk.graphics,
			       list([blk.model.in,blk.model.in2],blk.model.intyp),
			       list([blk.model.out,blk.model.out2],blk.model.outtyp),
			       [],[],[],[],[],[]);
  
  blk.graphics.pin = graphics.pin;
  blk.graphics.pout = graphics.pout;
  
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

