function [x,y,typ]=Actuator(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica Actuator.sci.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    if orient then 
      x=[0,0,0.80];y=[0,1,1/2]
      xpoly(orig(1)+x*sz(1),orig(2)+y*sz(2),color=3,close=%t,thickness= 2);
      x=0.8/3+x/3;y=1/3+ y/3;
      xfpoly(orig(1)+x*sz(1),orig(2)+y*sz(2),color=1,fill_color=5,thickness=1);
      xpoly(orig(1)+[0.8;1]*sz(1),orig(2)+[0.5;0.5]*sz(2),color=3,thickness=2)  
    else 
      x=[0.2,1,1];y=[1/2,1,0]
      xpoly(orig(1)+x*sz(1),orig(2)+y*sz(2),color=3,close=%t,thickness= 2);
      x=0.2+0.8/3+x/3;y=1/3+ y/3;
      xfpoly(orig(1)+x*sz(1),orig(2)+y*sz(2),color=1,fill_color=5,thickness=1);
      xpoly(orig(1)+[0.0;0.2]*sz(1),orig(2)+[0.5;0.5]*sz(2),color=3,thickness=2)  
    end
    fz=1.5*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),"actuator",posx="center",posy= ...
	    "bottom",size=fz);
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=4);
  endfunction

  
  function [x,y,typ]=Actuator_inputs(o)
  // Copyright INRIA
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    //[orig,sz,orient]=o(2)(1:3);
    inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);
    
    // [x_in_Icon,y_in_Icon,type(2=imp/1=exp_input/-1_exp_output),orientation(degree)]
    P=[-5,50,1,0;105,50,-2,0]

    in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
    out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
    in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
    out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
    
    x=[];y=[];typ=[]
    if orient then
      for i=1:size(P,'r')   
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	if (P(i,3))==1 then // explicit_input
	  inR=in($,:)*R;
	  x=[x,orig(1)+inR(:,1)+P(i,1)*sz(1)/100];
	  y=[y,orig(2)+inR(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,1];
	end
	if(P(i,3)==2) then  // implicit
	  in2R=in2($,:)*R; 
	  x=[x,orig(1)+in2R(:,1)+P(i,1)*sz(1)/100];// Black
	  y=[y,orig(2)+in2R(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,2];
	end
      end      
    else
      for i=1:size(P,'r')     
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	if (P(i,3))==1 then // explicit_input
	  inR=in($,:)*R;
	  x=[x,orig(1)+sz(1)-inR(:,1)-P(i,1)*sz(1)/100];
	  y=[y,orig(2)+inR(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,1];
	end
	if(P(i,3)==2) then  // implicit
	  in2R=in2($,:)*R; 
	  x=[x,orig(1)+sz(1)-in2R(:,1)-P(i,1)*sz(1)/100];
	  y=[y,orig(2)+in2R(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,2];
	end
      end            
    end
    
    
  endfunction
  //=========================
  function [x,y,typ]=Actuator_outputs(o)
  // Copyright INRIA
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    out=size(o.model.out,1);clkout=size(o.model.evtout,1);
    P=[-5,50,1,0;105,50,-2,0]

    in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
    out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
    in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
    out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
    
    x=[];y=[];typ=[];
    if orient then
      for i=1:size(P,'r')     
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	if (P(i,3))==-1 then // explicit_output
	  outR=out($,:)*R;
	  x=[x,orig(1)+outR(:,1)+P(i,1)*sz(1)/100];
	  y=[y,orig(2)+outR(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,1];
	end 
	if(P(i,3)==-2) then  // implicit
	  out2R=out2($,:)*R;
	  x=[x,orig(1)+out2R(:,1)+P(i,1)*sz(1)/100];
	  y=[y,orig(2)+out2R(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,2];		
	end	      
      end      
    else
      for i=1:size(P,'r')     
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	if (P(i,3))==-1 then // explicit_output
	  outR=out($,:)*R;
	  x=[x,orig(1)+sz(1)-outR(:,1)-P(i,1)*sz(1)/100];
	  y=[y,orig(2)+outR(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,1];
	end
	if(P(i,3)==-2) then  // implicit
	  out2R=out2($,:)*R;
	  x=[x,orig(1)+sz(1)-out2R(:,1)-P(i,1)*sz(1)/100];
	  y=[y,orig(2)+out2R(:,2)+P(i,2)*sz(2)/100];
	  typ=[typ,2];
	end
      end            
    end
    
  endfunction

  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f);
   case 'getinputs' then
    [x,y,typ]=Actuator_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=Actuator_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %t do
      [ok,k,exprs]=getvalue(["Set Actuator block parameters:";"";"k: Gain"],"k",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(k)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Actuator"
    PrametersValue=1
    ParametersName="k"
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[-5,50,1,0;105,50,-2,0]
    PortName=["Signal";"RealOutputx"]
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
    model.in=ones(size(MI,'*'),1);                  
    model.out=ones(size(MO,'*'),1);     
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1,1],model,exprs,list(gr_i,0) ,'Actuator') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
