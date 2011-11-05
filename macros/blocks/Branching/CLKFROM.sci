function [x,y,typ]=CLKFROM(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    prt='['+arg1.graphics.exprs+']'
    pat=xget('pattern');xset('pattern',default_color(-1))
    thick=xget('thickness');xset('thickness',2)
    if orient then
      y=orig(2)+sz(2)*[1/4 1/2 1;1 1 1;1 1/2 1/4;1/4 1/8 0;0 1/8 1/4]'
      x=orig(1)+sz(1)*[0 0 0;0 1/2 1;1 1 1;1 3/4 1/2;1/2 1/4 0]'
      x1=0
    else
      y=orig(2)+sz(2)*[0 1/2 3/4;3/4 7/8 1;1 7/8 3/4;3/4 1/2 0;0 0 0]'
      x=orig(1)+sz(1)*[0 0 0;0 1/4 1/2;1/2 3/4 1;1 1 1;1 1/2 0]'
      x1=0
    end
    xpolys(x,y,5*ones(1,5),color=default_color(-1),thickness=2);
    xstringb(orig(1)+x1*sz(1),orig(2),prt,(1-x1)*sz(1),sz(2));
  endfunction
      
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // do not draw the frame, do not draw the ports
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports,%f,arg1.graphics.flip);
   case 'getinputs' then
    x=[];y=[];typ=[]
   case 'getoutputs' then
    orig=arg1.graphics.orig;sz=arg1.graphics.sz;
    if arg1.graphics.flip then
      x=orig(1)+sz(1)/2
      y=orig(2)
    else
      x=orig(1)+sz(1)/2
      y=orig(2)+sz(2)
    end
    typ=-ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs
    while %t do
      [ok,tag,exprs]=getvalue('Set block parameters',..
			      'Tag',list('str',-1),exprs)
      if ~ok then break,end
      if model.opar<>list(tag) then needcompile=4;y=needcompile,end
      model.opar=list(tag)
      model.evtout=1
      model.firing=-1//compatibility
      graphics.exprs=exprs
      x.graphics=graphics
      x.model=model
      break
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    model.sim='clkfrom'
    model.evtout=1
    model.opar=list('A')
    model.blocktype='d'
    model.firing=-1
    model.dep_ut=[%f %f]
    exprs='A'
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1.5 1.5],model,exprs,gr_i,'CLKFROM');
    x.graphics.id="From"
  end
endfunction
