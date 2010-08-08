/* wnrm2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=WNRM2,SSI=0 
 *    Copyright INRIA 
 */
double nsp_calpack_wnrm2 (int *n, double *xr, double *xi, int *incx)
{
  /* System generated locals */
  int i__1;
  double ret_val;

  /* Local variables */
  int i__;
  double s;
  int ix;

  /*!purpose 
   * 
   *    cette fonction wnrm2 determine la norme l2 d'un vecteur 
   *    complexe double precision x, dont les parties reelles 
   *    sont rangees dans le vecteur double precision xr et 
   *    les parties imaginaires sont rangees dans le vecteur 
   *    double precision xi. 
   * 
   *!calling sequence 
   * 
   *     double precision function wnrm2(n,xr,xi,incx) 
   * 
   *     n: entier, taille du vecteur traite. 
   * 
   *     xr, xi: vecteurs double precision, parties reelles et 
   *    imaginaires, respectivement du vecteur x. 
   * 
   *     incx: increment entre deux composantes consecutives du 
   *    vecteur x. 
   * 
   *!auxiliary routines 
   * 
   *    pythag 
   * 
   *!author 
   * 
   *    cleve moler.- mathlab. 
   * 
   *! 
   *    norm2(x) 
   */
  /* Parameter adjustments */
  --xi;
  --xr;

  /* Function Body */
  s = 0.;
  if (*n <= 0)
    {
      goto L20;
    }
  ix = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      s = nsp_calpack_pythag (&s, &xr[ix]);
      s = nsp_calpack_pythag (&s, &xi[ix]);
      ix += *incx;
      /* L10: */
    }
L20:
  ret_val = s;
  return ret_val;
}				/* wnrm2_ */
