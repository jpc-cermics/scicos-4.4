function [x,y,typ]=HGround(job,arg1,arg2)
// Ground implicit block

  x=[];y=[];typ=[];
  select job
   case "plot" then
    standard_draw(arg1,%f)
   case "getinputs" then
    [x,y,typ]=standard_inputs(arg1)
   case "getoutputs" then
    [x,y,typ]=standard_outputs(arg1)
   case "getorigin" then
    [x,y]=standard_origin(arg1)
   case "set" then
    x=arg1;
   case "define" then
    model=scicos_model()
    model.in=[1];
    model.out=[];
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroGround'
    mo.inputs='p'
    model.equations=mo
    exprs=''
    gr_i=['txt=[''P=0''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    x=standard_define([1 1],model,exprs,gr_i,'HGround')
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=[]
  end
endfunction
