function Delete_()
  [%pt,scs_m,needcompile,Select]=do_delete(%pt,scs_m,needcompile,Select)
  Cmenu=''
  pt=[]
endfunction

function [%pt,scs_m,needcompile,Select]=do_delete(%pt,scs_m,needcompile,Select)
// do_delete - delete a scicos object
// get first object to delete
//!
// Copyright INRIA

  xcursor();
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
    xcursor(88); //TODO in scicos.sci
    xc=%pt(1);yc=%pt(2);%pt=[]
    K=getobj(scs_m,[xc;yc])
    if isempty(K) then return,end
  else
    K=NSelect(:,1)'
  end

  scs_m_save=scs_m,nc_save=needcompile
  // do not draw here 
  if new_graphics() then 
    [scs_m,DEL]=do_delete1(scs_m,K,%t)
  else
    [scs_m,DEL]=do_delete1(scs_m,K,%f)
  end
  // pause in do_delete;
  if ~isempty(DEL) then 
    needcompile=4,
    // suppress right-most deleted elements
    // scs_m.objs($).iskey['Deleted']
    // getfield(1,scs_m.objs($))=='Deleted'
    
    if new_graphics() then 
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
    else
      while scs_m.objs($).iskey['Deleted'] then
	scs_m.objs($)=null();
	if length(scs_m.objs)==0 then break,end
      end
      // redraw 
      xtape_status=xget('recording')
      [echa,echb]=xgetech();
      xclear(curwin,%t);
      xset("recording",1);
      xsetech(echa,echb);
      drawobjs(scs_m);
      xset('recording',xtape_status);
    end
    resume(scs_m_save,nc_save,enable_undo=%t,edited=%t,needreplay=needreplay);
  end
endfunction

