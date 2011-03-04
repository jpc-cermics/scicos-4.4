function scs_m=scs_show(scs_m,win)
// this function is used to display a diagram 
// in a new graphic window win.
//
// This is very similar to do_export_gwin 
// 
// Copyright INRIA
  xset('window',win);
  xclear();
  xselect();
  pwindow_set_size()
  window_set_size()
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1)
  // scs_m is maybe already displayed in an other windows 
  // thus we remove gr from scs_m for drawobjs to redraw.
  scs_m=scs_m_remove_gr(scs_m)
  scs_m=drawobjs(scs_m),
endfunction

