/* dipowe.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_dipowe (double *v, int *p, double *r__, int *ierr)
{
  /* Builtin functions */
  double pow_di (double *, int *);

  /* Local variables */

  /*!purpose 
   *    computes r=v^p where v double precision and b int 
   *!calling sequence 
   *    subroutine dipowe(v,p,r,ierr) 
   *    int p ,ierr 
   *    double precision v,r 
   * 
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
  if (*p == 1)
    {
      *r__ = *v;
    }
  else if (*p == 0)
    {
      /*    .  v^0 
       *        if(v.ne.0.0d+0) then 
       */
      *r__ = 1.;
      /*        else 
       *           ierr=1 
       *        endif 
       */
    }
  else if (*p < 0)
    {
      if (*v != 0.)
	{
	  *r__ = pow_di (v, p);
	}
      else
	{
	  *r__ = 0.;
	  *r__ = nsp_calpack_infinity (r__);
	  *ierr = 2;
	}
    }
  else
    {
      *r__ = pow_di (v, p);
    }
  /* 
   */
  return 0;
}				/* dipowe_ */
