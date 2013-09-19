function scmenu_save_as_palette()
  Cmenu=''

  spmode=pal_mode
  pal_mode=%t

  [ok,scs_m]=do_SaveAs(scs_m)
  if ok&~super_block then edited=%f,end
  pal_mode=spmode
endfunction
