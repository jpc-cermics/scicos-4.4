function [x,y,typ]=Bache(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xrects([orig(1);orig(2)+6*sz(2)/10;sz(1);6*sz(2)/10],scs_color(15));
    xpoly(orig(1)+[0;0;10;10;0;0;10]*sz(1)/10,orig(2)+[6;0;0;10;10;6;6]*sz(2)/10);
  endfunction
  
  function [x,y,typ]=bache_inputs(o)
  // Copyright INRIA
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    //[orig,sz,orient]=o(2)(1:3);
    inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);

    if orient then
      x1=orig(1)
      dx1=-xf/7
      x2=orig(1)+sz(1)
      dx2=xf/7
    else
      x1=orig(1)+sz(1)
      dx1=yf/7
      x2=orig(1)
      dx2=-xf/7
    end

    //y=[orig(2)+sz(2)-(sz(2)/2) ,orig(2)+yf/7+sz(2)]
    y=[orig(2)+8*sz(2)/10 ,orig(2)+2*sz(2)/10]
    x=[(x1+dx1),(x1+dx1)]
    typ=[2 2]

  endfunction

  function [x,y,typ]=bache_outputs(o)
  // Copyright INRIA
    xf=60
    yf=40
    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    //[orig,sz,orient]=o(2)(1:3);
    out=size(o.model.out,1);clkout=size(o.model.evtout,1);
    if orient then
      x1=orig(1)
      dx1=-xf/7
      x2=orig(1)+sz(1)
      dx2=xf/7
    else
      x1=orig(1)+sz(1)
      dx1=yf/7
      x2=orig(1)
      dx2=-xf/7
    end
    y=[orig(2)+8*sz(2)/10 ,orig(2)+2*sz(2)/10 ,orig(2)+6*sz(2)/10]
    x=[(x2+dx2),(x2+dx2),(x2+dx2)]
    typ=[2 2 1]
  endfunction

  function bache_draw_ports(o)
    
    nin=size(o.model.in,1);

    inporttype=o.graphics.in_implicit
    //inporttype=ones(nin,1)
    //if size(o.model.in,2)>1 then inporttype=o.model.in(:,2),end
    //  
    nout=size(o.model.out,1);
    outporttype=o.graphics.out_implicit
    //outporttype=ones(nout,1)
    //if size(o.model.out,2)>1 then outporttype=o.model.out(:,2),end

    clkin=size(o.model.evtin,1);
    clkout=size(o.model.evtout,1);

    [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
    xset('pattern',default_color(0));
    // --------------------------------------
    if %f then 
      select_face=[3,2];
      select_face_out=select_face(orient+1);
      select_face_in=select_face((~orient)+1);
      [x,y,typ]=bache_outputs(o)
      //standard orientation or tilded orientation
      // select the shape to use. 
      outtype=ones_new(1,nout);
      if ~isempty(outporttype) then  outtype( outporttype == 'I')=5;end 
      for k=1:nout
	if ~isempty(outporttype) && outporttype(k)=='B' then xset('pattern',default_color(3));end;
	scicos_lock_draw([x(k)-xf/8,y(k)],xf,yf,select_face_out,outtype(k));
	xset('pattern',default_color(1));
      end
      [x,y,typ]=bache_inputs(o)
      // select the shape to use. 
      outtype= 0*ones_new(1,nin);
      if ~isempty(inporttype) then  outtype( inporttype == 'I')=4;end 
      for k=1:nin
	if ~isempty(inporttype) && inporttype(k)=='B' then xset('pattern',default_color(3));end;
	scicos_lock_draw([x(k)+xf/8,y(k)],xf,yf,select_face_in,outtype(k));
	xset('pattern',default_color(1))
      end
    end
    // --------------------------------------
    
    if orient then  //standard orientation
      // set port shape
      out1=[ 0  -1
	     1   0
	     0   1
	     0  -1]*diag([xf/7,yf/14])
      
      in1= [-1  -1
	    0   0
	    -1   1
	    -1  -1]*diag([xf/7,yf/14])
      
      out2=[ 0  -1
	     1  -1
	     1   1
	     0   1]*diag([xf/7,yf/14])
      
      in2= [-1  -1
	    0  -1
	    0   1
	    -1   1]*diag([xf/7,yf/14])
      dy=sz(2)/(nout+1)
      xset('pattern',default_color(1))

      for k=1:nout
	if isempty(outporttype) then
	  xfpoly(out1(:,1)+ones(4,1)*(orig(1)+sz(1)),..
		 out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
	else
	  if outporttype(k) == 'E' then
	    xfpoly(out1(:,1)+ones(4,1)*(orig(1)+sz(1)),..
		   out1(:,2)+ones(4,1)*(orig(2)+6*sz(2)/10),1)
	  elseif outporttype(k)=='I' then
	    xpoly(out2(:,1)+ones(4,1)*(orig(1)+sz(1)),..
		  out2(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),type="lines",close=%t)
	  end
	end
      end

      dy=sz(2)/(nin+1)
      for k=1:nin
	if isempty(inporttype) then
	  xfpoly(in1(:,1)+ones(4,1)*orig(1),..
		 in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
	else
	  if inporttype(k)=='E' then
	    xfpoly(in1(:,1)+ones(4,1)*orig(1),..
		   in1(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),1)
	  elseif inporttype(k)=='I' then
	    xfpoly(in2(:,1)+ones(4,1)*orig(1),..
		   in2(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),1)
	  end
	end
      end
      
    else //tilded orientation
      out1=[0  -1
	    -1   0
	    0   1
	    0  -1]*diag([xf/7,yf/14])
      
      in1= [1  -1
	    0   0
	    1   1
	    1  -1]*diag([xf/7,yf/14])
      
      out2=[0  -1
	    -1  -1
	    -1   1
	    0   1]*diag([xf/7,yf/14])
      
      in2= [1  -1
	    0  -1
	    0   1
	    1   1]*diag([xf/7,yf/14])

      
      dy=sz(2)/(nout+1)
      xset('pattern',default_color(1))
      for k=1:nout
	if isempty(outporttype) then
	  xfpoly(out1(:,1)+ones(4,1)*orig(1)-1,..
		 out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
	else
	  if outporttype(k)=='E' then
	    xfpoly(out1(:,1)+ones(4,1)*orig(1)-1,..
		   out1(:,2)+ones(4,1)*(orig(2)+6*sz(2)/10),1)
	  elseif outporttype(k)=='I' then
	    xpoly(out2(:,1)+ones(4,1)*orig(1)-1,..
		  out2(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),type="lines",close=%t)
	  end
	end
      end
      
      dy=sz(2)/(nin+1)
      for k=1:nin
	if isempty(inporttype) then
	  xfpoly(in1(:,1)+ones(4,1)*(orig(1)+sz(1))+1,..
		 in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
	else
	  if inporttype(k)=='E' then
	    xfpoly(in1(:,1)+ones(4,1)*(orig(1)+sz(1))+1,..
		   in1(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),1)
	  elseif inporttype(k)=='I' then
	    xfpoly(in2(:,1)+ones(4,1)*(orig(1)+sz(1))+1,..
		   in2(:,2)+ones(4,1)*(orig(2)+2*sz(2)/10*(3*k-2)),1) 
	  end
	end
      end
    end
    // draw input/output clock ports
    //------------------------
    // set port shape

    out= [-1  0
	  0 -1
	  1  0
	  -1  0]*diag([xf/14,yf/7])


    in= [-1  1
	 0  0
	 1  1
	 -1  1]*diag([xf/14,yf/7])


    dx=sz(1)/(clkout+1)
    xset('pattern',default_color(-1))
    for k=1:clkout
      xfpoly(out(:,1)+ones(4,1)*(orig(1)+k*dx),..
	     out(:,2)+ones(4,1)*orig(2),1)
    end
    dx=sz(1)/(clkin+1)
    for k=1:clkin
      xfpoly(in(:,1)+ones(4,1)*(orig(1)+k*dx),..
	     in(:,2)+ones(4,1)*(orig(2)+sz(2)),1)
    end
    xset('pattern',default_color(0))
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

function standard_draw_ports(o)
// function used to draw ports 
  nin=size(o.model.in,1);
  nout=size(o.model.out,1);
  inporttype=o.graphics.in_implicit
  outporttype=o.graphics.out_implicit
  clkin=size(o.model.evtin,1);
  clkout=size(o.model.evtout,1);
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0));
  //draw input/output ports
  //standard orientation or tilded orientation
  select_face=[3,2];
  select_face_out=select_face(orient+1);
  select_face_in=select_face((~orient)+1);
  xpos=[orig(1),orig(1)+sz(1)];
  xpos_out=xpos[orient+1];
  xpos_in= xpos[(~orient)+1];
  // set port shape
  dy=sz(2)/(nout+1)
  xset('pattern',default_color(1))
  // select the shape to use. 
  outtype=ones_new(1,nout);
  if ~isempty(outporttype) then  outtype( outporttype == 'I')=5;end 
  for k=1:nout
    if ~isempty(outporttype) && outporttype(k)=='B' then xset('pattern',default_color(3));end;
    scicos_lock_draw([xpos_out,orig(2)+sz(2)-dy*k],xf,yf,select_face_out,outtype(k));
    xset('pattern',default_color(1));
  end
  dy=sz(2)/(nin+1)
  outtype= 0*ones_new(1,nin);
  if ~isempty(inporttype) then  outtype( inporttype == 'I')=4;end 
  for k=1:nin
    if ~isempty(inporttype) && inporttype(k)=='B' then xset('pattern',default_color(3));end;
    scicos_lock_draw([xpos_in,orig(2)+sz(2)-dy*k],xf,yf,select_face_in,outtype(k));
    xset('pattern',default_color(1))
  end
  // draw input/output clock ports
  //------------------------
  dx=sz(1)/(clkout+1)
  xset('pattern',default_color(-1))
  for k=1:clkout
    scicos_lock_draw([orig(1)+k*dx,orig(2)],xf,yf,1,3)
  end
  dx=sz(1)/(clkin+1)
  for k=1:clkin
    scicos_lock_draw([orig(1)+k*dx,orig(2)+sz(2)],xf,yf,0,2)
  end
  xset('pattern',default_color(0))
endfunction 
