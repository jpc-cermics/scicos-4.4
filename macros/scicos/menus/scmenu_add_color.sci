function scmenu_add_color()
  [edited,options]=do_options(scs_m.props.options,'Cmap',edited)
  if edited then 
    scs_m.props.options=options
    set_cmap(scs_m.props.options('Cmap'))
    set_background()
    Cmenu='Replot'
  else
    Cmenu=''
  end
  %pt=[]
endfunction
