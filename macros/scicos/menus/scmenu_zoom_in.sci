function scmenu_zoom_in()
  Cmenu=''
  xinfo('Zoom in');
  zoomfactor=1.2;
  scs_m.props.zoom = scs_m.props.zoom*zoomfactor;
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
  edited=%t;
  xinfo(' ')
endfunction

