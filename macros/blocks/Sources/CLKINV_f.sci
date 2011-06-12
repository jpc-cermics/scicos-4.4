function [x,y,typ]=CLKINV_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // draw icon 
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    gr_i=arg1.graphics.gr_i;
    // 
    prt=arg1.model.ipar
    color = default_color(-1);// red 
    x=orig(1)+sz(1)*[1/2;1;  1;0;0  ]
    y=orig(2)+sz(2)*[0;  1/3;1;1;1/3]
    xo=orig(1);yo=orig(2)+sz(2)/3
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then 
      xfpoly(x,y,color=color,thickness=2,fill_color=gr_i(2))
    else
      xfpoly(x,y,color=color,thickness=2);
    end
    xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5,'fill');
    //identification
    ident = arg1.graphics.id
    if ~isempty(ident) && length(ident)<>0 then
      if ~exists('%zoom') then %zoom=1;end
      fz=2*%zoom*4;
      xstring(orig(1)+sz(1)/2,orig(2)+sz(2),ident,posx='center',posy='bottom',size=fz);
    end
   case 'getinputs' then
    x=[];y=[];typ=[]
   case 'getoutputs' then
    orig=arg1.graphics.orig
    sz=arg1.graphics.sz
    x=orig(1)+sz(1)/2
    y=orig(2)
    typ=-ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics
    model=arg1.model

    exprs=graphics.exprs
    exprs=exprs(1) // compatibility
    while %t do
      [ok,prt,exprs]=getvalue('Set Event Input block parameters',..
			      'Port number',list('vec',1),exprs)
      prt=int(prt)
      if ~ok then break,end
      if prt<=0 then
	message('Port number must be a positive integer')
      else
	model.ipar=prt
	model.evtout=1
	model.firing=-1//compatibility
	graphics.exprs=exprs
	x.graphics=graphics
	x.model=model
	break
      end
    end
   case 'define' then
    prt=1
    model=scicos_model()
    model.sim='input'
    model.evtout=1
    model.ipar=prt
    model.blocktype='d'
    model.firing=-1
    model.dep_ut=[%f %f]
    
    exprs=string(prt)
    gr_i=['xo=orig(1);yo=orig(2)+sz(2)/3';
	  'xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5)']
    x=standard_define([1 1.5],model,exprs,gr_i,'CLKINV_f');
  end
endfunction
