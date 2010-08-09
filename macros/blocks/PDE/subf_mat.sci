function vect=subf_mat(M,N)
// Copyright INRIA
// d�velopp� par EADS-CCR
// fonction pour la soustraction ele/ele matrice //
// (string) M .- N matrice(string)               //
// sortie :                                      //
//    - vect (String) : Matrice de taille de M   //
// entr�es :                                     //
//    - M (String) : Matrice                     //
//    - N (String) : Matrice                     //
//-----------------------------------------------//
  vect=[];
  if (isempty(N )) then
    vect=M;
    return;
  elseif (isempty(M)) then
    vect='-1'.*N;
    return;
  end
  [n,m]=size(M);
  for i=1:n
    for j=1:m
      vect(i,j)=subf(M(i,j),N(i,j));
    end
  end
endfunction
