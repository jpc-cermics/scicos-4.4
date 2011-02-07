function [scs_m,needcompile] = do_replace(scs_m, needcompile, Clipboard, Select)
  //gh_curwin = scf(curwin) //** set the the current window and recover the handle
  o_n=Clipboard
  k=Select(1,1)
  o=scs_m.objs(k)
  o_n.graphics.flip=o.graphics.flip
  [ox,oy]=getorigin(o)
  o_n.graphics.orig=[ox,oy]
  scs_m_save=scs_m
  path=list('objs',k)
  if o_n.iskey['gr'] then o_n.delete['gr'], end
  scs_m=changeports(scs_m, path, o_n);
  nc_save=needcompile
  needcompile=4
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction
