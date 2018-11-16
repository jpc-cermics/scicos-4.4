function [x,y,typ]=MB_Gain(job,arg1,arg2)
  
  function blk_draw(o,sz,orig,orient,label)
    blue=xget('color','blue');
    white=xget('color','white');
    gain = o.graphics.exprs.gains;
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
    xpoly(xx,yy,type='lines',color=blue);
    w=sz(1)*(4/5);
    hf=(1/3);
    xstringb(orig(1),orig(2)+sz(2)*(1-hf)/2,gain,w,hf*sz(2),'fill');
  endfunction
  
  function txt = MB_Gain_funtxt(H)
    txt=VMBLOCK_classhead(H.nameF,H.in,H.intype,[H.in_r,H.in_c],
			  H.out,H.outtype,[H.out_r,H.out_c],H.param,H.paramv,H.pprop)
    txt.concatd["  equation"];
    if H.in_r==1 && H.out_r == 1 then
      txt.concatd["    y.signal = G* u.signal;"];
    elseif H.in_r==-1 && H.out_r == -2 then
      txt.concatd["    //// will be generated later"];
    elseif H.out_r==1 then
      start = sprintf("    y.signal=",i);
      S=m2s([]);
      if H.in_r == 1 then
	S.concatr[sprintf("G*u.signal")];
      else
	for j=1:H.in_r
	  S.concatr[sprintf("G[%d]*u[%d].signal",j,j)];
	end
      end
      txt.concatd[start + catenate(S,sep='+') + ";"];
    else
      for i=1:H.out_r
	start = sprintf("    y[%d].signal=",i);
	S=m2s([]);
	if H.in_r == 1 then
	  S.concatr[sprintf("G[%d,1]*u.signal",i)];
	else
	  for j=1:H.in_r
	    S.concatr[sprintf("G[%d,%d]*u[%d].signal",i,j,j)];
	  end
	end
	txt.concatd[start + catenate(S,sep='+') + ";"];
      end
    end
    txt.concatd[sprintf("end %s;", H.nameF)];
  endfunction
  
  function blk= MB_Gain_define(Gstr, old)
    if nargin <= 1 then 
      global(modelica_count=0);
      nameF='gain'+string(modelica_count);
      modelica_count =       modelica_count +1;
    else
      nameF=old.graphics.exprs.nameF;
    end
    context=acquire('%scicos_context',def=hash(4));
    [ok,He] = execstr(sprintf("G=%s;",Gstr),env=context,errcatch=%t);
    if ok then
      G=He.G; [m,n]=size(He.G);
    else
      lasterror();
      G=[]; [m,n]=(-1,-2);
    end
    H=hash(in=["u"], intype="I", in_r=[n], in_c=[1],
	   out=["y"], outtype="I", out_r=[m], out_c=[1],
	   param=['G'], paramv=list(G), pprop=[0], nameF=nameF);
    
    H.funtxt = MB_Gain_funtxt(H);
    
    if nargin == 2 then
      blk = VMBLOCK_define(H,old);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.gains = Gstr;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.model.in = [n];blk.model.in2=1;
      blk.model.out = [m];blk.model.out2=1;
    else
      blk = VMBLOCK_define(H);
      blk.graphics.exprs.funtxt = H.funtxt;
      blk.graphics.exprs.gains = Gstr;
      blk.model.sim(1) = H.nameF;
      blk.model.equations.model = H.nameF;
      blk.graphics.exprs.nameF = H.nameF;
      blk.graphics('3D') = %f; // coselica options 
      blk.graphics.gr_i="blk_draw(o,sz,orig,orient,model.label)";
      blk.gui = "MB_Gain";
      blk.model.in = [n];blk.model.in2=1;
      blk.model.out = [m];blk.model.out2=1;
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
      Gstr=x.graphics.exprs.gains;
      context=acquire('%scicos_context',def=hash(4));
      [ok_eval,H] = execstr(sprintf("G=%s;",Gstr),env=context,errcatch=%t);
      if x.model.in > 0 && size(H.G,'*')==1 then
	// must promote the scalar gain 
	Gstr=smat_create(x.model.in,1,Gstr);
	Gstr="diag(["+catenate(Gstr,sep=";")+"])";
	x.graphics.exprs.gains=Gstr;
      end
      gv_titles='Set MB_Gain block parameters';
      gv_names=['Gain'];
      gv_types = list('mat',[-1,-1]);
      [ok,G_new, Gstr_new]=getvalue(gv_titles,gv_names,gv_types,list(Gstr));
      if ~ok then return;end; // cancel in getvalue;
      x= MB_Gain_define(Gstr,x);
      if ~ok_eval || ~G_new.equal[H.G] then
	y=4;
	x.graphics.exprs.gains =  Gstr_new;
      end
      resume(needcompile=y);
    case 'define' then
      if nargin == 2 then G=arg1;else G="2";end
      x= MB_Gain_define(G);
  end

endfunction

