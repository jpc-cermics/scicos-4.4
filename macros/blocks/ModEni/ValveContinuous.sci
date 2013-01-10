function [x,y,typ]=ValveContinuous(job,arg1,arg2)
// Fan implicit block

  function blk_draw(sz,orig,orient,label)
    xfpolys(orig(1)+[0;5;7;3;5;10;10;0;0]*sz(1)/10,orig(2)+[4;2;7;7;2;0;4;0;4]*sz(2)/10,scs_color(8))
    xfarcs([orig(1)+3*sz(1)/10;orig(2)+sz(2);4*sz(1)/10;6*sz(2)/10;0;180*64],scs_color(2))
    xarcs([orig(1)+3*sz(1)/10;orig(2)+sz(2);4*sz(1)/10;6*sz(2)/10;0;180* ...
	   64],scs_color(1));
    xstringb(orig(1),orig(2)+sz(2)/2,"C.",sz(1)/3,sz(2)/3,"fill")
    //xa=[orig(1)+sz(1)/9,orig(1)+8*sz(1)/9];
    // if ~orient then
    //   xa=xa(2:-1:1);
    // end
    // xarrows(xa,[orig(2)+2*sz(2)/10,orig(2)+2*sz(2)/10],...
    // 	    style=xget('color','blue'),arsize=2*sz(2)/10);
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
   case "plot" then
    standard_draw(arg1,%f,vanne_draw_ports)
   case 'getinputs' then
    [x,y,typ]=vanne_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=vanne_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case "set" then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,kvs,price,mass,LeadTime,exprs]=getvalue('Set Valve Continuous block parameter',..
						  ['kvs la vanne est tout ouverte [1]';'price [k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[kvs;price;mass;LeadTime]
      model.equations.parameters(2)=list(kvs,price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    model=scicos_model()
    kvs=1
    price=5
    mass=5
    LeadTime=5
    model.rpar=[kvs;price;mass;LeadTime]
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroValveContinuous'
    mo.inputs=['p';'x']
    mo.outputs=['n']//;'confinedx']
    mo.parameters=list(['kvs';'price';'mass';'LeadTime'],list(kvs,price,mass,LeadTime))
    model.equations=mo
    
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    
    exprs=[string(kvs);string(price);string(mass);string(LeadTime)]
    // exprs=[string(qmax);string(K);string(timemax)]
    
    gr_i=['txt=[''Valve Continuous''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,list(gr_i,0),'ValveContinuous');
        
    x.graphics.in_implicit=['I','E']
    x.graphics.out_implicit=['I']//,'E']
  end
endfunction
