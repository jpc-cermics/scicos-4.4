#include "blocks.h"

void extract_bit_u16_RB1 (scicos_block * block, int flag)
{
  int i, numb;
  /*int maxim;*/
  SCSUINT16_COP *y, *u, ref, n;
  int *ipar;
  y = Getuint16OutPortPtrs (block, 1);
  u = Getuint16InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  /*maxim = 16;*/
  ref = 0;
  numb = *(ipar + 1) - *ipar + 1;
  for (i = 0; i < numb; i++)
    {
      n = (SCSUINT16_COP) pow (2, *ipar + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
  *y = *y >> *ipar;
}
