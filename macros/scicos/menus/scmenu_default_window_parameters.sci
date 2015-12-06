function scmenu_default_window_parameters()
// Copyright INRIA
  Cmenu='';
  scs_m.props.zoom=1.4;
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
  edited=%t;
  xinfo(' ')
endfunction
