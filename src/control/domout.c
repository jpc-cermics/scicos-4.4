/* domout.f -- translated by f2c (version 19961017).
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

/* Table of constant values */

static int c__40 = 40;
static int c__1 = 1;
static int c__41 = 41;
static int c__42 = 42;
static int c__43 = 43;
static int c__44 = 44;
static int c__45 = 45;
static int c__46 = 46;
static int c__47 = 47;

int
nsp_ctrlpack_domout (int *neq, double *q, double *qi, int *nbout, double *ti,
		     double *touti, int *itol, double *rtol, double *atol,
		     int *itask, int *istate, int *iopt, double *w, int *lrw,
		     int *iw, int *liw, U_fp jacl2, int *mf, int *job)
{
  /* System generated locals */
  int i__1, i__2;

  /* Builtin functions */
  double log (double);

  /* Local variables */
  double free;
  int kmax, ierr;
  double tpas;
  int lqex;
  double tout, eps390;
  int k, nface;
  double t, x;
  double tsave;
  int nqmax;
  int nqsav, k0, ng;
  int lq, nq;
  double yf, yi;
  int lw;
  double xx[1];
  int nboute, newrap, lrwork;
  int ltg;

  /*    Copyright INRIA 
   *!but 
   *    Etant sortie du domaine d'integration au cours 
   *    de l'execution de la routine Optm2, il s'agit ici de 
   *    gerer ou d'effectuer l'ensemble des taches necessaires 
   *    a l'obtention du point de la face par lequel la 
   *    'recherche' est passee. 
   *!liste d'appel 
   *    subroutine domout(neq,q,qi,nbout,ti,touti,itol,rtol,atol,itask, 
   *   *     istate,iopt,w,lrw,iw,liw,jacl2,mf,job) 
   * 
   *    double precision  atol(neq(1)+1),rtol(neq(1)+1),q(neq(1)+1), 
   *   *                  qi(neq(1)+1) 
   *    double precision w(*),iw(*) 
   * 
   *    Entree : 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome q 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de 
   *              fourier dans tq est neq(3)+2 
   *        neq(4:(nq+1)*(nq+2)) tableau de travail entier 
   *    - tq. tableau reel de taille au moins 
   *              7+dgmax+5*nq+6*ng+nq*ng+nq**2*(ng+1) 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        5+5*nq+5*ng+nq*ng+nq**2*(ng+1) 
   * 
   *    - toutes les variables et tableaux de variables necessaires a 
   *              l'execution de la routine Lsode 
   *    - qi. est le dernier point obtenu de la trajectoire 
   *       qui soit a l'interieur du domaine. 
   *    - q(1:nq+1). est celui precedemment calcule, qui se situe a 
   *      l'exterieur. 
   * 
   *    Sortie : 
   *    - q(1:nq+1). est cense etre le point correspondant a l'inter- 
   *       section entre la face et la trajectoire. 
   *    - job. est un parametre indiquant si le franchissement 
   *           est verifie. 
   *           si job=-1 pb de detection arret requis 
   * 
   *    Tableaux de travail 
   *    - w : 24+22*nq+ng+nq**2 
   *    - iw : 20+nq 
   *! 
   * 
   */
  /* Parameter adjustments */
  --iw;
  --w;
  --atol;
  --rtol;
  --qi;
  --q;
  --neq;

  /* Function Body */
  nq = neq[1];
  ng = neq[2];
  nqmax = neq[3];
  /* 
   */
  lq = 1;
  ltg = lq + nqmax + 1;
  /* 
   *Computing 2nd power 
   */
  i__1 = nq;
  *lrw = i__1 * i__1 + nq * 9 + 22;
  *liw = nq + 20;
  /* 
   */
  lrwork = 1;
  /*Computing 2nd power 
   */
  i__1 = nq;
  lw = lrwork + i__1 * i__1 + nq * 9 + 22;
  lqex = lw + nq * 12 + ng + 1;
  free = (double) (lqex + nq + 1);
  /* 
   */
  tout = *touti;
  nboute = 0;
  /* 
   *    --- Etape d'approche de la frontiere ---------------------------- 
   * 
   */
  kmax = (int) (log ((tout - *ti) / .00625) / log (2.));
  k0 = 1;
  if (sortie_1.info > 1)
    {
      nsp_ctrlpack_outl2 (&c__40, &nq, &kmax, xx, xx, &x, &x);
    }
L314:
  i__1 = kmax;
  for (k = k0; k <= i__1; ++k)
    {
      tpas = (tout - *ti) / 2.;
      if (*nbout > 0)
	{
	  *istate = 1;
	  i__2 = nq + 1;
	  C2F (dcopy) (&i__2, &qi[1], &c__1, &q[1], &c__1);
	  t = *ti;
	  tout = *ti + tpas;
	}
      else
	{
	  i__2 = nq + 1;
	  C2F (dcopy) (&i__2, &q[1], &c__1, &qi[1], &c__1);
	  *ti = t;
	  tout = *ti + tpas;
	}
    L340:
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__41, &nq, &nq, &q[1], xx, &t, &tout);
	}
      tsave = t;
      nsp_ctrlpack_lsode (nsp_ctrlpack_feq, &neq[1], &q[1], &t, &tout, itol,
			  &rtol[1], &atol[1], itask, istate, iopt, &w[lrwork],
			  lrw, &iw[1], liw, (U_fp) jacl2, mf);
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__42, &nq, &nq, &q[1], xx, &t, &tout);
	}
      if (*istate == -1 && t != tout)
	{
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_outl2 (&c__43, &nq, &nq, xx, xx, &x, &x);
	    }
	  if (t <= tsave)
	    {
	      *job = -1;
	      return 0;
	    }
	  *istate = 2;
	  goto L340;
	}
      nsp_ctrlpack_front (&nq, &q[1], nbout, &w[lw]);
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__44, &nq, nbout, xx, xx, &x, &x);
	}
      if (*nbout > 0)
	{
	  nboute = *nbout;
	  i__2 = nq + 1;
	  C2F (dcopy) (&i__2, &q[1], &c__1, &w[lqex], &c__1);
	}
      if (*istate < 0)
	{
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_outl2 (&c__45, &nq, istate, xx, xx, &x, &x);
	    }
	  *job = -1;
	  return 0;
	}
      if (k == kmax && nboute == 0 && tout != *touti)
	{
	  tout = *touti;
	  goto L340;
	}
      /* L380: */
    }
  /* 
   */
  if (nboute == 0)
    {
      *job = 0;
      return 0;
    }
  else if (nboute > 2)
    {
      newrap = 1;
      nqsav = nq;
      goto L390;
    }
  /* 
   */
  nsp_ctrlpack_watfac (&nq, &w[lqex], &nface, &newrap, &w[lw]);
  if (newrap == 1)
    {
      goto L390;
    }
  /* 
   */
  nqsav = nq;
  nsp_ctrlpack_onface (&nq, &q[1], &q[ltg], &ng, &nface, &ierr, &w[lw]);
  if (ierr != 0)
    {
      *job = -1;
      return 0;
    }
  yi = nsp_ctrlpack_phi (&qi[1], &nqsav, &q[ltg], &ng, &w[lw]);
  yf = nsp_ctrlpack_phi (&q[1], &nq, &q[ltg], &ng, &w[lw]);
  /* 
   */
  eps390 = 1e-8;
  if (yi < yf - eps390)
    {
      newrap = 1;
      goto L390;
    }
  /* 
   */
  if (sortie_1.info > 1)
    {
      nsp_ctrlpack_outl2 (&c__46, &nq, &nface, &q[1], xx, &yi, &yf);
    }
  /* 
   */
  newrap = 0;
  /* 
   */
L390:
  if (newrap == 1)
    {
      nq = nqsav;
      k0 = kmax;
      ++kmax;
      *nbout = 1;
      if (*ti + tpas * 2 <= *ti)
	{
	  *job = -1;
	  return 0;
	}
      tout = *ti + tpas * 2;
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__47, &nq, &nq, xx, &qi[1], &x, &x);
	}
      goto L314;
    }
  /* 
   */
  neq[1] = nq;
  *job = 1;
  return 0;
  /* 
   */
}				/* domout_ */
