function [x,y,typ]=Bache(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xrects([orig(1);orig(2)+6*sz(2)/10;sz(1);6*sz(2)/10],scs_color(15));
    xpoly(orig(1)+[0;0;10;10;0;0;10]*sz(1)/10,orig(2)+[6;0;0;10;10;6;6]*sz(2)/10);
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
  endfunction
  
  function [x,y,typ]=bache_inputs(o)
  // input port positions
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1)-dx;
    else
      x1=orig(1)+sz(1)+dx;
    end
    y=[orig(2)+8*sz(2)/10 ,orig(2)+2*sz(2)/10]
    x=[x1,x1];
    typ=[2 2]
  endfunction

  function [x,y,typ]=bache_outputs(o)
  // output port positions
    xf=60;yf=40;dx=xf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1) +dx;
    else
      x2=orig(1) -dx;
    end
    y=[orig(2)+8*sz(2)/10 ,orig(2)+2*sz(2)/10 ,orig(2)+6*sz(2)/10]
    x=[x2,x2,x2];
    typ=[2 2 1]
  endfunction

  function bache_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
  // NORTH->(0,dy) SOUTH=(0,-dy), SLD_EAST=(-dx,0), WEST=(0,dx)
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2,2,2]; face_in=[3,3];
      dx_out=[-dx,-dx,-dx];dy_out=[0,0,0]; dx_in=[dx,dx];dy_in=[0,0];
    else 
      face_out=[3,3,3]; face_in=[2,2];
      dx_out=[dx,dx,dx];dy_out=[0,0,0]; dx_in=[-dx,-dx];dy_in=[0,0];
    end
    scicos_draw_ports(o,bache_inputs,face_in,dx_in,dy_in,bache_outputs,face_out,dx_out,dy_out);
  endfunction
  
  x=[];y=[];typ=[];

  select job
   case 'plot' then
    standard_draw(arg1,%f,bache_draw_ports)
   case 'getinputs' then
    [x,y,typ]=bache_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=bache_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,Patm,A,ze1,ze2,zs1,zs2,z0,T0,p_rho,exprs]=getvalue('Thermal-hydraulic tank parameters', ..
						  ['Atmospheric pressure inside the tank: Patm (Pa)';..
		    'Surface area of the tank: A (m2)';..
		    'Altitude of the first input port: ze1 (m)';..
		    'Altitude of the second input port: ze2 (m)';..
		    'Altitude of the first output port: zs1 (m)';..
		    'Altitude of the second output port: zs2 (m)';..
		    'Initial fluid level in the tank: z0 (m)';..
		    'Temperature of fluid in the tank: T0 (K)';..
		    'Density of fluid: p_rho (kg/m3)'],..
						  list('vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1),exprs)

      if ~ok then break,end
      model.rpar=[Patm;A;ze1;ze2;zs1;zs2;z0;T0;p_rho]
      model.equations.parameters(2)=list(Patm,A,ze1,ze2,zs1,zs2,z0,T0,p_rho)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    in=2
    out=3
    model=scicos_model()
    model.in=[-(1:in)'];
    model.out=[-(1:out)'];
    Patm=1.013E5
    A=1
    ze1=40
    ze2=0
    zs1=40
    zs2=0
    z0=30
    T0=290
    p_rho=0
    model.rpar=[Patm;A;ze1;ze2;zs1;zs2;z0;T0;p_rho]
    model.sim='Bache'
    model.blocktype='c'
    model.dep_ut=[%t %f]

    mo=modelica()
    mo.model='Bache'
    mo.inputs=['Ce1' 'Ce2'];
    mo.outputs=['Cs1' 'Cs2' 'yNiveau'];
    mo.parameters=list(['Patm';'A';'ze1';'ze2';'zs1';'zs2';'z0';'T0';'p_rho'],[Patm;A;ze1;ze2;zs1;zs2;z0;T0;p_rho])
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    exprs=[string(Patm);string(A);string(ze1);string(ze2);string(zs1); ...
	   string(zs2);string(z0);string(T0);string(p_rho)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'Bache');
    x.graphics.in_implicit=['I';'I']
    x.graphics.out_implicit=['I';'I';'E']
  end
endfunction

