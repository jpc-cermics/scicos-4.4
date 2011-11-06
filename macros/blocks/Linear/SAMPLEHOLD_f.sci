function [x,y,typ]=SAMPLEHOLD_f(job,arg1,arg2)
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
    x.model.firing=[] //compatibility
   case 'define' then
    in=-1
    model=scicos_model()
    model.sim='samphold'
    model.in=-1
    model.out=-1
    model.evtin=1
    model.blocktype='d'
    model.dep_ut=[%t %f]

    gr_i='xstringb(orig(1),orig(2),''S/H'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,' ',gr_i,'SAMPLEHOLD_f');
  end
endfunction
