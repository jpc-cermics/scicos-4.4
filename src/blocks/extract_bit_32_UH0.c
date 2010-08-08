#include "blocks.h"

void extract_bit_32_UH0 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSINT32_COP *y, *u, ref, n;
  y = Getint32OutPortPtrs (block, 1);
  u = Getint32InPortPtrs (block, 1);
  maxim = 32;
  ref = 0;
  for (i = 0; i < maxim / 2; i++)
    {
      n = (SCSINT32_COP) pow (2, maxim / 2 + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
}
