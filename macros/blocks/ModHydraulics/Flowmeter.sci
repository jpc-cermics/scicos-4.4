function [x,y,typ]=Flowmeter(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica CapteurD.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    g=scs_color(15);
    xfarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],g);
    xarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],1);
    xpolys(orig(1)+[ .5, .01; .5,1.01]*sz(1),orig(2)+[ .4, .1; .1,.1]*sz(2),[1,1],thickness=2)  
    if orient then  
      xstring(orig(1)+0.01*sz(1),orig(2)+0.84*sz(2),"Q")
    else  
      xstring(orig(1)+sz(1)-(0.01*sz(1)),orig(2)+0.84*sz(2),"Q")
    end;
  endfunction
  
  function [x,y,typ]=Flowmeter_inputs(o)
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
  
  function [x,y,typ]=Flowmeter_outputs(o)
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+dy+sz(2),orig(2)+0.1*sz(2)];
    x=[orig(1)+sz(1)/2,x2]
    typ=[1 2]
  endfunction

  function Flowmeter_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[0,2]; face_in=[3];
      dx_out=[0,-dx];dy_out=[-dy,0]; dx_in=[dx];dy_in=[0];
    else 
      face_out=[0,3]; face_in=[2];
      dx_out=[0,dx];dy_out=[-dy,0]; dx_in=[-dx];dy_in=[0];
    end
    scicos_draw_ports(o,Flowmeter_inputs,face_in,dx_in,dy_in,...
		      Flowmeter_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,Flowmeter_draw_ports)
   case 'getinputs' then
    [x,y,typ]=Flowmeter_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=Flowmeter_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %f do
      [ok,Qini,exprs]=getvalue(["Set Flowmeter block parameters:";"";"Qini: "],"Qini",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(Qini)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Flowmeter"
    PrametersValue=1
    ParametersName="Qini"
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[50,105,-1,90;0,10,2,0;101,10,-2,0]
    PortName=["Mesure";"C1";"C2"]
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
    exprs="1"
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0) ,'Flowmeter') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
