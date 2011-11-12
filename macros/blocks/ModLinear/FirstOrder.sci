function [x,y,typ]=FirstOrder(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica FirstOrder.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=1,jpos=1,acol=13,fcol=13);
    x=[0.1;0.15;0.2;0.25;0.3;0.35;0.4;0.45;0.5;0.55;0.6;0.65;0.7;0.75; ...
       0.8;0.85;0.9];
    y=[0.1;0.27445;0.4021;0.4954565;0.56375;0.61375;0.6503;0.67705; ...
       0.69665;0.71095;0.72145;0.7291;0.7347;0.7388;0.7418;0.744;0.7456];
    scicos_blk_draw_curv(x=x,y=y,color=5);
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"PT1",...
	    posx="center",posy="bottom",size=fz);
  endfunction

  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)
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
      [ok,k,T,y_start,exprs]=getvalue(["Set FirstOrder block parameters:";
		    "";
		    "k      : Gain: TF(s)=K/(T*s+1)";
		    "T      : Time Constant";
		    "y_start: Initial or guess value of output (= state)"],...
				      ["k";"T";"y_start"],...
				      list("vec",1,"vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k,T,y_start)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="FirstOrder"
    PrametersValue=[1;1;0]
    ParametersName=["k";"T";"y_start"]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[-5,50,2,0;105,50,-2,0]
    PortName=["u";"y"]
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
    exprs=["1";"1";"0"]
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,2],model,exprs,list(gr_i,0) ,'FirstOrder') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
