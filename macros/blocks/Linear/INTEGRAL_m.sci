function [x,y,typ]=INTEGRAL_m(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),type="lines")
    txt="1/s";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,x0,reinit,satur,maxp,lowp,exprs]=getvalue('Set Integral block parameters',..
						    ['Initial Condition';
						     'With re-intialization (1:yes, 0:no)';'With saturation (1:yes, 0:no)';
						     'Upper limit';'Lower limit'],..
						    list('mat',[-1 -1],'vec',1,'vec',1,'mat',[-1 -1],'mat',[-1 -1]),exprs)
      if ~ok then break,end
      if isreal(x0) then Datatype=1; else Datatype=2; end;
      if reinit<>0 then reinit=1;end
      if satur<>0 then
	satur=1;
	if Datatype==1 then
	  if size(maxp,'*')==1 then maxp=maxp*ones(size(x0)),end
	  if size(lowp,'*')==1 then lowp=lowp*ones(size(x0)),end
	  if (size(x0)<>size(maxp) | size(x0)<>size(lowp)) then
	    message('x0 and Upper limit and Lower limit must have same size')
	    ok=%f
	  elseif or(maxp<=lowp)  then
	    message('Upper limits must be > Lower limits')
	    ok=%f
	  elseif or(x0>maxp)|or(x0<lowp) then
	    message('Inital condition x0 should be inside the limits')
	    ok=%f
	  else
	    rpar=[real(maxp(:));real(lowp(:))]
	    model.nzcross=size(x0,'*')
	    model.nmode=size(x0,'*')
	  end
	elseif (Datatype==2) then
	  if size(maxp,'*')==1 then maxp=maxp*ones(size(x0))+%i*(maxp*ones(size(x0))),end
	  if size(lowp,'*')==1 then lowp=lowp*ones(size(x0))+%i*(lowp*ones(size(x0))),end
	  if (size(x0)<>size(maxp) | size(x0)<>size(lowp)) then
	    message('x0 and Upper limit and Lower limit must have same size')
	    ok=%f
	  elseif or(real(maxp)<=real(lowp))| or(imag(maxp)<=imag(lowp)) then
	    message('Upper limits must be > Lower limits')
	    ok=%f
	  elseif or(real(x0)>real(maxp))|or(real(x0)<real(lowp))| or(imag(x0)>imag(maxp))|or(imag(x0)<imag(lowp)) then
	    message('Inital condition x0 should be inside the limits')
	    ok=%f
	  else
	    rpar=[real(maxp(:));real(lowp(:));imag(maxp(:));imag(lowp(:))]
	    model.nzcross=2*size(x0,'*')
	    model.nmode=2*size(x0,'*')
	  end
	end
      else
	rpar=[]
	model.nzcross=0
	model.nmode=0
      end
      if ok then
	model.rpar=rpar
	if (Datatype==1) then
	  model.state=real(x0(:))
	  model.sim=list('integral_func',4)
	  it=[1;ones(reinit,1)]
	  ot=1;
	elseif (Datatype==2) then 
	  model.state=[real(x0(:));imag(x0(:))];
	  model.sim=list('integralz_func',4)
	  it=[2;2*ones(reinit,1)]
	  ot=2;
	else message("Datatype is not supported");ok=%f;end
	  if ok then
	    if size(x0,"*")>1 then
	      in=[size(x0,1)*[1;ones(reinit,1)],size(x0,2)*[1;ones(reinit,1)]]
	      out=size(x0)
	    else
	      in=[-1*[1;ones(reinit,1)],-2*[1;ones(reinit,1)]]
	      out=[-1,-2]
	    end
	    [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(reinit,1),[])
	  end
      end
      if ok then
	graphics.exprs=exprs
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'compile' then
    model=arg1
    if size(model.state,"*")==1 then
      model.state(1:model.in(1),1:model.in2(1))=model.state
      if model.nzcross>0 then
	x0=model.state
	nx=size(x0,'*')
	rpar=model.rpar
	if isreal(x0) then
	  model.nzcross=nx
	  model.nmode=nx
	  if size(rpar,1)==2 then model.rpar=duplicate(rpar,[nx;nx]),end
	else
	  model.nzcross=2*nx
	  model.nmode=2*nx
	  if size(rpar,1)==4 then model.rpar=duplicate(rpar,[nx;nx;nx;nx]),end
	end
      end
    end
    x=model
   case 'define' then
    maxp=1;minp=-1;rpar=[]
    model=scicos_model()
    model.state=0
    model.sim=list('integral_func',4)
    model.in=-1
    model.out=-1
    model.in2=-2
    model.out2=-2
    model.rpar=rpar
    model.blocktype='c'
    model.dep_ut=[%f %t]

    exprs=string([0;0;0;maxp;minp])
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'INTEGRAL_m');
  end
endfunction
