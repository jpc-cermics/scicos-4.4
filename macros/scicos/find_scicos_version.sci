function [scicos_ver]=find_scicos_version(scs_m)
// Copyright INRIA
// find_scicos_version tries to retrieve a scicos
// version number in a scs_m structure.
// 21/08/07: Alan, inital revision
// 
  
  if ~exists('scicos_ver') then
    scicos_ver = "scicos2.2";
  else
    scicos_ver = scicos_ver;
  end
  
  if scs_m.iskey['version'] then
    if scs_m.version<>'' then
      // version is stored in the structure.
      scicos_ver=scs_m.version
      return;
    end
    n=size(scs_m.objs);
    for j=1:n //loop on objects
      o=scs_m.objs(j);
      if o.type =='Block' then
	if o.model.iskey['equations'] then
	  scicos_ver = "scicos2.7.3"
	  break;
	else
	  // the last version supported here is scicos2.7
	  // other tests can be done
	  scicos_ver = "scicos2.7"
	  break;
	end
      end
    end //** end for
  end
endfunction
