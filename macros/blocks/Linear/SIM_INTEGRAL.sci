function [x,y,typ]=SIM_INTEGRAL(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),
	  orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),type="lines")
    txt="1/s";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction

  function [ok,model,graphics]=SIM_INTEGRAL_check(model,graphics,x0,reinit,satur,maxp,lowp,new_exprs)
    ok = %t;model = model; graphics=graphics;
    // crossings due to saturation 
    if satur<>0 then
      if size(maxp,'*')==1 then maxp=maxp*ones(size(x0)),end
      if size(lowp,'*')==1 then lowp=lowp*ones(size(x0)),end
      if (size(x0)<>size(maxp) | size(x0)<>size(lowp)) then
	message('x0 and Upper limit and Lower limit must have same size')
	ok=%f;return;
      elseif or(maxp<=lowp)  then
	message('Upper limits must be > Lower limits')
	ok=%f;return;
      elseif or(x0>maxp)|or(x0<lowp) then
	message('Inital condition x0 should be inside the limits')
	ok=%f;return;
      else
	model.rpar=[real(maxp(:));real(lowp(:))]
	model.nzcross=size(x0,'*')
	model.nmode=size(x0,'*')
      end
    else
      model.rpar=[]
      model.nzcross=0
      model.nmode=0
    end
    
    model.state=real(x0(:))
    model.sim=list('integral_func',4)
    
    if reinit<>0 then reinit=1;end
    it=[1;ones(reinit,1)]
    ot=1;
    if size(x0,"*")>1 then
      in=[size(x0,1)*[1;ones(reinit,1)],size(x0,2)*[1;ones(reinit,1)]]
      out=size(x0)
    else
      in=[-1*[1;ones(reinit,1)],[1;ones(reinit,1)]]
      out=[-1,1]
    end
    [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(reinit,1),[])
    x.model = model;
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    gv_title = "Set Integral block parameters";
    gv_names = ["Initial Condition is external (1:yes, 0:no)";
		"Internal initial Condition";
	        "With re-intialization (1:yes, 0:no)";
		"With saturation (1:yes, 0:no)";
		"Upper limit";
		"Lower limit"],..
    gv_types = list("vec",1,"mat",[-1 -1],"vec",1,"vec",1,"mat",[-1 -1],"mat",[-1 -1]);
        
    while %t do
      [ok,init_is_external,x0,reinit,satur,maxp,lowp,new_exprs]=getvalue(gv_title, gv_names,gv_types, x.graphics.exprs);
      if ~ok then break,end
      if init_is_external<>0 then
	Integral_m_exprs= new_exprs(2:$);
	Integral_m_exprs(2)= "1";
	[scs_m]= SIM_INTEGRAL_define(Integral_m_exprs);
	scs_m = do_silent_eval(scs_m);
	x.model.rpar = scs_m;
	x.model.sim= 'csuper';
	x.graphics.exprs = new_exprs;
	it=[1;1];
	ot=1;
	in=[-1*[1;1],[1;1]];
	out=[-1,1];
	[x.model,x.graphics,ok]=set_io(x.model,x.graphics,list(in,it),list(out,ot),ones(reinit,1),[])
	break;
      else
	[ok,model,graphics]=SIM_INTEGRAL_check(x.model,x.graphics,x0,reinit,satur,maxp,lowp,new_exprs)
	if ok then
	  x.model = model;
	  x.graphics = graphics;
	  x.graphics.exprs = new_exprs;
	  break;
	end
      end
    end
    
   case 'compile' then
     model=arg1;
     if type(model.rpar,'short') == 'm' then
       // standard integrator block 
       if size(model.state,"*")==1 then
	 model.state(1:model.in(1),1:model.in2(1))=model.state
	 if model.nzcross>0 then
	   x0=model.state
	   nx=size(x0,'*')
	   rpar=model.rpar
	   if isreal(x0) then
	     model.nzcross=nx
	     model.nmode=nx
	     if size(rpar,1)==2 then model.rpar=duplicate(rpar,[nx;nx]),end
	   else
	     model.nzcross=2*nx
	     model.nmode=2*nx
	     if size(rpar,1)==4 then model.rpar=duplicate(rpar,[nx;nx;nx;nx]),end
	   end
	 end
       end
     end
     x=model;
   case 'define' then
    maxp=1;minp=-1;rpar=[]
    model=scicos_model()
    model.state=0
    model.sim=list('integral_func',4)
    model.in=-1
    model.out=-1
    model.in2=-2
    model.out2=-2
    model.rpar=rpar
    model.blocktype='c'
    model.dep_ut=[%f %t]

    exprs=string([0;0;0;0;maxp;minp])
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'SIM_INTEGRAL');
  end
endfunction

function [scs_m]= SIM_INTEGRAL_define(exprs)
  
  scs_m = instantiate_diagram ();
  blk0 = IN_f('define');
  params = cell (0, 2);
  params.concatd [ { "prt", '1' } ];
  params.concatd [ { "otsz", '-1' } ];
  params.concatd [ { "ot", '-1' } ];
  blk0 = set_block_parameters (blk0, params);
  blk0 = set_block_size (blk0, [15, 10]);
  blk0 = set_block_origin (blk0, [0, 100]);
  [scs_m, block_tag5] = add_block (scs_m, blk0, 'in1');

  blk0 = IN_f('define');
  params = cell (0, 2);
  params.concatd [ { "prt", '2' } ];
  params.concatd [ { "otsz", '-1' } ];
  params.concatd [ { "ot", '-1' } ];
  blk0 = set_block_parameters (blk0, params);
  blk0 = set_block_size (blk0, [15, 10]);
  blk0 = set_block_origin (blk0, [0, 0]);
  [scs_m, block_tag6] = add_block (scs_m, blk0, 'in2');

  blk0 = OUT_f('define');
  params = cell (0, 2);
  params.concatd [ { "prt", '1' } ];
  blk0 = set_block_parameters (blk0, params);
  blk0 = set_block_size (blk0, [15, 10]);
  blk0 = set_block_origin (blk0, [300, 0]);
  [scs_m, block_tag7] = add_block (scs_m, blk0, 'out');

  blk0 = INTEGRAL_m('define');
  blk0.graphics.exprs = exprs;
  blk0 = set_block_nin (blk0, 2);
  blk0 = set_block_nout (blk0, 1);
  blk0 = set_block_size (blk0, [30, 30]);
  blk0 = set_block_origin (blk0, [100, 0]);
  [scs_m, block_tag8] = add_block (scs_m, blk0, 'integrator');
  
  blk0 = EVTGEN_f('define');
  params = cell (0, 2);
  params.concatd [ { "tt", '0' } ];
  blk0 = set_block_parameters (blk0, params);
  blk0 = set_block_size (blk0, [30,30]);
  blk0 = set_block_origin (blk0, [100, 100]);
  [scs_m, block_tag9] = add_block (scs_m, blk0, 'event_gen');

  scs_m = add_explicit_link (scs_m, [block_tag5, '1'], [block_tag8, '1'], []);
  scs_m = add_explicit_link (scs_m, [block_tag6, '1'], [block_tag8, '2'], []);
  scs_m = add_explicit_link (scs_m, [block_tag8, '1'], [block_tag7, '1'], []);
  scs_m = add_event_link (scs_m, [block_tag9, '1'], [block_tag8, '1'], []);
  
endfunction


