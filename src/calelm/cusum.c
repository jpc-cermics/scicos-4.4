/* cusum.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_cusum (int *n, double *w)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int k;
  double t;

  /*    Utility fct: cumulated sum 
   *    Copyright INRIA 
   */
  /* Parameter adjustments */
  --w;

  /* Function Body */
  t = 0.;
  i__1 = *n;
  for (k = 1; k <= i__1; ++k)
    {
      w[k] = t + w[k];
      t = w[k];
      /* L1: */
    }
  return 0;
}				/* cusum_ */
