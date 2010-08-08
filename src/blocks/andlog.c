#include "blocks.h"

/* Logical and block
 * if event input exists synchronuously, output is 1 else -1
 */

void andlog (int *flag, int *nevprt, const double *t, double *xd, double *x,
	     int *nx, double *z, int *nz, double *tvec, int *ntvec,
	     double *rpar, int *nrpar, int *ipar, int *nipar, double *u,
	     int *nu, double *y, int *ny)
{
  if (*flag == 1)
    y[0] = (*nevprt != 3) ? -1.00 : 1.00;
}
