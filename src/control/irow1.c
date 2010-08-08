/* irow1.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int nsp_ctrlpack_irow1 (int *i__, int *m)
{
  /* System generated locals */
  int ret_val;

  /*% calling sequence 
   *       int function irow1(i,m) 
   *%purpose 
   *   this routine is only to be call from syhsc 
   *% 
   */
  ret_val = (*i__ - 1) * *m - (*i__ - 2) * (*i__ - 3) / 2;
  if (*i__ == 1)
    {
      ret_val = 0;
    }
  return ret_val;
}				/* irow1_ */
