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

function full_path=get_subobj_path(path)
// Deprecated: this function is the same as 
// scs_full_path
  full_path=  scs_full_path(path);
endfunction

function path=scs_full_path_old(P)
// Author S. Steer. Copyright INRIA
// Given a path in the superclock hierachy, this function returns a path
// in the scs_m data structure
// P is a vector of numbers. All but the last entries are Superblocks index 
// path is a list such as scs_m(path) is the required object
  path=list('objs');
  for l=P(1:$-1),path($+1)=l;path($+1)='model';path($+1)= 'rpar';path($+1)='objs';end
  path($+1)=P($);
endfunction

