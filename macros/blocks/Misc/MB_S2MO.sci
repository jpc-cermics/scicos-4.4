function [x,y,typ]=MB_S2MO(job,arg1,arg2)
  // converts n-scicos signals of size 1 to a modelica signal of size nx1
  // using VMBLOCK

  function blk_draw(o,sz,orig,orient)
    blue=xget('color','blue');
    dim = sci2exp(o.model.out);
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1/2;
    end
    xpoly(xx,yy,type='lines',color=blue,thickness=3);
    if orient then
      xstring(orig(1),orig(2),dim,fill=%t,w=sz(1)/2,h=sz(2),posx='center',posy='center');
    else
      xstring(orig(1)+sz(1)/2,orig(2),dim,fill=%t,w=sz(1)/2,h=sz(2),posx='center',posy='center');
    end
  endfunction
  
  function txt = MB_S2MO_funtxt(H, n ) 
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if n < 0 then
      txt.concatd[sprintf("    y[:].signal= u1;")];
    elseif n== 1 then
      txt.concatd[sprintf("    y.signal= u1;")];
    else
      for i=1:n
	txt.concatd[sprintf("    y[%d].signal= u%d;",i,i)];
      end
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_S2MO_define(n,old)
    n1 = max(n,1);
    if nargin <= 1 then 
      global(modelica_count=0);
      nameF='s2mo'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    H=hash(in=["u"+string(1:n1)'], intype=smat_create(n1,1,"E"),
	   in_r=ones(n1,1), in_c=ones(n1,1),
	   out=["y"], outtype="I", out_r=n, out_c=1,
	   param=[], paramv=list(),
	   pprop=[], nameF=nameF);
    
    H.funtxt = MB_S2MO_funtxt(H,n1);
    
    if nargin == 2 then
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
      blk.graphics.gr_i="blk_draw(o,sz,orig,orient)";
      blk.graphics.sz=[2,2];
      blk.gui = "MB_S2MO";
      blk.model.out =  n ;
      blk.model.in = sign(n) * ones(max(n,1),1);
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_coselica_draw(arg1,%f);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      x= MB_S2MO_define(max(arg1.model.out),x);
    case 'define' then
      n=-1; if nargin == 2 then n=arg1;end
      x= MB_S2MO_define(n);
  end
endfunction

