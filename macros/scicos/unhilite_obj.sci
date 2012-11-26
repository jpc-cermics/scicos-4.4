function unhilite_obj(o,draw=%t,warn=%f)
// Copyright ENPC
  if type(o,'short')=='m' then 
    for k=1:size(o,'*')
      unhilite_obj(scs_m.objs(o(k)),draw=draw,warn=warn);
    end
    return;
  end
  if ~o.iskey['gr'] then return;end 
  if o.type =='Block'|o.type=='Text' then
    if warn then
      o.gr.mark_color=10;
      o.gr.mark_size=0;
    end
    o.gr.hilited = %f;
  elseif o.type =='Link' then
    // A link is a compound with a polyline inside 
    if warn then
      o.gr.children(1).mark_size=-1;
      o.gr.children(1).mark=-2;
      o.gr.children(1).mark_color=-1;
    else
      o.gr.children(1).hilited = %f;
    end
  end
  if draw then 
    o.gr.invalidate[];
  end
endfunction

function unhilite_all(scs_m,draw=%t,warn=%f)
  for i=1:length(scs_m.objs)
    o=scs_m.objs(i)
    otype=o.type;
    if isequal(otype,'Block') then
      if scs_m.objs(i).model.sim(1)=='super' then
        unhilite_all(scs_m.objs(i).model.rpar,draw=draw,warn=warn)
      end
    end
    unhilite_obj(o,draw=draw,warn=warn)
  end
endfunction
