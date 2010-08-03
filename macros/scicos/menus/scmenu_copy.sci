function Copy_()
  Cmenu='Open/Set'
  xinfo('Click on the object to copy, drag, click (left to copy, right t"+...
	" o cancel)')
  [%pt,scs_m,needcompile]=do_copy(%pt,scs_m,needcompile)
  xinfo(' ')
endfunction

function [%pt,scs_m,needcompile]=do_copy(%pt,scs_m,needcompile)
// Copyright INRIA
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
        resume(%win=win,Cmenu=Cmenu,btn=btn);
        return;
      end
    else
      xinfo('Click where you want object to be placed (right-click to cancel)')
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[]
    kc=find(win==windows(:,2))
    if isempty(kc) then
      message('This window is not an active palette')
      k=[];break
    elseif windows(kc,1)<0 then //click dans une palette
      kpal=-windows(kc,1)
      palette=palettes(kpal)
      k=getblocktext(palette,[xc;yc])
      if ~isempty(k) then 
	o=disconnect_ports(palette.objs(k)),
	break,
      end
    elseif win==curwin then //click dans la fenetre courante
      k=getblocktext(scs_m,[xc;yc])
      if ~isempty(k) then
	o=disconnect_ports(scs_m.objs(k)) // mark ports disconnected
	break,
      end
    elseif slevel>1 then
      execstr('k=getblocktext(scs_m_'+string(windows(kc,1))+',[xc;yc])')
      if ~isempty(k) then
	execstr('o=scs_m_'+string(windows(kc,1))+'.objs(k)')
	o=disconnect_ports(o)//mark ports disconnected
	break,
      end
    else
      message('This window is not an active palette')
      k=[];break
    end
  end
  if ~isempty(k) then
    if new_graphics() then 
      // new graphics 
      // -----------
      xset('window',curwin);
      xselect();
      xcursor(52);
      rep(3)=-1
      // initial point is %pt;
      pt=[xc,yc];
      // record the objects in graphics 
      F=get_current_figure();
      F.draw_latter[];
      // o is a copy we create a new graphic object for the copy 
      F.start_compound[];
      drawobj(o)
      C=F.end_compound[];
      o.gr = C;
      while rep(3)==-1 then 
	// get new position
	//printf("In Copy moving %d\n",curwin);
	rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f)
	//printf("In Copy moving after getmouse %f,%f,%f\n",rep(1),rep(2),rep(3));
	tr = rep(1:2) - pt;
	pt = rep(1:2)
	F.draw_latter[];
	o.gr.translate[tr];
	o.graphics.orig=o.graphics.orig + tr;
	F.draw_now[];
      end
      if rep(3)==2 then 
	// this is a cancel 
	F.remove[o.gr];
	F.draw_now[];
	xcursor();
	return;
      end
      xcursor();
    else
      // old graphics 
      // -----------
      xset('window',curwin);
      xtape_status=xget('recording')
      rep(3)=-1
      [xy,sz]=(o.graphics.orig,o.graphics.sz)
      p_offset= xy-[xc,yc];
      // record the objects in graphics 
      [echa,echb]=xgetech();
      xclear(curwin,%t);
      xset("recording",1);
      xsetech(echa,echb);
      drawobjs(scs_m);
      xset('recording',0);
      while rep(3)==-1 then 
	// move loop
	// draw block shape
	// redraw the non moving objects.
	xset("recording",1);
	xclear(curwin,%f);
	xtape('replay',curwin);
	xset("recording",0);
	xrect(xy(1),xy(2)+sz(2),sz(1),sz(2))
	if pixmap then xset('wshow'),end
	// get new position
	rep=xgetmouse(clearq=%f)
	// clear block shape
	// xrect(xy(1),xy(2)+sz(2),sz(1),sz(2))
	//xc=rep(1);yc=rep(2)
	xy=rep(1:2) +p_offset  ;
      end
      // update and draw block
      if rep(3)==2 then
	// redraw the non moving objects.
	xset("recording",1);
	xclear(curwin,%f);
	xtape('replay',curwin);
	xset("recording",0);
	xset('recording',xtape_status);      
	if pixmap then xset('wshow'),end
	return
      end
      o.graphics.orig=xy
      // now redraw 
      xset("recording",1);
      xclear(curwin,%f);
      xtape('replay',curwin);
      drawobj(o)
      if pixmap then xset('wshow'),end
    end
    
    scs_m_save=scs_m,nc_save=needcompile
    scs_m.objs($+1)=o
    needcompile=4
    xset('recording',xtape_status);      
    resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
  end
        
endfunction

function o=disconnect_ports(o)
  graphics=o.graphics
  graphics.pin=0*graphics.pin
  graphics.pout=0*graphics.pout
  graphics.pein=0*graphics.pein
  graphics.peout=0*graphics.peout
  o.graphics=graphics
endfunction
