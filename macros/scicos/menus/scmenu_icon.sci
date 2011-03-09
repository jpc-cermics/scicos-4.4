function Icon_()
  Cmenu=''
  xinfo('Click on block to edit its icon')
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [%pt,scs_m]=do_block(%pt,scs_m)
  xinfo(' ')
  edited=%t
endfunction

function [%pt,scs_m]=do_block(%pt,scs_m)
// do_block - edit a block icon
// Copyright INRIA
// modif jpc 2004 
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
	iterate = %f // we can stop
      end
      F.draw_now[];
    end
  end
endfunction
