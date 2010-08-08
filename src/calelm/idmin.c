/* idmin.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_idmin (int *n, double *x, int *incx)
{
  /* System generated locals */
  int x_dim1, x_offset, ret_val, i__1;

  /* Local variables */
  double xmin;
  int i__, j;

  /* 
   *    PURPOSE 
   *       finds the index of the first element having minimum value 
   *       without taking into account the nan(s) 
   * 
   *    NOTE 
   *       - original version modified by Bruno (for the nan problem...) 
   *         (01/01/2003) 
   *       - this function return 1 if x has only nan components : may be 
   *         this is not a good behavior 
   *       - this function doesn't test if n<1 or incx<1 : this is done 
   *         by the scilab interface 
   * 
   */
  /* Parameter adjustments */
  x_dim1 = *incx;
  x_offset = x_dim1 + 1;
  x -= x_offset;

  /* Function Body */
  ret_val = 1;
  /*    initialize the min with the first component being not a nan 
   */
  j = 1;
  while (nsp_calpack_isanan (&x[j * x_dim1 + 1]) == 1)
    {
      ++j;
      if (j > *n)
	{
	  return ret_val;
	}
    }
  xmin = x[j * x_dim1 + 1];
  ret_val = j;
  /*    the usual loop 
   */
  i__1 = *n;
  for (i__ = j + 1; i__ <= i__1; ++i__)
    {
      if (x[i__ * x_dim1 + 1] < xmin)
	{
	  /*a test with a nan must always re 
	   */
	  xmin = x[i__ * x_dim1 + 1];
	  ret_val = i__;
	}
    }
  return ret_val;
}				/* idmin_ */
