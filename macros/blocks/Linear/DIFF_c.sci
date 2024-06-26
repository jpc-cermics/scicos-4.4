function [x,y,typ]=DIFF_c(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[]
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
    x=arg1
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      ask_again=%f
      [ok,x0,xd0,exprs]=getvalue('Set continuous linear system parameters',..
				 ['Initial state','Initial Derivative'],list('vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      x0=x0(:);N=size(x0,'*');
      xd0=xd0(:);Nxd=size(xd0,'*');
      if (N~=Nxd) then 
	message('Incompatible sizes: states and their derivatives should have the same size ')
	ask_again=%t
      end  
      if (N<=0 & ~ask_again) then
	message('number of states must be > 0 ')
	ask_again=%t
      end
      
      if ~ask_again  then
	graphics.exprs=exprs
	model.state=[x0;xd0];
	model.out=[N]
	model.in=N
	x.graphics=graphics;x.model=model
	break
      end
    end
    x.model.firing=[] //compatibility
   case 'define' then
    x0=[0;0]
    model=scicos_model()
    model.sim=list('diffblk_c',10004)
    model.in=1
    model.out=1
    model.state=x0
    model.blocktype='c'
    model.dep_ut=[%f %t]
    
    exprs=[strcat(sci2exp(x0(1)));strcat(sci2exp(x0(2)))]
    gr_i=['xstringb(orig(1),orig(2),'' s  '',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,exprs,gr_i,'DIFF_c');
  end
endfunction
