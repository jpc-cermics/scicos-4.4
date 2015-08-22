function blk = set_block_parameters(blk,params)
// params is a cell array here
  [m,n]=size(params)
  exprs=m2s([])
  for i=1:m ;
    // do not accept \n in names
    if params{i,1}=="nom" then
      value =strsubst(params{i,2},"\\n"," ");
      if part(value,1)=="''" then value=part(value,2:length(value));end
      n = length(value);
      if part(value,n)=="''" then value=part(value,1:n-1);end
    elseif params{i,1}=="txt" then
      value =params{i,2};
      if part(value,1)=="''" then value=part(value,2:length(value));end
      n = length(value);
      if part(value,n)=="''" then value=part(value,1:n-1);end
    else
      value =params{i,2};
    end
    exprs.concatd[value];
  end
  blk.graphics.exprs = exprs
  if blk.gui == 'TEXT_f' then
    // font size are too big
    siz=evstr(exprs(3));
    blk.graphics.exprs(3)= sprintf("%f",siz/3.0);
  end
endfunction
