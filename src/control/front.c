/* front.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Table of constant values */

static int c__1 = 1;
static int c_n1 = -1;

int nsp_ctrlpack_front (int *nq, double *tq, int *nbout, double *w)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int fail, nbon, lpol, i__, lfree;
  int lzmod;
  int lzi, lzr;

  /*!but 
   *    cette routine calcule le nombre de racines  du polynome q(z) qui 
   *    sont situees a l'exterieur du cercle unite . 
   *!liste d'appel 
   *    subroutine front(nq,tq,nbout,w) 
   *    dimension tq(0:*),w(*) 
   *    Entree : 
   *    - nq . est le degre du polynome q(z) 
   *    - tq   . le tableau du polynome en question 
   * 
   *    Sortie : 
   *    -nbout . est le nombre de racine a l'exterieur du  du cercle unite 
   *    tableau de travail 
   *    -w 3*nq+1 
   *! 
   *    Copyright INRIA 
   * 
   * 
   */
  /* Parameter adjustments */
  --tq;
  --w;

  /* Function Body */
  lpol = 1;
  lzr = lpol + *nq + 1;
  lzi = lzr + *nq;
  lzmod = lpol;
  lfree = lzi + *nq;
  /* 
   */
  i__1 = *nq + 1;
  C2F (dcopy) (&i__1, &tq[1], &c__1, &w[lpol], &c_n1);
  nsp_ctrlpack_rpoly (&w[lpol], nq, &w[lzr], &w[lzi], &fail);
  nsp_ctrlpack_modul (nq, &w[lzr], &w[lzi], &w[lzmod]);
  /* 
   */
  *nbout = 0;
  nbon = 0;
  i__1 = *nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (w[lzmod - 1 + i__] > 1.)
	{
	  ++(*nbout);
	}
      if (w[lzmod - 1 + i__] == 1.)
	{
	  ++nbon;
	}
      /* L110: */
    }
  /* 
   */
  return 0;
}				/* front_ */
