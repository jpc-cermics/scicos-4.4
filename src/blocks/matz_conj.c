#include "blocks.h"

void matz_conj (scicos_block * block, int flag)
{
  int i ;
  int mu = GetOutPortRows (block, 1);
  int nu = GetOutPortCols (block, 1);
  double *u1r = GetRealInPortPtrs (block, 1);
  double *u1i = GetImagInPortPtrs (block, 1);
  double *yr = GetRealOutPortPtrs (block, 1);
  double *yi = GetImagOutPortPtrs (block, 1);
  for (i = 0; i < mu * nu; i++)
    {
      *(yr + i) = *(u1r + i);
      *(yi + i) = -(*(u1i + i));
    }
}
