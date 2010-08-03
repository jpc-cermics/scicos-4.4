function ok=set_cmap(cmap)
//appends new colors to the colormap
// Copyright INRIA
  if isempty(cmap) then ok=%t,return,end
  d=xget('colormap');  
  for k=1:size(cmap,1)
    [mc,kk]=min(abs(d-ones_new(size(d,1),1)*cmap(k,:))*[1;1;1])
    if mc>.0001 then
      d=[d;cmap(k,:)]
    end
  end
  ok =execstr('xset(''colormap'',d)',errcatch=%t)
endfunction
