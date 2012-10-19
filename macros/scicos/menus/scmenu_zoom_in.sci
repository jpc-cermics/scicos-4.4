function scmenu_zoom_in()
  Cmenu=''
  xinfo('Zoom in')
  zoomfactor=1.2
  %zoom=%zoom*zoomfactor
  F=get_current_figure()
  gh=nsp_graphic_widget(curwin)
  winsize=gh.get_size[]
  axsize=xget("wdim")
  viewport=xget("viewport");
  viewport=viewport*zoomfactor-0.5*winsize*(1-zoomfactor)
  viewport=max([0,0],min(viewport,-winsize+axsize))

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%f
    end
  end

  window_set_size(curwin,%f)
  //we need redraw text and some blocks
  //with not filled text
  [scs_m]=redrawifnecessary(scs_m,F)

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%t
    end
  end

  F.invalidate[]
  xinfo(' ')
endfunction
