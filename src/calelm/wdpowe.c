/* wdpowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wdpowe (double *vr, double *vi, double *p, double *rr,
		    double *ri, int *ierr)
{
  /* System generated locals */
  int i__1;

  /* Builtin functions */
  double exp (double), cos (double), sin (double);

  /* Local variables */
  double si, sr;

  /*!purpose 
   *    computes v^p with v complex and p real 
   *!calling sequence 
   *    subroutine wdpowe(vr,vi,p,rr,ri,ierr) 
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
  if ((double) ((int) (*p)) == *p)
    {
      i__1 = (int) (*p);
      nsp_calpack_wipowe (vr, vi, &i__1, rr, ri, ierr);
    }
  else
    {
      if (Abs (*vr) + Abs (*vi) != 0.)
	{
	  nsp_calpack_wlog (vr, vi, &sr, &si);
	  sr = exp (sr * *p);
	  si *= *p;
	  *rr = sr * cos (si);
	  *ri = sr * sin (si);
	}
      else
	{
	  if (*p > 0.)
	    {
	      *rr = 0.;
	      *ri = 0.;
	    }
	  else if (*p < 0.)
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
}				/* wdpowe_ */
