function scs_m=set_diagram_wpar(scs_m,wpar)
  // wpar = [frect, wdim, viewport, wpdim, winpos];
  //  wdim=scs_m.props.wpar(5:6);
  //  viewport=scs_m.props.wpar(7:8);
  //  wpdim = scs_m.props.wpar(9:10);
  //  wpos =  scs_m.props.wpar(11:12);
  //  %zoom=scs_m.props.wpar(13)
  if length(wpar) > 12 then wpar = wpar(1:12);end
  scs_m.props.wpar = wpar;

endfunction
