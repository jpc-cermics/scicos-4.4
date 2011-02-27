function systshow(scs_m,zoom=1)
// Copyright INRIA
// display a diagram recursively displaying 
// super blocks. 
//
  curwin = max(winsid())+1;
  if isempty(curwin) then curwin=0;end 
  xset('window',curwin);
  scs_m=scs_m_remove_gr(scs_m);
  %zoom=restore(curwin,[],zoom);
  drawobjs(scs_m);
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block' && o.model.sim(1)=='super' then 
      systshow(o.model.rpar,zoom=zoom);
    end
  end
endfunction
