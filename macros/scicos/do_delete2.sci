function [scs_m,DEL]=do_delete2(scs_m,K,gr)
//perform deletion of scs_m object whose index are given in the vector 
//K and all connected links. splits which are not given in K are not deleted
//!
// Copyright INRIA
scs_m=scs_m
DEL=[] //table of deleted objects
K0=K
while ~isempty(K) do
  k=K(1);K(1)=[]
  o=scs_m.objs(k);
  if isempty(find(DEL==k)) then typ=o.type;else typ='Deleted',end

  DEL=[DEL k]

  if typ=='Link' then
    [ct,from,to]=(o.ct,o.from,o.to)
    tokill=[%t,%t]
    if ct(2)<>2 then
      //disconnect to block
      scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'in',ct(2),0)
      //disconnect from block
      scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'out',ct(2),0)
    else
      if or(scs_m.objs(to(1)).graphics.pin==k) then
	scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'in',ct(2),0)
      else
	scs_m.objs(to(1))=mark_prt(scs_m.objs(to(1)),to(2),'out',ct(2),0)
      end
       if or(scs_m.objs(from(1)).graphics.pin==k) then
	 scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'in',ct(2),0)
       else
	 scs_m.objs(from(1))=mark_prt(scs_m.objs(from(1)),from(2),'out',ct(2),0)
       end
    end
  elseif typ=='Block' then
    // get connected links
    connected=get_connected(scs_m,k)
    //ask for connected links deletion
    K=[K connected]
  elseif typ=='Text' then
  elseif typ=='Deleted' then
  else
    message('This object can''t be deleted')
  end
end

if gr then
  F=get_current_figure();
  F.draw_latter[];
  for k=DEL
    if scs_m.objs(k).iskey['gr'] then
      F.remove[scs_m.objs(k).gr];
    end
    scs_m.objs(k)=mlist('Deleted')
  end
else
  for k=DEL
    scs_m.objs(k)=mlist('Deleted')
  end
end

endfunction
