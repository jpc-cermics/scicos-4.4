function blk = set_block_parameters(blk,params)
// params is a cell array here 
  [m,n]=size(params) 
  exprs=m2s([])
  for i=1:m ;exprs.concatd[params{i,2}]; end
  blk.graphics.exprs = exprs
endfunction

