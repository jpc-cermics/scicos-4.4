function scs_m=drawobjs(scs_m,win)
// This function is used to create/add graphics 
// in the current window (xget('window')) or to
// win if win is given. 
// The graphic objects which are created are 
// inserted in the scs_m structure. 
//
  if nargin < 2 then 
    win = xget('window');
  end
  if ~exists('options') then 
    options=scs_m.props.options;
  end
  drawtitle(scs_m.props,win)
  set_background()
  F=get_figure(win);
  if length(scs_m.objs) == 0 then
    F.invalidate[];
    return;
  end 
  // draw the objets and keep their associated graphic objects
  // note that drawobj will remove old graphic objects if they 
  // exists in each object
  F.draw_latter[];
  for i=1:length(scs_m.objs);
    scs_m.objs(i)=drawobj(scs_m.objs(i),F)
  end
  F.draw_now[]; // will just activate a process_updates 
  show_info(scs_m.props.doc)
endfunction
