/* hessl2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Table of constant values */

static double c_b4 = 0.;
static int c__1 = 1;

int nsp_ctrlpack_hessl2 (int *neq, double *tq, double *pd, int *nrowpd)
{
  /* System generated locals */
  int pd_dim1, pd_offset, i__1;

  /* Local variables */
  int itij, jmxnv, jmxnw, id1aux, id2aux, ng, nq, iw, jw;
  int itg, itp, itq, itr, itv, itw;

  /*!but 
   *    Elle etablit la valeur de la Hessienne, derivee 
   *      seconde de la fonction phi au point q . 
   *!liste d'appel 
   *    subroutine hessl2(neq,tq,pd,nrowpd) 
   *    Entree : 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome tq (ou q). 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de fourier dans 
   *              tq est neq(3)+2 
   *        neq(4:(nq+1)*(nq+2)) tableau de travail entier 
   *    - tq. tableau reel de taille au moins 
   *              6+dgmax+5*nq+6*ng+nq*ng+nq**2*(ng+1) 
   *        tq(1:nq+1) est le tableau des coefficients du polynome. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        5+5*nq+5*ng+nq*ng+nq**2*(ng+1) 
   *    Sortie : 
   *    - pd matrice hessienne 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --neq;
  --tq;
  pd_dim1 = *nrowpd;
  pd_offset = pd_dim1 + 1;
  pd -= pd_offset;

  /* Function Body */
  nq = neq[1];
  ng = neq[2];
  /* 
   *    decoupage du tableau neq 
   */
  jmxnv = 4;
  jmxnw = jmxnv + (nq + 1);
  /*Computing 2nd power 
   */
  i__1 = nq + 1;
  jw = jmxnw + i__1 * i__1;
  /* 
   *    decoupage du tableau tq 
   */
  itq = 1;
  itg = itq + neq[3] + 1;
  itr = itg + ng + 1;
  itp = itr + nq + ng + 1;
  itv = itp + nq + ng + 1;
  itw = itv + nq + ng + 1;
  itij = itw + nq + ng + 1;
  id1aux = itij + ng + 1;
  id2aux = id1aux + (ng + 1) * nq;
  iw = id2aux + nq * nq * (ng + 1);
  nsp_ctrlpack_hl2 (&nq, &tq[1], &tq[itg], &ng, &pd[pd_offset], nrowpd,
		    &tq[itr], &tq[itp], &tq[itv], &tq[itw], &tq[itij],
		    &tq[id1aux], &tq[id2aux], &neq[jmxnv], &neq[jmxnw]);
  return 0;
}				/* hessl2_ */

int
nsp_ctrlpack_hl2 (int *nq, double *tq, double *tg, int *ng, double *pd,
		  int *nrowpd, double *tr, double *tp, double *tv, double *tw,
		  double *tij, double *d1aux, double *d2aux, int *maxnv,
		  int *maxnw)
{
  /* System generated locals */
  int pd_dim1, pd_offset, d1aux_dim1, d1aux_offset, d2aux_dim1, d2aux_dim2,
    d2aux_offset, maxnw_dim1, maxnw_offset, i__1, i__2, i__3;

  /* Local variables */
  int ltvq, i__, j, k, minij, maxij;
  double y1, y2;
  int ichoi1, ichoi2;
  int nw;
  int ichoix;
  int nv1, nv2;

  /*! 
   * 
   * 
   *    --- Calcul des derivees premieres de 'vq' --- 
   * 
   */
  /* Parameter adjustments */
  maxnw_dim1 = *nq;
  maxnw_offset = maxnw_dim1 + 1;
  maxnw -= maxnw_offset;
  --maxnv;
  --tq;
  d2aux_dim1 = *nq;
  d2aux_dim2 = *nq;
  d2aux_offset = d2aux_dim1 * (d2aux_dim2 + 1) + 1;
  d2aux -= d2aux_offset;
  d1aux_dim1 = *ng + 1;
  d1aux_offset = d1aux_dim1 + 1;
  d1aux -= d1aux_offset;
  --tij;
  --tw;
  --tv;
  --tp;
  --tr;
  --tg;
  pd_dim1 = *nrowpd;
  pd_offset = pd_dim1 + 1;
  pd -= pd_offset;

  /* Function Body */
  i__1 = *nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (i__ == 1)
	{
	  /*    .     division euclidienne de z^nq*g par q 
	   */
	  nsp_dset (nq, &c_b4, &tp[1], &c__1);
	  i__2 = *ng + 1;
	  C2F (dcopy) (&i__2, &tg[1], &c__1, &tp[*nq + 1], &c__1);
	  i__2 = *nq + *ng;
	  nsp_ctrlpack_dpodiv (&tp[1], &tq[1], &i__2, nq);
	  nv1 = *ng;
	  /*    .     calcul de Lq et Vq 
	   */
	  nsp_ctrlpack_lq (nq, &tq[1], &tr[1], &tg[1], ng);
	  ltvq = *nq + 1;
	  /*    .     division euclidienne de Vq par q 
	   */
	  i__2 = *ng + 1;
	  C2F (dcopy) (&i__2, &tr[ltvq], &c__1, &tv[1], &c__1);
	  nsp_dset (nq, &c_b4, &tv[*ng + 2], &c__1);
	  nsp_ctrlpack_dpodiv (&tv[1], &tq[1], ng, nq);
	  nv2 = *ng - *nq;
	}
      else
	{
	  ichoi1 = 1;
	  nsp_ctrlpack_dzdivq (&ichoi1, &nv1, &tp[1], nq, &tq[1]);
	  ichoi2 = 2;
	  nsp_ctrlpack_mzdivq (&ichoi2, &nv2, &tv[1], nq, &tq[1]);
	}
      maxnv[i__] = Max (nv1, nv2);
      i__2 = maxnv[i__] + 1;
      for (j = 1; j <= i__2; ++j)
	{
	  d1aux[j + i__ * d1aux_dim1] = tp[*nq + j] - tv[*nq + j];
	  /* L10: */
	}
      /* L20: */
    }
  /* 
   *    --- Calcul des derivees secondes de 'vq' --- 
   * 
   */
  i__1 = *nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = *ng + *nq + 1;
      nsp_dset (&i__2, &c_b4, &tw[1], &c__1);
      for (j = *nq; j >= 1; --j)
	{
	  if (j == *nq)
	    {
	      i__2 = maxnv[i__] + 1;
	      C2F (dcopy) (&i__2, &d1aux[i__ * d1aux_dim1 + 1], &c__1,
			   &tw[*nq], &c__1);
	      nw = maxnv[i__] + *nq - 1;
	      nsp_ctrlpack_dpodiv (&tw[1], &tq[1], &nw, nq);
	      nw -= *nq;
	    }
	  else
	    {
	      ichoix = 1;
	      nsp_ctrlpack_dzdivq (&ichoix, &nw, &tw[1], nq, &tq[1]);
	    }
	  i__2 = nw + 1;
	  for (k = 1; k <= i__2; ++k)
	    {
	      d2aux[i__ + (j + k * d2aux_dim2) * d2aux_dim1] = tw[*nq + k];
	      /* L30: */
	    }
	  maxnw[i__ + j * maxnw_dim1] = nw;
	  /* L40: */
	}
      /* L50: */
    }
  /* 
   *    --- Conclusion des calculs sur la hessienne --- 
   * 
   */
  i__1 = *nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = i__;
      for (j = 1; j <= i__2; ++j)
	{
	  nsp_ctrlpack_scapol (&maxnv[i__], &d1aux[i__ * d1aux_dim1 + 1],
			       &maxnv[j], &d1aux[j * d1aux_dim1 + 1], &y1);
	  /* 
	   */
	  if (maxnw[i__ + j * maxnw_dim1] > maxnw[j + i__ * maxnw_dim1])
	    {
	      maxij = maxnw[i__ + j * maxnw_dim1];
	      minij = maxnw[j + i__ * maxnw_dim1];
	      i__3 = maxij + 1;
	      for (k = minij + 2; k <= i__3; ++k)
		{
		  tij[k] = -d2aux[i__ + (j + k * d2aux_dim2) * d2aux_dim1];
		  /* L60: */
		}
	    }
	  else if (maxnw[i__ + j * maxnw_dim1] < maxnw[j + i__ * maxnw_dim1])
	    {
	      maxij = maxnw[j + i__ * maxnw_dim1];
	      minij = maxnw[i__ + j * maxnw_dim1];
	      i__3 = maxij + 1;
	      for (k = minij + 2; k <= i__3; ++k)
		{
		  tij[k] = -d2aux[j + (i__ + k * d2aux_dim2) * d2aux_dim1];
		  /* L70: */
		}
	    }
	  else
	    {
	      maxij = maxnw[i__ + j * maxnw_dim1];
	      minij = maxij;
	    }
	  /* 
	   */
	  i__3 = minij + 1;
	  for (k = 1; k <= i__3; ++k)
	    {
	      tij[k] =
		-d2aux[i__ + (j + k * d2aux_dim2) * d2aux_dim1] - d2aux[j +
									(i__ +
									 k *
									 d2aux_dim2)
									*
									d2aux_dim1];
	      /* L80: */
	    }
	  /* 
	   */
	  nsp_ctrlpack_scapol (&maxij, &tij[1], ng, &tr[ltvq], &y2);
	  if (i__ == j)
	    {
	      pd[i__ + i__ * pd_dim1] = (y1 + y2) * -2.;
	    }
	  else
	    {
	      pd[i__ + j * pd_dim1] = (y1 + y2) * -2.;
	      pd[j + i__ * pd_dim1] = (y1 + y2) * -2.;
	    }
	  /* L90: */
	}
      /* L100: */
    }
  return 0;
}				/* hl2_ */
