/* irow2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int nsp_ctrlpack_irow2 (int *i__, int *m)
{
  /* System generated locals */
  int ret_val;

  /* Local variables */
  int k;

  /*%calling sequence 
   *       int function irow2(i,m) 
   * 
   *%purpose 
   *     this routine is only to be called from syhsc 
   *% 
   */
  ret_val = ((*i__ - 1) << 1) * *m;
  k = (*i__ - 4) * (*i__ - 3) / 2;
  if (*i__ <= 2)
    {
      k = 0;
    }
  ret_val -= k;
  return ret_val;
}				/* irow2_ */
