function pwindow_read_size()
  winsize=scs_m.props.wpar(9:10)
  winpos=scs_m.props.wpar(11:12)
  xset("wpdim",winsize(1),winsize(2))
  xset("wpos",winpos(1),winpos(2))
endfunction
