/* dtild.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=DTILD,SSI=0 
 *    Copyright INRIA 
 */
int nsp_calpack_dtild (int *n, double *x, int *incx)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, i1, i2;
  double xx;

  /*!but 
   * 
   *    cette subroutine inverse l'ordre des elements d'un 
   *    vecteur x 
   * 
   *!liste d'appel 
   * 
   *     subroutine  dtild(n,x,incx) 
   * 
   *    n: taille du vecteur dx 
   * 
   *    x: double precision, vecteur 
   * 
   *    incx: increment entre les composantes du vecteur. 
   * 
   *!auteur 
   * 
   *    serge Steer Inria 1986 
   * 
   *! 
   * 
   * 
   */
  /* Parameter adjustments */
  --x;

  /* Function Body */
  if (*n <= 1)
    {
      return 0;
    }
  i1 = 1;
  i2 = *n * *incx;
  i__1 = *n / 2;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      xx = x[i1];
      x[i1] = x[i2];
      x[i2] = xx;
      i1 += *incx;
      i2 -= *incx;
      /* L10: */
    }
  return 0;
}				/* dtild_ */
