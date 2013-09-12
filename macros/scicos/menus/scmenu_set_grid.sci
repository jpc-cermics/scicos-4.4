function scmenu_set_grid()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'Grid')
  if changed then
    scs_m.props.options=options
    edited=%t
    if options('Grid') then
      Cmenu='Replot'
    end
  end
  %pt=[]
endfunction
