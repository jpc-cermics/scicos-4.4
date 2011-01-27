function SMove_()
 Cmenu=''
 SelectSize=size(Select)
 SelectSize=SelectSize(1)
 if ~isempty(Select) then
   if ~isempty(find(Select(:,2)<>curwin)) then
     Select=[]
     Cmenu='SMove'
     return
   end
 end
 [scs_m]=do_move(%pt,scs_m)
 %pt=[]
endfunction

function [scs_m]=do_move(%pt,scs_m)
// Copyright INRIA
// get a scicos object to move, and move it with connected objects
 win=%win;
 xc=%pt(1);yc=%pt(2)
 [k,wh]=getobj(scs_m,[xc;yc])
 if isempty(k) then return, end
 Cmenu=check_edge(scs_m.objs(k),"Smart Move",%pt);
 if isequal(Cmenu,"Link") then resume(Cmenu="Smart Link"), end
 scs_m_save=scs_m
 xcursor(52);
 if scs_m.objs(k).type=='Block' | scs_m.objs(k).type =='Text' then
   needreplay=replayifnecessary()
   if new_graphics() then 
     scs_m=moveblock_new(scs_m,k,xc,yc)
   else
     scs_m=moveblock(scs_m,k,xc,yc)
   end
 elseif scs_m.objs(k).type =='Link' then
   if wh>0 then
     if new_graphics() then 
       scs_m=movelink_new(scs_m,k,xc,yc,wh)
     else
       scs_m=movelink(scs_m,k,xc,yc,wh)
     end
   else
     if new_graphics() then 
       scs_m=movecorner_new(scs_m,k,xc,yc,wh)
     else
       scs_m=movecorner(scs_m,k,xc,yc,wh)
     end
   end
   xcursor()
 end
  resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
endfunction

function scs_m=moveblock(scs_m,k,xc,yc)
// Copyright INRIA  
// Move  block k and modify connected links if any
//!
//look at connected links
  xtape_status=xget('recording')
  connected=get_connected(scs_m,k)
  o=scs_m.objs(k)
  xx=[];yy=[];ii=[];clr=[];mx=[];my=[]

  // build movable segments for all connected links
  //===============================================
  for i=connected
    oi=scs_m.objs(i)
    xset("recording",xtape_status);
    drawobj(oi) //erase link
    if pixmap then xset('wshow'),end
    // [xl,yl,ct,from,to]=oi([2,3,7:9])
    [xl,yl,ct,from,to]=(oi.xx,oi.yy,oi.ct,oi.from,oi.to)
    clr=[clr ct(1)]
    nl=prod(size(xl))
    xtape_status=xget('recording');xset('recording',0);
    xpolys(xl,yl,ct(1))// redraw thin link
    
    if from(1)==k then
      ii=[ii i]
      // build movable segments for this link
      if nl>=4 then
	x1=xl(1:4)
	y1=yl(1:4)
      elseif nl==3 then 
	// 3 points link add one point at the begining
	x1=xl([1 1:3])
	y1=yl([1 1:3])
      elseif xl(1)==xl(2)|yl(1)==yl(2) then 
	// vertical or horizontal 2 points link, add a point in the middle
	x1=[xl(1);xl(1)+(xl(2)-xl(1))/2;xl(1)+(xl(2)-xl(1))/2;xl(2)]
	y1=[yl(1);yl(1)+(yl(2)-yl(1))/2;yl(1)+(yl(2)-yl(1))/2;yl(2)]
      else
	// oblique 2 points link add 2 points in the middle
	x1=[xl(1);xl(1)+(xl(2)-xl(1))/2;xl(1)+(xl(2)-xl(1))/2;xl(2)]
	y1=[yl(1);yl(1);yl(2);yl(2)]
      end
      //set allowed (x or y) move for each points of build movable segments
      if nl==3 then
	if xl(1)==xl(2) then 
	  mx=[mx,[1;1;1;0]]
	  my=[my,[1;1;0;0]]
	else
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	end
      else
	if xl(1)==xl(2) then
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	else
	  mx=[mx,[1;0;0;0]]
	  my=[my,[1;1;0;0]]
	end
      end
      xx=[xx x1];yy=[yy y1]  //store  movable segments for this link
    elseif to(1)==k then
      ii=[ii -i]
      // build movable segments
      if nl>=4 then
	x1=xl(nl:-1:nl-3)
	y1=yl(nl:-1:nl-3)
      elseif nl==3 then 
	// 3 points link add one point at the end
	sel=[nl:-1:nl-2,nl-2]
	x1=xl([nl nl:-1:nl-2])
	y1=yl([nl nl:-1:nl-2])
      elseif xl(1)==xl(2)|yl(1)==yl(2) then 
	// vertical or horizontal 2 points link add a point in the middle
	xm=xl(2)+(xl(1)-xl(2))/2
	x1= [xl(2);xm;xm;xl(1)]
	ym=yl(2)+(yl(1)-yl(2))/2;
	y1= [yl(2);ym;ym;yl(1)]
      else
	// oblique 2 points link add 2 points in the middle
	xm=xl(2)+(xl(1)-xl(2))/2
	x1=[xl(2);xm;xm;xl(1)]
	y1=[yl(2);yl(2);yl(1);yl(1)]
      end
      if nl==3 then
	if x1(2)==x1(3) then 
	  mx=[mx,[1;1;1;0]]
	  my=[my,[1;1;0;0]]
	else
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	end
      else
	if x1(1)==x1(2) then
	  mx=[mx,[1;1;0;0]]
	  my=[my,[1;1;1;0]]
	else
	  mx=[mx,[1;0;0;0]]
	  my=[my,[1;1;0;0]]
	end
      end
      xx=[xx x1];yy=[yy y1] //store  movable segments for this link
    end
  end

  // move a block and connected links
  //=================================
  [mxx,nxx]=size(xx)
  if ~isempty(connected) then // move a block and connected links
    [xmin,ymin]=getorigin(o)
    xc=xmin;yc=ymin
    rep(3)=-1
    [xy,sz]=(o.graphics.orig,o.graphics.sz)
    // clear block
    xset("recording",xtape_status);
    drawobj(o)
    xtape_status=xget('recording');xset('recording',0);

    xpolys(xx+mx*(xc-xmin),yy+my*(yc-ymin),clr)// erase moving part of links
    pat=xget('pattern')
    xset('pattern',default_color(0))
    while rep(3)==-1 ,  // move loop
      
      // draw block shape
      xrect(xc,yc+sz(2),sz(1),sz(2))
      // draw moving links
      xpolys(xx+mx*(xc-xmin),yy+my*(yc-ymin),clr)
      // get new position
      if pixmap then xset('wshow'),end    
      rep=xgetmouse(clearq=%f);
      // clear block shape
      xrect(xc,yc+sz(2),sz(1),sz(2))
      // clear moving part of links
      xpolys(xx+mx*(xc-xmin),yy+my*(yc-ymin),clr)
      xc=rep(1);yc=rep(2)
      xy=[xc,yc];
    end
    xpolys(xx+mx*(xc-xmin),yy+my*(yc-ymin),clr) 
    xset('pattern',pat)
    
    // update and draw block
    if rep(3)<>2 then o.graphics.orig=xy;  scs_m.objs(k)=o;end
    xset("recording",xtape_status);
    drawobj(o)
    if pixmap then xset('wshow'),end
    //udate moved links in scicos structure
    xx=xx+mx*(xc-xmin)
    yy=yy+my*(yc-ymin)
    for i=1:prod(size(ii))
      oi=scs_m.objs(abs(ii(i)))
      xl=oi.xx;yl=oi.yy;nl=prod(size(xl))
      if ii(i)>0 then
	if nl>=4 then
	  xl(1:4)=xx(:,i)
	  yl(1:4)=yy(:,i)
	elseif nl==3 then
	  xl=xx(2:4,i)
	  yl=yy(2:4,i)
	else
	  xl=xx(:,i)
	  yl=yy(:,i)
	end
      else
	if nl>=4 then
	  xl(nl-3:nl)=xx(4:-1:1,i)
	  yl(nl-3:nl)=yy(4:-1:1,i)
	elseif nl==3 then
	  xl=xx(4:-1:2,i)
	  yl=yy(4:-1:2,i)
	else
	  xl=xx(4:-1:1,i)
	  yl=yy(4:-1:1,i)
	end
      end
      nl=prod(size(xl))
      //eliminate double points
      kz=find((xl(2:nl)-xl(1:nl-1)).^2+(yl(2:nl)-yl(1:nl-1)).^2==0)
      xl(kz)=[];yl(kz)=[]
      //store
      xtape_status=xget('recording');xset('recording',0);
      xpolys(xl,yl,oi.ct(1))// erase thin link
      if rep(3)<>2 then
	oi.xx=xl;oi.yy=yl;
	scs_m.objs(abs(ii(i)))=oi;
      end
      xset("recording",xtape_status);
      drawobj(oi)  //draw final link
    end
    if pixmap then xset('wshow'),end
  else // move an unconnected block
    rep(3)=-1
    [xy,sz]=(o.graphics.orig,o.graphics.sz)
    // clear block
    drawobj(o)
    xtape_status=xget('recording');xset('recording',0);
    while rep(3)==-1 , //move loop
		       // draw block shape
		       xrect(xc,yc+sz(2),sz(1),sz(2))
		       // get new position
		       rep=xgetmouse(clearq=%f)
		       // clear block shape
		       xrect(xc,yc+sz(2),sz(1),sz(2))
		       xc=rep(1);yc=rep(2)
		       xy=[xc,yc];
		       if pixmap then xset('wshow'),end
    end
    // update and draw block
    if rep(3)<>2 then o.graphics.orig=xy,scs_m.objs(k)=o,end
    xset("recording",xtape_status);
    drawobj(o)
    if pixmap then xset('wshow'),end
  end
endfunction

function scs_m=moveblock_new(scs_m,k,xc,yc)
// Copyright INRIA  
// Move  block k and modify connected links if any
//!
//look at connected links
    
  connected=unique(get_connected(scs_m,k))
  o=scs_m.objs(k)
  xx=[];yy=[];ii=[];clr=[];mx=[];my=[];mv=[];

  // build movable segments for all connected links
  //===============================================
  for i=connected
    oi=scs_m.objs(i)
    // [xl,yl,ct,from,to]=oi([2,3,7:9])
    [xl,yl,ct,from,to]=(oi.xx,oi.yy,oi.ct,oi.from,oi.to)
    clr=[clr ct(1)]
    nl=size(xl,'*');
    //xtape_status=xget('recording');xset('recording',0);
    //xpolys(xl,yl,ct(1))// redraw thin link
    if from(1)==k then
      // change the links for a link starting at moving point 
      if xl(1)==xl(2)|yl(1)==yl(2) then 
	if nl == 2  then 
	  xm=(xl(1)+xl(2))/2;
	  ym=(yl(1)+yl(2))/2;
	  oi.gr.children(1).x= [xl(1);xm;xm;xl(2:$)];
	  oi.gr.children(1).y= [yl(1);ym;ym;yl(2:$)];
	end
	mv=[mv,2]; // move 2 points ;
      else
	mv=[mv,1];
      end
    elseif to(1)==k then
      // change the links for a link ending at moving point
      if xl($)==xl($-1)|yl($)==yl($-1) then 
	if nl == 2  then 
	  xm=(xl(1)+xl(2))/2;
	  ym=(yl(1)+yl(2))/2;
	  oi.gr.children(1).x= [xl(1);xm;xm;xl(2:$)];
	  oi.gr.children(1).y= [yl(1);ym;ym;yl(2:$)];
	end
	mv=[mv,2]; // move 2 points ;
      else
	mv=[mv,1];
      end
    end
  end
  // move a block and connected links
  //=================================
  
  if ~isempty(connected) then 
    // move a block and connected links
    F=get_current_figure()
    pat=xget('pattern')
    xset('pattern',default_color(0))
    pto=[xc,yc];
    pt = pto;
    while 1
      // move loop
      // get new position
      rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
      if rep(3)==10 then
        global scicos_dblclk
        scicos_dblclk=[rep(1),rep(2),curwin]
      end
      if or(rep(3)==[0,-5, 2, 3, 5]) then
        break
      end
      pt = rep(1:2);
      tr= pt - pto;
      // draw block shape
      o.gr.translate[tr];
      // draw moving links
      for ii=1:length(connected)
	i=connected(ii);	
	oi=scs_m.objs(i)
	if oi.from(1)==k then
	  // translate the first 
	  xl= oi.gr.children(1).x(1:2);
	  yl= oi.gr.children(1).y(1:2);
	  if xl(1)==xl(2) then 
	    oi.gr.children(1).x(1:2)= xl+ tr(1);
	    oi.gr.children(1).y(1)= yl(1)+ tr(2);
	  elseif yl(1)==yl(2) then 
	    oi.gr.children(1).x(1)= xl(1)+ tr(1);
	    oi.gr.children(1).y(1:2)= yl+ tr(2);
	  else
	    oi.gr.children(1).x(1)= xl(1)+ tr(1);
	    oi.gr.children(1).y(1)= yl(1)+ tr(2);
	  end
	elseif to(1)==k then
	  xl= oi.gr.children(1).x($-1:$);
	  yl= oi.gr.children(1).y($-1:$);
	  if xl(1)==xl(2) then 
	    oi.gr.children(1).x($-1:$)= xl+ tr(1);
	    oi.gr.children(1).y($)= yl(2)+ tr(2);
	  elseif yl(1)==yl(2) then 
	    oi.gr.children(1).x($)= xl(2)+ tr(1);
	    oi.gr.children(1).y($-1:$)= yl+ tr(2);
	  else
	    oi.gr.children(1).x($)= xl(2)+ tr(1);
	    oi.gr.children(1).y($)= yl(2)+ tr(2);
	  end
	end
	oi.gr.invalidate[];
      end
      pto=pt;
    end
    // update the block structure and connected links
    if rep(3)<>2 then
      // updates
      o.graphics.orig.redim[1,-1]; // be sure that we are a row
      o.graphics.orig= o.graphics.orig + pt - [xc,yc];
      o.gr.invalidate[];
      for i=connected
	xl= scs_m.objs(i).gr.children(1).x(:);
	yl= scs_m.objs(i).gr.children(1).y(:);
	nl=size(xl,'*');
	//eliminate double points
	kz=find((xl(2:nl)-xl(1:nl-1)).^2+(yl(2:nl)-yl(1:nl-1)).^2==0)
	xl(kz)=[];yl(kz)=[]
	scs_m.objs(i).xx = xl;
	scs_m.objs(i).yy = yl;
	scs_m.objs(i).gr.children(1).x = xl;
	scs_m.objs(i).gr.children(1).y = yl;
	scs_m.objs(i).gr.invalidate[];
      end
      //redraw block
      scs_m.objs(k)=o;
    else
      // we need to restore back the links
      for i=connected
	scs_m.objs(i).gr.children(1).x(:) = scs_m.objs(i).xx;
	scs_m.objs(i).gr.children(1).y(:) = scs_m.objs(i).yy;
	scs_m.objs(i).gr.invalidate[];
      end
      // we need to move the block where it was
      o.gr.translate[[xc,yc]-pt];
      scs_m.objs(k)=o;
    end
  else 
    // move an unconnected block
    // stupid_moveblock_new does a good job 
    // in that case.
    scs_m=stupid_moveblock_new(scs_m,k,xc,yc);
  end
endfunction


function scs_m=movelink(scs_m,k,xc,yc,wh)
// move the  segment wh of the link k and modify the other segments if necessary
//!
  o=scs_m.objs(k)
  drawobj(o) //erase link
  if pixmap then xset('wshow'),end
  xtape_status=xget('recording');xset('recording',0);
  [xx,yy,ct]=(o.xx,o.yy,o.ct)
  xpolys(xx,yy,ct(1)) //redraw thin  link 
  if pixmap then xset('wshow'),end

  nl=size(o.xx,'*')  // number of link points
  if wh==1 then
    from=o.from;to=o.to;
    if is_split(scs_m.objs(from(1)))&is_split(scs_m.objs(to(1)))&nl<3 then
      scs_m=movelink1(scs_m)
    elseif ~is_split(scs_m.objs(from(1)))|nl<3 then
      p=projaff(xx(1:2),yy(1:2),[xc,yc])
      X1=[xx(1);p(1);xx(2)]
      Y1=[yy(1);p(2);yy(2)]
      x1=X1;y1=Y1;
      xpolys(x1,y1,ct(1)) //erase moving part of the link
      rep(3)=-1
      while rep(3)==-1 do
	xpolys(x1,y1,ct(1))//draw moving part of the link
	rep=xgetmouse(clearq=%f);
	if pixmap then xset('wshow'),end
	xpolys(x1,y1,ct(1))//erase moving part of the link
	xc1=rep(1);yc1=rep(2)
	x1(2)=X1(2)-(xc-xc1)
	y1(2)=Y1(2)-(yc-yc1)
      end
      xpolys(x1,y1,ct(1))//draw moving part of the link
      xx=[xx(1);x1(2);xx(2:$)]
      yy=[yy(1);y1(2);yy(2:$)]
      xpolys(xx,yy,ct(1)) // erase thin link
      if rep(3)<>2 then 
	o.xx=xx;o.yy=yy
	scs_m.objs(k)=o
      end
      xset("recording",xtape_status);
      drawobj(o)
      if pixmap then xset('wshow'),end
    else  // link comes from a split 
      scs_m=movelink2(scs_m)
    end
  elseif wh>=nl-1 then
    to=o.to
    if ~is_split(scs_m.objs(to(1)))|nl<3 then
      p=projaff(xx($-1:$),yy($-1:$),[xc,yc])
      X1=[xx($-1);p(1);xx($)]
      Y1=[yy($-1);p(2);yy($)]
      x1=X1;y1=Y1;
      xpolys(x1,y1,ct(1)) //erase moving part of the link
      rep(3)=-1
      while rep(3)==-1 do
	xpolys(x1,y1,ct(1))//draw moving part of the link
	rep=xgetmouse(clearq=%f);
	if pixmap then xset('wshow'),end
	xpolys(x1,y1,ct(1))//erase moving part of the link
	xc1=rep(1);yc1=rep(2)
	x1(2)=X1(2)-(xc-xc1)
	y1(2)=Y1(2)-(yc-yc1)
      end
      xpolys(x1,y1,ct(1))//draw moving part of the link
      xx=[xx(1:$-1);x1(2);xx($)]
      yy=[yy(1:$-1);y1(2);yy($)]
      xpolys(xx,yy,ct(1)) // erase thin link
      if rep(3)<>2 then 
	o.xx=xx;o.yy=yy
	scs_m.objs(k)=o
      end
      xset("recording",xtape_status);
      drawobj(o)
      if pixmap then xset('wshow'),end
    else // link goes to a split 
      scs_m=movelink3(scs_m)
    end
  elseif nl<4 then
    p=projaff(xx(wh:wh+1),yy(wh:wh+1),[xc,yc])
    X1=[xx(wh);p(1);xx(wh+1)]
    Y1=[yy(wh);p(2);yy(wh+1)]
    x1=X1;y1=Y1;
    xpolys(x1,y1,ct(1)) //erase moving part of the link
    rep(3)=-1
    while rep(3)==-1 do
      xpolys(x1,y1,ct(1))//draw moving part of the link
      rep=xgetmouse(clearq=%f);
      if pixmap then xset('wshow'),end
      xpolys(x1,y1,ct(1))//erase moving part of the link
      xc1=rep(1);yc1=rep(2)
      x1(2)=X1(2)-(xc-xc1)
      y1(2)=Y1(2)-(yc-yc1)
    end
    xpolys(x1,y1,ct(1))//draw moving part of the link
    xx=[xx(1:wh);x1(2);xx(wh+1:$)]
    yy=[yy(1:wh);y1(2);yy(wh+1:$)]
    xpolys(xx,yy,ct(1)) // erase thin link
    if rep(3)<>2 then
      o.xx=xx;o.yy=yy
      scs_m.objs(k)=o
    end
    xset("recording",xtape_status);
    drawobj(o)
    if pixmap then xset('wshow'),end
  else
    scs_m=movelink4(scs_m)
  end
endfunction

function scs_m=movelink4(scs_m)
  o;
  e=[min(yy(wh:wh+1))-max(yy(wh:wh+1)),min(xx(wh:wh+1))-max(xx(wh:wh+1))];
  e=e/norm(e)
  X1=xx(wh-1:wh+2);
  Y1=yy(wh-1:wh+2);
  x1=X1;y1=Y1;
  xpolys(x1,y1,ct(1)) //erase moving part of the link
  rep(3)=-1
  while rep(3)==-1 do
    xpolys(x1,y1,ct(1))//draw moving part of the link
    if pixmap then xset('wshow'),end
    rep=xgetmouse(clearq=%f);
    xpolys(x1,y1,ct(1))//erase moving part of the link
    xc1=rep(1);yc1=rep(2)
    x1(2:3)=X1(2:3)+e(1)*(xc-xc1)
    y1(2:3)=Y1(2:3)+e(2)*(yc-yc1)
  end
  //erase rest of the link
  xpolys(xx(1:wh-1),yy(1:wh-1),ct(1))
  xpolys(xx(wh+2:$),yy(wh+2:$),ct(1))
  if rep(3)<>2 then 
    o.xx(wh-1:wh+2)=x1;o.yy(wh-1:wh+2)=y1;
    scs_m.objs(k)=o
  end
  xset("recording",xtape_status);
  drawobj(o)
  if pixmap then xset('wshow'),end
endfunction

function scs_m=movelink1(scs_m)
  o;
  //link between to splits
  e=[min(yy)-max(yy),min(xx)-max(xx)];
  e=e/norm(e)
  xpolys(xx,yy,ct(1))//erase  the link
  X1=xx;Y1=yy
  rep(3)=-1
  while rep(3)==-1 do
    xpolys(xx,yy,ct(1))  //draw  the link
    if pixmap then xset('wshow'),end
    rep=xgetmouse(clearq=%f);
    xpolys(xx,yy,ct(1)) //erase moving part of the link
    xc1=rep(1);yc1=rep(2)
    xx=X1+e(1)*(xc-xc1)
    yy=Y1+e(2)*(yc-yc1)
  end
  if rep(3)<>2 then o.xx=xx;o.yy=yy;end
  scs_m.objs(k)=o
  xset("recording",xtape_status);
  drawobj(o)
  if pixmap then xset('wshow'),end
  if rep(3)==2 then return,end

  //move split block and update other connected links
  connected=[get_connected(scs_m,from(1)),get_connected(scs_m,to(1))]

  for j=find(connected<>k),
    drawobj(scs_m.objs(connected(j))),//erase  other connected links
  end
  drawobj(scs_m.objs(from(1)))//erase split
  drawobj(scs_m.objs(to(1)))//erase split
  
  // change links
  if connected(1)<>k then
    //update links coordinates
    o=scs_m.objs(connected(1));
    if size(o.xx,'*')>2 then
      if o.xx($)==o.xx($-1) then
	o.xx($-1:$)=o.xx($-1:$)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      elseif o.yy($)==o.yy($-1) then
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($-1:$)=o.yy($-1:$)+e(2)*(yc-yc1);
      else
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      end
    else
      o.xx($)=o.xx($)+e(1)*(xc-xc1);
      o.yy($)=o.yy($)+e(2)*(yc-yc1);
    end
    scs_m.objs(connected(1))=o;
    drawobj(o) //redraw link
  end
  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o=scs_m.objs(connected(kk))
      if size(o.xx,'*')>2 then
	if o.xx(1)==o.xx(2) then
	  o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	elseif o.yy(1)==o.yy(2) then
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
	else
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	end
      else
	o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
      scs_m.objs(connected(kk))=o;
      drawobj(o)//redraw link
    end
  end
  //update split coordinates
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  drawobj(o)//redraw split
  scs_m.objs(from(1))=o
  o=scs_m.objs(to(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  drawobj(o)//redraw split
  scs_m.objs(to(1))=o

endfunction

function scs_m=movelink2(scs_m)
  o;
  e=[min(yy(1:2))-max(yy(1:2)),min(xx(1:2))-max(xx(1:2))];
  e=e/norm(e)
  X1=xx(1:3)
  Y1=yy(1:3)
  x1=X1;y1=Y1;
  xpolys(x1,y1,ct(1))//erase  moving part of the link
  if pixmap then xset('wshow'),end
  rep(3)=-1
  while rep(3)==-1 do
    xpolys(x1,y1,ct(1))  //draw moving part of the link
    if pixmap then xset('wshow'),end
    rep=xgetmouse(clearq=%f);
    xpolys(x1,y1,ct(1)) //erase moving part of the link
    xc1=rep(1);yc1=rep(2)
    x1(1:2)=X1(1:2)+e(1)*(xc-xc1)
    y1(1:2)=Y1(1:2)+e(2)*(yc-yc1)
  end
  xpolys(xx(3:$),yy(3:$),ct(1)) // erase rest of initial  link
  if pixmap then xset('wshow'),end
  if rep(3)<>2 then
    o.xx(1:3)=x1;o.yy(1:3)=y1;
  end
  scs_m.objs(k)=o
  xset("recording",xtape_status);
  drawobj(o)
  if pixmap then xset('wshow'),end
  if rep(3)==2 then return,end

  //move split block and update other connected links
  connected=get_connected(scs_m,from(1))

  for j=find(connected<>k),
    drawobj(scs_m.objs(connected(j))),//erase  other connected links
  end
  drawobj(scs_m.objs(from(1)))//erase split
  
  // change links
  if connected(1)<>k then
    //update links coordinates
    o=scs_m.objs(connected(1));
    if size(o.xx,'*')>2 then
      if o.xx($)==o.xx($-1) then
	o.xx($-1:$)=o.xx($-1:$)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      elseif o.yy($)==o.yy($-1) then
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($-1:$)=o.yy($-1:$)+e(2)*(yc-yc1);
      else
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      end
    else
      o.xx($)=o.xx($)+e(1)*(xc-xc1);
      o.yy($)=o.yy($)+e(2)*(yc-yc1);
    end
    scs_m.objs(connected(1))=o;
    drawobj(o) //redraw link
  end
  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o=scs_m.objs(connected(kk))
      if size(o.xx,'*')>2 then
	if o.xx(1)==o.xx(2) then
	  o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	elseif o.yy(1)==o.yy(2) then
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
	else
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	end
      else
	o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
      scs_m.objs(connected(kk))=o;
      drawobj(o)//redraw link
    end
  end
  //update split coordinates
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  drawobj(o)//redraw split
  scs_m.objs(from(1))=o
  if pixmap then xset('wshow'),end
endfunction

function scs_m=movelink3(scs_m)
  o;
  e=[min(yy($-1:$))-max(yy($-1:$)),min(xx($-1:$))-max(xx($-1:$))];
  e=e/norm(e)
  X1=xx($-2:$)
  Y1=yy($-2:$)
  x1=X1;y1=Y1;
  xpolys(x1,y1,ct(1)) //erase moving part of the link
  rep(3)=-1
  while rep(3)==-1 do
    xpolys(x1,y1,ct(1))//draw moving part of the link
    rep=xgetmouse(clearq=%f);
    xpolys(x1,y1,ct(1))//erase moving part of the link
    xc1=rep(1);yc1=rep(2)
    x1($-1:$)=X1($-1:$)+e(1)*(xc-xc1)
    y1($-1:$)=Y1($-1:$)+e(2)*(yc-yc1)
    if pixmap then xset('wshow'),end
  end
  xpolys(xx(1:$-2),yy(1:$-2),ct(1))//erase rest of the link
  if pixmap then xset('wshow'),end
  if rep(3)<>2 then
    o.xx($-2:$)=x1;o.yy($-2:$)=y1;
    scs_m.objs(k)=o
  end
  xset("recording",xtape_status);
  drawobj(o)
  if pixmap then xset('wshow'),end
  if rep(3)==2 then return,end

  //move split block and update other connected links
  connected=get_connected(scs_m,to(1))
  for j=find(connected<>k),
    drawobj(scs_m.objs(connected(j))),//erase connected links
  end
  drawobj(scs_m.objs(to(1))) //erase split

  for kk=2:size(connected,'*')
    //update links coordinates
    o=scs_m.objs(connected(kk))
    if size(o.xx,'*')>2 then
      if o.xx(1)==o.xx(2) then
	o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
	o.yy(1)=o.yy(1)+e(2)*(yc-yc1) 
      elseif o.yy(1)==o.yy(2) then 
	o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
      else
	o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
    else
      o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
      o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
    end
    scs_m.objs(connected(kk))=o;
    drawobj(o) // redraw connected links
  end
  o=scs_m.objs(to(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  drawobj(o) //redraw split
  scs_m.objs(to(1))=o
  if pixmap then xset('wshow'),end

endfunction

function scs_m=movecorner(scs_m,k,xc,yc,wh)
  o=scs_m.objs(k)
  [xx,yy,ct]=(o.xx,o.yy,o.ct)
  if wh==-1|wh==-size(xx,'*') then //link endpoint choosen
    scs_m=movelink(scs_m,k,xc,yc,-wh)
    return
  end
  wh=[-wh-1 -wh]
  drawobj(o) //erase link
  xtape_status=xget('recording');xset('recording',0);
  xpolys(xx,yy,ct(1)) //draw thin link
  if pixmap then xset('wshow'),end
  wh=[wh wh($)+1]
  X1=xx(wh)
  Y1=yy(wh)
  x1=X1;y1=Y1;

  xpolys(x1,y1,ct(1)) //erase moving part of the link
  rep(3)=-1

  while rep(3)==-1 do
    xpolys(x1,y1,ct(1))//draw moving part of the link
    rep=xgetmouse(clearq=%f );
    if pixmap then xset('wshow'),end
    xpolys(x1,y1,ct(1))//erase moving part of the link
    xc1=rep(1);yc1=rep(2)
    x1(2)=X1(2)-(xc-xc1)
    y1(2)=Y1(2)-(yc-yc1)
  end
  [frect1,frect]=xgetech();
  eps=16        //0.04*min(abs(frect(3)-frect(1)),abs(frect(4)-frect(2)))
  if abs(x1(1)-x1(2))<eps then
    x1(2)=x1(1)
  elseif abs(x1(2)-x1(3))<eps then
    x1(2)=x1(3)
  end  
  if abs(y1(1)-y1(2))<eps then
    y1(2)=y1(1)
  elseif abs(y1(2)-y1(3))<eps then
    y1(2)=y1(3)
  end  
  d=projaff([x1(1);x1(3)],[y1(1);y1(3)],[x1(2);y1(2)])
  if norm(d(:)-[x1(2);y1(2)])<eps then
    xx(wh)=x1
    yy(wh)=y1
    xx(wh(2))=[]
    yy(wh(2))=[]
    x1(2)=[];y1(2)=[]
  else
    xx(wh)=x1
    yy(wh)=y1
  end
  xpolys(x1,y1,ct(1))//draw moving part of the link
  xpolys(xx,yy,ct(1)) //erase thin link
  if rep(3)<>2 then
    o.xx=xx;o.yy=yy
    scs_m.objs(k)=o
  end
  xset("recording",xtape_status);
  drawobj(o)
  if pixmap then xset('wshow'),end
endfunction

function scs_m=movelink_new(scs_m,k,xc,yc,wh)
// move the  segment wh of the link k and modify the other segments if necessary
//!
  o=scs_m.objs(k)
  nl=size(o.xx,'*')  // number of link points
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;
  if wh==1 then
    from=o.from;to=o.to;
    if is_split(scs_m.objs(from(1))) && is_split(scs_m.objs(to(1))) &&nl<3 then
      scs_m=movelink1_new(scs_m)
    elseif ~is_split(scs_m.objs(from(1)))|| nl < 3 then
      // we have selected the first segment 
      if %f then 
	// add a point and move it 
	F=get_current_figure()
	p=projaff(xx(1:2),yy(1:2),[xc,yc])
	o.gr.children(1).x = [xx(1);p(1); xx(2:$)];
	o.gr.children(1).y = [yy(1);p(2); yy(2:$)];
	pto=[xc,yc];
// 	rep(3)=-1
// 	while rep(3)==-1 ,
        while 1
	  rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
          if rep(3)==10 then
            global scicos_dblclk
            scicos_dblclk=[rep(1),rep(2),curwin]
          end
          if or(rep(3)==[0,-5, 2, 3, 5]) then
            break
          end
	  pt = rep(1:2);
	  tr= pt - pto;
	  F.draw_latter[];
	  o.gr.children(1).x(2) = o.gr.children(1).x(2) + tr(1);
	  o.gr.children(1).y(2) = o.gr.children(1).y(2) + tr(2);
	  F.draw_now[];
	  pto=pt;
	end
	if rep(3)<>2 then 
	  o.xx = o.gr.children(1).x;
	  o.yy = o.gr.children(1).y;
	  scs_m.objs(k)=o
	else
	  // undo the move 
	  F.draw_latter[];
	  o.gr.children(1).x = o.xx;
	  o.gr.children(1).y = o.yy;
	  F.draw_now[];
	end
      else
	// add a corner 
	p=projaff(xx(1:2),yy(1:2),[xc,yc]);
	o.gr.children(1).x = [xx(1);p(1);p(1); xx(2:$)];
	o.gr.children(1).y = [yy(1);p(2);p(2); yy(2:$)];
	o.xx = o.gr.children(1).x;
	o.yy = o.gr.children(1).y;
	// and force a move of 
	scs_m.objs(k)=o;
	scs_m=movelink_new(scs_m,k,xc,yc,wh+2)
      end
    else  
      // link comes from a split 
      scs_m=movelink2_new(scs_m,o)
    end
  elseif wh >= nl-1 then
    to=o.to
    if ~is_split(scs_m.objs(to(1))) | nl < 3 then
      // we have selected the last segment 
      if %f then 
	// add a point and move it 
	F=get_current_figure()
	p=projaff(xx($-1:$),yy($-1:$),[xc,yc])
	o.gr.children(1).x = [xx(1:$-1);p(1); xx($)];
	o.gr.children(1).y = [yy(1:$-1);p(2); yy($)];
	pto=[xc,yc];
	rep(3)=-1
	while rep(3)==-1 ,
	  rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
	  pt = rep(1:2);
	  tr= pt - pto;
	  F.draw_latter[];
	  o.gr.children(1).x($-1) = o.gr.children(1).x($-1) + tr(1);
	  o.gr.children(1).y($-1) = o.gr.children(1).y($-1) + tr(2);
	  F.draw_now[];
	  pto=pt;
	end
	if rep(3)<>2 then 
	  o.xx = o.gr.children(1).x;
	  o.yy = o.gr.children(1).y;
	  scs_m.objs(k)=o
	else
	  // undo the move 
	  F.draw_latter[];
	  o.gr.children(1).x = o.xx;
	  o.gr.children(1).y = o.yy;
	  F.draw_now[];
	end
      else
	// add a corner 
	p=projaff(xx($-1:$),yy($-1:$),[xc,yc]);
	o.gr.children(1).x = [xx(1:$-1);p(1);p(1); xx($)];
	o.gr.children(1).y = [yy(1:$-1);p(2);p(2); yy($)];
	o.xx = o.gr.children(1).x;
	o.yy = o.gr.children(1).y;
	// and force a move of 
	scs_m.objs(k)=o;
	scs_m=movelink_new(scs_m,k,xc,yc,nl-1)
      end
    else 
      // link goes to a split 
      scs_m=movelink3_new(scs_m,o)
    end
  elseif nl < 4 then
    //-------------
    F=get_current_figure()
    p=projaff(xx(wh:wh+1),yy(wh:wh+1),[xc,yc])
    o.gr.children(1).x = [xx(1:wh);p(1);xx(wh+1:$)];
    o.gr.children(1).y = [yy(1:wh);p(2);yy(wh+1:$)];
    pto=[xc,yc];
    rep(3)=-1
    while rep(3)==-1 ,
      rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
      pt = rep(1:2);
      tr= pt - pto;
      F.draw_latter[];
      o.gr.children(1).x(wh+1) = o.gr.children(1).x(wh+1) + tr(1);
      o.gr.children(1).y(wh+1) = o.gr.children(1).y(wh+1) + tr(2);
      F.draw_now[];
      pto=pt;
    end
    if rep(3)<>2 then 
      o.xx = o.gr.children(1).x;
      o.yy = o.gr.children(1).y;
      scs_m.objs(k)=o
    else
      // undo the move 
      F.draw_latter[];
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      F.draw_now[];
    end
  else
    o=movelink4_new(o);
    scs_m.objs(k)=o;
  end
endfunction

function o=movelink4_new(o)
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;
  e=[min(yy(wh:wh+1))-max(yy(wh:wh+1)),min(xx(wh:wh+1))-max(xx(wh:wh+1))];
  e=e/norm(e)
  F=get_current_figure()
  pto=[xc,yc];
  while 1
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==10 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    pt = rep(1:2);
    tr= pt - pto;
    F.draw_latter[];
    o.gr.children(1).x(wh:wh+1) = o.gr.children(1).x(wh:wh+1) - e(1)*tr(1);
    o.gr.children(1).y(wh:wh+1) = o.gr.children(1).y(wh:wh+1) - e(2)*tr(2);
    F.draw_now[];
    pto=pt;
  end
  if rep(3)<>2 then 
    o.xx = o.gr.children(1).x;
    o.yy = o.gr.children(1).y;
  else
    // undo the move 
    F.draw_latter[];
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_now[];
  end
endfunction

function scs_m=movelink1_new(scs_m)
  o;
  xx=o.gr.children(1).x;
  yy=o.gr.children(1).y;
  e=[min(yy)-max(yy),min(xx)-max(xx)];
  e=e/norm(e)
  F=get_current_figure()
  pto=[xc,yc];
  while 1
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==10 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    pt = rep(1:2);
    tr= pt - pto;
    F.draw_latter[];
    o.gr.children(1).x = o.gr.children(1).x + e(1)*tr(1);
    o.gr.children(1).y = o.gr.children(1).y + e(2)*tr(2);
    F.draw_now[];
    pto=pt;
  end
  if rep(3)==2 then 
    // undo the move 
    F.draw_latter[];
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_now[];
    return;
  end

  o.xx = o.gr.children(1).x;
  o.yy = o.gr.children(1).y;

  //move split block and update other connected links
  connected=[get_connected(scs_m,from(1)),get_connected(scs_m,to(1))]
  
  F.draw_latter[];
  // change links
  if connected(1)<>k then
    //update links coordinates
    o=scs_m.objs(connected(1));
    if size(o.xx,'*')>2 then
      if o.xx($)==o.xx($-1) then
	o.xx($-1:$)=o.xx($-1:$)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      elseif o.yy($)==o.yy($-1) then
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($-1:$)=o.yy($-1:$)+e(2)*(yc-yc1);
      else
	o.xx($)=o.xx($)+e(1)*(xc-xc1);
	o.yy($)=o.yy($)+e(2)*(yc-yc1);
      end
    else
      o.xx($)=o.xx($)+e(1)*(xc-xc1);
      o.yy($)=o.yy($)+e(2)*(yc-yc1);
    end
    o.gr.children(1).x= o.xx;
    o.gr.children(1).y= o.yy;
    scs_m.objs(connected(1))=o;
  end
  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o=scs_m.objs(connected(kk))
      if size(o.xx,'*')>2 then
	if o.xx(1)==o.xx(2) then
	  o.xx(1:2)=o.xx(1:2)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	elseif o.yy(1)==o.yy(2) then
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1:2)=o.yy(1:2)+e(2)*(yc-yc1)
	else
	  o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	  o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
	end
      else
	o.xx(1)=o.xx(1)+e(1)*(xc-xc1)
	o.yy(1)=o.yy(1)+e(2)*(yc-yc1)
      end
      o.gr.children(1).x= o.xx;
      o.gr.children(1).y= o.yy;
      scs_m.objs(connected(kk))=o;
    end
  end
  //update split coordinates
  // XXX gr should be changed 
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  o.gr.translate[[e(1)*(xc-xc1),e(2)*(yc-yc1)]];
  scs_m.objs(from(1))=o
  o=scs_m.objs(to(1))
  o.graphics.orig(1)=o.graphics.orig(1)+e(1)*(xc-xc1);
  o.graphics.orig(2)=o.graphics.orig(2)+e(2)*(yc-yc1);
  o.gr.translate[[e(1)*(xc-xc1),e(2)*(yc-yc1)]];
  scs_m.objs(to(1))=o
  F.draw_now[];
endfunction

function scs_m=movelink2_new(scs_m,o)
  xx=o.gr.children(1).x(1:2);
  yy=o.gr.children(1).y(1:2);
  e=[max(yy)-min(yy),max(xx)-min(xx)];
  e= e ./norm(e)
  F=get_current_figure()
  pto=[xc,yc];
  while 1
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==10 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    pt = rep(1:2);
    tr= pt - pto;
    F.draw_latter[];
    o.gr.children(1).x(1:2) = o.gr.children(1).x(1:2) + e(1)*tr(1);
    o.gr.children(1).y(1:2) = o.gr.children(1).y(1:2) + e(2)*tr(2);
    F.draw_now[];
    pto=pt;
  end
  if rep(3)==2 then 
    // undo the move 
    F.draw_latter[];
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_now[];
    // we can quit 
    return;
  end
  
  F.draw_latter[];
  tr(1) = o.gr.children(1).x(1) - xx(1);
  tr(2) = o.gr.children(1).y(1) - yy(1);
  // update moved link 
  o.xx = o.gr.children(1).x;
  o.yy = o.gr.children(1).y;
  scs_m.objs(k)=o;
  //move split block and update other connected links
  connected=get_connected(scs_m,from(1))
  // change links
  if connected(1)<>k then
    //update links coordinates
    o=scs_m.objs(connected(1));
    if size(o.xx,'*')>2 then
      if o.xx($) ==o.xx($-1) then
	o.xx($-1:$)=o.xx($-1:$)+ tr(1);
	o.yy($)=o.yy($)+ tr(2);
      elseif o.yy($)==o.yy($-1) then
	o.xx($)=o.xx($)+ tr(1);
	o.yy($-1:$)=o.yy($-1:$)+tr(2);
      else
	o.xx($)=o.xx($)+ tr(1);
	o.yy($)=o.yy($)+ tr(2);
      end
    else
      o.xx($)=o.xx($)+ tr(1);
      o.yy($)=o.yy($)+ tr(2);
    end
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    scs_m.objs(connected(1))=o;
  end
  for kk=2:size(connected,'*')
    if connected(kk)<>k then
      //update links coordinates
      o=scs_m.objs(connected(kk))
      if size(o.xx,'*')>2 then
	if o.xx(1)==o.xx(2) then
	  o.xx(1:2)=o.xx(1:2)+tr(1);
	  o.yy(1)=o.yy(1)+ tr(2);
	elseif o.yy(1)==o.yy(2) then
	  o.xx(1)=o.xx(1)+ tr(1);
	  o.yy(1:2)=o.yy(1:2)+tr(2);
	else
	  o.xx(1)=o.xx(1)+ tr(1);
	  o.yy(1)=o.yy(1)+ tr(2);
	end
      else
	o.xx(1)=o.xx(1)+ tr(1);
	o.yy(1)=o.yy(1)+ tr(2);
      end
      o.gr.children(1).x = o.xx;
      o.gr.children(1).y = o.yy;
      scs_m.objs(connected(kk))=o;
    end
  end
  //update split coordinates
  o=scs_m.objs(from(1))
  o.graphics.orig(1)=o.graphics.orig(1)+ tr(1);
  o.graphics.orig(2)=o.graphics.orig(2)+ tr(2);
  o.gr.translate[tr];
  scs_m.objs(from(1))=o
  F.draw_now[];
endfunction

function scs_m=movelink3_new(scs_m,o)
  // moving the last part of a link 
  o;
  xx=o.gr.children(1).x($-1:$);
  yy=o.gr.children(1).y($-1:$);
  e=[max(yy)-min(yy),max(xx)-min(xx)];
  e=e/norm(e)
  F=get_current_figure()
  pto=[xc,yc];
  while 1
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==10 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    pt = rep(1:2);
    tr= pt - pto;
    F.draw_latter[];
    o.gr.children(1).x($-1:$) = o.gr.children(1).x($-1:$) + e(1)*tr(1);
    o.gr.children(1).y($-1:$) = o.gr.children(1).y($-1:$) + e(2)*tr(2);
    F.draw_now[];
    pto=pt;
  end
  if rep(3)==2 then 
    // undo the move 
    F.draw_latter[];
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_now[];
    // we can quit 
    return;
  end
  
  F.draw_latter[];
  tr(1) = o.gr.children(1).x($) - xx($);
  tr(2) = o.gr.children(1).y($) - yy($);
  // update moved link 
  o.xx = o.gr.children(1).x;
  o.yy = o.gr.children(1).y;
  scs_m.objs(k)=o;
  
  //move split block and update other connected links
  connected=get_connected(scs_m,to(1))
  for kk=2:size(connected,'*')
    //update links coordinates
    o=scs_m.objs(connected(kk))
    if size(o.xx,'*')>2 then
      if o.xx(1)==o.xx(2) then
	o.xx(1:2)=o.xx(1:2)+ tr(1)
	o.yy(1)=o.yy(1)+ tr(2)
      elseif o.yy(1)==o.yy(2) then 
	o.xx(1)=o.xx(1)+ tr(1)
	o.yy(1:2)=o.yy(1:2)+tr(2)
      else
	o.xx(1)=o.xx(1)+ tr(1)
	o.yy(1)=o.yy(1)+ tr(2)
      end
    else
      o.xx(1)=o.xx(1)+ tr(1);
      o.yy(1)=o.yy(1)+ tr(2);
    end
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    scs_m.objs(connected(kk))=o;
  end
  o=scs_m.objs(to(1))
  o.graphics.orig(1)=o.graphics.orig(1)+tr(1);
  o.graphics.orig(2)=o.graphics.orig(2)+tr(2);
  o.gr.translate[tr];
  scs_m.objs(to(1))=o;
  F.draw_now[];
endfunction

function scs_m=movecorner_new(scs_m,k,xc,yc,wh)
  o=scs_m.objs(k)
  scs_m=movelink_new(scs_m,k,xc,yc,-wh)
  return
  if wh == -1 | wh == -size(o.xx,'*') then 
    //link endpoint choosen
    scs_m=movelink_new(scs_m,k,xc,yc,-wh)
    return
  end
  wh=-wh;
  F=get_current_figure()
  pto=[xc,yc];
  while 1
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f);
    if rep(3)==10 then
      global scicos_dblclk
      scicos_dblclk=[rep(1),rep(2),curwin]
    end
    if or(rep(3)==[0,-5, 2, 3, 5]) then
      break
    end
    pt = rep(1:2);
    tr= pt - pto;
    F.draw_latter[];
    o.gr.children(1).x(wh) = o.gr.children(1).x(wh) +tr(1);
    o.gr.children(1).y(wh) = o.gr.children(1).y(wh) +tr(2);
    F.draw_now[];
    pto=pt;
  end
  if rep(3)<>2 then 
    o.xx = o.gr.children(1).x;
    o.yy = o.gr.children(1).y;
  else
    // undo the move 
    F.draw_latter[];
    o.gr.children(1).x = o.xx;
    o.gr.children(1).y = o.yy;
    F.draw_now[];
    return;
  end
  
  [frect1,frect]=xgetech();
  eps=16        //0.04*min(abs(frect(3)-frect(1)),abs(frect(4)-frect(2)))
  
  xx= o.gr.children(1).x;
  yy= o.gr.children(1).y;
  
  if abs(xx(wh-1)-xx(wh))<eps then
    xx(wh)=xx(wh-1)
  elseif abs(xx(wh)-xx(wh+1))<eps then
    xx(wh)=xx(wh+1)
  end  
  if abs(yy(wh-1)-yy(wh))<eps then
    yy(wh)=yy(wh-1)
  elseif abs(yy(wh)-yy(wh+1))<eps then
    yy(wh)=yy(wh+1)
  end 
  d=projaff([xx(wh-1);xx(wh+1)],[yy(wh-1);yy(wh+1)],[xx(wh);yy(wh)])
  if norm(d(:)-[xx(wh);yy(wh)])<eps then
    xx(wh)=[]
    yy(wh)=[]
  end
  F.draw_latter[];
  o.xx=xx;
  o.yy=yy;
  o.gr.children(1).x = o.xx;
  o.gr.children(1).y = o.yy;
  F.draw_now[];
  scs_m.objs(k)=o
endfunction
