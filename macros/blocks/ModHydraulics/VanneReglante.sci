function [x,y,typ]=VanneReglante(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xfpolys(orig(1)+[0;5;7;3;5;10;10;0;0]*sz(1)/10,orig(2)+[4;2;7;7;2;0;4;0;4]*sz(2)/10,scs_color(15))
    xfarcs([orig(1)+3*sz(1)/10;orig(2)+sz(2);4*sz(1)/10;6*sz(2)/10;0;180*64],scs_color(15))
    xarcs([orig(1)+3*sz(1)/10;orig(2)+sz(2);4*sz(1)/10;6*sz(2)/10;0;180* ...
	   64],scs_color(1));
    // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
  endfunction 
  
  function [x,y,typ]=vanne_inputs(o)
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1) -dx;
    else
      x1=orig(1)+sz(1)+dx 
    end
    y=[orig(2)+2*sz(2)/10,orig(2)+dy+sz(2)]
    x=[x1,orig(1)+sz(1)/2]
    typ=[2 1]
  endfunction
  
  function [x,y,typ]=vanne_outputs(o)
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+2*sz(2)/10]
    x=[x2]
    typ=[2]
  endfunction
  
  function vanne_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2]; face_in=[3,0];
      dx_out=[-dx];dy_out=[0]; dx_in=[dx,0];dy_in=[0,-dy];
    else 
      face_out=[3]; face_in=[2,0];
      dx_out=[dx];dy_out=[0]; dx_in=[-dx,0];dy_in=[0,-dy];
    end
    scicos_draw_ports(o,vanne_inputs,face_in,dx_in,dy_in,vanne_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];

  select job
   case 'plot' then
    standard_draw(arg1,%f,vanne_draw_ports)
   case 'getinputs' then
    [x,y,typ]=vanne_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=vanne_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,Cvmax,p_rho,exprs]=getvalue('Paramètres de la vanne reglante',..
				      ['Cvmax';'p_rho'],..
				      list('vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      model.rpar=[Cvmax;p_rho]
      model.equations.parameters(2)=list(Cvmax,p_rho)
      //    model.equations.parameters=list([Cvmax;p_rho])
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    model=scicos_model()
    model.in=[1;1];
    model.out=[1];
    Cvmax=8005.42
    p_rho=0
    model.rpar=[Cvmax;p_rho]
    model.sim='VanneReglante'
    model.blocktype='c'
    model.dep_ut=[%t %f]

    mo=modelica()
    mo.model='VanneReglante'
    mo.inputs=['C1' 'Ouv'];
    mo.outputs='C2';
    mo.parameters=list(['Cvmax';'p_rho'],[Cvmax;p_rho])
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    exprs=[string(Cvmax);string(p_rho)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'VanneReglante');
    x.graphics.in_implicit=['I';'E']
    x.graphics.out_implicit=['I']
  end
endfunction

