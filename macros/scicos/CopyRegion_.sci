function CopyRegion_()
  Cmenu='Open/Set'
  xinfo('Copy Region: Click, drag region, click (left to fix, right to cancel)')
  if new_graphics() then 
    [scs_m,needcompile]=do_copy_region_new(scs_m,needcompile);
  else
    [scs_m,needcompile]=do_copy_region(scs_m,needcompile);
  end
  xinfo(' ')
endfunction

function [scs_m,needcompile]=do_copy_region(scs_m,needcompile)
  [btn,%pt,win,Cmenu]=cosclick()
  if Cmenu<>"" then
    resume(Cmenu)
    return;
  end
  xc=%pt(1);yc=%pt(2);
  // get region to copy 
  [reg,rect]=get_region(xc,yc,win)
  // Copyright INRIA
  if isempty(rect) then return,end

  modified=length(reg)>1
  xinfo('Drag to destination position and click (left to fix, right to cancel)')
  rep(3)=-1
  yc=yc-rect(4)  
  
  thick=xget('thickness');
  col=default_color(0);
  // record the objects in graphics 
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",1);
  xsetech(echa,echb);
  drawobjs(scs_m);
  xset('recording',0);
  //move loop
  while rep(3)==-1 then 
    // redraw the non moving objects with tape_replay
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",0);
    // draw moving rectangle 
    xrect(xc,yc+rect(4),rect(3),rect(4),color=col,thickness=thick+1);
    if pixmap then xset('wshow'),end
    // get new position
    rep=xgetmouse()
    xc=rep(1)-rect(3);
    yc=rep(2);
    xy=[xc,yc];
  end

  xset("recording",xtape_status);
  if rep(3)==2 then return,end

  scs_m_save=scs_m,nc_save=needcompile
  n=length(scs_m.objs)
  for k=1:size(reg.objs)
    o=reg.objs(k)
    // translate blocks and update connection index 
    if o.type =='Link' then
      o.xx=o.xx-rect(1)+xc
      o.yy=o.yy-rect(2)+yc
      [from,to]=(o.from,o.to)
      o.from(1)=o.from(1)+n;
      o.to(1)=o.to(1)+n;
    elseif o.type =='Block' then
      o.graphics.orig(1)=o.graphics.orig(1)-rect(1)+xc
      o.graphics.orig(2)=o.graphics.orig(2)-rect(2)+yc
      k_conn=find(o.graphics.pin>0)
      o.graphics.pin(k_conn)=o.graphics.pin(k_conn)+n
      k_conn=find(o.graphics.pout>0)
      o.graphics.pout(k_conn)=o.graphics.pout(k_conn)+n
      k_conn=find(o.graphics.pein>0)
      o.graphics.pein(k_conn)=o.graphics.pein(k_conn)+n
      k_conn=find(o.graphics.peout>0)
      o.graphics.peout(k_conn)=o.graphics.peout(k_conn)+n
    elseif o.type =='Text' then
      o.graphics.orig(1)=o.graphics.orig(1)-rect(1)+xc
      o.graphics.orig(2)=o.graphics.orig(2)-rect(2)+yc
    end
    scs_m.objs($+1)=o
    // drawobj(o)
  end
  
  // redraw 
  xtape_status=xget('recording')
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",1);
  xsetech(echa,echb);
  drawobjs(scs_m);
  xset('recording',xtape_status);
  
  if modified then 
    needcompile=4
    resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
    return;
  end
endfunction


function [scs_m,needcompile]=do_copy_region_new(scs_m,needcompile)
  [btn,%pt,win,Cmenu]=cosclick()
  if Cmenu<>"" then
    resume(Cmenu)
    return;
  end
  xc=%pt(1);yc=%pt(2);
  // get region to copy 
  [reg,rect]=get_region(xc,yc,win)
  // Copyright INRIA
  if isempty(rect) then return,end

  modified=length(reg)>1
  xinfo('Drag to destination position and click (left to fix, right to cancel)')
  rep(3)=-1
  yc=yc-rect(4)  
  
  thick=xget('thickness');
  col=default_color(0);
  // put the moving rectangle in the figure 
  F=get_current_figure();
  F.start_compound[];
  xrect(xc,yc+rect(4),rect(3),rect(4),color=col,thickness=0);
  C=F.end_compound[];
  R=C.children(1);
  xcursor(52);
  //move loop
  while rep(3)==-1 then 
    // redraw the non moving objects with tape_replay
    F.process_updates[];
    // get new position
    rep=xgetmouse(cursor=%f,getrelease=%t)
    xc=rep(1)-rect(3);
    yc=rep(2);
    R.invalidate[];
    R.x=xc;R.y=yc+rect(4);
    R.invalidate[];
  end
  xcursor();
  F.remove[C];
  F.draw_now[];
  if rep(3)==2 then return,end
  scs_m_save=scs_m,nc_save=needcompile
  n=length(scs_m.objs)
  for k=1:size(reg.objs)
    o=reg.objs(k)
    // translate blocks and update connection index 
    if o.type =='Link' then
      o.xx=o.xx-rect(1)+xc
      o.yy=o.yy-rect(2)+yc
      [from,to]=(o.from,o.to)
      o.from(1)=o.from(1)+n;
      o.to(1)=o.to(1)+n;
    elseif o.type =='Block' then
      o.graphics.orig(1)=o.graphics.orig(1)-rect(1)+xc
      o.graphics.orig(2)=o.graphics.orig(2)-rect(2)+yc
      k_conn=find(o.graphics.pin>0)
      o.graphics.pin(k_conn)=o.graphics.pin(k_conn)+n
      k_conn=find(o.graphics.pout>0)
      o.graphics.pout(k_conn)=o.graphics.pout(k_conn)+n
      k_conn=find(o.graphics.pein>0)
      o.graphics.pein(k_conn)=o.graphics.pein(k_conn)+n
      k_conn=find(o.graphics.peout>0)
      o.graphics.peout(k_conn)=o.graphics.peout(k_conn)+n
    elseif o.type =='Text' then
      o.graphics.orig(1)=o.graphics.orig(1)-rect(1)+xc
      o.graphics.orig(2)=o.graphics.orig(2)-rect(2)+yc
    end
    // record draw 
    if o.iskey['gr'] then  o.delete['gr'];end 
    F.start_compound[];
    drawobj(o);
    o.gr =F.end_compound[];
    scs_m.objs($+1)=o;
    o.gr.invalidate[];
  end
  
  // redraw 
    
  if modified then 
    needcompile=4
    resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
    return;
  end
endfunction


