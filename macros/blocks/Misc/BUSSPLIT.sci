function [x,y,typ] = BUSSPLIT(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[];
  select job
   case 'plot' then
    color = default_color(3);
    orig = arg1.graphics.orig ;
    w=1;
    xarc(orig(1)-w,orig(2)+w,2*w,2*w,0,360*64,color=color,background=color)
   case 'getinputs' then
    graphics = arg1.graphics ;
    orig = graphics.orig;
    x = orig(1)
    y = orig(2)
    typ =3*ones_deprecated(x)
   case 'getoutputs' then
    graphics=arg1.graphics;orig=graphics.orig;
    x=[1 1]*orig(1)
    y=[1 1]*orig(2)
    typ=3*ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()         ;
    model.sim       = 'bussplit'   ;
    model.in        = -1         ;
    model.out       = [-1;-1;-1] ;
    model.blocktype = 'c'        ;
    model.dep_ut    = [%t %f]    ;
    x=standard_define([1 1]/3,model,[],[],'BUSSPLIT');
    x.graphics.in_implicit='B'
    x.graphics.out_implicit=['B';'B';'B']
  end
endfunction
