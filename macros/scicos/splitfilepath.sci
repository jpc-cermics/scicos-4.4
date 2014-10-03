// XXXX A simplifier 
// en utilisant fileparts version nsp 

function [path,name,ext]=splitfilepath(fname)
// in splitfilepath extension do not contain the dot 
  [path,name,ext]=splitfilepath_cos(fname);
endfunction

function [path,name,ext]=fileparts(fname)
  if fname.equal[''] then 
    name='';path='';ext='';
    return;
  end
  name=file('root',file('tail',fname));
  path=file('dirname',fname);
  ext = file('extension',fname);
endfunction

function [path,name,ext]=splitfilepath_cos(fname)
// Copyright INRIA
  l=length(fname)
  //getting the extension part
  n=l
  while n>0
    cn=part(fname,n)
    if cn=='.'|cn=='/'|cn=='\' then break,end
    n=n-1
  end
  if n==0 then
    ext=emptystr()
    name=fname
    path='./'
    return
  elseif cn=='/'|cn=='\' then
    ext=emptystr()
    n=l
  else
    ext=part(fname,n+1:l)
    n=n-1
  end
  //getting the name part
  l=n
  n=l
  while n>0
    cn=part(fname,n)
    if cn=='/'|cn=='\' then break,end
    n=n-1
  end
  if n==0 then
    name=part(fname,1:l)
    path='./'
  else
    name=part(fname,n+1:l)
    path=part(fname,1:n)
  end
endfunction
