function [x,y,typ]=MB_MO2S(job,arg1,arg2)
  // convert a modelica signal of size nx1 to n-scicos signals of size 1
  // using VMBLOCK
  
  function blk_draw(o,sz,orig)
    // using summation draw
    // should turn the square to blue triangles.
    blue=xget('color','blue');
    white=xget('color','white');
    gray=xget('color','gray');

    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=0;
    if ~o.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=gray,background=white);
    if ~exists("%zoom") then %zoom=1, end;
    xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de;
    yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2);
    xpoly(xx,yy,type='lines',color=blue);
  endfunction

  function txt = MB_MO2S_funtxt(H, n ) 
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],H.out,H.outtype,
			  [H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt=strsubst(txt,'RealOutput','Real');
    txt.concatd["  equation"];
    for i=1:n
      txt.concatd[sprintf("    y%d= u[%d].signal;",i,i)];
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_MO2S_define(n,old)
    n1 = max(n,1);
    if nargin <= 1 then 
      global(modelica_count=0);
      nameF='mo2s'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    
    H=hash(in=["u"], intype="I", in_r=n, in_c=1,
	   out=["y"+string(1:n1)'], outtype=smat_create(n1,1,"E"),
	   out_r=ones(n1,1), out_c=ones(n1,1),
	   param=[], paramv=list(),
	   pprop=[], nameF=nameF);
    
    H.funtxt = MB_MO2S_funtxt(H,n1);
    
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
      blk.graphics.gr_i=list("blk_draw(o,sz,orig)",xget('color','blue'))
      blk.gui = "MB_MO2S";
      blk.model.in =  n ;
      blk.model.out = ones(max(n,1),1);
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
      x=arg1;
      x= MB_MO2S_define(max(arg1.model.in),x);
    case 'define' then
      n=-1; if nargin == 2 then n=arg1;end
      x= MB_MO2S_define(n);
  end
endfunction

