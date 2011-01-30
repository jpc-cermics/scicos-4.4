function Flip_()
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;
  scs_m=do_tild(scs_m)
  %pt=[]
endfunction

function [scs_m]=do_tild(scs_m)
  xc=%pt(1);yc=%pt(2);
  k=getblock(scs_m,[xc;yc]);
  if ~isempty(k) then 
    scs_m_save=scs_m;
    path=list('objs',k);
    o=scs_m.objs(k);
    o_geom=o.graphics;
    o_geom.flip=~o_geom.flip;
    o.graphics=o_geom;
    scs_m.objs(k)=o;
    o_n=o;
    scs_m=changeports(scs_m, path, o_n);
    resume(scs_m_save,enable_undo=%t,edited=%t);
  else
    return
  end
endfunction
