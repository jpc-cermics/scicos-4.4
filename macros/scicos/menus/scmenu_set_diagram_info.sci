function SetDiagramInfo_()
// Copyright INRIA
  Cmenu='Open/Set'
  [ok,info]=do_set_info(scs_m.props.doc)
  if ok then scs_m.props.doc=info,end
endfunction

function [ok,new_info]=do_set_info(info)
//This function may be redefined by the user to handle definition 
//of the informations associated with the current diagram
// Copyright INRIA
  if prod(size(info))==0 then
    info=list(' ')
  end
  new_info=x_dialog('Set Diagram informations',info(1))
  if isempty(new_info) then 
    ok=%f
  else
    ok=%t
    new_info=list(new_info)
  end
endfunction
