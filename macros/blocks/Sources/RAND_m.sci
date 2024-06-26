function [x,y,typ]=RAND_m(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then //normal  position
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    if size(exprs,'*')==14 then exprs(9)=[],end //compatiblity
    while %t do
      [ok,typ,flag,a,b,seed_c,exprs]=getvalue([
	  'Set Random generator block parameters';
	  'flag = 0 : Uniform distribution A is min and A+B max';
	  'flag = 1 : Normal distribution A is mean and B deviation';
	  ' ';
	  'A and B must be matrix with equal sizes'],..
					      ['Datatype(1=real double  2=complex)';'Flag';'A';'B';'SEED'],..
					      list('vec',1,'vec',1,'mat',[-1 -2],'mat','[-1 -2]','mat',[1 2]),exprs)
      if ~ok then break,end
      if flag<>0&flag<>1 then
	message('flag must be equal to 1 or 0')
      else
	out=size(a)
	if typ==1 then
	  junction_name='rndblk_m';
	  model.rpar=[real(a(:));real(b(:))]
	  model.dstate=[seed_c(1);0*real(a(:))]
	  ot=1
	elseif typ==2 then
	  junction_name='rndblkz_m';
	  ot=2
	  model.rpar=[real(a(:));imag(a(:));real(b(:));imag(b(:))]
	  model.dstate=[seed_c(:);0*[real(a(:));imag(a(:))]]
	else message("Datatype is not supported");ok=%f;end
	  if ok then
	    [model,graphics,ok]=set_io(model,graphics,list([],[]),list(out,ot),1,[])
	    if ok then 
	      model.sim=list(junction_name,4)
	      graphics.exprs=exprs
	      model.ipar=flag
	      x.graphics=graphics;x.model=model
	      break
	    end
	  end
      end
    end
   case 'define' then
    a=0
    b=1
    dt=0
    flag=0
    junction_name='rndblk_m';
    funtyp=4;
    model=scicos_model()
    model.sim=list(junction_name,funtyp)
    model.in=[]
    model.in2=[]
    model.intyp=[]
    model.out=1
    model.out2=1
    model.outtyp=1
    model.evtin=1
    model.evtout=[]
    model.state=[]
    model.dstate=[int(rand()*(10^7-1));0*a(:)]
    model.rpar=[a(:),b(:)]
    model.ipar=flag
    model.blocktype='d' 
    model.firing=[]
    model.dep_ut=[%f %f]

    exprs=[sci2exp(1);string(flag);sci2exp([a]);sci2exp([b]);sci2exp([model.dstate(1) int(rand()*(10^7-1))])]
    gr_i=['txt=[''random'';''generator''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
    x=standard_define([3 2],model,exprs,gr_i,'RAND_m');
  end
endfunction
