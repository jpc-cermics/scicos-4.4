function [x,y,typ]=Gain(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Gain.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    if length(arg1.graphics.exprs(1))>6 then
      gain=part(arg1.graphics.exprs(1),1:4)+'..'
    else 
      gain=arg1.graphics.exprs(1);
    end
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1/4
    end
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' && ~isempty(gr_i(2)) then
      coli=gr_i(2);
      xpoly(xx',yy',color=xget('color','blue'),fill_color=coli);
    else
      xpoly(xx,yy,type='lines',color=xget('color','blue'));
    end
    xstringb(orig(1)+x1*sz(1),orig(2),gain,(1-x1)*sz(1),sz(2));
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,Gain_draw_ports)
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
      [ok,k,exprs]=getvalue(["Set Gain block parameters:";"";"k: Gain"],"k",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Gain"
    PrametersValue=[]
    ParametersName="k"
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
    exprs="1"
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,2],model,exprs,list(gr_i,0) ,'Gain' );
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
