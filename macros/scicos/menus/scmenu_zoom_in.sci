function Zoomin_()
  Cmenu=''
  xinfo('Zoom in')
  zoomfactor=1.2
  %zoom=%zoom*zoomfactor
  F=get_current_figure()
  gh=nsp_graphic_widget(curwin)
  winsize=gh.get_size[]
  axsize=xget("wdim")
  viewport=xget("viewport");
  viewport = viewport * zoomfactor - 0.5 * winsize*(1-zoomfactor)  ;
  viewport=max([0,0],min(viewport,-winsize+axsize)) 
  //window_set_size(gh_window, viewport);
  window_set_size(curwin,viewport)
  drawobjs(scs_m),
  xinfo(' ')
  if pixmap then xset('wshow'),end
endfunction

