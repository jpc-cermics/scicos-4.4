#include "blocks.h"

void extract_bit_u16_MSB1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSUINT16_COP *y, *u, ref, n;
  int *ipar;
  y = Getuint16OutPortPtrs (block, 1);
  u = Getuint16InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  maxim = 16;
  ref = 0;
  for (i = 0; i < *ipar; i++)
    {
      n = (SCSUINT16_COP) pow (2, maxim - 1 - i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> (maxim - *ipar);
}
