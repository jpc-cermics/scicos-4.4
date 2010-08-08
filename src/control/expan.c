/* expan.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_expan (double *a, int *la, double *b, int *lb, double *c__,
		    int *nmax)
{
  int j, k, m, n;
  double s, a0;

  /*! but 
   *calcul des nmax premiers coefficients de la longue division de 
   * b par a .On suppose a(1) non nul. 
   *!liste d'appel 
   *      subroutine expan(a,la,b,lb,c,nmax) 
   * a vecteur de longueur la des coeffs par puissances croissantes 
   * b   "           "     lb        "                "          " 
   * c                     nmax   des coeffs de  a/b 
   * 
   *!origine 
   *    F Delebecque INRIA 1986 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --a;
  --b;
  --c__;

  /* Function Body */
  m = *la;
  n = *lb;
  a0 = a[1];
  if (a0 == 0.)
    {
      return 0;
    }
  k = 1;
L2:
  s = 0.;
  if (k == 1)
    {
      goto L8;
    }
  j = 1;
L5:
  ++j;
  if (j > Min (m, k))
    {
      goto L8;
    }
  s += a[j] * c__[k - j + 1];
  goto L5;
L8:
  if (k <= n)
    {
      c__[k] = (b[k] - s) / a0;
    }
  else
    {
      c__[k] = -s / a0;
    }
  if (k == *nmax)
    {
      return 0;
    }
  ++k;
  goto L2;
}				/* expan_ */
