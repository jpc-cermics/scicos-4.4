function [x,y,typ]=MB_Expression(job,arg1,arg2)
  // A Modelica block (following coselica types i.e using RealInput/RealOutput types)
  // used to add vectors in the SUMMATION spirit 
  
  function txt = MB_Expression_funtxt(H, n, expression)
    // n : signal dimensions
    // signs : the signs to be used for each of them
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if n == 1 then
      u_dim=max(1,H.in_r);
      ins = "u"+string((1:u_dim));
      ins1 = "u["+string(1:u_dim)+"]";
      modelica_expr= strsubst(expression,ins,ins1+".signal");
    else
      ins = "u"+string(1:size(H.in_r,'*'));
      modelica_expr= strsubst(expression,ins,ins+".signal");
    end
    txt.concatd[sprintf("    y.signal = %s;",modelica_expr)];
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function [ok,msg, vars, params, paramv]=MB_Expression_analyse(n,expression)
    ok = %t; msg = ""; vars=0; params=m2s([]); paramv = list();
    // build the expression 
    ok=execstr(sprintf("bexp=scalexp_create(""%s"")",expression),errcatch=%t);
    if ~ok then
      message(["Erroneous expression";lasterror()]) 
      return;
    end
    // get variables contained in expression
    vars = bexp.get_vars[];
    I=[];
    for i=1:size(vars,"*")
      ok= execstr("[a]=sscanf("""+vars(i)+""",""u%d"")",errcatch=%t)
      if ok then I=[I;i,a]; else lasterror(); end;
    end
    // keep the params name 
    params = vars;if ~isempty(I) then params(I(:,1))=[];end
    // vars contains the numbers which gives unames contained in expression
    // unames = "u"+ string(vars);
    vars = sort(I(:,2),'g','i');
    if n == 1 then
      if vars($) > 8 then
	msg="when n==1 then variable names should be, u1,...,u8";
	ok=%f;return;
      end
    else
      if vars($) > n then
	msg=sprintf("n==%d, thus variables names should be, u1,...,u%d",n,n);
	ok=%f;return;
      end
    end
    // get the param values
    if size(params,'*')==0 then
      paramv = list();
    else
      cmd = sprintf("paramv=list(%s);",catenate(params,sep=","));
      context=acquire('%scicos_context',def=hash(4));
      [ok,He] = execstr(cmd,env=context,errcatch=%t);
      if ~ok then msg("Failed to evaluate parameters contained in expression");
	ok=%f;return;
      else
	paramv = He.paramv;
      end
    end
  endfunction
  
  function [ok,msg,blk]= MB_Expression_define(n,u_dim,expression,old)
    ok = %t; msg = "";blk = [];
    if nargin <= 3 then 
      global(modelica_count=0);
      nameF='expression'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    [ok,msg, vars, params,paramv]=MB_Expression_analyse(n,expression);
    if ~ok then return;end
    
    if n == 1 then
      H=hash(in=["u"], intype="I", in_r= u_dim, in_c=1,
	     out=["y"], outtype=["I"], out_r= 1, out_c=1,
	     param=params, paramv=paramv, pprop=zeros(size(params)), nameF=nameF);
    else
      H=hash(in=["u"+string(1:n)'], intype=smat_create(n,1,"I"),
	     in_r= ones(n,1), in_c=ones(n,1),
	     out=["y"], outtype=["I"], out_r= 1, out_c=1,
	     param=params, paramv=paramv, pprop=zeros(size(params)), nameF=nameF);
    end
    
    H.funtxt = MB_Expression_funtxt(H, n, expression);
    
    if nargin == 4 then
      blk = old;
      if n == 1 then
	it=1; ot = 1;
	in_imp= 1; out_imp=1;
      else
	it =ones(n,1); ot=1;
	in_imp= 1:n; out_imp=1;
      end
      [model,graphics,ok]=set_io(old.model,old.graphics,...
				 list([H.in_r,H.in_c],it),...
				 list([H.out_r,H.out_c],ot),[],[],
				 in_imp,out_imp);
      blk.model = model;
      blk.graphics=graphics;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.n = n;
      blk.graphics.exprs.expression = expression;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.n = n;
      blk.graphics.exprs.expression = expression;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options
      gr_i=["xstringb(orig(1),orig(2),[""Mathematical"";""Expression""],sz(1),sz(2),""fill"");"]
      blk.graphics.gr_i=gr_i;
      blk.gui = "MB_Expression";
      if n == 1 then blk.model.in = -1;else blk.model.in = ones(n,1);end
      blk.model.out = 1;
      blk.model.dep_ut = [%t,%t];
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      // XXXXX si on connait la taille de l'entrée il faut controler qu'elle est compatible avec u 
      x=arg1;
      gv_title = ["Give a scalar expression using inputs u1, u2,...";
		  "If only one input, input is vector [u1,u2,...] (max 8)";
		  "ex: (dd*u1+sin(u2)>0)*u3";
		  "Note that here dd must be defined in context"];
      gv_names = ["number of inputs";"nsp expression"];
      gv_types = list("vec",1,"str",1);
      exprs = list(string(x.graphics.exprs.n),x.graphics.exprs.expression);
      [ok, n_new, expression_new , str]=getvalue(gv_title,gv_names,gv_types,exprs);
						 
      if ~ok then return;end; // cancel in getvalue;
      [ok,msg,x_new]= MB_Expression_define(n_new,x.model.in, expression_new,x);
      if ~ok then
	message(msg);return;
      end
      x=x_new;
      y=4;
      resume(needcompile=y);
    case 'define' then
      if nargin >= 2 then n=arg1;else n=2;end
      if nargin >= 3 then expression=arg2;else expression="sin(u1)+u2";end
      [ok,msg,x]= MB_Expression_define(n,-1,expression);
  end
endfunction



  
