function scmenu_default_window_parameters()
// Copyright INRIA
  Cmenu='Replot'
  %zoom=1.4;// not a good idea, use a variable. It is also used in scicos.sci
  // update wdim and wpdim
  window_set_size();
  edited=%t
endfunction
