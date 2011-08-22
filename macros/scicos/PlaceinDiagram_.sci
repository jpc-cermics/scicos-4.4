function PlaceinDiagram_()
// Copyright INRIA  
  Cmenu='';
  if type(btn,'short')<>'h' then pause bug;return;end ;
  // just use the name !
  ok=execstr('blk='+btn.rname+'(''define'')',errcatch=%t)
  if ~ok then 
    message(sprintf('Failed to drop a ""%s"" block !",btn.rname));
    lasterror();
    Cmenu='';
    return;
  else
    blk.graphics.sz=20*blk.graphics.sz;
  end
  [%pt,scs_m,needcompile]=do_placeindiagram_new(scs_m,blk);
endfunction

function [%pt,scs_m,needcompile]=do_placeindiagram_new(scs_m,blk)
// jpc April 13 2009
  needcompile=%f;
  o=disconnect_ports(blk);
  xc=%pt(1);yc=%pt(2);%pt=[];
  sz=o.graphics.sz;
  o.graphics.orig=[xc-sz(1)/2,yc-sz(2)/2];
  xset('window',curwin);
  xselect();
  xcursor(52);
  rep(3)=-1
  // initial point is %pt;
  pt=[xc,yc];
  // record the objects in graphics 
  F=get_current_figure();
  xset('process_updates'); // process the expose events
  // o is a copy we create a new graphic object for the copy
  o=drawobj(o,F)
  while rep(3)==-1 then 
    // get new position
    // printf("In Copy moving %d\n",curwin);
    // xset('process_updates'); // process the expose events
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f)
    //printf("In Copy moving after getmouse %f,%f,%f\n",rep(1),rep(2),rep(3));
    tr = rep(1:2) - pt;
    pt = rep(1:2)
    o.gr.translate[tr];
    // o.gr.invalidate[];
    o.graphics.orig=o.graphics.orig + tr;
  end
  if rep(3)==2 then 
    // this is a cancel 
    // 
    F.remove[o.gr];
    // This will just activate the process update ?
    F.draw_now[]; 
    xcursor();
    return;
  end
  xcursor();
  //     
  scs_m_save=scs_m,nc_save=needcompile
  scs_m.objs($+1)=o
  needcompile=4
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction

