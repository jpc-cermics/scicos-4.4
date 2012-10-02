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
  //window_set_size(curwin,viewport)
  window_set_size(curwin,%f)
  //scs_m=do_replot(scs_m);
  //we need redraw text
  for i=1:length(scs_m.objs)
    if scs_m.objs(i).type=="Text" then
      o=scs_m.objs(i)
      [o,ok]=drawobj(o,F)
      scs_m.objs(i)=o;
    end
  end
  F.invalidate[]
  xinfo(' ')
endfunction
