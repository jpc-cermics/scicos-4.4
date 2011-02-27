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
  xinfo(' ')
endfunction
