function [x,y,typ]=CCS(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica CCS.mo model
//   - avec un dialogue de saisie de parametre
  
  function blk_draw(sz,orig,orient,label)
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9,thickness=2);
    if orient then 
      x=[orig(1)+3*sz(1)/4,orig(1)+3*sz(1)/4];
      y=[orig(2)+sz(2)/4+sz(2)/10,orig(2)+(3/4)*sz(2)-sz(2)/10];
      xarrows(x,y,style=xget('color','red'),arsize=sz(2)/10);
      xrect([orig(1)+sz(1)/2;orig(2)+(3/4)*sz(2);sz(1)/2;sz(2)/2],color=0,thickness=2);
      x=[orig(1)+(3/4)*sz(1),orig(1)+(3/4)*sz(1)];
      xsegs(x,[orig(2),orig(2)+(1/4)*sz(2)]);
      xsegs(x,[orig(2)+(3/4)*sz(2),orig(2)+sz(2)]);
      x=[orig(1),orig(1)+sz(1)/2];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xarrows(x,y,arsize=sz(1)/5);
      xstring(orig(1),orig(2)+(3/4)*sz(2),"CCS")
    else
      x=[orig(1)+sz(1)/4,orig(1)+sz(1)/4];
      y=[orig(2)+sz(2)/4+sz(2)/10,orig(2)+(3/4)*sz(2)-sz(2)/10];
      xarrows(x,y,style=xget('color','red'),arsize=sz(2)/10);
      xrect([orig(1);orig(2)+(3/4)*sz(2);sz(1)/2;sz(2)/2],color=0,thickness=2);
      x=[orig(1)+(1/4)*sz(1),orig(1)+(1/4)*sz(1)];
      xsegs(x,[orig(2),orig(2)+(1/4)*sz(2)]);
      xsegs(x,[orig(2)+(3/4)*sz(2),orig(2)+sz(2)]);
      x=[orig(1)+sz(1),orig(1)+sz(1)/2];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xarrows(x,y,arsize=sz(1)/5);
      xstring(orig(1)+sz(1)/2,orig(2)+(3/4)*sz(2),"CCS")
    end
  endfunction

  function [x,y,typ]=CCS_inputs(o)
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
  
  function [x,y,typ]=CCS_outputs(o)
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

  function CCS_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[1]; face_in=[3,0];
      dx_out=-[0];dy_out=[+dy]; dx_in=[dx,0];dy_in=[0,-dy];
    else 
      face_out=[1]; face_in=[2,0];
      dx_out=[0];dy_out=[+dy]; dx_in=[-dx,0];dy_in=[0,-dy];
    end
    scicos_draw_ports(o,CCS_inputs,face_in,dx_in,dy_in,CCS_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,CCS_draw_ports)
   case 'getinputs' then
    [x,y,typ]=CCS_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=CCS_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x=arg1
   case 'define' then      
    ModelName="CCS"
    PrametersValue=[]
    ParametersName=[]
    model=scicos_model()                  
    Typein=[];Typeout=[];MI=[];MO=[]       
    P=[2,50,1,0; 70,98,2,0;70,2,-2,0]

    PortName=["Iin";"n";"p"]

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
    x=standard_define([2.1,3],model,exprs,list(gr_i,0) ,'CCS') ;
    x.graphics.in_implicit=Typein;                     
    x.graphics.out_implicit=Typeout;                   
  end
endfunction
