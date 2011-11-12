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

    gr_i=["txt=""sin"";";
	  "rectstr=stringbox(txt,orig(1),orig(2)+0.2*sz(2),0,1,1);";
	  "if ~exists(""%zoom"") then %zoom=1, end;";
	  "w=(rectstr(1,3)-rectstr(1,2))*%zoom*0.5;";
	  "h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
	  ""
	  "xpolys(orig(1)+[0;0;1;1;0]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";
	  ""
	  "if orient then";
	  "  xpolys(orig(1)+[0.1,0.05;0.1,0.91]*sz(1),orig(2)+[0.89,0.5;0.05,0.5]*sz(2),[3,3])";
	  "  xpolys(orig(1)+[0.1;0.1565;0.1925;0.2245;0.253;0.281;0.309;0.337;0.3655;0.3935;0.4255;0.46585;0.5505;0.5865;0.6185;0.6465;0.675;0.703;0.731;0.7595;0.7875;0.8195;0.86;0.9]*sz(1),"+...
	  "orig(2)+[0.5;0.671;0.7655;0.832;0.873;0.8955;0.899;0.883;0.8485;0.797;0.7205;0.606;0.346;0.249;0.179;0.1345;0.108;0.1;0.112;0.1425;0.1905;0.264;0.376;0.5]*sz(2),5)";
	  "  xset(''color'',12);";
	  "  xset(''thickness'',2);";
	  "  xset(''color'',2)";
	  "  xfpolys(orig(1)+[0.1,0.97;0.06,0.86;0.14,0.86;0.1,0.97]*sz(1),orig(2)+[0.97,0.1+0.4;0.86,0.14+0.4;0.86,0.06+0.4;0.97,0.1+0.4]*sz(2),[1,1])";
	  "else";
	  "  xpolys(orig(1)+[0.9,0.95;0.9,0.09]*sz(1),orig(2)+[0.89,0.5;0.05,0.5]*sz(2),[3,3])";
	  "  xpolys(orig(1)+[0.9;0.8435;0.8075;0.7755;0.747;0.719;0.691;0.663;0.6345;0.6065;0.5745;0.53415;0.4495;0.4135;0.3815;0.3535;0.325;0.297;0.269;0.2405;0.2125;0.1805;0.14;0.1]*sz(1),"+...
	  "orig(2)+[0.5;0.671;0.7655;0.832;0.873;0.8955;0.899;0.883;0.8485;0.797;0.7205;0.606;0.346;0.249;0.179;0.1345;0.108;0.1;0.112;0.1425;0.1905;0.264;0.376;0.5]*sz(2),5)";
	  "  xset(''color'',12);";
	  "  xset(''thickness'',2);";
	  "  xset(''color'',2)";
	  "  xfpolys(orig(1)+[0.9,0.03;0.94,0.14;0.86,0.14;0.9,0.03]*sz(1),orig(2)+[0.97,0.1+0.4;0.86,0.14+0.4;0.86,0.06+0.4;0.97,0.1+0.4]*sz(2),[1,1])";
	  "end"
	  "xset(''thickness'',1);"]
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
