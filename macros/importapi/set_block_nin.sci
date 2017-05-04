function blk = set_block_nin(blk,nin)

  if blk.gui == 'OUTIMPL_f' || blk.gui == 'INIMPL_f' then return;end 
  
  if  blk.gui == 'IMPSPLIT_f' then 
    mo = blk.model.equations;
    s='n';
    mo.inputs=s(ones(1,nin))';
    blk.model.equations= mo;
    blk.model.in=ones(size(mo.inputs,'*'),1)
    I='I';
    blk.graphics.in_implicit=I(ones(1,nin))';
    blk.graphics.pin = zeros(nin,1);
    return;
  end 
    
  if nin == size(blk.model.in,1) then return;end;
    
  if ~isempty(blk.graphics.pin) &  ~and(0==blk.graphics.pin) then
    error("Number of ports of connected blocks cannot be changed.")
  end

  if or(blk.graphics.in_implicit=='I')  then 
    error(sprintf("Error: %s has variable number of implicit ports",blk.gui));
  end
  
  blk.graphics.pin=zeros(nin,1)
  if nin>size(blk.model.in,1) then
    blk.model.in($+1:nin,1)=-20;
  elseif nin<size(blk.model.in,1) then
    blk.model.in=blk.model.in(1:nin);
  end
    
  I='E';
  blk.graphics.in_implicit=I(ones(nin,1))
  
endfunction

