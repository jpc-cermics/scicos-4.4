function [x,y,typ]=DERIV(job,arg1,arg2)
// Copyright INRIA
  
  function blk_draw(sz,orig,orient,label)
    xstringb(orig(1),orig(2)," du/dt   ",sz(1),sz(2),"fill");
    txt="s";
    if ~exists("%zoom") then %zoom=1, end;
    fz=2*%zoom*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
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
   case 'define' then
    model=scicos_model()
    model.sim=list('deriv',4)
    model.in=-1
    model.out=-1
    model.blocktype='x'
    model.dep_ut=[%t %t]
    
    exprs=[]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'DERIV');
  end 
endfunction

