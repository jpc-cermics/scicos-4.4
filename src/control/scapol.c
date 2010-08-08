/* scapol.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/*/MEMBR ADD NAME=SCAPOL,SSI=0 
 *    Copyright INRIA 
 */
int nsp_ctrlpack_scapol (int *na, double *a, int *nb, double *b, double *y)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int nmax, k;
  double aux;

  /*!but 
   *    cette subroutine a pour but de calculer le produit 
   *    scalaire de deux polynomes 
   *!liste d'appel 
   *    subroutine scapol(na,a,nb,b,y) 
   *    Entree : 
   *     a. est le premier polynome de degre na 
   *     b. est le second polynome du produit, et est de degre nb 
   * 
   *    Sortie : 
   *     y. est le resultat du produit scalaire <a,b> 
   *! 
   * 
   */
  if (*na >= *nb)
    {
      nmax = *nb;
    }
  else
    {
      nmax = *na;
    }
  /* 
   */
  aux = 0.;
  i__1 = nmax;
  for (k = 0; k <= i__1; ++k)
    {
      aux += a[k] * b[k];
      /* L20: */
    }
  *y = aux;
  /* 
   */
  return 0;
}				/* scapol_ */
