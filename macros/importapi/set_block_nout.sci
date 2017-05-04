function blk = set_block_nout(blk,nout)

  if blk.gui == 'OUTIMPL_f' || blk.gui == 'INIMPL_f' then return;end 
  
  if  blk.gui == 'IMPSPLIT_f' then 
    mo = blk.model.equations;
    s='n';
    mo.outputs=s(ones(1,nout))';
    blk.model.equations= mo;
    blk.model.out=ones(size(mo.outputs,'*'),1)
    I='I';
    blk.graphics.out_implicit=I(ones(1,nout))';
    blk.graphics.pout = zeros(nout,1);
    return;
  end 
  
  if nout == size(blk.model.out,1) then return;end;
  
  if ~isempty(blk.graphics.pout) &  ~and(0==blk.graphics.pout) then
    error("Number of ports of connected blocks cannot be changed.")
  end

  blk.graphics.pout=zeros(nout,1)
  if nout>size(blk.model.out,1) then
    blk.model.out($+1:nout,1)=-10  // correct size
  elseif nout<size(blk.model.out,1) then
    blk.model.out=blk.model.out(1:nout)
  end

  I='E';
  blk.graphics.out_implicit=I(ones(nout,1));
  
endfunction
