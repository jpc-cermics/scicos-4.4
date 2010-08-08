# include "blocks.h"

void shift_8_RA (scicos_block * block, int flag)
{
  char *u, *y;
  int *ipar;
  int mu, nu, i;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = Getint8InPortPtrs (block, 1);
  y = Getint8OutPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  for (i = 0; i < mu * nu; i++)
    y[i] = u[i] >> (-ipar[0]);
}
