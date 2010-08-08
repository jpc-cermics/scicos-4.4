#include "blocks.h"


void extract_bit_16_MSB1 (scicos_block * block, int flag)
{
  int i, maxim;
  SCSINT16_COP *y, *u, ref, n;
  int *ipar;
  y = Getint16OutPortPtrs (block, 1);
  u = Getint16InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  maxim = 16;
  ref = 0;
  for (i = 0; i < *ipar; i++)
    {
      n = (SCSINT16_COP) pow (2, maxim - 1 - i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> (maxim - *ipar);
}
