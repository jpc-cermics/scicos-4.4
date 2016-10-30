function [scs_m]=do_turn(%pt,scs_m,theta)
// turn selected object by theta angle 
//** get the mouse coord.
  if ~isempty(%pt) then 
    xc=%pt(1);
    yc=%pt(2);
  end
    
  //**--------- check Select ------------------
  SelectSize=size(Select);
  SelectSize=SelectSize(1);

  if SelectSize<>0 then
    if SelectSize==1 & Select(1,2)==%win then
      k=Select(1,1)
    elseif SelectSize>1 then
      if ~isempty(find(Select(:,2)==%win)) then
        k=getobj(scs_m,[xc;yc]);
      else
        k=getobj(scs_m,[xc;yc]);
      end
    else
      k=getobj(scs_m,[xc;yc]);
    end
  else
    k=getobj(scs_m,[xc;yc]);
  end

  //**--------- check k and scs_m.objs(k) ------------------

  // if you click in the void ... return back
  if isempty(k) then return;end;
  scs_m_save=scs_m
  path=list('objs',k)
  o=scs_m.objs(k)

  //**disable rotation for link
  if o.type=='Link' then return;end;
  
  //**--------- scs_m theta update -------------------------
  geom=o.graphics
  geom.theta=geom.theta + theta
  //** angle normalization 
  while geom.theta>=360 then
    geom.theta=geom.theta-360;
  end
  while geom.theta<=-360 then
    geom.theta=geom.theta+360;
  end
  
  //** 
  o.graphics=geom
  scs_m.objs(k)=o 
  o_n=o
  scs_m=changeports(scs_m,path,o_n)
  resume(scs_m_save,enable_undo=%t,edited=%t)
endfunction
