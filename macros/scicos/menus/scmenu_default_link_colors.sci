function scmenu_default_link_colors()
  Cmenu=''
  [edited,options]=do_options(scs_m.props.options,'LinkColor',edited)
  scs_m.props.options=options
  if edited then Cmenu='Replot',end
endfunction
