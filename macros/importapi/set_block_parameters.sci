function blk = set_block_parameters(blk,params)
// params is a cell array here 
  [m,n]=size(params) 
  exprs=m2s([])
  for i=1:m ;exprs.concatd[params{i,2}]; end
  blk.graphics.exprs = exprs
  if blk.gui == 'TEXT_f' then 
    // font size are too big 
    siz=evstr(exprs(3));
    blk.graphics.exprs(3)= sprintf("%f",siz/3.0);
  end
endfunction

