/* degl2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Common Block Declarations */

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
static int c__51 = 51;
static int c__17 = 17;
static int c__50 = 50;
static int c__53 = 53;

int
nsp_ctrlpack_degl2 (double *tg, int *ng, int *neq, int *imina, int *iminb,
		    int *iminc, double *ta, double *tb, double *tc,
		    int *iback, int *ntback, double *tback, int *mxsol,
		    double *w, int *iw, int *ierr)
{
  /* System generated locals */
  int ta_dim1, ta_offset, tb_dim1, tb_offset, tc_dim1, tc_offset, tback_dim1,
    tback_offset, i__1, i__2;
  double d__1;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int lneq;
  int j, k;
  double t;
  double x;
  int lfree;
  int lqdot, imult, lwopt;
  int neqbac;
  int lw, lifree;
  double xx[1];
  int liwopt, nch;
  int ltg, liw, ltq, ltr;
  double tms[2];
  int lrw;
  double tps[2], phi0;

  /*!but 
   *    Cette procedure a pour objectif de determiner le plus grand 
   *    nombre de minimums de degre "neq". 
   *!liste d'appel 
   *    subroutine degre (neq,imina,iminb,iminc,ta,tb,tc, 
   *   &     iback,ntback,tback) 
   * 
   *    Entree : 
   *    -neq. est le degre des polynomes parmi lesquels ont 
   *      recherche les minimums. 
   *    -imina. est le nombre de minimums de degre "neq-1" 
   *      contenus dans ta. 
   *    -iminb. est le nombre de minimums de degre "neq-2" 
   *      contenus dans tb. 
   *    -iminc. est le nombre de minimums de degre "neq-3" 
   *      contenus dans tc. 
   *    -ta. est le tableau contenant donc les minimums de degre 
   *      "neq-1" 
   *    -tb. est le tableau contenant donc les minimums de degre 
   *      "neq-2" 
   *    -tc. est le tableau contenant donc les minimums de degre 
   *      "neq-3" 
   *    -iback. est le nombre de minimums obtenus apres une 
   *      intersection avec la frontiere 
   *    -ntback est un tableau d'entier qui contient les degre 
   *      de ces minimums 
   *    -tback. est le tableau qui contient leurs coefficients, 
   *      ou ils sont ordonnes degre par degre. 
   * 
   *    Sortie : 
   *    -imina. est le nombre de minimums de degre neq que l'on 
   *      vient de determiner 
   *    -iminb. est le nombre de minimums de degre "neq-1" 
   *    -iminc. est le nombre de minimums de degre "neq-2" 
   *    -ta. contient les mins de degre neq, -tb. ceux de degre 
   *      neq-1 et tc ceux de degre neq-2 
   *    -iback,ntback,tback ont pu etre augmente des mins obtenus 
   *      apres intersection eventuelle avec la frontiere. 
   * 
   *    tableaux de travail 
   *     w : 33+33*neq+7*ng+neq*ng+neq**2*(ng+2) 
   *     iw :29+neq**2+4*neq 
   * 
   *    Copyright INRIA 
   *! 
   * 
   * 
   * 
   */
  /* Parameter adjustments */
  --tg;
  tback_dim1 = *mxsol;
  tback_offset = tback_dim1 + 1;
  tback -= tback_offset;
  --ntback;
  tc_dim1 = *mxsol;
  tc_offset = tc_dim1 + 1;
  tc -= tc_offset;
  tb_dim1 = *mxsol;
  tb_offset = tb_dim1 + 1;
  tb -= tb_offset;
  ta_dim1 = *mxsol;
  ta_offset = ta_dim1 + 1;
  ta -= ta_offset;
  --w;
  --iw;

  /* Function Body */
  tps[0] = 1.;
  tps[1] = 1.;
  tms[0] = -1.;
  tms[1] = 1.;
  /* 
   * 
   *    -------- Reinitialisation des tableaux -------- 
   * 
   */
  if (*neq == 1)
    {
      goto L111;
    }
  /* 
   */
  i__1 = *iminb;
  for (j = 1; j <= i__1; ++j)
    {
      C2F (dcopy) (neq, &tb[j + tb_dim1], mxsol, &tc[j + tc_dim1], mxsol);
      /* L110: */
    }
  *iminc = *iminb;
  /* 
   */
L111:
  i__1 = *imina;
  for (j = 1; j <= i__1; ++j)
    {
      C2F (dcopy) (neq, &ta[j + ta_dim1], mxsol, &tb[j + tb_dim1], mxsol);
      /* L120: */
    }
  *iminb = *imina;
  *imina = 0;
  ++(*neq);
  neqbac = *neq;
  /* 
   *Computing 2nd power 
   */
  i__1 = *neq;
  lrw = i__1 * i__1 + *neq * 9 + 22;
  liw = *neq + 20;
  /*    decoupage du tableau de travail w 
   */
  ltq = 1;
  /*Computing 2nd power 
   */
  i__1 = *neq;
  lwopt = ltq + 6 + *neq * 6 + *ng * 6 + *neq * *ng + i__1 * i__1 * (*ng + 1);
  /*Computing 2nd power 
   */
  i__1 = *neq;
  ltr = lwopt + 25 + *neq * 26 + *ng + i__1 * i__1;
  lfree = ltr + *neq + 1;
  /* 
   *    les lrw elements de w suivant w(lwopt) ne doivent pas etre modifies 
   *    d'un appel de optml2 a l'autre 
   */
  lw = lwopt + lrw;
  ltg = ltq + *neq + 1;
  i__1 = *ng + 1;
  C2F (dcopy) (&i__1, &tg[1], &c__1, &w[ltg], &c__1);
  /*    decoupage du tableau de travail iw 
   */
  lneq = 1;
  liwopt = lneq + 3 + (*neq + 1) * (*neq + 2);
  lifree = liwopt + 20 + *neq;
  /* 
   */
  iw[lneq] = *neq;
  iw[lneq + 1] = *ng;
  iw[lneq + 2] = *neq;
  if (sortie_1.info > 0)
    {
      nsp_ctrlpack_outl2 (&c__51, neq, neq, xx, xx, &x, &x);
    }
  /* 
   *    -------- Boucles de calculs -------- 
   * 
   */
  i__1 = *iminb;
  for (k = 1; k <= i__1; ++k)
    {
      /* 
       */
      i__2 = *neq - 1;
      C2F (dcopy) (&i__2, &tb[k + tb_dim1], mxsol, &w[ltr], &c__1);
      w[ltr + *neq - 1] = 1.;
      /* 
       */
      for (imult = 1; imult <= 2; ++imult)
	{
	  /* 
	   */
	  if (imult == 1)
	    {
	      i__2 = *neq - 1;
	      nsp_ctrlpack_dpmul1 (&w[ltr], &i__2, tps, &c__1, &w[ltq]);
	    }
	  else if (imult == 2)
	    {
	      i__2 = *neq - 1;
	      nsp_ctrlpack_dpmul1 (&w[ltr], &i__2, tms, &c__1, &w[ltq]);
	    }
	  /* 
	   */
	L140:
	  /* 
	   */
	  nch = 1;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  *neq = iw[lneq];
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_outl2 (&nch, &iw[lneq], &neqbac, &w[ltq], xx, &x,
				  &x);
	    }
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_lq (neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feq (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, neq, neq, &w[ltq], &w[lqdot], &phi0,
				  &x);
	    }
	  if (nch == 15 && comall_1.nall1 == 0)
	    {
	      *ierr = 4;
	      return 0;
	    }
	  /* 
	   */
	  if (nch == -1)
	    {
	      goto L140;
	    }
	  if (nch == -2)
	    {
	      goto L140;
	    }
	  /* 
	   */
	  nch = 2;
	  nsp_ctrlpack_optml2 (nsp_ctrlpack_feq, nsp_ctrlpack_jacl2,
			       &iw[lneq], &w[ltq], &nch, &w[lwopt],
			       &iw[liwopt]);
	  *neq = iw[lneq];
	  if (sortie_1.info > 1)
	    {
	      nsp_ctrlpack_lq (neq, &w[ltq], &w[lw], &w[ltg], ng);
	      x = sqrt (no2f_1.gnrm);
	      C2F (dscal) (neq, &x, &w[lw], &c__1);
	      nsp_ctrlpack_outl2 (&nch, neq, &neqbac, &w[ltq], &w[lw], &x,
				  &x);
	      phi0 = (d__1 =
		      nsp_ctrlpack_phi (&w[ltq], neq, &w[ltg], ng, &w[lw]),
		      Abs (d__1));
	      lqdot = lw;
	      nsp_ctrlpack_feq (&iw[lneq], &t, &w[ltq], &w[lqdot]);
	      nsp_ctrlpack_outl2 (&c__17, neq, neq, &w[ltq], &w[lqdot], &phi0,
				  &x);
	    }
	  if (nch == 15 && comall_1.nall1 == 0)
	    {
	      *ierr = 4;
	      return 0;
	    }
	  /* 
	   * 
	   */
	  if (nch == -1)
	    {
	      goto L140;
	    }
	  if (nch == -2)
	    {
	      goto L140;
	    }
	  /* 
	   */
	  if (nch == 15)
	    {
	      if (sortie_1.info > 0)
		{
		  nsp_ctrlpack_outl2 (&c__50, neq, neq, xx, xx, &x, &x);
		}
	      goto L170;
	    }
	  /* 
	   */
	  nch = *neq - neqbac;
	  if (nch == -2)
	    {
	      nsp_ctrlpack_storl2 (neq, &w[ltq], &w[ltg], ng, iminc,
				   &tc[tc_offset], iback, &ntback[1],
				   &tback[tback_offset], &nch, mxsol,
				   &w[lwopt], ierr);
	    }
	  else if (nch == -1)
	    {
	      nsp_ctrlpack_storl2 (neq, &w[ltq], &w[ltg], ng, iminb,
				   &tb[tb_offset], iback, &ntback[1],
				   &tback[tback_offset], &nch, mxsol,
				   &w[lwopt], ierr);
	    }
	  else
	    {
	      nsp_ctrlpack_storl2 (neq, &w[ltq], &w[ltg], ng, imina,
				   &ta[ta_offset], iback, &ntback[1],
				   &tback[tback_offset], &nch, mxsol,
				   &w[lwopt], ierr);
	    }
	  /* 
	   */
	L170:
	  *neq = neqbac;
	  iw[lneq] = *neq;
	  /* 
	   */
	  /* L180: */
	}
      /* L190: */
    }
  if (sortie_1.info > 0)
    {
      x = (double) (*mxsol);
      nsp_ctrlpack_outl2 (&c__53, neq, imina, &ta[ta_offset], xx, &x, &x);
    }
  return 0;
}				/* degl2_ */
