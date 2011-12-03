#include "blocks.h"

void extract_bit_32_RB0 (scicos_block * block, int flag)
{
  int i, numb;
  int maxim;
  SCSINT32_COP *y, *u, ref, n;
  int *ipar;
  y = Getint32OutPortPtrs (block, 1);
  u = Getint32InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  /*maxim = 32;*/
  ref = 0;
  numb = *(ipar + 1) - *ipar + 1;
  for (i = 0; i < numb; i++)
    {
      n = (SCSINT32_COP) pow (2, *ipar + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
}
