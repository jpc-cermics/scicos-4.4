function Duplicate_()
  Cmenu=''
  xinfo('Click on the object to copy, drag, click (left to copy, right t"+...
	" o cancel)')
  [scs_m,needcompile,Select]=do_duplicate(%pt,scs_m,needcompile,Select)
  %pt=''
  xinfo(' ')
endfunction

function [scs_m,needcompile,Select]=do_duplicate(%pt,scs_m,needcompile,Select)
  win=%win;
  xc=%pt(1);yc=%pt(2);
  kc=find(win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active palette')
    k=[];
  elseif windows(kc,1)<0 then //click dans une palette
    kpal=-windows(kc,1)
    palette=palettes(kpal)
    k=getblocktext(palette,[xc;yc])
    if ~isempty(k) then 
      o=disconnect_ports(palette.objs(k))
    end
  elseif win==curwin then //click dans la fenetre courante
    k=getblocktext(scs_m,[xc;yc])
    if ~isempty(k) then
      o=disconnect_ports(scs_m.objs(k)) // mark ports disconnected
    end
  elseif slevel>1 then
    execstr('k=getblocktext(scs_m_'+string(windows(kc,1))+',[xc;yc])')
    if ~isempty(k) then
      execstr('o=scs_m_'+string(windows(kc,1))+'.objs(k)')
      o=disconnect_ports(o)//mark ports disconnected
    end
  else
    message('This window is not an active palette')
    k=[];
  end
  if ~isempty(k) then
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
      if o.iskey['gr'] then o.delete['gr'], end
      o=drawobj(o)
      F.draw_now[];
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
	F.draw_latter[];
	F.remove[o.gr];
	F.draw_now[];
	xcursor();
	return;
      end
      xcursor();
    
    scs_m_save=scs_m,nc_save=needcompile
    scs_m.objs($+1)=o
    needcompile=4
    Select = [length(scs_m.objs), curwin];
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
