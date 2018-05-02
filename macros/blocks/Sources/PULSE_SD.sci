function [x,y,typ]=PULSE_SD(job,arg1,arg2)
//Generated from SuperBlock on 7-Feb-2008
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
     arg1.model.ipar=1;
    typ=list()
    graphics=arg1.graphics;
    exprs=graphics.exprs
    Btitre= "Set Pulse Generator parameters"
    Exprs0= ["E";"W";"F";"A"]
    Bitems= ["Phase delay (secs)";"Pulse Width (% of period)";"Period (secs)";"Amplitude"];
    Ss=list("vec",1,"vec",1,"vec",1,"mat",[-1 -1])
    context=hash(10);
    x=arg1;
    ok=%f
    while ~ok do
      [ok,context.E,context.W,context.F,context.A,exprs]=getvalue(Btitre,Bitems,Ss,exprs);
      if ~ok then return;end
      sblock=x.model.rpar
      // evaluates sblock context using the new values;
      // this is redondant with what is done in do_eval 
      // but gives more explicit messages to user in case of pbs
      [new_context,ierr]=script2var(sblock.props.context,context);
      if ierr==0 then
	// re-evaluate parameters using context 
	[sblock,%w,needcompile2,ok]=do_eval(sblock,list(),context)
	if ok then
          y=max(2,y,needcompile2);
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
	end
      else
	message(lasterror());
	ok=%f
      end
    end
   case 'define' then
    x= pulse_sd_gener();
  end
endfunction

function x=pulse_sd_gener()
  x_0=scicos_diagram();
  x_1=scicos_params();
  x_1.context= [ "E2=E+W/100*F";
		 "if (W<0 | W>100) then error(''Width must be between 0 and 100'');end";
		 "E2=modulo(E2,F)" ];
  x_1.Title=  [ "SuperBlock", "/home/fady/Scicos_examples/" ]
  x_1.tf=     [   10 ]
  x_1.tol=    [   1.000e-04; 1.000e-06; 1.000e-10; 1.000e+05; 0; 0; 0 ]
  x_1.wpar= [-162.7581, 435.5437, 67.6073, 416.6764, 827.0000, 479.0000, ...
	     0, 15.0000, 827.0000, 480.0000, 715.0000, 167.0000, 1.4000 ]
  x_0.props=x_1;clear('x_1');
  x_1=list();
  x_2=CONST_m('define');
  x_2.graphics.exprs=       [ "A" ]
  x_2.graphics.pout=       [   5 ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.orig=       [    30.8012,   158.9173 ]
  x_1(1)=x_2;clear('x_2');
  x_2=Ground_g('define');
  x_2.graphics.pout=       [   4 ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.orig=       [    31.5345,   215.3840 ]
  x_1(2)=x_2;clear('x_2');
  x_2=SELECT_m('define');
  x_2.graphics.exprs=  [ "-1"; "2"; "1+b2m(E2<E)" ]
  x_2.graphics.pin=       [   4;  5 ]
  x_2.graphics.pout=       [   11 ]
  x_2.graphics.in_implicit=       [ "E"; "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.pein=       [   9; 8 ]
  x_2.graphics.orig=       [   106.0065,   186.0938 ]
  x_1(3)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   80.1060;  97.4351;  97.4351 ]
  x_2.yy=       [   235.3840; 235.3840; 212.7605 ]
  x_2.from=       [   2,   1,   0 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(4)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   79.3726;  97.4351;   97.4351 ]
  x_2.yy=       [   178.9173; 178.9173; 199.4271 ]
  x_2.from=       [   1,   1,   0 ]
  x_2.to=       [   3,   2,   1 ]
  x_1(5)=x_2;clear('x_2');
  x_2=SampleCLK('define');
  x_2.graphics.peout=       [   9 ]
  x_2.graphics.exprs=       [ "F";"E2" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_2.graphics.orig=       [    82.3497,   274.2174 ]
  x_1(6)=x_2;clear('x_2');
  x_2=SampleCLK('define');
  x_2.graphics.peout=       [   8 ]
  x_2.graphics.exprs=       [ "F"; "E" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_2.graphics.orig=       [   160.4888,   274.2174 ]
  x_1(7)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   190.4888;  190.4888; 132.6732; 132.6732 ]
  x_2.yy=       [   274.2174;  240.9905; 240.9905; 231.8081 ]
  x_2.from=     [   7,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   3,   2,   1 ]
  x_1(8)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   112.3497; 112.3497; 119.3398; 119.3398 ]
  x_2.yy=       [   274.2174; 248.2137; 248.2137; 231.8081 ]
  x_2.from=     [   6,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(9)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.pin= [   11 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.sz=  [   20,   20 ]
  x_2.graphics.orig=[   174.5779,   196.0938 ]
  x_1(10)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   154.5779;174.5779 ]
  x_2.yy=       [   206.0938;206.0938 ]
  x_2.from=       [   3,   1,   0 ]
  x_2.to=       [   10,    1,    1 ]
  x_1(11)=x_2;clear('x_2');
  x_0.objs=x_1;clear('x_1');
  x_0.version=     [ "scicos4.2" ]
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
  E=0.1; W=30; F=1; A=1;
  exprs=[sci2exp(E); sci2exp(W); sci2exp(F); sci2exp(A)];
  gr_i=list(..
	    ["xx=[1 3 3 3 5 5 5 7]/8;";
	     "yy=[1 1 3 1 1 3 1 1]/4;";
	     "x=orig(1)*ones(1,8)+sz(1)*xx;";
	     "y=orig(2)*ones(1,8)+sz(2)*yy;";
	     "xpolys(x'',y'');"],8)
  x=standard_define([3,2],model,exprs,gr_i,'PULSE_SD');
endfunction
