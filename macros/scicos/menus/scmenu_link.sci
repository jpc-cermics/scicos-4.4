function Link_()
  Cmenu=''
  xinfo('Click link origin, drag, click left for final or intermediate points or right to cancel')
  if new_graphics() then 
    xcursor(GDK.PENCIL);
    [%pt,scs_m,needcompile]=getlink_new(%pt,scs_m,needcompile);
    xcursor();
  else
    [%pt,scs_m,needcompile]=getlink(%pt,scs_m,needcompile);
  end
  xinfo(' ')
endfunction

