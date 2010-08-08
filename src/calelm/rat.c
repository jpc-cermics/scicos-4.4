/* rat.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_rat (double *x, double *eps, int *n, int *d__, int *fail)
{
  /* System generated locals */
  double d__1;

  /* Local variables */
  int nmax;
  double z__;
  int d0, d1, n0, n1, bm;
  double ax, xd, dz, xn, err;

  /*!but 
   *    ce sous programme approximme un reel x par un rationnel n/d 
   *!liste d'appel 
   * 
   *      subroutine rat(x,eps,n,d,fail) 
   *    double precision x,eps 
   *    int n,d,fail 
   * 
   *    x: reel contenant le nombre a approximer 
   *    eps: precision requise : (Abs(x-n/d))<eps 
   *    n,d:entiers contenant respectivement le numerateur et le 
   *        denominateur du resultat 
   *    fail:indicateur d'erreur 
   *          fail=0 : ok 
   *          fail.ne.0 precision requise trop grande ou nombre trop 
   *          grand ou trop petit pour etre code sous cette forme 
   *!origine 
   *    s steer inria 
   *! 
   * 
   *    Copyright INRIA 
   *possibly the largest int (hum ???) 
   */
  nmax = 2147483647;
  *fail = 0;
  n0 = 0;
  d0 = 1;
  n1 = 1;
  d1 = 0;
  z__ = Abs (*x);
  ax = z__;
L10:
  err = (d__1 = d1 * ax - n1, Abs (d__1));
  if (err <= d1 * *eps)
    {
      goto L20;
    }
  if (z__ > (double) nmax)
    {
      goto L30;
    }
  bm = (int) z__;
  dz = z__ - bm;
  if (dz == 0.)
    {
      goto L15;
    }
  z__ = 1. / dz;
L15:
  xn = n0 + (double) bm *n1;
  xd = d0 + (double) bm *d1;
  if (xn > (double) nmax || xd > (double) nmax)
    {
      goto L30;
    }
  n0 = n1;
  d0 = d1;
  n1 = (int) xn;
  d1 = (int) xd;
  if (dz == 0.)
    {
      goto L20;
    }
  goto L10;
L20:
  *n = n1;
  *d__ = d1;
  if (*x < 0.)
    {
      *n = -(*n);
    }
  return 0;
L30:
  *fail = 1;
  return 0;
}				/* rat_ */
