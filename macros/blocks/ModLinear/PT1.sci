function [x,y,typ]=PT1(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica PT1.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    col=xget('color');xset('color',2);  
    xstringb(orig(1),orig(2),['   k   ';' T*s+1 '],sz(1),sz(2),'fill');
    xpoly([orig(1)+.1*sz(1),orig(1)+.9*sz(1)],[1,1]*(orig(2)+sz(2)/2)),
    xset('color',col);
    xrect([orig(1)+0*sz(1); orig(2)+1*sz(2);1*sz(1);1*sz(2)],color=13);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f);
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
      [ok,k,Ti,exprs]=getvalue(["Set PT1 block parameters:";"";"k : Gain";"Ti: Constante de temps (s)"],["k";"Ti"],list("vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k,Ti)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="PT1"
    PrametersValue=[1;1]
    ParametersName=["k";"Ti"]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[-5,50,2,0;105,50,-2,0;-5,10,2,0]
    PortName=["u";"y";"u0"]
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
    x=standard_define([2,2],model,exprs,list(gr_i,0),'PT1');
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
