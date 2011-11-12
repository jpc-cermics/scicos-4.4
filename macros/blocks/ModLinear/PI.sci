function [x,y,typ]=PI(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica PI.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=1,jpos=1,acol=13,fcol=13);
    if orient then 
      x=[0,0,3];  y=[0,1,4];
    else
      x=[0,3-0.1,3];  y=[0,1,4];
    end
    scicos_blk_draw_curv(x=x,y=y,color=5)
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"PI",...
	    posx="center",posy="bottom",size=fz);
  endfunction


  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,PI_draw_ports)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %t do
      [ok,k,T,exprs]=getvalue(["Set PI block parameters:";"";"k: Gain";"T: Time Constant (s)"],["k";"T"],list("vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k,T)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="PI"
    PrametersValue=[]
    ParametersName=["k";"T"]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[-5,50,2,0;105,50,-2,0]
    PortName=["RealInputx";"RealOutputx"]
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
    x=standard_define([2,2],model,exprs,list(gr_i,0) ,'PI') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
