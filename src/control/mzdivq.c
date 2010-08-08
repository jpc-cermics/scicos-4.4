/* mzdivq.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_mzdivq (int *ichoix, int *nv, double *tv, int *nq, double *tq)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  double raux;
  int i__;

  /*!but 
   *    cette routine calcule, lorsque l'on connait le quotient et le reste 
   *       de la division par q d'un polynome, le reste et le quotient de 
   *       la division par q de ce    polynome multiplie par z. 
   *!liste d'appel 
   * 
   *     subroutine mzdivq(ichoix,nv,tv,nq,tq) 
   * 
   *    entree : 
   *    - ichoix. le nouveau reste ne sequential calculant 
   *         qu'avec le reste precedent, ce qui n'est pas le cas du 
   *         quotient, la possibilite est donnee de ne calculer que 
   *         ce reste. ichoix=1 .Si l'on desire calculer aussi le 
   *         quotient, ichoix=2. 
   *    - nv. est le degre du quotient entrant tv. 
   *    - tv. est le tableau contenant les coeff. du quotient. 
   *    - tr. est le tableau contenant les coeff. du reste de 
   *          degre nq-1. 
   *    - nq. est le degre du polynome tq. 
   *    - tq. est le tableau contenant les coeff. du pol. tq. 
   * 
   *    sortie : 
   *    - nv. est le degre du nouveau quotient. 
   *    - tv. contient les coeff. du nouveau quotient. 
   *    - tr. ceux du nouveau reste de degre toujours nq-1. 
   *! 
   *    Copyright INRIA 
   * 
   */
  raux = tv[*nq - 1];
  /* 
   *    -- Calcul du nouveau reste ------------- 
   * 
   */
  for (i__ = *nq - 1; i__ >= 1; --i__)
    {
      tv[i__] = tv[i__ - 1] - tq[i__] * raux;
      /* L20: */
    }
  /* 
   */
  tv[0] = -tq[0] * raux;
  /* 
   */
  if (*ichoix == 1)
    {
      return 0;
    }
  /* 
   *    -- Calcul du nouveau quotient ---------- 
   * 
   */
  i__1 = *nq;
  for (i__ = *nq + *nv; i__ >= i__1; --i__)
    {
      tv[i__ + 1] = tv[i__];
      /* L30: */
    }
  /* 
   */
  tv[*nq] = raux;
  ++(*nv);
  /* 
   */
  return 0;
}				/* mzdivq_ */
