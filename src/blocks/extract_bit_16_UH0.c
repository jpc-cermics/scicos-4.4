#include "blocks.h"

void extract_bit_16_UH0 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSINT16_COP *y, *u, ref, n;
  y = Getint16OutPortPtrs (block, 1);
  u = Getint16InPortPtrs (block, 1);
  maxim = 16;
  ref = 0;
  for (i = 0; i < maxim / 2; i++)
    {
      n = (SCSINT16_COP) pow (2, maxim / 2 + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
}
