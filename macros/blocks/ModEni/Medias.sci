function [x,y,typ]=Medias(job,arg1,arg2)
// FluxSensor block
  
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
    //messagebox('No settings for a FluxSensor block type');
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    titles=['water density [kg/m^3]';
	    'water kinematic viscosity [m^2/s]';
	    'minimum volumetric flow [m^3/s]';
	    'gravity constant [m/s^2]';
	    'atmosphere pressure [kg/s^2/m]'];
    while %t do
      [ok,rho,nu,qmin,g,p0,exprs]=getvalue('Set Medias block parameter',titles,...
					   list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[rho;nu;qmin;g;p0]
      model.equations.parameters(2)=list(rho,nu,qmin,g,p0)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    //messagebox('haha')
    model=scicos_model()
    rho=1000
    nu=1.002e-6
    qmin=1e-6
    g=9.8
    p0=101350
    model.rpar=[rho;nu;qmin;g;p0]
    model.sim='Hydraulics'
    model.in=[];
    model.out=[];
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    mo=modelica()
    mo.model='HydroMedias'
    mo.inputs=[];
    mo.outputs=[];
    mo.parameters=list(['rho';'nu';'qmin';'g';'p0'],list(rho,nu,qmin,g,p0))
    model.equations=mo
    exprs=[string(rho);string(nu);string(qmin);string(g);string(p0)]
    gr_i=['txt=[''Medias''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    x=standard_define([2 2],model,exprs,gr_i,'Medias')
    x.graphics.in_implicit=[]
    x.graphics.out_implicit=[]
  end
endfunction
