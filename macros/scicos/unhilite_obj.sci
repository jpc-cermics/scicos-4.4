function unhilite_obj(o,draw=%t)
// Copyright ENPC
  if new_graphics() then
    // XXX A revoir car les objets on changé 
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
  else
    scicos_redraw_scene(scs_m,[],0)
  end
endfunction
