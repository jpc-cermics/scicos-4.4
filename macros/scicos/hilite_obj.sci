function hilite_obj(o,draw=%t)
// Copyright INRIA
// just keep the new_graphics case 
// 
  if type(o,'short')=='m' then 
    for k=1:size(o,'*')
      hilite_obj(scs_m.objs(o(k)),draw=draw);
    end
    return;
  end
  if ~o.iskey['gr'] then return;end 
  if o.type =='Block' then
    o.gr.hilited = %t;
    o.gr.invalidate[];
  elseif o.type =='Link' then
    // A link is a compound with a polyline inside 
    o.gr.children(1).hilited = %t;
    o.gr.invalidate[];
  end
endfunction

