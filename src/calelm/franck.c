/* franck.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*/MEMBR ADD NAME=FRANCK,SSI=0 
 *    Copyright INRIA 
 */
int nsp_calpack_franck (double *a, int *na, int *n, int *job)
{
  /* System generated locals */
  int a_dim1, a_offset, i__1, i__2;

  /* Local variables */
  int klig, kcol, k, l;
  double x;
  int n1, ls, ksd;

  /*!but 
   *    cette subroutine genere la matrice de franck d'ordre n 
   *    definie par : a(i,j)=j si i.le.j , a(j,j-1)=j , a(i,j)=0 
   *    si i.gt.j+1 . ou son inverse 
   *!liste d'appel 
   *    subroutine franck(a,na,n,job) 
   * 
   *    double precision a(na,n) 
   *    int na,n,job 
   * 
   *    a :tableau contenant apres execution la matrice 
   *    na:nombre de ligne du tableau a 
   *    n : dimension de la matrice 
   *    job : entier caracterisant le resultat demande 
   *          job = 0 : matrice de franck 
   *          job = 1 : son inverse 
   *!sous programme appeles 
   *    dble real (fortran) 
   *! 
   *variables internes 
   * 
   */
  /* Parameter adjustments */
  a_dim1 = *na;
  a_offset = a_dim1 + 1;
  a -= a_offset;

  /* Function Body */
  if (*job == 1)
    {
      goto L50;
    }
  /* 
   */
  a[a_dim1 + 1] = (double) (*n);
  if (*n == 1)
    {
      return 0;
    }
  i__1 = *n;
  for (k = 2; k <= i__1; ++k)
    {
      x = (double) (*n + 1 - k);
      a[k + (k - 1) * a_dim1] = x;
      i__2 = k;
      for (l = 1; l <= i__2; ++l)
	{
	  a[l + k * a_dim1] = x;
	  /* L10: */
	}
      /* L20: */
    }
  if (*n == 2)
    {
      return 0;
    }
  i__1 = *n;
  for (l = 3; l <= i__1; ++l)
    {
      n1 = l - 2;
      i__2 = n1;
      for (k = 1; k <= i__2; ++k)
	{
	  a[l + k * a_dim1] = 0.;
	  /* L40: */
	}
    }
  return 0;
  /* 
   */
L50:
  if (*n == 1)
    {
      return 0;
    }
  n1 = *n - 1;
  i__2 = n1;
  for (k = 1; k <= i__2; ++k)
    {
      a[k + (k + 1) * a_dim1] = -1.;
      a[k + 1 + (k + 1) * a_dim1] = (double) (*n + 1 - k);
      /* L60: */
    }
  a[a_dim1 + 1] = 1.;
  i__2 = n1;
  for (ksd = 1; ksd <= i__2; ++ksd)
    {
      ls = *n - ksd;
      i__1 = ls;
      for (l = 1; l <= i__1; ++l)
	{
	  klig = *n + 1 - l;
	  kcol = klig - ksd;
	  a[klig + kcol * a_dim1] = -a[klig - 1 + kcol * a_dim1] * l;
	  /* L65: */
	}
      /* L66: */
    }
  /* 
   */
  if (*n < 3)
    {
      return 0;
    }
  i__2 = *n;
  for (kcol = 3; kcol <= i__2; ++kcol)
    {
      n1 = kcol - 2;
      i__1 = n1;
      for (klig = 1; klig <= i__1; ++klig)
	{
	  a[klig + kcol * a_dim1] = 0.;
	  /* L70: */
	}
    }
  return 0;
}				/* franck_ */
