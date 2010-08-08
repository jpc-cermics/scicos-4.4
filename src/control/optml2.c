/* optml2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Common Block Declarations */

struct
{
  double t;
} temps_;

#define temps_1 temps_

struct
{
  int nall1;
} comall_;

#define comall_1 comall_

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
static double c_b3 = 10.;
static double c_b9 = 1e-5;
static double c_b11 = 1e-7;
static int c__30 = 30;
static int c__31 = 31;
static int c__32 = 32;
static double c_b20 = .1;
static int c__33 = 33;
static int c__34 = 34;
static double c_b26 = 1e-6;
static int c__35 = 35;
static int c__36 = 36;
static int c__37 = 37;
static int c__38 = 38;
static int c__14 = 14;
static int c__17 = 17;
static int c__39 = 39;



int
nsp_ctrlpack_optml2 (ct_Feq feq, U_fp jacl2, int *neq, double *q, int *nch,
		     double *w, int *iw)
{
  /* System generated locals */
  int i__1, i__2;
  double d__1;

  /* Builtin functions */
  double pow_di (double *, int *), sqrt (double);

  /* Local variables */
  int itol, iopt, ntol, liww;
  double tout;
  int i__, j, nqbac;
  double x;
  int lfree, ilcom;
  int latol, itask;
  int ipass, lqdot, nbout;
  int lrtol, lwork;
  double t0, touti, dnorm0;
  int mf, ng;
  double ti;
  int nq, lw, lifree;
  double tt, xx[1];
  int nlsode, istate;
  double epstop;
  int job;
  int lqi, ltg, liw, lrw;
  double phi0;

  /*!but 
   *     Routine de recherche de minimum du probleme d'approximation L2 
   *      par lsoda ( Lsoda = routine de resolution d'equa diff ) 
   *!liste d'appel 
   *    subroutine optml2(feq,jacl2,neq,q,nch,w,iw) 
   * 
   *    external feq,jacl2 
   *    double precision q(*),w(*) 
   *    int nch,iw(*) 
   * 
   *    Entrees : 
   *    - feq est la subroutine qui calcule le gradient, 
   *       oppose de la derivee premiere de la fonction phi. 
   *    - neq. tableau entier de taille 3+(npara+1)*(npara+2) 
   *        neq(1)=nq est le degre effectif du polynome  q. 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de fourier dans 
   *              q est neq(3)+2 
   *    - neq est le degre du polynome q 
   *    - tq. tableau reel de taille au moins 
   *              6+dgmax+5*nq+6*ng+nq*ng+nq**2*(ng+1) 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        5+5*nq+5*ng+nq*ng+nq**2*(ng+1) 
   *    - nch est l indice (valant 1 ou 2) qui classifie l 
   *      appel comme etant soit celui de la recherche et de la 
   *      localisation d un minimum local, soit de la 
   *      confirmation d un minimum local. 
   * 
   *    Sorties : 
   *    - neq est toujours le degre du polynome q (il peut  avoir varie). 
   *    - q est le polynome (ou plutot le tableau contenant 
   *        ses coefficients) qui resulte de la recherche ,il peut 
   *        etre du meme degre que le polynome initial mais aussi 
   *        de degre inferieur dans le cas d'une sortie de face. 
   * 
   *    Tableau de travail 
   *    - w de taille 25+26*nq+ng+nq**2 
   *    - iw de taille 20+nq 
   *! 
   *    Copyright INRIA 
   * 
   * 
   */
  /* Parameter adjustments */
  --iw;
  --w;
  --q;
  --neq;

  /* Function Body */
  nq = neq[1];
  ng = neq[2];
  ltg = neq[3] + 1;
  /* 
   *    taille des tableaux de travail necessaires a lsode 
   *Computing 2nd power 
   */
  i__1 = nq;
  lrw = i__1 * i__1 + nq * 9 + 22;
  liw = nq + 20;
  /*    decoupage du tableau de travail w 
   */
  lqi = 1;
  lqdot = lqi + nq + 1;
  latol = lqdot + nq;
  lrtol = latol + nq;
  lwork = lrtol + nq;
  /*Computing 2nd power 
   */
  i__1 = nq;
  lfree = lwork + 24 + nq * 22 + ng + i__1 * i__1;
  /* 
   */
  lw = lwork + lrw;
  /*    decoupage du tableau de travail iw 
   */
  liww = 1;
  lifree = liww + liw;
  /* 
   */
  nqbac = nq;
  /* 
   *    --- Initialisation de lsode ------------------------ 
   * 
   */
  if (*nch == 1)
    {
      temps_1.t = 0.;
    }
  t0 = temps_1.t;
  tt = .1;
  tout = t0 + tt;
  itol = 4;
  /* 
   */
  if (nq < 7)
    {
      ntol = (nq - 1) / 3 + 5;
    }
  else
    {
      ntol = (nq - 7) / 2 + 7;
    }
  i__1 = -ntol;
  d__1 = pow_di (&c_b3, &i__1);
  nsp_dset (&nq, &d__1, &w[lrtol], &c__1);
  i__1 = -(ntol + 2);
  d__1 = pow_di (&c_b3, &i__1);
  nsp_dset (&nq, &d__1, &w[latol], &c__1);
  /* 
   */
  itask = 1;
  if (*nch == 1)
    {
      istate = 1;
    }
  if (*nch == 2)
    {
      istate = 3;
    }
  iopt = 0;
  mf = 21;
  /* 
   *    --- Initialisation du nombre maximal d'iteration --- 
   * 
   */
  if (*nch == 1)
    {
      if (nq <= 11)
	{
	  nlsode = ((nq - 1) << 1) + 11;
	}
      else
	{
	  nlsode = 29;
	}
    }
  else
    {
      nlsode = 19;
    }
  ilcom = 0;
  ipass = 0;
  /* 
   *    --- Appel  de lsode -------------------------------- 
   * 
   */
L210:
  i__1 = nlsode;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      /* 
       */
    L220:
      ++ilcom;
      /* 
       *    -- Reinitialisation de la Tolerance -- 
       * 
       */
      if (ilcom == 2 && *nch == 1)
	{
	  nsp_dset (&nq, &c_b9, &w[lrtol], &c__1);
	  nsp_dset (&nq, &c_b11, &w[latol], &c__1);
	  istate = 3;
	}
      else if (ilcom == 2 && *nch == 2)
	{
	  w[lrtol] = 1e-8;
	  w[latol] = 1e-10;
	  w[lrtol + 1] = 1e-7;
	  w[latol + 1] = 1e-9;
	  w[lrtol + nq - 1] = 1e-5;
	  w[latol + nq - 1] = 1e-7;
	  i__2 = nq - 2;
	  for (j = 2; j <= i__2; ++j)
	    {
	      w[lrtol + j] = 1e-6;
	      w[latol + j] = 1e-8;
	      /* L240: */
	    }
	  istate = 3;
	}
      /* 
       *    -------------------------------------- 
       * 
       */
      i__2 = nq + 1;
      C2F (dcopy) (&i__2, &q[1], &c__1, &w[lqi], &c__1);
      ti = temps_1.t;
      touti = tout;
      /* 
       */
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__30, &nq, &nq, &q[1], xx, &temps_1.t, &tout);
	}
      /* 
       */
      nsp_ctrlpack_lsode ((S_fp) feq, &neq[1], &q[1], &temps_1.t, &tout,
			  &itol, &w[lrtol], &w[latol], &itask, &istate, &iopt,
			  &w[lwork], &lrw, &iw[liww], &liw, (U_fp) jacl2,
			  &mf);
      /* 
       */
      nsp_ctrlpack_front (&nq, &q[1], &nbout, &w[lw]);
      /* 
       */
      (*feq) (&neq[1], &temps_1.t, &q[1], &w[lqdot]);
      dnorm0 = C2F (dnrm2) (&nq, &w[lqdot], &c__1);
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__31, &nq, &nbout, &q[1], &dnorm0, &temps_1.t,
			      &tout);
	}
      /* 
       *    -- test pour degre1 ----------- 
       */
      if (comall_1.nall1 > 0 && nq == 1 && nbout > 0)
	{
	  return 0;
	}
      /* 
       * 
       *    -- Istate de lsode ------------ 
       * 
       */
      if (istate == -5)
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__32, &nq, &nq, xx, xx, &x, &x);
	    }
	  C2F (dscal) (&nq, &c_b20, &w[lrtol], &c__1);
	  C2F (dscal) (&nq, &c_b20, &w[latol], &c__1);
	  if (temps_1.t == 0.)
	    {
	      istate = 1;
	    }
	  if (temps_1.t != 0.)
	    {
	      istate = 3;
	    }
	  ilcom = 0;
	  goto L220;
	}
      /* 
       */
      if (istate == -6)
	{
	  /*    echec de l'integration appel avec de nouvelles tolerances 
	   */
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__33, &nq, &nq, xx, xx, &x, &x);
	    }
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_outl2 (&c__34, &nq, &itol, &w[latol], &w[lrtol],
				  &temps_1.t, &tout);
	    }
	  iopt = 0;
	  itol = 4;
	  nsp_dset (&nq, &c_b26, &w[lrtol], &c__1);
	  nsp_dset (&nq, &c_b26, &w[latol], &c__1);
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_outl2 (&c__35, &nq, &itol, &w[latol], &w[lrtol],
				  &x, &x);
	    }
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__36, &nq, &nq, xx, xx, &x, &x);
	    }
	  istate = 3;
	  if (temps_1.t != tout)
	    {
	      goto L220;
	    }
	}
      /* 
       */
      if (istate < -1 && istate != -6 && istate != -5)
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__37, &nq, &iopt, xx, xx, &x, &x);
	    }
	  *nch = 15;
	  return 0;
	}
      /* 
       *    ------------------------------- 
       * 
       *    -- Sortie de face ------------- 
       * 
       */
      if (nbout > 0 && nbout != 99)
	{
	  nsp_ctrlpack_domout (&neq[1], &q[1], &w[lqi], &nbout, &ti,
			       &temps_1.t, &itol, &w[lrtol], &w[latol],
			       &itask, &istate, &iopt, &w[lwork], &lrw,
			       &iw[liww], &liw, (U_fp) jacl2, &mf, &job);
	  nq = neq[1];
	  if (job == -1)
	    {
	      /*    anomalie dans la recherche de l'intersection 
	       */
	      *nch = 16;
	      return 0;
	    }
	  if (job == 1)
	    {
	      *nch = nq - nqbac;
	      return 0;
	    }
	}
      /* 
       *    ------------------------------- 
       * 
       *    -- test sur le gradient ------- 
       * 
       */
      epstop = pow_di (&c_b26, nch);
      (*feq) (&neq[1], &temps_1.t, &q[1], &w[lqdot]);
      dnorm0 = C2F (dnrm2) (&nq, &w[lqdot], &c__1);
      if (dnorm0 < epstop)
	{
	  goto L299;
	}
      /* 
       *    ------------------------------- 
       * 
       *    -- Istate de lsode (suite) ---- 
       * 
       */
      if (istate == -1 && temps_1.t != tout)
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__38, &nq, &nq, xx, xx, &x, &x);
	    }
	  istate = 2;
	  goto L220;
	}
      /* 
       *    ------------------------------- 
       * 
       */
      tt = sqrt (10.) * tt;
      tout = t0 + tt;
      /* 
       */
      /* L290: */
    }
  /* 
   */
  if (*nch == 2 && dnorm0 > 1e-6)
    {
      ++ipass;
      if (ipass < 5)
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_lq (&nq, &q[1], &w[lw], &q[ltg], &ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (&nq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&c__14, &nq, &nq, &q[1], &w[lw], &x, &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&q[1], &nq, &q[ltg], &ng, &w[lw]),
		      Abs (d__1));
	      (*feq) (&neq[1], &temps_1.t, &q[1], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, &nq, &nq, &q[1], &w[lqdot], &phi0,
				  &x);
	    }
	  goto L210;
	}
      else
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__39, &nq, &nq, xx, xx, &x, &x);
	    }
	  *nch = 17;
	  return 0;
	}
    }
  /* 
   */
L299:
  return 0;
  /* 
   */
}				/* optml2_ */
