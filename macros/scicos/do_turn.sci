function [scs_m]=do_turn(%pt,scs_m,theta)
  //** get the current win ID
  win=%win;

  //** get the mouse coord.
  xc=%pt(1);
  yc=%pt(2);

  //**--------- check Select ------------------
  SelectSize=size(Select);
  SelectSize=SelectSize(1);

  if SelectSize<>0 then
    if SelectSize==1 & Select(1,2)==%win then
      k=Select(1,1)
    elseif SelectSize>1 then
      if find(Select(:,2)==%win)<>[] then
        //scs_m=do_multiturn(scs_m,win)
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
  if isempty(k) then
    return
  end //** if you click in the void ... return back

  scs_m_save=scs_m
  path=list('objs',k)
  o=scs_m.objs(k)

  if o.type=='Link' then
    return
  end //**disable rotation for link

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
