function scmenu_default_link_colors()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'LinkColor')
  if changed then
    scs_m.props.options=options
    Cmenu='Replot'
    edited=%t
  end
  %pt=[]
endfunction
