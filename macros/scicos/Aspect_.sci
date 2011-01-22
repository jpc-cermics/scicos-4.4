function Aspect_()
  Cmenu=''
  [edited,options]=do_options(scs_m.props.options,'3D')
  scs_m.props.options=options
  if new_graphics() then 
    // we do not need a resize here.
    if edited then scs_m=do_replot(scs_m);end
  else
    Cmenu='Replot';
  end
endfunction
