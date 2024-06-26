/* unsfdcopy-hpux.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_unsfdcopy (int *n, double *dx, int *incx, double *dy, int *incy)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, m, ix, iy, mp1;

  /* 
   *    copies a vector, x, to a vector, y. 
   *    uses unrolled loops for increments equal to one. 
   *    jack dongarra, linpack, 3/11/78. 
   *    modified 12/3/93, array(1) declarations changed to array(*) 
   * 
   * 
   */
  /* Parameter adjustments */
  --dy;
  --dx;

  /* Function Body */
  if (*n <= 0)
    {
      return 0;
    }
  if (*incx == 1 && *incy == 1)
    {
      goto L20;
    }
  /* 
   *       code for unequal increments or equal increments 
   *         not equal to 1 
   * 
   */
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
      dy[iy] = dx[ix];
      ix += *incx;
      iy += *incy;
      /* L10: */
    }
  return 0;
  /* 
   *       code for both increments equal to 1 
   * 
   * 
   *       clean-up loop 
   * 
   */
L20:
  m = *n % 7;
  if (m == 0)
    {
      goto L40;
    }
  i__1 = m;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      dy[i__] = dx[i__];
      /* L30: */
    }
  if (*n < 7)
    {
      return 0;
    }
L40:
  mp1 = m + 1;
  i__1 = *n;
  for (i__ = mp1; i__ <= i__1; i__ += 7)
    {
      dy[i__] = dx[i__];
      dy[i__ + 1] = dx[i__ + 1];
      dy[i__ + 2] = dx[i__ + 2];
      dy[i__ + 3] = dx[i__ + 3];
      dy[i__ + 4] = dx[i__ + 4];
      dy[i__ + 5] = dx[i__ + 5];
      dy[i__ + 6] = dx[i__ + 6];
      /* L50: */
    }
  return 0;
}				/* unsfdcopy_ */
