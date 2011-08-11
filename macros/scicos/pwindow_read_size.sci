function pwindow_read_size(win)
  if nargin<1 then
    win=curwin
  end
  gh=nsp_graphic_widget(win)
  winsize=scs_m.props.wpar(9:10)
  winpos=scs_m.props.wpar(11:12)
  gh.move[winpos(1),winpos(2)]
  gh.resize[winsize(1),winsize(2)]
  xflush()
endfunction
