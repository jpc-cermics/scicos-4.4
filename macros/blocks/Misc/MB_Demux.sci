function [x,y,typ]=MB_Demux(job,arg1,arg2)
// A Modelica block (following coselica types i.e using RealInput/RealOutput types)
// used to add vectors in the SUMMATION spirit 

  function blk_draw(o,sz,orig)  
    txt="MB_DeMux";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction

  function txt = MB_Demux_funtxt(H, dim_or, dim_ir)
    
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop);
    txt.concatd["  equation"];
    start = 0;
    for i=1:size(dim_or,'*')
      fmt = sprintf("    y%d[%%d].signal= u[%%d].signal;",i);
      yrange=(1:dim_or(i))';
      urange=start + (1:dim_or(i))';
      start = start + dim_or(i);
      if size(urange,'*')== 1 then
	fmt1 = sprintf("    y%d.signal= u[%%d].signal;",i);
	txt1 = sprintf(fmt1,urange);
      else
	txt1 = sprintf(fmt,yrange,urange);
      end
      txt.concatd[txt1];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Demux_define(dim_or, dim_ir, old)
    if nargin <= 2 then 
      global(modelica_count=0);
      nameF='demux'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    n_demux = size(dim_or,'*');
    H=hash(in=["u"], intype=smat_create(1,1,"I"),...
	   in_r= dim_ir, in_c=ones(1,1),...
	   out=["y"+string(1:n_demux)'], outtype=smat_create(n_demux,1,"I"), ...
	   out_r= dim_or, out_c= ones(n_demux,1),...
	   param=[], paramv=list(), pprop=[], nameF=nameF);
    
    H.funtxt = MB_Demux_funtxt(H, dim_or, dim_ir);
    
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
      blk.graphics.sz=[0.5,2];      
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i="blk_draw(o,sz,orig)";//,xget('color','blue'));
      blk.gui = "MB_Demux";
      blk.model.in = dim_ir;
      blk.model.out = dim_or;
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
     y=acquire('needcompile',def=0);
     exprs = sci2exp(arg1.model.out);
     x=arg1;
     while %t do
       [ok,out,exprs]=getvalue('Set MB_Demux block parameters',
			       ['Number of output ports or vector of sizes'],list('vec',-1),exprs)
      if ~ok then break,end
      if size(out,'*')==1 then
	out = max(out,1);
        it=-1
        ot=-ones(out,1)
        oup=[-[1:out]',ones(out,1)]
        inp=[0,1]
        [model,graphics,ok]=set_io(arg1.model,arg1.graphics,
				   list(inp,it),...
				   list(oup,ot),[],[])
      else
        if size(out,'*')==0| or(out==0) then
	  message(['Block must have at least 1 and at most 31 output ports';
		   'size 0 is not allowed'])
	  ok=%f;
	else
	  if min(out)<0 then nin=0,else nin=sum(out),end
          it=-1
          ot=-ones(size(out,'*'),1)
          oup=[out(:),ones(size(out,'*'),1)]
          inp=[nin,1]
	  [model,graphics,ok]=set_io(arg1.model,arg1.graphics,
				     list(inp,it),...
				     list(oup,ot),[],[])
	end
      end
      if ok then
	x.graphics=graphics;x.model=model;
	x= MB_Demux_define(x.model.out,x.model.in,x);
	break
      end
     end
     y=4; // XXXX a revoir;
     resume(needcompile=y);
   case 'define' then
    dim_or = [-1;-2];dim_ir = 0;
    if nargin >= 2 then dim_or = arg1;end;
    if nargin >= 3 then dim_ir = arg2;end;
    if and(dim_or >= 0) then dim_ir = sum(dim_or);end
    x= MB_Demux_define(dim_or,dim_ir);
  end
endfunction
