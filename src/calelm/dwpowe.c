/* dwpowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static double c_b2 = 0.;

int
nsp_calpack_dwpowe (double *v, double *pr, double *pi, double *rr,
		    double *ri, int *ierr)
{
  /* Builtin functions */
  double exp (double), cos (double), sin (double);

  /* Local variables */
  double si, sr;
  int iscmpl;

  /*!purose 
   *    computes v^p with v double precision and p complex 
   *!calling sequence 
   *    subroutine dwpowe(v,pr,pi,rr,ri,ierr) 
   *    int ierr 
   *    double precision v,pr,pi,rr,ri 
   * 
   *    pr   : exponent real part 
   *    pi   : exponent imaginary part 
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
  if (*pi == 0.)
    {
      /*    p real 
       */
      nsp_calpack_ddpowe (v, pr, rr, ri, ierr, &iscmpl);
    }
  else
    {
      if (*v != 0.)
	{
	  nsp_calpack_wlog (v, &c_b2, &sr, &si);
	  nsp_calpack_wmul (&sr, &si, pr, pi, &sr, &si);
	  sr = exp (sr);
	  *rr = sr * cos (si);
	  *ri = sr * sin (si);
	}
      else
	{
	  if (*pr > 0.)
	    {
	      *rr = 0.;
	      *ri = 0.;
	    }
	  else if (*pr < 0.)
	    {
	      *ri = 0.;
	      *rr = nsp_calpack_infinity (ri);
	      *ierr = 2;
	    }
	  else
	    {
	      *rr = 1.;
	      *ri = 0.;
	    }
	}
    }
  /* 
   */
  return 0;
}				/* dwpowe_ */
