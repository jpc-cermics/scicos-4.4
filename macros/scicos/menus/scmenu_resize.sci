function scmenu_resize()
  Cmenu='';
  sc=scs_m;
  [scs_m]= do_resize(scs_m);
  if ~scs_m.equal[sc] then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m]=do_resize(scs_m)
// resize a block or a link 
// for a block resize its box 
// for a link changes its thickness and type
//
// if no selection return;
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
  
  if scs_m.objs(K).type=='Block' then
    scs_m_save=scs_m
    path=list('objs',K)
    o=scs_m.objs(K)
    o_n=scs_m.objs(K)
    graphics=o.graphics
    sz=graphics.sz
    orig=graphics.orig
    %scs_help='scmenu_resizeblock'
    if %t then 
      rect=[orig(1);orig(2)+sz(2);0;0]
      if size(%pt,'*')==2 then 
	rect(3:4)=%pt(:);
      end
      [rect,button]=rubberbox(rect,%t);
      w=rect(3);h=rect(4);ok = %t;
      if ok && rect(1)==orig(1) then 
	graphics.sz=[w;h]
	graphics.orig=[orig(1),orig(2)+sz(2)-h];
	o_n.graphics=graphics
	scs_m=changeports(scs_m, path, o_n)
      end
    else
      [ok,w,h]=getvalue('Set Block sizes',['width';'height'],..
			list('vec',1,'vec',1),string(sz(:)))
      if ok then
	graphics.sz=[max(w,10);max(h,10)];
	graphics.orig=orig
	o_n.graphics=graphics
	scs_m=changeports(scs_m, path, o_n)
      end
    end
  elseif scs_m.objs(K).type=='Link' then
    [pos,ct]=(scs_m.objs(K).thick, scs_m.objs(K).ct)
    Thick=pos(1)
    Type=pos(2)
    %scs_help='scmenu_resizelink'
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
endfunction
