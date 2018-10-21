function [x,y,typ]=MB_MathFun(job,arg1,arg2)
  // A modelica block for non-scalar trig functions
  // XXX: tester que le nom choisit existe dans les fonctions
  //      verifier que la fonction signe existe en modelica
  
  function [x,y,xpos,ypos]=sin_values()
    ypos=0.1; xpos= 0.55;
    x = linspace(0,2*%pi,20); y = sin(x);
  endfunction

  function [x,y,xpos,ypos]=cos_values()
    ypos=0.1; xpos= 0.55;
    x = linspace(0,2*%pi,20); y = cos(x);
  endfunction

  function [x,y,xpos,ypos]=tan_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-%pi/2+0.1,%pi/2-0.1,20); y = tan(x);
  endfunction

  function [x,y,xpos,ypos]=asin_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-1+0.02,1-0.02,20); y = asin(x);
  endfunction

  function [x,y,xpos,ypos]=acos_values()
    ypos=0.5; xpos= 0.15;
    x = linspace(-1+0.02,1-0.02,20); y = acos(x);
  endfunction

  function [x,y,xpos,ypos]=atan_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-10,10,20); y = atan(x);
  endfunction

  function [x,y,xpos,ypos]=sinh_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-5,5,20); y = sinh(x);
  endfunction

  function [x,y,xpos,ypos]=cosh_values()
    ypos=0.5; xpos= 0.15;
    x = linspace(-5,5,20); y = cosh(x);
  endfunction

  function [x,y,xpos,ypos]=tanh_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-5,5,20); y = tanh(x);
  endfunction
  
  function [x,y,xpos,ypos]=exp_values()
    ypos=0.5; xpos= 0.15;
    x = linspace(0,5,20); y = exp(x);
  endfunction

  function [x,y,xpos,ypos]=log_values()
    ypos=0.1; xpos= 0.55;
    x = linspace(0.2,5,20); y = log(x);
  endfunction

  function [x,y,xpos,ypos]=log10_values()
    ypos=0.1; xpos= 0.55;
    x = linspace(0.2,5,20); y = log(x)./log(10);
  endfunction
  
  function [x,y,xpos,ypos]=abs_values()
    ypos=0.5; xpos= 0.15;
    x = linspace(-1,1,20); y = abs(x);
  endfunction

  function [x,y,xpos,ypos]=sign_values()
    ypos=0.5; xpos= 0.55;
    x = linspace(-1,1,20); y = sign(x);
  endfunction
  
  function blk_draw(sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    black=xget('color','black');
    gray=xget('color','gray');
    red = xget('color','red');
    if orient then
      xx=orig(1);yy=orig(2);
      ww=sz(1);hh=sz(2);
    else
      xx=orig(1)+sz(1);yy=orig(2);
      ww=-sz(1);hh=sz(2);
    end
    // frame 
    if orient then
      xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    else
      xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    end
    // label 
    if orient then
      xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    else
      xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*1.05,label,sz(1)*1.5,sz(2)*0.2,"fill");
    end
    
    execstr(sprintf("[xv,yv,xpos,ypos] = %s_values()",C));
    //ypos=0.1;  // y-axis left 
    //ypos=0.5;  // y-axis midle
    xpoly(xx+ww*[ypos;ypos],yy+hh*[0.84;0.1],color=gray);
    xfpoly(xx+ww*[ypos;ypos-0.04;ypos+0.04;ypos],yy+hh*[0.95;0.84;0.84;0.95],color=gray,fill_color=gray);
    //xpos=0.15;// down x-axis 
    //xpos=0.55; // midle x-axis
    xpoly(xx+ww*[0.05;0.91],yy+hh*[xpos;xpos],color=gray);
    xfpoly(xx+ww*[0.95;0.84;0.84;0.95],yy+hh*[xpos;xpos+0.04;xpos-0.04;xpos],color=gray,fill_color=gray);

    xv = 0.1 + 0.8* (xv - min(xv)) ./ (max(xv) -min(xv)) 
    yv = 0.15 + 0.8* (yv - min(yv)) ./ (max(yv) -min(yv)) 
    xpoly(xx+ww*xv,yy+hh*yv,color=blue);
    if orient then
       xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    else
       xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    end
  endfunction

  function txt = MB_MathFun_funtxt(H, n, math_fname)
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if n > 0 then 
      if n==1 then
	txt.concatd["    y.signal= u.signal;"];
      else
	for i=1:n
	  txt.concatd[sprintf("    y[%d].signal= %s(u[%d].signal);",i,math_fname,i)];
	end
      end
    else
      txt.concatd[sprintf("    y[:].signal= %s(u[:].signal);",math_fname)];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
    
  function blk= MB_MathFun_define(n,math_fname, old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='generic'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end

    H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	   out=["y"], outtype="I", out_r=[n], out_c=[1],
	   param=[], paramv=list(), pprop=[], nameF=nameF);

    H.funtxt = MB_MathFun_funtxt(H, n, math_fname);
    
    if nargin == 3 then
      blk = old;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.paramv = math_fname;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.paramv = math_fname;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'))
      blk.gui = "MB_MathFun";
      blk.model.in = -1;
      blk.model.out = -1;
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      // get string inside list(str);
      xparamv=regsub(arg1.graphics.exprs.paramv,"^list\(+(.*)\)+$","\\1")
      paramv=arg1.graphics.exprs.paramv;
      C = xparamv;
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      // The code is regenerated according to new dimensions and function
      // when executing a script coming from do_api_save the classname is
      // x.graphics.exprs.nameF
      // we have to use this name to update 
      x=arg1;
      value=x.graphics.exprs.paramv;
      gv_titles='Set MB_MathFun block parameters';
      gv_names=['trigonometric function'];
      gv_types = list('str',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      x= MB_MathFun_define(x.model.in,value_n,x);
    case 'define' then
      x= MB_MathFun_define(-1,"sin");
  end
endfunction
