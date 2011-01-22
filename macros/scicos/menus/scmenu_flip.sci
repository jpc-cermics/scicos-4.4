function Flip_()
  Cmenu=''
  xinfo('Click on block to be flipped')
  scs_m_save=scs_m;nc_save=needcompile;
  scs_m=do_tild(scs_m)
  xinfo(' ')
  %pt=[]
endfunction

function scs_m=do_tild(scs_m)
// Copyright INRIA
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
    k=getblock(scs_m,[xc;yc])
    if ~isempty(k) then break,end
  end
  if ~isempty(get_connected(scs_m,k)) then
    message('Connected block can''t be tilded')
    return
  end
  o=scs_m.objs(k)
  geom=o.graphics;geom.flip=~geom.flip;o.graphics=geom;
  scs_m_save=scs_m
  
  if new_graphics() then 
    F=get_current_figure();
    F.draw_latter[];
    F.remove[scs_m.objs(k).gr];
    F.start_compound[];
    drawobj(o);
    C=F.end_compound[];
    o.gr=C;
    scs_m.objs(k)=o
    F.draw_now[];
  else
    scs_m.objs(k)=o
    // redraw 
    xtape_status=xget('recording')
    [echa,echb]=xgetech();
    xclear(curwin,%t);
    xset("recording",1);
    xsetech(echa,echb);
    drawobjs(scs_m);
    xset('recording',xtape_status);
  end
  
  resume(scs_m_save,enable_undo=%t,edited=%t);
endfunction
