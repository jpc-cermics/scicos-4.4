function PlaceDropped_()
// jpc April 2009 
// place a new block selected by drag and drop from menus.
  Cmenu='Open/Set';
  if type(btn,'short')<>'h' then pause bug;return;end ;
  blk = scs_m_palettes(scs_full_path(btn.path));
  if new_graphics() then 
    [%pt,scs_m,needcompile]=do_place_dropped_new(scs_m,blk);
  else
    [%pt,scs_m,needcompile]=do_place_dropped(scs_m,blk);
  end
endfunction

function [pt,path,win]=PlaceDropped_info(pt1,palette,blk,winid)
// jpc April 2009 
// function activated when a block is dropped 
// 
  pt = pt1;
  path=[palette,blk];
  win=winid;
endfunction

function [%pt,scs_m,needcompile]=do_place_dropped_old(scs_m,blk)
  needcompile=%f;
  o=disconnect_ports(blk);
  xc=%pt(1);yc=%pt(2);%pt=[];
  sz=o.graphics.sz;
  o.graphics.orig=[xc-sz(1)/2,yc-sz(2)/2];

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

  scs_m_save=scs_m,nc_save=needcompile
  scs_m.objs($+1)=o
  needcompile=4
  xset('recording',xtape_status);      
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction


function [%pt,scs_m,needcompile]=do_place_dropped(scs_m,blk)
  needcompile=%f;
  o=disconnect_ports(blk);
  xc=%pt(1);yc=%pt(2);%pt=[];
  sz=o.graphics.sz;
  o.graphics.orig=[xc-sz(1)/2,yc-sz(2)/2];
  xset('window',curwin);
  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  drawobj(o)
  if pixmap then xset('wshow'),end
  scs_m_save=scs_m,nc_save=needcompile
  scs_m.objs($+1)=o
  needcompile=4
  xset('recording',xtape_status);      
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction


function [%pt,scs_m,needcompile]=do_place_dropped_new(scs_m,blk)
// jpc April 18 2009
  needcompile=%t;
  o=disconnect_ports(blk);
  xc=%pt(1);yc=%pt(2);%pt=[];
  printf("Start at position [%f,%f]\n",xc,yc);
  sz=o.graphics.sz;
  o.graphics.orig=[xc-sz(1)/2,yc-sz(2)/2];
  xset('window',curwin);
  xselect();
  F=get_current_figure();
  F.draw_latter[];
  // o is a copy we create a new graphic object for the copy 
  F.start_compound[];
  drawobj(o)
  C=F.end_compound[];
  o.gr = C;
  F.draw_now[];

  scs_m_save=scs_m,nc_save=needcompile
  scs_m.objs($+1)=o
  needcompile=4
  xset('recording',xtape_status);      
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction

