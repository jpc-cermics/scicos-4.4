/* dpofa.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Table of constant values */

static int c__1 = 1;

int nsp_ctrlpack_dpofa (double *a, int *lda, int *n, int *info)
{
  /* System generated locals */
  int a_dim1, a_offset, i__1, i__2, i__3;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int j, k;
  double s, t;
  int jm1;

  /*!purpose 
   * 
   *    dpofa factors a double precision symmetric positive definite 
   *    matrix. 
   * 
   *    dpofa is usually called by dpoco, but it can be called 
   *    directly with a saving in time if  rcond  is not needed. 
   *    (time for dpoco) = (1 + 18/n)*(time for dpofa) . 
   * 
   *!calling sequence 
   * 
   *     subroutine dpofa(a,lda,n,info) 
   *    on entry 
   * 
   *       a       double precision(lda, n) 
   *               the symmetric matrix to be factored.  only the 
   *               diagonal and upper triangle are used. 
   * 
   *       lda     int 
   *               the leading dimension of the array  a . 
   * 
   *       n       int 
   *               the order of the matrix  a . 
   * 
   *    on return 
   * 
   *       a       an upper triangular matrix  r  so that  a = trans(r)*r 
   *               where  trans(r)  is the transpose. 
   *               the strict lower triangle is unaltered. 
   *               if  info .ne. 0 , the factorization is not complete. 
   * 
   *       info    int 
   *               = 0  for normal return. 
   *               = k  signals an error condition.  the leading minor 
   *                    of order  k  is not positive definite. 
   * 
   *!originator 
   *    linpack.  this version dated 08/14/78 . 
   *    cleve moler, university of new mexico, argonne national lab. 
   * 
   *!auxiliary routines 
   * 
   *    blas ddot 
   *    fortran sqrt 
   * 
   *! 
   *    internal variables 
   * 
   *    begin block with ...exits to 40 
   * 
   * 
   */
  /* Parameter adjustments */
  a_dim1 = *lda;
  a_offset = a_dim1 + 1;
  a -= a_offset;

  /* Function Body */
  i__1 = *n;
  for (j = 1; j <= i__1; ++j)
    {
      *info = j;
      s = 0.;
      jm1 = j - 1;
      if (jm1 < 1)
	{
	  goto L20;
	}
      i__2 = jm1;
      for (k = 1; k <= i__2; ++k)
	{
	  i__3 = k - 1;
	  t =
	    a[k + j * a_dim1] - C2F (ddot) (&i__3, &a[k * a_dim1 + 1],
					    &c__1, &a[j * a_dim1 + 1], &c__1);
	  t /= a[k + k * a_dim1];
	  a[k + j * a_dim1] = t;
	  s += t * t;
	  /* L10: */
	}
    L20:
      s = a[j + j * a_dim1] - s;
      /*    ......exit 
       */
      if (s <= 0.)
	{
	  goto L40;
	}
      a[j + j * a_dim1] = sqrt (s);
      /* L30: */
    }
  *info = 0;
L40:
  return 0;
}				/* dpofa_ */
