function scs_m=scs_show(scs_m,win)
// shows diagram scs_m in a new graphic window win.
// This is very similar to do_export_gwin 
// 
// Copyright INRIA
  xset('window',win);
  xset('recording',0);
  xset('default')
  xclear(); // clear and tape_clean in nsp 
  xselect();
  pwindow_set_size()
  window_set_size()
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1)
  scs_m=drawobjs(scs_m),
endfunction

