function [x,y,typ]=AtanTF(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica AtanTF.mo model
//   - avec un dialogue de saisie de parametre
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1,%f,AtanTF_draw_ports)
case 'getinputs' then
  [x,y,typ]=AtanTF_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=AtanTF_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;
  x=arg1
case 'define' then
  ModelName="AtanTF"
  PrametersValue=[]
  ParametersName=[]
  model=scicos_model()
  Typein=[];Typeout=[];MI=[];MO=[]
  P=[-5,50,2,0;105,50,2,0]
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
exprs=[]
gr_i=["xpolys(orig(1)+[0.5,0.05;0.5,0.91]*sz(1),orig(2)+[0.89,0.5;0.05,0.5]*sz(2),[3,3])";
      "xpolys(orig(1)+[1;1;0;0;1]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";
      ""
      "txt=""atan"";";
      "rectstr=stringbox(txt,orig(1),orig(2),0,1,1);";
      "if ~exists(""%zoom"") then %zoom=1, end;";
      "w=(rectstr(1,3)-rectstr(1,2))*%zoom*0.5;";
      "h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
      ""
      "if orient then";
      "  xstringb(orig(1)+0.05*sz(1),orig(2)+0.6*sz(2),txt,w,h,""fill"");";
      "  xpolys(orig(1)+[0.1;0.2365;0.313;0.3655;0.4015;0.4295;0.4495;0.46985;0.49395;0.52615;0.54625;0.5665;0.5905;0.6225;0.667;0.735;0.8475;0.9]*sz(1),"+...
        "orig(2)+[0.1;0.124;0.1515;0.185;0.224;0.271;0.318;0.3805;0.4747;0.605;0.6705;0.721;0.7645;0.804;0.838;0.868;0.893;0.9]*sz(2),5)";"  xset(''color'',12);";
      "  xset(''thickness'',2);";
      "  xset(''color'',2);";
      "  a=0.4;"
      "  xfpolys(orig(1)+[0.1+a,0.97;0.06+a,0.86;0.14+a,0.86;0.1+a,0.97]*sz(1),orig(2)+[0.97,0.1+a;0.86,0.14+a;0.86,0.06+a;0.97,0.1+a]*sz(2),[1,1])";
      "else";
      "  xstringb(orig(1)+0.55*sz(1),orig(2)+0.6*sz(2),txt,w,h,""fill"");";
      "  xpolys(orig(1)+[0.9;0.7635;0.687;0.6345;0.5985;0.5705;0.5505;0.53015;0.50605;0.47385;0.45375;0.4335;0.4095;0.3775;0.333;0.265;0.1525;0.1]*sz(1),"+...
        "orig(2)+[0.1;0.124;0.1515;0.185;0.224;0.271;0.318;0.3805;0.4747;0.605;0.6705;0.721;0.7645;0.804;0.838;0.868;0.893;0.9]*sz(2),5)";
      "  xset(''color'',12);";
      "  xset(''thickness'',2);";
      "  xset(''color'',2);";
      "  a=0.4;"
      "  xfpolys(orig(1)+[0.9-a,0.03;0.94-a,0.14;0.86-a,0.14;0.9-a,0.03]*sz(1),orig(2)+[0.97,0.1+a;0.86,0.14+a;0.86,0.06+a;0.97,0.1+a]*sz(2),[1,1])";
      "end"
      "xset(''thickness'',1);"]
model.blocktype='c'
model.dep_ut=[%f %t]
mo.model=ModelName
model.equations=mo
model.in=ones(size(MI,'*'),1)
model.out=ones(size(MO,'*'),1)
x=standard_define([2,2],model,exprs,list(gr_i,0),'AtanTF');
x.graphics.in_implicit=Typein;
x.graphics.out_implicit=Typeout;
end
endfunction
//=========================
function AtanTF_draw_ports(o)
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0))
  // draw input/output ports
  //------------------------
  // [x_in_Icon,y_in_Icon,type(2=imp_in/-2:imp_out/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,-2,0]

  //============================
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
//=========================
function [x,y,typ]=AtanTF_inputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  //[orig,sz,orient]=o(2)(1:3);
  inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);
  
  // [x_in_Icon,y_in_Icon,type(2=imp/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,-2,0]
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
function [x,y,typ]=AtanTF_outputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  out=size(o.model.out,1);clkout=size(o.model.evtout,1);
  P=[-5,50,2,0;105,50,-2,0]
 
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
