function [x,y,typ]=BUSIN_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // draw the icon 
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    prt=arg1.model.ipar
    if orient then
      x=orig(1)+sz(1)*[-1/6;-1/6;1/1.5;1;1/1.5]
      y=orig(2)+sz(2)*[0;1;1; 1/2;0]
      xo=orig(1);yo=orig(2)
    else
      x=orig(1)+sz(1)*[0;1/3;7/6;7/6;1/3]
      y=orig(2)+sz(2)*[1/2;1;1;0;0]
      xo=orig(1)+sz(1)/3;yo=orig(2)
    end
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then 
      xfpoly(x,y,color=2,thickness=2,fill_color=gr_i(2))
    else
      xfpoly(x,y,color=2,thickness=2);
    end
    xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2),'fill')
    // Identification 
    ident = arg1.graphics.id
    if ~isempty(ident) && length(ident)<>0 then
      fz=2*acquire("%zoom",def=1)*4;
      xstring(orig(1)+sz(1)/2,orig(2),ident,posx='center',posy='up',size=fz);
    end
    x=[];y=[]
   case 'getinputs' then
    x=[];y=[];typ=[]
   case 'getoutputs' then
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;

    if orient then
      x=orig(1)+sz(1)
      y=orig(2)+sz(2)/2
    else
      x=orig(1)
      y=orig(2)+sz(2)/2
    end
    typ=3*ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs;
    
    while %t do
      [ok,prt,exprs]=getvalue('Set Input block parameters',..
			      'Port number',list('vec',1),exprs)
      if ~ok then break,end
      prt=int(prt)
      if prt<=0 then
	message('Port number must be a positive integer')
      else
	if model.ipar<>prt then needcompile=4;y=needcompile,end
	model.ipar=prt
	model.firing=[];model.out=-1//compatibility
	graphics.exprs=exprs
	x.graphics=graphics
	x.model=model
	break
      end
    end
   case 'define' then
    in=-1
    prt=1
    model=scicos_model()
    model.sim='inputbus'
    model.out=-1
    model.out2=-2
    model.outtyp=-1
    model.ipar=prt
    model.blocktype='c'
    model.dep_ut=[%f %f]
    exprs=sci2exp(prt)
    gr_i=' '
    x=standard_define([1 1],model,exprs,gr_i,'BUSIN_f');
  end
endfunction
