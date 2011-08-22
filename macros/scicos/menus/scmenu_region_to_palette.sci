function scmenu_region_to_palette()
//   Cmenu=''
//   xinfo(' Click, drag region and click (left to fix, right to cancel)')
//   ierr=execstr('[%pt,scs_m]=do_region2block(%pt,scs_m)',errcatch=%t);
//   if ~ierr then 
//     message(lasterror());
//   end
  Cmenu=''
  if isempty(Select) || ~isequal(Select(1,2),curwin) then
    return
  end
  // use a common function with region_to_superblock
  // but for a palette the links to the new block are 
  // removed 
  [%pt,scs_m]=do_select2block(%pt,scs_m,PAL_f);
  Cmenu='Replot';%pt=[];
endfunction

function [%pt,scs_m] = obsolete_do_region_to_palette(%pt,scs_m)
// Copyright INRIA
  scs_m_save = scs_m
  nc_save    = needcompile;
  if (scs_mb.objs)==0 then //** if no object selected
    return
  end
  //superblock should not inherit the context nor the name
  scs_mb.props.context=' ' 
  scs_mb.props.title(1)='Palette'
  [scs_mb,edited,ok] = do_rename(scs_mb,%t,%t)
  if ~ok then scs_m=scs_m_save;%pt=[];return;end
  ox=rect(1); oy=rect(2)+rect(4); w=rect(3), h=rect(4)
  n=0
  W=max(600,rect(3))
  H=max(400,rect(4))
  sup = PAL_f('define')
  sup.graphics.orig   = [rect(1)+rect(3)/2-20, rect(2)+rect(4)/2-20]
  sup.graphics.sz     = [40 40]
  sup.model.rpar      = scs_mb
  sup.graphics.id     = scs_mb.props.title(1)
  del=[]
  for k=1:lstsize(scs_m.objs)
    o = scs_m.objs(k)
    if typeof(o)=='Block'| typeof(o)=='Text' then //** OK
      // check if block is outside rectangle
      orig = o.graphics.orig
      sz = o.graphics.sz
      x  = [0 1 1 0]*sz(1)+orig(1)
      y  = [0 0 1 1]*sz(2)+orig(2)
      ok = %f
      for kk=1:4
	data=[(ox-x(kk))'*(ox+w-x(kk)),(oy-h-y(kk))'*(oy-y(kk))];
	if data(1)<0 & data(2)<0 then
	  ok = %t;
	  del= [del k];
	  break;
	end
      end //** for()
    end //** of if()
  end ;//** of for()
  needreplay = replayifnecessary() ;
  drawlater();
  [scs_m,DEL] = do_delete2(scs_m,del,%t) ; //** VERY dangerous here !
  // add super block
  drawobj(sup)
  scs_m.objs($+1) = sup
  [scs_m_save,nc_save,enable_undo,edited,needcompile,..
   needreplay] = resume(scs_m_save,nc_save,%t,%t,4,needreplay)
endfunction

