function scs_m=scs_show(scs_m,win)
// this function is used to display a diagram 
// in a new graphic window win.
// This is very similar to do_export_gwin 
// Copyright INRIA/Enpc
  xset('window',win);
  xclear();
  xselect();  
  options=scs_m.props.options
  set_background();
  scs_m=scs_m_remove_gr(scs_m);
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
  %zoom=restore(win,1.0);
  scs_m=drawobjs(scs_m,win);
endfunction

