function scmenu_background_color()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'Background')
  if changed then
    scs_m.props.options=options
    set_background()
    Cmenu='Replot'
    edited=%t
  end
endfunction
