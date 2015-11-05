function window_read_size(win)
  printf("-->window_read_size\n");
  if nargin<1 then
    win=curwin
  end

  xset('window',win)
  F=get_current_figure()
  gh=nsp_graphic_widget(win)

  axsize=scs_m.props.wpar(5:6)

  xset("wdim",axsize(1),axsize(2))
  xset('wresize',2);
  arect=[0 0 0 0];
  // (xmin,ymin,xmax,ymax)
  mrect=scs_m.props.wpar(1:4);
  // Pb here: sch�ma imported from
  // scicoslab have not a proper wpar.
  // mrect=mrect([1,3,2,4]);
  // we merge mrect with frect
  [frect,wdim]=darea_window_compute_size(dig_bound(scs_m));
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

  if size(scs_m.props.wpar,'*')>13 then
    if exists('gtk_get_major_version','function') then
      hscrollbar.set_page_size[scs_m.props.wpar(14)];
      vscrollbar.set_page_size[scs_m.props.wpar(15)];
    else
      hscrollbar.page_size=scs_m.props.wpar(14)
      vscrollbar.page_size=scs_m.props.wpar(15)
    end
  end
  if exists('gtk_get_major_version','function') then
    hscrollbar.set_value[scs_m.props.wpar(7)];
    vscrollbar.set_value[scs_m.props.wpar(8)];
  else
    hscrollbar.value=scs_m.props.wpar(7)
    vscrollbar.value=scs_m.props.wpar(8)
  end
  F.invalidate[]
  F.process_updates[]
endfunction
