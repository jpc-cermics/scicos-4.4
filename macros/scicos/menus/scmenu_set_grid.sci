function scmenu_set_grid()
  [edited2,options]=do_options(scs_m.props.options,'Grid',%f)
  scs_m.props.options=options
  if options('Grid') && edited2 then
    scs_m=do_replot(scs_m)
  end
  if ~edited then edited=edited2, end
  Cmenu='';%pt=[];
endfunction
