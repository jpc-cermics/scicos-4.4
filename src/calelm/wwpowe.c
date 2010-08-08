/* wwpowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wwpowe (double *vr, double *vi, double *pr, double *pi,
		    double *rr, double *ri, int *ierr)
{
  /* Builtin functions */
  double exp (double), cos (double), sin (double);

  /* Local variables */
  double si, sr;

  /*!purpose 
   *    computes v^p with v complex and p complex 
   *!calling sequence 
   *    subroutine wdpowe(vr,vi,p,rr,ri,ierr) 
   *    int ierr 
   *    double precision vr,vi,pr,pi,rr,ri 
   *    vr   : real part of v 
   *    vi   : imaginary part of v 
   *    pr   : real part of p 
   *    pi   : imaginary part of p 
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
      nsp_calpack_wdpowe (vr, vi, pr, rr, ri, ierr);
    }
  else
    {
      if (Abs (*vr) + Abs (*vi) != 0.)
	{
	  nsp_calpack_wlog (vr, vi, &sr, &si);
	  nsp_calpack_wmul (&sr, &si, pr, pi, &sr, &si);
	  sr = exp (sr);
	  *rr = sr * cos (si);
	  *ri = sr * sin (si);
	}
      else
	{
	  *ri = 0.;
	  *rr = nsp_calpack_infinity (ri);
	  *ierr = 2;
	}
    }
  /* 
   */
  return 0;
}				/* wwpowe_ */
