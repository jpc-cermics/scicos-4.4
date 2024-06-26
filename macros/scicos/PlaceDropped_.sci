function PlaceDropped_()
// jpc April 2009 
// place a new block selected by drag and drop from menus.
  Cmenu='';
  if type(btn,'short')<>'h' then pause bug;return;end ;
  // just use the name !
  ok=execstr('blk='+btn.name+'(''define'')',errcatch=%t)
  if ~ok then 
    message(sprintf('Failed to drop a ""%s"" block !",btn.name));
    lasterror();
    Cmenu='';
    return;
  else
    blk.graphics.sz=20*blk.graphics.sz;
  end
  [%pt,scs_m,needcompile]=do_place_dropped_new(scs_m,blk);
endfunction

function [pt,path,win,bname]=PlaceDropped_info(pt1,palette,blk,winid,bname)
// jpc April 2009 
// function activated when a block is dropped 
// 
  pt = pt1; // point clicked at destination 
  path=[palette,blk]; // path in pallettes 
  win=winid; // destination window
endfunction

function [%pt,scs_m,needcompile]=do_place_dropped_new(scs_m,blk)
// jpc April 18 2009
  needcompile=%t;
  o=disconnect_ports(blk);
  xc=%pt(1);yc=%pt(2);%pt=[];
  sz=o.graphics.sz;
  orig=[xc-sz(1)/2,yc-sz(2)/2];
  options=scs_m.props.options
  X_W = options('Wgrid')(1)
  Y_W = options('Wgrid')(2)
  if options('Snap') then
    [orig]=get_wgrid_alignment(orig,[X_W Y_W])
  end
  o.graphics.orig=orig;
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

