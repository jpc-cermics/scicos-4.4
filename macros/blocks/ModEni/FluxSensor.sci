function [x,y,typ]=FluxSensor(job,arg1,arg2)
// FluxSensor block
  
  function blk_draw(sz,orig,orient,label)
  // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    g=scs_color(2);
    xfarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],g);
    xarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],1);
    xpolys(orig(1)+[ .5, .01; .5,1.01]*sz(1),orig(2)+[ .4, .1; .1,.1]*sz(2),[1,1],thickness=2)  
    if orient then  
      xstring(orig(1)+0.01*sz(1),orig(2)+0.84*sz(2),"Q")
    else  
      xstring(orig(1)+sz(1)-(0.01*sz(1)),orig(2)+0.84*sz(2),"Q")
    end;
  endfunction
  
  function [x,y,typ]=FSensor_inputs(o)
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1) -dx;
    else
      x1=orig(1)+sz(1)+dx 
    end
    y=[orig(2)+0.1*sz(2)];
    x=[x1];
    typ=[2]
  endfunction
  
  function [x,y,typ]=FSensor_outputs(o)
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+0.1*sz(2),orig(2)+dy+sz(2)];
    x=[x2,orig(1)+sz(1)/2]
    typ=[2 1];
  endfunction

  function FSensor_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2,0]; face_in=[3];
      dx_out=[-dx,0];dy_out=[0,-dy]; dx_in=[dx];dy_in=[0];
    else 
      face_out=[3,0]; face_in=[2];
      dx_out=[dx,0];dy_out=[0,-dy]; dx_in=[-dx];dy_in=[0];
    end
    scicos_draw_ports(o,FSensor_inputs,face_in,dx_in,dy_in,...
		      FSensor_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,FSensor_draw_ports)
   case 'getinputs' then
    [x,y,typ]=FSensor_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=FSensor_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case "set" then
    //messagebox('No settings for a FluxSensor block type');
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,price,mass,LeadTime,exprs]=getvalue('Set Flux Sensor block parameter',..
						     ['price [k€]';'mass [T]';'Lead Time [Day]'], ...
						     list('vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[price;mass;LeadTime]
      model.equations.parameters(2)=list(price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    //messagebox('haha')
    model=scicos_model()
    price=5
    mass=5
    LeadTime=5
    model.rpar=[price;mass;LeadTime]
    model.sim='Hydraulics'
    model.in=1;
    model.out=[1; 1];
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    mo=modelica()
    mo.model='HydroFluxSensor'
    mo.inputs='p';
    mo.outputs=['n';'q']
    mo.parameters=list(['price';'mass';'LeadTime'],list(price,mass,LeadTime))
    model.equations=mo
    
    exprs=[string(price);string(mass);string(LeadTime)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0) ,'FluxSensor');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I';'E']
  end
endfunction
