function blk = set_block_ident(blk,id)
  if size(id,'*') == 1 then 
    blk.graphics.id=split(id)';
  else
    blk.graphics.id=id;
  end
endfunction
