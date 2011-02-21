function Zoomout_()
  Cmenu=''
  xinfo('Zoom out')
  zoomfactor=1.2 
  %zoom=%zoom/zoomfactor
  F=get_current_figure()
  gh=nsp_graphic_widget(curwin)
  winsize=gh.get_size[]
  viewport=xget("viewport");
  viewport=viewport/zoomfactor-0.5*winsize*(1-1/zoomfactor)
  window_set_size(curwin,viewport)
  // F.invalidate[] or  drawobjs(scs_m)
  // are not usefull here window_set_size should produce a redraw
  // drawobjs(scs_m);
  xinfo(' ')
  if pixmap then xset('wshow'),end
endfunction
