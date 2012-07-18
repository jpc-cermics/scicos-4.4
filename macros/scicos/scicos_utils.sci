function scicos_utils()
// a set of function which emulate scilab functions.
endfunction

function A=emptystr(a,b)
  if nargin==0 then 
    A=smat_create(1,1);
  elseif nargin==1 then 
    A=smat_create(size(a,1),size(a,2));
  else
    A=smat_create(a,b);
  end
endfunction

function B=string(A)
// a revoir 
  if type(A,'short')=='s' then 
    B=A;
  elseif type(A,'short')=='b' then 
    B=string(b2m(A));
    B=strsubst(B,'1','T');
    B=strsubst(B,'0','F');
  elseif type(A,'short')=='i' then
    B=string(i2m(A));
  else
    B=m2s(A);// used defaut format 
  end
endfunction

function xbasc()
  xclear()
endfunction

function y=strcat(mat,sep)
  if nargin <= 1, sep ="";end 
  y=catenate(mat,sep=sep);
endfunction

function y=str2code(str)
  y=ascii(str)(:)
endfunction

function y=diffobjs(A,B)
  y=~A.equal[B];
endfunction

function scicos_mputl(str,fname)
    F=fopen(fname,mode="w");
    F.put_smatrix[str];
    F.close[];
endfunction

function str=scicos_mgetl(fname)
    F=fopen(fname,mode="r");
    ierr=execstr('str=F.get_smatrix[]',errcatch=%t)
    if ~ierr then
      str=[]
      lasterror()
    end
    F.close[];
endfunction

function y=isequal(a,b)
  y=a.equal[b] 
endfunction

function y=isequalbitwise(a,b)
  y=a.equal[b] 
endfunction

function y=newest(varargin)
  if nargin==1 then str=varargin(1),else str=varargin,end
  n=prod(size(str))
  dat=zeros(1,n)
  for i=1:n
    ierr=execstr('dd=file(""mtime"",str(i))',errcatch=%t)
    if ~ierr then
      dat(i)=0
      lasterror()
    else
      dat(i)=dd
    end
  end
  [dat,y]=sort(dat)
  y=y(1)
endfunction

function y=double(x)
  if type(x,'short')=='b' then
    y=b2m(x)
  elseif type(x,'short')=='i' then
    y=i2m(x)
  else
    if isreal(x,%t) then
      y=x
    else
      y=real(x)
    end
  end
endfunction

function y=int64(x)
  y=m2i(double(x),"int64")
endfunction

function y=int32(x)
  y=m2i(double(x),"int32")
endfunction

function y=int16(x)
  y=m2i(double(x),"int16")
endfunction

function y=int8(x)
  y=m2i(double(x),"int8")
endfunction

function y=uint64(x)
  y=m2i(double(x),"uint64")
endfunction

function y=uint32(x)
  y=m2i(double(x),"uint32")
endfunction

function y=uint16(x)
  y=m2i(double(x),"uint16")
endfunction

function y=uint8(x)
  y=m2i(double(x),"uint8")
endfunction
