#include "blocks.h"

void extract_bit_u16_UH1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSUINT16_COP *y, *u, ref, n;
  y = Getuint16OutPortPtrs (block, 1);
  u = Getuint16InPortPtrs (block, 1);
  maxim = 16;
  ref = 0;
  for (i = 0; i < maxim / 2; i++)
    {
      n = (SCSUINT16_COP) pow (2, maxim / 2 + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> maxim / 2;
}
