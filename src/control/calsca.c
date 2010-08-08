/* calsca.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

int
nsp_ctrlpack_calsca (int *ns, double *ts, double *tr, double *y0, double *tg,
		     int *ng)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, k;
  double x[41];
  int nu;
  double aux;

  /*!but 
   *    Calcule le produit scalaire entre une fonction de Hardi donnee 
   *    par ses coefficients de fourrier et une fonction rationnelle r/s 
   *!liste d'appel 
   *    subroutine calsca(ns,ts,tr,y0) 
   *    Entrees : 
   *    ng. est le plus grand indice (compte negativement) des 
   *        coefficients de fourrier de la fonction de Hardi u 
   *    tg. vecteur des coefficients de fourrier 
   *    ns. est le degre du denominateur (polynome monique) 
   *    ts. est le tableau des coefficients du denominateur 
   *    tr. est le tableau des coefficients du numerateur dont 
   *        le degre est inferieur a ns 
   * 
   *    sortie  : y0. contient la valeur du produit scalaire recherche. 
   *! 
   *    Copyright INRIA 
   * 
   */
  nu = *ng + 1;
  i__1 = *ns - 1;
  for (i__ = 0; i__ <= i__1; ++i__)
    {
      x[i__] = 0.;
      /* L20: */
    }
  aux = x[*ns - 1];
  for (k = nu; k >= 1; --k)
    {
      for (i__ = *ns - 1; i__ >= 1; --i__)
	{
	  x[i__] = x[i__ - 1] - ts[i__] * aux + tr[i__] * tg[k - 1];
	  /* L29: */
	}
      x[0] = -ts[0] * aux + tr[0] * tg[k - 1];
      aux = x[*ns - 1];
      /* L30: */
    }
  *y0 = x[*ns - 1];
  return 0;
}				/* calsca_ */
