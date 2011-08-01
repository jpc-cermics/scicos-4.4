function scmenu_save_as_palette()
  Cmenu=''

  spmode=pal_mode
  pal_mode=%t

  [scs_m,editedx]=do_SaveAs()
  if ~super_block then edited=editedx,end
  pal_mode=spmode
endfunction
