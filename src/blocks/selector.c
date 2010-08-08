/* Copyright INRIA */

#include "blocks.h"

void scicos_selector_block (scicos_args_F2);

void
selector (flag, nevprt, t, xd, x, nx, z, nz, tvec, ntvec, rpar, nrpar,
	  ipar, nipar, inptr, insz, nin, outptr, outsz, nout)
  int *flag, *nevprt, *nx, *nz, *ntvec, *nrpar, ipar[], *nipar, insz[],
  *nin, outsz[], *nout;
double x[], xd[], z[], tvec[], rpar[];
double *inptr[], *outptr[], *t;

{
  int k;
  double *y;
  double *u;
  int nev, ic;

  ic = (int) z[0];
  if ((*flag) < 3)
    {
      ic = -1;
      nev = *nevprt;
      while (nev >= 1)
	{
	  ic = ic + 1;
	  nev = nev / 2;
	}
    }
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
