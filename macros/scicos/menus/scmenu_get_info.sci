function scmenu_get_info()
  do_block_info(%pt,scs_m)
  Cmenu=''
  %pt=[]
endfunction

function %pt=do_block_info(%pt,scs_m)
// Copyright INRIA
  L=list();
  if isempty(Select) then
    win = %win;
    xc = %pt(1); yc = %pt(2); %pt = []
    kc = find(win==windows(:,2))
    if isempty(kc) then
      message("This window is not an active scicos window.")
      return
    elseif win==curwin then   // click in the current window 
      k=getobj(scs_m,[xc;yc])
      if ~isempty(k) then [txt,L]=get_block_info(scs_m,k), end
    end
  else
    //** Object selected  
    if size(Select,1)>1 then
      message("Only one block can be selected for this operation.")
      return
    end
    win=Select(1,2);
    kc=find(win==windows(:,2))
    k=Select(1,1)
    if isempty(kc) then
      message("This window is not an active scicos window.")
    elseif win==curwin then // click in the current window 
      [txt,L]=get_block_info(scs_m,k)
    end
  end
  // show info 
  if length(L)<> 0 then scicos_show_info_notebook(L); end 

endfunction


