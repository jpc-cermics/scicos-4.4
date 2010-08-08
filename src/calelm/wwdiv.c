/* wwdiv.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wwdiv (double *ar, double *ai, double *br, double *bi,
		   double *cr, double *ci, int *ierr)
{
  double d__, r__;

  /* 
   *    PURPOSE 
   *       complex division algorithm : compute c := a / b 
   *       where : 
   * 
   *       a = ar + i ai 
   *       b = br + i bi 
   *       c = cr + i ci 
   * 
   *       inputs  : ar, ai, br, bi  (double precision) 
   *       outputs : cr, ci          (double precision) 
   *                 ierr  (int) ierr = 1 if b = 0 (else 0) 
   * 
   *    IMPLEMENTATION NOTES 
   *       1/ Use scaling with ||b||_oo; the original wwdiv.f used a scaling 
   *          with ||b||_1.  It results fewer operations.  From the famous 
   *          Golberg paper.  This is known as Smith's method. 
   *       2/ Currently set c = NaN + i NaN in case of a division by 0 ; 
   *          is that the good choice ? 
   * 
   *    AUTHOR 
   *       Bruno Pincon <Bruno.Pincon@iecn.u-nancy.fr> 
   * 
   *    PARAMETERS 
   *    LOCAL VARIABLES 
   *    TEXT 
   */
  *ierr = 0;
  /*    Treat special cases 
   */
  if (*bi == 0.)
    {
      if (*br == 0.)
	{
	  *ierr = 1;
	  /*          got NaN + i NaN 
	   */
	  *cr = *bi / *br;
	  *ci = *cr;
	}
      else
	{
	  *cr = *ar / *br;
	  *ci = *ai / *br;
	}
    }
  else if (*br == 0.)
    {
      *cr = *ai / *bi;
      *ci = -(*ar) / *bi;
    }
  else
    {
      /*    Generic division algorithm 
       */
      if (Abs (*br) >= Abs (*bi))
	{
	  r__ = *bi / *br;
	  d__ = *br + r__ * *bi;
	  *cr = (*ar + *ai * r__) / d__;
	  *ci = (*ai - *ar * r__) / d__;
	}
      else
	{
	  r__ = *br / *bi;
	  d__ = *bi + r__ * *br;
	  *cr = (*ar * r__ + *ai) / d__;
	  *ci = (*ai * r__ - *ar) / d__;
	}
    }
  return 0;
}				/* wwdiv_ */
