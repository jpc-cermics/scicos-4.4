function [xc,x]=unimesh1D(N,a,b)
// Copyright INRIA
// d�velopp� par EADS-CCR
// maillage pour les volumes finis 1D en incluant les noeuds    //
// aux limites.                                                 //
// sorties :                                                    //
//    - x (Double) : vecteur colonne representant les noeuds   //
//    - xc (Double) : vecteur colonne representant les cellules //
//      (les volumes de contr�le).                              //
//    - N (Entier) : est le nombre de noeuds                    //
//    - a, b (Doubles) :correspondent aux deux points limites   //
//--------------------------------------------------------------//

  deltax=(b-a)/(N-1);
  dx2=deltax/2;
  x=(a:deltax:b)';
  xc=[a-dx2;(dx2:deltax:b)';b+dx2];
  
endfunction
