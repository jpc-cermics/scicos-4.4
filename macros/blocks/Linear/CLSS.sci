function [x,y,typ]=CLSS(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[]
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
    x=arg1
    graphics=arg1.graphics;exprs=graphics.exprs
    if size(exprs,'*')==7 then exprs=exprs([1:4 7]),end //compatibility
    if size(exprs,1) >= 5 && exprs(5,1)=="0" || exprs(5,1)=="[]" then
      // try to fix x0 dimensions
      if ~exists('%scicos_context') then %scicos_context=hash(4);end
      Ai=evstr(exprs(1,1),%scicos_context);
      exprs(5,1)= sprintf("zeros(%d,1)",size(Ai,2));
    end
    model=arg1.model;
    while %t do
      [ok,A,B,C,D,x0,exprs]=getvalue('Set continuous linear system parameters',..
				     ['A matrix';
		    'B matrix';
		    'C matrix';
		    'D matrix';
		    'Initial state'],..
				     list('mat',[-1,-1],..
					  'mat',['size(%1,2)','-1'],..
					  'mat',['-1','size(%1,2)'],..
					  'mat',[-1 -1],..
					  'vec','size(%1,2)'),..
				     exprs)
      if ~ok then break,end
      out=size(C,1);if out==0 then out=[],end
      in=size(B,2);if in==0 then in=[],end
      [ms,ns]=size(A)
      okD=%t
      if size(D,'*')<>size(C,1)*size(B,2) then
	if size(D,'*')==1 then
	  D=ones_deprecated(C*B)*D
	elseif  size(D,'*')==0 then
	  D=zeros_deprecated(C*B)
	else
	  okD=%f
	end
      end
      if ms<>ns|~okD then
	message('A matrix is not square or D has wrong dimension')
      else
	[model,graphics,ok]=check_io(model,graphics,in,out,[],[])
	if ok then
	  graphics.exprs=exprs;
	  rpar=[A(:);B(:);C(:);D(:)];
	  if ~isempty(D) then
	    if norm(D,1)<>0 then
	      mmm=[%t %t];
	    else
	      mmm=[%f %t];
	    end
	    if or(model.dep_ut<>mmm) then
	      model.dep_ut=mmm,end
	  else
	    model.dep_ut=[%f %t];
	  end
	  model.state=x0(:);model.rpar=rpar
	  x.graphics=graphics;x.model=model
	  break
	end
      end
    end
   case 'define' then
    x0=0;A=-1;B=1;C=1;D=0;in=1;out=1

    model=scicos_model()
    model.sim=list('csslti4',4)
    model.in=in
    model.out=out
    model.state=x0
    model.rpar=[A(:);B(:);C(:);D(:)];
    model.blocktype='c'
    model.dep_ut=[%f %t]

    exprs=[strcat(sci2exp(A));
	   strcat(sci2exp(B));
	   strcat(sci2exp(C));
	   strcat(sci2exp(D));
	   strcat(sci2exp(x0))]
    gr_i=['txt=[''xd=Ax+Bu'';''y=Cx+Du''];';
	  'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
    x=standard_define([4 2],model,exprs,gr_i,'CLSS');
  end
endfunction
