function n=countblocks_old(scs_m)
// count number of blocks used in the scicos data structure scs_m
// Copyright INRIA
  n=0
  for o=scs_m.objs
    if o.type =='Block' then
      if o.model.sim(1).equal['super'] || o.model.sim(1).equal['csuper'] then
	n=n+countblocks(o.model.rpar)
      else
	n=n+1
      end
    else
      n=n+1
    end
  end
endfunction

function n=countblocks(scs_m)
// C-version 
  n=scicos_count_blocks(scs_m);
endfunction

