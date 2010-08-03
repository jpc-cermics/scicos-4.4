function scs_m=scs_show(scs_m,win)
// Copyright INRIA
  oldwin=xget('window')
  xset('window',win);
  xset('recording',0);
  xset('default')
  xclear(); // clear and tape_clean in nsp 
  xselect();
  wsiz=scs_m.props.wpar
  options=scs_m.props.options
  set_background()
  rect=dig_bound(scs_m);
  if ~isempty(rect) then 
    %wsiz=[rect(3)-rect(1),rect(4)-rect(2)];
  else
    %wsiz=[600/%zoom,400/%zoom]
  end
  // 1.3 to correct for X version
  xset('wpdim',min(1000,%zoom*%wsiz(1)),min(800,%zoom*%wsiz(2)));
  window_set_size(rect=rect,a=1);
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1)
  if new_graphics() then
    scs_m=drawobjs(scs_m),
  else
    drawobjs(scs_m),
  end
  if pixmap then xset('wshow'),end
endfunction

