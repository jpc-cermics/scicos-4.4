/* arl2a.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Common Block Declarations */

struct
{
  int io, info, ll;
} sortie_;

#define sortie_1 sortie_

struct
{
  double gnrm;
} no2f_;

#define no2f_1 no2f_

struct
{
  int nall1;
} comall_;

#define comall_1 comall_

/* Table of constant values */

static int c__1 = 1;
static int c__23 = 23;

int
nsp_ctrlpack_arl2a (double *f, int *nf, double *ta, int *mxsol, int *imina,
		    int *nall, int *inf, int *ierr, int *ilog, double *w,
		    int *iw)
{
  /* System generated locals */
  int ta_dim1, ta_offset, i__1, i__2;
  double d__1;

  /* Local variables */
  int ideg, ldeg, ntbj, lter;
  int iback, j;
  int ildeg;
  double x[1];
  int lfree, iminb, dgmax, iminc, ilntb;
  int ng;
  int ncoeff, ltback, ilfree;
  double tt;
  int ilnter, nch, ltb, ltc, neq, ltq;

  /*!but 
   *    Cette procedure a pour but de rechercher le plus 
   *    grand nombre d'approximants pour chaque degre en partant 
   *    du degre 1 jusqu'a l'ordre nall. 
   *!liste d'appel 
   *    subroutine arl2a(f,nf,ta,nta,nall,info,ierr,io) 
   *    double precision ta(mxsol,0:nall),f(nf),w(*) 
   *    int iw(*) 
   * 
   *    entrees 
   *     f : vecteur des coefficients de Fourier 
   *     nf : nombre de coefficients de Fourrier maxi 200 
   *     nall: degre des polynomes minimums que l'on veut  atteindre. 
   *     inf : impression de la progression de l'algorithme: 
   *           0 = rien 
   *           1 = resultats intermediaires et messages d'erreur 
   *           2 = suivi detaille 
   *     ilog : etiquette logique du fichier ou sont ecrite ces informations 
   * 
   *     sorties 
   *      ta :tableau contenant les minimums  locaux a l'ordre nall 
   *      imina : nombre de minimums trouves 
   *      ierr. contient l'information sur le deroulement du programme 
   *         ierr=0 : ok 
   *         ierr=1 : trop de coefficients de fourrier (maxi 200) 
   *         ierr=2 : ordre d'approximation trop eleve 
   *         ierr=3 : boucle indesirable sur 2 ordres 
   *         ierr=4 : plantage lsode 
   *         ierr=5 : plantage dans recherche de l'intersection avec une face 
   *         ierr=7 : trop de solutions 
   * 
   *     tableaux de travail 
   *     w: 34+34*nall+7*ng+nall*ng+nall**2*(ng+2)+4*(nall+1)*mxsol 
   *     iw :29+nall**2+4*nall+2*mxsol 
   *!Origine 
   *M Cardelli L Baratchart INRIA Sophia-Antipolis 1989 
   *! 
   *    Copyright INRIA 
   * 
   *    decoupage du tableau de travail w 
   */
  /* Parameter adjustments */
  --f;
  ta_dim1 = *mxsol;
  ta_offset = ta_dim1 + 1;
  ta -= ta_offset;
  --w;
  --iw;

  /* Function Body */
  dgmax = *nall;
  ncoeff = *nf;
  ng = *nf - 1;
  ldeg = 1;
  /*Computing 2nd power 
   */
  i__1 = dgmax;
  ltb = ldeg + 33 + dgmax * 33 + ng * 7 + dgmax * ng + i__1 * i__1 * (ng + 2);
  ltc = ltb + (*nall + 1) * *mxsol;
  ltback = ltc + (*nall + 1) * *mxsol;
  lter = ltback + (*nall + 1) * *mxsol;
  ltq = ltback + (*nall + 1) * *mxsol;
  lfree = ltq + *nall + 1;
  /* 
   *    decoupage du tableau de travail iw 
   */
  ildeg = 1;
  /*Computing 2nd power 
   */
  i__1 = dgmax;
  ilntb = ildeg + 29 + i__1 * i__1 + (dgmax << 2);
  ilnter = ilntb + *mxsol;
  ilfree = ilnter + *mxsol;
  /*    initialisations 
   */
  sortie_1.io = *ilog;
  sortie_1.ll = 80;
  sortie_1.info = *inf;
  comall_1.nall1 = *nall;
  /* 
   *test validite des arguments 
   * 
   */
  ng = *nf - 1;
  no2f_1.gnrm = C2F (dnrm2) (nf, &f[1], &c__1);
  d__1 = 1. / no2f_1.gnrm;
  C2F (dscal) (nf, &d__1, &f[1], &c__1);
  /*Computing 2nd power 
   */
  d__1 = no2f_1.gnrm;
  no2f_1.gnrm = d__1 * d__1;
  /* 
   * 
   */
  iback = 0;
  /* 
   */
  nsp_ctrlpack_deg1l2 (&f[1], &ng, imina, &ta[ta_offset], mxsol, &w[ldeg],
		       &iw[ildeg], ierr);
  if (*ierr > 0)
    {
      return 0;
    }
  if (*nall == 1)
    {
      goto L400;
    }
  neq = 1;
  /* 
   */
  i__1 = *nall;
  for (ideg = 2; ideg <= i__1; ++ideg)
    {
      nsp_ctrlpack_degl2 (&f[1], &ng, &neq, imina, &iminb, &iminc,
			  &ta[ta_offset], &w[ltb], &w[ltc], &iback,
			  &iw[ilntb], &w[ltback], mxsol, &w[ldeg], &iw[ildeg],
			  ierr);
      if (*ierr > 0)
	{
	  return 0;
	}
      /* 
       */
      if (*imina == 0)
	{
	  goto L201;
	}
      /* 
       */
      /* L200: */
    }
  /* 
   */
L201:
  if (sortie_1.info > 1)
    {
      nsp_ctrlpack_outl2 (&c__23, &neq, &iback, x, x, &tt, &tt);
    }
  /* 
   */
  if (iback > 0)
    {
      *imina = 0;
      neq = iw[ilntb];
      *inf = 1;
      i__1 = *nall - 1;
      for (ideg = neq; ideg <= i__1; ++ideg)
	{
	  /* 
	   */
	  i__2 = iback;
	  for (j = *inf; j <= i__2; ++j)
	    {
	      ntbj = iw[ilntb + j - 1];
	      if (ntbj == neq)
		{
		  C2F (dcopy) (&ntbj, &w[ltback - 1 + j], mxsol,
			       &w[ltq], &c__1);
		  w[ltq + ntbj] = 1.;
		  /* 
		   */
		  nch = 1;
		  /*    remplacement de tq par w(ltq) tq n'est pas defini 
		   */
		  nsp_ctrlpack_storl2 (&neq, &w[ltq], &f[1], &ng, imina,
				       &ta[ta_offset], &iback, &iw[ilnter],
				       &w[lter], &nch, mxsol, &w[ldeg], ierr);
		}
	      else
		{
		  *inf = j;
		  goto L260;
		}
	      /* L250: */
	    }
	  /* 
	   */
	L260:
	  nsp_ctrlpack_degl2 (&f[1], &ng, &neq, imina, &iminb, &iminc,
			      &ta[ta_offset], &w[ltb], &w[ltc], &iback,
			      &iw[ilnter], &w[lter], mxsol, &w[ldeg],
			      &iw[ildeg], ierr);
	  if (*ierr > 0)
	    {
	      return 0;
	    }
	  /* 
	   */
	  /* L300: */
	}
    }
  /* 
   */
L400:
  /* 
   */
  return 0;
}				/* arl2a_ */
