function [x,y,typ]=CONSTRAINT2_c(job,arg1,arg2)
// Copyright INRIA
  function blk_draw(sz,orig,orient,label)
    txt=["=f(x'',x)"]; xstringb(orig(1),orig(2)+sz(2)*0.2,txt,sz(1)/2,sz(2)/2,"fill");
    txt=["x "];xstringb(orig(1)+0.65*sz(1),orig(2)+sz(2)*0.5,txt,sz(1)/2,sz(2)/3);
    txt=["x''"];xstringb(orig(1)+0.65*sz(1),orig(2)+sz(2)*0.1,txt,sz(1)/2,sz(2)/3);
    txt="solve f(x'',x)=0";xstringb(orig(1)+.01*sz(1), orig(2)+.25*sz(1), txt, sz(1)/1.1,sz(2)/1.1,"fill");
  endfunction
  
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
    model=arg1.model;
    while %t do
      ask_again=%f

      [ok,x0,xd0,id,exprs]=getvalue('Set Constraint block parameters',['Initial guess values of states x';'Initial guess values of derivative x''';'Id(i)=1: if x''(i) is present in the feedback, else Id(i)=0'],list('vec',-1,'vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      x0=x0(:);N=size(x0,'*');
      xd0=xd0(:);Nxd=size(xd0,'*');
      id=id(:);Nid=size(id,'*');
      
      if (N~=Nxd)|(N~=Nid) then 
	message('incompatible sizes, states, their derivatives, and ID should be the same size ')
	ask_again=%t
      end  
      
      if (N<=0 & ~ask_again) then
	message('number of states (constraints) must be > 0 ')
	ask_again=%t
      end
      
      if (~ask_again) then 
	for i=1:N, 
	  if ~((id(i)==0) | (id(i)==1)) then
	    ask_again=%t
	    message(['Id(i) must be either';'0 when x''(i) is not present in the feedback';'1: when x''(i) is present in the feedback'])
	    break
	  end  
	  if (id(i)==0) then id(i)=-1;end;
	end
      end
      
      if ~ask_again  then
	graphics.exprs=exprs
	model.state=[x0;xd0];
	model.out=[N;N]
	model.in=N
	model.ipar=id
	x.graphics=graphics;x.model=model
	break
      end
    end      
    
   case 'define' then
    x0=[0];
    xd0=[0];
    id=[0];
    model=scicos_model()
    model.sim=list('constraint_c',10004)
    model.in=1
    model.out=[1;1]
    model.state=[x0;xd0]
    model.ipar=id
    model.blocktype='c'
    model.dep_ut=[%f %t]
    exprs=list(strcat(sci2exp(x0)),strcat(sci2exp(xd0)),strcat(sci2exp(id)))
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([3 2],model,exprs,gr_i,'CONSTRAINT2_c');
  end
endfunction
