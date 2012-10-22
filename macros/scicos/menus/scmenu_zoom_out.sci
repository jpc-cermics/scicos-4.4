function scmenu_zoom_out()
  Cmenu=''
  xinfo('Zoom out')
  zoomfactor=1.2 
  %zoom=%zoom/zoomfactor
  F=get_current_figure()
  gh=nsp_graphic_widget(curwin)
  winsize=gh.get_size[]
  viewport=xget("viewport");
  viewport=viewport/zoomfactor-0.5*winsize*(1-1/zoomfactor)

  F.draw_latter[]; // to block the redraw in window_set_size
  window_set_size(curwin,%f,invalidate=%f);
  //we need redraw text and some blocks
  //with not filled text
  [scs_m]=scmenu_redraw_zoomed_text(scs_m,F);
  F.draw_now[];
  F.invalidate[];
  edited=%t
  xinfo(' ')
endfunction
