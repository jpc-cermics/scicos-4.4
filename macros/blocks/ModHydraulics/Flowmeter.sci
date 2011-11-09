function [x,y,typ]=Flowmeter(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica CapteurD.mo model
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    g=scs_color(15);
    xfarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],15);
    xarcs([orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040],1);
    xpolys(orig(1)+[ .5, .01; .5,1.01]*sz(1),orig(2)+[ .4, .1; .1,.1]*sz(2),[1,1],thickness=2)  
    if orient then  
      xstring(orig(1)+0.01*sz(1),orig(2)+0.84*sz(2),"Q")
    else  
      xstring(orig(1)+sz(1)-(0.01*sz(1)),orig(2)+0.84*sz(2),"Q")
    end;
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
  endfunction
      
  function [x,y,typ]=Flowmeter_inputs(o)
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1) -dx;
    else
      x1=orig(1)+sz(1)+dx 
    end
    y=[orig(2)+0.1*sz(2)];
    x=[x1];
    typ=[2]
  endfunction
  
  function [x,y,typ]=Flowmeter_outputs(o)
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+0.1*sz(2),orig(2)+dy+sz(2)]
    x=[x2,orig(1)+sz(1)/2]
    typ=[2 1]
  endfunction
  
  function Flowmeter_draw_ports(o)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    nin=size(o.model.in,1);
    inporttype=o.graphics.in_implicit
    nout=size(o.model.out,1);
    outporttype=o.graphics.out_implicit
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    // port orientation 2 in and one out 
    if orient then 
      select_face_out=[2,0]; select_face_in=[3];
      xdelta_out=-[dx,0]; xdelta_in=[dx];ydelta_out=[0,-dy];
    else 
      select_face_out=[3,0]; select_face_in=[2];
      xdelta_out=[dx,0]; xdelta_in=[-dx];ydelta_out=[0,-dy];
    end
    [x,y,typ]=Flowmeter_outputs(o)
    //standard orientation or tilded orientation
    // select the shape to use square or triangle.
    port_type=[4,1];// implicit out and one standard  
    for k=1:nout
      scicos_lock_draw([x(k)+xdelta_out(k),y(k)+ydelta_out(k)],xf,yf,select_face_out(k),port_type(k));
    end
    [x,y,typ]=Flowmeter_inputs(o);
    port_type=[5]// one implicit
    for k=1:nin
      scicos_lock_draw([x(k)+xdelta_in(k),y(k)],xf,yf,select_face_in(k),port_type(k));
    end
  endfunction 
  
  
  function Flowmeter_draw_ports_old(o)
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    xset('pattern',default_color(0))
    // draw input/output ports
    //------------------------
    // [x_in_Icon,y_in_Icon,type(2=imp_in/-2:imp_out/1=exp_input/-1_exp_output),orientation(degree)]
    P=[50,105,-1,90;0,10,2,0;101,10,-2,0]
    // setting the input/ outputs and direction
    // implicit port: if it's located in the right it's output and while,
    // else black
    // explicit ports:
    
    in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
    out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
    in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
    out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
    
    xset('pattern',default_color(1))           
    xset('thickness',1)   
    
    if orient then
      for i=1:size(P,'r')      
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	
	if P(i,3)==1 then // explicit
	  inR=in*R;
	  xfpoly(orig(1)+inR(:,1)+P(i,1)*sz(1)/100,orig(2)+inR(:,2)+P(i,2)*sz(2)/100,1)      
	end
	
	if  P(i,3)==-1 then
	  outR=out*R;
	  xfpoly(orig(1)+outR(:,1)+P(i,1)*sz(1)/100,orig(2)+outR(:,2)+P(i,2)*sz(2)/100,1)      	  
	end  
	
	if P(i,3)==2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	  in2R=in2*R; 			
	  xfpoly(orig(1)+in2R(:,1)+P(i,1)*sz(1)/100,orig(2)+  in2R(:,2)+P(i,2)*sz(2)/100,1)	
	end
	
	if P(i,3)==-2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	  out2R=out2*R;
	  xpoly(orig(1)+out2R(:,1)+P(i,1)*sz(1)/100,orig(2)+  out2R(:,2)+P(i,2)*sz(2)/100, type='lines',close=%t)	
	end
      end  
    else
      for i=1:size(P,'r')     
	theta=P(i,4)*%pi/180;
	R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
	
	if P(i,3)==1 then // explicit
	  inR=in*R;
	  xfpoly(orig(1)+sz(1)-inR(:,1)-P(i,1)*sz(1)/100,orig(2)+inR(:,2)+P(i,2)*sz(2)/100,1)      
	end
	if P(i,3)==-1 then // explicit
	  outR=out*R;
	  xfpoly(orig(1)+sz(1)-outR(:,1)-P(i,1)*sz(1)/100,orig(2)+outR(:,2)+P(i,2)*sz(2)/100,1)      
	end
	
	if P(i,3)==2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	  in2R=in2*R; 			
          xfpoly(orig(1)+sz(1)-in2R(:,1)-P(i,1)*sz(1)/100,orig(2)+  in2R(:,2)+P(i,2)*sz(2)/100,1)	
	end
	if P(i,3)==-2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	  out2R=out2*R;
	  xpoly(orig(1)+sz(1)-out2R(:,1)-P(i,1)*sz(1)/100,orig(2)+  out2R(:,2)+P(i,2)*sz(2)/100, type='lines',close=%t)
	end
      end          
    end
  endfunction 

  
  
  function [x,y,typ]=Flowmeter_inputs_old(o)
  // input port positions
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    //[orig,sz,orient]=o(2)(1:3);
    inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);
    
    // [x_in_Icon,y_in_Icon,type(2=imp/1=exp_input/-1_exp_output),orientation(degree)]
    P=[50,105,-1,90;0,10,2,0;101,10,-2,0]
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
  function [x,y,typ]=Flowmeter_outputs_old(o)
  // Copyright INRIA
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    out=size(o.model.out,1);clkout=size(o.model.evtout,1);
    P=[50,105,-1,90;0,10,2,0;101,10,-2,0]
    
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
    standard_draw(arg1,%f,Flowmeter_draw_ports)
   case 'getinputs' then
    [x,y,typ]=Flowmeter_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=Flowmeter_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
    exprs=x.graphics.exprs
    while %f do
      [ok,Qini,exprs]=getvalue(["Set Flowmeter block parameters:";"";"Qini: "],"Qini",list("vec",1),exprs)
      if ~ok then break,end
      x.model.equations.parameters(2)=list(Qini)
      x.graphics.exprs=exprs
      break
    end
   case 'define' then      
    ModelName="Flowmeter"
    PrametersValue=1
    ParametersName="Qini"
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[50,105,-1,90;0,10,2,0;101,10,-2,0]
    PortName=["Mesure";"C1";"C2"]
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
    x=standard_define([2 2],model,exprs,list(gr_i,0) ,'Flowmeter') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
