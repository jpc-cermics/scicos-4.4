function scs_m=scicos_diagram_show(scs_m,win=0,margins=%t,scicos_uim=%f,scicos_istop=%t,read=%f,popup_dim=%t)
// shows a scs_m in a graphics window 
// 
  if ~window_exists(win) then 
    xset('window',win);
  else
    // remove graphics from figure except the current axe 
    F=get_figure(win);
    if length(F.children) > 0 then 
      F.children(1).children=list();
    end
  end
  // the scicos menu 
  if scicos_uim then scicos_set_uimanager(scicos_istop);end;
  // remove previously recorded graphics 
  scs_m=scs_m_remove_gr(scs_m);
  // fix the window size 
  window_set_size(win,viewport=[-1,-1],invalidate=%f,read=read,margins=margins,popup_dim=popup_dim);
  // redraw and expose
  scs_m=drawobjs(scs_m,win);
endfunction
