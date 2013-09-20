function [x,y,typ]=CLR_f(job,arg1,arg2)
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    x0=model.state
    rpar=model.rpar
    ns=prod(size(x0));nin=1;nout=1
    // not sure that varnumsubs is really usefull here 
    // polynomials are kept with %s internally and exposed 
    // with s 
    if ~exists('%scicos_context') then 
      %scicos_context=hash(1);
    else
      %scicos_context=%scicos_context;
    end
    %scicos_context.s=poly(0,'s');
    exprs(1)=varnumsubst(exprs(1),"%s","s")
    exprs(2)=varnumsubst(exprs(2),"%s","s")
    while %t do
      [ok,num,den,exprs]=getvalue('Set continuous SISO transfer parameters',..
				  ['Numerator (s)';
		    'Denominator (s)'],..
				  list('pol',1,'pol',1),exprs)
      if ~ok then break,end
      if type(num,'short')=='m' then num=m2p(num);end
      if type(den,'short')=='m' then den=m2p(den);end
      if num.degree[] > den.degree[] then
	message('Transfer must be proper or strictly proper !')
	ok=%f;
      end
      if ok then
	//H=cont_frm(num,den);[A,B,C,D]=H(2:5);
	[A,B,C,D]=scicos_getabcd(num,den);
	exprs(1)=varnumsubst(exprs(1),"s","%s")
	exprs(2)=varnumsubst(exprs(2),"s","%s")
	graphics.exprs=exprs;
	[ns1,vns1]=size(A);
	rpar=[matrix(A,ns1*ns1,1);
	      matrix(B,ns1,1);
	      matrix(C,ns1,1);
	      D]
	if norm(D,1)<>0 then
	  mmm=[%t %t];
	else
	  mmm=[%f %t];
	end
	if or(model.dep_ut<>mmm) then 
	  model.dep_ut=mmm,end
	  if ns1<=ns then
	    x0=x0(1:ns1)
	  else
	    x0(ns1,1)=0
	  end
	  model.state=x0
	  model.rpar=rpar
	  x.graphics=graphics;x.model=model
	  break
      end
    end
   case 'define' then
    x0=0;A=-1;B=1;C=1;D=0;
    exprs=['1';'1+%s']
    model=scicos_model()
    model.sim=list('csslti',1)
    model.in=1
    model.out=1
    model.state=x0
    model.rpar=[A(:);B(:);C(:);D(:)]
    model.blocktype='c'
    model.dep_ut=[%f %t]

    gr_i=['xstringb(orig(1),orig(2),[''num(s)'';''den(s)''],sz(1),sz(2),''fill'')';
	  'xpoly([orig(1)+.1*sz(1),orig(1)+.9*sz(1)],[1,1]*(orig(2)+sz(2)/2))']

    x=standard_define([2.5 2.5],model,exprs,gr_i,'CLR_f');
  end
endfunction

function [a,b,c,d]=scicos_getabcd(num,den)
// Controllable state-space form of the transfer num/den
// a minimal version of cont_frm since we do not have 
// syslin in nsp (Aug 2011).
  if size(den,'*')<>1 then  
    error("getabcd: den should be a polynom\n");
    return;
  end
  [ns,ne]=size(num);
  nd=den.degree[];
  num.set_var['s']
  den.set_var['s']
  // normalization
  dnd=den.coeffs{1}($); den=den/dnd;num=num/dnd
  // D(s)
  d=num;
  for l=1:ns,
    for k=1:ne,
      // take care of nsp order [quotient,rem]=pdiv(..)
      [nl,dl]=pdiv(num(l,k),den),
      num(l,k)=dl,d(l,k)=nl,
    end
  end
  if max(d.degree[])==0 then 
    // return a matrix not a polynomial matrix 
    dc=d.coeffs;
    d=zeros(size(dc));
    for i=1:size(dc,'*') 
      dci=dc{i}; // direct call dc{i}(1) => crash (XXX)
      //alan confirms that direct call dc{i}(1) => crash again 25/01/13
      d(i)= dci(1);
    end
  end
  //matrices a b and c
  if nd<>0 then
    dc=den.coeffs{1}; 
    a=[];
    for k=1:nd,a=[a,-dc(k)*eye(ne,ne)];end
    a=[0*ones((nd-1)*ne,ne),eye(ne*(nd-1),ne*(nd-1));a];
    b=[0*ones((nd-1)*ne,ne);eye(ne,ne)]
    cc= num.coeffs;
    //assume that one have only one polynom
    c=zeros(1,nd);
    cc=cc{1}
    for i=1:nd
      if i<=length(cc) then
        c(i)=cc(i)
      end
    end
  else
    a=[];b=[];c=[];
  end;
  // [n,v]=size(a);
  // sl=syslin([],a,b,c,d,0*ones(n,1))
endfunction

function [num,den]=abcd2nd(A,B,C,D,var='s',rmax=0.0)
// (a,b,c,d) -> num/den 
// 
  if isempty(B) then num=D;den=eye(size(D));return;end
  if isempty(C) then num=D;den=eye(size(D));return;end
  if size(A,'*')==0 then
    h=D // missing num and den ? 
    return
  end 
  Den=poly(A,var); // characteristic polynomial;
  na=Den.degree[];den=[];
  [m,n]=size(D);
  c=C;
  den=pmat_create(m,n);
  num=pmat_create(m,n);
  for l=1:m
    [m,i]=max(abs(c(l,:)));
    if m<>0 then
      ci=c(l,i)
      t=eye(na,na)*ci;t(i,:)=[-c(l,1:i-1), 1, -c(l,i+1:na)]
      al=A*t;
      t=eye(na,na)/ci;t(i,:)=[c(l,1:i-1)/ci, 1, c(l,i+1:na)/ci]
      al=t*al;ai=al(:,i),
      b=t*B;
      for k=1:n
	al(:,i)=ai+b(:,k);
	// on peut simplifier avec gcd mais pb de normalisation.
	// [z,f1,f2,res] = gcd_p_p(u,v,
	// [nlk,dlk]=simp(poly(al,var),Den)
	den(l,k)= Den; // dlk;
	num(l,k)=-(poly(al,var)-Den)*ci; // -(nlk-dlk)*ci
      end
    else
      num(l,1:n)=0*ones(1,n);
      den(l,1:n)=ones(1,n);
    end
  end
endfunction


if %f then 
  num1=poly(1:4,'x',roots=%f);
  num2=poly(8:10,'x',roots=%f);
  num=[num1,num2];
  den=poly(1:2,'x',roots=%f);
  [a,b,c,d]=getabcd(num,den);

  den=poly(1:5,'x',roots=%f);
  [a,b,c,d]=getabcd(num,den);
end
