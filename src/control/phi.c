/* phi.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

double nsp_ctrlpack_phi (double *tq, int *nq, double *tg, int *ng, double *w)
{
  /* System generated locals */
  double ret_val;

  /* Local variables */
  int ltlq, lfree;
  double y0;
  int ltr;

  /*%but 
   *calcule la fonction phi 
   *%liste d'appel 
   *    Entree : 
   *       tg . tableau des coefficients de la fonction g . 
   *       ng . degre du polynome g 
   *       tq . tableau des coefficients du polynome q 
   *       nq . degre du polynome q 
   *       w  . tableau de travail de taille nq+ng+1 
   *    Sortie : 
   *       phi 
   *% 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --tq;
  --w;
  --tg;

  /* Function Body */
  ltr = 1;
  lfree = ltr + *nq + *ng + 1;
  nsp_ctrlpack_lq (nq, &tq[1], &w[ltr], &tg[1], ng);
  /* 
   */
  ltlq = ltr;
  nsp_ctrlpack_calsca (nq, &tq[1], &w[ltlq], &y0, &tg[1], ng);
  /* 
   */
  ret_val = 1. - y0;
  /* 
   */
  return ret_val;
}				/* phi_ */
