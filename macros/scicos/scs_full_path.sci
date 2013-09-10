function path=scs_full_path(P)
// Copyright ENPC 
// Given a path in the superblock hierachy given by P (a vector of
// numbers), this function returns a path in the scs_m data structure:
// scs_m(scs_full_path(P))
  path=list();
  for i=1:(size(P,'*')-1)
    path.concat[list('objs',P(i),'model','rpar')];
  end
  path.concat[list('objs',P($))];
endfunction

function path=scs_short_path(L)
// Copyright ENPC 
// Given a path in the scs_m data structure this function 
// return a path given by a vector of numbers
  path=[]
  for i=1:size(L)
    if type(L(i),'short')== 'm' then path.concatr[L(i)];end 
  end
endfunction

function full_path=get_subobj_path(path)
// Deprecated: this function is the same as 
// scs_full_path
  full_path=  scs_full_path(path);
endfunction

