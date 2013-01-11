function scmenu_details()
  Cmenu=''
  do_details(Select)
endfunction

function do_details(x)
  if type(x,'short')=='m' then
    Select=x
    sel_items=size(Select)
    obj_selected = sel_items(1)
    if obj_selected==0 then
      o=scs_m
    else
      cwin=Select(1,2)
      if cwin==curwin then
        k=Select(1,1)
        o=scs_m.objs(k)
      end
    end
  else
    o=x
  end
  in=o
  editvar('in')
  if ~in.equal[o] then
    message('No change accepted')
  end
endfunction
