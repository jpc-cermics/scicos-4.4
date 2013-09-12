function scmenu_show_block_shadow()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'3D')
  if changed then
    scs_m.props.options=options
    // we do not need a resize here.
    scs_m=do_replot(scs_m)
    edited=%t
  end
endfunction
