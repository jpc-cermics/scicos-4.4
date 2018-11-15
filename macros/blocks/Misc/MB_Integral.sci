function [x,y,typ]=MB_Integral(job,arg1,arg2)
  // A modelica block for non-scalar trig functions
  // XXX: tester que le nom choisit existe dans les fonctions
  //      verifier que la fonction signe existe en modelica

  function blk_draw(sz,orig,orient,label)
    xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),
	  orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),type="lines")
    txt="1/s";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  function txt = MB_Integral_funtxt(H, n, outmin,outmax)
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if ~isempty(outmin) || ~isempty(outmax) then
      fmt = "    der(%%s) = if %s then 0 else %%s;";
      fmt_outmin = "outMin[%%%%d]";
      fmt_neg = "%%s < %s and %%s < 0";
      fmt_pos = " %%s > %s and %%s > 0";
      if size(outmin,'*')==1 then fmt_outmin = "outMin";end
      fmt_outmax = "outMax[%%%%d]";
      if size(outmax,'*')==1 then fmt_outmax = "outMax";end
      fmt_u = "u[%%d].signal";
      if n == 1 then fmt_u = "u.signal";end
      fmt_y = "y[%%d].signal";
      if n == 1 then fmt_y = "y.signal";end
      fmt_cond = "";
      if size(outmin,'*')<>0 then
	fmt_cond = sprintf(fmt_neg,fmt_outmin);
	fmt_cond = sprintf(fmt_cond,fmt_y,fmt_u);
      end
      if size(outmax,'*')<>0 then
	fmt_cond2 = sprintf(fmt_pos,fmt_outmax);
	fmt_cond2 = sprintf(fmt_cond2,fmt_y,fmt_u);
	if fmt_cond == "" then
	  fmt_cond = fmt_cond2;
	else
	  fmt_cond = fmt_cond + " or " + fmt_cond2;
	end
      end
      fmt = sprintf(fmt,fmt_cond);
      // take care of potential extra % infmt_y and fmt_u 
      fmt = sprintf(fmt,sprintf(fmt_y),sprintf(fmt_u));
      if n > 0 then 
	if n==1 then
	  txt.concatd[fmt];
	else
	  count = strindex(fmt,"%d");
	  for i=1:n
	    inds = i*ones(size(count));
	    txt.concatd[sprintf(fmt,inds{:})];
	  end
	end
      else
	txt.concatd[strsubst(fmt,"[%d]","[:]")];
      end
      txt.concatd[sprintf("end %s;", H.nameF)];
    else
      fmt = "    der(y[%d].signal) = u[%d].signal;";
      if n > 0 then 
	if n==1 then
	  txt.concatd[strsubst(fmt,"[%d]","")];
	else
	  for i=1:n
	    txt.concatd[sprintf(fmt,i,i)];
	  end
	end
      else
	txt.concatd[strsubst(fmt,"[%d]","[:]")];
      end
      txt.concatd[sprintf("end %s;", H.nameF)];
    end
  endfunction
  
  function blk= MB_Integral_define(n, outmin,outmax, old)
    if nargin <= 3 then 
      global(modelica_count=0);
      nameF='integral'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    param=[]; paramv=list(); pprop=[];
    if ~isempty(outmin) then
      param=["outMin"]; paramv=list(outmin); pprop=[0];
    end
    if ~isempty(outmax) then
      param=[param,"outMin"]; paramv($+1)=outmax; pprop=[pprop,0];
    end
    
    H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	   out=["y"], outtype="I", out_r=[n], out_c=[1],
	   param=param, paramv=paramv, pprop=pprop, nameF=nameF);
    
    H.funtxt = MB_Integral_funtxt(H, n,  outmin,outmax);
    
    if nargin == 4 then
      blk = old;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.params = list(n,outmin,outmax);
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.params = list(n,outmin,outmax);
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i=list("blk_draw(sz,orig,orient,model.label)",xget('color','blue'))
      blk.gui = "MB_Integral";
      blk.model.in = n;
      blk.model.out = n;
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
      gv_titles='Set MB_Integral block parameters';
      gv_names=['trigonometric function'];
      gv_types = list('str',-1);
      [ok,C, value_n]=getvalue(gv_titles,gv_names,gv_types,value);
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Integral_define(x.model.in,value_n,x);
    case 'define' then
      L=list(1,[],[]);
      if nargin == 2 then L=arg1;end
      x= MB_Integral_define(L(1),L(2),L(3));
      x.model.in = L(1);
      x.model.in2 = 1;
      x.model.intype = 1;
      x.model.out = L(1);
      x.model.out2 = 1;
      x.model.outtype = 1;
  end
endfunction

