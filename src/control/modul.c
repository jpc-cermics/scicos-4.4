/* modul.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int nsp_ctrlpack_modul (int *neq, double *zeror, double *zeroi, double *zmod)
{
  /* System generated locals */
  int i__1;
  double d__1, d__2;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int i__;

  /*!but 
   *    ce sous programme calcule le vecteur des modules d'un vecteur 
   *    de nombres complexes 
   *!liste d'appel 
   *    subroutine modul(neq,zeror,zeroi,zmod) 
   *    double precision zeror(neq),zeroi(neq),zmod(neq) 
   * 
   *    neq : longueur des vecteurs 
   *    zeror (zeroi) : vecteurs des parties reelles (imaginaires) du 
   *           vecteur de nombres complexes 
   *    zmod : vecteur des modules 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --zmod;
  --zeroi;
  --zeror;

  /* Function Body */
  i__1 = *neq + 1;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      /*Computing 2nd power 
       */
      d__1 = zeror[i__];
      /*Computing 2nd power 
       */
      d__2 = zeroi[i__];
      zmod[i__] = sqrt (d__1 * d__1 + d__2 * d__2);
      /* L50: */
    }
  /* 
   */
  return 0;
}				/* modul_ */
