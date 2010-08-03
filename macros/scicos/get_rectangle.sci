function [ox,oy,w,h,ok]=get_rectangle(xc,yc)
  if new_graphics() then 
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
  else
    // -----------------------------
    // Copyright INRIA
    // get a rectangle in window curwin 
    // note that xset('window',curwin) is supposed 
    // to already have been done. 
    pat=xget('pattern')
    xset('pattern',default_color(0))
    xtape_status=xget('recording')  
    // record the objects in graphics 
    [echa,echb,echc,echd]=xgetech();
    xclear(curwin,%t);
    xset("recording",1);
    xsetech(wrect=echa,frect=echb,arect=echd)
    drawobjs(scs_m);
    xset('recording',0);
    
    rep(3)=-1
    ox=xc
    oy=yc
    w=0;h=0
    ok=%t
    first=%t
    pixmap=xget('pixmap')==1
    
    while rep(3)==-1 do
      // redraw the non moving objects with tape_replay
      xset("recording",1);
      xclear(curwin,%f);
      xtape('replay',curwin);
      xset("recording",0);
      // draw moving rectangle 
      xrect(ox,oy,w,h)
      if pixmap then xset('wshow'),end  
      if first then rep=xgetmouse();else rep=xgetmouse(clearq=%f),end
      xc1=rep(1);yc1=rep(2)
      ox=min(xc,xc1)
      oy=max(yc,yc1)
      w=abs(xc-xc1);h=abs(yc-yc1)
      first=%f
    end
    if rep(3)==2 then ok=%f,end
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",xtape_status);
    xset('pattern',pat)
  end
  
endfunction


