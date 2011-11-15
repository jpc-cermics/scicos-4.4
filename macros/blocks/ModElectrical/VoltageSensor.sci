function [x,y,typ]=VoltageSensor(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xarc(orig(1)+sz(1)*1/8,orig(2)+sz(2)*4.3/5,sz(1)*3/4,sz(2)*3/4,0,360*64);
    xsegs(orig(1)+sz(1)*[0 1/8],orig(2)+sz(2)*[1/2 1/2],style=0);
    xsegs(orig(1)+sz(1)*[7/8 1],orig(2)+sz(2)*[1/2 1/2],style=0);
    xsegs(orig(1)+sz(1)*[1.5/8 2.5/8],orig(2)+sz(2)*[1.3/2 1.2/2],style=0);
    xsegs(orig(1)+sz(1)*[2.5/8 3.2/8],orig(2)+sz(2)*[1.62/2 1.3/2],style=0);
    xsegs(orig(1)+sz(1)*[1/2 1/2],orig(2)+sz(2)*[4.25/5 1.3/2],style=0);
    xsegs(orig(1)+sz(1)*[4.9/8 5.5/8],orig(2)+sz(2)*[1.3/2 1.65/2],style=0);
    xsegs(orig(1)+sz(1)*[5.5/8 6.5/8],orig(2)+sz(2)*[1.2/2 1.32/2],style=0);
    xsegs(orig(1)+sz(1)*[1/2 4.5/8],orig(2)+sz(2)*[1/2 1.32/2],style=0) ;
    xsegs(orig(1)+sz(1)*[1/2 1/2],orig(2)+sz(2)*[0.9/8,0],style=0);
    xfarc(orig(1)+sz(1)*0.93/2,orig(2)+sz(2)*1/2,sz(1)*0.2/4,sz(2)*0.2/4,0,360*64);
    xx=orig(1)+sz(1)*4.2/8+[.9 1 0 .9]*sz(1)/12;
    yy=orig(2)+sz(2)*1.27/2+[0.1 1 0.3 0.1]*sz(2)/7;
    xfpoly(xx,yy);
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2)/5,"V",posx="center",posy="bottom");
  endfunction 

    function [x,y,typ]=sensor_outputs(o)
  // The outputs are to be defined here 
  // x and y are the translated input positions 
  // (x,y) is to be translated by (+-dx,0) or (0,+-dy) 
  // depending on the port position (west, 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
  // two outputs: first is implicit then explicit 
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    graphics=o.graphics
    orig=graphics.orig;sz=graphics.sz;
    if graphics.flip then
      x=orig(1)+sz(1)+dx;
    else
      x=orig(1)-dx;
    end
    y=[orig(2)+sz(2)/2,orig(2)- dy] 
    x=[x,orig(1)+sz(1)/2]
    typ=[2 1]
  endfunction
  
  
  function [x,y,typ]=sensor_inputs(o)
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
    x=[xo]
    y=[orig(2)+sz(2)/2]
    typ=[2]
  endfunction
  
  function sensor_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2,1]; face_in=[3];
      dx_out=[-dx,0];dy_out=[0,dy]; dx_in=[dx];dy_in=[0];
    else 
      face_out=[3,1]; face_in=[2];
      dx_out=[dx,0];dy_out=[0,dy]; dx_in=[-dx];dy_in=[0];
    end
    scicos_draw_ports(o,sensor_inputs,face_in,dx_in,dy_in,sensor_outputs,face_out,dx_out,dy_out);
  endfunction
    
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,sensor_draw_ports) 
   case 'getinputs' then
    [x,y,typ]=sensor_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=sensor_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.in=1;model.out=[1; 1];
    model.sim='VoltageSensor'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='VoltageSensor'
    mo.inputs='p';
    mo.outputs=['n';'v']
    model.equations=mo
    exprs=[]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'VoltageSensor');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I';'E']
  end
endfunction

