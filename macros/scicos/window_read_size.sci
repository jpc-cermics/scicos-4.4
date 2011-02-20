function window_read_size(win)
  if nargin<1 then
    win=curwin
  end

  F=get_current_figure()
  gh=nsp_graphic_widget(win)

  xset("wresize",0);

  xflush()

  axsize=scs_m.props.wpar(5:6)
  xset("wdim",axsize(1),axsize(2))

  xflush()

  arect=[0 0 0 0]
  mrect=scs_m.props.wpar(1:4)
  wrect=[0,0,1,1];

  if length(F.children)==0 then
    xsetech(arect=arect,frect=mrect,fixed=%t,clip=%f,axesflag=0,iso=%t)
  else
    A=F.children(1)
    A.arect=arect
    A.frect=mrect
    A.fixed=%t
    A.clip=%f
    A.set[rect=mrect]; // rect is hidden but can be accessed through set and get
  end

  xflush()

  Vbox=gh.get_children[]
  Vbox=Vbox(1)
  ScrolledWindow=Vbox.get_children[]
  ScrolledWindow=ScrolledWindow(3)
  hscrollbar=ScrolledWindow.get_hadjustment[]
  vscrollbar=ScrolledWindow.get_vadjustment[]
  if size(scs_m.props.wpar,'*')>13 then
    hscrollbar.page_size=scs_m.props.wpar(14)
    vscrollbar.page_size=scs_m.props.wpar(15)
  end
  hscrollbar.value=scs_m.props.wpar(7)
  vscrollbar.value=scs_m.props.wpar(8)

  xflush()
endfunction
