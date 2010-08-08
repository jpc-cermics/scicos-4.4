# include "blocks.h"

void shift_32_RA (scicos_block * block, int flag)
{
  SCSINT32_COP *u, *y;
  int *ipar;
  int mu, nu, i;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = Getint32InPortPtrs (block, 1);
  y = Getint32OutPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  for (i = 0; i < mu * nu; i++)
    y[i] = u[i] >> -ipar[0];
}
