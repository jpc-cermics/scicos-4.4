function [x,y,typ]=Constant(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Constant.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=1,jpos=1,acol=13,fcol=13);
    xf=60;yf=40;
    xof=xf/10;yof=yf/7;
    x=[orig(1)+xof,orig(1)+sz(1)-xof];
    y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
    xpoly(x,y,color=5);
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"constant",...
	    posx="center",posy="bottom",size=fz);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,Constant_draw_ports)
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
      [ok,k,exprs]=getvalue(["Set Constant block parameters:";"";"k: Constant output values"],"k",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Constant"
    PrametersValue=1
    ParametersName="k"
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[105,50,-2,0]
    PortName="RealOutputx"
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
    x=standard_define([2,1],model,exprs,list(gr_i,0) ,'Constant' );
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
