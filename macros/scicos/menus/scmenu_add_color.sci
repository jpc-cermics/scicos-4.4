function scmenu_add_color()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'Cmap')
  if changed then 
    scs_m.props.options=options
    set_cmap(scs_m.props.options('Cmap'))
    set_background()
    Cmenu='Replot'
    edited=%t
  end
  %pt=[]
endfunction
