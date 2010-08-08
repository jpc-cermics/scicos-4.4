/* wrscal.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=WRSCAL,SSI=0 
 *    Copyright INRIA 
 */
int nsp_calpack_wrscal (int *n, double *s, double *xr, double *xi, int *incx)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, ix;

  /*!but 
   * 
   *    cette subroutine calcule le produit d'une constante reelle 
   *    double precision s par un vecteur complexe x, dont les 
   *    reelles de ses composantes sont rangees dans xr et les 
   *    parties imaginaires dans xi. 
   * 
   *!liste d'appel 
   * 
   *     subroutine wrscal(n,s,xr,xi,incx) 
   * 
   *    n: entier, longueur du vecteur x. 
   * 
   *    s: double precision. the real factor 
   * 
   *    xr, xi: doubles precision, parties reelles et imaginaires, 
   *    respectivement, des composantes du vecteur x. 
   * 
   *    incx: increment entre deux composantes consecutives de x. 
   * 
   *!auteur 
   * 
   *    cleve moler.- mathlab. 
   * 
   *! 
   */
  /* Parameter adjustments */
  --xi;
  --xr;

  /* Function Body */
  if (*n <= 0)
    {
      return 0;
    }
  ix = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      xr[ix] = *s * xr[ix];
      xi[ix] = *s * xi[ix];
      ix += *incx;
      /* L10: */
    }
  return 0;
}				/* wrscal_ */
