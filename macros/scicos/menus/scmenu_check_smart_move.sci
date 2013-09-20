function scmenu_check_smart_move()
// after a mouse event in %win at position %pt 
// 
  [Cmenu,Sel]=do_check_smart_move(Select);
  if ~Sel.equal[Select] then 
    // XXX selection have to be changed 
    Select=Sel;
  end
  if Cmenu=='' then pt=[];end 
endfunction

function [Cmenu,Select]=do_check_smart_move(Select)
// this function can change %ppt throught resume
// 
  Cmenu='';Select=Select;
  if %win== curwin then
    // the press is in the current window
    Cmenu="Smart Move";
    k=getobj(scs_m,%pt)
    if isempty(k) then
      // if the press is in the void of the current window 
      Cmenu="SelectRegion";resume(%ppt=%pt);Select=[];
      return;
    end
    if size(Select,1) <=1 then
      // with zero or one object already selected 
      // check if me move object or create a link
      Cmenu=check_edge(scs_m.objs(k),"Smart Move",%pt)
      if Cmenu=="Link" then
	Cmenu="Smart Link"
	Select=[]
      elseif Cmenu=="Smart Move" then
	Select=[k, %win]
      else
        Cmenu="SelectRegion";
        Select=[];
        resume(%ppt=%pt);
      end
    else
      // more than one object are selected 
      if isempty(find(k==Select(:,1))) then
	// restrict selection to moving object 
        Cmenu=check_edge(scs_m.objs(k),Cmenu,%pt);
        if Cmenu=="Smart Move" then
	  Select=[k,%win];
        else
          Cmenu="SelectRegion";
          resume(%ppt=%pt);
          Select=[];
        end
      else
	Select=Select
      end
    end
  else
    // %win <> curwin 
    // we should never be there since navigation should 
    //printf('do_check_smart_move with %%win<>curwin\n');
    kc=find(%win==windows(:,2));
    // check if the press is not inside an scicos active window
    if isempty(kc) then return;end 
    if slevel > 1 then
      printf('XXXX a press with slevel > 1 ');
      execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
    else
      k=[];
    end
    if ~isempty(k) then
      Cmenu="Duplicate"
      Select=[k,%win]
    else
      // press in the void
      Cmenu="SelectRegion"
      Select=[]
    end
  end
endfunction
