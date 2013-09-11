function scmenu_id_fonts()
  Cmenu=''
  [edited,options]=do_options(scs_m.props.options,'ID',edited)
  scs_m.props.options=options
  if edited then Cmenu='Replot',end
endfunction
