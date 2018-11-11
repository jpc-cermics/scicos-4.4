function [x,y,typ]=MB_Mux(job,arg1,arg2)
  // A Modelica block (following coselica types i.e using RealInput/RealOutput types)
  // used to add vectors in the SUMMATION spirit 

  function blk_draw(o,sz,orig)  
    txt="Mux";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction

  function txt = MB_Mux_funtxt(H, dim_or, dim_ir)
    
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop);
    txt.concatd["  equation"];
    start = 0;
    for i=1:size(dim_ir,'*')
      fmt = sprintf("    y[%%d].signal= u%d[%%d].signal;",i);
      urange=(1:dim_ir(i))';
      yrange=start + (1:dim_ir(i))';
      start = start + dim_ir(i);
      if size(urange,'*')== 1 then
	fmt1 = sprintf("    y[%%d].signal= u%d.signal;",i);
	txt1 = sprintf(fmt1,yrange);
      else
	txt1 = sprintf(fmt,yrange,urange);
      end
      txt.concatd[txt1];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Mux_define(dim_or, dim_ir, old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='mux'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    n_mux = size(dim_ir,'*');
    H=hash(in=["u"+string(1:n_mux)'], intype=smat_create(n_mux,1,"I"),...
	   in_r= dim_ir, in_c=ones(n_mux,1),...
	   out=["y"], outtype=smat_create(1,1,"I"), ...
	   out_r= dim_or, out_c= ones(1,1),...
	   param=[], paramv=list(), pprop=[], nameF=nameF);
    
    H.funtxt = MB_Mux_funtxt(H, dim_or, dim_ir);
    
    if nargin == 3 then
      blk = old;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i=list("blk_draw(o,sz,orig)",xget('color','blue'))
      blk.gui = "MB_Mux";
      blk.model.in = dim_ir;
      blk.model.out = dim_or;
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      //signs=arg1.graphics.exprs.signs;
      standard_coselica_draw(arg1);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      exprs = sci2exp(arg1.model.in);
      x=arg1;
      while %t do
	[ok,in,exprs_new]=getvalue('Set MUX block parameters',
				   'Number of input ports or vector of sizes',list('vec',-1),exprs)
	if ~ok then break,end
	if size(in,'*')==1 then
	  in = max(in,1);
	  it=-ones(in,1)
	  ot=-1
	  inp=[-[1:in]',ones(in,1)]
	  oup=[0,1]
	  [model,graphics,ok]=set_io(arg1.model,arg1.graphics,...
				     list(inp,it),...
				     list(oup,ot),[],[])
	else
	  if size(in,'*')==0| or(in==0) then
	    message(['MB_Mux must have at least one input port';
		     'Size 0 is not allowed. '])
	    ok=%f
	  else
	    if min(in) < 0 then nout=0,else nout=sum(in),end
	    it=-ones(size(in,'*'),1)
	    ot=-1
	    inp=[in(:),ones(size(in,'*'),1)]
	    oup=[nout,1]
	    [model,graphics,ok]=set_io(arg1.model,arg1.graphics,...
				       list(inp,it),...
				       list(oup,ot),[],[])
	  end
	end
	if ok then
	  x.graphics=graphics;x.model=model
	  x= MB_Mux_define(x.model.out,x.model.in,x);
	  break
	end
      end
      y=4; // XXXX a revoir;
      resume(needcompile=y);
    case 'define' then
      dim_ir = [-1;-2];dim_or = 0;
      if nargin >= 2 then dim_ir = arg1;end;
      if nargin >= 3 then dim_or = arg2;end;
      if and(dim_ir >= 0) then dim_or = sum(dim_ir);end
      x= MB_Mux_define(dim_or,dim_ir);
  end
endfunction
