function [x,y,typ]=MB_Integral(job,arg1,arg2)
  // A modelica block for non-scalar trig functions
  
  function blk_draw(sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1,color=blue,background=white);
    xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),
	  orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),type="lines")
    txt="1/s";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
  function txt = MB_Integral_funtxt(H, xinit, outmin,outmax)
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],m2s([]),[],[],H.param,H.paramv,H.pprop)
    n = size(xinit,'*');
    if n > 1 then 
      txt.concatd[sprintf("RealOutput y[%d](signal(start=xinit[:,1]));",n)];
    else
      txt.concatd[sprintf("RealOutput y(signal(start=xinit));")];
    end
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
  
  function blk= MB_Integral_define(exprs, old)
    E = acquire('%scicos_context',def=hash(1));
    [ok,E1]=execstr(["xinit";"outmin"; "outmax"]+ "=" + exprs, env=E, errcatch=%t);
    if ~ok then xinit=[0];outmin=[];outmax=[];
    else
      xinit=E1.xinit; outmin=E1.outmin; outmax=E1.outmax;
    end
    if nargin <= 1 then 
      global(modelica_count=0);
      nameF='integral'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    param=["xinit"]; paramv=list(xinit); pprop=[0];
    if ~isempty(outmin) then
      param=[param,"outMin"]; paramv($+1)=outmin; pprop=[pprop,0];
    end
    if ~isempty(outmax) then
      param=[param,"outMax"]; paramv($+1)=outmax; pprop=[pprop,0];
    end
    n = size(xinit,'*');
    H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	   out=["y"], outtype="I", out_r=[n], out_c=[1],
	   param=param, paramv=paramv, pprop=pprop, nameF=nameF);
    
    H.funtxt = MB_Integral_funtxt(H, xinit, outmin, outmax);
    
    if nargin == 2 then
      blk = VMBLOCK_define(H,old);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.exprs = exprs;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.exprs = exprs;
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
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      // set parameters and regenerate the code accordingly
      // The set action is also called during translation from
      // scicos to modelica.
      // In that case it is possible that the model.in is > 1 and xinit
      // is equal to one since it is possible for the Intergral_m block
      // We need to set up xinit in that case to reflect the real dimension.
      x=arg1;
      graphics=arg1.graphics;
      exprs=graphics.exprs.exprs;
      model=arg1.model;
      while %t do
	[ok,x0,outmin,outmax,exprs_new]=getvalue('Set MB_Integral block parameters',
						 ['Initial Condition';
						  'Upper limit or []';'Lower limit or []'],
						 list('mat',[-1 -1],'mat',[-1 -1],'mat',[-1 -1]),exprs);
	if ~ok then break,end
	if %f then 
	  message('Upper limits must be > Lower limits')
	  message('Inital condition x0 should be inside the limits')
      	  rpar=[real(maxp(:));real(lowp(:))]
	  model.nzcross=size(x0,'*')
	  model.nmode=size(x0,'*')
      	  model.rpar=rpar
	  model.state=real(x0(:))
	  model.sim=list('integral_func',4)
	  it=[1;ones(reinit,1)]
	  ot=1;
	  if size(x0,"*")>1 then
	    in=[size(x0,1)*[1;ones(reinit,1)],size(x0,2)*[1;ones(reinit,1)]]
	    out=size(x0)
	  else
	    in=[-1*[1;ones(reinit,1)],-2*[1;ones(reinit,1)]]
	    out=[-1,-2]
	  end
	end
	if x.model.in > 0 && size(x0,'*')==1 then
	  xinit=smat_create(x.model.in,1,exprs_new(1));
	  xinit="["+catenate(xinit,sep=";")+"]";
	  exprs_new(1)=xinit;
	end
	x= MB_Integral_define(exprs_new,x);
	break;
      end
    case 'define' then
      // ["initial_state","outmin","outmax"]
      // outmin and outmax can be []
      // The dimension of "initial_state" gives the size of the initial state
      // But when converting from scicos to modelica we have to take care
      // That in scicos dimension 1 may be promoted to higher dimensions;
      A=["0";"[]";"[]"];
      if nargin == 2 then A=arg1;end
      x= MB_Integral_define(A);
  end
endfunction

