function [x,y,typ]=PID2(job,arg1,arg2)
  //Generated from PID on 5-Jan-2009
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
      graphics=arg1.graphics;
      exprs=graphics.exprs
      Btitre=..
      "Set PID parameters"
      Exprs0=..
      ["p";"i";"d"]
      Bitems=..
      ["Proportional";"Integral";"Derivative"]
      Ss=..
      list("pol",-1,"pol",-1,"pol",-1)
      scicos_context=hash(10)
      x=arg1
      ok=%f
      while ~ok do
	[ok,scicos_context.p,scicos_context.i,scicos_context.d,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
	if ~ok then return;end
	%scicos_context=scicos_context
	sblock=x.model.rpar
	[%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
	if ierr==0 then
	  [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)
	  if ok then
            y=max(2,y,needcompile2);
            x.graphics.exprs=exprs
            x.model.rpar=sblock
            break
	  end
	else
	  message(lasterror())
	  ok=%f
	end
      end
    case 'define' then
      scs_m_1= PID_diagram("p","i","d");
      model=scicos_model()
      model.sim="csuper"
      model.in=-1
      model.in2=-2
      model.intyp=-1
      model.out=-1
      model.out2=-2
      model.outtyp=-1
      model.evtin=[]
      model.evtout=[]
      model.state=[]
      model.dstate=[]
      model.odstate=list()
      model.rpar=scs_m_1
      model.ipar=1
      model.opar=list()
      model.blocktype="h"
      model.firing=[]
      model.dep_ut=[%f,%f]
      model.label=""
      model.nzcross=0
      model.nmode=0
      model.equations=list()
      p=1
      i=2
      d=1
      exprs=[sci2exp(p,0)
	     sci2exp(i,0)
	     sci2exp(d,0) ]
      gr_i=list("xstringb(orig(1),orig(2),""PID"",sz(1),sz(2),''fill'');",8)
      x=standard_define([2,2],model,exprs,gr_i,'PID2');
  end
endfunction
