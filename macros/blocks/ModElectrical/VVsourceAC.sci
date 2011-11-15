function [x,y,typ]=VVsourceAC(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xarc(orig(1)+sz(1)*1/8,orig(2)+sz(2)*4.3/5,sz(1)*3/4,sz(2)*3/4,0,360*64);
    xsegs(orig(1)+sz(1)*[0 1/8],orig(2)+sz(2)*[1/2 1/2],style=0);
    xsegs(orig(1)+sz(1)*[7/8 1],orig(2)+sz(2)*[1/2 1/2],style=0);
    xsegs(orig(1)+(sz(1)/2)*[1 1],orig(2)+sz(2)*[7/8, 1],style=0);
    V=string(model.rpar(1));
    xstringb(orig(1),orig(2)+sz(2)*0.2,"~",sz(1),sz(2)*0.3,"fill")
    xstringb(orig(1),orig(2)+sz(2)*0.5,V,sz(1),sz(2)*0.3,"fill");
  endfunction 
  
  function [x,y,typ]=VVac_inputs(o)
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

  function [x,y,typ]=VVac_outputs(o)
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
  
  function VVac_draw_ports(o)
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
    scicos_draw_ports(o,VVac_inputs,face_in,dx_in,dy_in,VVac_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1,%f,VVac_draw_ports)
   case 'getinputs' then
    [x,y,typ]=VVac_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=VVac_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,FR,exprs]=getvalue('Set voltage source parameter',..
			     ['Frequency (Hz)'],..
			     list('vec',-1),exprs)
      if ~ok then break,end
      model.rpar=[FR]
      model.equations.parameters(2)=list(FR)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    model=scicos_model()
    model.in=[1;1];
    model.out=[1];
    VA=220
    FR=50
    model.rpar=[FR]
    model.sim='VVsourceAC'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='VVsourceAC'
    mo.inputs=['p','VA'];
    mo.outputs='n';
    mo.parameters=list(['f'],list(FR))
    model.equations=mo
    
    exprs=[string(FR)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'VVsourceAC');
    x.graphics.in_implicit=['I','E']
    x.graphics.out_implicit=['I']
  end
endfunction
