/* deg1l2.f -- translated by f2c (version 19961017).
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

/* Table of constant values */

static int c__1 = 1;
static int c__51 = 51;
static int c__17 = 17;
static int c__52 = 52;

int
nsp_ctrlpack_deg1l2 (double *tg, int *ng, int *imin, double *ta, int *mxsol,
		     double *w, int *iw, int *ierr)
{
  /* System generated locals */
  int ta_dim1, ta_offset, i__1;
  double d__1;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int lneq, lntb;
  int iback;
  double t;
  double x;
  int lfree, dgmax, icomp;
  int lqdot, lwopt;
  int neqbac;
  int ltback, lw, lifree;
  double xx[1];
  int minmax, liwopt, nch;
  int neq, ltg, ltq, lrw;
  double phi0;

  /*!but 
   *    Determiner la totalite des polynome de degre 1. 
   *!liste d'appel 
   *    sorties : 
   *    -imin. est le nombre de minimums obtenus. 
   *    -ta. est le tableau dans lequel sont conserves les 
   *       minimums. 
   *    tableaux de travail (dgmax=1) 
   *    - w :32+32*dgmax+7*ng+dgmax*ng+dgmax**2*(ng+2)+2*mxsol 
   *    -iw : 29+dgmax**2+4*dgmax+ mxsol 
   *!remarque 
   *    on notera que le neq ieme coeff de chaque colonne 
   *    devant contenir le coeff du plus au degre qui est 
   *    toujours 1. contient en fait la valeur du critere 
   *    pour ce polynome. 
   *! 
   *    Copyright INRIA 
   * 
   * 
   * 
   */
  /* Parameter adjustments */
  --tg;
  ta_dim1 = *mxsol;
  ta_offset = ta_dim1 + 1;
  ta -= ta_offset;
  --w;
  --iw;

  /* Function Body */
  dgmax = 1;
  ltq = 1;
  /*Computing 2nd power 
   */
  i__1 = dgmax;
  lwopt =
    ltq + 6 + dgmax * 6 + *ng * 6 + dgmax * *ng + i__1 * i__1 * (*ng + 1);
  /*Computing 2nd power 
   */
  i__1 = dgmax;
  ltback = lwopt + 25 + dgmax * 26 + *ng + i__1 * i__1;
  lfree = ltback + (*mxsol << 1);
  /* 
   *    les lrw elements de w suivant w(lwopt) ne doivent pas etre modifies 
   *    d'un appel de optml2 a l'autre 
   *Computing 2nd power 
   */
  i__1 = dgmax;
  lrw = i__1 * i__1 + dgmax * 9 + 22;
  lw = lwopt + lrw;
  /* 
   */
  lneq = 1;
  liwopt = lneq + 3 + (dgmax + 1) * (dgmax + 2);
  lntb = liwopt + 20 + dgmax;
  lifree = lntb + *mxsol;
  /* 
   */
  minmax = -1;
  neq = 1;
  neqbac = 1;
  iback = 0;
  /* 
   */
  iw[lneq] = neq;
  iw[lneq + 1] = *ng;
  iw[lneq + 2] = dgmax;
  /* 
   */
  w[ltq] = .9999;
  w[ltq + 1] = 1.;
  ltg = ltq + 2;
  i__1 = *ng + 1;
  C2F (dcopy) (&i__1, &tg[1], &c__1, &w[ltg], &c__1);
  /* 
   */
  if (sortie_1.info > 0)
    {
      nsp_ctrlpack_outl2 (&c__51, &neq, &neq, xx, xx, &x, &x);
    }
  for (icomp = 1; icomp <= 50; ++icomp)
    {
      if (minmax == -1)
	{
	  nch = 1;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_lq (&neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (&neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, &neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], &neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feq (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, &neq, &neq, &w[ltq], &w[lqdot],
				  &phi0, &x);
	    }
	  nch = 2;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_lq (&neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (&neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, &neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], &neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feq (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, &neq, &neq, &w[ltq], &w[lqdot],
				  &phi0, &x);
	    }
	  minmax = 1;
	}
      else
	{
	  nch = 1;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feqn, nsp_ctrlpack_jacl2n,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_lq (&neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (&neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, &neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], &neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feqn (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, &neq, &neq, &w[ltq], &w[lqdot],
				  &phi0, &x);
	    }
	  nch = 2;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feqn, nsp_ctrlpack_jacl2n,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_lq (&neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (&neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, &neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], &neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feqn (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, &neq, &neq, &w[ltq], &w[lqdot],
				  &phi0, &x);
	    }
	  minmax = -1;
	}
      if ((d__1 = w[ltq], Abs (d__1)) > 1.)
	{
	  goto L140;
	}
      if (minmax == 1)
	{
	  if (icomp == 1)
	    {
	      *imin = 1;
	      ta[*imin + ta_dim1] = w[ltq];
	      ta[*imin + (ta_dim1 << 1)] =
		nsp_ctrlpack_phi (&w[ltq], &neq, &tg[1], ng, &w[lwopt]);
	    }
	  else
	    {
	      nsp_ctrlpack_storl2 (&neq, &w[ltq], &w[ltg], ng, imin,
				   &ta[ta_offset], &iback, &iw[lntb],
				   &w[ltback], &nch, mxsol, &w[lwopt], ierr);
	      if (*ierr > 0)
		{
		  return 0;
		}
	    }
	}
      w[ltq] += -1e-5;
      /* L120: */
    }
  /* 
   */
L140:
  if (sortie_1.info > 0)
    {
      x = (double) (*mxsol);
      nsp_ctrlpack_outl2 (&c__52, &neq, imin, &ta[ta_offset], xx, &x, &x);
    }
  /* 
   */
  return 0;
}				/* deg1l2_ */
