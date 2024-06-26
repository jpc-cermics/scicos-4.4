function scmenu_check_move()
// check to decide between possible 
// move actions 
  [Cmenu,Sel]=do_check_move(Select);
  if ~Sel.equal[Select] then 
    // selection have to be changed 
    Select = Sel;
    if ~isempty(Sel) then Sel=Sel(1);end
  end
  if Cmenu=='' then pt=[];end 
endfunction

function [Cmenu,Select]=do_check_move(Select)
// this function can change %ppt through resume
// 
  Cmenu='';Select=Select;
  if %win == curwin then 
    // the press is in the current window
    Cmenu="Move";
    k=getobj(scs_m,%pt)
    //pause
    if isempty(k) then
      // if the press is in the void of the current window 
      Cmenu="SelectRegion";resume(%ppt=%pt);Select=[];
      return;
    end
    if size(Select,1) <= 1 then
      // with zero or one object already selected 
      // check if me move object or create a link
      Cmenu=check_edge(scs_m.objs(k),Cmenu,%pt);
      if Cmenu=="Link" then
	Select=[];
      elseif Cmenu=="Move" then
	Select=[k,%win];
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
        if Cmenu=="Move" then
          Select=[k,%win];
        else
          Cmenu="SelectRegion";
          resume(%ppt=%pt);
          Select=[];
        end 
      else
	Select=Select;
      end
    end
  else
    // %win <> curwin 
    // we should never be there since navigation should 
    //printf('do_check_move with %%win<>curwin\n');
    // the press is not in the current window 
    kc=find(%win==windows(:,2));
    // check if the press is not inside an scicos active window
    if isempty(kc) then return;end 
    if slevel>1 then 
      printf('XXXX a press with slevel > 1 ');
      // the press is over a block inside a superblock window
      execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
    else
      k=[];
    end
    if ~isempty(k) then 
      // press over a valid block 
      Cmenu="Duplicate"
      Select=[k,%win]
    else 
      // press in the void   
      Cmenu="SelectRegion"
      Select=[];
    end
  end
endfunction



