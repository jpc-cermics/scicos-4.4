function connected=get_connected(scs_m,k,typ='')
//return the vector of number of link connected to a given block
//   scs_m      :   structure of blocks and links
//   k          :   block_number
//   typ        :   'in','out','clkin','clkout'
//   connected  :   vector of connected link numbers
// Copyright INRIA
  connected=[]
  graphics=scs_m.objs(k).graphics
  if typ=='' then typ=['in','out','clkin','clkout'];end 
  // XXX for x=typ  typ(i) au lieu de typ(1,i) 
  for i=1:size(typ,'*')
    if typ(1,i)=='in' then 
      ip=graphics.pin
      connected=[connected,ip(find(ip>0))'],
    elseif typ(1,i)=='out' then 
      op=graphics.pout
      connected=[connected,op(find(op>0))'],
    elseif typ(1,i)=='clkin' then 
      cip=graphics.pein
      connected=[connected,cip(find(cip>0))'],
    elseif typ(1,i)=='clkout' then 
      cop=graphics.peout
      connected=[connected,cop(find(cop>0))'],
    end
  end
endfunction
