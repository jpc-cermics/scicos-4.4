/* ddif.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=DDIF,SSI=0 
 *    Copyright INRIA 
 */
int nsp_calpack_ddif (int *n, double *a, int *na, double *b, int *nb)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, ia, ib;

  /*!but 
   *    ddif effectue l'operation vectorielle b=b-a 
   *!liste d'appel 
   *    subroutine ddif(n,a,na,b,nb) 
   *    double precision a(*),b(*) 
   *    int n,na,nb 
   * 
   *    n : nombre d'elements des vecteurs a et b 
   *    a : tableau contenant a 
   *    na : increment entre deux elements consecutifs de a 
   *         na > 0 
   *    b,nb : definitions similaires a celles de a et na 
   *! 
   */
  /* Parameter adjustments */
  --b;
  --a;

  /* Function Body */
  ia = 1;
  ib = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      b[ib] -= a[ia];
      ia += *na;
      ib += *nb;
      /* L10: */
    }
  return 0;
}				/* ddif_ */
