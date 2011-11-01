function unhilite_obj(o,draw=%t)
// Copyright ENPC
  if type(o,'short')=='m' then 
    for k=1:size(o,'*')
      unhilite_obj(scs_m.objs(o(k)),draw=draw);
    end
    return;
  end
  if ~o.iskey['gr'] then return;end 
  if o.type =='Block'|o.type=='Text' then
    o.gr.hilited = %f;
  elseif o.type =='Link' then
    // A link is a compound with a polyline inside 
    o.gr.children(1).hilited = %f;
  end
  if draw then 
    o.gr.invalidate[];
  end
endfunction

function unhilite_all(scs_m,draw=%t)
  for i=1:length(scs_m.objs)
    o=scs_m.objs(i)
    otype=o.type;
    if isequal(otype,'Block') then
      if scs_m.objs(i).model.sim(1)=='super' then
        unhilite_all(scs_m.objs(i).model.rpar,draw=draw)
      end
    end
    if o.iskey['gr'] then
      if otype=='Block' | otype=='Text' then
        o.gr.hilited = %f;
      elseif otype =='Link' then
        o.gr.children(1).hilited=%f
      end
      if draw then 
        o.gr.invalidate[];
      end
    end
  end
endfunction

