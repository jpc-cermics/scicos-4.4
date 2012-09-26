function pwindow_read_size(win)
  if nargin<1 then
    win=curwin
  end
  gh=nsp_graphic_widget(win)
  winsize=scs_m.props.wpar(9:10)
  winpos=scs_m.props.wpar(11:12)
  gh.move[winpos(1),winpos(2)]
  xset("wresize",0);
  xset('wdim',int(winsize(1)),int(winsize(2)))
  wdim=xget('wdim');
  while not(and(wdim==[int(winsize(1)),int(winsize(2))]))
    xset('wdim',int(winsize(1)),int(winsize(2)))
    wdim=xget('wdim');
    xflush()
    xpause(1);
  end
  xset('wpdim',int(winsize(1)),int(winsize(2)))
  wpdim=xget('wpdim');
  while not(and(wpdim==[int(winsize(1)),int(winsize(2))])) then
    xset('wpdim',int(winsize(1)),int(winsize(2)))
    wpdim=xget('wpdim');
    xflush();
    xpause(1);
  end
  F=get_current_figure();
  gh=nsp_graphic_widget(F.id)
  gh.set_geometry_hints[]
endfunction
