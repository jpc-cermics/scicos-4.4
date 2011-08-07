function scs_m=delete_unconnected(scs_m)
// delete unconnected blocks and all relevant parts of a diagram
// may be used before compilation
// Copyright INRIA
// printf("In delete unconnected\n");

  n=length(scs_m.objs)
  if n==0 then return;end 
  
  DEL=[]
  DELL=[]
  finish=%f
  while ~finish
    finish=%t
    for k=1:n  //loop on scs_m objects
      if scs_m.objs(k).type =='Block' then
        if scs_m.objs(k).gui<>'SUM_f'&scs_m.objs(k).gui<>'SOM_f' then
	  if find(scs_m.objs(k).gui==['IFTHEL_f','ESELECT_f']) then
	    kk=[find(scs_m.objs(k).graphics.pein==0),find(scs_m.objs(k).graphics.pin==0)]
	    if ~isempty(kk) // a synchro block is not active, remove it
	      [scs_m,DEL1,DELL1]=do_delete1(scs_m,k,%f)
	      DEL=[DEL DEL1]
	      DELL=[DELL DELL1]
	      finish=%f
	    end
	  else
	    kk=find(scs_m.objs(k).graphics.pin==0);
	    if ~isempty(kk) then 
	      // at least one  input port is not connected delete the
              // block
	      if scs_m.objs(k).graphics.iskey["in_implicit"] then
		if ~isempty(scs_m.objs(k).graphics.in_implicit) && ...
		      ~isempty(scs_m.objs(k).graphics.in_implicit(kk)) then
		  if or(scs_m.objs(k).graphics.in_implicit(kk)<>"I") then 
		    [scs_m,DEL1,DELL1]=do_delete1(scs_m,k,%f)
		    DEL=[DEL, DEL1]
		    DELL=[DELL, DELL1]
		    finish=%f
		  end
		end
	      else
	        [scs_m,DEL1,DELL1]=do_delete1(scs_m,k,%f)
	        DEL=[DEL, DEL1]
	        DELL=[DELL, DELL1]
	        finish=%f
	      end
	    end
	  end
        end
      end
    end 
  end

  //Suppress rigth-most deleted elements
  while scs_m.objs($).type =='Deleted' then
    scs_m.objs($)=null();
    if length(scs_m.objs)==0 then break,end
  end
  
  // Notify by hiliting and message edition
  if ~isempty(DEL) then 
    wins=xget('window')
    // recursively show in graphic window 
    // and hilite the super blocks which lead to 
    // this scs_m 
    if ~isempty(path) then
      mxwin=max(winsid())
      for k=1:size(path,'*')
	hilite_obj(scs_m_s.objs(path(k)))
	scs_m_s=scs_m_s.objs(path(k)).model.rpar;
	scs_m_s=scs_show(scs_m_s,mxwin+k)
      end
    end
    // hilite the blocks which are in DELL and not in 
    // DELL
    F=get_current_figure()
    for k=DEL
      if isempty(find(k==DELL)) then hilite_obj(scs_m_s.objs(k)),end
    end
    message(['Hilited blocks or links are ignored because of'
	     'undefined input(s)'])
    for k=size(path,'*'):-1:1,xdel(mxwin+k),end
    // back to the initial window    
    xset('window',wins)
    // if the blocks were in the already opened window 
    // then unhilite them.
    if isempty(path) then 
      F=get_current_figure()
      for k=DEL
	if isempty(find(k==DELL)) then unhilite_obj(scs_m_s.objs(k)),end
      end
    end
  end
endfunction
