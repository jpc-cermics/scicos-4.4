/* dwpow.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_dwpow (int *n, double *vr, double *vi, int *iv, double *powr,
		   double *powi, int *ierr)
{
  /* System generated locals */
  int i__1;

  /* Builtin functions */
  double pow_dd (double *, double *), log (double), cos (double),
    sin (double);

  /* Local variables */
  int i__;
  int ii;
  double si, sr;
  int iscmpl;

  /*!but 
   *    eleve les elements d'un vecteur reel a une puissance complexe 
   *!liste d'appel 
   *    subroutine dwpow(n,vr,vi,iv,powr,powi,ierr) 
   *    int n,iv,ierr 
   *    double precision vr(n*iv),vi(n*iv),powr,powi 
   * 
   *    n : nombre d'elements du vecteur 
   *    vr : tableau contenant les  elements du vecteur 
   *    vi : tableau contenant en retour les parties imaginaires du resultat 
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
  /*    puissance reelle 
   */
  nsp_calpack_ddpow (n, &vr[1], &vi[1], iv, powr, ierr, &iscmpl);
  return 0;
  /* 
   */
L1:
  /*    puissance complexes 
   */
  ii = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (vr[ii] != 0.)
	{
	  sr = pow_dd (&vr[ii], powr);
	  si = log (vr[ii]) * *powi;
	  vr[ii] = sr * cos (si);
	  vi[ii] = sr * sin (si);
	  ii += *iv;
	}
      else
	{
	  if (*powr > 0.)
	    {
	      vr[ii] = 0.;
	      vi[ii] = 0.;
	      ii += *iv;
	    }
	  else
	    {
	      *ierr = 2;
	      return 0;
	    }
	}
      /* L20: */
    }
  /* 
   */
  return 0;
}				/* dwpow_ */
