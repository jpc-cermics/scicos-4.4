function [x,y,typ]=Limiter(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Limiter.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=2,jpos=2,acol=13,fcol=13);
    x=linspace(-5,5,20); y=min(max(x,-2),2);
    scicos_blk_draw_curv(x=x,y=y,color=5)
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"limiter",...
	    posx="center",posy="bottom",size=fz);
  endfunction

  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,Limiter_draw_ports)
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
      [ok,uMax,uMin,exprs]=getvalue(["Set Limiter block parameters:";"";"uMax: Upper limit";"uMin: Lower limit"],["uMax";"uMin"],list("vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(uMax,uMin)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Limiter"
    PrametersValue=[]
    ParametersName=["uMax";"uMin"]
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
    exprs=["1";"-1"]
    gr_i=["";"if orient then";"  xpolys(orig(1)+[0.5,0.05;0.5,0.84]*sz(1),orig(2)+[0.05,0.5;0.84,0.5]*sz(2),[3,3])";"  xset(''thickness'',2);";"  xpolys(orig(1)+[0.1;0.25;0.75;0.9]*sz(1),orig(2)+[0.15;0.15;0.85;0.85]*sz(2),5)";"  xset(''color'',2)";"  xfpolys(orig(1)+[0.96,0.5;0.85,0.46;0.85,0.54;0.96,0.5]*sz(1),orig(2)+[0.5,0.97;0.54,0.86;0.46,0.86;0.5,0.97]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[0;0;1;1;0]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"else";"  xpolys(orig(1)+[0.5,0.95;0.5,0.16]*sz(1),orig(2)+[0.05,0.5;0.84,0.5]*sz(2),[3,3])";"  xset(''thickness'',2);";"  xpolys(orig(1)+[0.9;0.75;0.25;0.1]*sz(1),orig(2)+[0.15;0.15;0.85;0.85]*sz(2),5)";"  xset(''color'',2)";"  xfpolys(orig(1)+[0.04,0.5;0.15,0.54;0.15,0.46;0.04,0.5]*sz(1),orig(2)+[0.5,0.97;0.54,0.86;0.46,0.86;0.5,0.97]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[1;1;0;0;1]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"end"]
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,2],model,exprs,list(gr_i,0) ,'Limiter') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
