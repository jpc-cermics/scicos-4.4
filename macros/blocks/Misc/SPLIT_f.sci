function [x,y,typ] = SPLIT_f(job,arg1,arg2)
  // Copyright INRIA
  x=[];y=[],typ=[];
  select job
   case 'plot' then
    color = default_color(1);
    orig = arg1.graphics.orig ;
    w=1;
    xarc(orig(1)-w,orig(2)+w,2*w,2*w,0,360*64,color=color,background=color)
   case 'getinputs' then
    graphics = arg1.graphics ;
    orig = graphics.orig;
    x = orig(1)
    y = orig(2)
    typ = ones_deprecated(x)
   case 'getoutputs' then
    graphics=arg1.graphics;orig=graphics.orig;nout=size(arg1.graphics.pout,'*')
    x=ones(1,nout)*orig(1)
    y=ones(1,nout)*orig(2)
    typ=ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()         ;
    model.sim       = 'lsplit'   ;
    model.in        = -1         ;
    model.out       = [-1;-1;-1] ;
    model.blocktype = 'c'        ;
    model.dep_ut    = [%t %f]    ;
    x=standard_define([1 1]/3,model,[],[],'SPLIT_f');
  end
endfunction
