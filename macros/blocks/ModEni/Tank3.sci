function [x,y,typ]=Tank3(job,arg1,arg2)
// Tank3 
  function blk_draw(sz,orig,orient,label)
    xrects([orig(1);orig(2)+6*sz(2)/10;sz(1);6*sz(2)/10],scs_color(2));
    xpoly(orig(1)+[0;0;10;10;0;0;10]*sz(1)/10,orig(2)+[6;0;0;10;10;6;6]*sz(2)/10);
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
  endfunction
  
  function [x,y,typ]=tank3_inputs(o)
  // input port positions
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
    else
      x1=orig(1)+sz(1)+dx;
    end
    y=[orig(2)+3*sz(2)/4,orig(2)+1*sz(2)/2,orig(2)+sz(2)/4]
    x=[x1,x1,x1];
    typ=[2 2 2]
  endfunction

  function [x,y,typ]=tank3_outputs(o)
  // output port positions
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    x=orig(1)+sz(1)/2;
    y=[orig(2)]
    typ=[1]
  endfunction
  
  function tank3_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[1]; face_in=[3,3,3];
      dx_out=[0];dy_out=[0]; dx_in=[dx,dx,dx];dy_in=[0,0,0];
    else 
      face_out=[1]; face_in=[2,2,2];
      dx_out=[0];dy_out=[0]; dx_in=[-dx,-dx,-dx];dy_in=[0,0,0];
    end
    scicos_draw_ports(o,tank3_inputs,face_in,dx_in,dy_in,tank3_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];

  select job
   case 'plot' then
    standard_draw(arg1,%f,tank3_draw_ports)
   case 'getinputs' then
    [x,y,typ]=tank3_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=tank3_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case "set" then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,initialHt,inHt1,inHt2,inHt3,Area,price,mass,LeadTime,exprs]=getvalue('Set Tank3 block parameter',..
						  ['initialHt [m]';'inHt1 [m]';'inHt2 [m]';'inHt3 [m]';'Area [m^2]';'price[k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[initialHt;inHt1;inHt2;inHt3;Area;price;mass;LeadTime]
      model.equations.parameters(2)=list(initialHt,inHt1,inHt2,inHt3,Area,price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    model=scicos_model()
    initialHt=0.0
    inHt1=0
    inHt2=0
    inHt3=0
    Area=1
    price=5
    mass=5
    LeadTime=5
    model.rpar=[initialHt;inHt1;inHt2;inHt3;Area;price;mass;LeadTime]
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroTank3'
    mo.inputs=['p','n','t']
    mo.outputs=['Ht']
    mo.parameters=list(['initialHt';'inHt1';'inHt2';'inHt3';'Area';'price';'mass';'LeadTime'],list(initialHt,inHt1,inHt2,Area,price,mass,LeadTime))
    model.equations=mo
    
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    
    exprs=[string(initialHt);string(inHt1);string(inHt2);string(inHt3);
	   string(Area);string(price);string(mass);string(LeadTime)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'Tank3');
    x.graphics.in_implicit=['I','I','I']
    x.graphics.out_implicit=['E']
  end
endfunction
