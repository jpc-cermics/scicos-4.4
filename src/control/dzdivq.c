/* dzdivq.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_dzdivq (int *ichoix, int *nv, double *tv, int *nq, double *tq)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  double vaux;
  int i__;

  /*!but 
   *    calcule ici les quotient et reste de la division 
   *      par q d'un polynome p, a partir des quotient et reste 
   *      de la division par q du produit de ce polynome par z. 
   *!liste d'appel 
   *    subroutine dzdivq(ichoix,nv,tv,nq,tq) 
   *    Entree : 
   *    - ichoix. prend la valeur 1 si l'on ne desire que 
   *      calculer le nouveau quotient (puisqu'il ne se calcule 
   *      qu'a partir du precedent. 2 sinon. 
   *    - nv. est le degre du quotient entrant tv. 
   *    - tv. est le tableau contenant les coeff. du quotient. 
   *    - tr. est le tableau contenant les coeff. du reste de 
   *      degre nq-1. 
   *    - nq. est le degre du polynome tq. 
   *    - tq. est le tableau contenant les coeff. du pol. tq. 
   * 
   *    sortie : 
   *    - nv. est le degre du nouveau quotient. 
   *    - tv. contient les coeff. du nouveau quotient. 
   *    - tr. ceux du nouveau reste de degre toujours nq-1. 
   * 
   *    -------------------------- 
   *    Copyright INRIA 
   * 
   */
  vaux = tv[*nq];
  /* 
   *    -- Calcul du nouveau quotient --------- 
   * 
   */
  i__1 = *nq + *nv - 1;
  for (i__ = *nq; i__ <= i__1; ++i__)
    {
      tv[i__] = tv[i__ + 1];
      /* L20: */
    }
  /* 
   */
  tv[*nq + *nv] = 0.;
  --(*nv);
  /* 
   */
  if (*ichoix == 1)
    {
      return 0;
    }
  /* 
   *    -- calcul du nouveau reste ------------ 
   * 
   */
  i__1 = *nq - 2;
  for (i__ = 0; i__ <= i__1; ++i__)
    {
      tv[i__] = vaux * tq[i__ + 1] + tv[i__ + 1];
      /* L30: */
    }
  /* 
   */
  tv[*nq - 1] = vaux;
  /* 
   */
  return 0;
}				/* dzdivq_ */
