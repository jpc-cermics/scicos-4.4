function scmenu_set_default_action()
  Cmenu='';%pt=[];
  [edited,options]=do_options(scs_m.props.options,'DefaultAction',edited)
  scs_m.props.options=options
endfunction
