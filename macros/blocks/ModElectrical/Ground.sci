function [x,y,typ]=Ground(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xsegs(orig(1)+sz(1)*[1/2 1/2],orig(2)+sz(2)*[1 1/2],style=0);
    xsegs(orig(1)+sz(1)*[0 1],orig(2)+sz(2)*[1/2 1/2],style=0);
    xsegs(orig(1)+sz(1)*[2/8 6/8],orig(2)+sz(2)*[1/4 1/4],style=0);
    xsegs(orig(1)+sz(1)*[3/8 5/8],orig(2)+sz(2)*[0 0],style=0);
  endfunction 

  function [x,y,typ]=ground_inputs(o)
  // The inputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // one implicit input up 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    x=orig(1)+(sz(1)/2)
    y=orig(2)+sz(2)+dy
    typ=2
  endfunction
  
  function [x,y,typ]=ground_outputs(o)
    x=[],y=[],typ=[];
  endfunction

  function ground_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    face_out=[]; face_in=[0];
    dx_out=-[];dy_out=[]; dx_in=[0];dy_in=[-dy];
    scicos_draw_ports(o,ground_inputs,face_in,dx_in,dy_in,ground_outputs,face_out,dx_out,dy_out);
  endfunction
  
  
  function xxground_draw_ports(o)
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    in= 0.8*[ -1  -1
	      1  -1
	      1   1
	      -1   1]*diag([xf/14,yf/7])  
    xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1)/2),..
	   in(:,2)+ones(4,1)*(orig(2)+sz(2)+yf/14),1)
  endfunction 
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,ground_draw_ports)
   case 'getinputs' then
    [x,y,typ]=ground_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=ground_outputs(arg1)
   case 'getoutputs' then
    x=[];y=[],typ=[]
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.in=[1];
    model.out=[];
    model.sim='Ground'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='Ground'
    mo.inputs='p';
    model.equations=mo
    exprs=''
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1 1],model,exprs,list(gr_i,0),'Ground');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']
  end
endfunction

