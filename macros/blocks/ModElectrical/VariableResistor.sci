function [x,y,typ]=VariableResistor(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xx=[0,1,1,7,7,8,7,7,1,1]/8;
    yy=[1,1,0,0,1,1,1,2,2,1]/2;
    xpoly(orig(1)+xx*sz(1),orig(2)+yy*sz(2));
  endfunction 

  function [x,y,typ]=VR_inputs(o)
  // The inputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // two inputs one implicit and one explicit
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    graphics=o.graphics
    orig=graphics.orig;sz=graphics.sz;
    if graphics.flip then
      xo=orig(1)-dx;
    else
      xo=orig(1)+sz(1)+dx;
    end
    x=[xo,orig(1)+(sz(1)/2)]
    y=[orig(2)+sz(2)/2,orig(2)+sz(2)+dy]
    typ=[2 1]
  endfunction

  function [x,y,typ]=VR_outputs(o)
  // The outputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // one output implicit 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    graphics=o.graphics
    orig=graphics.orig;sz=graphics.sz;
    if graphics.flip then
      x=orig(1)+sz(1)+dx;
    else
      x=orig(1)-dx;
    end
    y=orig(2)+sz(2)/2;
    typ=[2]
  endfunction
  
  function VR_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2]; face_in=[3,0];
      dx_out=-[dx];dy_out=[0]; dx_in=[dx,0];dy_in=[0,-dy];
    else 
      face_out=[3]; face_in=[2,0];
      dx_out=[dx];dy_out=[0]; dx_in=[-dx,0];dy_in=[0,-dy];
    end
    scicos_draw_ports(o,VR_inputs,face_in,dx_in,dy_in,VR_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    R=arg1.graphics.exprs;
    standard_draw(arg1,%f,VR_draw_ports)
   case 'getinputs' then
    [x,y,typ]=VR_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=VR_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.sim='VariableResistor'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='VariableResistor'
    mo.inputs=['p','R'];
    mo.outputs='n';
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    exprs=[]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 0.18],model,exprs,list(gr_i,0),'VariableResistor');
    x.graphics.in_implicit=['I','E']
    x.graphics.out_implicit=['I']
  end
endfunction
