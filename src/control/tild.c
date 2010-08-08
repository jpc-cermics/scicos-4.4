/* tild.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/*/MEMBR ADD NAME=TILD,SSI=0 
 *    Copyright INRIA 
 */
int nsp_ctrlpack_tild (int *n, double *tp, double *tpti)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int j;

  /*!but 
   *    pour un polynome p(z)  l'operation tild aboutit a un polynome 
   *    ptild(z) defini par la relation suivante : 
   *      ptild(z)= z**n * p(1/z) . 
   *!liste d'appel 
   *    Entree : - tp . vecteur des coefficients du polynome a "tilder" . 
   *             -  n . degre du polynome "tp" 
   * 
   *    Sortie : - tpti . vecteur des coefficients du polynome resultant . 
   * 
   *! 
   * 
   */
  i__1 = *n;
  for (j = 0; j <= i__1; ++j)
    {
      tpti[j] = tp[*n - j];
      /* L50: */
    }
  return 0;
}				/* tild_ */
