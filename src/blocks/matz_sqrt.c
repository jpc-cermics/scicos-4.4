#include "blocks.h"

void matz_sqrt (scicos_block * block, int flag)
{
  if (flag == 1)
    {
      double *ui, *ur;
      double *yi, *yr;
      int nu, mu, i;

      mu = GetInPortRows (block, 1);
      nu = GetInPortCols (block, 1);

      ur = GetRealInPortPtrs (block, 1);
      ui = GetImagInPortPtrs (block, 1);
      yr = GetRealOutPortPtrs (block, 1);
      yi = GetImagOutPortPtrs (block, 1);

      for (i = 0; i < mu * nu; i++)
	{
	  doubleC in = { ur[i], ui[i] }
	  , out;
	  nsp_sqrt_c (&in, &out);
	  yr[i] = out.r;
	  yi[i] = out.i;
	}
    }
}
