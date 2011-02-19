function scs_m=drawobjs(scs_m)
// Copyright INRIA
// adapted to a graphic object 
    drawtitle(scs_m.props)
    F=get_current_figure();
    if length(scs_m.objs) == 0 then
      F.draw_now[];
      return;
    end 
    // check if we already have internal graphic objects 
    if scs_m.objs(1).iskey['gr'] then 
      // we already have stuffs recorded
      F.invalidate[];
      return;
    end
    // draw the objets and keep their associated graphic objects
    F=get_current_figure();
    F.draw_latter[];
    for i=1:length(scs_m.objs);
      scs_m.objs(i)=drawobj(scs_m.objs(i))
    end
    F.draw_now[];
    // will just activate a process_updates 
    show_info(scs_m.props.doc)
endfunction
