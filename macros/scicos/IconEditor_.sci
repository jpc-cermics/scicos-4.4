function IconEditor_()
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [%pt,scs_m]=do_icon_edit(%pt,scs_m)
  Cmenu='Open/Set'
  xinfo(' ')
  edited=%t  
endfunction

function [%pt,scs_m]=do_icon_edit(%pt,scs_m) 
// do_block - edit a block icon
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
    K=getblock(scs_m,[xc;yc])
    if ~isempty(K) then break,end
  end
  gr_i=scs_m.objs(K).graphics.gr_i
  if type(gr_i,'short')<>'l' then
    gr_i=list(gr_i,[],list('sd',[0 0 1 1]))
  end
  if size(gr_i,'*')==2 then gr_i(3)=list('sd',[0 0 1 1]);end
  oldwin=xget('window')
  win=winsid()
  if isempty(win) then
    win=0
  else
    win=max(win)+1
  end
  xset('window',win)
  xselect()
  coli=gr_i(2)
  sd=gr_i(3)
  sd=gr_menu(sd);
  if or(win==winsid()) then xdel(win);end
  gr_i = gr_sd_to_string(sd);
  xset('window',oldwin)
    
  // chek that gr_i has a correct syntax;
  if execstr(['function gr_void()';gr_i;'endfunction'],errcatch=%t) == %f then
    message(['Incorrect syntax in icon graphics ']);
    return;
  end
  // update and redraw 
  o=scs_m.objs(K)
  drawblock(o)
  o.graphics.gr_i=list(gr_i,coli,sd)
  if ~execstr('drawblock(o)',errcatch=%t) then 
    message(['errof during drawblock evaluation: '])//    lasterror()])
  else
    scs_m.objs(K)=o
  end
endfunction
