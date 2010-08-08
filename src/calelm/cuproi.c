/* cuproi.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_cuproi (int *n, double *wr, double *wi)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int k;
  double ti, tr, wwr;

  /*    Utility fct: cumulated product, complex argument 
   *    Copyright INRIA 
   */
  /* Parameter adjustments */
  --wi;
  --wr;

  /* Function Body */
  tr = 1.;
  ti = 0.;
  i__1 = *n;
  for (k = 1; k <= i__1; ++k)
    {
      /*    w(k)=t*w(k) 
       */
      wwr = wr[k];
      wr[k] = tr * wwr - ti * wi[k];
      wi[k] = tr * wi[k] + ti * wwr;
      tr = wr[k];
      ti = wi[k];
      /* L1: */
    }
  return 0;
}				/* cuproi_ */
