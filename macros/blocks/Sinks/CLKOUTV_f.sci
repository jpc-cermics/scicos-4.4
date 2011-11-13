function [x,y,typ]=CLKOUTV_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    xf=60;
    yf=40;
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    prt=arg1.model.ipar;
    color = default_color(-1);// red 
    x=orig(1)+sz(1)*[1/2;1;  1;0;0  ];
    y=orig(2)+sz(2)*[0;  1/3;1;1;1/3];
    xo=orig(1);yo=orig(2)+sz(2)/3;
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then 
      xfpoly(x,y,color=color,thickness=2,fill_color=gr_i(2))
    else
      xfpoly(x,y,color=color,thickness=2);
    end
    xstringb(xo,yo,string(prt),sz(1),sz(2)/1.5,'fill');
    in= [-1/14,  1/7
	 0,    0
	 1/14,  1/7
	 -1/14,  1/7]*diag([xf,yf]);
    xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1)/2),..
	   in(:,2)+ones(4,1)*(orig(2)+sz(2)),..
	   thickness=2,color=color,fill_color=1)
    // Identification 
    ident = arg1.graphics.id
    //identification
    ident = arg1.graphics.id
    if ~isempty(ident) && length(ident)<>0 then
      if ~exists('%zoom') then %zoom=1;end
      fz=2*%zoom*4;
      xstring(orig(1)+sz(1)/2,orig(2),ident,...
	      posx='center',posy='up',size=fz);
    end
    x=[];y=[];
   case 'getinputs' then
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    x=orig(1)+sz(1)/2
    y=orig(2)+sz(2)
    typ=-ones_deprecated(x) 
   case 'getoutputs' then
    x=[];y=[];typ=[];
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs;
    while %t do
      [ok,prt,exprs]=getvalue('Set Event Output block parameters',..
			      'Port number',list('vec',1),exprs)
      if ~ok then break,end
      prt=int(prt)
      if prt<=0 then
	message('Port number must be a positive integer')
      else
	model.ipar=prt
	model.evtin=1
	graphics.exprs=exprs
	x.graphics=graphics;
	x.model=model
	break
      end
    end
   case 'define' then
    prt=1
    model=scicos_model()
    model.sim='output'
    model.evtin=1
    model.ipar=prt
    model.blocktype='d'
    model.firing=[]
    model.dep_ut=[%f %f]

    exprs=string(prt)
    x=standard_define([1 1.5],model,exprs,' ','CLKOUTV_f');
  end
endfunction
