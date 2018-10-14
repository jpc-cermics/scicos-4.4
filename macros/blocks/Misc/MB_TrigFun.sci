function [x,y,typ]=MB_TrigFun(job,arg1,arg2)
  // A modelica block for non-scalar trig functions
  
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
    xpoly(xx+ww*[0.1;0.1],yy+hh*[0.84;0.1],color=gray);
    xfpoly(xx+ww*[0.1;0.06;0.14;0.1],yy+hh*[0.95;0.84;0.84;0.95],color=gray,fill_color=gray);
    xpoly(xx+ww*[0.05;0.91],yy+hh*[0.15;0.15],color=gray);
    xfpoly(xx+ww*[0.95;0.84;0.84;0.95],yy+hh*[0.15;0.19;0.11;0.15],color=gray,fill_color=gray);
    xv = linspace(0,2*%pi,20);yv = sin(xv);
    xv = 0.1 + 0.8* (xv - min(xv)) ./ (max(xv) -min(xv)) 
    yv = 0.15 + 0.8* (yv - min(yv)) ./ (max(yv) -min(yv)) 
    xpoly(xx+ww*xv,yy+hh*yv,color=blue);
    if orient then
       xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    else
       xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*-0.25,C,sz(1)*1.5,sz(2)*0.2,"fill");
    end
  endfunction
  
  function blk_draw_old(sz,orig,orient,label)
    dx=sz(1)/5;dy=sz(2)/10;
    w=sz(1)-2*dx;h=sz(2)-2*dy;
    txt="C";
    xstringb(orig(1)+dx,orig(2)+dy,txt,w,h,'fill');
  endfunction
  
  function blk= MB_TrigFun_define(n,fname, old)
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
    
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if n > 0 then 
      if n==1 then
	txt.concatd["    y.signal= C;"];
      else
	for i=1:n
	  txt.concatd[sprintf("    y[%d].signal= %s(u[%d].signal);",i,fname,i)];
	end
      end
    else
      txt.concatd[sprintf("    y[:].signal= %s(u[:]);",fname)];
    end
    txt.concatd[sprintf("end %s;", nameF)];
    
    H.funtxt = txt;
    if nargin == 3 then 
      blk = VMBLOCK_define(H,old);
    else
      blk = VMBLOCK_define(H);
    end
    // remove leading and trainling () 
    blk.graphics.exprs.paramv = fname;
    blk.graphics.exprs.funtxt = txt;
    blk.graphics('3D') = %f; // coselica options 
    blk.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'))
    blk.gui = "MB_TrigFun";
    blk.model.in = -1;
    blk.model.out = -1;
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
      x=arg1;
      // get string inside list(str);
      value=x.graphics.exprs.paramv;
      gv_titles='Set MB_TrigFun block parameters';
      gv_names=['trigonometric function'];
      gv_types = list('str',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      if ~value_n.equal[value] then 
	x= MB_TrigFun_define(-1,value_n,x);
      end
    case 'define' then
      x= MB_TrigFun_define(-1,"sin");
  end
endfunction
