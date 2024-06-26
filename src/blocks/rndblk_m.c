#include "blocks.h"

void rndblk_m (scicos_block * block, int flag)
{
  double *y;
  double *rpar;
  double *z;
  int *ipar;
  int ny, my, i, iy;
  double sr, si, tl;

  my = GetOutPortRows (block, 1);
  ny = GetOutPortCols (block, 1);
  ipar = GetIparPtrs (block);
  rpar = GetRparPtrs (block);
  y = GetRealOutPortPtrs (block, 1);
  z = GetDstate (block);

  /* printf("Z est de taille %d et (%d,%d)\n",block->nz,my,ny); */

  if (flag == 2 || flag == 4)
    {
      if (ipar[0] == 0)
	{
	  iy = (int) z[0];
	  for (i = 0; i < my * ny; i++)
	    {
	      *(z + i + 1) = nsp_urand (&iy);
	    }
	}
      else
	{
	  iy = (int) z[0];
	  for (i = 0; i < my * ny; i++)
	    {
	      do
		{
		  sr = 2.0 * nsp_urand (&iy) - 1.0;
		  si = 2.0 * nsp_urand (&iy) - 1.0;
		  tl = sr * sr + si * si;
		}
	      while (tl > 1.0);
	      z[i + 1] = sr * (sqrt (-2.0 * log (tl) / tl));
	    }
	}
      *(z) = iy;
    }

  if (flag == 1 || flag == 6)
    {
      for (i = 0; i < my * ny; i++)
	*(y + i) = *(rpar + i) + (*(rpar + i + my * ny)) * (*(z + i + 1));
    }
}
