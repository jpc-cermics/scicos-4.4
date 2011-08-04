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
  eps=sz/5
  orig=orig+eps
  sz=sz-2*eps
  if ~isempty(%pt) then
    xxx = rotate([%pt(1);%pt(2)],...
		 -o.graphics.theta*%pi/180,...
		 [orig(1)+sz(1)/2;orig(2)+sz(2)/2])
    %xc=xxx(1)
    %yc=xxx(2)
  end
  data=[(orig(1)-%xc)*(orig(1)+sz(1)-%xc),..
	(orig(2)-%yc)*(orig(2)+sz(2)-%yc)]
  if data(1)<0 && data(2)<0 then 
    // we have cliked inside the block so it is probably not a link
    return;
  end 
  [%xout,%yout,typout]=getoutputports(o)
  if ~isempty(%xout) && ~(o.gui=="SPLIT_f" || o.gui=="CLKSPLIT_f") then
    %xxyymax=o.graphics.orig(:)+o.graphics.sz(:)
    %xout=max(min(%xout,%xxyymax(1)),o.graphics.orig(1))
    %yout=max(min(%yout,%xxyymax(2)),o.graphics.orig(2))
    %center=orig+sz/2
    if or((%xc-%xout).^2+(%yc-%yout).^2 <(%xc-%center(1)).^2+...
	  (%yc-%center(2)).^2) then
      Cmenu='Link';
    end
  end
endfunction
