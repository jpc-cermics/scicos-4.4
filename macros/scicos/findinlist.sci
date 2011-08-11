function [paths]=findinlist(L,v)
// Copyright INRIA
// search all occurences of v in List. 
// The search is recursive and found objects 
// are given byt their pathes in L.
// 
// Note that: Lr=findinlist(list(4,8,67,list(5,67)),list(5,67))
// will return list()
// Lr=findinlist(list(4,8,67,list(5,67)),67)
// will return list(3,[4,2]);
// rewritten:  jpc 2011
//
// XXX: in scicoslab this function works for list or mlist 
//      here it only works for list since path are given 
//      as vector of integers.
// could be changed by changing the coding of answers.
// 
  paths=list()
  if type(L,'short')<> 'l' then 
    error('Error: in findinlist, first argument should be a list !');
    return;
  end
  for k=1:length(L)
    l=L(k);
    if type(l,'short')== 'l' then
      q=findinlist(l,v);
      for j=1:length(q) do paths($+1)=[k,q(j)];end 
    elseif l.equal[v] then
      paths($+1)= k;
    else
    end
  end
endfunction
