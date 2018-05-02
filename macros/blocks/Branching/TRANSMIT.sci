function [x,y,typ]=TRANSMIT(job,arg1,arg2)
// Copyright ENPC
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
    y=acquire('needcompile',def=0);
    y=max(y,4);
    if x.model.ipar(1)==1 then 
      x.model.ipar=[0,5];
    else
      x.model.ipar=[1,3];
    end
    exprs=string(x.model.ipar)
    // printf("model %d %d\n",x.model.ipar(1),x.model.ipar(2));
   case 'define' then
    model=scicos_model()
    model.sim=list('transmit_or_zero',4)
    model.in=1
    model.out=0
    model.ipar=[1,3];
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=string(model.ipar)
    gr_i='xfrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=model.ipar(2))';
    x=standard_define([.5 2],model,exprs,gr_i,'TRANSMIT')
    //x.graphics.id="Transmit"
    x.graphics('3D')=%f; // no 3d for this block !
    x.graphics.sz=[0.5,0.5];
  end
endfunction

