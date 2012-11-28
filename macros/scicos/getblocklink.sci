function [k,wh]=getblocklink(scs_m,pt)
// Copyright INRIA
  n=length(scs_m.objs)
  wh=[];
  data=[]
  k=[]
  eps=6
  for i=1:n ; //loop on objects
    x=pt(1);y=pt(2)
    o=scs_m.objs(i)
    if o.type =='Block' then
      [orig,sz]=(o.graphics.orig,o.graphics.sz)
      xxx = rotate([x;y],...
                    -o.graphics.theta*%pi/180,...
                   [orig(1)+sz(1)/2;orig(2)+sz(2)/2])
      x=xxx(1)
      y=xxx(2)
      orig=orig-eps;sz=sz+2*eps;
      data=[(orig(1)-x)*(orig(1)+sz(1)-x),(orig(2)-y)*(orig(2)+sz(2)-y)]
      if data(1)<0&data(2)<0 then k=i,break,end
    elseif o.type =='Link' then
      xx=o.xx;yy=o.yy;
      [d,ptp,ind]=dist2polyline(xx,yy,pt)
      if d<eps then k=i,wh=ind,break,end
    end
  end
endfunction
