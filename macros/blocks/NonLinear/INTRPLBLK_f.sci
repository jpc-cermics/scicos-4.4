function [x,y,typ]=INTRPLBLK_f(job,arg1,arg2)
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
    while %t do
      [ok,a,b,exprs]=getvalue('Set Interpolation block parameters',..
			      ['X coord.';'Y coord.'],list('vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      if size(a,'*') <> size(b,'*') then
	message('X and Y must have the same size')
      elseif min(a(2:$)-a(1:$-1)) <=0 then
	message('X must be strictly increasing')
      else
	if ok then
	  graphics.exprs=exprs
	  model.rpar=[a(:);b(:)]
	  x.graphics=graphics;x.model=model
	  break
	end
      end
    end
   case 'define' then
    a=[0;1];b=[0;1]
    model=scicos_model()
    model.sim='intrpl'
    model.in=1
    model.out=1
    model.rpar=[a;b]
    model.blocktype='c'
    model.dep_ut=[%t %f]

    exprs=[strcat(sci2exp(a));strcat(sci2exp(b))]
    gr_i=['xstringb(orig(1),orig(2),''interp'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,exprs,gr_i,'INTRPLBLK_f');
  end
endfunction
