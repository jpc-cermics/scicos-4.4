#include "blocks.h"

void extdiag (scicos_block * block, int flag)
{
  double *u1;
  double *y;
  int mu, nu, i, ii;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u1 = GetRealInPortPtrs (block, 1);
  y = GetRealOutPortPtrs (block, 1);
  for (i = 0; i < mu * nu; i++)
    *(y + i) = 0;
  for (i = 0; i < Min (mu, nu); i++)
    {
      ii = i + i * mu;
      *(y + ii) = *(u1 + ii);
    }
}
