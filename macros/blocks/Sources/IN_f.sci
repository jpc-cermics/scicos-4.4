function [x,y,typ]=IN_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // draw Icon 
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9,thickness=4);
    prt=arg1.model.ipar
    color = default_color(1);
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
      xfpoly(x,y,color=color,thickness=2,fill_color=gr_i(2))
    else
      xfpoly(x,y,color=color,thickness=2);
    end
    xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2),'fill');
    //xstringb(xo,yo,string(prt),sz(1)/1.5,sz(2));
    // Identification 
    ident = arg1.graphics.id
    if ~isempty(ident) && length(ident)<>0 then
      if ~exists('%zoom') then %zoom=1;end
      fz=2*%zoom*4;
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
    typ=ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs;
    if size(exprs,'*')==2 then exprs=exprs(1),end //old compatibility
    if size(exprs,'*')==1 then exprs=[exprs(1);'-1';'-1'],end //compatibility
    while %t do
      [ok,prt,otsz,ot,exprs]=getvalue('Set Input block parameters',..
				      ['Port number';'Outport Size (-1 for inherit)';'Outport Type (-1 for inherit)'],list('vec',1,'vec',-1,'vec',1),exprs);
      if ~ok then 
      	// change port number in any case
	ok1=execstr('prti=evstr(graphics.exprs(1))',errcatch=%t);
	if ~ok1 then lasterror();
	else
	  model.ipar=prti
	  x.model=model
	end
	break
      end 
      prt=int(prt)
      if prt<=0 then
	message('Port number must be a positive integer')
      elseif ~isequal(size(otsz,'*'),2) & ~isequal(otsz,-1) then 
	message('Outport Size must be a 2 elements vector or -1 for inheritence')
      elseif ((ot<1|ot>9)&(ot<>-1)) then
	message('Outport type must be a number between 1 and 9, or -1 for inheritance.')
      else
	if model.ipar<>prt then needcompile=4;y=needcompile,end
	model.ipar=prt
	model.firing=[];
	if size(otsz,'*')==2 then
	  model.out=otsz(1)
	  model.out2=otsz(2)
	else
	  model.out=-1;model.out2=-2
	end
	model.outtyp=ot;
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
    model.sim='input'
    model.out=-1
    model.out2=-2
    model.outtyp=-1
    model.ipar=prt
    model.blocktype='c'
    model.dep_ut=[%f %f]

    exprs=[sci2exp(prt);'-1';'-1']
    gr_i=' '
    x=standard_define([1 1],model,exprs,gr_i,'IN_f');
  end
endfunction
