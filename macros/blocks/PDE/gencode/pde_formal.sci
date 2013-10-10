function y=pde_formal()
  y='formal'
endfunction

function y = multMatVect(M, x)
// Copyright INRIA
// developed by EADS-CCR
// y = M*x 
// M: a pxn sparse matrix of double
// x: a nx1 vector of string
// y: a px1 vector of string
  if isempty(M) then y=m2s([]); return;end
  [ij,v,mn_M]=spget(M);
  mn_x = size(x);
  if(mn_x(1) <> mn_M(2)) then
    error('Incompatible dimensions');
    return;
  end
  // Perform the multiplication
  y = smat_create(mn_M(1),1,"0");
  for n=1:length(v)
    strv=m2s_opt(v(n));
    y(ij(n, 1)) = addfv(y(ij(n, 1)),mulfv(strv, x(ij(n, 2))));
  end
endfunction

function y = multVectStr(M, x)
// Copyright INRIA
// developed by EADS-CCR
// y = M .* x 
// M: a sparse matrix of double
// x: a string
// y = M .* x 
// Check the dimensions
  if isempty(x) || x.equal[''] then 
    y = smat_create(size(M,1),size(M,2),"0");
    return;
  end
  [ij,v,mn_M]=spget(M);
  // Perform the multiplication
  y = smat_create(mn_M(1),mn_M(2),"0");
  for n=1:length(v)
    strv=m2s_opt(v(n));
    y(ij(n,1),ij(n,2)) = mulf(strv,x);
  end
  if (y == '') then
    y=[];
  end
endfunction

function C=mulfstring(A,B)
// Copyright INRIA
// developed by EADS-CCR
// multiply two matrices 
// C= A * B 
  if isempty(A) || isempty(B) then
     C=m2s([]);
     return;
  end
  [l,m]=size(A);[m,n]=size(B);C=m2s([]);
  for j=1:n,
    y=m2s([]);
    for i=1:l,
      t=mulf(A(i,1),B(1,j));
      for k=2:m
	t=addf(t,mulf(A(i,k),B(k,j)));
      end
      y=[y;t];
    end
    C=[C y];
  end
endfunction

function vect=mulf_string(M,vec)
// Copyright INRIA
// developed by EADS-CCR
// vectf = M * vec 
  vect=m2s([]);
  N=size(vec,'*');
  for i=1:N
    line=m2s([]);
    for j=1:N
      line=[line,mulf(M(i,j),vec(j))];
    end
    som='0';
    for i1=1:N
      som=addf(som,line(i1));
    end
    vect=[vect;som];
  end
endfunction

function vect=addf_mat(M,N)
// Copyright INRIA
// developed by EADS-CCR
// vect = M + N 
  if isempty(N) || N.equal[''] then
    vect=M;
    return;
  elseif isempty(M) || M.equal['']   then
    vect=N;
    return;
  end
  vect=M;
  [n,m]=size(M);
  for i=1:n
    for j=1:m
      vect(i,j)=addf(M(i,j),N(i,j));
    end
  end
endfunction

function vect=subf_mat(M,N)
// Copyright INRIA
// developed by EADS-CCR
// vectf= M .- N 
  if isempty(N) || N.equal[''] then
    vect=M;
    return;
  elseif  isempty(M) || M.equal['']  then
    vect=N;
    [n,m]=size(N);
    for i=1:n
      for j=1:m
	vect(i,j)=subf('0',N(i,j));
      end
    end
    return;
  end
  vect=M;
  [n,m]=size(M);
  for i=1:n
    for j=1:m
      vect(i,j)=subf(M(i,j),N(i,j));
    end
  end
endfunction

function x=addfv(x1,x2)
// Copyright INRIA
// developed by EADS-CCR
// addition with special case with empty elements.
  if isempty(x1) then
    x=x2;
  elseif isempty(x2) then
    x=x1;
  else
    x=addf(x1,x2);
  end
endfunction

function x=subfv(x1,x2)
// Copyright INRIA
// developed by EADS-CCR
  if isempty(x1) then
    x='-'+x2;
  elseif isempty(x2) then
    x=x1;
  else
    x=subf(x1,x2);
  end
endfunction

function x=mulfv(x1,x2)
// Copyright INRIA
// developed by EADS-CCR
  if (isempty(x1) || isempty(x2) || x1.equal[''] || x2.equal[''] ) then
    x='0';
  else
    x=mulf(x1,x2);
  end
endfunction

function x=mulf3v(x1,x2,x3)
// Copyright INRIA
// developed by EADS-CCR
  if isempty(x1) || isempty(x2) || isempty(x3) then
    x='0';
  else
    x=mulf3(x1,x2,x3);
  end
endfunction

function str=addf(a,b)
  if a.equal[emptystr()] && b.equal[emptystr()] then
    str='0';return;
  end
  if a.equal['0'] || a.equal[emptystr()] then str=b;return;end
  if b.equal['0'] || b.equal[emptystr()] then str=a;return;end
  if pde_num(a) && pde_num(b) then 
    x = evstr(a+'+'+b);
    str=m2s_opt(x);
    return;
  end
  if ~validvar(a,id='NAME') && ~pde_num(a) then 
    a='('+a+')';
  end
  if ~validvar(b,id='NAME') && ~pde_num(b) then 
    b='('+b+')';
  end
  str=a+"+"+b
endfunction

function str=mulf(a,b)
  if a.equal[emptystr()] || b.equal[emptystr()] then
    str='0';return;
  end
  if a.equal['1'] then str=b;return;end
  if b.equal['1'] then str=a;return;end
  if a.equal['0'] || b.equal['0'] then str='0';return;end
  if pde_num(a) && pde_num(b) then 
    x = evstr(a+'*'+b);
    str=m2s_opt(x);
    return;
  end
  if ~validvar(a,id='NAME') && ~pde_num(a) then 
    a='('+a+')';
  end
  if ~validvar(b,id='NAME') && ~pde_num(b) then 
    b='('+b+')';
  end
  str=a+"*"+b
endfunction

function x=mulf3(x1,x2,x3)
// Copyright INRIA
// developed by EADS-CCR
// mulf avec 3 entrée : x=mulf(x1,x2,x3)
  xx=mulf(x1,x2);
  x=mulf(xx,x3);
endfunction

function str=subf(a,b)
  if a.equal[emptystr()] && b.equal[emptystr()] then
    str='0';return;
  end
  if a.equal['0'] || a.equal[emptystr()] then 
    if ~pde_name(b) && ~validvar(b,id='NUMBER') then 
      b='('+b+')';
    end
    str='-'+b;
    return;
  end
  if b.equal['0'] || b.equal[emptystr()] then str=a;return;end
  if pde_num(a) && pde_num(b) then 
    x = evstr(a+'-'+b);
    str=m2s_opt(x);
    return;
  end
  if ~validvar(a,id='NAME') && ~pde_num(a) then 
    a='('+a+')';
  end
  if ~validvar(b,id='NAME') && ~pde_num(b) then 
    b='('+b+')';
  end
  str=a+"-"+b
endfunction

function str=rdivf(a,b)
  if b.equal['1'] then str=a;return;end
  if pde_num(a) && pde_num(b) then 
    x = evstr(a+'/'+b);
    str=m2s_opt(x);
    return;
  end
  if ~validvar(a,id='NAME') && ~pde_num(a) then 
    a='('+a+')';
  end
  if ~validvar(b,id='NAME') && ~pde_num(b) then 
    b='('+b+')';
  end
  str=a+"/"+b
endfunction

function str=ldivf(a,b)
  if a.equal['1'] then str=b;return;end
  if pde_num(a) && pde_num(b) then 
    x = evstr(a+'\'+b);
    str=m2s_opt(x);
    return;
  end
  if ~validvar(a,id='NAME') && ~pde_num(a) then 
    a='('+a+')';
  end
  if ~validvar(b,id='NAME') && ~pde_num(b) then 
    b='('+b+')';
  end
  str=a+"\"+b
endfunction

function x=msprintfv(x)
// Copyright INRIA
// développé par EADS-CCR
  if isempty(x) then
    x=m2s([]);
  else
    //x=sprintf('%.16g',x(:));
    xn=smat_create(size(x,1),size(x,2));
    for i=1:size(x,'*')
      xn(i)=m2s_opt(x(i));
    end
    x=xn;
  end
endfunction

function str=m2s_opt(x)
//
  if isinf(x) || isnan(x) then  str=m2s(x);return;end
  if x > 1.0e16 then str=m2s(x);return;end
  S=['rep=[';sprintf('%30.*f',(1:20)',x*ones(20,1))];
  S($)=S($)+'];';
  execstr(S);
  I=find(abs(x-rep)/x <= %eps);
  if ~isempty(I) then 
    str=stripblanks(sprintf('%30.*f',I(1),x));
    return;
  end
  S=['rep=[';sprintf('%30.*g',(1:20)',x*ones(20,1))];
  S($)=S($)+'];';
  execstr(S);
  I=find(abs(x-rep)/x <= %eps);
  if ~isempty(I) then 
    str=stripblanks(sprintf('%30.*g',I(1),x));
    return;
  end
  str=m2s(x);  
endfunction

function b=pde_num(str)
//
  b= validvar(str,id='NUMBER') || ...
     (part(str,1) == '-' && validvar(part(str,2:length(str)),id='NUMBER'));
endfunction

function b=pde_name(str)
//
  b= validvar(str,id='NAME');
endfunction



if %f then 
  // small test 
  namea='a'+string(1:4);
  nameb='b'+string(1:4);
  A=namea;A.redim[2,2];
  B=nameb;B.redim[2,2];
  H=hash(8);
  for i=1:4,
    H('a'+string(i))=rand(1,1);
    H('b'+string(i))=rand(1,1);
  end
  C=mulfstring(A,B);
  Ce=evstr(C,H);
  Ce1=evstr(A,H)*evstr(B,H);
  if norm(Ce-Ce1) > 1.e-6 then pause;end 
  //
  A=matrix('u'+string(1:9),3,3);
  B=matrix('v'+string(1:9),3,3);
  x=mulfstring(A,B);
  V=matrix('v'+string(1:9),3,1);
  x=mulf_string(A,V);
  // 
  M=sprand(4,3,0.8);
  x='x'+string((1:3)')
  z=multMatVect(M, x);
  //
  y=multVectStr(M,'x')
end

