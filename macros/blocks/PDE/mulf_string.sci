function vect=mulf_string(M,vec)
// Copyright INRIA
// d�velopp� par EADS-CCR
// fonction pour la multiplication matrice     //
// (string) * vecteur(string)                  //
// sortie :                                    //
//    - vect (String) : Vecteur de taille de M //
// entr�es :                                   //
//    - M (String) : Matrice                   //
//    - N (String) : Vecteur                   //
//---------------------------------------------//
  vect=[];
  N=size(vec,'*');
  for i=1:N
    line=[];
    for j=1:N
      line=[line,mulf(M(i,j),vec(j))];
    end
    som='';
    for i=1:N
      som=addf(som,line(i));
    end
    vect=[vect;som];
  end
endfunction
