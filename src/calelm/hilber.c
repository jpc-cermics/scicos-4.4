/* hilber.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=HILBER,SSI=0 
 *    Copyright INRIA 
 */
int nsp_calpack_hilber (double *a, int *lda, int *n)
{
  /* System generated locals */
  int a_dim1, a_offset, i__1, i__2;
  double d__1;

  /* Local variables */
  int i__, j;
  double p, r__;
  int ip1;

  /*!but 
   *    hilber genere l'inverse de la matrice de hilbert 
   *!liste d'appel 
   *     subroutine hilber(a,lda,n) 
   *    double precision a(lda,n) 
   * 
   *    a : tableau contenant apres execution l'inverse de la matrice 
   *        de hilbert de dimension n 
   *    lda : nombre de ligne de a dans le programme appelant 
   *    n : dimension de la matrice de hilbert 
   *! 
   */
  /* Parameter adjustments */
  a_dim1 = *lda;
  a_offset = a_dim1 + 1;
  a -= a_offset;

  /* Function Body */
  p = (double) (*n);
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (i__ != 1)
	{
	  /*Computing 2nd power 
	   */
	  d__1 = (double) (i__ - 1);
	  p =
	    (double) (*n - i__ + 1) * p * (double) (*n + i__ -
						    1) / (d__1 * d__1);
	}
      r__ = p * p;
      a[i__ + i__ * a_dim1] = r__ / (double) ((i__ << 1) - 1);
      if (i__ == *n)
	{
	  goto L20;
	}
      ip1 = i__ + 1;
      i__2 = *n;
      for (j = ip1; j <= i__2; ++j)
	{
	  /*Computing 2nd power 
	   */
	  d__1 = (double) (j - 1);
	  r__ = -((double) (*n - j + 1) * r__ * (*n + j - 1)) / (d__1 * d__1);
	  a[i__ + j * a_dim1] = r__ / (double) (i__ + j - 1);
	  a[j + i__ * a_dim1] = a[i__ + j * a_dim1];
	  /* L10: */
	}
    L20:
      ;
    }
  return 0;
}				/* hilber_ */
