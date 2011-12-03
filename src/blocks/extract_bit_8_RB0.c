#include "blocks.h"

void extract_bit_8_RB0 (scicos_block * block, int flag)
{
  int i, numb;
  /*int maxim*/
  char *y, *u, ref, n;
  int *ipar;
  y = Getint8OutPortPtrs (block, 1);
  u = Getint8InPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  /*maxim = 8;*/
  ref = 0;
  numb = *(ipar + 1) - *ipar + 1;
  for (i = 0; i < numb; i++)
    {
      n = (char) pow (2, *ipar + i);
      ref = ref + n;
    }
  *y = (*u) & (ref);
}
