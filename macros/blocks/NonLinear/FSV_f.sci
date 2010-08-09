function [x,y,typ]=FSV_f(job,arg1,arg2)
//Absolute value block GUI.
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
case 'define' then
  in=1 //One input/output port with undefinite dimension
  model=scicos_model()
  model.sim=list('fsv',1)
  model.in=in
  model.out=in
  model.blocktype='c'
  model.dep_ut=[%t %f]

  exprs=' '
  gr_i='xstringb(orig(1),orig(2),''f_sv'',sz(1),sz(2),''fill'')'
  x=standard_define([2 2],model,exprs,gr_i,'FSV_f');
end
endfunction
