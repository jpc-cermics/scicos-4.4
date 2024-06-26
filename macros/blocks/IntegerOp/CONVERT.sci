function [x,y,typ]=CONVERT(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    VOP=['    double ','    double ','    int32 ','    int16 ',...
	 '    int8 ','    uint32 ','    uint16 ','    uint8 ']
    if or(stripblanks(arg1.graphics.exprs(2))==['1','2','3','4','5','6','7','8']) then
      iid=evstr( arg1.graphics.exprs(2))
    else
      iid=0
    end
    if iid>0 then  OPER=VOP(iid), else OPER="other type",end
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
    while %t do
      [ok,it,ot,np,exprs]=getvalue('Set CONVERT block parameters',..
				   ['Input type (-1=inherit 1=double 3=int32  4=int16 5=int8 ...)';..
		    'Output type (-2=inherit 1=double 3=int32 4=int16 ...)';..
		    'Do on Overflow(0=Nothing 1=Saturate 2=Error)'],..
				   list('vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      if (np~=0 & np~=1 & np~=2) then message ("type is not supported");ok=%f;end
      if it==2 then it =1;end
      if ot==2 then ot=1;end
      if (it>9|it==0|it<-1) then message ("input type is not supported");ok=%f;end
      if (ot>9|ot==0|ot<-2) then message ("output type is not supported");ok=%f;end
      model.sim=list('convert',4)
      model.ipar=-np-1;
      in=[model.in model.in2]
      out=[model.out model.out2]
      if ok then
	[model,graphics,ok]=set_io(model,graphics,...
				   list(in,it),...
				   list(out,ot),[],[])
      end
      if ok then
	graphics.exprs=exprs
	x.graphics=graphics;x.model=model
	break
      end
    end

   case 'compile'
    model=arg1
    if model.ipar<0 then 
      np= -model.ipar-1
    elseif model.ipar<38 then
      np=0
    elseif model.ipar<65 then
      np=1
    else
      np=2        
    end
    it=model.intyp
    ot=model.outtyp
    if (it==ot) then
      model.ipar=1;
    elseif it==9 then
      if ot==1 then model.ipar=96;
      elseif ot==3|ot==6 then model.ipar=1;
      elseif ot==4|ot==7 then model.ipar=97;
      elseif ot==5|ot==8 then model.ipar=98;
      end
    elseif ot==9 then
      if it==1 then model.ipar=92;
      elseif it==3|it==6 then model.ipar=93;
      elseif it==4|it==7 then model.ipar=94;
      elseif it==5|it==8 then model.ipar=95;
      end
    else
      if (np==0) then	
	if (it==1) then
	  if (ot==3) then model.ipar=2;
	  elseif (ot==4) then model.ipar=3;
	  elseif (ot==5) then model.ipar=4;
	  elseif (ot==6) then model.ipar=5;
	  elseif (ot==7) then model.ipar=6;
	  elseif (ot==8) then model.ipar=7;
	  end
	elseif (it==3) then
	  if (ot==1) then model.ipar=8;
	  elseif (ot==4) then model.ipar=9;
	  elseif (ot==5) then model.ipar=10;
	  elseif (ot==6) then model.ipar=1;
	  elseif (ot==7) then model.ipar=11;
	  elseif (ot==8) then model.ipar=12;
	  end
	elseif (it==4) then
	  if (ot==1) then model.ipar=13;
	  elseif (ot==3) then model.ipar=14;
	  elseif (ot==5) then model.ipar=15;
	  elseif (ot==6) then model.ipar=16;
	  elseif (ot==7) then model.ipar=1;
	  elseif (ot==8) then model.ipar=17;
	  end
	elseif (it==5) then
	  if (ot==1) then model.ipar=18;
	  elseif (ot==3) then model.ipar=19;
	  elseif (ot==4) then model.ipar=20;
	  elseif (ot==6) then model.ipar=21;
	  elseif (ot==7) then model.ipar=22;
	  elseif (ot==8) then model.ipar=1;
	  end
	elseif (it==6) then
	  if (ot==1) then model.ipar=23;
	  elseif (ot==3) then model.ipar=1;
	  elseif (ot==4) then model.ipar=24;
	  elseif (ot==5) then model.ipar=25;
	  elseif (ot==7) then model.ipar=26;
	  elseif (ot==8) then model.ipar=27;
	  end
	elseif (it==7) then
	  if (ot==1) then model.ipar=28;
	  elseif (ot==3) then model.ipar=29;
	  elseif (ot==4) then model.ipar=1;
	  elseif (ot==5) then model.ipar=30;
	  elseif (ot==6) then model.ipar=31;
	  elseif (ot==8) then model.ipar=32;
	  end
	elseif (it==8) then
	  if (ot==1) then model.ipar=33;
	  elseif (ot==3) then model.ipar=34;
	  elseif (ot==4) then model.ipar=35;
	  elseif (ot==5) then model.ipar=1;
	  elseif (ot==6) then model.ipar=36;
	  elseif (ot==7) then model.ipar=37;
	  end
	end
      elseif (np==1) then
	if (it==1) then
	  if (ot==3) then model.ipar=38;
	  elseif (ot==4) then model.ipar=39;
	  elseif (ot==5) then model.ipar=40;
	  elseif (ot==6) then model.ipar=41;
	  elseif (ot==7) then model.ipar=42;
	  elseif (ot==8) then model.ipar=43;
	  end
	elseif (it==3) then
	  if (ot==1) then model.ipar=8;
	  elseif (ot==4) then model.ipar=44;
	  elseif (ot==5) then model.ipar=45;
	  elseif (ot==6) then model.ipar=46;
	  elseif (ot==7) then model.ipar=47;
	  elseif (ot==8) then model.ipar=48;
	  end
	elseif (it==4) then
	  if (ot==1) then model.ipar=13;
	  elseif (ot==3) then model.ipar=14;
	  elseif (ot==5) then model.ipar=49;
	  elseif (ot==6) then model.ipar=50;
	  elseif (ot==7) then model.ipar=51;
	  elseif (ot==8) then model.ipar=52;
	  end
	elseif (it==5) then
	  if (ot==1) then model.ipar=18;
	  elseif (ot==3) then model.ipar=19;
	  elseif (ot==4) then model.ipar=20;
	  elseif (ot==6) then model.ipar=53;
	  elseif (ot==7) then model.ipar=54;
	  elseif (ot==8) then model.ipar=55;
	  end
	elseif (it==6) then
	  if (ot==1) then model.ipar=23;
	  elseif (ot==3) then model.ipar=56;
	  elseif (ot==4) then model.ipar=57;
	  elseif (ot==5) then model.ipar=58;
	  elseif (ot==7) then model.ipar=59;
	  elseif (ot==8) then model.ipar=60;
	  end
	elseif (it==7) then
	  if (ot==1) then model.ipar=28;
	  elseif (ot==3) then model.ipar=29;
	  elseif (ot==4) then model.ipar=61;
	  elseif (ot==5) then model.ipar=62;
	  elseif (ot==6) then model.ipar=31;
	  elseif (ot==8) then model.ipar=63;
	  end
	elseif (it==8) then
	  if (ot==1) then model.ipar=33;
	  elseif (ot==3) then model.ipar=34;
	  elseif (ot==4) then model.ipar=35;
	  elseif (ot==5) then model.ipar=64;
	  elseif (ot==6) then model.ipar=36;
	  elseif (ot==7) then model.ipar=37;
	  end
	end
      elseif (np==2) then
	if (it==1) then
	  if (ot==3) then model.ipar=65;
	  elseif (ot==4) then model.ipar=66;
	  elseif (ot==5) then model.ipar=67;
	  elseif (ot==6) then model.ipar=68;
	  elseif (ot==7) then model.ipar=69;
	  elseif (ot==8) then model.ipar=70;
	  end
	elseif (it==3) then
	  if (ot==1) then model.ipar=8;
	  elseif (ot==4) then model.ipar=71;
	  elseif (ot==5) then model.ipar=72;
	  elseif (ot==6) then model.ipar=73;
	  elseif (ot==7) then model.ipar=74;
	  elseif (ot==8) then model.ipar=75;
	  end
	elseif (it==4) then
	  if (ot==1) then model.ipar=13;
	  elseif (ot==3) then model.ipar=14;
	  elseif (ot==5) then model.ipar=76;
	  elseif (ot==6) then model.ipar=77;
	  elseif (ot==7) then model.ipar=78;
	  elseif (ot==8) then model.ipar=79;
	  end
	elseif (it==5) then
	  if (ot==1) then model.ipar=18;
	  elseif (ot==3) then model.ipar=19;
	  elseif (ot==4) then model.ipar=20;
	  elseif (ot==6) then model.ipar=80;
	  elseif (ot==7) then model.ipar=81;
	  elseif (ot==8) then model.ipar=82;
	  end
	elseif (it==6) then
	  if (ot==1) then model.ipar=23;
	  elseif (ot==3) then model.ipar=83;
	  elseif (ot==4) then model.ipar=84;
	  elseif (ot==5) then model.ipar=85;
	  elseif (ot==7) then model.ipar=86;
	  elseif (ot==8) then model.ipar=87;
	  end
	elseif (it==7) then
	  if (ot==1) then model.ipar=28;
	  elseif (ot==3) then model.ipar=29;
	  elseif (ot==4) then model.ipar=88;
	  elseif (ot==5) then model.ipar=89;
	  elseif (ot==6) then model.ipar=31;
	  elseif (ot==8) then model.ipar=90;
	  end
	elseif (it==8) then
	  if (ot==1) then model.ipar=33;
	  elseif (ot==3) then model.ipar=34;
	  elseif (ot==4) then model.ipar=35;
	  elseif (ot==5) then model.ipar=91;
	  elseif (ot==6) then model.ipar=36;
	  elseif (ot==7) then model.ipar=37;
	  end
	end
      end
    end
    model.intyp=it
    model.outtyp=ot
    x=model
   case 'define' then
    
    np=0
    model=scicos_model()
    model.sim=list('convert',4)
    model.in=-1
    model.out=-1
    model.in2=-2
    model.out2=-2
    model.intyp=1
    model.outtyp=3
    model.rpar=[]
    model.ipar=-np-1
    model.blocktype='c'
    model.dep_ut=[%t %f]

    
    exprs=[sci2exp(1);sci2exp(3);sci2exp(np)]
    gr_i=['xstringb(orig(1),orig(2),[''convert to'';OPER],sz(1),sz(2),''fill'');']
    x=standard_define([3 2],model, exprs,gr_i,'CONVERT')
  end
endfunction
