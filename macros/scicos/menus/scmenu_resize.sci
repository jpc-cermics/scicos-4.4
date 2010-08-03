function Resize_()
  Cmenu='Open/Set'
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  xinfo('Click block to resize')
  [%pt,scs_m]=do_resize(%pt,scs_m)
  xinfo(' ')
  edited=%t
endfunction

function [%pt,scs_m]=do_resize(%pt,scs_m)
// Copyright INRIA
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
        return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[];
    K=getblocklink(scs_m,[xc;yc])
    if ~isempty(K) then 
      if scs_m.objs(K).type =='Block' then
	break,
      else
	[pos,ct]=(scs_m.objs(K).void,scs_m.objs(K).ct)
	Thick=pos(1)
	Type=pos(2)
	[ok,Thick,Type]=getvalue('Link parameters',['Thickness';'Type'],
	list('vec','1','vec',1),[string(Thick);string(Type)])
	if ok then
	  drawobj(scs_m.objs(K))
	  edited=or(scs_m.objs(K).void<>[Thick,Type]);
	  scs_m.objs(K).void=[Thick,Type];
	  drawobj(scs_m.objs(K))
	end
	return
      end
    end
  end
  
  o=scs_m.objs(K)
  graphics=o.graphics
  sz=graphics.sz
  orig=graphics.orig
  [ok,w,h]=getvalue('Set Block sizes',['width';'height'],...
		    list('vec',1,'vec',1),string(sz(:)))
  if ok  then
    w=max(w,5)
    h=max(h,5)
    if w<>sz(1) then
      c = [get_connected(scs_m,K,typ='out'),
	   get_connected(scs_m,K,typ='clkin'),
	   get_connected(scs_m,K,typ='clkout')];
      if ~isempty(c) then 
	message(['Block with connected standard port outputs'
		 'or Event ports cannot be resized horizontally'])
	return
      end
    end
    if h<>sz(2) then
      c = [get_connected(scs_m,K,typ='out'),
	   get_connected(scs_m,K,typ='in'),
	   get_connected(scs_m,K,typ='clkin')];
      if ~isempty(c) then 
	message(['Block with connected standards ports'
		 'or Event input ports cannot be resized vertically'])
	return
      end
    end
    if or(graphics.sz<>[w;h]) || or(graphics.orig<>orig) then 
      graphics.sz=[w;h]
      graphics.orig=orig
      o.graphics=graphics
      if new_graphics() then
        F=get_current_figure();
        F.draw_latter[];
        F.remove[scs_m.objs(K).gr];
        F.start_compound[];
        drawobj(o);
        C=F.end_compound[];
        o.gr=C;
        scs_m.objs(K)=o
        F.draw_now[];
      else
        scs_m.objs(K)=o
        // redraw the scene 
        scicos_redraw_scene(scs_m,[],0)
      end
    end
  end
endfunction


