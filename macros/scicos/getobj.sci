function [k,wh]=getobj(scs_m,pt)
 eps=6
 k=[]
 wh=[]
 data=[]
 n=length(scs_m.objs)
 x=pt(1);y=pt(2);
 for i=n:-1:1
   o=scs_m.objs(i)
   if o.type=="Block" then
     [orig,sz]=(o.graphics.orig, o.graphics.sz);
     sz=sz+2*eps;
     orig=orig-eps;
     if ~isempty(pt) then
       xxx=rotate([pt(1);pt(2)],..
                  -o.graphics.theta * %pi/180,...
                  [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
         x=xxx(1);
         y=xxx(2);
     end
     data=[(orig(1)-x)*(orig(1)+sz(1)-x),..
           (orig(2)-y)*(orig(2)+sz(2)-y)]
     if data(1)<0 & data(2)<0 then
       k=i;
       return;
     end
   end
 end

 for i=n:-1:1
   o=scs_m.objs(i);
   select o.type
      case "Text" then
      //TODO
//       [orig,sz]=(o.graphics.orig,o.graphics.sz)
//       rect = stringbox(tomultline(o.graphics.exprs(1)), orig(1), orig(2), 0, o.model.ipar(1),o.model.ipar(2))
//       xstr=rect(1,1);
//       ystr=rect(2,1);
//       wstr=rect(1,3)-rect(1,2);
//       hstr=rect(2,2)-rect(2,4);
//       orig(1)=xstr
//       orig(2)=ystr
//       sz(1)=wstr*%zoom
//       sz(2)=hstr*%zoom
//       if ~isempty(pt) then
//         xxx=rotate([pt(1);pt(2)],...
//                    -o.graphics.theta*%pi/180,...
//                    [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
//         x=xxx(1);
//         y=xxx(2);
//       end
//       data=[(orig(1)-x)*(orig(1)+sz(1)-x),..
//             (orig(2)-y)*(orig(2)+sz(2)-y)]
//       if data(1)<0 & data(2)<0 then
//         k=i;
//         return;
//       end
     case "Link" then
       xx=o.xx;
       yy=o.yy;
       [d,ptp,ind]=dist2polyline(xx,yy,pt);
       if d<eps/2 then
         k=i;wh=ind;
         return 
       end
   end
 end
endfunction
