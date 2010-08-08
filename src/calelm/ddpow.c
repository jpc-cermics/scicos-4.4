/* ddpow.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static double c_b4 = 0.;

int
nsp_calpack_ddpow (int *n, double *vr, double *vi, int *iv, double *dpow,
		   int *ierr, int *iscmpl)
{
  /* System generated locals */
  int i__1;

  /* Builtin functions */
  double pow_dd (double *, double *), exp (double), cos (double),
    sin (double);

  /* Local variables */
  int i__;
  int ii;
  double si, sr;

  /*!but 
   *    eleve a une puissance reelle les elements d'un vecteur de flottants 
   *    double precision 
   *!liste d'appel 
   *    subroutine ddpow(n,v,iv,dpow,ierr) 
   *    int n,iv,ierr 
   *    double precision v(n*iv),dpow 
   * 
   *    n : nombre d'element du vecteur 
   *    vr : tableau contenant en entree les elements du vecteur et en 
   *         sortie les parties reelles du resultat 
   *    vi : tableau contenant en sortie les parties imaginaire (eventuelles) 
   *         du resultat 
   *    iv : increment entre deux element consecutif du vecteur dans le 
   *         tableau v 
   *    dpow : puissance a la quelle doivent etre eleves les elements du 
   *           vecteur 
   *    ierr : indicateur d'erreur 
   *           ierr=0 si ok 
   *           ierr=1 si 0**0 
   *           ierr=2 si 0**k avec k<0 
   *    iscmpl : 
   *           iscmpl=0 resultat reel 
   *           iscmpl=1 resultat complexe 
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
  *iscmpl = 0;
  /* 
   */
  if ((double) ((int) (*dpow)) != *dpow)
    {
      goto L1;
    }
  /*puissance entiere 
   */
  i__1 = (int) (*dpow);
  nsp_calpack_dipow (n, &vr[1], iv, &i__1, ierr);
  return 0;
  /* 
   */
L1:
  ii = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (vr[ii] > 0.)
	{
	  vr[ii] = pow_dd (&vr[ii], dpow);
	  vi[ii] = 0.;
	}
      else if (vr[ii] < 0.)
	{
	  nsp_calpack_wlog (&vr[ii], &c_b4, &sr, &si);
	  sr = exp (sr * *dpow);
	  si *= *dpow;
	  vr[ii] = sr * cos (si);
	  vi[ii] = sr * sin (si);
	  *iscmpl = 1;
	}
      else
	{
	  if (*dpow < 0.)
	    {
	      *ierr = 2;
	      return 0;
	    }
	  else if (*dpow == 0.)
	    {
	      *ierr = 1;
	      return 0;
	    }
	  else
	    {
	      vr[ii] = 0.;
	      vi[ii] = 0.;
	    }
	}
      ii += *iv;
      /* L20: */
    }
  /* 
   */
  return 0;
}				/* ddpow_ */
