#include "blocks.h"

void bit_clear_16 (scicos_block * block, int flag)
{
  int m, n, i;
  SCSINT16_COP *opar;
  SCSINT16_COP *u, *y;
  m = GetInPortRows (block, 1);
  n = GetOutPortCols (block, 1);
  opar = Getint16OparPtrs (block, 1);
  u = Getint16InPortPtrs (block, 1);
  y = Getint16OutPortPtrs (block, 1);
  for (i = 0; i < m * n; i++)
    y[i] = ((u[i]) & (*opar));
}
