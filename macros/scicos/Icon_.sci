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
  while %t do
    gr_i=dialog(['Give scilab instructions to draw block';
		 'shape.';		 
		 'orig(1) : block down left corner x coordinate';
		 'orig(2) : block down left corner y coordinate';
		 'sz(1)   : block width';
		 'sz(2)   : block height'],gr_i)
    if size(gr_i,'*')==0 then return,end
    // FIXME: remove the catenate 
    if execstr(catenate(['function mac()';gr_i;'endfunction'])) == %f then
      message(['Incorrect syntax: '])//    lasterror()])
    else
      o=scs_m.objs(K)
      drawblock(o)
      o.graphics.gr_i=list(gr_i,coli)
      if ~execstr('drawblock(o)',errcatch=%t) then 
	message(['errof during drawblock evaluation: '])//    lasterror()])
      else
	scs_m.objs(K)=o
	break
      end
    end
  end
endfunction
