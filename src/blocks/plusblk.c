#include "blocks.h"

void toberemoved_plusblk (int *flag, int *nevprt, const double *t, double *xd,
	      double *x, int *nx, double *z, int *nz, double *tvec,
	      int *ntvec, double *rpar, int *nrpar, int *ipar,
	      int *nipar, double **inptr, int *insz, int *nin,
	      double **outptr, int *outsz, int *nout)
{
  int k, i, n= outsz[0];
  double *y= (double *) outptr[0], *u;
  /* insz[0]==insz[1] .. ==insz[*nin]== outsz[0] */
  for (i = 0; i < n; i++)
    {
      y[i] = 0.0;
      for (k = 0; k < *nin; k++)
	{
	  u = (double *) inptr[k];
	  y[i] = y[i] + u[i];
	}
    }
}
