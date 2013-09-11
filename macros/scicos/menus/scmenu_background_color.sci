function scmenu_background_color()
  Cmenu=''
  [edited,options]=do_options(scs_m.props.options,'Background',edited)
  scs_m.props.options=options
  
  if edited then
    scs_m.props.options=options
    set_background()
    Cmenu='Replot'
  end
endfunction
