function unhilite_obj(o,draw=%t)
// Copyright ENPC
  if type(o,'short')=='m' then 
    for k=1:size(o,'*')
      unhilite_obj(scs_m.objs(o(k)),draw=draw);
    end
    return;
  end
  if o.type =='Block' then
    o.gr.hilited = %f;
    o.gr.invalidate[];
  elseif o.type =='Link' then
    // A link is a compound with a polyline inside 
    o.gr.children(1).hilited = %f;
    if draw then 
      o.gr.invalidate[];
    end
  end
endfunction
