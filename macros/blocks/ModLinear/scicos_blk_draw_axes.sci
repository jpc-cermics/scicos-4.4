
function scicos_blk_draw_axes(sz,orig,orient,ipos=2,jpos=2,acol=9,fcol=13)
// make an icon by drawing a curve with axes 
// -----------------------------------------
  xf=60;yf=40;
  xof=xf/10;yof=yf/7;
  xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=fcol);
  // a vertical axis 
  xpos=orig(1)+[xof,sz(1)/2,sz(1)-xof]
  // dir=0,1,2,3, typ=[0,1]
  if ~orient then iposr=[3,2,1]; ipos =iposr(ipos);end 
  scicos_lock_draw([xpos(ipos),orig(2)+sz(2)-yof],xf/2,yf/2,0,1,color=acol);
  xsegs([xpos(ipos),xpos(ipos)],[orig(2)+yof,orig(2)+sz(2)-yof],style=acol);
  // an horizontal axis 
  ypos=orig(2)+[yof,sz(2)/2,sz(2)-yof]
  if orient then 
    xt=orig(1)+sz(1)-xof;dir=2;
  else
    xt=orig(1)+xof;dir=3;
  end
  // dir=0,1,2,3, typ=[0,1]
  scicos_lock_draw([xt,ypos(jpos)],xf/2,yf/2,dir,1,color=acol);
  xsegs([orig(1)+xof,orig(1)+sz(1)-xof],[ypos(jpos),ypos(jpos)],style=acol);
endfunction

function scicos_blk_draw_curv(x=linspace(-%pi,%pi,20),y=x,color=5)
// a curve 
  xf=60;yf=40;
  xof=xf/10;yof=yf/7;
  y1= orig(2)+yof + (sz(2)-2*yof)*(y-min(y))/(max(y)-min(y));
  x1= orig(1)+xof + (x-min(x))*(sz(1)-2*xof)/(max(x)-min(x));
  if ~orient then x1=x1($:-1:1);end
  xpoly(x1,y1,color=color);
endfunction


