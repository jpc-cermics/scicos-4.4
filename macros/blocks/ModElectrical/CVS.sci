function [x,y,typ]=CVS(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica CVS.mo model
//   - avec un dialogue de saisie de parametre
    
  function blk_draw(sz,orig,orient,label)
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9,thickness=2);
    if orient then 
      x=[orig(1)+3*sz(1)/4,orig(1)+3*sz(1)/4];
      y=[orig(2)+sz(2)/4+sz(2)/10,orig(2)+(3/4)*sz(2)-sz(2)/10];
      //xarrows(x,y,style=xget('color','red'),arsize=sz(2)/10);
      xstringb(orig(1)+sz(1)/2,orig(2)+(1/4)*sz(2),['+';'-'],sz(1)/2,sz(2)/2,'fill');
      xrect([orig(1)+sz(1)/2;orig(2)+(3/4)*sz(2);sz(1)/2;sz(2)/2],color=0,thickness=2);
      x=[orig(1)+(3/4)*sz(1),orig(1)+(3/4)*sz(1)];
      xsegs(x,[orig(2),orig(2)+(1/4)*sz(2)]);
      xsegs(x,[orig(2)+(3/4)*sz(2),orig(2)+sz(2)]);
      x=[orig(1),orig(1)+sz(1)/2];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xarrows(x,y,arsize=sz(1)/5);
      xstring(orig(1),orig(2)+(3/4)*sz(2),"CVS")
    else
      x=[orig(1)+sz(1)/4,orig(1)+sz(1)/4];
      y=[orig(2)+sz(2)/4+sz(2)/10,orig(2)+(3/4)*sz(2)-sz(2)/10];
      //xarrows(x,y,style=xget('color','red'),arsize=sz(2)/10);
      xstringb(orig(1),orig(2)+(1/4)*sz(2),['+';'-'],sz(1)/2,sz(2)/2,'fill');
      xrect([orig(1);orig(2)+(3/4)*sz(2);sz(1)/2;sz(2)/2],color=0,thickness=2);
      x=[orig(1)+(1/4)*sz(1),orig(1)+(1/4)*sz(1)];
      xsegs(x,[orig(2),orig(2)+(1/4)*sz(2)]);
      xsegs(x,[orig(2)+(3/4)*sz(2),orig(2)+sz(2)]);
      x=[orig(1)+sz(1),orig(1)+sz(1)/2];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xarrows(x,y,arsize=sz(1)/5);
      xstring(orig(1)+sz(1)/2,orig(2)+(3/4)*sz(2),"CVS")
    end
  endfunction

  function [x,y,typ]=CVS_inputs(o)
  // two inputs one explicit one implicit 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
      x2=orig(1)+(3/4)*sz(1);
    else
      x1=orig(1)+sz(1)+dx 
      x2=orig(1)+(1/4)*sz(1);
    end
    y=[orig(2)+sz(2)/2,orig(2)+sz(2)+dy]
    x=[x1,x2]
    typ=[1 2]
  endfunction
  
  function [x,y,typ]=CVS_outputs(o)
  // one output implicit 
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+(3/4)*sz(1);
    else
      x2=orig(1)+(1/4)*sz(1);
    end
    y=[orig(2)-dy]
    x=[x2]
    typ=[2]
  endfunction

  function CVS_draw_ports(o)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    nin=size(o.model.in,1);
    inporttype=o.graphics.in_implicit
    nout=size(o.model.out,1);
    outporttype=o.graphics.out_implicit
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    // port orientation 2 in and one out 
    if orient then 
      select_face_out=[1]; select_face_in=[3,0];
      xdelta_out=-[0];ydelta_out=[+dy]; xdelta_in=[dx,0];ydelta_in=[0,-dy];
    else 
      select_face_out=[1]; select_face_in=[2,0];
      xdelta_out=[0];ydelta_out=[+dy]; xdelta_in=[-dx,0];ydelta_in=[0,-dy];
    end
    [x,y,typ]=CVS_outputs(o)
    // standard orientation or tilded orientation
    // select the shape to use square or triangle.
    port_type=4;// implicit out 
    for k=1:nout
      scicos_lock_draw([x(k)+xdelta_out(k),y(k)+ydelta_out(k)],xf,yf,select_face_out(k),port_type);
    end
    [x,y,typ]=CVS_inputs(o);
    port_type=[0,5]// one implicit and one standard 
    for k=1:nin
      scicos_lock_draw([x(k)+xdelta_in(k),y(k)+ydelta_in(k)],xf,yf,select_face_in(k),port_type(k));
    end
  endfunction 


  function xblk_draw(sz,orig,orient,label)
    if orient then  
      xpolys(orig(1)+[0.7142857,0.7142857,0.3714286,0.0571429,0.3714286; ...
		      0.7142857,0.7142857,0.4285714,0.4142857,0.4285714]*sz(1),...
	     orig(2)+[0.7,0,0.54,0.5,0.46;0.98,0.3,0.5,0.5,0.5]*sz(2),[2,2,6,6,6])  
      xstring(orig(1)+0.1428571*sz(1),orig(2)+0.75*sz(2),"CVS") 
      xrects([orig(1)+0.4285714*sz(1); orig(2)+0.7*sz(2);0.5714286*sz(1);0.4*sz(2)],0);
      xstring(orig(1)+0.7*sz(1),orig(2)+0.55*sz(2),"+")
      xstring(orig(1)+0.7*sz(1),orig(2)+0.35*sz(2),"-")
    else  
      xpolys(orig(1)+[0.2857143,0.2857143,0.6285714,0.9428571,0.6285714; ...
		      0.2857143,0.2857143,0.5714286,0.5857143,0.5714286]*sz(1),...
	     orig(2)+[0.7,0,0.54,0.5,0.46;0.98,0.3,0.5,0.5,0.5]*sz(2),[2,2, ...
		    6,6,6])
      xstring(orig(1)+0.6*sz(1),orig(2)+0.75*sz(2),"CVS") 
      xrects([orig(1)+0*sz(1); orig(2)+0.7*sz(2);0.5714286*sz(1);0.4* ...
	      sz(2)],0)
      xstring(orig(1)+sz(1)-(0.7*sz(1)),orig(2)+0.55*sz(2),"+")
      xstring(orig(1)+sz(1)-(0.7*sz(1)),orig(2)+0.35*sz(2),"-")
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,CVS_draw_ports)
   case 'getinputs' then
    [x,y,typ]=CVS_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=CVS_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
   case 'define' then      
    ModelName="CVS"
    PrametersValue=[]
    ParametersName=[]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[2,50,1,0; 70,98,2,0;70,2,-2,0]

    PortName=["vin";"p";"n"]
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
    model.blocktype='c'                              
    model.dep_ut=[%f %t]                               
    mo.model=ModelName                                 
    model.equations=mo                                 
    model.in=ones(size(MI,'*'),1)                    
    model.out=ones(size(MO,'*'),1)                   
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2.1,3],model,exprs,list(gr_i,0) ,'CVS') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
