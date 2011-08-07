function SelectLink_()
// unselect current selection and check 
// if new selection can be a link.
  SelectRegion=list(); // unselect region XXX 
  [Cmenu,Sel]=do_check_select_link();
  if Cmenu == '' then %pt=[];end 
  if ~Sel.equal[Select] then 
    // XXX  update selection in menus 
    Select = Sel;
  end
endfunction

function scmenu_check_select_link()
// unselect current selection and check 
// if new selection can be a link.
  SelectRegion=list(); // unselect region XXX 
  [Cmenu,Sel]=do_check_select_link();
  if Cmenu == '' then %pt=[];end 
  if ~Sel.equal[Select] then 
    // XXX  update selection in menus 
    Select = Sel;
  end
endfunction

function [Cmenu,Select]=do_check_select_link()
// unselect current selection and check 
// if new selection can be a link.
// note that this function resume %ppt 
// 
  Cmenu='';%pt=[];Select=[];
  // ? 
  if windows( find(%win==windows(:,2)), 1 )==100000 then
    return
  end
  kc=find(%win==windows(:,2))
  // %win is not a scicos window 
  if isempty(kc) then return;end 
  if %win==curwin then 
    // button press in current window 
    k=getobj(scs_m,%pt);
    if ~isempty(k) then
      // check if we want to initiate a Link ?
      Cmenu=check_edge(scs_m.objs(k),'',%pt);
      if Cmenu=='' then 
        Select=[k,%win];
      end       
    else 
      // click in the void 
      resume(%ppt=%pt);
    end
  elseif slevel > 1 then
    printf("XXX: do_check_select_link with slevel > 1");
    execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)');
    if ~isempty(k) then
      Select=[k,%win];
    else  
      // click in the void 
      resume(%ppt=%pt);
    end
  else 
    message('2 - This window is not an active scicos window')
  end
endfunction

