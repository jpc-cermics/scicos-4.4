function [x,y,typ]=MB_Gain(job,arg1,arg2)
  
  function blk_draw(o,sz,orig,orient,label)
    gain = sci2exp(o.graphics.exprs.paramv)
    gain = strsubst(gain,' ','');
    if length(gain) > 6 then
      gain=part(gain,1:4)+'..'
    end
    ll=length(gain);
    a=ll/(1+ll)/2
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1-2*a
    end
    xpoly(xx,yy,type='lines');
    w=sz(1)*(4/5);
    hf=(1/3);
    xstringb(orig(1),orig(2)+sz(2)*(1-hf)/2,gain,w,hf*sz(2),'fill');
  endfunction
  
  function txt = MB_Gain_funtxt(H)
    G=H.paramv(1);
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],
			  H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if size(G,'*') == 1 then
      txt.concatd["    y.signal = G* u.signal;"];
    else
      for i=1:size(G,'r')
	start = sprintf("    y[%d].signal=",i);
	S=m2s([]);
	for j=1: size(G,'c')
	  S.concatr[sprintf("G[%d,%d]*u[%d].signal",i,j,j)];
	end
	txt.concatd[start + catenate(S,sep='+') + ";"];
      end
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Gain_define(G, old)
    if nargin <= 1 then 
      global(modelica_count=0);
      nameF='gain'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    [m,n]=size(G);
    H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	   out=["y"], outtype="I", out_r=[m], out_c=[1],
	   param=['G'], paramv=list(G), pprop=[0], nameF=nameF);
    
    H.funtxt = MB_Gain_funtxt(H);
    
    if nargin == 2 then
      blk = old;
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.paramv = G;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.model.in = [n];
      blk.model.out = [m];
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.paramv = G;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i="blk_draw(o,sz,orig,orient,model.label)";
      blk.gui = "MB_Gain";
      blk.model.in = [n];
      blk.model.out = [m];
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
      // The code is regenerated according to new dimensions and function
      // when executing a script coming from do_api_save the classname is
      // x.graphics.exprs.nameF
      // we have to use this name to update 
      y=acquire('needcompile',def=0);
      x=arg1;
      G=x.graphics.exprs.paramv;
      gv_titles='Set MB_Gain block parameters';
      gv_names=['Gain'];
      gv_types = list('mat',[-1,-1]);
      gain = strsubst(sci2exp(G),' ','');
      [ok,G_new, value_n]=getvalue(gv_titles,gv_names,gv_types,list(gain));
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Gain_define(G_new,x);
      if ~G.equal[G_new] then y=4;end
      resume(needcompile=y);
    case 'define' then
      if nargin == 2 then G=arg1;else G=2;end
      x= MB_Gain_define(G);
  end

endfunction

