/* onface.f -- translated by f2c (version 19961017).
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

static double c_b2 = 0.;
static int c__1 = 1;
static int c__70 = 70;
static int c__71 = 71;
static int c__2 = 2;
static int c_n1 = -1;

int
nsp_ctrlpack_onface (int *nq, double *tq, double *tg, int *ng, int *nprox,
		     int *ierr, double *w)
{
  /* System generated locals */
  int i__1, i__2, i__3;
  double d__1;

  /* Builtin functions */
  int pow_ii (int *, int *);
  double pow_di (double *, int *);

  /* Local variables */
  double srgd;
  int ndiv;
  double beta0;
  int lrgd0, lrgd1;
  double auxt1, taux2[3], auxt2;
  int i__, j, k;
  double t;
  int lbeta;
  double x;
  int nbeta, lfree;
  int lqdot;
  int nqdot, nqvra, lqaux;
  double t0, tmult, tabeta[3];
  int lw;
  double xx[1];
  int lgp, ngp;
  double srq, tps[2];
  int lgp1, lrq0, lrq1;

  /*!but 
   *    il est question ici de calculer (ou d estimer) 
   *    le polynome (ou point) qui se situe a l'intersection 
   *    de la recherche et de la face-frontiere du domaine. 
   *!liste d'appel 
   *    subroutine onface(nq,tq,nprox) 
   * 
   *    double precision tq(0:nq),w(*) 
   *    int nq,nprox,ierr 
   * 
   *    Entree : 
   *    - nq. est le degre du polynome q(z) avant toute 
   *       modification. 
   *    - tq. est le tableau de ses coefficients 
   *    - nprox. est l indice de la face par laquelle on estime 
   *       que la recherche a franchi la frontiere du domaine. 
   * 
   *    Sortie : 
   *    -nq. est alors le degre des polynomes de la face 
   *      traversee et donc du polynome intersection. Sa valeur 
   *      est inferieur de 1 ou 2 a sa valeur precedente. 
   *    - tq. contient en sortie les coefficients du polynome 
   *      intersection dans le domaine de la face traversee. 
   * 
   *    Tableau de travail 
   *    - w : 12*nq+ng+1 
   *! 
   *    Copyright INRIA 
   * 
   * 
   *    decoupage du tableau de travail 
   */
  /* Parameter adjustments */
  --tg;
  --w;

  /* Function Body */
  lqaux = 1;
  lqdot = lqaux;
  lrq0 = lqdot + *nq + 1;
  lrq1 = lrq0 + *nq;
  lrgd0 = lrq1 + *nq;
  lrgd1 = lrgd0 + *nq;
  lgp = lrgd1 + *nq;
  lgp1 = lgp + (*nq << 1) - 2;
  lbeta = lgp1;
  lw = lbeta + (*nq << 1) - 2;
  lfree = lw + *nq * 3 + *ng + 1;
  /* 
   */
  nqvra = *nq;
  /* 
   */
  tps[1] = 1.;
  tps[0] = 1.;
  /* 
   */
  if (*nprox != 0)
    {
      tps[0] = (double) (*nprox);
      /*    calcul du reste de la division de q par tps 
       */
      d__1 = -tps[0];
      nsp_ctrlpack_horner (tq, nq, &d__1, &c_b2, &srq, xx);
      /*    calcul du reste de la division de qdot  par 1+z 
       */
      nsp_ctrlpack_feq1 (nq, &t, tq, &tg[1], ng, &w[lqdot], &w[lw]);
      d__1 = -tps[0];
      nsp_ctrlpack_horner (&w[lqdot], nq, &d__1, &c_b2, &srgd, xx);
      /* 
       */
      d__1 = -srq / srgd;
      C2F (daxpy) (nq, &d__1, &w[lqdot], &c__1, tq, &c__1);
      /* 
       */
      nsp_ctrlpack_dpodiv (tq, tps, nq, &c__1);
      if (sortie_1.info > 0)
	{
	  nsp_ctrlpack_outl2 (&c__70, &c__1, &c__1, xx, xx, &x, &x);
	}
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__71, &c__1, &c__1, tq, xx, &x, &x);
	}
      C2F (dcopy) (nq, &tq[1], &c__1, tq, &c__1);
      --(*nq);
      /* 
       */
    }
  else if (*nprox == 0)
    {
      /* 
       */
      taux2[2] = 1.;
      taux2[1] = 0.;
      taux2[0] = 1.;
      /* 
       */
      i__1 = *nq + 1;
      C2F (dcopy) (&i__1, tq, &c__1, &w[lqaux], &c__1);
      i__1 = *nq - 2;
      for (ndiv = 0; ndiv <= i__1; ++ndiv)
	{
	  i__2 = *nq - ndiv;
	  nsp_ctrlpack_dpodiv (&w[lqaux], taux2, &i__2, &c__2);
	  w[lrq1 + ndiv] = w[lqaux + 1];
	  w[lrq0 + ndiv] = w[lqaux];
	  /* 
	   */
	  i__2 = *nq - ndiv;
	  for (j = 2; j <= i__2; ++j)
	    {
	      w[lqaux + j - 1] = w[lqaux + j];
	      /* L180: */
	    }
	  w[lqaux] = 0.;
	  /* L200: */
	}
      w[lrq1 - 1 + *nq] = w[lqaux + 1];
      w[lrq0 - 1 + *nq] = w[lqaux];
      /* 
       */
      nsp_ctrlpack_feq1 (nq, &t, tq, &tg[1], ng, &w[lqaux], &w[lw]);
      nqdot = *nq - 1;
      /* 
       */
      i__1 = nqdot - 2;
      for (ndiv = 0; ndiv <= i__1; ++ndiv)
	{
	  i__2 = nqdot - ndiv;
	  nsp_ctrlpack_dpodiv (&w[lqaux], taux2, &i__2, &c__2);
	  w[lrgd1 + ndiv] = w[lqaux + 1];
	  w[lrgd0 + ndiv] = w[lqaux];
	  /* 
	   */
	  i__2 = nqdot - ndiv;
	  for (j = 2; j <= i__2; ++j)
	    {
	      w[lqaux + j - 1] = w[lqaux + j];
	      /* L220: */
	    }
	  w[lqaux] = 0.;
	  /* L240: */
	}
      w[lrgd1 - 1 + nqdot] = w[lqaux + 1];
      w[lrgd0 - 1 + nqdot] = w[lqaux];
      /* 
       *    - construction du polynome gp(z) dont on cherchera une racine 
       *    comprise entre -2 et +2 ----------------------------- 
       * 
       */
      i__1 = (*nq << 1) - 2;
      nsp_dset (&i__1, &c_b2, &w[lgp], &c__1);
      i__1 = (*nq << 1) - 2;
      nsp_dset (&i__1, &c_b2, &w[lgp1], &c__1);
      /* 
       */
      i__1 = *nq;
      for (j = 1; j <= i__1; ++j)
	{
	  i__2 = nqdot;
	  for (i__ = 1; i__ <= i__2; ++i__)
	    {
	      k = i__ + j - 2;
	      w[lgp + k] +=
		pow_ii (&c_n1, &k) * w[lrq0 - 1 + j] * w[lrgd1 - 1 + i__];
	      w[lgp1 + k] +=
		pow_ii (&c_n1, &k) * w[lrq1 - 1 + j] * w[lrgd0 - 1 + i__];
	      /* L258: */
	    }
	  /* L260: */
	}
      /* 
       */
      i__1 = (*nq << 1) - 2;
      nsp_calpack_ddif (&i__1, &w[lgp1], &c__1, &w[lgp], &c__1);
      ngp = (*nq << 1) - 3;
      nsp_ctrlpack_rootgp (&ngp, &w[lgp], &nbeta, &w[lbeta], ierr, &w[lw]);
      if (*ierr != 0)
	{
	  return 0;
	}
      /* 
       */
      i__1 = nbeta;
      for (k = 1; k <= i__1; ++k)
	{
	  /* 
	   *    - calcul de t (coeff multiplicateur) - 
	   * 
	   */
	  auxt1 = 0.;
	  i__2 = *nq;
	  for (i__ = 1; i__ <= i__2; ++i__)
	    {
	      d__1 = -w[lbeta - 1 + k];
	      i__3 = i__ - 1;
	      auxt1 += w[lrq1 - 1 + i__] * pow_di (&d__1, &i__3);
	      /* L280: */
	    }
	  /* 
	   */
	  auxt2 = 0.;
	  i__2 = nqdot;
	  for (i__ = 1; i__ <= i__2; ++i__)
	    {
	      d__1 = -w[lbeta - 1 + k];
	      i__3 = i__ - 1;
	      auxt2 += w[lrgd1 - 1 + i__] * pow_di (&d__1, &i__3);
	      /* L290: */
	    }
	  /* 
	   */
	  tmult = -auxt1 / auxt2;
	  /* 
	   */
	  if (k == 1)
	    {
	      t0 = tmult;
	      beta0 = w[lbeta];
	    }
	  else if (Abs (tmult) < Abs (t0))
	    {
	      t0 = tmult;
	      beta0 = w[lbeta - 1 + k];
	    }
	  /* 
	   */
	  /* L299: */
	}
      /* 
       */
      nsp_ctrlpack_feq1 (nq, &t, tq, &tg[1], ng, &w[lqdot], &w[lw]);
      C2F (daxpy) (nq, &t0, &w[lqdot], &c__1, tq, &c__1);
      /* 
       */
      tabeta[2] = 1.;
      tabeta[1] = beta0;
      tabeta[0] = 1.;
      nsp_ctrlpack_dpodiv (tq, tabeta, nq, &c__2);
      if (sortie_1.info > 0)
	{
	  nsp_ctrlpack_outl2 (&c__70, &c__2, &c__2, xx, xx, &x, &x);
	}
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__71, &c__2, &c__2, tq, xx, &x, &x);
	}
      /* 
       */
      i__1 = *nq - 1;
      C2F (dcopy) (&i__1, &tq[2], &c__1, tq, &c__1);
      *nq += -2;
      /* 
       */
    }
  /* 
   */
  return 0;
}				/* onface_ */
