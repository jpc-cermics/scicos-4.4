#include "blocks.h"

void zcross2(scicos_args_F0);

void zcross2 (int *flag, int *nevprt, const double *t, double *xd,
	      double *x, int *nx, double *z, int *nz, double *tvec,
	      int *ntvec, double *rpar, int *nrpar, int *ipar,
	      int *nipar, double *u, int *nu, double *g, int *ng)
{

  int i, j;
  int surface_matched, exist_enabled_surface;

  exist_enabled_surface = 0;
  if ((*flag == 3) && (*nevprt < 0))
    {
      for (i = 0; i < *ntvec; i++)
	{
	  surface_matched = 1;
	  exist_enabled_surface = 0;

	  for (j = 0; j < *ng; j++)
	    {
	      if (rpar[(*ng + 1) * i + j] != 0)
		{
		  exist_enabled_surface = 1;
		  if ((rpar[(*ng + 1) * i + j] * g[j]) <= 0)
		    {
		      surface_matched = 0;
		    }
		}
	    }

	  if ((surface_matched == 1) && (exist_enabled_surface == 1))
	    tvec[i] = *t + rpar[(*ng + 1) * i + *ng];
	  else
	    tvec[i] = -1;

	}
    }
  else
    {
      if (*flag == 9)
	{
	  for (i = 0; i < *ng; i++)
	    g[i] = u[i];
	}
    }
}
