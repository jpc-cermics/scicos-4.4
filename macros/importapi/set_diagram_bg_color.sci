function scs_m = set_diagram_bg_color(scs_m,clr)
  cmap=xget("colormap")
  dif=abs(cmap-ones(size(cmap,1),1)*clr)*[1;1;1]
  [ju,col]=min(dif)
  scs_m.props.options.Background(1)=col
endfunction
