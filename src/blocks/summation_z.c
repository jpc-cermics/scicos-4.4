#include "blocks.h"

void summation_z (scicos_block * block, int flag)
{
  int j, k;
  double *ur;
  double *ui;
  int *ipar= GetIparPtrs (block);
  double *yr = GetRealOutPortPtrs (block, 1);
  double *yi = GetImagOutPortPtrs (block, 1);
  int mu = GetInPortRows (block, 1);
  int nu = GetInPortCols (block, 1);

  if (flag == 1)
    {
      if (GetNin (block) == 1)
	{
	  ur = GetRealInPortPtrs (block, 1);
	  ui = GetImagInPortPtrs (block, 1);
	  yr[0] = 0.0;
	  yi[0] = 0.0;
	  for (j = 0; j < mu * nu; j++)
	    {
	      yr[0] = yr[0] + ur[j];
	      yi[0] = yi[0] + ui[j];
	    }
	  if (ipar[0] < 0) {yr[0]= -yr[0];yi[0]= -yi[0];}
	}
      else
	{
	  for (j = 0; j < mu * nu; j++)
	    {
	      yr[j] = 0.0;
	      yi[j] = 0.0;
	      for (k = 1; k < GetNin (block) + 1; k++)
		{
		  ur = GetRealInPortPtrs (block, k);
		  ui = GetImagInPortPtrs (block, k);
		  if (ipar[k - 1] > 0)
		    {
		      yr[j] = yr[j] + ur[j];
		      yi[j] = yi[j] + ui[j];
		    }
		  else
		    {
		      yr[j] = yr[j] - ur[j];
		      yi[j] = yi[j] - ui[j];
		    }
		}
	    }
	}
    }
}
