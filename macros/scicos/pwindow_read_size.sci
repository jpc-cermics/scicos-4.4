function pwindow_read_size(win)
  // printf("debug: inside pwindow_read_size\n");
  if nargin<1 then
    win=curwin
  end
  winsize=scs_m.props.wpar(9:10)
  winpos=scs_m.props.wpar(11:12)
  gh=nsp_graphic_widget(win)
  gh.move[winpos(1),winpos(2)]
  xset('wdim',int(winsize(1)),int(winsize(2)))
  xset('wpdim',int(winsize(1)),int(winsize(2)))
endfunction
