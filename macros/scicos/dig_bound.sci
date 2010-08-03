function [rect]=dig_bound(scs_m)
// Copyright INRIA
  n=size(scs_m.objs,1); // XXXXX 
  if n < 1 then rect=[];return;end
  vmin=[100000,100000]; 
  vmax=-vmin;
  for i=1:n ; //loop on objects
    o=scs_m.objs(i)
    // otype=o(1)(1,1) 
    if o.type =='Block' | o.type =='Text' then
      orig = o.graphics.orig(:)'; 
      sz=    o.graphics.sz(:)';
      vmin=min(vmin,orig);
      vmax=max(vmax,orig+sz);
    elseif o.type =='Link' then
      xx=o.xx(:);yy=o.yy(:);
      vmin=min([vmin;xx,yy],'r')
      vmax=max([vmax;xx,yy],'r')
    end
  end
  if vmin==[100000,100000] then 
    // note that even if n is non null 
    // the diagram may contain only 
    // Deleted objects. 
    rect=[];
  else
    rect=[vmin,vmax];
  end
endfunction


