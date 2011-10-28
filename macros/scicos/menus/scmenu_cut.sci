function scmenu_cut()
// Cut selection and store 
// selection in Clipboard.
  
  if isempty(Select) then
    Cmenu='';%pt=[];%ppt=[];
    return
  end
  if Select(1,2)==curwin then
    scs_m_save=scs_m;
    nc_save=needcompile; 
    del=setdiff(1:size(scs_m.objs),Select(:,1));
    scs_m_sel=do_purge(do_delete1(scs_m,del,%f));
    if size(scs_m_sel.objs)==1 then
      Clipboard=scs_m_sel.objs(1);
    else
      Clipboard=scs_m_sel;
    end
    scicos_menus_paste_set_sensitivity(%t);
    [scs_m,DEL]=do_delete1(scs_m,Select(:,1)',%t);
    Select(find(Select(:,2)==curwin),:)=[];
    if ~isempty(DEL) then 
      needcompile=4
      edited=%t
      enable_undo=%t
      while scs_m.objs($).type =='Deleted' then
        scs_m.objs($) = null();
        if length(scs_m.objs)==0 then break,end;
      end
    end
    scicos_menus_select_set_sensitivity(Select, curwin); 
    Cmenu='';
  else
    message(['Only current diagram can be edited'])
    Cmenu='';%pt=[];%ppt=[];
  end
endfunction
