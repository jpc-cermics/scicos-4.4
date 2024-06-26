#include "blocks.h"

void cumsumz_c (scicos_block * block, int flag)
{
  double *ur;
  double *ui;
  double *yr;
  double *yi;
  int nu, mu, i, j, ij;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  yr = GetRealOutPortPtrs (block, 1);
  yi = GetImagOutPortPtrs (block, 1);

  for (i = 0; i < mu; i++)
    {
      yr[i] = ur[i];
      yi[i] = ui[i];
    }
  for (j = 1; j < nu; j++)
    {
      for (i = 0; i < mu; i++)
	{
	  ij = i + j * mu;
	  yr[ij] = ur[ij] + yr[ij - mu];
	  yi[ij] = ui[ij] + yi[ij - mu];
	}
    }
}
