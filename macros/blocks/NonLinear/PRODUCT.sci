function [x,y,typ]=PRODUCT(job,arg1,arg2)
// Copyright INRIA
  
  function PRODUCT_draw(o,sz,orig)
    [x,y,typ]=standard_inputs(o) ;
    dd=sz(1)/8,de=0,
    if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    for k=1:size(x,'*');
      if size(sgn,1)>= k then
	if sgn(k)>0 then;
	  xstring(orig(1)+dd,y(k)-4,'*');
	else;
	  xstring(orig(1)+dd,y(k)-4,'/');
	end;
      end;
    end;
    xx=sz(1)*[.8 .8 .4  .4]+orig(1)+de;
    yy=sz(2)*[.2 .8 .8  .2]+orig(2);
    xpoly(xx,yy,type='lines')
    txt='Product';
    style=5;
    rectstr=stringbox(txt,orig(1),orig(2),0,style,1);
    zoom =acquire("%zoom",def=1);
    w=(rectstr(1,3)-rectstr(1,2))*zoom;
    h=(rectstr(2,2)-rectstr(2,4))*zoom;
    xstringb(orig(1)+sz(1)/2-w/2,orig(2)-h-4,txt,w,h,'fill');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    sgn=arg1.model.ipar
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics
    model=arg1.model
    exprs=graphics.exprs
    while %t do
      [ok,sgn,exprs]=getvalue(['         Set multiplication block parameters';
		    '(multiplication is set with + 1, division with -1)';''],...
			      'Number of inputs or sign vector',...
			      list('vec',-1),exprs)
      if ~ok then break,end
      sgn=sgn(:);
      if size(sgn,1)==1 then 
	if sgn<1 then
	  message('Number of inputs must be > 0')
	  ok=%f
	elseif sgn==1 then
	  in=-1
	  sgn=[]
	  nout=1
	else
	  in=-ones(sgn,1)
	  sgn=ones(sgn,1)
	  nout=-1
	end
      else
	if ~and(abs(sgn)==1) then
	  message('Signs can only be +1 or -1')
	  ok=%f
	else
	  in=-ones(size(sgn,1),1)
	  nout=-1
	end
      end
      if ok then
	[model,graphics,ok]=check_io(model,graphics,in,nout,[],[])
      end
      if ok then
	model.ipar=sgn
	graphics.exprs=exprs
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    sgn=[1;-1]
    model=scicos_model()
    model.sim=list('product',4)
    model.in=[-1;-1]
    model.out=-1
    model.ipar=sgn
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    exprs=sci2exp(sgn)
    gr_i=['PRODUCT_draw(o,sz,orig);'];
    x=standard_define([2 3],model, exprs,gr_i,'PRODUCT');
  end
endfunction
