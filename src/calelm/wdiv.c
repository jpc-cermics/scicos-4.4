/* wdiv.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wdiv (double *ar, double *ai, double *br, double *bi, double *cr,
		  double *ci)
{
  /* System generated locals */
  double d__1, d__2;

  /* Local variables */
  double d__, s, ais, bis, ars, brs;

  /*!but 
   * 
   *    cette subroutine wdiv calcule la division c=a/b de 
   *    nombres complexes de double precision. les parties 
   *    reelles de a, b et c sont rangees, respectivement dans 
   *    ar, br et cr. de facon analogue les parties imaginaires 
   *    de a, b et c son rangees dans ai, bi et ci. 
   * 
   *!liste d'appel 
   * 
   *    subroutine wdiv(ar,ai,br,bi,cr,ci) 
   * 
   *    ar, ai: double precision, parties reelle et imaginaire de a. 
   * 
   *    br, bi: double precision, parties reelle et imaginaire de b. 
   * 
   *    cr, ci: double precision, parties reelle et imaginaire de c. 
   * 
   *!auteur 
   * 
   *    cleve moler. 
   * 
   *! 
   *    Copyright INRIA 
   *    c = a/b 
   */
  s = Abs (*br) + Abs (*bi);
  if (s == 0.)
    {
      return 0;
    }
  ars = *ar / s;
  ais = *ai / s;
  brs = *br / s;
  bis = *bi / s;
  /*Computing 2nd power 
   */
  d__1 = brs;
  /*Computing 2nd power 
   */
  d__2 = bis;
  d__ = d__1 * d__1 + d__2 * d__2;
  *cr = (ars * brs + ais * bis) / d__;
  *ci = (ais * brs - ars * bis) / d__;
  return 0;
}				/* wdiv_ */
