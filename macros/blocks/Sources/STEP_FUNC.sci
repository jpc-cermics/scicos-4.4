function [x,y,typ]=STEP_FUNC(job,arg1,arg2)
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
    graphics=arg1.graphics;
    exprs=graphics.exprs
    Btitre="Set block parameters"
    Exprs0=["s1";"s2";"s3"]
    Bitems=["Step time";"Initial value";"Final value"]
    Ss=list("vec",1,"vec",1,"vec",1)
    context=hash(0);
    x=arg1;
    ok=%f
    while ~ok do
      [ok,context.s1,context.s2,context.s3,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
      if ~ok then return;end
      sblock=x.model.rpar;
      [new_context,ierr]=script2var(sblock.props.context,context)
      if ierr==0 then
	// re-evaluate parameters using context 
	[sblock,%w,needcompile2,ok]=do_eval(sblock,list(),context)
	if ok then
          y=max(2,y,needcompile2)
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
	end
      else
	err=lasterror();
	if ~isempty(err) then message(err);end
	ok=%f;
      end
    end
   case 'define' then
     x=step_func_define();
   case 'upgrade' then
     x=arg1;
  end
endfunction

function x=step_func_define()
  x_0=scicos_diagram();
  x_1=scicos_params();
  x_1.context=      [ " " ]

  x_0.props=x_1;clear('x_1');

  x_1=list();
  x_2=STEP('define');
  x_2.graphics.peout=       [   2 ]
  x_2.graphics.exprs=       [ "s1";  "s2";  "s3" ]
  x_2.graphics.pout=       [   4 ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.pein=       [   2 ]
  x_2.graphics.orig=       [   329.3040,   162.0107 ]
  x_1(1)=x_2;clear('x_2');

  x_2=scicos_link();
  x_2.xx=       [   349.3040; 349.3040; 349.9583; 307.8288; 307.8288; 307.8288; 308.5552; 349.3040; 349.3040 ]
  x_2.id=       [ "" ]
  x_2.from=       [   1,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   1,   1,   1 ]
  x_2.yy=       [   156.2964;144.5654;144.5654;144.5654;145.2949;224.0773;224.0773;224.0773;207.7250 ]
  x_1(2)=x_2;clear('x_2');

  x_2=SAMPHOLD_m('define');
  x_2.graphics.pin=       [   4 ]
  x_2.graphics.pout=       [   8 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.pein=       [   6 ]
  x_2.graphics.orig=       [   410.2471,   162.0107 ]
  x_1(3)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   377.8754; 401.6757 ]
  x_2.id=       [ "" ]
  x_2.from=       [   1,   1,   0 ]
  x_2.to=       [   3,   1,   1 ]
  x_2.yy=       [   182.0107; 182.0107 ]
  x_1(4)=x_2;clear('x_2');
  x_2=SampleCLK('define');
  x_2.graphics.peout=       [   6 ]
  x_2.graphics.exprs=       [ "0";
		    "0" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_2.graphics.orig=       [   400.2471,   243.7730 ]
  x_1(5)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   430.2471;
		    430.2471 ]
  x_2.id=       [ "" ]
  x_2.from=       [   5,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   3,   1,   1 ]
  x_2.yy=       [   243.7730; 207.7250 ]
  x_1(6)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.pin=       [   8 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   478.8185,   172.0107 ]
  x_1(7)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   458.8185; 478.8185 ]
  x_2.id=       [ "" ]
  x_2.from=       [   3,   1,   0 ]
  x_2.to=       [   7,   1,   1 ]
  x_2.yy=       [   182.0107; 182.0107 ]
  x_1(8)=x_2;clear('x_2');
  x_0.objs=x_1;clear('x_1');
  x_0.version=     [ "scicos4.4" ]
  sblock=x_0;clear('x_0');
  
  model=scicos_model()
  model.sim="csuper"
  model.in=[]
  model.in2=[]
  model.intyp=1
  model.out=-1
  model.out2=-2
  model.outtyp=-1
  model.evtin=[]
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.odstate=list()
  model.rpar=sblock;
  model.ipar=1
  model.opar=list()
  model.blocktype="h"
  model.firing=[]
  model.dep_ut=[%f,%f]
  model.label=""
  model.nzcross=0
  model.nmode=0
  model.equations=list()
  s3=1; s2=0; s1=1;
  exprs=[sci2exp(s1,0);sci2exp(s2,0);sci2exp(s3,0)]
  gr_i=['xp=orig(1)+[0.071;0.413;0.413;0.773]*sz(1);';
	'yp=orig(2)+[0.195;0.195;0.635;0.635]*sz(2);';
	'xpoly(xp,yp,type='"lines"',color=1)'];
  x=standard_define([2,2],model,exprs,gr_i,'STEP_FUNC');
endfunction
