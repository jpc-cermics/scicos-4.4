function o=drawobj(o,win)
// Copyright INRIA
// This function creates a graphical object 
// associated to object o. The graphicak object is 
// inserted in the current figure and stored in the 
// gr field of the object.
// Adapted to nsp new graphics: Chancelier, Layec 2011.
//
  if nargin<=1 then
    win=curwin
  end
  xset('window',win)
  F=get_current_figure()
  ishilited=%f
  if o.iskey['gr'] then 
    ishilited=o.gr.hilited
  end
  F.start_compound[];
  otype = o.type;
  ok = %t;
  select otype 
   case 'Block' then
    if o.gui == "" then 
       message(['Block with an undefined field gui';
                'You must leave scicos and define it now.']),
       ok = %f;
       break;
     end
     // perform graphics redirected to create a compound in F.
     ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
     if ~ok then
       message(['Error in '+ o.gui+'(''plot'',o) evaluation:\n'; ...
		catenate(lasterror())]);
       break;
     end
     if %f then 
       // debug 
       [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
       sel_x=orig(1);sel_y=orig(2)+sz(2);
       sel_w=sz(1);sel_h=sz(2);
       xrect(sel_x,sel_y,sel_w,sel_h)
     end
   case 'Link' then
    if o.thick(2)>=0 then
      xpoly(o.xx,o.yy);
      C=F.children(1).children($)
      C.color=o.ct(1)
      C.thickness=max(o.thick(1),1)*max(o.thick(2),1)
    end
   case 'Text' then
    ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
    if ~ok then
      message(['Error in '+ o.gui+'(''plot'',o) evaluation\n'; ...
	       catenate(lasterror())]);
      ok=%f;
    end
  else 
    // other cases.
    ok= %f;
  end
  
  if ~ok then 
    // failed to draw or nothing to draw 
    C=F.end_compound[];
    F.remove[C];
    return;
  end
  
  if ( otype.equal['Block'] ||otype.equal['Text']) && o.graphics.theta<>0 then
    // we need to rotate the object 
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    sel_x=orig(1);sel_y=orig(2)+sz(2);
    sel_w=sz(1);sel_h=sz(2);
    // change rectangles to polylines to be able to rotate them
    change_xrect(F,F.children(1),sel_x+sel_w/2,sel_y-sel_h/2);
    C=F.end_compound[];
    if o.iskey['gr'] then F.remove[o.gr];end 
    o.gr=C;
    o.gr.hilited=ishilited;
    // rotate the objects contained in the compound C
    rotate_compound(sel_x+sel_w/2,sel_y-sel_h/2,o.graphics.theta,o.gr)
  else
    C=F.end_compound[];
    if o.iskey['gr'] then F.remove[o.gr];end 
    o.gr=C;
    o.gr.hilited=ishilited
  end
endfunction

function del=change_xrect(F,C,px,py)
// changes the "GrRect" to polylines in C 
// and remove the "GrRect" from F.
// This function is used in a situation 
// where F is a figure and we are inside 
// a F.start_compound[], F.end_compound[]
// process.
  del={};
  for i=1:size(C.children)
    select type(C.children(i),'string')
     case "GrRect" then
      o = C.children(i);
      x=o.x; y=o.y; w=o.w; h=o.h;
      xxx=rotate([x,x,x+w,x+w; y,y-h,y-h,y],0,[px,py]);
      xfpoly(xxx(1,:),xxx(2,:),color=o.color,fill_color=o.fill_color,...
	     thickness=o.thickness);
      del{$+1}=C.children(i);
     case "Compound" then
      change_xrect(F,C.children(i),px,py);
    end
  end
  for i=1:size(del,'*') 
    F.remove[del{i}];
  end
endfunction

function rotate_compound(px,py,theta,C)
// Rotate the objects contained in the graphic object 
// theta is the angle rotation and the rotation center is 
// the center of the rectangle [sel_x, sel_y, sel_w, sel_h] 
//
  if %f then 
    // XXX: we could directly use this on the compound 
    // but it poses pbs with strings and xrect 
    // when nsp graphics will take care of that the 
    // code will be simplified.
    C.translate[-[px,py]];
    C.rotate[[cos(-theta*%pi/180),sin(-theta*%pi/180)]];
    C.translate[[px,py]];
    return
  end
  
  for i=1:size(C.children)
    select type(C.children(i),'string')
     case "Grstring" then
      C.children(i).angle=theta
     case "Compound" then
      rotate_compound(px,py,theta,C.children(i))
     case "GrArc" then
      // should correct grarcs.c
      o=C.children(i);
      xxx=rotate([o.x+o.w/2; o.y-o.h/2],theta*%pi/180, [px,py])
      C.children(i).x=xxx(1,1)-o.w/2
      C.children(i).y=xxx(2,1)+o.h/2
    else
      C.children(i).translate[-[px,py]];
      C.children(i).rotate[[cos(-theta*%pi/180),sin(-theta*%pi/180)]];
      C.children(i).translate[[px,py]];
    end
  end
endfunction

