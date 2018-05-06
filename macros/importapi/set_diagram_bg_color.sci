function scs_m = set_diagram_bg_color(scs_m,color)
  if size(color,'*') <> 1 then 
    cmap=xget("colormap")
    dif=abs(cmap-ones(size(cmap,1),1)*color)*[1;1;1]
    [ju,color]=min(dif);
  end
  scs_m.props.options.Background(1)=color;
endfunction
