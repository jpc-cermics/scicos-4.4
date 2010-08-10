function drawobj(o)
// Copyright INRIA
  otype = o.type;
  select otype 
   case 'Block' then
    if o.gui == "" then 
      message(['Block with an undefined field gui';
	       'You must leave scicos and define it now.']),
      return 
    end
    ierr=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
    if %f && new_graphics() then
      [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
      xrect(orig(1),orig(2)+sz(2),sz(1),sz(2))
    end
    if ~ierr then
      // XXX message(['Block '+o.gui+ ' not defined ';
      // 'You must leave scicos and define it now.']),
      message(['Error in '+ o.gui+'(''plot'',o) evaluation\n';catenate(lasterror())]);
    end
   case 'Link' then
    if o.thick(2)>=0 then
      thick=xget('thickness');d=xget('color')
      xset('thickness',max(o.thick(1),1)*max(o.thick(2),1))
      xset('color',o.ct(1))
      xpoly(o.xx,o.yy)
      xset('color',d)
      xset('thickness',thick)
    end
   case 'Text' then
    ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
    if ~ok then
      message(['Error in '+ o.gui+'(''plot'',o) evaluation\n';catenate(lasterror())]);
    end
  end
endfunction

