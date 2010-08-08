#include "blocks.h"

void root_coef (scicos_block * block, int flag)
{
  double *u;
  double *y;
  int mu;
  mu = GetInPortRows (block, 1);
  u = GetRealInPortPtrs (block, 1);
  y = GetRealOutPortPtrs (block, 1);
  if (flag == 1 || flag == 6)
    nsp_calpack_dprxc (&mu, u, y);
}
