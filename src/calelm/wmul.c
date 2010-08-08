/* wmul.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wmul (double *ar, double *ai, double *br, double *bi, double *cr,
		  double *ci)
{
  double t;

  /*    Copyright INRIA 
   *    c = a*b 
   */
  t = *ar * *bi + *ai * *br;
  *cr = *ar * *br - *ai * *bi;
  *ci = t;
  return 0;
}				/* wmul_ */
