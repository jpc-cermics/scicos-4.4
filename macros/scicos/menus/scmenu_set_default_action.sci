function scmenu_set_default_action()
  Cmenu='';%pt=[];
  [changed,options]=do_options(scs_m.props.options,'DefaultAction')
  if changed then
    scs_m.props.options=options
    edited=%t
  end
endfunction
