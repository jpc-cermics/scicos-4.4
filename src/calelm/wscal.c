/* wscal.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wscal (int *n, double *sr, double *si, double *xr, double *xi,
		   int *incx)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, ix;

  /*!but 
   * 
   *    cette subroutine wscal multiplie une contante complexe s 
   *    (dont la partie reelle est rangee dans sr et la partie 
   *    imaginaire dans si) par un vecteur x (dont les parties 
   *    reelles de ses composantes sont rangees dans xr et les 
   *    parties imaginaires dans xi). le resultat reste dans x. 
   * 
   *!liste d'appel 
   * 
   *     subroutine wscal(n,sr,si,xr,xi,incx) 
   * 
   *    n: entier, taille du vecteur x. 
   * 
   *    sr, si: double precision, parties reelle et imaginaire 
   *    de s. 
   * 
   *    xr, xi: vecteurs double precision, contiennent, 
   *    respectivement, les parties reelles et imaginaires des 
   *    composants du vecteur x. 
   * 
   *    incx: entier, increment entre deux composantes consecutives 
   *    de x. 
   * 
   *!routines auxilieres 
   * 
   *    wmul 
   * 
   *!auteur 
   * 
   *    cleve moler. 
   * 
   *! 
   *    Copyright INRIA 
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
      nsp_calpack_wmul (sr, si, &xr[ix], &xi[ix], &xr[ix], &xi[ix]);
      ix += *incx;
      /* L10: */
    }
  return 0;
}				/* wscal_ */
