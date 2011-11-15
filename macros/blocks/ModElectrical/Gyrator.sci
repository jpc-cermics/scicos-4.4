function [x,y,typ]=Gyrator(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Gyrator.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    if orient then  
      xrects([orig(1)+0.2*sz(1); orig(2)+1*sz(2);0.6*sz(1);1*sz(2)],0)  
      xpolys(orig(1)+[0.02,0.02,0.8,0.8,0.3,0.395;0.2,0.2,0.98,0.98,0.7, 0.595]*sz(1),...
	     orig(2)+[0.9166667,0.0833333,0.9166667,0.0833333,0.75,0.3166667;0.9166667,0.0833333,0.9166667,0.0833333,0.75,0.3166667]*sz(2),[2,2,2,2,2,2]); 
      xset("color",0)  
      xfpolys(orig(1)+[0.65,0.35;0.7,0.4;0.65,0.4;0.65,0.35]*sz(1),...
	      orig(2)+[0.7833333,0.3166667;0.75,0.35;0.7166667,0.2833333;0.7833333,0.3166667]*sz(2),[2,2])  
      xpolys(orig(1)+[0.48,0.515,0.46;0.47,0.505,0.535]*sz(1),...
	     orig(2)+ [0.5416667,0.5416667,0.5416667;0.4583333,0.4583333,0.5416667]*sz(2),[6,6,6])
    else  
      xrects([orig(1)+0.2*sz(1); orig(2)+1*sz(2);0.6*sz(1);1*sz(2)],0)  
      xpolys(orig(1)+[0.98,0.98,0.2,0.2,0.7,0.605;0.8,0.8,0.02,0.02,0.3,0.405]*sz(1),...
	     orig(2)+[0.9166667,0.0833333,0.9166667,0.0833333,0.75,0.3166667;0.9166667,0.0833333,0.9166667,0.0833333,0.75,0.3166667]*sz(2),[2,2,2,2,2,2])  
      xset("color",0)  
      xfpolys(orig(1)+[0.35,0.65;0.3,0.6;0.35,0.6;0.35,0.65]*sz(1), ...
	      orig(2)+[0.7833333,0.3166667;0.75,0.35;0.7166667,0.2833333;0.7833333,0.3166667]*sz(2),[2,2])  
      xpolys(orig(1)+[0.52,0.485,0.54;0.53,0.495,0.465]*sz(1),...
	     orig(2)+ [0.5416667,0.5416667,0.5416667;0.4583333,0.4583333,0.5416667]*sz(2),[6,6,6])
    end  
    xstring(orig(1)+0.35*sz(1),orig(2)+0.5*sz(2),"G1")  
    xstring(orig(1)+0.35*sz(1),orig(2)+0.0833333*sz(2),"G2");
  endfunction 
    
  function [x,y,typ]=Gyrator_inputs(o)
  // The inputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // 4 inputs impicit 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
      x1=orig(1)+sz(1)+dx;
    end
    y=[orig(2)+sz(2)-dy/2,orig(2)+dy/2,orig(2)+sz(2)-dy/2,orig(2)+dy/2]
    x=[x1,x1,x2,x2];
    typ=[2 2 2 2];
  endfunction
  
  function [x,y,typ]=Gyrator_outputs(o)
  // The outputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // one output implicit 
    x=[],y=[],typ=[];
  endfunction
  
  function Gyrator_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[]; face_in=[3,3,2,2];
      dx_out=[];dy_out=[]; dx_in=[dx,dx,-dx,-dx];dy_in=[0,0,0,0];
    else 
      face_out=[1]; face_in=[2,2,3,3];
      dx_out=[];dy_out=[]; dx_in=[-dx,-dx,dx,dx];dy_in=[0,0,0,0];
    end
    scicos_draw_ports(o,Gyrator_inputs,face_in,dx_in,dy_in,Gyrator_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,Gyrator_draw_ports)
   case 'getinputs' then
    [x,y,typ]=Gyrator_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=Gyrator_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %t do
      [ok,G1,G2,exprs]=getvalue(["Set Gyrator block parameters:";"";"G1: Gyration conductance";"G2: Gyration conductance"],["G1";"G2"],list("vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(G1,G2)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Gyrator"
    PrametersValue=[1;1]
    ParametersName=["G1";"G2"]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[2.5,90,2,0;2.5,10,2,0;97.5,90,2,0;97.5,10,2,0]
    PortName=["p1";"n1";"p2";"n2"]
    for i=1:size(P,'r')                                             
      if P(i,3)==1  then  Typein= [Typein; 'E'];MI=[MI;PortName(i)];end
      if P(i,3)==2  then  Typein= [Typein; 'I'];MI=[MI;PortName(i)];end
      if P(i,3)==-1 then  Typeout=[Typeout;'E'];MO=[MO;PortName(i)];end
      if P(i,3)==-2 then  Typeout=[Typeout;'I'];MO=[MO;PortName(i)];end
    end
    model=scicos_model()
    mo=modelica()
    model.sim=ModelName;
    mo.inputs=MI;
    mo.outputs=MO;
    model.rpar=PrametersValue;
    mo.parameters=list(ParametersName,PrametersValue,zeros_deprecated(ParametersName));
    exprs=["1";"1"]

    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([3,1.8],model,exprs,list(gr_i,0) ,'Gyrator') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
