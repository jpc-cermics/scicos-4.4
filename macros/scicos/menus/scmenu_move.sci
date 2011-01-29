function Move_()
  Cmenu=''
  SelectSize = size(Select) ; //** [row, col]
  SelectSize = SelectSize(1) ; //**  row
  if ~isempty(Select) then
    if ~isempty(find(Select(:,2)<>curwin)) then
      Select=[]
      Cmenu='Move'
      return
    end
  end
  if SelectSize==1 & scs_m.objs(Select(1)).type=="Link" then
    [%pt,scs_m]=do_stupidmove(%pt,scs_m)
  else
    [scs_m] = do_stupidMultimove(%pt, Select, scs_m)
  end
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

function [scs_m] = do_stupidMultimove(%pt, Select, scs_m)
  rel=15/100
  have_moved=%f
  xc = %pt(1)
  yc = %pt(2)
  scs_m_save = scs_m
  needreplay = replayifnecessary()
  [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
  if Cmenu=='Quit' then [%win,Cmenu] = resume(%win,Cmenu), end
  if have_moved then
    resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
  end
endfunction

//  ---------------------------- Move Blocks and connected Link(s) ----------------------------
function [scs_m,have_moved] = stupid_MultiMoveObject(scs_m, Select, xc, yc)
  // Move Selected Blocks/Texts and Links and modify connected (external) links if any

  //** scs_m  : the local level diagram
  //** Select : matrix [object_id win_id] of selected object
  //** xc ,yc : mouse coodinate of the last valid LEFT BUTTON PRESS
  //**
  //** Select : matrix of selected object
  //**          Each line is:  [object_id win_id] : "object_id" is the same INDEX used in "scs_m.obj"
  //**                                          and "win_id"    is the Scilab window id.
  //**          Multiple selection is permitted: each object is a line of the matrix.
  //**----------------------------------------------------------------------------------
  //**
  //** the code below is modified according the new graphics API
  /////////////////////////////////////gh_curwin = gh_current_window ; //** acqiore the current window handle

  //** at this point I need to build the [scs_m] <-> [gh_window] datastructure
  //** I need an equivalent index for the graphics

  //**-----------------------------------------------------------------------------------------------
  //** Acquire axes physical limits (visible limits are smaller) to avoid "off window" move
  //figure_axes_size = gh_curwin.axes_size ; //** size in pixel
  //x_f = figure_axes_size(1) ;
  //y_f = figure_axes_size(2) ;

  //[x1_f, y1_f, rect_f] = xchange([0, x_f],[0, y_f],"i2f"); //** convert to local coordinate

  //x_min = x1_f(1) ; x_max = x1_f(2) ; //** hor. limits
  //y_min = y1_f(2) ; y_max = y1_f(1) ; //** ver. limits (inverted because the upper left corner effect)
  //**-------------------------------------------------------------------------------------------------

  //** Initialization
  have_moved  = %f;
  gh_link_i   = list();
  gh_link_mod = list();

  //**----------------------------------------------------------------------------------
  diagram_links=[]; //** ALL the LINKs of the diagram
  diagram_size=size(scs_m.objs)
  if diagram_size<>0
    for k=1:diagram_size //** scan ALL the diagram and look for 'Link'
      if scs_m.objs(k).type=="Link" then
        diagram_links = [diagram_links k]
      end
    end
  end
  //**----------------------------------------------------------------------------------
  //** Classification of selected object
  sel_block = []; //** blocks selected by the user
  sel_link  = []; //** links
  sel_text  = []; //** text

  SelectObject_id = Select(:,1)'  ; //** select all the object in the current window

  if isempty(SelectObject_id) then
    k=getblocktext(scs_m,[xc;yc])
    if isempty(k) then return, end
    SelectObject_id = k
  end

  //** scan all the selected object
  for k=SelectObject_id
    if scs_m.objs(k).type=='Block' then
      sel_block = [sel_block k]
    end
    if scs_m.objs(k).type=='Link' then
      sel_link = [sel_link k]
    end
    if scs_m.objs(k).type=='Text' then
      sel_text = [sel_text k]
    end
  end //** end of scan

  //**----------------------------------------------------------------------------------
  int_link = []; //** link(s) involved in the move operation

  for l = diagram_links                   //** scan all links and look for external link
     from_block = scs_m.objs(l).from(1) ; //** link proprieties
       to_block = scs_m.objs(l).to(1)   ;
     //** "from" and "to" are relatives to selected blocks
      if (or(from_block==sel_block)) & (or(to_block==sel_block)) then
           int_link = [int_link l]; //** pile up
      end
  end //** end of the link scan
  //**-----------------------------------------------------------------------------------

  //**----------------------------------------------------------------------------------
  connected = []; //** ALL the Links that from/to the supercompound
  ext_block = []; //** ALL the selected blocks that have a links from/to the supercompound

  for k = sel_block //** Scan ALL the selected block and look for external link

     sig_in = scs_m.objs(k).graphics.pin' ; //** signal input
     for l = sig_in //** scan all the input
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then //** the link is not internal
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

     sig_out = scs_m.objs(k).graphics.pout' ; //** signal output
     for l = sig_out //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

     ev_in = scs_m.objs(k).graphics.pein' ;
     for l = ev_in //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
            connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end
	
     ev_out = scs_m.objs(k).graphics.peout' ;
     for l = ev_out //** scan all the output
	  if (~(or(l==int_link ))) & (or(l==diagram_links)) then // ext link
	    connected = [connected l]; //** add to the list of link to move
	    ext_block = [ext_block k];
	  end
     end

  end //** end of scan
  //**-----------------------------------------------------------------------------------

  //** look for all the connected link(s) and build "impiling" the two data structures
  //** [xm , ym] for the links data points
  //** gh_link_i is a vector of the associated graphic handles

  xm = []; //** init
  ym = [];
  if ~isempty(connected) then //** check if external link are present
    for l=1:length(connected) //** scan all the connected links
      i  = connected(l)  ;
      oi = scs_m.objs(i) ;
      gh_link_i($+1)=oi.gr;
      [xl, yl, ct, from, to] = (oi.xx, oi.yy, oi.ct, oi.from, oi.to)
      if from(1)==ext_block(l) then 
        xm = [xm, [xl(2);xl(1)] ];
        ym = [ym, [yl(2);yl(1)] ];
      end

      if to(1)==ext_block(l) then
        xm = [xm, xl($-1:$) ];
        ym = [ym, yl($-1:$) ];
      end
    end
  end
  //** ----------------------------------------------------------------------

  //** Supposing that all the selected object are in the current window
  //** create a new compund that include ALL the selected object
  SuperCompound_id = [sel_block int_link sel_text] ;

  //** -----------------------------------------------------------------------
  xmt = xm ;
  ymt = ym ; //** init ...

  //** --------------------------------- MOVE BLOCK WITH CONNECTED LINKS ------------

  xco = xc;
  yco = yc;

  move_x = 0 ;
  move_y = 0 ;

  //**-------------------------------------------------------------------
  gh_link_mod = []
  tmp_data    = []
  t_xmt       = []
  t_ymt       = []

  //** ------------------------------- INTERACTIVE MOVEMENT LOOP ------------------------------

  /////////////////////////////////////drawlater();
  moved_dist=0
  /////////////////////////////////////if with_gtk() then queue_state=[],end

    xcursor(52);
    while 1 do //** interactive move loop
      rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
      //** left button release, right button (press, click)
      if rep(3)==3 then
        global scicos_dblclk
        scicos_dblclk=[rep(1),rep(2),curwin]
      end
      if or(rep(3)==[-5, 2, 3, 5]) then
        break
      end

      //** Window change and window closure protection
      //gh_figure = gcf()
      //if gh_figure.figure_id<>curwin | rep(3)==-100 then
      //  [%win,Cmenu] = resume(curwin,'Quit')
      //end

      if %scicos_snap then
        SnapIncX = %scs_wgrid(1)
        SnapIncY = %scs_wgrid(2)
        if abs( floor(rep(1)/SnapIncX)-(rep(1)/SnapIncX) ) <...
           abs(  ceil(rep(1)/SnapIncX)-(rep(1)/SnapIncX) )
          delta_x  = floor((rep(1)-xc)/SnapIncX)*SnapIncX;
          xc = floor(rep(1)/SnapIncX)*SnapIncX ;
        else
          delta_x  = ceil((rep(1)-xc)/SnapIncX)*SnapIncX;
          xc = ceil(rep(1)/SnapIncX)*SnapIncX ;
        end
        if abs( floor(rep(2)/SnapIncY)-(rep(2)/SnapIncY) ) <...
           abs(  ceil(rep(2)/SnapIncY)-(rep(2)/SnapIncY) )
          delta_y  = floor((rep(2)-yc)/SnapIncY)*SnapIncY;
          yc = floor(rep(2)/SnapIncY)*SnapIncY ;
        else
          delta_y  = ceil((rep(2)-yc)/SnapIncY)*SnapIncY;
          yc = ceil(rep(2)/SnapIncY)*SnapIncY ;
        end
      else
        //** Mouse movement limitation: to avoid go off the screen
        //if rep(1)>x_min & rep(1)<x_max
          delta_x = rep(1) - xc ; //** calc the differential position
          xc = rep(1);
        //else
        //  delta_x = 0.0 ;
        //end

        //if rep(2)>y_min & rep(2)<y_max
          delta_y = rep(2) - yc ; //** calc the differential position
          yc = rep(2)
        //else
        //  delta_y = 0.0 ;
        //end
      end

      //** Integrate the movements
      move_x = move_x +  delta_x ;
      move_y = move_y +  delta_y ;

      moved_dist=moved_dist+abs(delta_x)+abs(delta_y)
      // under window clicking on a block in a different window causes a move
      if moved_dist>.001 then have_moved=%t,end

      //** Move the SuperCompound
      for k = SuperCompound_id
        o=scs_m.objs(k)
        o.gr.translate[[delta_x , delta_y]];
      end

      if ~isempty(connected) then  //** Move the links
        xmt(2,:) = xm(2,:) + move_x ;
        ymt(2,:) = ym(2,:) + move_y ;
        j = 0 ;
        for l=1:length(connected)
          i  = connected(l)
          oi = scs_m.objs(i)
          [xl,from,to] = (oi.xx,oi.from,oi.to);
          gh_link_mod = gh_link_i(l);

          if from(1)==ext_block(l) then
            xx = gh_link_mod.children(1).x(:);
            yy = gh_link_mod.children(1).y(:);
            tmp_data = [xx,yy]

            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            t_xmt = xmt([2,1],j)
            t_ymt = ymt([2,1],j)
            data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ]
            gh_link_mod.children(1).x=data(:,1)
            gh_link_mod.children(1).y=data(:,2)

            if size(gh_link_mod.children)>1 then
              xx = gh_link_mod.children(1).x(:);
              yy = gh_link_mod.children(1).y(:);
              rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
              xx = gh_link_mod.children(2).x(:);
              yy = gh_link_mod.children(2).y(:);
              gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
              gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
            end
          end

          if to(1)==ext_block(l) then
            xx = gh_link_mod.children(1).x(:)
            yy = gh_link_mod.children(1).y(:)
            tmp_data = [xx,yy]

            rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
            j = j + 1 ;
            data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ]
            gh_link_mod.children(1).x=data(:,1)
            gh_link_mod.children(1).y=data(:,2)

            if size(gh_link_mod.children)>1 then
              xx = gh_link_mod.children(1).x(:);
              yy = gh_link_mod.children(1).y(:);
              rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
              xx = gh_link_mod.children(2).x(:);
              yy = gh_link_mod.children(2).y(:);
              gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
              gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
            end
          end
          gh_link_mod.invalidate[]
        end
      end
    end //** ... of while Interactive move LOOP --------------------------------------------------------------
    xcursor();

    //**-----------------------------------------------
    //gh_figure = gcf();
    //if gh_figure.figure_id<>curwin | rep(3)==-100 then
    //     [%win,Cmenu] = resume(curwin,'Quit') ;
    //end
    //**-----------------------------------------------

    //** OK If update and block and links position in scs_m

    //** if the exit condition is NOT a right button press OR click
    if and(rep(3)<>[2 5]) then //** update the data structure
      //** Rigid SuperCompund Elements
      block=[];

      for k = sel_block
           block = scs_m.objs(k)    ;
	   xy_block = block.graphics.orig ;
	   xy_block(1) = xy_block(1) + move_x ;
	   xy_block(2) = xy_block(2) + move_y ;
	   block.graphics.orig = xy_block ;
	   scs_m.objs(k) = block; //update block coordinates
      end

      text=[]
      for k = sel_text
           text = scs_m.objs(k)
	   xy_text = text.graphics.orig ;
           xy_text(1) = xy_text(1) + move_x ;
	   xy_text(2) = xy_text(2) + move_y ;
	   text.graphics.orig = xy_text;
	   scs_m.objs(k) = text; //update block coordinates
      end

      link_=[]
      for l = int_link
           link_= scs_m.objs(l)
           [xl, yl] = (link_.xx, link_.yy)
	   xl = xl + move_x ;
	   yl = yl + move_y ;
	   link_.xx = xl ; link_.yy = yl ;
	   scs_m.objs(l) = link_ ; 
      end

      //** Flexible Link elements
      if ~isempty(connected) then
          j = 0 ;
          for l=1:length(connected)
             i  = connected(l)  ;
             oi = scs_m.objs(i) ;
             [xl,from,to] = (oi.xx,oi.from,oi.to);

             if from(1)==ext_block(l) then
               j = j + 1 ;
               oi.xx(1:2) = xmt([2,1],j) ;
               oi.yy(1:2) = ymt([2,1],j) ;
             end

             if to(1)==ext_block(l) then
               j = j + 1 ;
               oi.xx($-1:$) = xmt(:,j) ;
               oi.yy($-1:$) = ymt(:,j) ;
             end
              scs_m.objs(i) = oi ; //** update the datastructure 
           end //... for loop
      end //** of if
      //**---------------------------------------------------
      if size(sel_block,2)==1&length(connected)==1 then
        k = sel_block
        lk = scs_m.objs(connected(1))

        moving=0
        if size(lk.xx,'*')==2 then
          dx=lk.xx(1)-lk.xx(2);dy=lk.yy(1)-lk.yy(2);
          if abs(dx)<rel*abs(dy) then
            dy=0;moving=1
          elseif abs(dy)<rel*abs(dx) then
            dx=0;moving=1
          end

          if moving then
            if lk.to(1)==k then
              scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig+[dx,dy]
              lk.xx(2)=lk.xx(2)+dx;lk.yy(2)=lk.yy(2)+dy
              scs_m.objs(connected(1))=lk
              gh_link_mod = gh_link_i(1)
              gh_link_mod.children(1).x(2)=gh_link_mod.children(1).x(2)+dx
              gh_link_mod.children(1).y(2)=gh_link_mod.children(1).y(2)+dy
              gh_link_mod.invalidate[]
            elseif lk.from(1)==k  then
              scs_m.objs(k).graphics.orig=scs_m.objs(k).graphics.orig-[dx,dy]
              lk.xx(1)=lk.xx(1)-dx;lk.yy(1)=lk.yy(1)-dy
              dx=-dx;dy=-dy
              scs_m.objs(connected(1))=lk
              gh_link_mod=gh_link_i(1)
              gh_link_mod.children(1).x(1)=gh_link_mod.children(1).x(1)+dx
              gh_link_mod.children(1).y(1)=gh_link_mod.children(1).y(1)+dy
              gh_link_mod.invalidate[]
            else
              resume(Cmenu='Replot') // graphics inconsistent with scs_m
            end
          end
        end

        if moving then
          o=scs_m.objs(k)
          o.gr.translate[[dx,dy]];
          o.gr.invalidate[]
        end
      end

    //**=---> If the user abort the operation
    else //** restore original position of block and links in figure
         //** in this case: [scs_m] is not modified !

        //** Move back the SuperCompound
        for k=SuperCompound_id 
          o=scs_m.objs(k)
          o.gr.translate[[-move_x,-move_y]];
        end

	//**-------------------------------------------------------
        if ~isempty(connected) then 
	    xmt(2,:) = xm(2,:);  //** original datas of links
            ymt(2,:) = ym(2,:);
            j = 0 ; //** init
            for l=1:length(connected)
               i  = connected(l)  ;
               oi = scs_m.objs(i) ;
               [xl,from,to] = (oi.xx,oi.from,oi.to);
               gh_link_mod = gh_link_i(l) ; // get the link graphics data structure

               if from(1)==ext_block(l) then
                 xx=gh_link_mod.children(1).x(:);
                 yy=gh_link_mod.children(1).y(:);
                 rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 tmp_data = [xx,yy]
                 j = j + 1 ;
                 t_xmt = xmt([2,1],j) ;  t_ymt = ymt([2,1],j) ;
                 data = [ [t_xmt(1) , t_ymt(1)] ; tmp_data(2:$ , 1:$) ];
                 gh_link_mod.children(1).x=data(:,1)
                 gh_link_mod.children(1).y=data(:,2)
                 if size(gh_link_mod.children)>1 then
                   xx = gh_link_mod.children(1).x(:);
                   yy = gh_link_mod.children(1).y(:);
                   rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                   xx=gh_link_mod.children(2).x(:);
                   yy=gh_link_mod.children(2).y(:);
                   gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
                   gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
                 end
               end

               if to(1)==ext_block(l) then
                 xx = gh_link_mod.children(1).x(:);
                 yy = gh_link_mod.children(1).y(:);
                 rect=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                 tmp_data = [xx,yy]
                 j = j +  1 ;
                 data = [ tmp_data(1:$-2 , 1:$) ; [xmt(:,j) , ymt(:,j)] ];
                 gh_link_mod.children(1).x=data(:,1)
                 gh_link_mod.children(1).y=data(:,2)
                 if size(gh_link_mod.children)>1 then
                   xx=gh_link_mod.children(1).x(:);
                   yy=gh_link_mod.children(1).y(:);
                   rect_now=[min(xx)+(max(xx)-min(xx))/2 min(yy)+(max(yy)-min(yy))/2]
                   xx = gh_link_mod.children(2).x(:);
                   yy = gh_link_mod.children(2).y(:);
                   gh_link_mod.children(2).x=xx-(rect(1)-rect_now(1))
                   gh_link_mod.children(2).y=yy-(rect(2)-rect_now(2))
                 end
               end
               gh_link_mod.invalidate[]
             end //... for loop
          end //** of if
         //**------------------------------------------------------

      //draw(gh_curwin.children);
      //show_pixmap();

    end //**----------------------------------------

endfunction
