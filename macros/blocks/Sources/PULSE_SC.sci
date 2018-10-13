function [x,y,typ]=PULSE_SC(job,arg1,arg2)
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
     arg1.model.ipar=1;
    typ=list()
    graphics=arg1.graphics;
    exprs=graphics.exprs
    Btitre= "Set Pulse Generator parameters"
    Exprs0= ["E";"W";"F";"A"]
    Bitems= ["Phase delay (secs)";"Pulse Width (% of period)";"Period (secs)";"Amplitude"];
    Ss=list("pol",-1,"pol",-1,"pol",-1,"mat",[-1 -1])
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
          y=max(2,y,needcompile2)
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
     scs_m= pulse_sc_define();
     model=scicos_model(sim="csuper",in=[],in2=[],intyp=1,out=-1,out2=-2,outtyp=-1,
			evtin=[],evtout=[],state=[],dstate=[],odstate=list(),
			rpar=scs_m,ipar=1,opar=list(),blocktype="h",firing=[],
			dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
     E=0.1; W=30; F=1; A=1;
     exprs=[sci2exp(E); sci2exp(W); sci2exp(F); sci2exp(A)];
     gr_i=list(["xx=[1 3 3 3 5 5 5 7]/8;";
		"yy=[1 1 3 1 1 3 1 1]/4;";
		"x=orig(1)*ones(1,8)+sz(1)*xx;";
		"y=orig(2)*ones(1,8)+sz(2)*yy;";
		"xpolys(x'',y'');"],8)
     x=standard_define([3,2],model,exprs,gr_i,'PULSE_SC');
   case 'upgrade' then
     x=arg1;
  end
endfunction

function scs_m=pulse_sc_define()
  
  scs_m=scicos_diagram();

  params=scicos_params();
  params.context= [ "E2=E+W/100*F";
		    "if (W<0 | W>100) then error(''Width must be between 0 and 100'');end";
		    "if (E2 >= F) then error (''Offset must be lower than (frequency*(1-Width/100))''); end"];
  params.Title=  [ "SuperBlock", "/home/fady/Scicos_examples/" ]
  params.tf=     [   10 ]
  params.tol=    [   1.000e-04; 1.000e-06; 1.000e-10; 1.000e+05; 0; 0; 0 ]
  params.wpar= [-162.7581, 435.5437, 67.6073, 416.6764, 827.0000, 479.0000, ...
	     0, 15.0000, 827.0000, 480.0000, 715.0000, 167.0000, 1.4000 ]
  scs_m.props=params;
  
  blk=CONST_m('define');
  blk.graphics.exprs=       [ "A" ]
  blk.graphics.pout=       [   5 ]
  blk.graphics.out_implicit=       [ "E" ]
  blk.graphics.sz=       [   40,   40 ]
  blk.graphics.orig=       [    30.8012,   158.9173 ]
  scs_m.objs(1)=blk;

  blk=Ground_g('define');
  blk.graphics.pout=       [   4 ]
  blk.graphics.out_implicit=       [ "E" ]
  blk.graphics.sz=       [   40,   40 ]
  blk.graphics.orig=       [    31.5345,   215.3840 ]
  scs_m.objs(2)=blk;

  blk=SELECT_m('define');
  blk.graphics.exprs=  [ "-1"; "2"; "1" ]
  blk.graphics.pin=       [   4;  5 ]
  blk.graphics.pout=       [   11 ]
  blk.graphics.in_implicit=       [ "E"; "E" ]
  blk.graphics.out_implicit=       [ "E" ]
  blk.graphics.sz=       [   40,   40 ]
  blk.graphics.pein=       [   9; 8 ]
  blk.graphics.orig=       [   106.0065,   186.0938 ]
  scs_m.objs(3)=blk;

  blk=scicos_link();
  blk.xx=       [   80.1060;  97.4351;  97.4351 ]
  blk.yy=       [   235.3840; 235.3840; 212.7605 ]
  blk.from=       [   2,   1,   0 ]
  blk.to=       [   3,   1,   1 ]
  scs_m.objs(4)=blk;

  blk=scicos_link();
  blk.xx=       [   79.3726;  97.4351;   97.4351 ]
  blk.yy=       [   178.9173; 178.9173; 199.4271 ]
  blk.from=       [   1,   1,   0 ]
  blk.to=       [   3,   2,   1 ]
  scs_m.objs(5)=blk;

  blk=SampleCLK('define');
  blk.graphics.peout=       [   9 ]
  blk.graphics.exprs=       [ "F";"E2" ]
  blk.graphics.sz=       [   60,   40 ]
  blk.graphics.orig=       [    82.3497,   274.2174 ]
  scs_m.objs(6)=blk;

  blk=SampleCLK('define');
  blk.graphics.peout=       [   8 ]
  blk.graphics.exprs=       [ "F"; "E" ]
  blk.graphics.sz=       [   60,   40 ]
  blk.graphics.orig=       [   160.4888,   274.2174 ]
  scs_m.objs(7)=blk;

  blk=scicos_link();
  blk.xx=       [   190.4888;  190.4888; 132.6732; 132.6732 ]
  blk.yy=       [   274.2174;  240.9905; 240.9905; 231.8081 ]
  blk.from=     [   7,   1,   0 ]
  blk.ct=       [    5,   -1 ]
  blk.to=       [   3,   2,   1 ]
  scs_m.objs(8)=blk;

  blk=scicos_link();
  blk.xx=       [   112.3497; 112.3497; 119.3398; 119.3398 ]
  blk.yy=       [   274.2174; 248.2137; 248.2137; 231.8081 ]
  blk.from=     [   6,   1,   0 ]
  blk.ct=       [    5,   -1 ]
  blk.to=       [   3,   1,   1 ]
  scs_m.objs(9)=blk;

  blk=OUT_f('define');
  blk.graphics.pin= [   11 ]
  blk.graphics.in_implicit=       [ "E" ]
  blk.graphics.sz=  [   20,   20 ]
  blk.graphics.orig=[   174.5779,   196.0938 ]
  scs_m.objs(10)=blk;

  blk=scicos_link();
  blk.xx=       [   154.5779;174.5779 ]
  blk.yy=       [   206.0938;206.0938 ]
  blk.from=       [   3,   1,   0 ]
  blk.to=       [   10,    1,    1 ]
  scs_m.objs(11)=blk;
  
endfunction

