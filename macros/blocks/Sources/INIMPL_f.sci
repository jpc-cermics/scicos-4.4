function [x,y,typ]=INIMPL_f(job,arg1,arg2)
  // Copyright INRIA
  x=[];y=[];typ=[]
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      x=[];y=[];typ=[]
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      x=arg1;
      graphics=arg1.graphics;exprs=graphics.exprs
      model=arg1.model;
      exprs = x.graphics.exprs;
      if size(exprs,'*')==2 then exprs=exprs(1);end;
      while %t do
	[ok,prt,exprs]=getvalue('Set Input block parameters',
				'Port number',list('vec',1),exprs)
	if ~ok then break,end
	prt=int(prt)
	if prt<=0 then
	  message('Port number must be a positive integer')
	else
	  if model.ipar<>prt then y=4;end
	  x.graphics.exprs=exprs
	  x.model.ipar=prt;
	  break
	end
      end
      resume(needcompile=y);
    case 'define' then
      prt=1;
      mo=scicos_modelica(model='PORT',outputs='n'); 
      model=scicos_model(sim='inimpl', out=[-1], out2=[1], ipar=[prt], dep_ut=[%f %f],
			 blocktype='c', equations=mo);
      exprs=sci2exp(prt);
      gr_i=['prt=string(model.ipar);xstringb(orig(1),orig(2),prt,sz(1),sz(2))']
      x=standard_define([1 1],model,exprs,gr_i,'INIMPL_f');
      x.graphics.out_implicit=['I']
  end
endfunction
