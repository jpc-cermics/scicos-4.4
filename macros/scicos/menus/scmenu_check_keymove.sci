function scmenu_check_keymove()
// action initiated by pressing the 
// move key
  [Cmenu,Sel]=do_check_keymove(Select,"Move");
  if ~Sel.equal[Select] then 
    // XXX selection have to be changed 
    Select=Sel;
  end
  if Cmenu=='' then pt=[];end 
endfunction

function scmenu_check_keysmartmove()
// action initiated by pressing the 
// move key
  [Cmenu,Sel]=do_check_keymove(Select,"Smart Move");
  if ~Sel.equal[Select] then 
    // XXX selection have to be changed 
    Select=Sel;
  end
  if Cmenu=='' then pt=[];end 
endfunction

function [Cmenu,Select]=do_check_keymove(Select,action)
// this function can change %ppt through resume
// 
  Cmenu='';Select=Select;
  if %win == curwin then 
    // the press is in the current window
    Cmenu=action;
    k=getobj(scs_m,%pt)
    if isempty(k)  then //&& size(Select,1) <= 0
      // if the press is in the void of the current window 
      // and no selection
      Cmenu="";Select=[];
      return;
    end
    if size(Select,1) <= 1 then
      // with zero or one object already selected 
      // check if me move object or create a link
      Select=[k,%win];
    else 
      // more than one object are selected 
      if isempty(find(k==Select(:,1))) then 
	// restrict selection to moving object 
	Select=[k,%win];
      else
	Select=Select;
      end
    end
  end
endfunction



