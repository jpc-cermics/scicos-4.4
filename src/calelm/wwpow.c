/* wwpow.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wwpow (int *n, double *vr, double *vi, int *iv, double *powr,
		   double *powi, int *ierr)
{
  /* System generated locals */
  int i__1;
  double d__1, d__2;

  /* Builtin functions */
  double exp (double), cos (double), sin (double);

  /* Local variables */
  int i__;
  int ii;
  double si, sr;

  /*!but 
   *    eleve les elements d'un vecteur complexe a une puissance complexe 
   *!liste d'appel 
   *    subroutine wwpow(n,vr,vi,iv,powr,powi,ierr) 
   *    int n,iv,ierr 
   *    double precision vr(n*iv),vi(n*iw),powr,powi 
   * 
   *    n : nombre d'element du vecteur 
   *    vr : tableau contenant les parties reelles des elements du vecteur 
   *    vi : tableau contenant les parties imaginaires des elements du vecteur 
   *    iv : increment entre deux element consecutif du vecteur dans le 
   *         tableau v 
   *    powr : partie reelle de la puissance a la quelle doivent etre 
   *           eleves les elements du vecteur 
   *    powi : partie imaginaire de la puissance a la quelle doivent etre 
   *           eleves les elements du vecteur 
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
  if (*powi != 0.)
    {
      goto L1;
    }
  /*puissance reelle 
   */
  nsp_calpack_wdpow (n, &vr[1], &vi[1], iv, powr, ierr);
  return 0;
  /* 
   */
L1:
  /*puissance complexes 
   */
  ii = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if ((d__1 = vr[ii], Abs (d__1)) + (d__2 = vi[ii], Abs (d__2)) != 0.)
	{
	  nsp_calpack_wlog (&vr[ii], &vi[ii], &sr, &si);
	  nsp_calpack_wmul (&sr, &si, powr, powi, &sr, &si);
	  sr = exp (sr);
	  vr[ii] = sr * cos (si);
	  vi[ii] = sr * sin (si);
	  ii += *iv;
	}
      else
	{
	  *ierr = 0;
	  return 0;
	}
      /* L20: */
    }
  /* 
   */
  return 0;
}				/* wwpow_ */
