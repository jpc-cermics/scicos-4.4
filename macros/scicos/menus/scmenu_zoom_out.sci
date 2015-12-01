function scmenu_zoom_out()
  Cmenu=''
  xinfo('Zoom out')
  zoomfactor=1.2 
  scs_m.props.zoom = scs_m.props.zoom/zoomfactor;

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%f
    end
  end

  window_set_size(curwin,%f,invalidate=%f,popup_dim=%f);
  
  // we need redraw text and some blocks with not filled text
  [scs_m]=scmenu_redraw_zoomed_text(scs_m,F);

  for i=1:length(scs_m.objs)
    if scs_m.objs(i).iskey['gr'] then
      scs_m.objs(i).gr.show=%t
    end
  end

  F.invalidate[];
  edited=%t
  xinfo(' ')
endfunction
