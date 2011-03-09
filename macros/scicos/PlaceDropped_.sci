function PlaceDropped_()
// jpc April 2009 
// place a new block selected by drag and drop from menus.
  Cmenu='';
  if type(btn,'short')<>'h' then pause bug;return;end ;
  blk = scs_m_palettes(scs_full_path(btn.path));
  [%pt,scs_m,needcompile]=do_place_dropped_new(scs_m,blk);
endfunction

function [pt,path,win]=PlaceDropped_info(pt1,palette,blk,winid)
// jpc April 2009 
// function activated when a block is dropped 
// 
  pt = pt1;
  path=[palette,blk];
  win=winid;
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
  o=drawobj(o,F)
  F.draw_now[];

  scs_m_save=scs_m,nc_save=needcompile
  scs_m.objs($+1)=o
  needcompile=4
  //xset('recording',xtape_status);      
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction

