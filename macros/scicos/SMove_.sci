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
   scs_m=moveblock_new(scs_m,k,xc,yc)
 elseif scs_m.objs(k).type =='Link' then
   if wh>0 then
     scs_m=movelink_new(scs_m,k,xc,yc,wh)
   else
     scs_m=movecorner_new(scs_m,k,xc,yc,wh)
   end
   xcursor()
 end
  resume(scs_m_save,needreplay,enable_undo=%t,edited=%t,nc_save=needcompile);
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
      if rep(3)==3 then
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