#include "blocks.h"

extern void scicos_writeau_block (scicos_args_F2);
void writeau (scicos_args_F2);

void writeau (int *flag, int *nevprt, const double *t, double *xd,
	      double *x, int *nx, double *z, int *nz, double *tvec,
	      int *ntvec, double *rpar, int *nrpar, int *ipar, int *nipar,
	      double **inptr, int *insz, int *nin, double **outptr,
	      int *outsz, int *nout)
{
  scicos_writeau_block (flag, nevprt, t, xd, x, nx, z, nz, tvec, ntvec, rpar,
			nrpar, ipar, nipar, inptr, insz, nin, outptr, outsz,
			nout);
}
