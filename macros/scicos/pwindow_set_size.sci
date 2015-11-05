function pwindow_set_size()
  printf("enter: pwindow_set_size\n");
  rect=dig_bound(scs_m);
  if isempty(rect) then 
    wdim=[600,400];
  else
    wdim=%zoom*[rect(3)-rect(1),rect(4)-rect(2)]+[50,100];
  end;
  D=gdk_display_get_default();
  S=D.get_default_screen[]
  wdim_max= [S.get_width[] S.get_height[]];
  wdim = max(min(wdim,wdim_max),[400,300]);
  printf("set wdim to %dx%d\n",wdim(1),wdim(2));
  xset('wpdim',wdim(1),wdim(2));
  printf("quit: pwindow_set_size\n");
  xflush();
endfunction

