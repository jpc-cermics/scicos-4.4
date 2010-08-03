function cors=shiftcors(cors,ns)
// Copyright INRIA
// rewriten for Nsp with map (jpc)
  if type(cors,'short')=='l' then
    cors=map(cors,shiftcors,list(ns));
  else
    I = find(cors<>0);
    cors(I)= cors(I)+ ns;
  end
endfunction
