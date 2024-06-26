#include "blocks.h"

void extract_bit_u32_UH1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSUINT32_COP *y, *u, ref, n;
  y = Getuint32OutPortPtrs (block, 1);
  u = Getuint32InPortPtrs (block, 1);
  maxim = 32;
  ref = 0;
  for (i = 0; i < maxim / 2; i++)
    {
      n = (SCSUINT32_COP) pow (2, maxim / 2 + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> maxim / 2;
}
