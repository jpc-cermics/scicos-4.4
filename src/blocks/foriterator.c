#include "blocks.h"

void foriterator (scicos_block * block, int flag)
{
  void *y, *u, *z;
  int *ipar;
  int so;
  int nin;
  z = GetOzPtrs (block, 1);
  so = GetSizeOfOut (block, 1);
  if (flag == 1)
    {
      y = GetOutPortPtrs (block, 1);
      memcpy (y, z, so);
    }
  else if (flag == 2)
    {
      ipar = GetIparPtrs (block);
      if (*ipar == 0)
	{
	  if (so == 1)
	    {
	      char *inp;
	      inp = (char *) z;
	      *inp = *inp + 1;
	    }
	  else if (so == 2)
	    {
	      SCSINT16_COP *inp;
	      inp = (SCSINT16_COP *) z;
	      *inp = *inp + 1;
	    }
	  else if (so == 4)
	    {
	      SCSINT32_COP *inp;
	      inp = (SCSINT32_COP *) z;
	      *inp = *inp + 1;
	    }
	  else if (so == 8)
	    {
	      double *inp;
	      inp = (double *) z;
	      *inp = *inp + 1;
	    }
	}
      else
	{
	  nin = GetNin (block);
	  u = GetInPortPtrs (block, nin);
	  memcpy (z, u, so);
	}
    }
}
