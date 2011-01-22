function Label_()
  Cmenu=''
  xinfo('Click block to label')
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [%pt,%mod,scs_m]=do_label(%pt,scs_m)
  edited=edited|%mod
  xinfo(' ')
endfunction

function [%pt,mod,scs_m]=do_label(%pt,scs_m)
// do_block - edit a block label
// Copyright INRIA
  mod=%f
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
  o=scs_m.objs(K)
  model=o.model
  lab=model.label
  lab=dialog('Give block label',lab)
  if size(lab,'*')<>0 then
    lab=stripblanks(lab)
    if length(lab)==0 then lab=' ',end
    model.label=lab
    o.model=model
    scs_m.objs(K)=o
    mod=%t
  end
endfunction
