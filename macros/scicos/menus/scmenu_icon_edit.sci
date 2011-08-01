function scmenu_icon_edit()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_icon_edit(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function IconEditor_()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_icon_edit(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m,changed]=do_icon_edit(scs_m) 
// edit a block icon
// Copyright INRIA

  changed=%f;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  k=Select(find(Select(:,2)==curwin),1);
  
  if length(k)<> 1 then 
    message('Select only one block or one link for resizing !');
    return;
  end
  
  path=list('objs',k)
  o=scs_m.objs(k)
  
  if o.type <> 'Block' then return;end 
  
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
  F=get_figure(oldwin);
  gr_old = o.gr;
  if ~execstr('o=drawobj(o,F)',errcatch=%t) then 
    message(['Error during drawblock evaluation.']);
    lasterror();
  else
    // remove the old graphics from the figure 
    F.remove[gr_old];
    // update scs_m;
    changed=%t;
    scs_m.objs(k)=o;
  end
endfunction
