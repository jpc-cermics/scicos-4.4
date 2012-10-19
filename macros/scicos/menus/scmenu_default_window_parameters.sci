function scmenu_default_window_parameters()
// Copyright INRIA
  Cmenu='Replot'
  %zoom=1.4   // not a good idea, use a variable. It is also used in scicos.sci
  pwindow_set_size();
  edited=%t
  //window_set_size();
endfunction
