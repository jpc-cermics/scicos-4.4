/* wipow.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static double c_b4 = 1.;
static double c_b5 = 0.;

int
nsp_calpack_wipow (int *n, double *vr, double *vi, int *iv, int *ipow,
		   int *ierr)
{
  /* System generated locals */
  int i__1, i__2;
  double d__1, d__2;

  /* Local variables */
  int i__, k, ii;
  double xi, xr;

  /*!but 
   *    eleve a une puissance entiere les elements d'un vecteur de flottants 
   *    complexes 
   *!liste d'appel 
   *    subroutine wipow(n,vr,vi,iv,ipow,ierr) 
   *    int n,iv,ipow ,ierr 
   *    double precision vr(n*iv),vi(n*iw) 
   * 
   *    n : nombre d'element du vecteur 
   *    vr : tableau contenant les parties reelles des elements du vecteur 
   *    vi : tableau contenant les parties imaginaires des elements du vecteur 
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
  --vi;
  --vr;

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
      /*puissance 0 
       */
      ii = 1;
      i__1 = *n;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if ((d__1 = vr[ii], Abs (d__1)) + (d__2 = vi[ii], Abs (d__2)) != 0.)
	    {
	      vr[ii] = 1.;
	      vi[ii] = 0.;
	      ii += *iv;
	    }
	  else
	    {
	      *ierr = 1;
	      return 0;
	    }
	  /* L10: */
	}
      return 0;
      /* 
       */
    }
  else if (*ipow < 0)
    {
      /*puissance negative 
       */
      ii = 1;
      i__1 = *n;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if ((d__1 = vr[ii], Abs (d__1)) + (d__2 = vi[ii], Abs (d__2)) != 0.)
	    {
	      nsp_calpack_wdiv (&c_b4, &c_b5, &vr[ii], &vi[ii], &vr[ii],
				&vi[ii]);
	      ii += *iv;
	    }
	  else
	    {
	      *ierr = 2;
	      return 0;
	    }
	  /* L20: */
	}
      if (*ipow == -1)
	{
	  return 0;
	}
    }
  /* 
   *puissance  positive et fin puissance negatives 
   */
  ii = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      xr = vr[ii];
      xi = vi[ii];
      i__2 = Abs (*ipow);
      for (k = 2; k <= i__2; ++k)
	{
	  nsp_calpack_wmul (&xr, &xi, &vr[ii], &vi[ii], &vr[ii], &vi[ii]);
	  /* L31: */
	}
      ii += *iv;
      /* L30: */
    }
  /* 
   */
  return 0;
}				/* wipow_ */
