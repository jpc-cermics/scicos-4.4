function [x,y,typ]=Sine(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Sine.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    scicos_blk_draw_axes(sz,orig,orient,ipos=1,jpos=2,acol=13,fcol=13);
    x=linspace(-%pi,%pi,20); y=sin(x);
    scicos_blk_draw_curv(x=x,y=y,color=5)
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"sin",...
	    posx="center",posy="bottom",size=fz);
  endfunction


  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f)//,Sine_draw_ports)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,amplitude,freqHz,...
       phase,offset,startTime,exprs]=getvalue(["Set Sine block parameters:";
		    "";
		    "Amplitude: Amplitude of sine wave";
		    "FreqHz   : Frequency of sine wave";
		    "Phase    : Phase of sine wave";
		    "Offset   : Offset of output signal";
		    "StartTime: Output = offset for time < startTime"],...
					      ["amplitude";"freqHz";"phase";"offset";"startTime"],...
					      list("vec",1,"vec",1,"vec",1,"vec",1,"vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(amplitude,freqHz,phase,offset,startTime)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then
    ModelName="Sine"
    PrametersValue=[1;1;0;0;0]
    ParametersName=["amplitude";"freqHz";"phase";"offset";"startTime"]
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
    exprs=["1";"1";"0";"0";"0"]
    model.blocktype='c'
    model.dep_ut=[%f %t]
    mo.model=ModelName
    model.equations=mo
    model.in=ones(size(MI,'*'),1)
    model.out=ones(size(MO,'*'),1)
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,2],model,exprs,list(gr_i,0),'Sine');
    x.graphics.in_implicit=Typein;
    x.graphics.out_implicit=Typeout;
  end
endfunction
