# include "blocks.h"

void matmul_i32n (scicos_block * block, int flag)
{
  if ((flag == 1) | (flag == 6))
    {
      SCSINT32_COP *u1, *u2, *y;
      double k, C, D, t;
      int mu1, nu1, nu2, i, j, l, ji, jl, il;
      /*int *ipar;*/

      mu1 = GetInPortRows (block, 1);
      nu1 = GetInPortCols (block, 1);
      nu2 = GetInPortCols (block, 2);
      u1 = Getint32InPortPtrs (block, 1);
      u2 = Getint32InPortPtrs (block, 2);
      y = Getint32OutPortPtrs (block, 1);
      /*ipar = GetIparPtrs (block);*/


      k = pow (2, 32);
      for (l = 0; l < nu2; l++)
	{
	  for (j = 0; j < mu1; j++)
	    {
	      D = 0;
	      jl = j + l * mu1;
	      for (i = 0; i < nu1; i++)
		{
		  ji = j + i * mu1;
		  il = i + l * nu1;
		  C = (double) (u1[ji]) * (double) (u2[il]);
		  D = D + C;
		}
	      t = D - (double) ((int) (D / (k))) * ((k));
	      if ((t >= k / 2) | (-(t) >= k / 2))
		{
		  if (t >= 0)
		    (t) =
		      (-((k / 2)) +
		       fabs (t -
			     (double) ((int) ((t) / ((k / 2)))) * ((k / 2))));
		  else
		    (t) =
		      -(-((k / 2)) +
			fabs (t -
			      (double) ((int) ((t) / ((k / 2)))) *
			      ((k / 2))));
		}
	      y[jl] = (SCSINT32_COP) t;
	    }
	}
    }
}
