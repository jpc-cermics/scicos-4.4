function ret=hilite_obj(o,draw=%t,warn=%f)
// Copyright INRIA
// just keep the new_graphics case 

  ret=%t;
  
  if type(o,'short')=='m' then 
    for k=1:size(o,'*')
      hilite_obj(scs_m.objs(o(k)),draw=draw,warn=warn);
    end
    return;
  end
  if ~o.iskey['gr'] then 
    ret=%f;// printf("Object not displayed !\n");
    return;
  end 
  if o.type =='Block'|o.type=='Text' then
    if warn then
      o.gr.hilite_color=7;
      o.gr.hilite_size=1;
    end
    o.gr.hilited = %t;
  elseif o.type =='Link' then
    // A link is a compound with a polyline inside 
    if warn then
      o.gr.children(1).mark_size=1;
      o.gr.children(1).mark=15;
      o.gr.children(1).mark_color=7;
    else
      o.gr.children(1).hilited = %t;
    end
  end
  if draw then 
    o.gr.invalidate[];
  end
endfunction
