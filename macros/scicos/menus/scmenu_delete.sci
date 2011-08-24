function scmenu_delete()
  [%pt,scs_m,needcompile,Select]=do_delete(%pt,scs_m,needcompile,Select)
  Cmenu=''
  pt=[]
endfunction

function [%pt,scs_m,needcompile,Select]=do_delete(%pt,scs_m,needcompile,Select)
// do_delete - delete a scicos object
// get first object to delete
//!
// Copyright INRIA

  if %win<>curwin then
    //disp('window mismatch in do_delete')
    return
  end

  if ~isempty(Select) then
    NSelect=Select(find(Select(:,2)==curwin),:) 
  else
    NSelect=[]
  end
  
  if isempty(NSelect) then
    if ~isempty(%pt) then 
      xc=%pt(1);yc=%pt(2);%pt=[]
      K=getobj(scs_m,[xc;yc])
    else
      K=[];
    end
  else
    K=NSelect(:,1)';
  end

  if isempty(K) then 
    message('Make a selection first !');
    return;
  end
  
  scs_m_save=scs_m,nc_save=needcompile
  // do not draw here 
  [scs_m,DEL]=do_delete1(scs_m,K,%t)
  // pause in do_delete;
  if ~isempty(DEL) then 
    needcompile=4,
    // suppress right-most deleted elements
    // scs_m.objs($).iskey['Deleted']
    // getfield(1,scs_m.objs($))=='Deleted'
    while scs_m.objs($).iskey['Deleted'] then
      // need to remove the graphic object from figure 
      scs_m.objs($)=null();
      if length(scs_m.objs)==0 then break,end
    end
    if ~isempty(NSelect) then
      new_Select=[]
      for i=1:size(Select,1)
	if isempty(find(Select(i,1)==DEL)) | isempty(find(Select(i,2)==curwin))
	  new_Select=[new_Select;Select(i,:)];
	end
      end
      Select=new_Select;
    end
    resume(scs_m_save,nc_save,enable_undo=%t,edited=%t,needreplay=needreplay);
  end
endfunction

