/* lq.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"
#include "../calelm/calpack.h"

int nsp_ctrlpack_lq (int *nq, double *tq, double *tr, double *tg, int *ng)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  double temp;
  int j;

  /*!but 
   *    cette routine calcule a  partir de g(z) et q(z) le 
   *    polynome Lq(z) defini comme le reste , tilde , de la division 
   *    par q(z) du produit g(z) par le tilde de q(z) . 
   *!liste d'appel 
   *    Entree : 
   *       tg . tableau des coefficients de la fonction g . 
   *       ng . degre du polynome g 
   *       tq . tableau des coefficients du polynome q 
   *       nq . degre du polynome q 
   *    Sortie : 
   *       tr . tableau [tlq,tvq] 
   *            tlq =tr(1:nq) coefficients du polynome Lq 
   *            tvq =tr(nq+1:nq+ng+1) coefficients du quotient vq de la 
   *                   division par q du polynome gqti . 
   *! 
   *    Copyright INRIA 
   * 
   *    calcul de tg*tq~ 
   */
  /* Parameter adjustments */
  --tq;
  --tg;
  --tr;

  /* Function Body */
  nsp_ctrlpack_tild (nq, &tq[1], &tr[1]);
  nsp_ctrlpack_dpmul1 (&tg[1], ng, &tr[1], nq, &tr[1]);
  /* 
   *    division euclidienne de tg*tq~ par tq 
   */
  i__1 = *ng + *nq;
  nsp_ctrlpack_dpodiv (&tr[1], &tq[1], &i__1, nq);
  /* 
   *    calcul du tilde du reste  sur place 
   */
  i__1 = *nq / 2;
  for (j = 1; j <= i__1; ++j)
    {
      temp = tr[j];
      tr[j] = tr[*nq + 1 - j];
      tr[*nq + 1 - j] = temp;
      /* L10: */
    }
  /* 
   */
  return 0;
}				/* lq_ */
