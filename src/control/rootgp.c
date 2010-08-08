/* rootgp.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Common Block Declarations */

struct
{
  int info, i1;
} arl2c_;

#define arl2c_1 arl2c_

/* Table of constant values */

static int c_n1 = -1;
static int c__1 = 1;

int
nsp_ctrlpack_rootgp (int *ngp, double *gpp, int *nbeta, double *beta,
		     int *ierr, double *w)
{
  /* System generated locals */
  int i__1;
  double d__1;

  /* Local variables */
  int fail;
  int kpol, j, kfree;
  int kzi, kzr;

  /* 
   * 
   *    Entree : - gpp. est le tableau contenant les coeff du polynome 
   *             gpp(z) et dont le degre est ngp. 
   *             - ngp. est le degre de gp(z). 
   *             - w tableau de travail de taille 3*ngp+1 
   *    Sortie : - beta. est le tableau contenant les racines du 
   *             polynome gpp(z) reelles comprises entre -2 et 2. 
   *             - nbeta. est le nombre de ces racines. 
   * 
   *! 
   * 
   *    decoupage du tableau de travail 
   * 
   */
  /* Parameter adjustments */
  --gpp;
  --beta;
  --w;

  /* Function Body */
  kpol = 1;
  kzr = kpol + *ngp + 1;
  kzi = kzr + *ngp;
  kfree = kzi + *ngp;
  /* 
   */
  i__1 = *ngp + 1;
  C2F (dcopy) (&i__1, &gpp[1], &c_n1, &w[kpol], &c__1);
  nsp_ctrlpack_rpoly (&w[kpol], ngp, &w[kzr], &w[kzi], &fail);
  *nbeta = 0;
  i__1 = *ngp - 1;
  for (j = 0; j <= i__1; ++j)
    {
      if (w[kzi + j] == 0. && (d__1 = w[kzr + j], Abs (d__1)) <= 2.)
	{
	  ++(*nbeta);
	  beta[*nbeta] = w[kzr + j];
	}
      /* L110: */
    }
  if (*nbeta == 0)
    {
      /*        if(info.ge.2) then 
       *        print*,' Problem : Cannot find a possible value for Beta' 
       *        print*,' Stopping execution immediately' 
       *        endif 
       */
      *ierr = 4;
      return 0;
    }
  return 0;
}				/* rootgp_ */
