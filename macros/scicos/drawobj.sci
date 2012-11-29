function [o,ok]=drawobj(o,F)
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
  ok=%t;
  if nargin<=1 then F= get_figure(curwin); end
  // record graphics 
  F.start_compound[];
  otype = o.type;
  ok = %t;
  ishilited=%f
  select otype 
   case 'Block' then
    // keep track of previous hilited field 
    if o.iskey['gr'] then 
      ishilited=o.gr.hilited
    end

    // draw  a block 
    if o.gui == "" then 
      message(['Block with an undefined gui field';
	       'You must leave scicos and define it now.']),
      ok = %f;
    else
      // perform graphics redirected to create a compound in F.
      ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
      if ~ok then
	message(['Error in '+ o.gui+'(''plot'',o) evaluation:\n'; ...
		 catenate(lasterror())]);
      end
    end
   case 'Link' then
     // keep track of previous hilited field 
     if o.iskey['gr'] then 
       ishilited=o.gr.children(1).hilited
     end

     //draw ident if needed
     ident = o.id
     //## for compatibility
     if isempty(ident) then ident=emptystr(),end
     if ident=='drawlink' then ident=emptystr(),end

     if ~ident.equal[emptystr()] then
       rect=[min(o.xx)+(max(o.xx)-min(o.xx))/2 min(o.yy)+(max(o.yy)-min(o.yy))/2]

       //@@ compute bbox
       //rectstr = stringbox(ident, rect(1,1), rect(1,2), 0,...
       //                    options.ID(2)(1), options.ID(2)(2));
       //w=(rectstr(1,3)-rectstr(1,2)) * %zoom;
       //h=(rectstr(2,2)-rectstr(2,4)) * %zoom;

       //@@ fill ident in a box
       //xstringb(rect(1,1) - w / 2, rect(1,2) - (h*1.1) , ident , w, h,'fill') ;
       //pause
     end

     // draw link 
     xpoly(o.xx,o.yy);
     C=F.children(1).children($)
     C.color=o.ct(1)
     C.thickness=max(o.thick(1),1)*max(o.thick(2),1)

   case 'Text' then
    // keep track of previous hilited field 
    if o.iskey['gr'] then 
      ishilited=o.gr.hilited
    end
    // draw text 
    ok=execstr(o.gui+'(''plot'',o)' ,errcatch=%t)
    if ~ok then
      message(['Error in '+ o.gui+'(''plot'',o) evaluation\n'; ...
	       catenate(lasterror())]);
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
  C.mark=0;C.mark_size=0;
  if o.iskey['gr'] then 
    // remove previous graphic object 
    // o.gr.invalidate[];
    F.remove[o.gr];
  end 
  o.gr=C;
  if otype=='Link' then
    o.gr.children(1).hilited=ishilited;
  else
    o.gr.hilited=ishilited;
  end

  // check for needed rotation 
  if (otype.equal['Block'] || otype.equal['Text']) then 
    if ~o.graphics.iskey['theta'] then o.graphics.theta=0; end 
    if o.graphics.theta<>0 then
      // rotate the objects contained in the compound C
      if otype.equal['Text'] then
        rect = o.gr.get_bounds[];
        orig = [rect(1) rect(2)];
        sz   = [rect(3)-rect(1) rect(4)-rect(2)];
        o.graphics.sz = sz;
      else
        [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
      end
      tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
      theta= -o.graphics.theta;
      o.gr.translate[-tr];
      o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
      o.gr.translate[tr];
    else
      if otype.equal['Text'] then 
        rect = o.gr.get_bounds[];
        sz   = [rect(3)-rect(1) rect(4)-rect(2)];
        o.graphics.sz = sz;
      end
    end
  end
endfunction

