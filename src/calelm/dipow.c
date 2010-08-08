/* dipow.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int nsp_calpack_dipow (int *n, double *v, int *iv, int *ipow, int *ierr)
{
  /* System generated locals */
  int i__1;

  /* Builtin functions */
  double pow_di (double *, int *);

  /* Local variables */
  int i__, ii;

  /*!but 
   *    eleve a une puissance entiere les elements d'un vecteur de flottants 
   *    double precision 
   *!liste d'appel 
   *    subroutine dipow(n,v,iv,ipow,ierr) 
   *    int n,iv,ipow ,ierr 
   *    double precision v(n*iv) 
   * 
   *    n : nombre d'element du vecteur 
   *    v : tableau contenant les elements du vecteur 
   *    iv : increment entre deux element consecutif du vecteur dans le 
   *         tableau v 
   *    ipow : puissance a la quelle doivent etre eleves les elements du 
   *           vecteur 
   *    ierr : indicateur d'erreur 
   *           ierr=0 si ok 
   *           ierr=1 si 0**0 
   *           ierr=2 si 0**k avec k<0 
   *!origine 
   *Serge Steer INRIA 1989 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --v;

  /* Function Body */
  *ierr = 0;
  /* 
   */
  if (*ipow == 1)
    {
      return 0;
    }
  if (*ipow == 0)
    {
      /*    puissance 0 
       */
      ii = 1;
      i__1 = *n;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (v[ii] != 0.)
	    {
	      v[ii] = 1.;
	      ii += *iv;
	    }
	  else
	    {
	      *ierr = 1;
	      return 0;
	    }
	  /* L10: */
	}
    }
  else if (*ipow < 0)
    {
      /*    puissance negative 
       */
      ii = 1;
      i__1 = *n;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (v[ii] != 0.)
	    {
	      v[ii] = pow_di (&v[ii], ipow);
	      ii += *iv;
	    }
	  else
	    {
	      *ierr = 2;
	      return 0;
	    }
	  /* L20: */
	}
    }
  else
    {
      /*    puissance  positive 
       */
      ii = 1;
      i__1 = *n;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  v[ii] = pow_di (&v[ii], ipow);
	  ii += *iv;
	  /* L30: */
	}
    }
  /* 
   */
  return 0;
}				/* dipow_ */
