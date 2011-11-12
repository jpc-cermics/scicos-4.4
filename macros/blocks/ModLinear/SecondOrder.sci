function [x,y,typ]=SecondOrder(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica SecondOrder.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=1,jpos=1,acol=13,fcol=13);
    xs=[0.1;0.14;0.18;0.22;0.26;0.3;0.34;0.38;0.42;0.46;0.5; ...
	0.54;0.58;0.62;0.66;0.7;0.74;0.78;0.82;0.86;0.9];
    ys=[0.1;0.15735;0.3025;0.48739;0.66375;0.794;0.85755;...
	0.85245;0.79225;0.7003;0.60275;0.522295;0.473645;0.461855;...
	0.48286;0.52605;0.5778;0.62515;0.6583;0.6725;0.66805];
    scicos_blk_draw_curv(x=xs,y=ys,color=5)
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"PT2",...
	    posx="center",posy="bottom",size=fz);
  endfunction

  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,SecondOrder_draw_ports)
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
      [ok,k,w,D,y_start,yd_start,exprs]=getvalue(["Set SecondOrder block parameters:";"";"k       : Gain:  TF=K/( (s/w)^2+ 2*D*(s/w)+1 )";"w       : Angular frequency";"D       : Damping";"y_start : Initial or guess value of output (= state)";"yd_start: Initial or guess value of derivative"],["k";"w";"D";"y_start";"yd_start"],list("vec",1,"vec",1,"vec",1,"vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k,w,D,y_start,yd_start)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="SecondOrder"
    PrametersValue=[1;1;1;0;0]
    ParametersName=["k";"w";"D";"y_start";"yd_start"]
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
    exprs=["1";"1";"1";"0";"0"]
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1) 
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,2],model,exprs,list(gr_i,0)  ,'SecondOrder');
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
