function scmenu_set_grid()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'Grid')
  if changed then
    scs_m.props.options=options
    edited=%t
  end
  if scs_m.props.options('Grid') && changed then
    Cmenu='Replot'
  end
  %pt=[]
endfunction
