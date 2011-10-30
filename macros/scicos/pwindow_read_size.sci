function pwindow_read_size(win)
  if nargin<1 then
    win=curwin
  end
  gh=nsp_graphic_widget(win)
  F=get_current_figure();
  winsize=scs_m.props.wpar(9:10)
  winpos=scs_m.props.wpar(11:12)
  gh.move[winpos(1),winpos(2)]
  gh.resize[winsize(1),winsize(2)]
  //printf(" winsize(1)=%d, winsize(2)=%d\n",winsize(1),winsize(2))
  xset('wdim',winsize(1),winsize(2)) //en double !!
  xflush()
endfunction
