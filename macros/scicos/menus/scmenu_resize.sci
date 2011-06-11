function Resize_()
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;enable_undo=%t
  [%pt,scs_m]=do_resize(%pt,scs_m)
  edited=%t;
  %pt=[];
endfunction

function [%pt,scs_m]=do_resize(%pt,scs_m)
  win=%win
  if isempty(Select) then
    K=getblocklink(scs_m,%pt(:));
  else
    K=Select(:,1)'
    if size(K,'*')>1 | %win<>Select(1,2) then
      message("Only one block can be selected in current window for this operation.")
      Cmenu='';return;
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
