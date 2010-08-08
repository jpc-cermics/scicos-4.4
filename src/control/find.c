/* find.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_find (int *lsize, double *alpha, double *beta, double *s,
		   double *p)
{
  /* System generated locals */
  int ret_val;

  /*    Copyright INRIA 
   *!purpose 
   *     this function checks if 
   *      the real root alpha/beta lies in the unit disc (if lsize=1) 
   *      the complex conjugate roots with sum s and product p lie 
   *      in the unit disc (if lsize=2) 
   *     if so, find=1, otherwise find=-1 
   *     in this function the parameter s is not referenced 
   * 
   *!calling sequence 
   * 
   *    int function find(lsize,alpha,beta,s,p) 
   *    int lsize 
   *    double precision alpha,beta,s,p 
   *!auxiliary routines 
   *    Abs(fortran) 
   *! 
   */
  ret_val = -1;
  if (*lsize == 2)
    {
      goto L2;
    }
  if (Abs (*alpha) < Abs (*beta))
    {
      ret_val = 1;
    }
  return ret_val;
L2:
  if (Abs (*p) < 1.)
    {
      ret_val = 1;
    }
  return ret_val;
}				/* find_ */
