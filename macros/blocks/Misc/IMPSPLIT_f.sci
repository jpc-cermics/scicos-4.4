function [x,y,typ]=IMPSPLIT_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[];
  select job
   case 'plot' then
    color = default_color(1);
    orig = arg1.graphics.orig ;
    w=1;
    xarc(orig(1)-w,orig(2)+w,2*w,2*w,0,360*64,color=color,background=color)
   case 'getinputs' then
    graphics=arg1.graphics;orig=graphics.orig;
    x=orig(1)
    y=orig(2)
    typ=ones_deprecated(x)*2
   case 'getoutputs' then
    graphics=arg1.graphics;orig=graphics.orig;
    x=[1 1]*orig(1)
    y=[1 1]*orig(2)
    typ=ones_deprecated(x)*2
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model();
    model.sim       = 'limpsplit';
    mo=modelica()
    mo.model='limpsplit'
    mo.inputs='n';
    mo.outputs=['n';'n']
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    x=standard_define([1 1]/3,model,[],[],'IMPSPLIT_f');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I' 'I']
  end
endfunction
