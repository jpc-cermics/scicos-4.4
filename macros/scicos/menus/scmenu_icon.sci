function scmenu_icon()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_icon(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function scmenu_icon()
// XXX to be removed 
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_icon(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m,changed]=do_icon(scs_m)
// edit a block icon
// Copyright INRIA
  changed=%f;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  
  if length(K)<> 1 then 
    message('Select only one block or one link for resizing !');
    return;
  end

  if scs_m.objs(K).type <> 'Block' then return;end 
  gr_i=scs_m.objs(K).graphics.gr_i
  
  if type(gr_i,'short')=='l' then
    [gr_i,coli]=gr_i(1:2)
  else
    coli=[]
  end
  if type(gr_i,'short')<>'s' then gr_i=''; end
  iterate = %t
  while iterate do
    gr_i_new=dialog(['Give scilab instructions to draw block';
		     'shape.';		 
		     'orig(1) : block down left corner x coordinate';
		     'orig(2) : block down left corner y coordinate';
		     'sz(1)   : block width';
		     'sz(2)   : block height'],gr_i);
    
    if size(gr_i_new,'*')==0 then return,end
    // FIXME: remove the catenate 
    if ~execstr(['function mac()';gr_i_new;'endfunction'],errcatch=%t) then
      message(['Incorrect syntax: ';catenate(lasterror())]);
      gr_i = gr_i_new;
    else
      F=get_current_figure();
      F.draw_latter[];
      // create new graphic object for the block.
      scs_m.objs(K).graphics.gr_i=list(gr_i_new,coli);
      ok = execstr('scs_m.objs(K)=drawobj(scs_m.objs(K),F);',errcatch=%t);
      if ~ok then 
	message(['error during drawblock evaluation';catenate(lasterror())]);
	scs_m.objs(K).graphics.gr_i=gr_i;
      else
	changed=%t;
	iterate = %f // we can stop
      end
      F.draw_now[];
    end
  end
endfunction
