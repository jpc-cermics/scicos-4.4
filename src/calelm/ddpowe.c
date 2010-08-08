/* ddpowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static double c_b2 = 0.;

int
nsp_calpack_ddpowe (double *v, double *p, double *rr, double *ri, int *ierr,
		    int *iscmpl)
{
  /* System generated locals */
  int i__1;

  /* Builtin functions */
  double pow_dd (double *, double *), exp (double), cos (double),
    sin (double);

  /* Local variables */
  double si, sr;

  /*!purpose 
   *    computes v^p with p and v double precision 
   *!calling sequence 
   *    subroutine ddpowe(v,p,rr,ri,ierr,iscmpl) 
   *    int ierr 
   *    double precision v,p,rr,ri 
   * 
   *    rr   : result's real part 
   *    ri   : result's imaginary part 
   *    ierr : error flag 
   *           ierr=0 if ok 
   *           ierr=1 if 0**0 
   *           ierr=2 if  0**k with k<0 
   *    iscmpl : 
   *           iscmpl=0 if result is real 
   *           iscmpl=1 if result is complex 
   *!origin 
   *Serge Steer INRIA 1996 
   *! 
   *    Copyright INRIA 
   * 
   */
  *ierr = 0;
  *iscmpl = 0;
  /* 
   */
  if ((double) ((int) (*p)) == *p)
    {
      i__1 = (int) (*p);
      nsp_calpack_dipowe (v, &i__1, rr, ierr);
      *ri = 0.;
    }
  else
    {
      if (*v > 0.)
	{
	  *rr = pow_dd (v, p);
	  *ri = 0.;
	}
      else if (*v < 0.)
	{
	  nsp_calpack_wlog (v, &c_b2, &sr, &si);
	  sr = exp (sr * *p);
	  si *= *p;
	  *rr = sr * cos (si);
	  *ri = sr * sin (si);
	  *iscmpl = 1;
	}
      else if (*v == 0.)
	{
	  if (*p < 0.)
	    {
	      *ri = 0.;
	      *rr = nsp_calpack_infinity (ri);
	      *ierr = 2;
	    }
	  else if (*p == 0.)
	    {
	      /*              ierr=1 
	       */
	      *rr = 1.;
	      *ri = 0.;
	    }
	  else if (*p > 0.)
	    {
	      *rr = 0.;
	      *ri = 0.;
	    }
	  else
	    {
	      /*             p is nan 
	       */
	      *rr = *p;
	      *ri = 0.;
	    }
	}
      else
	{
	  /*          v is nan 
	   */
	  *rr = *v;
	  *ri = 0.;
	}
    }
  /* 
   */
  return 0;
}				/* ddpowe_ */
