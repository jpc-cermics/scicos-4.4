function scmenu_rotate_left()
  Cmenu=''
  if ~isempty(Select) && ~isempty(find(Select(:,2)<>curwin)) then
    Select=[]; Cmenu='Rotate Left';
    return
  end
  scs_m_save=scs_m
  nc_save=needcompile
  [scs_m]=do_turn(%pt,scs_m,45)
  Cmenu=''
  %pt=[]
endfunction
