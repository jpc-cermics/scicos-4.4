function Resize_()
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [%pt,scs_m]=do_resize(%pt,scs_m)
  edited=%t
  %pt=[]
endfunction

function [%pt,scs_m]=do_resize(%pt,scs_m)
  win=%win
  if isempty(Select) then
    xc=%pt(1)
    yc=%pt(2)
    %pt=[]
    K=getblocklink(scs_m,[xc;yc])
  else
    K=Select(:,1)'
    %pt=[]
    if size(K,'*')>1 | %win<>Select(1,2) then
      message("Only one block can be selected in current window for this operation.")
      Cmenu='';%pt=[];return;
    end
  end
  if ~isempty(K) then
    if scs_m.objs(K).type=='Block' then
      scs_m_save=scs_m
      path=list('objs',K)
      o=scs_m.objs(K)
      o_n=scs_m.objs(K)
      graphics=o.graphics
      sz=graphics.sz
      orig=graphics.orig
      %scs_help='Resize_block'
      [ok,w,h]=getvalue('Set Block sizes',['width';'height'],..
                     list('vec',1,'vec',1),string(sz(:)))
      if ok then
        graphics.sz=[w;h]
        graphics.orig=orig
        o_n.graphics=graphics
        scs_m=changeports(scs_m, path, o_n)
      end
    elseif scs_m.objs(K).type=='Link' then
      [pos,ct]=(scs_m.objs(K).thick, scs_m.objs(K).ct)
      Thick=pos(1)
      Type=pos(2)
      %scs_help='Resize_link'
      [ok,Thick,Type]=getvalue('Link parameters',['Thickness';'Type'],..
                                  list('vec','1','vec',1),[string(Thick);string(Type)])
      if ok then
        edited=or(scs_m.objs(K).thick<>[Thick,Type])
        scs_m.objs(K).thick=[Thick,Type]
        scs_m.objs(K).gr.children(1).thickness=max(scs_m.objs(K).thick(1),1)*..
                                               max(scs_m.objs(K).thick(2),1)
        scs_m.objs(K).gr.invalidate[]
      end
    else
      message("Resize is allowed only for Blocks or Links.")
    end
  else
    Cmenu=''
  end
endfunction
