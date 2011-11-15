function [x,y,typ]=PNP(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica PNP.mo model
//   - avec un dialogue de saisie de parametre
//=========================

  function blk_draw(sz,orig,orient,label)

    if orient then  
      xpolys(orig(1)+[0.45,0.45,1,0.65,0.45,0.65;0.45,0.005,0.65,0.45,0.65, ...
		      0.995]*sz(1),orig(2)+[0.8333333,0.5,0.9166667,0.9166667,0.4166667,0.0833333;0.1666667,0.5,0.9166667,0.5833333,0.0833333,0.0833333]*sz(2),[1,1,1,1,1,1])  
      xset('color',0)  
      xfpolys(orig(1)+[0.45;0.525;0.485;0.45]*sz(1),orig(2)+[0.4166667; ...
		    0.3583333;0.2916667;0.4166667]*sz(2),2)
    else  
      xpolys(orig(1)+[0.55,0.55,0,0.35,0.55,0.35;0.55,0.995,0.35,0.55,0.35, ...
		      0.005]*sz(1),orig(2)+[0.8333333,0.5,0.9166667, ...
		    0.9166667,0.4166667,0.0833333;0.1666667,0.5,0.9166667,0.5833333,0.0833333,0.0833333]*sz(2),[1,1,1,1,1,1])  
      xset('color',0)  
      xfpolys(orig(1)+[0.55;0.475;0.515;0.55]*sz(1),orig(2)+[0.4166667; ...
		    0.3583333;0.2916667;0.4166667]*sz(2),2)
    end
  endfunction 

  function [x,y,typ]=PNP_inputs(o)
  // The inputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // two inputs one explicit one implicit 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
    else
      x1=orig(1)+sz(1)+dx 
    end
    y=[orig(2)+sz(2)/2];
    x=[x1]
    typ=[2]
  endfunction
  
  function [x,y,typ]=PNP_outputs(o)
  // The outputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // one output implicit 
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+sz(2)-dy/2,orig(2)+dy/2]
    x=[x2,x2]
    typ=[2,2]
  endfunction
  
  function PNP_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[3,3]; face_in=[3];
      dx_out=-[0,0];dy_out=[0,0]; dx_in=[dx];dy_in=[0];
    else 
      face_out=[2,2]; face_in=[2];
      dx_out=[0,0];dy_out=[0,0]; dx_in=[-dx];dy_in=[0];
    end
    scicos_draw_ports(o,PNP_inputs,face_in,dx_in,dy_in,PNP_outputs,face_out,dx_out,dy_out);
  endfunction
    
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,PNP_draw_ports)
   case 'getinputs' then
    [x,y,typ]=PNP_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=PNP_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %t do
      [ok,Bf,Br,Is,Vak,Tauf,Taur,Ccs,Cje,Cjc,Phie,Me,Phic,Mc,Gbc,Gbe,Vt,EMinMax,exprs]=getvalue(["Set PNP block parameters:";""],["Bf  : Forward beta";"Br  : Reverse beta";"Is  : Transport saturation current";"Vak : Early voltage (inverse), 1/Volt";"Tauf: Ideal forward transit time";"Taur: Ideal reverse transit time";"Ccs : Collector-substrat(ground) cap.";"Cje : Base-emitter zero bias depletion cap.";"Cjc : Base-coll. zero bias depletion cap.";"Phie: Base-emitter diffusion voltage";"Me  : Base-emitter gradation exponent";"Phic: Base-collector diffusion voltage";"Mc  : Base-collector gradation exponent";"Gbc : Base-collector conductance";"Gbe : Base-emitter conductance";"Vt  : Voltage equivalent of temperature";"EMinMax: if x > EMinMax, the exp(x) function is linearized"],list("vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(Bf,Br,Is,Vak,Tauf,Taur,Ccs,Cje,Cjc,Phie,Me,Phic,Mc,Gbc,Gbe,Vt,EMinMax)
      x.graphics.exprs=exprs
      break
    end
    
   case 'define' then      
    ModelName="PNP"
    PrametersValue=[50;0.1;0;0.02;1.200D-10;5.000D-09;1.000D-12;4.000D-13;5.000D-13;0.8;0.4;0.8;0.333;1.000D-15;1.000D-15;0.02585;40]
    ParametersName=["Bf";"Br";"Is";"Vak";"Tauf";"Taur";"Ccs";"Cje";"Cjc";"Phie";"Me";"Phic";"Mc";"Gbc";"Gbe";"Vt";"EMinMax"]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[100,90,-2,0;0,50,2,0;100,10,-2,0]
    PortName=["C";"B";"E"]
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
    exprs=["50";"0.1";"1.e-16";"0.02";"0.12e-9";"5e-9";"1e-12";"0.4e-12";"0.5e-12";"0.8";"0.4";"0.8";"0.333";"1e-15";"1e-15";"0.02585";"40"]
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,1.2],model,exprs,list(gr_i,0),'PNP') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
