function ok=set_cmap(cmap)
// appends new colors to the current colormap
// Copyright INRIA
  ok=%t;
  if isempty(cmap) then return,end
  if isempty(winsid()) then return,end
  d=xget('colormap');
  changed=%f;
  for k=1:size(cmap,1)
    [mc,kk]=min(abs(d-ones_new(size(d,1),1)*cmap(k,:))*[1;1;1])
    if mc > .0001 then
      d=[d;cmap(k,:)]
      changed=%t
    end
  end
  if changed then 
    ok =execstr('xset(''colormap'',d)',errcatch=%t);
    if ~ok then lasterror();end
  end
endfunction
