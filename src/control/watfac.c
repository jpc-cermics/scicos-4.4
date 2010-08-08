/* watfac.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Table of constant values */

static int c__1 = 1;
static int c_n1 = -1;

int
nsp_ctrlpack_watfac (int *nq, double *tq, int *nface, int *newrap, double *w)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int fail;
  int indi, lpol, nmod1, j, lfree;
  int lzmod;
  int lzi, lzr;

  /*!but 
   *    Cette procedure est charge de determiner quelle est 
   *    la face franchie par la trajectoire du gradient. 
   *!liste d'appel 
   *    subroutine watfac(nq,tq,nface,newrap,w) 
   *    dimension tq(0:nq),w(3*nq+1) 
   * 
   *    Entrees : 
   *    - nq. est toujours le degre du polynome q(z) 
   *    - tq. est le tableau des coefficients de ce polynome. 
   * 
   *    Sortie  : 
   *    - nface contient l indice de la face que le chemin 
   *      de la recherche a traverse. 
   *      Les valeurs possibles de nface sont: 0 pour la face 
   *      complexe, 1 pour la face 'z+1' et -1 pour la face  'z-1'. 
   *    - newrap est un parametre indiquant s'il est necessaire 
   *      ou pas d'effectuer un nouveau un rapprochement. 
   * 
   *    Tableaux de travail 
   *    - w : 3*nq+1 
   *! 
   *    Copyright INRIA 
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
  nmod1 = 0;
  i__1 = *nq;
  for (j = 1; j <= i__1; ++j)
    {
      if (w[lzmod - 1 + j] >= 1.)
	{
	  ++nmod1;
	  if (nmod1 == 1)
	    {
	      indi = j;
	    }
	}
      /* L110: */
    }
  /* 
   */
  if (nmod1 == 2)
    {
      if (w[lzi - 1 + indi] == 0.)
	{
	  *newrap = 1;
	  return 0;
	}
      else
	{
	  *nface = 0;
	}
    }
  /* 
   */
  if (nmod1 == 1)
    {
      if (w[lzr - 1 + indi] > 0.)
	{
	  *nface = -1;
	}
      else
	{
	  *nface = 1;
	}
    }
  /* 
   */
  *newrap = 0;
  /* 
   */
  return 0;
}				/* watfac_ */
