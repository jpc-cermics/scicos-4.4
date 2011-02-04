function o=drawobj(o,win)
// Copyright INRIA
  if nargin<=1 then
    win=curwin
  end
  xset('window',win)
  F=get_current_figure()
  ishilited=%f
  if o.iskey['gr'] then 
    //F.remove[o.gr];
    ishilited=o.gr.hilited
    o.delete['gr'];
  end
  F.start_compound[];
  otype = o.type;
  select otype 
   case 'Block' then
     if o.gui == "" then 
       message(['Block with an undefined field gui';
                'You must leave scicos and define it now.']),
       break
     end
     ierr=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
     [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
     sel_x=orig(1);sel_y=orig(2)+sz(2);
     sel_w=sz(1);sel_h=sz(2);
     if %f && new_graphics() then
       xrect(sel_x,sel_y,sel_w,sel_h)
     end
//     if o.graphics.theta<>0 then
//       rotate_compound(sel_x, sel_y, sel_w, sel_h,1,o.graphics.theta, ...
// 		      get_current_figure())
//     end
     if ~ierr then
       // XXX message(['Block '+o.gui+ ' not defined ';
       // 'You must leave scicos and define it now.']),
       message(['Error in '+ o.gui+'(''plot'',o) evaluation\n';catenate(lasterror())]);
     end
   case 'Link' then
     if o.thick(2)>=0 then
       xpoly(o.xx,o.yy)
       C=F.children(1).children($)
       C.color=o.ct(1)
       C.thickness=max(o.thick(1),1)*max(o.thick(2),1)
     end
   case 'Text' then
     ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
     if ~ok then
       message(['Error in '+ o.gui+'(''plot'',o) evaluation\n';catenate(lasterror())]);
     end
  end

  C=F.end_compound[];
  o.gr=C;
  o.gr.hilited=ishilited
endfunction
