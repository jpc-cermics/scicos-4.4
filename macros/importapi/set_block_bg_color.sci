function blk = set_block_bg_color(blk,color)
  if size(color,'*') <> 1 then 
    cmap=xget("colormap")
    dif=abs(cmap-ones(size(cmap,1),1)*color)*[1;1;1]
    [ju,color]=min(dif);
  end
  if type(blk.graphics.gr_i,'short')== 's' then
    blk.graphics.gr_i = list(blk.graphics.gr_i,color),
  else
    blk.graphics.gr_i(2)=color;
  end
endfunction
