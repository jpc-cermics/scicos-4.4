function scmenu_zoom_out()
  Cmenu=''
  xinfo('Zoom out');
  zoomfactor=1.2
  F=get_current_figure();
  for i=1:length(scs_m.objs)
    F.remove[scs_m.objs(i).gr];
  end
  scs_m.props.zoom = scs_m.props.zoom/zoomfactor;
  window_set_size(curwin,%f,invalidate=%f,popup_dim=%f);
  // we need redraw text and some blocks
  // with not filled text
  scs_m=scs_m_remove_gr(scs_m); 
  scs_m=drawobjs(scs_m,curwin);
  edited=%t;
  xinfo(' ')
endfunction
