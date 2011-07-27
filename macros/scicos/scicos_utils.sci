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
