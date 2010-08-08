/* arl2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"
#include "../calelm/calpack.h"

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

/* Table of constant values */

static int c__1 = 1;
static int c__20 = 20;
static int c__17 = 17;
static int c__21 = 21;
static int c__22 = 22;

int
nsp_ctrlpack_arl2 (double *f, int *nf, double *num, double *tq, int *dgmin,
		   int *dgmax, double *errl2, double *w, int *iw, int *inf,
		   int *ierr, int *ilog)
{
  /* System generated locals */
  int i__1, i__2;
  double d__1;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int liww;
  double t;
  double x;
  int lfree, lwode;
  int lqdot;
  int dg, dgback;
  int ntest1, ng, ifaceo;
  int ncoeff, lw, lifree, dginit;
  double xx[1];
  int liwode, nch;
  int dgr;
  int ltg, nnn, liw, ltq, ltr;
  double tms[2];
  int lrw;
  double tps[2], phi0;

  /*!but 
   *    Cette procedure a pour but de gerer l'execution dans 
   *    le cas ou un unique polynome approximant est desire 
   *!liste d'appel 
   *     subroutine arl2(f,nf,num,tq,dgmin,dgmax,errl2,w, 
   *    $     inf,ierr,ilog) 
   * 
   *    double precision tq(dgmax+1),f(nf),num(dgmax) 
   *    double precision w(*) 
   *    int dgmin,dgmax,dginit,info,ierr,iw(*) 
   * 
   *    Entree : 
   *    dgmin. est le degre du polynome de depart quand il est 
   *       fourni, (vaux 0 s'il ne l'est pas). 
   *    dginit. est le premier degre pour lequel aura lieu la 
   *       recherche. 
   *    dgmax. est le degre desire du dernier approximant 
   *    tq. est le tableau contenant le polynome qui peut etre 
   *       fourni comme point de depart par l'utilisateur. 
   * 
   *    Sortie : 
   *    tq. contient la solution obtenu de degre dgmax. 
   *    num. contient les coefficients du numerateur optimal 
   *    errl2. contient l'erreur L2 pour l'optimum retourne 
   *    ierr. contient l'information sur le deroulement du programme 
   *         ierr=0 : ok 
   *         ierr=3 : boucle indesirable sur 2 ordres 
   *         ierr=4 : plantage lsode 
   *         ierr=5 : plantage dans recherche de l'intersection avec une face 
   * 
   * tableau de travail 
   *    w: dimension:  32+32*dgmax+7*ng+dgmax*ng+dgmax**2*(ng+2) 
   *    iw : dimension  29+dgmax**2+4*dgmax 
   *!sous programme appeles 
   * optml2,feq,jacl2,outl2,lq,phi (arl2) 
   * dcopy,dnrm2,dscal,dpmul1 
   *!origine 
   *M Cardelli, L Baratchart  INRIA sophia-Antipolis 1989, S Steer 
   *!organigramme 
   *arl2 
   *   optml2 
   *         outl2 
   *         feq 
   *         domout 
   *                onface 
   *                       rootgp 
   *                       feq 
   *                       outl2 
   *                outl2 
   *                phi 
   *                lsode 
   *                front 
   *                watfac 
   *         front 
   *         lsode 
   *                feq 
   *                jacl2 
   *                       hessl2 
   *                             lq 
   *   outl2 
   *         feq 
   *         phi 
   *         lq 
   *         jacl2 
   *   phi 
   *         lq 
   *         calsca 
   *   feq 
   *         lq 
   *         calsca 
   *   lq 
   *! 
   *    Copyright INRIA 
   * 
   * 
   *    taille des tableaux de travail necessaires a lsode 
   */
  /* Parameter adjustments */
  --f;
  --tq;
  --num;
  --w;
  --iw;

  /* Function Body */
  /*Computing 2nd power 
   */
  i__1 = *dgmax;
  lrw = i__1 * i__1 + *dgmax * 9 + 22;
  liw = *dgmax + 20;
  /*    decoupage du tableau de travail w 
   */
  ncoeff = *nf;
  ng = *nf - 1;
  ltq = 1;
  ltg = ltq + *dgmax + 1;
  lwode = ltg + ng + 1;
  /*Computing 2nd power 
   */
  i__1 = *dgmax;
  ltr =
    lwode + 5 + *dgmax * 5 + ng * 5 + *dgmax * ng + i__1 * i__1 * (ng + 1);
  /*Computing 2nd power 
   */
  i__1 = *dgmax;
  lfree = ltr + 25 + *dgmax * 26 + ng + i__1 * i__1;
  /*    les lrw elements de w suivant w(ltr) ne doivent pas etre modifies 
   *    d'un appel de optml2 a l'autre 
   */
  lw = ltr + lrw;
  /* 
   *    decoupage du tableau de travail iw 
   */
  liwode = 1;
  liww = liwode + 4 + (*dgmax + 1) * (*dgmax + 2);
  lifree = liww + 20 + *dgmax;
  iw[liwode + 1] = ng;
  iw[liwode + 2] = *dgmax;
  sortie_1.ll = 80;
  sortie_1.info = *inf;
  sortie_1.io = *ilog;
  /* 
   *test validite des arguments 
   * 
   */
  if (*dgmin > 0)
    {
      dginit = *dgmin;
      i__1 = *dgmin + 1;
      C2F (dcopy) (&i__1, &tq[1], &c__1, &w[ltq], &c__1);
    }
  else
    {
      w[ltq] = 1.;
      dginit = 1;
    }
  /* 
   */
  dgr = dginit;
  *ierr = 0;
  ntest1 = -1;
  /* 
   */
  ng = *nf - 1;
  C2F (dcopy) (nf, &f[1], &c__1, &w[ltg], &c__1);
  no2f_1.gnrm = C2F (dnrm2) (nf, &f[1], &c__1);
  d__1 = 1. / no2f_1.gnrm;
  C2F (dscal) (nf, &d__1, &w[ltg], &c__1);
  /*Computing 2nd power 
   */
  d__1 = no2f_1.gnrm;
  no2f_1.gnrm = d__1 * d__1;
  /* 
   */
  tps[0] = 1.;
  tps[1] = 1.;
  tms[0] = -1.;
  tms[1] = 1.;
  /* 
   *    ---- Boucle de calcul --------------------------------------------- 
   * 
   */
  i__1 = *dgmax;
  for (nnn = dginit; nnn <= i__1; ++nnn)
    {
      /* 
       */
      ifaceo = 0;
      /* 
       */
      if (nnn == dginit)
	{
	  if (*dgmin > 0)
	    {
	      dg = dginit;
	      goto L230;
	    }
	  else
	    {
	      dg = dginit - 1;
	    }
	}
      /* 
       */
    L200:
      ++dg;
      /* 
       *    -- Initialisation du nouveau point de depart -- 
       *    (dans l'espace de dimension dg , Hyperespace superieur 
       *    d'une dimension par rapport au precedent ). 
       * 
       */
      if (ntest1 == 1)
	{
	  i__2 = dg - 1;
	  nsp_ctrlpack_dpmul1 (&w[ltq], &i__2, tps, &c__1, &w[ltr]);
	  i__2 = dg + 1;
	  C2F (dcopy) (&i__2, &w[ltr], &c__1, &w[ltq], &c__1);
	}
      else if (ntest1 == -1)
	{
	  i__2 = dg - 1;
	  nsp_ctrlpack_dpmul1 (&w[ltq], &i__2, tms, &c__1, &w[ltr]);
	  i__2 = dg + 1;
	  C2F (dcopy) (&i__2, &w[ltr], &c__1, &w[ltq], &c__1);
	}
      /* 
       *    ------------------------ 
       * 
       */
    L230:
      dgback = dg;
      /* 
       */
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__20, &dg, &dgback, xx, xx, &x, &x);
	}
      /* 
       */
      nch = 1;
      iw[liwode] = dg;
      nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2, &iw[liwode],
			   &w[ltq], &nch, &w[ltr], &iw[1]);
      dg = iw[liwode];
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_lq (&dg, &w[ltq], &w[lw], &w[ltg], &ng);
	  x = sqrt (no2f_1.gnrm);
	  C2F (dscal) (&dg, &x, &w[lw], &c__1);
	  nsp_ctrlpack_outl2 (&nch, &dg, &dg, &w[ltq], &w[lw], &x, &x);
	  phi0 = (d__1 =
		  nsp_ctrlpack_phi (&w[ltq], &dg, &w[ltg], &ng, &w[lw]),
		  Abs (d__1));
	  lqdot = lw;
	  nsp_ctrlpack_feq (&iw[liwode], &t, &w[ltq], &w[lqdot]);
	  nsp_ctrlpack_outl2 (&c__17, &dg, &dg, &w[ltq], &w[lqdot], &phi0,
			      &x);
	}
      if (nch >= 15)
	{
	  if (nch == 17)
	    {
	      i__2 = dg + 1;
	      C2F (dcopy) (&i__2, &w[ltq], &c__1, &tq[1], &c__1);
	      dgr = dg;
	      goto L231;
	    }
	  *ierr = nch - 11;
	  goto L510;
	}
      /* 
       */
      if (nch < 0)
	{
	  ++ifaceo;
	  ntest1 = -ntest1;
	  if (dg == 0)
	    {
	      goto L200;
	    }
	  goto L230;
	}
      /* 
       */
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__21, &dg, &dg, xx, xx, &x, &x);
	}
      nch = 2;
      iw[liwode] = dg;
      nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2, &iw[liwode],
			   &w[ltq], &nch, &w[ltr], &iw[1]);
      if (sortie_1.info > 0)
	{
	  nsp_ctrlpack_lq (&dg, &w[ltq], &w[lw], &w[ltg], &ng);
	  x = sqrt (no2f_1.gnrm);
	  C2F (dscal) (&dg, &x, &w[lw], &c__1);
	  nsp_ctrlpack_outl2 (&nch, &dg, &dg, &w[ltq], &w[lw], &x, &x);
	  phi0 = (d__1 =
		  nsp_ctrlpack_phi (&w[ltq], &dg, &w[ltg], &ng, &w[lw]),
		  Abs (d__1));
	  lqdot = lw;
	  nsp_ctrlpack_feq (&iw[liwode], &t, &w[ltq], &w[lqdot]);
	  nsp_ctrlpack_outl2 (&c__17, &dg, &dg, &w[ltq], &w[lqdot], &phi0,
			      &x);
	}
      if (nch >= 15)
	{
	  if (nch == 17)
	    {
	      i__2 = dg + 1;
	      C2F (dcopy) (&i__2, &w[ltq], &c__1, &tq[1], &c__1);
	      dgr = dg;
	      goto L231;
	    }
	  *ierr = nch - 11;
	  goto L510;
	}
      /* 
       */
      if (nch < 0)
	{
	  ++ifaceo;
	  ntest1 = -ntest1;
	  if (dg == 0)
	    {
	      goto L200;
	    }
	  goto L230;
	}
      /* 
       * 
       */
    L231:
      if (ifaceo == 8)
	{
	  if (sortie_1.info >= 0)
	    {
	      nsp_ctrlpack_outl2 (&c__22, &dg, &dg, xx, xx, &x, &x);
	    }
	  *ierr = 3;
	  goto L510;
	}
      /* 
       */
      if (dg < nnn)
	{
	  goto L200;
	}
      i__2 = dg + 1;
      C2F (dcopy) (&i__2, &w[ltq], &c__1, &tq[1], &c__1);
      dgr = dg;
      /* 
       */
      /* L500: */
    }
  /* 
   *Fin de la recherche Optimale 
   *numerateur optimal 
   */
L510:
  no2f_1.gnrm = sqrt (no2f_1.gnrm);
  nsp_ctrlpack_lq (&dgr, &tq[1], &w[ltr], &w[ltg], &ng);
  C2F (dcopy) (&dgr, &w[ltr], &c__1, &num[1], &c__1);
  C2F (dscal) (&dgr, &no2f_1.gnrm, &num[1], &c__1);
  /*    Le gradient de la fonction critere y vaut :-tqdot 
   *    call feq(dg,t,w(ltq),tqdot) 
   *    valeur du critere 
   */
  lw = ltg + ncoeff + 1;
  *errl2 =
    sqrt (nsp_ctrlpack_phi (&tq[1], &dgr, &w[ltg], &ng, &w[lw])) *
    no2f_1.gnrm;
  *dgmax = dgr;
  /* 
   */
  return 0;
}				/* arl2_ */
