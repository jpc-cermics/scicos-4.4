#include "blocks.h"

void exttril (scicos_block * block, int flag)
{
  double *u;
  double *y;
  int nu, mu, i, j, ij;

  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = GetRealInPortPtrs (block, 1);
  y = GetRealOutPortPtrs (block, 1);
  for (i = 0; i < mu * nu; i++)
    *(y + i) = 0;
  for (j = 0; j < nu; j++)
    {
      for (i = j; i < mu; i++)
	{
	  ij = i + j * mu;
	  *(y + ij) = *(u + ij);
	}
    }
}
