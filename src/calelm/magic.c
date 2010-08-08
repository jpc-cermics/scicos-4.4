/* magic.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static int c__1 = 1;

/*/MEMBR ADD NAME=MAGIC,SSI=0 
 */
int nsp_calpack_magic (double *a, int *lda, int *n)
{
  /* System generated locals */
  int a_dim1, a_offset, i__1, i__2;

  /* Local variables */
  int i__, j, k, m;
  double t;
  int i1, j1, m1, m2, im, jm, mm;

  /*!purpose 
   *    algorithms for magic squares taken from 
   *       mathematical recreations and essays, 12th ed., 
   *       by w. w. rouse ball and h. s. m. coxeter 
   *!calling sequence 
   *    subroutine magic(a,lda,n) 
   *    double precision a(lda,n) 
   *    int lda,n 
   *! 
   * 
   */
  /* Parameter adjustments */
  a_dim1 = *lda;
  a_offset = a_dim1 + 1;
  a -= a_offset;

  /* Function Body */
  if (*n % 4 == 0)
    {
      goto L100;
    }
  if (*n % 2 == 0)
    {
      m = *n / 2;
    }
  if (*n % 2 != 0)
    {
      m = *n;
    }
  /* 
   *    odd order or upper corner of even order 
   * 
   */
  i__1 = m;
  for (j = 1; j <= i__1; ++j)
    {
      i__2 = m;
      for (i__ = 1; i__ <= i__2; ++i__)
	{
	  a[i__ + j * a_dim1] = 0.;
	  /* L10: */
	}
      /* L20: */
    }
  i__ = 1;
  j = (m + 1) / 2;
  mm = m * m;
  i__1 = mm;
  for (k = 1; k <= i__1; ++k)
    {
      a[i__ + j * a_dim1] = (double) k;
      i1 = i__ - 1;
      j1 = j + 1;
      if (i1 < 1)
	{
	  i1 = m;
	}
      if (j1 > m)
	{
	  j1 = 1;
	}
      if ((int) a[i1 + j1 * a_dim1] == 0)
	{
	  goto L30;
	}
      i1 = i__ + 1;
      j1 = j;
    L30:
      i__ = i1;
      j = j1;
      /* L40: */
    }
  if (*n % 2 != 0)
    {
      return 0;
    }
  /* 
   *    rest of even order 
   * 
   */
  t = (double) (m * m);
  i__1 = m;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = m;
      for (j = 1; j <= i__2; ++j)
	{
	  im = i__ + m;
	  jm = j + m;
	  a[i__ + jm * a_dim1] = a[i__ + j * a_dim1] + t * 2;
	  a[im + j * a_dim1] = a[i__ + j * a_dim1] + t * 3;
	  a[im + jm * a_dim1] = a[i__ + j * a_dim1] + t;
	  /* L50: */
	}
      /* L60: */
    }
  m1 = (m - 1) / 2;
  if (m1 == 0)
    {
      return 0;
    }
  i__1 = m1;
  for (j = 1; j <= i__1; ++j)
    {
      C2F (dswap) (&m, &a[j * a_dim1 + 1], &c__1,
		   &a[m + 1 + j * a_dim1], &c__1);
      /* L70: */
    }
  m1 = (m + 1) / 2;
  m2 = m1 + m;
  C2F (dswap) (&c__1, &a[m1 + a_dim1], &c__1, &a[m2 + a_dim1], &c__1);
  C2F (dswap) (&c__1, &a[m1 + m1 * a_dim1], &c__1,
	       &a[m2 + m1 * a_dim1], &c__1);
  m1 = *n + 1 - (m - 3) / 2;
  if (m1 > *n)
    {
      return 0;
    }
  i__1 = *n;
  for (j = m1; j <= i__1; ++j)
    {
      C2F (dswap) (&m, &a[j * a_dim1 + 1], &c__1,
		   &a[m + 1 + j * a_dim1], &c__1);
      /* L80: */
    }
  return 0;
  /* 
   *    double even order 
   * 
   */
L100:
  k = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = *n;
      for (j = 1; j <= i__2; ++j)
	{
	  a[i__ + j * a_dim1] = (double) k;
	  if (i__ % 4 / 2 == j % 4 / 2)
	    {
	      a[i__ + j * a_dim1] = (double) (*n * *n + 1 - k);
	    }
	  ++k;
	  /* L110: */
	}
      /* L120: */
    }
  return 0;
}				/* magic_ */
