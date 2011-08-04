function scmenu_select_all()
// Copyright INRIA
  Cmenu="";%pt=[];Select=[];
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if typeof(o)<>'Deleted' then
      Select=[Select;[k,curwin]]
    end
  end
endfunction

