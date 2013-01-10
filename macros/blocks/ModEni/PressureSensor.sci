function [x,y,typ]=PressureSensor(job,arg1,arg2)
  
  function blk_draw(sz,orig,orient,label)
  // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    g=scs_color(2);
    xfarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],g);
    xarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],1);
    xpolys(orig(1)+[ .5, .01; .5,1.01]*sz(1),orig(2)+[ .4, .1; .1,.1]*sz(2),[1,1],thickness=2)  
    if orient then  
      xstring(orig(1)+0.01*sz(1),orig(2)+0.84*sz(2),"Pr")
    else  
      xstring(orig(1)+sz(1)-(0.01*sz(1)),orig(2)+0.84*sz(2),"Pr")
    end;
  endfunction
  
  function [x,y,typ]=PSensor_inputs(o)
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
  
  function [x,y,typ]=PSensor_outputs(o)
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

  function PSensor_draw_ports(o)
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
    scicos_draw_ports(o,PSensor_inputs,face_in,dx_in,dy_in,...
		      PSensor_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,PSensor_draw_ports)
   case 'getinputs' then
    [x,y,typ]=PSensor_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=PSensor_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case "set" then
    // messagebox("No settings for a PressureSensor block type");
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,IsPa,price,mass,LeadTime,exprs]=getvalue('Set Pressure Sensor block parameter',..
						  ['choose the unity [Pa(1) atm(0)]';'price [k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[IsPa;price;mass;LeadTime]
      model.equations.parameters(2)=list(IsPa,price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
    
   case "define" then
    model=scicos_model()
    IsPa=1
    price=5
    mass=5
    LeadTime=5
    model.rpar=[IsPa;price;mass;LeadTime]
    model.sim='Hydraulics'
    model.in=1;
    model.out=[1; 1];
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    mo=modelica()
    mo.model='HydroPressureSensor'
    mo.inputs='p';
    mo.outputs=['n';'dpression_conv']
    mo.parameters=list(['IsPa';'price';'mass';'LeadTime'],list(IsPa,price,mass,LeadTime))
    model.equations=mo
    
    exprs=[string(IsPa);string(price);string(mass);string(LeadTime)]
    gr_i=['txt=[''Pressure Sensor''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    x=standard_define([2 2],model,exprs,gr_i,'PressureSensor');
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0) ,'PressureSensor');
    
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I';'E']
  end
endfunction
