/* jacl2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_jacl2 (int *neq, double *t, double *tq, int *ml, int *mu,
		    double *pd, int *nrowpd)
{
  /* System generated locals */
  int pd_dim1, pd_offset;

  /* Local variables */
  int nq;

  /*!but 
   *    jacl2 cree la matrice  jacobienne necessaire a Lsoda, 
   *    qui correspond en fait a la hessienne du probleme 
   *    d'approximation L2. 
   *!liste d'appel 
   *    entree : 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome q 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de 
   *              fourier dans tq est neq(3)+2 
   *        neq(4:(nq+1)*(nq+2)) tableau de travail entier 
   *    - t est une variable parametrique necessaire a Lsoda. 
   *    - tq. tableau reel de taille au moins 
   *              7+dgmax+5*nq+6*ng+nq*ng+nq**2*(ng+1) 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        5+5*nq+5*ng+nq*ng+nq**2*(ng+1) 
   *    - ml et mu sont les parametres du stockage par bande 
   *       de la matrice qui n a pas lieu ici ,ils donc ignores. 
   * 
   *    sortie : 
   *    - pd. est le tableau ou l on range la matrice pleine 
   *      dont les elements sont etablis par la sub. Hessien 
   *    - nrowpd. est le nombre de ligne du tableau pd 
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
  nsp_ctrlpack_hessl2 (&neq[1], &tq[1], &pd[pd_offset], nrowpd);
  nq = neq[1];
  /*     write(6,'(''jac='')') 
   *     do 10 i=1,nq 
   *        write(6,'(5(e10.3,2x))') (pd(i,j),j=1,nq) 
   *10   continue 
   * 
   */
  return 0;
}				/* jacl2_ */

int
nsp_ctrlpack_jacl2n (int *neq, double *t, double *tq, int *ml, int *mu,
		     double *pd, int *nrowpd)
{
  /* System generated locals */
  int pd_dim1, pd_offset, i__1, i__2;

  /* Local variables */
  int i__, j;
  int nq;

  /*!but 
   *    jacl2 cree la matrice  jacobienne necessaire a Lsoda, 
   *    qui correspond en fait a la hessienne du probleme 
   *    d'approximation L2. 
   *!liste d'appel 
   *    entree : 
   *    - neq. tableau entier de taille 3+(nq+1)*(nq+2) 
   *        neq(1)=nq est le degre effectif du polynome q 
   *        neq(2)=ng est le nombre de coefficient de fourier 
   *        neq(3)=dgmax degre maximum pour q (l'adresse des coeff de 
   *              fourier dans tq est neq(3)+2 
   *        neq(4:(nq+1)*(nq+2)) tableau de travail entier 
   *    - t est une variable parametrique necessaire a Lsoda. 
   *    - tq. tableau reel de taille au moins 
   *              7+dgmax+5*nq+6*ng+nq*ng+nq**2*(ng+1) 
   *        tq(1:nq+1) est le tableau des coefficients du polynome q. 
   *        tq(dgmax+2:dgmax+ng+2) est le tableau des coefficients 
   *                     de fourier 
   *        tq(dgmax+ng+3:) est un tableau de travail de taille au moins 
   *                        5+5*nq+5*ng+nq*ng+nq**2*(ng+1) 
   *    - ml et mu sont les parametres du stockage par bande 
   *       de la matrice qui n a pas lieu ici ,ils donc ignores. 
   * 
   *    sortie : 
   *    - pd. est le tableau ou l on range la matrice pleine 
   *      dont les elements sont etablis par la sub. Hessien 
   *    - nrowpd. est le nombre de ligne du tableau pd 
   *! 
   * 
   */
  /* Parameter adjustments */
  --neq;
  --tq;
  pd_dim1 = *nrowpd;
  pd_offset = pd_dim1 + 1;
  pd -= pd_offset;

  /* Function Body */
  nsp_ctrlpack_hessl2 (&neq[1], &tq[1], &pd[pd_offset], nrowpd);
  nq = neq[1];
  i__1 = nq;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = nq;
      for (j = 1; j <= i__2; ++j)
	{
	  pd[i__ + j * pd_dim1] = -pd[i__ + j * pd_dim1];
	  /* L10: */
	}
      /* L20: */
    }
  /*     write(6,'(''jac='')') 
   *     do 10 i=1,nq 
   *        write(6,'(5(e10.3,2x))') (pd(i,j),j=1,nq) 
   *10   continue 
   * 
   */
  return 0;
}				/* jacl2n_ */
