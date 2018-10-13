function [x,y,typ]=PID2(job,arg1,arg2)
  // contains a diagram inside
  
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
      y=acquire('needcompile',def=0);
      typ=list()
      x=arg1;
      exprs = x.graphics.exprs;
      Btitre= "Set PID parameters"
      Exprs0= ["p";"i";"d"]
      Bitems=  ["Proportional";"Integral";"Derivative"]
      Ss= list("pol",-1,"pol",-1,"pol",-1)
      s_context=hash(10)
      ok=%f
      while ~ok do
	[ok,s_context.p,s_context.i,s_context.d,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
	if ~ok then return;end
	%scicos_context=s_context
	scsm=x.model.rpar
	[%scicos_context,ierr]=script2var(scsm.props.context,%scicos_context)
	if ierr==0 then
	  [scsm,%w,needcompile2,ok]=do_eval(scsm,list(),%scicos_context)
	  if ok then
            y=max(2,y,needcompile2);
            x.graphics.exprs=exprs;
            x.model.rpar=scsm;
            break
	  end
	else
	  message(lasterror())
	  ok=%f
	end
      end
      resume(needcompile=y);
      
    case 'define' then
      scs_m_1= PID_diagram("p","i","d");
      model=scicos_model(sim="csuper",in=-1,in2=-2,intyp=-1,out=-1,
			 out2=-2,outtyp=-1,evtin=[],evtout=[],state=[],
			 dstate=[],odstate=list(),rpar=scs_m_1,ipar=1,
			 opar=list(),blocktype="h",firing=[],dep_ut=[%f,%f],
			 label="",nzcross=0,nmode=0,	equations=list())
      p=1; i=2; d=1;
      exprs=[sci2exp(p,0); sci2exp(i,0); sci2exp(d,0) ]
      gr_i=list("xstringb(orig(1),orig(2),""PID"",sz(1),sz(2),''fill'');",8)
      x=standard_define([2,2],model,exprs,gr_i,'PID2');
      x.graphics.exprs = exprs;
    case 'upgrade' then
      x=arg1
  end
endfunction
