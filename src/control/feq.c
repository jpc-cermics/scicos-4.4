/* feq.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"
#include "../calelm/calpack.h"

int nsp_ctrlpack_feq (int *neq, double *t, double *tq, double *tqdot)
{
  int ifree, ng, nq, iw, itg, itq;

  /*!but 
   *     Etablir la valeur de l'oppose du gradient au point q 
   *!liste d'appel 
   *    subroutine feq(neq,t,tq,tqdot) 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome tq (ou q). 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de fourier dans 
   *              tq est neq(3)+2 
   *    - t  . variable parametrique necessaire a l'execution de 
   *        la routine lsoda . 
   *    - tq. tableau reel de taille au moins 
   *              3+dgmax+nq+2*ng 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        nq+ng+1 
   *    Sortie : 
   *    - tqdot . tableau contenant les opposes des coordonnees du 
   *             gradient de la fonction PHI au point q 
   *!Remarque 
   *    la structure particuliere  pour neq et tq est liee au fait que feq peut 
   *    etre appele comme un external de lsode 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --tqdot;
  --tq;
  --neq;

  /* Function Body */
  nq = neq[1];
  ng = neq[2];
  /* 
   *    decoupage du tableau tq 
   */
  itq = 1;
  itg = itq + neq[3] + 1;
  iw = itg + ng + 1;
  ifree = iw + 1 + nq + ng;
  nsp_ctrlpack_feq1 (&nq, t, &tq[1], &tq[itg], &ng, &tqdot[1], &tq[iw]);
  return 0;
}				/* feq_ */

int nsp_ctrlpack_feqn (int *neq, double *t, double *tq, double *tqdot)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, ifree, ng, nq, iw, itg, itq;

  /*!but 
   *     Etablir la valeur  du gradient au point q 
   *!liste d'appel 
   *    subroutine feqn(neq,t,tq,tqdot) 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome tq (ou q). 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de fourier dans 
   *              tq est neq(3)+2 
   *    - t  . variable parametrique necessaire a l'execution de 
   *        la routine lsoda . 
   *    - tq. tableau reel de taille au moins 
   *              3+dgmax+nq+2*ng 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        nq+ng+1 
   *    Sortie : 
   *    - tqdot . tableau contenant les opposes des coordonnees du 
   *             gradient de la fonction PHI au point q 
   *!Remarque 
   *    la structure particuliere  pour neq et tq est liee au fait que feq peut 
   *    etre appele comme un external de lsode 
   *! 
   * 
   */
  /* Parameter adjustments */
  --tqdot;
  --tq;
  --neq;

  /* Function Body */
  nq = neq[1];
  ng = neq[2];
  /* 
   *    decoupage du tableau tq 
   */
  itq = 1;
  itg = itq + neq[3] + 1;
  iw = itg + ng + 1;
  ifree = iw + 1 + nq + ng;
  nsp_ctrlpack_feq1 (&nq, t, &tq[1], &tq[itg], &ng, &tqdot[1], &tq[iw]);
  i__1 = nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      tqdot[i__] = -tqdot[i__];
      /* L10: */
    }
  return 0;
}				/* feqn_ */

int
nsp_ctrlpack_feq1 (int *nq, double *t, double *tq, double *tg, int *ng,
		   double *tqdot, double *tr)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int ltlq, ltvq, i__;
  double y0;
  int nr, nv, ichoix;

  /* 
   */
  /* Parameter adjustments */
  --tqdot;
  --tq;
  --tg;
  --tr;

  /* Function Body */
  i__1 = *nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      /* 
       *    -- calcul du terme general -- 
       * 
       */
      if (i__ == 1)
	{
	  nsp_ctrlpack_lq (nq, &tq[1], &tr[1], &tg[1], ng);
	  /*    .     tlq =tr(1:nq); tvq =tr(nq+1:nq+ng+1) 
	   */
	  ltlq = 1;
	  ltvq = *nq + 1;
	  /* 
	   *    division de tvq par q 
	   */
	  nsp_ctrlpack_dpodiv (&tr[ltvq], &tq[1], ng, nq);
	  nv = *ng - *nq;
	}
      else
	{
	  ichoix = 1;
	  nsp_ctrlpack_mzdivq (&ichoix, &nv, &tr[ltvq], nq, &tq[1]);
	}
      /* 
       *    calcul de tvq~ sur place 
       */
      nr = *nq - 1;
      nsp_ctrlpack_tild (&nr, &tr[ltvq], &tr[1]);
      nsp_ctrlpack_calsca (nq, &tq[1], &tr[1], &y0, &tg[1], ng);
      /* 
       *    -- conclusion -- 
       * 
       */
      tqdot[i__] = y0 * -2.;
      /* 
       */
      /* L199: */
    }
  /*     write(6,'(''tqdot='',5(e10.3,2x))') (tqdot(i),i=1,nq) 
   * 
   */
  return 0;
}				/* feq1_ */
