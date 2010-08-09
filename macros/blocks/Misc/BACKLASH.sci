function [x,y,typ]=BACKLASH(job,arg1,arg2)
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    rpar=model.rpar
    while %t do
      [ok,ini,gap,zcr,exprs]=getvalue('Set backlash parameters',..
				      ['Initial output';
		    'Gap';'Use zero-crossing (0:no, 1:yes)'],..
		    list('vec',1,'vec',1,'vec',1),exprs)
      
      
      if ~ok then break,end
      if ok then
	graphics.exprs=exprs;
	rpar(1)=ini;rpar(2)=gap;
	if zcr<>0 then
	  model.nzcross=2
	else
	  model.nzcross=0
	end
	model.rpar=rpar
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    exprs=['0';'1';'1']
    model=scicos_model()
    model.sim=list('backlash',4)
    model.in=1
    model.out=1
    model.rpar=[0;1]
    model.nzcross=2;
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    gr_i=['xstringb(orig(1),orig(2),[''backlash''],sz(1),sz(2),''fill'')']
    
    x=standard_define([2.5 2],model,exprs,gr_i,'BACKLASH');
  end
endfunction
