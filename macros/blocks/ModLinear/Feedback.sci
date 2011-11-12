function [x,y,typ]=Feedback(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Feedback.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    xf=60;yf=40;
    if orient then  
      // an horizontal arrow 
      xarc([orig(1)+0.4*sz(1); orig(2)+0.6*sz(2);0.2*sz(1);0.2*sz(2);0;23040],color=2);
      xpolys(orig(1)+[0,0.6,0.5,0.28,0.23,0.6;0.4,1,0.5,0.28,0.33,0.7]*sz(1),...
	     orig(2)+[0.5,0.5,0.4,0.74,0.69,0.22;0.5,0.5,0,0.64,0.69, 0.22]*sz(2), [3,3,3,3,3,3]);
      xfpolys(orig(1)+[0.39,0.5,0.85;0.28,0.46,0.74;0.28,0.54,0.74;0.39, 0.5,0.85]*sz(1),...
	      orig(2)+[0.5,0.39,0.5;0.54,0.28,0.54;0.46,0.28,0.46;0.5,0.39,0.5]*sz(2),[1,1,1])  
      xpolys(orig(1)+[0.53;0.44;0.52;0.45;0.54]*sz(1),orig(2)+[0.56;0.56; 0.5;0.44;0.44]*sz(2),3)
    else
      xarc([orig(1)+0.4*sz(1); orig(2)+0.6*sz(2);0.2*sz(1);0.2*sz(2);0;23040],color=2)
      xpolys(orig(1)+[1,0.4,0.5,0.72,0.77,0.4;0.6,0,0.5,0.72,0.67,0.3]*sz(1),...
	     orig(2)+[0.5,0.5,0.4,0.74,0.69,0.22;0.5,0.5,0,0.64,0.69,0.22]*sz(2),[3,3,3,3,3,3])  
      xfpolys(orig(1)+[0.61,0.5,0.15;0.72,0.54,0.26;0.72,0.46,0.26;0.61, 0.5,0.15]*sz(1),...
	      orig(2)+[0.5,0.39,0.5;0.54,0.28,0.54;0.46,0.28,0.46;0.5,0.39,0.5]*sz(2),[1,1,1])  
      xpolys(orig(1)+[0.47;0.56;0.48;0.55;0.46]*sz(1),orig(2)+[0.56;0.56;0.5;0.44;0.44]*sz(2),3);
    end
  endfunction
  
  function Feedback_draw_ports(o)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    nin=size(o.model.in,1);
    inporttype=o.graphics.in_implicit
    nout=size(o.model.out,1);
    outporttype=o.graphics.out_implicit
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    // port orientation 2 in and one out 
    if orient then 
      select_face_out=[2]; select_face_in=[3,0];
      xdelta_out=-[dx]; xdelta_in=[dx,0];ydelta_in=[0,-dy];
    else 
      select_face_out=[3]; select_face_in=[2,0];
      xdelta_out=[dx]; xdelta_in=[-dx,0];ydelta_in=[0,-dy];
    end
    [x,y,typ]=Feedback_outputs(o)
    // standard orientation or tilded orientation
    // select the shape to use square or triangle.
    port_type=4;// implicit out 
    for k=1:nout
      scicos_lock_draw([x(k)+xdelta_out(k),y(k)],xf,yf,select_face_out(k),port_type);
    end
    [x,y,typ]=Feedback_inputs(o);
    port_type=[5,5]// one implicit and one standard 
    for k=1:nin
      scicos_lock_draw([x(k)+xdelta_in(k),y(k)+ydelta_in(k)],xf,yf,select_face_in(k),port_type(k));
    end
  endfunction 
    
  function [x,y,typ]=Feedback_inputs(o)
  // input port positions 2 inputs 
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
    else
      x1=orig(1)+sz(1)+dx;
    end
    y=[orig(2)+sz(2)/2,orig(2)]
    x=[x1, orig(1)+sz(1)/2];
    typ=[2 2]
  endfunction
  
  function [x,y,typ]=Feedback_outputs(o)
  // output port positions 1 output 
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1) +dx;
    else
      x2=orig(1) -dx;
    end
    y=[orig(2)+sz(2)/2];
    x=[x2];
    typ=[2]
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f, Feedback_draw_ports)
   case 'getinputs' then
    [x,y,typ]=Feedback_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=Feedback_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %t do
      [ok,n,exprs]=getvalue(["Set Feedback block parameters:";"";"n: size of input and feedback signal"],"n",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(n)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Feedback"
    PrametersValue=1
    ParametersName="n"
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[0,50,2,0;50,0,2,90;105,51,-2,0]
    PortName=["RealInput1";"RealInput2";"RealOutputx"]
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
    x=standard_define([2,2],model,exprs,list(gr_i,0) ,'Feedback' );
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
