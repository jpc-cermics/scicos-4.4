/* wsign.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wsign (double *xr, double *xi, double *yr, double *yi,
		   double *zr, double *zi)
{
  /* System generated locals */
  double d__1, d__2;

  /* Local variables */
  double t;

  /*    Copyright INRIA 
   *    if y .ne. 0, z = x*y/abs(y) 
   *    if y .eq. 0, z = x 
   */
  t = nsp_calpack_pythag (yr, yi);
  *zr = *xr;
  *zi = *xi;
  if (t != 0.)
    {
      d__1 = *yr / t;
      d__2 = *yi / t;
      nsp_calpack_wmul (&d__1, &d__2, zr, zi, zr, zi);
    }
  return 0;
}				/* wsign_ */
