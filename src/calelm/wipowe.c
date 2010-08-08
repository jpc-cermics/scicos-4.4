/* wipowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static double c_b2 = 1.;
static double c_b3 = 0.;

int
nsp_calpack_wipowe (double *vr, double *vi, int *p, double *rr, double *ri,
		    int *ierr)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int k;
  double xi, xr;

  /*!purpose 
   *    computes v^p with v complex and p int 
   *!calling sequence 
   *    subroutine wipowe(vr,vi,p,rr,ri,ierr) 
   *    int ierr 
   *    double precision vr,vi,p,rr,ri 
   *    vr   : real part of v 
   *    vi   : imaginary part of v 
   *    rr   : result's real part 
   *    ri   : result's imaginary part 
   *    ierr : error flag 
   *           ierr=0 if ok 
   *           ierr=1 if 0**0 
   *           ierr=2 if  0**k with k<0 
   *!origin 
   *Serge Steer INRIA 1996 
   *! 
   *    Copyright INRIA 
   * 
   */
  *ierr = 0;
  /* 
   */
  if (*p == 0)
    {
      *rr = 1.;
      *ri = 0.;
    }
  else if (*p < 0)
    {
      if (Abs (*vr) + Abs (*vi) != 0.)
	{
	  nsp_calpack_wdiv (&c_b2, &c_b3, vr, vi, rr, ri);
	  xr = *rr;
	  xi = *ri;
	  i__1 = Abs (*p);
	  for (k = 2; k <= i__1; ++k)
	    {
	      nsp_calpack_wmul (&xr, &xi, rr, ri, rr, ri);
	      /* L10: */
	    }
	}
      else
	{
	  *ri = 0.;
	  *rr = nsp_calpack_infinity (ri);
	  *ierr = 2;
	}
    }
  else
    {
      *rr = *vr;
      *ri = *vi;
      xr = *rr;
      xi = *ri;
      i__1 = Abs (*p);
      for (k = 2; k <= i__1; ++k)
	{
	  nsp_calpack_wmul (&xr, &xi, rr, ri, rr, ri);
	  /* L20: */
	}
    }
  return 0;
}				/* wipowe_ */
