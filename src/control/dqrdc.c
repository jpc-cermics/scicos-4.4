/* dqrdc.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Table of constant values */

static int c__1 = 1;

int
nsp_ctrlpack_dqrdc (double *x, int *ldx, int *n, int *p, double *qraux,
		    int *jpvt, double *work, int *job)
{
  /* System generated locals */
  int x_dim1, x_offset, i__1, i__2, i__3;
  double d__1, d__2;

  /* Builtin functions */
  double d_sign (double *, double *), sqrt (double);

  /* Local variables */
  int negj;
  int maxj;
  int j, l;
  double t;
  int swapj;
  double nrmxl;
  int jj, jp, pl, pu;
  double tt, maxnrm;
  int lp1, lup;

  /*!purpose 
   * 
   *    dqrdc uses householder transformations to compute the qr 
   *    factorization of an n by p matrix x.  column pivoting 
   *    based on the 2-norms of the reduced columns may be 
   *    performed at the users option. 
   * 
   *!calling sequence 
   * 
   *     subroutine dqrdc(x,ldx,n,p,qraux,jpvt,work,job) 
   *    on entry 
   * 
   *       x       double precision(ldx,p), where ldx .ge. n. 
   *               x contains the matrix whose decomposition is to be 
   *               computed. 
   * 
   *       ldx     int. 
   *               ldx is the leading dimension of the array x. 
   * 
   *       n       int. 
   *               n is the number of rows of the matrix x. 
   * 
   *       p       int. 
   *               p is the number of columns of the matrix x. 
   * 
   *       jpvt    int(p). 
   *               jpvt contains ints that control the selection 
   *               of the pivot columns.  the k-th column x(k) of x 
   *               is placed in one of three classes according to the 
   *               value of jpvt(k). 
   * 
   *                  if jpvt(k) .gt. 0, then x(k) is an initial 
   *                                     column. 
   * 
   *                  if jpvt(k) .eq. 0, then x(k) is a free column. 
   * 
   *                  if jpvt(k) .lt. 0, then x(k) is a final column. 
   * 
   *               before the decomposition is computed, initial columns 
   *               are moved to the beginning of the array x and final 
   *               columns to the end.  both initial and final columns 
   *               are frozen in place during the computation and only 
   *               free columns are moved.  at the k-th stage of the 
   *               reduction, if x(k) is occupied by a free column 
   *               it is interchanged with the free column of largest 
   *               reduced norm.  jpvt is not referenced if 
   *               job .eq. 0. 
   * 
   *       work    double precision(p). 
   *               work is a work array.  work is not referenced if 
   *               job .eq. 0. 
   * 
   *       job     int. 
   *               job is an int that initiates column pivoting. 
   *               if job .eq. 0, no pivoting is done. 
   *               if job .ne. 0, pivoting is done. 
   * 
   *    on return 
   * 
   *       x       x contains in its upper triangle the upper 
   *               triangular matrix r of the qr factorization. 
   *               below its diagonal x contains information from 
   *               which the orthogonal part of the decomposition 
   *               can be recovered.  note that if pivoting has 
   *               been requested, the decomposition is not that 
   *               of the original matrix x but that of x 
   *               with its columns permuted as described by jpvt. 
   * 
   *       qraux   double precision(p). 
   *               qraux contains further information required to recover 
   *               the orthogonal part of the decomposition. 
   * 
   *       jpvt    jpvt(k) contains the index of the column of the 
   *               original matrix that has been interchanged into 
   *               the k-th column, if pivoting was requested. 
   * 
   *!originator 
   *    linpack. this version dated 08/14/78 . 
   *    g.w. stewart, university of maryland, argonne national lab. 
   * 
   *!auxiliary routines 
   * 
   *    blas daxpy,ddot,dscal,dswap,dnrm2 
   *    fortran abs,max,min,sqrt 
   * 
   *! 
   *    internal variables 
   * 
   * 
   * 
   */
  /* Parameter adjustments */
  x_dim1 = *ldx;
  x_offset = x_dim1 + 1;
  x -= x_offset;
  --qraux;
  --jpvt;
  --work;

  /* Function Body */
  pl = 1;
  pu = 0;
  if (*job == 0)
    {
      goto L60;
    }
  /* 
   *       pivoting has been requested.  rearrange the columns 
   *       according to jpvt. 
   * 
   */
  i__1 = *p;
  for (j = 1; j <= i__1; ++j)
    {
      swapj = jpvt[j] > 0;
      negj = jpvt[j] < 0;
      jpvt[j] = j;
      if (negj)
	{
	  jpvt[j] = -j;
	}
      if (!swapj)
	{
	  goto L10;
	}
      if (j != pl)
	{
	  C2F (dswap) (n, &x[pl * x_dim1 + 1], &c__1,
		       &x[j * x_dim1 + 1], &c__1);
	}
      jpvt[j] = jpvt[pl];
      jpvt[pl] = j;
      ++pl;
    L10:
      /* L20: */
      ;
    }
  pu = *p;
  i__1 = *p;
  for (jj = 1; jj <= i__1; ++jj)
    {
      j = *p - jj + 1;
      if (jpvt[j] >= 0)
	{
	  goto L40;
	}
      jpvt[j] = -jpvt[j];
      if (j == pu)
	{
	  goto L30;
	}
      C2F (dswap) (n, &x[pu * x_dim1 + 1], &c__1, &x[j * x_dim1 + 1], &c__1);
      jp = jpvt[pu];
      jpvt[pu] = jpvt[j];
      jpvt[j] = jp;
    L30:
      --pu;
    L40:
      /* L50: */
      ;
    }
L60:
  /* 
   *    compute the norms of the free columns. 
   * 
   */
  if (pu < pl)
    {
      goto L80;
    }
  i__1 = pu;
  for (j = pl; j <= i__1; ++j)
    {
      qraux[j] = C2F (dnrm2) (n, &x[j * x_dim1 + 1], &c__1);
      work[j] = qraux[j];
      /* L70: */
    }
L80:
  /* 
   *    perform the householder reduction of x. 
   * 
   */
  lup = Min (*n, *p);
  i__1 = lup;
  for (l = 1; l <= i__1; ++l)
    {
      if (l < pl || l >= pu)
	{
	  goto L120;
	}
      /* 
       *          locate the column of largest norm and bring it 
       *          into the pivot position. 
       * 
       */
      maxnrm = 0.;
      maxj = l;
      i__2 = pu;
      for (j = l; j <= i__2; ++j)
	{
	  if (qraux[j] <= maxnrm)
	    {
	      goto L90;
	    }
	  maxnrm = qraux[j];
	  maxj = j;
	L90:
	  /* L100: */
	  ;
	}
      if (maxj == l)
	{
	  goto L110;
	}
      C2F (dswap) (n, &x[l * x_dim1 + 1], &c__1, &x[maxj * x_dim1 + 1],
		   &c__1);
      qraux[maxj] = qraux[l];
      work[maxj] = work[l];
      jp = jpvt[maxj];
      jpvt[maxj] = jpvt[l];
      jpvt[l] = jp;
    L110:
    L120:
      qraux[l] = 0.;
      if (l == *n)
	{
	  goto L190;
	}
      /* 
       *          compute the householder transformation for column l. 
       * 
       */
      i__2 = *n - l + 1;
      nrmxl = C2F (dnrm2) (&i__2, &x[l + l * x_dim1], &c__1);
      if (nrmxl == 0.)
	{
	  goto L180;
	}
      if (x[l + l * x_dim1] != 0.)
	{
	  nrmxl = d_sign (&nrmxl, &x[l + l * x_dim1]);
	}
      i__2 = *n - l + 1;
      d__1 = 1. / nrmxl;
      C2F (dscal) (&i__2, &d__1, &x[l + l * x_dim1], &c__1);
      x[l + l * x_dim1] += 1.;
      /* 
       *             apply the transformation to the remaining columns, 
       *             updating the norms. 
       * 
       */
      lp1 = l + 1;
      if (*p < lp1)
	{
	  goto L170;
	}
      i__2 = *p;
      for (j = lp1; j <= i__2; ++j)
	{
	  i__3 = *n - l + 1;
	  t =
	    -C2F (ddot) (&i__3, &x[l + l * x_dim1], &c__1,
			 &x[l + j * x_dim1], &c__1) / x[l + l * x_dim1];
	  i__3 = *n - l + 1;
	  C2F (daxpy) (&i__3, &t, &x[l + l * x_dim1], &c__1,
		       &x[l + j * x_dim1], &c__1);
	  if (j < pl || j > pu)
	    {
	      goto L150;
	    }
	  if (qraux[j] == 0.)
	    {
	      goto L150;
	    }
	  /*Computing 2nd power 
	   */
	  d__2 = (d__1 = x[l + j * x_dim1], Abs (d__1)) / qraux[j];
	  tt = 1. - d__2 * d__2;
	  tt = Max (tt, 0.);
	  t = tt;
	  /*Computing 2nd power 
	   */
	  d__1 = qraux[j] / work[j];
	  tt = tt * .05 * (d__1 * d__1) + 1.;
	  if (tt == 1.)
	    {
	      goto L130;
	    }
	  qraux[j] *= sqrt (t);
	  goto L140;
	L130:
	  i__3 = *n - l;
	  qraux[j] = C2F (dnrm2) (&i__3, &x[l + 1 + j * x_dim1], &c__1);
	  work[j] = qraux[j];
	L140:
	L150:
	  /* L160: */
	  ;
	}
    L170:
      /* 
       *             save the transformation. 
       * 
       */
      qraux[l] = x[l + l * x_dim1];
      x[l + l * x_dim1] = -nrmxl;
    L180:
    L190:
      /* L200: */
      ;
    }
  return 0;
}				/* dqrdc_ */
