function scmenu_region_to_palette()
  Cmenu=''
  if isempty(Select) then
    if ~isequal(%win,curwin) then
      return
    end
    [%pt,scs_m,Select]=do_region2block(%pt,scs_m,PAL_f)
  else
    if ~isequal(Select(1,2),curwin) then
      return
    end
    [%pt,scs_m]=do_select2block(%pt,scs_m,PAL_f);
  end
  Cmenu='';%pt=[];
endfunction
