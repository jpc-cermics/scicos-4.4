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
  arect=[0 0 0 0];
  // (xmin,ymin,xmax,ymax)
  mrect=scs_m.props.wpar(1:4);
  // Pb here: schéma imported from 
  // scicoslab have not a proper wpar. 
  // mrect=mrect([1,3,2,4]);
  // we merge mrect with frect 
  [frect,wdim]=windows_compute_size();
  mrect=[min(mrect(1:2),frect(1:2)),max(mrect(3:4),frect(3:4))];
  wrect=[0,0,1,1];
  if length(F.children)==0 then
    xsetech(arect=arect,frect=mrect,fixed=%t,clip=%f,axesflag=0,iso=%t)
  else
    A=F.children(1)
    A.arect=arect
    A.frect=mrect
    A.fixed=%t
    A.clip=%f
    // rect is hidden but can be accessed through set and get
    A.set[rect=mrect];
  end
  xflush()
  Vbox=gh.get_children[]
  Vbox=Vbox(1)
  ScrolledWindow=Vbox.get_children[]
  ScrolledWindow=ScrolledWindow($)
  hscrollbar=ScrolledWindow.get_hadjustment[]
  vscrollbar=ScrolledWindow.get_vadjustment[]
  //brutal approach : loop until the gtk scrollbar have good size
  while hscrollbar.upper>axsize(1) then
    xflush()
    xpause(1)
  end

  while vscrollbar.upper>axsize(2) then
    xflush()
    xpause(1)
  end

  if size(scs_m.props.wpar,'*')>13 then
    hscrollbar.page_size=scs_m.props.wpar(14)
    vscrollbar.page_size=scs_m.props.wpar(15)
    //printf("in window_read_size : hscrollbar.page_size=%d, vscrollbar.page_size=%d\n",hscrollbar.page_size,vscrollbar.page_size);
  end
  hscrollbar.value=scs_m.props.wpar(7)
  vscrollbar.value=scs_m.props.wpar(8)
  gh.set_geometry_hints[]
  //printf("in window_read_size : hscrollbar.value=%d, vscrollbar.value=%d\n",hscrollbar.value,vscrollbar.value);
  xflush()
endfunction
