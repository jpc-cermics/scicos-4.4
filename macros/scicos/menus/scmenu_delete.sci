function Delete_()
  Cmenu=''
  [%pt,scs_m,needcompile]=do_delete(%pt,scs_m,needcompile)
  pt=[]
endfunction

function [%pt,scs_m,needcompile]=do_delete(%pt,scs_m,needcompile)
// do_delete - delete a scicos object
// get first object to delete
//!
// Copyright INRIA
  xcursor(88);
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick(%f)
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
	xcursor();
	return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[]
    K=getobj(scs_m,[xc;yc])
    if ~isempty(K) then break,end
  end
  xcursor();
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

