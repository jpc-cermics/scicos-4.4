function blk = set_block_bg_color(blk,clr)
  cmap=xget("colormap")
  dif=abs(cmap-ones(size(cmap,1),1)*clr)*[1;1;1]
  [ju,col]=min(dif)
  if type(blk.graphics.gr_i,'short')== 's' then
    blk.graphics.gr_i = list(blk.graphics.gr_i,col),
  else
    blk.graphics.gr_i(2)=col
  end
endfunction
