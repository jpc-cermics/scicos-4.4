function Link_()
  Cmenu=''
  xinfo('Click link origin, drag, click left for final or intermediate points or right to cancel')
  [scs_m,needcompile]=getlink(%pt,scs_m,needcompile);
  %pt=[];Select=[];
  xinfo(' ')
endfunction

