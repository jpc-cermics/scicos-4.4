function [x,y,typ]=MB_Constantn(job,arg1,arg2)
  // A <<coselica>> block for non-scalar constants

  function blk_draw(sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    black=xget('color','black');
    gray=xget('color','gray');
    red = xget('color','red');
    C=strsubst(C,' ','');
    if length(C) > 20 then C = part(C,1:20)+"...";end
    
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
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.5;0.5],color=black);
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.6;0.6],color=red);
    xpoly(xx+ww*[0.1;0.9],yy+hh*[0.3;0.3],color=blue);
    if orient then
       xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*-0.25,"K="+C,sz(1)*1.5,sz(2)*0.2,"fill");
    else
       xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*-0.25,"K="+C,sz(1)*1.5,sz(2)*0.2,"fill");
    end
  endfunction
  
  function txt = MB_TrigFun_funtxt(H, C)
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,
			  H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if and(size(C)==1) then
      txt.concatd["    y.signal= C;"];
    elseif and(size(C)<>1) then
      for i=1:size(C,1)
	for j=1:size(C,2)
	  txt.concatd[sprintf("    y[%d,%d].signal= C[%d,%d];",i,j,i,j)];
	end
      end
    elseif size(C,2)==1 
      for i=1:size(C,'*')
	txt.concatd[sprintf("    y[%d].signal= C[%d,1];",i,i)];
      end
    else
      for i=1:size(C,'*')
	txt.concatd[sprintf("    y[%d].signal= C[%d];",i,i)];
      end
    end
    txt.concatd[sprintf("end %s;", nameF)];
  endfunction

  function blk= MB_Constantn_define(C,paramv, old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='cten'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    H=hash(in=[], intype=[], in_r=[], in_c=[],
	   out=["y"], outtype="I", out_r=size(C,1), out_c=size(C,2),
	   param=["C"], paramv=list(C),
	   pprop=[0], nameF=nameF);
    
    H.funtxt = MB_TrigFun_funtxt(H, C)
    
    if nargin == 3 then
      blk = VMBLOCK_define(H,old);
    else
      blk = VMBLOCK_define(H);
    end
    // remove leading and trainling () 
    paramv=regsub(paramv,"^\(+(.*)\)+$","\\1")
    blk.graphics.exprs.paramv = sprintf("list(%s)", paramv);
    blk.graphics.exprs.funtxt = H.funtxt;
    blk.graphics('3D') = %f; // coselica options 
    blk.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'))
    blk.gui = "MB_Constantn";
    blk.model.in = [];
    blk.model.in2 = [];
    blk.model.out = size(C,1);
    blk.model.out2 = size(C,2);
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
      xparamv=regsub(arg1.graphics.exprs.paramv,"^list\(+(.*)\)+$","\\1")
      value=list(strsubst(xparamv,'list',''));
      gv_titles='Set MB_Constantn block parameters';
      gv_names=['constant'];
      gv_types = list('vec',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Constantn_define(C,value_n,x);
      
    case 'define' then
      if nargin == 2 then cte = arg1; else cte= [1,2;3,7;8,9];end
      x= MB_Constantn_define(cte,sci2exp(cte));
  end
endfunction

