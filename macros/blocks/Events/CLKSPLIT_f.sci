function [x,y,typ] = CLKSPLIT_f(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[],typ=[];
  select job
   case 'plot' then
    color = default_color(-1);
    orig = arg1.graphics.orig ;
    w=1;
    xarc(orig(1)-w,orig(2)+w,2*w,2*w,0,360*64,color=color,background=color)
   case 'getinputs' then
    orig = arg1.graphics.orig;
    x = orig(1)
    y = orig(2)
    typ = -ones_deprecated(x)
   case 'getoutputs' then
    orig=arg1.graphics.orig;
    x=[1,1]*orig(1)
    y=[1,1]*orig(2)
    typ=-ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.sim='split'
    model.evtin=1
    model.evtout=[1;1]
    model.blocktype='d'
    model.firing=[%f,%f,%f] //????
    model.dep_ut=[%f %f]
    x = standard_define([1 1]/3,model,[],[],'CLKSPLIT_f');
  end
endfunction
