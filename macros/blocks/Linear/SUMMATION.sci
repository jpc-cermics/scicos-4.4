
function [x,y,typ]=SUMMATION(job,arg1,arg2)
// Copyright INRIA

  function SUMMATION_draw(o,sz,orig)
    [x,y,typ]=standard_inputs(o) 
    dd=sz(1)/8,de=0;
    if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end
    if ~exists("%zoom") then %zoom=1, end;
    fz=2*%zoom*4;
    for k=1:size(x,'*');
      if size(sgn,1) >= k then
	if sgn(k) > 0 then;
	  xstring(orig(1)+dd,y(k)-4,'+',size=fz);
	else;
	  xstring(orig(1)+dd,y(k)-4,'-',size=fz);
	end;
      end;
    end;
    xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de;
    yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2);
    xpoly(xx,yy,type='lines');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    sgn=arg1.model.ipar
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics
    model=arg1.model
    exprs=graphics.exprs
    if size(exprs,1)==1 then 
      exprs=[sci2exp(1);exprs;sci2exp(0)];
    elseif size(exprs,1)==2 then 
      exprs=[exprs;sci2exp(0)];
    end
    gv_titles=['Datatype (1=real double  2=complex 3=int32 ...)';
	       'Number of inputs or sign vector (of +1, -1)';
	       'Do on overflow(0=Nothing 1=Saturate 2=Error)'];
    
    while %t do
      [ok,Datatype,sgn,satur,exprs]=getvalue('Set sum block parameters',..
					     gv_titles,...
					     list('vec',1,'vec',-1,'vec',1),...
					     exprs);
      if ~ok then return;end // cancel in getvalue;
      sgn=sgn(:);
      if (satur ~=0 && satur~=1 && satur~=2) then 
	message("Do on overflow must be 0, or 1, or 2.");
	continue;
      end
      if size(sgn,1)==1 then 
	if sgn<1 then
	  message('Number of inputs must be > 0')
	  continue;
	elseif sgn==1 then
	  in=-1;in2=-2
	  sgn=[]
	  nout=1;nout2=1
	else
	  in=-ones(sgn,1);in2=2*in
	  sgn=ones(sgn,1)
	  nout=-1;nout2=-2
	end
      else
	if ~and(abs(sgn)==1) then
	  message('Signs can only be +1 or -1')
	  continue;
	else
	  in=-ones(size(sgn,1),1);in2=2*in
	  nout=-1;nout2=-2
	end
      end
      it=Datatype*ones(1,size(in,1));
      ot=Datatype;
      [model,graphics,ok]=set_io(model,graphics,...
				 list([in,in2],it),...
				 list([nout,nout2],ot),[],[])
      if ok then break;end 
    end
    model.rpar=satur;
    model.ipar=sgn
    graphics.exprs=exprs
    x.graphics=graphics;x.model=model
   case 'compile' then
    // 
    model=arg1
    satur=model.rpar
    model.rpar=[]
    Datatype=model.outtyp(1)
    Dt=["","_z","i32","i16","i8","ui32","ui16","ui8"];
    Tag=["n","s","e"];
    if Datatype==1 then 
      model.sim=list('summation',4)
    elseif Datatype==2 then
      model.sim=list('summation_z',4)
    elseif Datatype>8 then
      error("Datatype is not supported");
    else
      simstr=sprintf('summation_%s%s',Dt(Datatype),Tag(satur+1))
      model.sim=list(simstr,4);
    end
    x=model
    
   case 'define' then
    sgn=[1;-1]
    model=scicos_model()
    model.sim=list('summation',4)
    model.in=[-1;-1]
    model.out=-1
    model.in2=[-2;-2]
    model.out2=-2
    model.ipar=sgn
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=[sci2exp(1);sci2exp(sgn);sci2exp(0)];
    gr_i=['SUMMATION_draw(o,sz,orig);'];
    x=standard_define([2 3],model, exprs,gr_i,'SUMMATION');
  end
endfunction
