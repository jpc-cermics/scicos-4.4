function [ox,oy,w,h,ok]=get_rectangle(xc,yc)
// -----------------------------
// get a rectangle in window curwin 
// note that xset('window',curwin) is supposed 
// to already have been done. 
  rep(3)=-1
  ok=%t
  // record a rectangle 
  F=get_current_figure();
  F.start_compound[];
  xrect(xc,yc,1,1,color=default_color(0),thickness=0);
  C=F.end_compound[];
  R=C.children(1);// a grrect 
  R.invalidate[];
  while rep(3)==-1 do
    F.process_updates[];
    rep=xgetmouse(clearq=%f,cursor=%f,getrelease=%t);
    R.invalidate[];
    R.w=max(0,rep(1) - R.x);
    R.h=max(0,R.y -rep(2));
    R.invalidate[];
  end
  // remove the rectangle.
  ox=R.x;oy=R.y;w=R.w;h=R.h;
  F.remove[C];
  if rep(3)==2 then ok=%f,end
endfunction


