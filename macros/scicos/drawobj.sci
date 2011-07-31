function o=drawobj(o,F)
// Copyright INRIA
// This function creates a graphical object 
// associated to object o. The graphical object is 
// inserted in figure F and stored in the 
// gr field of the object. Note that if o.gr already 
// existed it is removed from the figure. 
//
// if F is not given it is assumed that 
// F=get_figure(curwin);
//
// Adapted to nsp new graphics: Chancelier, Layec 2011.
//

  if nargin<=1 then F= get_figure(curwin); end
  // keep track of previous hilited field 
  ishilited=%f
  if o.iskey['gr'] then 
    ishilited=o.gr.hilited
  end
  // record graphics 
  F.start_compound[];
  otype = o.type;
  ok = %t;
  select otype 
   case 'Block' then
    // draw  a block 
    if o.gui == "" then 
      message(['Block with an undefined gui field';
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
   case 'Link' then
    // draw a link 
    if o.thick(2)>=0 then
      xpoly(o.xx,o.yy);
      C=F.children(1).children($)
      C.color=o.ct(1)
      C.thickness=max(o.thick(1),1)*max(o.thick(2),1)
    end
   case 'Text' then
    // draw text 
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

  C=F.end_compound[];
  if o.iskey['gr'] then 
    // remove previous graphic object 
    // o.gr.invalidate[];
    F.remove[o.gr];
  end 
  o.gr=C;
  o.gr.hilited=ishilited;

  // check for needed rotation 
    
  if (otype.equal['Block'] || otype.equal['Text']) then 
    if ~o.graphics.iskey['theta'] then o.graphics.theta=0; end 
    if o.graphics.theta<>0 then
      // rotate the objects contained in the compound C
      [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
      tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
      theta=o.graphics.theta;
      o.gr.translate[-tr];
      o.gr.rotate[[cos(-theta*%pi/180),sin(-theta*%pi/180)]];
      o.gr.translate[tr];
    end
  end
endfunction

