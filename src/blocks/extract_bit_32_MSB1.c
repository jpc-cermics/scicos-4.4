#include "blocks.h"

void extract_bit_32_MSB1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSINT32_COP *y, *u, ref, n;
  int *ipar;
  y = Getint32OutPortPtrs (block, 1);
  u = Getint32InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  maxim = 32;
  ref = 0;
  for (i = 0; i < *ipar; i++)
    {
      n = (SCSINT32_COP) pow (2, maxim - 1 - i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> (maxim - *ipar);
}
