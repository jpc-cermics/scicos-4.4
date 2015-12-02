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
  %zoom = scs_m.props.zoom;
  // add colors defined for diagram 
  set_cmap(scs_m.props.options('Cmap')); 
  if scs_m.props.options('3D')(1) && scs_m.props.options('3D')(2) > xget('lastpattern') then 
    // if 3D shape color is not in colormap we set it to gray level 
    scs_m.props.options('3D')(2) = xget('lastpattern')+3; 
  end
  drawtitle(scs_m.props,win)
  F=get_figure(win);
  // set figure background: xset('background',options.Background(1));
  if length(F.children) > 0 then 
    A=F.children(1);
    A.background=scs_m.props.options.Background(1);
  end
  if length(scs_m.objs) == 0 then
    F.invalidate[];
    return;
  end 
  // draw the objets and keep their associated graphic objects
  // note that drawobj will remove old graphic objects if they 
  // exists in each object
  F.draw_latter[];
  // needed in drawobj 
  options =  scs_m.props.options; 
  for i=1:length(scs_m.objs);
    scs_m.objs(i)=drawobj(scs_m.objs(i),F)
  end
  F.draw_now[]; // will just activate a process_updates 
  show_info(scs_m.props.doc)
endfunction
