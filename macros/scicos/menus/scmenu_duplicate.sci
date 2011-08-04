function scmenu_duplicate()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_duplicate(%pt,scs_m,Select);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;needcompile=4;
    Select = [length(scs_m.objs), curwin];
  else
    clear sc;
  end
endfunction

function [scs_m,changed]=do_duplicate(pt,scs_m,Select)
// duplicate a set ob objects and insert them in the diagram 
// 
  changed=%f;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  if length(K)<> 1 then 
    message('Select only one block or one link for duplicate !');
    return;
  end
  o=scs_m.objs(K);
  if o.type <> 'Block' &&  o.type <> 'Text' then
    message('Select only blocks or texts for duplicate !');
    return;
  end
  o=disconnect_ports(o);
  // -----------
  xset('window',curwin);
  xselect();
  xcursor(52);
  rep(3)=-1
  // initial point is %pt;
  if isempty(pt) then 
    pt=o.graphics.orig+ o.graphics.sz/2 ;
  end 
  
  // record the objects in graphics 
  F=get_current_figure();
  F.draw_latter[];
  // o is a copy we create a new graphic object for the copy 
  if o.iskey['gr'] then o.delete['gr'], end
  o=drawobj(o,F)
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
  changed = %t;
  scs_m.objs($+1)=o
endfunction

function o=disconnect_ports(o)
  graphics=o.graphics
  graphics.pin=0*graphics.pin
  graphics.pout=0*graphics.pout
  graphics.pein=0*graphics.pein
  graphics.peout=0*graphics.peout
  o.graphics=graphics
endfunction
