/* wdotci.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=WDOTCI,SSI=0 
 *    Copyright INRIA 
 */
double
nsp_calpack_wdotci (int *n, double *xr, double *xi, int *incx, double *yr,
		    double *yi, int *incy)
{
  /* System generated locals */
  int i__1;
  double ret_val;

  /* Local variables */
  int i__;
  double s;
  int ix, iy;

  /* Parameter adjustments */
  --yi;
  --yr;
  --xi;
  --xr;

  /* Function Body */
  s = 0.;
  if (*n <= 0)
    {
      goto L20;
    }
  ix = 1;
  iy = 1;
  if (*incx < 0)
    {
      ix = (-(*n) + 1) * *incx + 1;
    }
  if (*incy < 0)
    {
      iy = (-(*n) + 1) * *incy + 1;
    }
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      s = s + xr[ix] * yi[iy] - xi[ix] * yr[iy];
      ix += *incx;
      iy += *incy;
      /* L10: */
    }
L20:
  ret_val = s;
  return ret_val;
}				/* wdotci_ */
