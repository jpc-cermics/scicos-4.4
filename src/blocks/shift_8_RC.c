# include "blocks.h"

void shift_8_RC (scicos_block * block, int flag)
{
  char *u, *y, v;
  int *ipar;
  int mu, nu, i, j;
  SCSUINT8_COP k;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = Getint8InPortPtrs (block, 1);
  y = Getint8OutPortPtrs (block, 1);
  ipar = GetIparPtrs (block);
  k = (SCSUINT8_COP) pow (2, 8 - 1);
  for (i = 0; i < mu * nu; i++)
    {
      v = u[i];
      for (j = 0; j < -ipar[0]; j++)
	{
	  y[i] = v & 1;
	  if (y[i] == 0)
	    {
	      y[i] = v >> 1;
	      y[i] = y[i] & (k - 1);
	    }
	  else
	    {
	      y[i] = v >> 1;
	      y[i] = (y[i]) | (k);
	    }
	  v = y[i];
	}
    }
}
