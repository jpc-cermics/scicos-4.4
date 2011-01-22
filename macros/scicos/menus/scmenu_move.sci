function Move_()
  Cmenu=''
  [%pt,scs_m]=do_stupidmove(%pt,scs_m)
  %pt=[]
endfunction

function [%pt,scs_m]=do_stupidmove(%pt,scs_m)
// Copyright INRIA
// get a scicos object to move, and move it with connected objects
// or quit if a menu is selected
  rela=.1
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn);
	return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[]
    if new_graphics() then 
      [k,wh,scs_m]=stupid_getobj_new(scs_m,[xc;yc])
    else
      [k,wh,scs_m]=stupid_getobj(scs_m,[xc;yc])
    end
    if ~isempty(k) then break,end
  end
  scs_m_save=scs_m
  //printf("In move \n");
  xcursor(52);
  if scs_m.objs(k).type =='Block'| scs_m.objs(k).type =='Text' then
    needreplay=replayifnecessary()
    if new_graphics() then
      scs_m=stupid_moveblock_new(scs_m,k,xc,yc)
    else 
      scs_m=stupid_moveblock(scs_m,k,xc,yc)
      xcursor();
    end
  elseif scs_m.objs(k).type == 'Link' then
    if new_graphics() then 
      scs_m=stupid_movecorner_new(scs_m,k,xc,yc,wh)
      xcursor();
    else
      scs_m=stupid_movecorner(scs_m,k,xc,yc,wh)
      xcursor();
    end
  end
  resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
endfunction

function scs_m=stupid_moveblock(scs_m,k,xc,yc)
// Move  block k and modify connected links if any
// look at connected links
  xtape_status=xget('recording')

  connected=unique(get_connected(scs_m,k))
  o=scs_m.objs(k)

  // build movable segments for all connected links
  //===============================================
  xm=[];ym=[];clr=[];
  mx=list();my=list();rlc=list();
  for l=1:length(connected)
    i=connected(l);
    oi=scs_m.objs(i);
    [xl,yl,ct,from,to]=(oi.xx,oi.yy,oi.ct,oi.from,oi.to);
    if from(1)==k then
      xm=[xm,[xl(2);xl(1)]];
      ym=[ym,[yl(2);yl(1)]];
      clr=[clr ct(1)];
      if size(xl,1)>2 then
        mx($+1)=xl(2:$);
        my($+1)=yl(2:$);
        rlc($+1)=ct(1);
      end
    end
    if to(1)==k then
      xm=[xm,xl($-1:$)];
      ym=[ym,yl($-1:$)];
      clr=[clr ct(1)];
      if size(xl,1)>2 then
        mx($+1)=xl(1:$-1);
        my($+1)=yl(1:$-1);
        rlc($+1)=ct(1);
      end
    end
  end
  xmt=xm;
  ymt=ym;

  // draw all the non moving objects
  // kept in recorded states for subsequent redraws.
  //===============================================
  others=1:length(scs_m.objs);
  others([k,connected])=[];
  // redraw others and record them
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",1);
  xsetech(echa,echb);
  for i=others
    drawobj(scs_m.objs(i))
  end
  for i=1:size(mx)
    xpolys(mx(i),my(i),rlc(i));
  end
  drawtitle(scs_m.props)
  show_info(scs_m.props.doc)
  xset('recording',0);

  // move a block and connected links
  //=================================
  [xmin,ymin]=getorigin(o);
  xco=xc;yco=yc;
  rep(3)=-1;
  [xy,sz]=(o.graphics.orig,o.graphics.sz);
  dx=xc-xmin;dy=yc-ymin;
  while rep(3)==-1 ,  // move loop
    // redraw the non moving objects.
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",0);
    // draw block shape
    xrect(xc-dx,yc+sz(2)-dy,sz(1),sz(2));
    // draw moving links
    if ~isempty(connected) then
      xpolys(xmt,ymt,clr);
    end
    if pixmap then xset('wshow'),end
    // get new position
    rep=xgetmouse(clearq=%f);
    xc=rep(1);yc=rep(2);
    if ~isempty(connected) then
      xmt(2,:)=xm(2,:)-xco+xc;
      ymt(2,:)=ym(2,:)-yco+yc;
    end
  end
  
  // update and draw block and connected links
  if rep(3)<>2 then
    // updates
    xy=[xc-dx,yc-dy];
    o.graphics.orig=xy;
    scs_m.objs(k)=o;
    j=0;
    for l=1:length(connected)
      i=connected(l);
      oi=scs_m.objs(i);
      [xl,from,to]=(oi.xx,oi.from,oi.to);
      if from(1)==k then
        j=j+1
        oi.xx(1:2)=xmt([2,1],j)
        oi.yy(1:2)=ymt([2,1],j)
      end
      if to(1)==k then
         j=j+1
         oi.xx($-1:$)=xmt(:,j)
         oi.yy($-1:$)=ymt(:,j)
      end
      scs_m.objs(i)=oi
    end
  end

  // now redraw
  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  drawobj(o);
  for l=1:length(connected)
    i=connected(l);
    drawobj(scs_m.objs(i));
  end
  if pixmap then xset('wshow'),end
  xset("recording",xtape_status);
endfunction

function scs_m=stupid_moveblock_new(scs_m,k,xc,yc)
// new graphics version.
// Move  block k and modify connected links if any
// look at connected links

  connected=unique(get_connected(scs_m,k))
  o=scs_m.objs(k)

  // collect movable segments for all connected links
  //===============================================
  scs_m_d=list();
  for i=connected
    scs_m_d.add_last[scs_m.objs(i).gr.children(1)];
  end

  // move a block and connected links
  //=================================
  pto=[xc,yc];
  pt = pto;
  F=get_current_figure()
  while %t 
    // the while loop must be stopped by a button release 
    // (due to the way we enter this while 
    // the mouse can be in a pressed state or not 
    // during the move. Thus, to quit in a coherent 
    // state we only accept to quit on a mouse release).
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    pt = rep(1:2);
    tr= pt - pto;
    // translate moving object 
    o.gr.translate[tr];
    // draw moving links
    for l=1:length(connected)
      i=connected(l);
      P=scs_m_d(l);
      oi=scs_m.objs(i);
      [xl,yl,ct,from,to]=(oi.xx,oi.yy,oi.ct,oi.from,oi.to);
      if from(1)==k then
        P.x(1)= P.x(1) + tr(1);
        P.y(1)= P.y(1) + tr(2);
      end
      if to(1)==k then
        P.x($)= P.x($) + tr(1);
        P.y($)= P.y($) + tr(2);
      end
      P.invalidate[];
    end
    pto=pt;
    // XXX this should be more <<hardcoded>>
    // printf("while event was %f\n",rep(3));
    if ~isempty(find(rep(3)==[-5,-4,-3])) then break;end 
  end
  xcursor();
  // update the block structure and connected links
  // if the release was a right button release this is 
  // a cancel
  if rep(3)<>-3 then
    // updates
    o.graphics.orig.redim[1,-1]; // be sure that we are a row
    o.graphics.orig= o.graphics.orig + pt - [xc,yc];
    for i=connected
      scs_m.objs(i).xx = scs_m.objs(i).gr.children(1).x(:);
      scs_m.objs(i).yy = scs_m.objs(i).gr.children(1).y(:);
    end
  end

  //redraw block
  o_n=scs_m.objs(k);
  o.graphics.orig.redim[1,-1]; // be sure that we are a row
  o_n.graphics.orig.redim[1,-1]; // be sure that we are a row
  tr=o.graphics.orig-o_n.graphics.orig-(pt-[xc,yc])
  o.gr.translate[tr];
  scs_m.objs(k)=o;
  //redraw link
  for i=connected
    scs_m.objs(i).gr.children(1).x = scs_m.objs(i).xx(:);
    scs_m.objs(i).gr.children(1).y = scs_m.objs(i).yy(:);
    scs_m.objs(i).gr.invalidate[];
  end
endfunction

function scs_m=stupid_movecorner(scs_m,k,xc,yc,wh)
  o=scs_m.objs(k)
  [xx,yy,ct]=(o.xx,o.yy,o.ct)
  seg=[-wh-1:-wh+1]
  // draw the rest of objects
  others=1:length(scs_m.objs);
  others([k])=[]
  // redraw others and record them
  [echa,echb]=xgetech();
  xclear(curwin,%t);
  xset("recording",1);
  xsetech(echa,echb);
  for i=others
    drawobj(scs_m.objs(i))
  end
  drawtitle(scs_m.props)
  show_info(scs_m.props.doc)
  xset('recording',0);

  rep(3)=-1
  while rep(3)==-1 do
    // redraw the non moving objects.
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",0);
    // xpolys(x1,y1,ct(1))//draw moving part of the link
    xpolys(xx,yy,ct(1));
    rep=xgetmouse(clearq=%f);
    if pixmap then xset('wshow'),end
    xc1=rep(1);yc1=rep(2)
    xx(seg(2))=xc1;//xx(seg(2))-(xc-xc1)
    yy(seg(2))=yc1;//yy(seg(2))-(yc-yc1)
  end
  // update
  x1=xx(seg);y1=yy(seg);
  if rep(3)<>2 then
    if abs(x1(1)-x1(2))<rela*abs(y1(1)-y1(2)) then
      x1(2)=x1(1)
    elseif abs(x1(2)-x1(3))<rela*abs(y1(2)-y1(3))then
      x1(2)=x1(3)
    end  
    if abs(y1(1)-y1(2))<rela*abs(x1(1)-x1(2)) then
      y1(2)=y1(1)
    elseif abs(y1(2)-y1(3))<rela*abs(x1(2)-x1(3)) then
      y1(2)=y1(3)
    end  
    d=projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)])
    if norm(d(:)-[x1(2);y1(2)])<
      rela*max(norm(d(:)-[x1(3);y1(3)]),norm(d(:)-[x1(1);y1(1)])) then
      xx(seg)=x1
      yy(seg)=y1
      xx(seg(2))=[]
      yy(seg(2))=[]
      x1(2)=[];y1(2)=[];seg(3)=[]
    else
      xx(seg)=x1
      yy(seg)=y1
    end
    o.xx=xx;o.yy=yy
    scs_m.objs(k)=o
  end
  // redraw 
  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  drawobj(o);
  xset("recording",0);
  if pixmap then xset('wshow'),end
  xset("recording",xtape_status);
endfunction

function scicos_smooth_corner(P,seg)
  x1=P.x(seg);y1=P.y(seg);
  if abs(x1(1)-x1(2)) < rela*abs(y1(1)-y1(2)) then
    x1(2)=x1(1)
  elseif abs(x1(2)-x1(3))<rela*abs(y1(2)-y1(3))then
    x1(2)=x1(3)
  end  
  if abs(y1(1)-y1(2))<rela*abs(x1(1)-x1(2)) then
    y1(2)=y1(1)
  elseif abs(y1(2)-y1(3))<rela*abs(x1(2)-x1(3)) then
    y1(2)=y1(3)
  end
  P.x(seg(2))=x1(2);
  P.y(seg(2))=y1(2);
endfunction

function scs_m=stupid_movecorner_new(scs_m,k,xc,yc,wh)
// move a point in a link in new_graphics 
  o=scs_m.objs(k);
  // indice of the moving point
  if wh > 0 then 
    return; 
  end
  // move only one point  -wh 
  wh = - wh;
  // the moving polygon 
  P=o.gr.children(1);
  pto=[xc,yc]; // old point 
  rep(3)=-1
  while rep(3)==-1 do
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==3 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    pt = rep(1:2);
    tr= pt - pto;
    pto=pt;
    // move the point which changes 
    F=get_current_figure()
    F.draw_latter[];
    P.x(wh)= P.x(wh) + tr(1);
    P.y(wh)= P.y(wh) + tr(2);
    // scicos_smooth_corner(P,seg);
    F.draw_now[];
    // redraw the non moving objects.
  end
  
  if rep(3)==2 then
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_latter[];
    P.x=o.xx; P.y=o.yy;
    F.draw_now[];
    return;
  end
  
  // update
  // smooth the final point
  if %f then 
    x1=P.x(seg);y1=P.y(seg);
    if rep(3)<>2 then
      if abs(x1(1)-x1(2))<rela*abs(y1(1)-y1(2)) then
	x1(2)=x1(1)
      elseif abs(x1(2)-x1(3))<rela*abs(y1(2)-y1(3))then
	x1(2)=x1(3)
      end  
      if abs(y1(1)-y1(2))<rela*abs(x1(1)-x1(2)) then
	y1(2)=y1(1)
      elseif abs(y1(2)-y1(3))<rela*abs(x1(2)-x1(3)) then
	y1(2)=y1(3)
      end  
      d=projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)])
      if norm(d(:)-[x1(2);y1(2)])<
	rela*max(norm(d(:)-[x1(3);y1(3)]),norm(d(:)-[x1(1);y1(1)])) then
	P.x(seg)=x1;
	P.y(seg)=y1;
	P.x(seg(2))=[];
	P.y(seg(2))=[];
	x1(2)=[];y1(2)=[];seg(3)=[];
      else
	P.x(seg)=x1;
	P.y(seg)=y1;
      end
      scs_m.objs(k).xx = P.x(:);
      scs_m.objs(k).yy = P.y(:);
    end
  end
  
  o.xx = o.gr.children(1).x;
  o.yy = o.gr.children(1).y;
  scs_m.objs(k) = o;
endfunction

function [k,wh,scs_m]=stupid_getobj(scs_m,pt)
  n=length(scs_m.objs)
  wh=[];
  x=pt(1);y=pt(2)
  data=[]
  k=[]
  for i=1:n ; //loop on objects
    o=scs_m.objs(i)
    if o.type =='Block' then
      graphics=o.graphics
      [orig,sz]=(graphics.orig,graphics.sz)
      data=[(orig(1)-x)*(orig(1)+sz(1)-x),(orig(2)-y)*(orig(2)+sz(2)-y)]
      if data(1)<0&data(2)<0 then k=i,break,end
    elseif o.type =='Link' then
      [frect1,frect]=xgetech();
      eps=4     
      xx=o.xx;yy=o.yy;
      [d,ptp,ind]=stupid_dist2polyline(xx,yy,pt,.85)
      if d<eps then 
	if ind==-1 then 
	  k=o.from(1),break,
	elseif ind==-size(xx,1) then 
	  k=o.to(1),break,
	elseif ind>0 then 
          draw_link_seg(o,[ind,ind+1])
          o.xx=[xx(1:ind);ptp(1);xx(ind+1:$)];
	  o.yy=[yy(1:ind);ptp(2);yy(ind+1:$)];
          scs_m.objs(i)=o
	  k=i,wh=-ind-1,break,
	else k=i,wh=ind,draw_link_seg(o,[-ind-1:-ind+1]);break,end
      end
    elseif o.type =='Text' then
      graphics=o.graphics
      [orig,sz]=(graphics.orig,graphics.sz)
      data=[(orig(1)-x)*(orig(1)+sz(1)-x),(orig(2)-y)*(orig(2)+sz(2)-y)]
      if data(1)<0&data(2)<0 then k=i,break,end
    end
  end
endfunction

function [k,wh,scs_m]=stupid_getobj_new(scs_m,pt)
// select object for new_graphics 
// we keep here the sign of wh
  n=length(scs_m.objs)
  wh=[];
  x=pt(1);y=pt(2)
  data=[]
  k=[]
  for i=1:n ; //loop on objects
    o=scs_m.objs(i)
    if o.type =='Block' then
      graphics=o.graphics
      [orig,sz]=(graphics.orig,graphics.sz)
      data=[(orig(1)-x)*(orig(1)+sz(1)-x),(orig(2)-y)*(orig(2)+sz(2)-y)]
      if data(1)<0&data(2)<0 then k=i,break,end
    elseif o.type =='Link' then
      [frect1,frect]=xgetech();
      eps=4     
      xx=o.xx;yy=o.yy;
      [d,ptp,ind]=dist2polyline(xx,yy,pt);
      wh=ind;
      if d < eps then 
	if ind==-1 then 
	  k=o.from(1)
	  break,
	elseif ind==-size(xx,1) then 
	  k=o.to(1),break,
	elseif ind>0 then 
          //draw_link_seg(o,[ind,ind+1])
	  d1=norm([xx(ind)-ptp(1),yy(ind)-ptp(2)]);
	  d2=norm([xx(ind+1)-ptp(1),yy(ind+1)-ptp(2)]);
	  if d1 < eps then
	    k=i;
	    wh= - ind;
	  elseif  d2 < eps   then 
	    k=i;
	    wh= -(ind+1);
	  else
	    o.xx=[xx(1:ind);ptp(1);xx(ind+1:$)];
	    o.yy=[yy(1:ind);ptp(2);yy(ind+1:$)];
	    P=o.gr.children(1);
	    P.x=o.xx;
	    P.y=o.yy;
	    k=i,
	    scs_m.objs(i)=o;
	    wh= -(ind+1);
	    // wehave added a point which is to be moved.
	  end
	  break;
	else 
	  //printf("a corner \n");
	  k=i,
	  break,
	end
      end
    elseif o.type =='Text' then
      graphics=o.graphics
      [orig,sz]=(graphics.orig,graphics.sz)
      data=[(orig(1)-x)*(orig(1)+sz(1)-x),(orig(2)-y)*(orig(2)+sz(2)-y)]
      if data(1)<0&data(2)<0 then k=i,break,end
    end
  end
endfunction

function [d,pt,ind]=stupid_dist2polyline(xp,yp,pt,pereps)
// computes minmum distance from a point to a polyline
// d    minimum distance to polyline
// pt   coordinate of the polyline closest point
// ind  
//     if negative polyline closest point is a polyline corner:
//        pt=[xp(-ind) yp(-ind)]
//     if positive pt lies on segment [ind ind+1]

  x=pt(1)
  y=pt(2)

  xp=xp(:);yp=yp(:)
  if ~isempty(%pt) then
    cr=4*sign((xp(1:$-1)-x).*(xp(1:$-1)-xp(2:$))+...
       (yp(1:$-1)-y).*(yp(1:$-1)-yp(2:$)))+...
       sign((xp(2:$)-x).*(xp(2:$)-xp(1:$-1))+...
       (yp(2:$)-y).*(yp(2:$)-yp(1:$-1)))
  else
    cr=4*sign((xp(1:$-1)).*(xp(1:$-1)-xp(2:$))+...
       (yp(1:$-1)).*(yp(1:$-1)-yp(2:$)))+...
       sign((xp(2:$)).*(xp(2:$)-xp(1:$-1))+...
       (yp(2:$)).*(yp(2:$)-yp(1:$-1)))
  end

  ki=find(cr==5) // index of segments for which projection fall inside
  np=size(xp,'*')
  if ~isempty(ki) then
    //projection on segments
    x=[xp(ki) xp(ki+1)]
    y=[yp(ki) yp(ki+1)]
    dx=x(:,2)-x(:,1)
    dy=y(:,2)-y(:,1)
    d_d=dx.^2+dy.^2
    d_x=( dy.*(-x(:,2).*y(:,1)+x(:,1).*y(:,2))+dx.*(dx*pt(1)+dy*pt(2)))./d_d
    d_y=(-dx.*(-x(:,2).*y(:,1)+x(:,1).*y(:,2))+dy.*(dx*pt(1)+dy*pt(2)))./d_d
    xp=[xp;d_x]
    yp=[yp;d_y]
  end

  zzz=[ones_new(np,1);zeros_new(size(ki,'*'),1)]*eps
  zz=[ones_new(np,1)*pereps;ones_new(size(ki,'*'),1)]
  if isempty(%pt) then
    [d,k]=min(sqrt(xp.^2+yp.^2).*zz-zzz) 
  else
    [d,k]=min(sqrt((xp-pt(1)).^2+(yp-pt(2)).^2).*zz-zzz) 
  end
  pt(1)=xp(k)
  pt(2)=yp(k)
  if k>np then ind=ki(k-np),else ind=-k,end
endfunction

function draw_link_seg(o,seg)
  if o.thick(2)>=0 then
    t=max(o.thick(1),1)*max(o.thick(2),1)
    xpoly(o.xx(seg),o.yy(seg),type='lines',color=o.ct(1),thickness=t)
  end
endfunction

function draw_link_last_seg(o)
  if o.thick(2)>=0 then
    t=max(o.thick(1),1)*max(o.thick(2),1)
    xpoly(o.xx($-1:$),o.yy($-1:$),type='lines',color=o.ct(1),thickness=t)
  end
endfunction


