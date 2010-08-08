# include "blocks.h"

void shift_u8_RA (scicos_block * block, int flag)
{
  SCSUINT8_COP *u, *y;
  int *ipar;
  int mu, nu, i;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = Getuint8InPortPtrs (block, 1);
  y = Getuint8OutPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  for (i = 0; i < mu * nu; i++)
    y[i] = u[i] >> (-ipar[0]);
}
