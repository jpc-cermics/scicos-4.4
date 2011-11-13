function [x,y,typ]=DLRADAPT_f(job,arg1,arg2)
// Copyright INRIA
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
    gv_titles=['Vector of p mesh points';
	       'Numerator roots (one line for each mesh)';
	       'Denominator roots (one line for each mesh)';
	       'Vector of gain at mesh points' ;
	       'past inputs (Num degree values)';
	       'past outputs (Den degree values)'];
    gv_types= list('vec',-1,'mat',[-1,-1],'mat',...
		   ['size(%1,''*'')','-1'],'vec','size(%1,''*'')',..
		   'vec','size(%2,2)','vec','size(%3,2)');
    while %t do
      [ok,p,rn,rd,g,last_u,last_y,exprs]=getvalue('Set block parameters',...
						  gv_titles, gv_types,exprs);
      if ~ok then break,end
      m=size(rn,2)
      [npt,n]=size(rd)
      if m>=n then
	message('Transfer must be strictly proper'),
      elseif size(rn,1)<>0&size(rn,1)<>size(p,'*') then
	message('Numerator roots matrix row size''s is incorrect')
      else
	rpar=[p(:);real(rn(:));imag(rn(:));real(rd(:));imag(rd(:));g(:)]
	ipar=[m;n;npt]
	model.dstate=[last_u(:);last_y(:)]
	model.rpar=rpar
	model.ipar=ipar
	graphics.exprs=exprs
	x.graphics=graphics;x.model=model
	break;
      end
    end
   case 'define' then
    names=['p';'rn';'rd';'g';'last_u';'last_y'];
    exprs=['[0;1]';
	   '[]';
	   '[0.2+0.8*%i,0.2-0.8*%i;0.3+0.7*%i,0.3-0.7*%i]';
	   '[1;1]';
	   '[]';
	   '[0;0]'];
    for i=1:size(names,'*');
      execstr(sprintf('%s=%s;',names(i),exprs(i)));
    end
    
    model=scicos_model()
    model.sim='dlradp'
    model.in=[1;1]
    model.out=1
    model.evtin=1

    model.dstate=[last_u;last_y]
    model.rpar=[p(:);real(rn(:));imag(rn(:));real(rd(:));imag(rd(:));g(:)]
    model.ipar=[0;2;2]
    model.blocktype='d'
    model.firing=[]
    model.dep_ut=[%t %f]
    gr_i=['txt=[''N(z,p)'';''-----'';''D(z,p)''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,exprs,gr_i,'DLRADAPT_f');
  end
endfunction
