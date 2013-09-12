function scmenu_id_fonts()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'ID')
  if changed then
    scs_m.props.options=options
    Cmenu='Replot'
    edited=%t
  end
  %pt=[]
endfunction
