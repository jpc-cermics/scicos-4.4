function [in,out]=get_blocks_in_rect(scs_m,ox,oy,w,h)
// Copyright INRIA
  in=[];out=[]
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block'| o.type =='Text' then
      x=[0 1 1 0]*o.graphics.sz(1)+o.graphics.orig(1)
      y=[0 0 1 1]*o.graphics.sz(2)+o.graphics.orig(2)
      ok=%f
      for kk=1:4
        data=[(ox-x(kk))'*(ox+w-x(kk)),(oy-h-y(kk))'*(oy-y(kk))];
        if data(1)<0&data(2)<0 then ok=%t;in=[in k];break;end
      end
      if ~ok then out=[out k],end
    end
  end
endfunction
