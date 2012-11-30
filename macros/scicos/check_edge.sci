function Cmenu=check_edge(o,Cmenu,%pt)
// used to check if we have selected a block or in fact 
// an outputport in a block. If a port was selected then 
// Cmenu="Link" is returned else the argument Cmenu 
// is returned unchanged.
  
  if windows(find(%win==windows(:,2)),1)==100000 then
    return
  end
  if o.type <> "Block" then return;end 
  %xc=%pt(1);
  %yc=%pt(2);
  orig=o.graphics.orig(:)
  sz=o.graphics.sz(:)

  if ~isempty(%pt) then
    xxx = rotate([%pt(1);%pt(2)],...
		 -o.graphics.theta*%pi/180,...
		 [orig(1)+sz(1)/2;orig(2)+sz(2)/2])
    %xc=xxx(1)
    %yc=xxx(2)
  end

  // Link detection in first
  [%xout,%yout,typout]=getoutputports(o)

  if ~isempty(%xout) &&...
     ~(o.gui=="SPLIT_f" || o.gui=="CLKSPLIT_f") then

    [m,kp1]=min((%yc-%yout).^2+(%xc-%xout).^2)
    %xout=%xout(kp1);%yout=%yout(kp1);typout=typout(kp1);

    [x1,y1,sz_x,sz_y]=get_port_bounds(%xout,%yout,o)

    data=[(x1-%xc)*(x1+sz_x-%xc),..
          (y1-sz_y-%yc)*(y1-%yc)]

    if data(1)<0 && data(2)<0 then
      Cmenu='Link';
      return
    end
  end

  // blk detection
  eps_blk=3
  orig=orig-eps_blk
  sz=sz+2*eps_blk
  data=[(orig(1)-%xc)*(orig(1)+sz(1)-%xc),..
        (orig(2)-%yc)*(orig(2)+sz(2)-%yc)]

  if data(1)<0 && data(2)<0 then 
    // we have cliked inside the block so it is probably not a link
    return;
  else
    Cmenu=''
  end
endfunction

//get_port_bounds return area where we
//can select a port to begin a link
//xport,yport : the port location
//o : the blk struct
//x,y,w,h : the rectangle of the area
//          (x,y) upper left point ?
function [x,y,w,h]=get_port_bounds(xport,yport,o)
  w=10;x_eps=3;
  h=10;y_eps=3;

  orig=o.graphics.orig(:)
  sz=o.graphics.sz(:)

  if xport<=orig(1) then
    x=xport
  elseif xport>=orig(1)+sz(1) then
    x=orig(1)+sz(1)-x_eps
    w=w+x_eps
  else
    x=xport-w/2
  end

  if yport<=orig(2) then
    y=orig(2)+y_eps
    h=h+y_eps
  elseif yport>=orig(2)+sz(2) then
    y=orig(2)+sz(2)+y_eps
    h=h+y_eps
  else
    y=yport+h/2
  end
endfunction
