function scs_m=drawobjs(scs_m)
// This function is used to add graphics 
// to the current figure and display them.
// Thus it is supposed that a current window is active.
// if scs_m does not contain graphic objects 
// then they are created and inserted in the 
// current figure.
// 
// if scs_m already contains graphic objects 
// a graphic refresh is activated using 
// F.invalidate[];
//
  if ~exists('options') then 
    options=scs_m.props.options;
  end
  drawtitle(scs_m.props)
  F=get_current_figure();
  win= xget('window');
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
    scs_m.objs(i)=drawobj(scs_m.objs(i),win)
  end
  F.draw_now[];
  // will just activate a process_updates 
  show_info(scs_m.props.doc)
endfunction
