/* lnblnk.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_lnblnk (char *str, long int str_len)
{
  /* System generated locals */
  int ret_val;

  /* Builtin functions */
  int i_len (char *, long int);

  /* Local variables */
  int n;

  /*    Copyright INRIA 
   */
  n = i_len (str, str_len) + 1;
L10:
  --n;
  if (n == 0)
    {
      ret_val = 0;
      return ret_val;
    }
  else
    {
      if (*(unsigned char *) &str[n - 1] != ' ')
	{
	  ret_val = n;
	  return ret_val;
	}
    }
  goto L10;
}				/* lnblnk_ */
