# include "blocks.h"

void shift_u16_RA (scicos_block * block, int flag)
{
  SCSUINT16_COP *u, *y;
  int *ipar;
  int mu, nu, i;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = Getuint16InPortPtrs (block, 1);
  y = Getuint16OutPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  for (i = 0; i < mu * nu; i++)
    y[i] = u[i] >> -ipar[0];
}
