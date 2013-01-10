function [x,y,typ]=VolumeFlow(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
  // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    g=scs_color(2);
    //orig=[0;0],sz=[2,2];
    c1=[orig(1)+ .2*sz(1); orig(2)+1*sz(2); .6*sz(1); .6*sz(2);0;23040];
    xarc(c1,thickness=3,color=1);
    c2=[orig(1)+ (0.4)*sz(1); orig(2)+(1-0.2)*sz(2); 0.3*sz(1); 0.3*sz(2);0;23040];
    xarc(c2,thickness=1,color=1,background=1);
    center2=[c2(1)+c2(3)/2;c2(2)-c2(4)/2];r2=c2(3)/2;
    center1=[c1(1)+c1(3)/2;c1(2)-c1(4)/2];r1=c1(3)/2;
    for i=linspace(0,2*%pi,10)
      v= linspace(r2,4*r1,50);
      xs=center2(1)+v*cos(i);
      ys=center2(2)+v*sin(i);
      I=find((xs-center1(1)).*(xs-center1(1))+(ys-center1(2)).*(ys-center1(2)) <= r1^2);
      xpoly([xs(1),xs(I($))],[ys(1),ys(I($))],color=g,thickness=1);
    end
    //
    xpolys(orig(1)+[0,0.8;0.2,1]*sz(1),orig(2)+[0.7,0.7;0.7,0.7]* sz(2),[1,1],thickness=2)  
    if orient then  
      xstring(orig(1)+0.01*sz(1),orig(2)+0.84*sz(2),"Q")
    else  
      xstring(orig(1)+sz(1)-(0.01*sz(1)),orig(2)+0.84*sz(2),"Q")
    end;
    xa=[orig(1)+sz(1)/9,orig(1)+8*sz(1)/9];
    if ~orient then
      xa=xa(2:-1:1);
    end
    xarrows(xa,[orig(2)+2*sz(2)/10,orig(2)+2*sz(2)/10],...
	    style=xget('color','blue'),arsize=2*sz(2)/10);
  endfunction
  
  function [x,y,typ]=VFlow_inputs(o)
    xf=60; yf=40; dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x1=orig(1) -dx;
    else
      x1=orig(1)+sz(1)+dx 
    end
    y=[orig(2)+0.7*sz(2),orig(2)+dy+sz(2)];
    x=[x1,orig(1)+sz(1)/2];
    typ=[2 1]
  endfunction
  
  function [x,y,typ]=VFlow_outputs(o)
  // Copyright INRIA
    xf=60;yf=40;  dx=xf/7; dy=yf/7;
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    if orient then
      x2=orig(1)+sz(1)+dx;
    else
      x2=orig(1)-dx;
    end
    y=[orig(2)+0.7*sz(2)];
    x=[x2]
    typ=[2];
  endfunction

  function VFlow_draw_ports(o)
  // function used to draw ports with non standard location 
  // the port translated positions are given by calling the 
  // block input/output functions 
    xf=60;yf=40;dx=xf/7; dy=yf/7;
    if o.graphics.flip then 
      face_out=[2]; face_in=[3,0];
      dx_out=[-dx];dy_out=[0]; dx_in=[dx,0];dy_in=[0,-dy];
    else 
      face_out=[3]; face_in=[2,0];
      dx_out=[dx];dy_out=[0]; dx_in=[-dx,0];dy_in=[0,-dy];
    end
    scicos_draw_ports(o,VFlow_inputs,face_in,dx_in,dy_in,...
		      VFlow_outputs,face_out,dx_out,dy_out);
  endfunction

  x=[];y=[];typ=[];
  select job  
   case 'plot' then
    standard_draw(arg1,%f,VFlow_draw_ports)
   case 'getinputs' then
    [x,y,typ]=VFlow_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=VFlow_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case "set" then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,price,mass,LeadTime,exprs]=getvalue('Set VolumeFlow block parameter',..
					      ['price [k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[price;mass;LeadTime]
      model.equations.parameters(2)=list(price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    model=scicos_model()
    price=5
    mass=5
    LeadTime=5
    model.rpar=[price;mass;LeadTime]
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroVolumeFlow'
    mo.inputs=['p','userq'];
    mo.outputs='n';
    mo.parameters=list(['price';'mass';'LeadTime'],list(price,mass,LeadTime))
    model.equations=mo
    
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    
    exprs=[string(price);string(mass);string(LeadTime)]
    // exprs=[string(qmax);string(K);string(timemax)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'VolumeFlow')
    x.graphics.in_implicit=['I','E']
    x.graphics.out_implicit=['I']
  end
endfunction
