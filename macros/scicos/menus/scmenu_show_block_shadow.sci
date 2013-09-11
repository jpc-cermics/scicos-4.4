function scmenu_show_block_shadow()
  Cmenu=''
  [edited2,options]=do_options(scs_m.props.options,'3D',%f)
  scs_m.props.options=options
  // we do not need a resize here.
  if edited2 then scs_m=do_replot(scs_m);end
  if ~edited then edited=edited2, end
endfunction
