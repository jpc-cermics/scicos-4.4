function hilite_obj(o,draw=%t)
//
// Copyright INRIA
  if new_graphics() then
    if o.type =='Block' then
      o.gr.hilited = %t;
      o.gr.invalidate[];
    elseif o.type =='Link' then
      // A link is a compound with a polyline inside 
      o.gr.children(1).hilited = %t;
      o.gr.invalidate[];
    end
  else
    xtape_status=xget('recording');xset('recording',0);
    if o.type =='Block' then
      graphics=o.graphics;
      [orig,sz]=(graphics.orig,graphics.sz)
      thick=xget('thickness')
      xset('thickness',6*thick);
      xrect(orig(1),orig(2)+sz(2),sz(1),sz(2));
      if pixmap then xset('wshow'),end
      xset('thickness',thick);
    elseif o.type =='Link' then
      o.thick(1)=5*max(o.thick(1),1)
      drawobj(o)
      if pixmap then xset('wshow'),end
    end
    xset("recording",xtape_status);
  end
endfunction
