function IconEditor_()
  scs_m_save=scs_m
  nc_save=needcompile
  [scs_m]=do_icon_edit(%pt,scs_m);
  Cmenu=''
  %pt=[]
  Cmenu=''
  edited=%t  
endfunction

function [scs_m]=do_icon_edit(%pt,scs_m) 
// do_block - edit a block icon
// Copyright INRIA

  //** get the current win ID
  win=%win;
  //**--------- check Select ------------------
  k= [] ; 
  SelectSize=size(Select,1);
  if SelectSize==1 && Select(1,2)==%win then
    k=Select(1,1);
  end
  if ~isempty(%pt) then 
    k= getobj(scs_m,%pt);
  end
  //**--------- check k and scs_m.objs(k) ------------------
  if isempty(k) then
    //** if you click in the void ... return back
    return
  end 
  
  scs_m_save=scs_m
  path=list('objs',k)
  o=scs_m.objs(k)
  
  if o.type=='Link' then
    //** disable rotation for link
    return
  end 
  // update gr_i 
  gr_i=o.graphics.gr_i
  if type(gr_i,'short')<>'l' then
    gr_i=list(gr_i,[],list('sd',[0 0 1 1]))
  end
  if size(gr_i,'*')==2 then gr_i(3)=list('sd',[0 0 1 1]);end
  // create a new window 
  oldwin=xget('window')
  win=max(winsid())+1;
  if isempty(win) then
    win=0
  end
  xset('window',win)
  xselect()
  coli=gr_i(2)
  sd=gr_i(3)
  sd=ngr_menu(sd);
  if or(win==winsid()) then xdel(win);end
  gr_i = ngr_sd_to_string(sd);
  xset('window',oldwin)
  // chek that gr_i has a correct syntax;
  if execstr(['function gr_void()';gr_i;'endfunction'],errcatch=%t) == %f then
    message(['Incorrect syntax in icon graphics ']);
    return;
  end
  // update and redraw 
  o.graphics.gr_i=list(gr_i,coli,sd);
  F=get_current_figure();
  gr_old = o.gr;
  if ~execstr('o=drawobj(o,oldwin)',errcatch=%t) then 
    message(['errof during drawblock evaluation: ']);
    lasterror();
  else
    // remove the old graphics from the figure 
    F.remove[gr_old];
    // update scs_m;
    scs_m.objs(k)=o;
  end
endfunction
