function [x,y,typ]=OUTIMPL_f(job,arg1,arg2)
  // Copyright INRIA
  x=[];y=[];typ=[]
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      x=[];y=[];typ=[];
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      x=arg1;
      // just in case this is an old bloc
      if size(x.graphics.exprs,'*') <>3 then x = OUTIMPL_f('update',x);end
      exprs = x.graphics.exprs;
      gv_title = 'Set Output block parameters';
      gv_titles = ['Port number';
		   'Inport Size (-1 for inherit)';
		   'Inport Type (-1 for inherit)'];
      while %t do
	[ok,port_n,size_n,type_n,exprs_n]=getvalue(gv_title, gv_titles,
						   list('vec',1,'vec',-1,'vec',1),exprs);
	if ~ok then return;end
	port_n=int(port_n);
	if port_n <= 0 then
	  message('Port number must be a positive integer');
	elseif size(size_n,'*')<>2 && ~size_n.equal[-1] then
	  message('Inport Size must be a 2 elements vector or -1 for inheritence')
	elseif ((type_n<1 | type_n>9) &(type_n<>-1)) then
	  message('Inport type must be a number between 1 and 9, or -1 for inheritance.')
	else
	  if x.model.ipar<>port_n then y=4;end
	  x.model.ipar=port_n
	  x.model.firing=[];
	  if size(size_n,'*')==2 then
	    x.model.in=size_n(1);
	    x.model.in2=size_n(2)
	  else
	    x.model.in=-1;
	    x.model.in2=-2
	  end
	  x.model.intyp=type_n;
	  x.graphics.exprs=exprs_n;
	  break
	end
      end
      resume(needcompile=y);
    case 'define' then
      if nargin == 2 then prt=arg1; else prt=1;end 
      mo=scicos_modelica(model='PORT', inputs='n');
      model=scicos_model(sim='outimpl', in=[-1], in2=[1], intyp=1, ipar=prt,
			 blocktype='c', dep_ut=[%f %f], equations=mo);
      exprs=[sci2exp(prt);'-1';'1'];
      gr_i=['prt=string(model.ipar);xstringb(orig(1),orig(2),prt,sz(1),sz(2))']
      x=standard_define([1 1],model,exprs,gr_i,'OUTIMPL_f');
      x.graphics.in_implicit=['I']
    case 'update' then
      x=arg1;
      insizes = [x.model.in, x.model.in2];
      x.graphics.exprs=[x.graphics.exprs(1);sci2exp(insizes);sci2exp(x.model.intyp)]
      ok = execstr(sprintf("prti=int(%s);",x.graphics.exprs(1)),errcatch=%t);
      if ok then x.model.ipar= prti;end
  end
endfunction
