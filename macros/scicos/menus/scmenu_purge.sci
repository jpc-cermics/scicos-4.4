function scmenu_purge()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_purge(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;needcompile=4;
  end
endfunction

function [scs_m_new,changed]=do_purge(scs_m)
// Copyright INRIA
// suppress deleted elements in a scicos data structure
//
  changed = %f;
  nx=length(scs_m.objs);
  //get index of deleted blocks
  deleted=[];
  for k=1:nx
    typ=scs_m.objs(k).type 
    if typ=='Deleted' then
      deleted=[deleted,k];
    elseif typ=='Block' then
      if scs_m.objs(k).model.sim(1)=='super' then
	scs_m.objs(k).model.rpar=do_purge(scs_m.objs(k).model.rpar)
      end
    end
  end
  
  if isempty(deleted) then //nothing has to be done
    scs_m_new=scs_m;
    return
  end

  retained=1:nx;retained(deleted)=[];
  //compute index cross table
  old_to_new=ones_new(1,nx);
  old_to_new(deleted)=0*deleted;
  //No rtitr old_to_new=rtitr(1,%z-1,old_to_new)';
  nres= length(old_to_new);
  res=0*ones_new(nres+1,1);
  for ik=1:nres
    res(ik+1) = res(ik)+ old_to_new(ik);
  end
  old_to_new=res;
  scs_m_new=scicos_diagram();
  scs_m_new.props=scs_m.props
  for k=1:size(retained,'*')
    o=scs_m.objs(retained(k))
    if o.type =='Block' then
      if ~isempty(o.graphics.pin) then
	o.graphics.pin=old_to_new(o.graphics.pin+1);
      end
      if ~isempty(o.graphics.pout) then
	o.graphics.pout=old_to_new(o.graphics.pout+1);
      end
      if ~isempty(o.graphics.pein) then
	o.graphics.pein=old_to_new(o.graphics.pein+1);
      end
      if ~isempty(o.graphics.peout) then
	o.graphics.peout=old_to_new(o.graphics.peout+1);
      end
    elseif o.type =='Link' then
      o.from(1)=old_to_new(o.from(1)+1);
      o.to(1)=old_to_new(o.to(1)+1);
    end
    scs_m_new.objs(k)=o;
  end
  changed = %t;
endfunction
