/* storl2.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "ctrlpack.h"

/* Common Block Declarations */

struct
{
  int io, info, ll;
} sortie_;

#define sortie_1 sortie_

/* Table of constant values */

static int c__80 = 80;
static int c__0 = 0;
static int c__81 = 81;

int
nsp_ctrlpack_storl2 (int *neq, double *tq, double *tg, int *ng, int *imin,
		     double *tabc, int *iback, int *ntback, double *tback,
		     int *nch, int *mxsol, double *w, int *ierr)
{
  /* System generated locals */
  int tabc_dim1, tback_dim1, i__1, i__2;
  double d__1;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  int jinf;
  double paux;
  int jsup;
  double diff0;
  int j, i__;
  double x;
  int ij, im, in;
  double xx[1];

  /*!but 
   *    Lorsque un minimum local vient d'etre determine, cette 
   *    procedure est appelee afin de verifier son originalite, 
   *    et si elle est effective, de le stocker dans le tableau 
   *    en construction, correspondant au degre de la recherche 
   *    en cours. S'il n'est pas de ce degre, il est alors range 
   *    dans le tableau 'tback' qui contient tout minimum origi- 
   *    nal obtenu apres une sortie de face. 
   *!liste d'appel 
   *    entrees : 
   *    - neq. est le degre du minimum nouvellement obtenu. 
   *    - tq. est le tableau contenant ses coefficients 
   *    - imin. est le nombre des minimums de meme degre, 
   *       deja reveles. 
   *    - tabc. etant le tableau contenant ces minimums. 
   *    - iback. est le nombre de minimums de degre 
   *       quelconque, reveles apres une sortie de face. 
   *    - ntback. est un tableau entier unicolonne contenant 
   *       les degres de ces polynomes. 
   *    - tback. est le tableau ou sont stockes ces polynomes. 
   *       Ainsi, le ieme polynome, de degre ntback(i), a 
   *       ses coeff dans la ieme ligne, c-a-d de tback(i,0) 
   *       a tback(i,ntback(i)-1). 
   *    - nch. est un parametre entier indiquant s'il s'agit 
   *       d'un minimum de meme degre que celui de la recherche 
   *       en cours, ou bien d'une sortie de face. 
   * 
   *    sorties : 
   *    - peuvent etre modifies: imin, tabc, iback, ntback, 
   *       tback, suivant le tableau ou a ete stocke le minimum tq 
   * 
   *    Copyright INRIA 
   * 
   *! 
   * 
   * 
   */
  /* Parameter adjustments */
  --tg;
  --ntback;
  tback_dim1 = *mxsol;
  --tback;
  tabc_dim1 = *mxsol;
  --tabc;
  --w;

  /* Function Body */
  *ierr = 0;
  if (*nch < -2)
    {
      goto L200;
    }
  if (*imin == 0)
    {
      goto L400;
    }
  /* 
   *    ---- test sur l'originalite du nouveau min ----------------------- 
   * 
   *    ---- par rapport a tabc. 
   * 
   */
  i__1 = *imin;
  for (im = 1; im <= i__1; ++im)
    {
      /* 
       */
      diff0 = 0.;
      i__2 = *neq - 1;
      for (ij = 0; ij <= i__2; ++ij)
	{
	  /*Computing 2nd power 
	   */
	  d__1 = tq[ij] - tabc[im + ij * tabc_dim1];
	  diff0 += d__1 * d__1;
	  /* L110: */
	}
      diff0 = sqrt (diff0);
      /* 
       */
      if (diff0 < .001)
	{
	  if (sortie_1.info > 0)
	    {
	      nsp_ctrlpack_outl2 (&c__80, &c__0, &c__0, xx, xx, &x, &x);
	    }
	  return 0;
	}
      /* 
       */
      /* L120: */
    }
  /* 
   *    ---- par rapport a tback. 
   * 
   *    - Situation des polynomes de meme degre. - 
   * 
   */
L200:
  if (*nch < 0 && *iback > 0)
    {
      jsup = *iback + 1;
      jinf = 0;
      /* 
       */
      for (j = *iback; j >= 1; --j)
	{
	  if (jsup > j && ntback[j] > *neq)
	    {
	      jsup = j;
	    }
	  /* L210: */
	}
      i__1 = *iback;
      for (j = 1; j <= i__1; ++j)
	{
	  if (jinf < j && ntback[j] < *neq)
	    {
	      jinf = j;
	    }
	  /* L220: */
	}
      /* 
       *    - Controle de l'originalite. - 
       * 
       */
      if (jsup - jinf > 1)
	{
	  /* 
	   */
	  i__1 = jsup - 1;
	  for (j = jinf + 1; j <= i__1; ++j)
	    {
	      /* 
	       */
	      diff0 = 0.;
	      i__2 = *neq - 1;
	      for (i__ = 0; i__ <= i__2; ++i__)
		{
		  /*Computing 2nd power 
		   */
		  d__1 = tq[i__] - tback[j + i__ * tback_dim1];
		  diff0 += d__1 * d__1;
		  /* L230: */
		}
	      diff0 = sqrt (diff0);
	      /* 
	       */
	      if (diff0 < .001)
		{
		  if (sortie_1.info > 0)
		    {
		      nsp_ctrlpack_outl2 (&c__80, &c__0, &c__0, xx, xx, &x,
					  &x);
		    }
		  return 0;
		}
	      /* 
	       */
	      /* L240: */
	    }
	}
    }
  /* 
   *    -------- classement du nouveau minimum ----- 
   *    ---- dans tback. 
   * 
   */
  if (*iback == *mxsol)
    {
      *ierr = 7;
      return 0;
    }
  if (*nch < 0)
    {
      /* 
       */
      if (*iback == 0)
	{
	  /* 
	   */
	  i__1 = *neq - 1;
	  for (i__ = 0; i__ <= i__1; ++i__)
	    {
	      tback[i__ * tback_dim1 + 1] = tq[i__];
	      /* L310: */
	    }
	  ntback[1] = *neq;
	  /* 
	   */
	}
      else if (jsup > *iback)
	{
	  /* 
	   */
	  i__1 = *neq - 1;
	  for (i__ = 0; i__ <= i__1; ++i__)
	    {
	      tback[jsup + i__ * tback_dim1] = tq[i__];
	      /* L330: */
	    }
	  ntback[*iback + 1] = *neq;
	  /* 
	   */
	}
      else
	{
	  /* 
	   */
	  i__1 = jsup;
	  for (j = *iback; j >= i__1; --j)
	    {
	      i__2 = ntback[j] - 1;
	      for (i__ = 0; i__ <= i__2; ++i__)
		{
		  tback[j + 1 + i__ * tback_dim1] =
		    tback[j + i__ * tback_dim1];
		  /* L340: */
		}
	      ntback[j + 1] = ntback[j];
	      /* L350: */
	    }
	  /* 
	   */
	  i__1 = *neq - 1;
	  for (i__ = 0; i__ <= i__1; ++i__)
	    {
	      tback[jsup + i__ * tback_dim1] = tq[i__];
	      /* L370: */
	    }
	  ntback[jsup] = *neq;
	  /* 
	   */
	}
      /* 
       */
      ++(*iback);
      if (sortie_1.info > 1)
	{
	  nsp_ctrlpack_outl2 (&c__81, neq, neq, xx, xx, &x, &x);
	}
      return 0;
      /* 
       */
    }
  /* 
   *    -------- dans tabc. 
   */
L400:
  if (*imin == *mxsol)
    {
      *ierr = 7;
      return 0;
    }
  paux = nsp_ctrlpack_phi (tq, neq, &tg[1], ng, &w[1]);
  /* 
   */
  if (*imin == 0)
    {
      /* 
       */
      i__1 = *neq - 1;
      for (ij = 0; ij <= i__1; ++ij)
	{
	  tabc[ij * tabc_dim1 + 1] = tq[ij];
	  /* L410: */
	}
      tabc[*neq * tabc_dim1 + 1] = paux;
      ++(*imin);
      /* 
       */
    }
  else
    {
      /* 
       */
      for (im = *imin; im >= 1; --im)
	{
	  /* 
	   */
	  if (paux > tabc[im + *neq * tabc_dim1] && im == *imin)
	    {
	      /* 
	       */
	      i__1 = *neq - 1;
	      for (ij = 0; ij <= i__1; ++ij)
		{
		  tabc[*imin + 1 + ij * tabc_dim1] = tq[ij];
		  /* L420: */
		}
	      tabc[*imin + 1 + *neq * tabc_dim1] = paux;
	      ++(*imin);
	      return 0;
	      /* 
	       */
	    }
	  else if (paux > tabc[im + *neq * tabc_dim1])
	    {
	      /* 
	       */
	      i__1 = im + 1;
	      for (in = *imin; in >= i__1; --in)
		{
		  i__2 = *neq;
		  for (ij = 0; ij <= i__2; ++ij)
		    {
		      tabc[in + 1 + ij * tabc_dim1] =
			tabc[in + ij * tabc_dim1];
		      /* L430: */
		    }
		  /* L440: */
		}
	      i__1 = *neq - 1;
	      for (ij = 0; ij <= i__1; ++ij)
		{
		  tabc[im + 1 + ij * tabc_dim1] = tq[ij];
		  /* L450: */
		}
	      tabc[im + 1 + *neq * tabc_dim1] = paux;
	      ++(*imin);
	      return 0;
	      /* 
	       */
	    }
	  else if (im == 1)
	    {
	      /* 
	       */
	      for (in = *imin; in >= 1; --in)
		{
		  i__1 = *neq;
		  for (ij = 0; ij <= i__1; ++ij)
		    {
		      tabc[in + 1 + ij * tabc_dim1] =
			tabc[in + ij * tabc_dim1];
		      /* L460: */
		    }
		  /* L470: */
		}
	      i__1 = *neq - 1;
	      for (ij = 0; ij <= i__1; ++ij)
		{
		  tabc[ij * tabc_dim1 + 1] = tq[ij];
		  /* L480: */
		}
	      tabc[*neq * tabc_dim1 + 1] = paux;
	      ++(*imin);
	      /* 
	       */
	    }
	  /* 
	   */
	  /* L490: */
	}
      /* 
       */
    }
  /* 
   */
  return 0;
}				/* storl2_ */
