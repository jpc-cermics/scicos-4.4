#include "blocks.h"

void extract_bit_u8_UH1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSUINT8_COP *y, *u, ref, n;
  y = Getuint8OutPortPtrs (block, 1);
  u = Getuint8InPortPtrs (block, 1);
  maxim = 8;
  ref = 0;
  for (i = 0; i < maxim / 2; i++)
    {
      n = (SCSUINT8_COP) pow (2, maxim / 2 + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> maxim / 2;
}
