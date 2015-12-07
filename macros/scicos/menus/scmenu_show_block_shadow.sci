function scmenu_show_block_shadow()
  Cmenu=''
  [changed,options]=do_options(scs_m.props.options,'3D')
  if changed then
    scs_m.props.options=options;
    scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%f,read=%f,popup_dim=%f);
    edited=%t;
  end
endfunction
