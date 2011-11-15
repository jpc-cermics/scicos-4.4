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
  // The inputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
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
  // The outputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // one output implicit 
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
    scicos_draw_ports(o,CVS_inputs,face_in,dx_in,dy_in,CVS_outputs,face_out,dx_out,dy_out);
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



function scicos_draw_ports(o,finputs,face_in,dx_in,dy_in,foutputs,face_out,dx_out,dy_out)
// function used to draw ports with non standard location 
// the port translated positions are given by calling the 
// block input/output functions 
// 
  xxx=0;
    // this part is copied verbatim 
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    nin=size(o.model.in,1);
    inporttype=o.graphics.in_implicit
    nout=size(o.model.out,1);
    outporttype=o.graphics.out_implicit
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    // Outputs 
    [x,y,typ]=foutputs(o)
    // port_type: the shape to use triangle(in:0, out:1) or square(in: 5,out:4 )
    port_type= ones_new(1,nout);
    if ~isempty(inporttype) then  port_type(outporttype == 'I')=4;end 
    // colors to be used 
    colors= 0*ones_new(1,nout);
    if ~isempty(outporttype) then colors(outporttype=='B')=default_color(3);end;
    for k=1:nout
      scicos_lock_draw([x(k)+dx_out(k),y(k)+dy_out(k)],xf,yf,...
		       face_out(k),port_type(k),color=colors(k)+xxx);
    end
    // Inputs 
    [x,y,typ]=finputs(o);
    port_type=[0,5]
    // detect between implicit and standard ports i.e rectangles or triangles 
    port_type= 0*ones_new(1,nin);
    if ~isempty(inporttype) then  port_type( inporttype == 'I')=5;end 
    // colors to be used 
    colors= 0*ones_new(1,nin);
    if ~isempty(inporttype) then colors(inporttype=='B')=default_color(3);end;
    for k=1:nin
      scicos_lock_draw([x(k)+dx_in(k),y(k)+dy_in(k)],xf,yf,...
		       face_in(k),port_type(k),color=colors(k)+xxx);
    end
endfunction 
