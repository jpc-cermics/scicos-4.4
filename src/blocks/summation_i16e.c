#include "blocks.h"

void summation_i16e (scicos_block * block, int flag)
{
  if ((flag == 1) | (flag == 6))
    {
      int j, k;
      int nu, mu, nin;
      SCSINT16_COP *y;
      int *ipar;
      double v, l;
      /*double *rpar;*/
      SCSINT16_COP *u;

      y = Getint16OutPortPtrs (block, 1);
      nu = GetInPortRows (block, 1);
      mu = GetInPortCols (block, 1);
      ipar = GetIparPtrs (block);
      /*rpar = GetRparPtrs (block);*/
      nin = GetNin (block);
      l = pow (2, 16) / 2;
      if (nin == 1)
	{
	  v = 0;
	  u = Getint16InPortPtrs (block, 1);
	  for (j = 0; j < nu * mu; j++)
	    {
	      v = v + (double) u[j];
	    }
	  if ((v >= l) | (v < -l))
	    {
	      sciprint ("overflow error");
	      set_block_error (-4);
	      return;
	    }
	  else
	    {
	      y[0] = (SCSINT16_COP) v;
	    }
	  if (ipar[0] < 0) y[0]= -y[0];
	}
      else
	{
	  for (j = 0; j < nu * mu; j++)
	    {
	      v = 0;
	      for (k = 0; k < nin; k++)
		{
		  u = Getint16InPortPtrs (block, k + 1);
		  if (ipar[k] > 0)
		    {
		      v = v + (double) u[j];
		    }
		  else
		    {
		      v = v - (double) u[j];
		    }
		}
	      if ((v >= l) | (v < -l))
		{
		  sciprint ("overflow error");
		  set_block_error (-4);
		  return;
		}
	      else
		y[j] = (SCSINT16_COP) v;
	    }
	}
    }
}
