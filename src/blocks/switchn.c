#include "blocks.h"

void
switchn (int *flag, int *nevprt, const double *t, double *xd,
	  double *x, int *nx, double *z, int *nz, double *tvec,
	  int *ntvec, double *rpar, int *nrpar, int *ipar,
	  int *nipar, double **inptr, int *insz, int *nin,
	  double **outptr, int *outsz, int *nout)
{

  int k;
  double *y;
  double *u;
  int /*nev, */ ic;
  ic = ipar[0];
  if (*nin > 1)
    {
      y = (double *) outptr[0];
      u = (double *) inptr[ic];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
  else
    {
      y = (double *) outptr[ic];
      u = (double *) inptr[0];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
}
