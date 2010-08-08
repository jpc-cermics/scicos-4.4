#include "blocks.h"

void multiplex (scicos_block * block, int flag)
{
  int _nin = GetNin (block);
  int _nout = GetNout (block);
  double *_u1 = GetRealInPortPtrs (block, 1);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  double *uytmp;
  int i, j, k;
  if (_nin == 1)
    {
      k = 0;
      for (i = 0; i < _nout; ++i)
	{
	  for (j = 0; j < GetOutPortRows (block, i + 1); ++j)
	    {
	      uytmp = GetRealOutPortPtrs (block, i + 1);
	      uytmp[j] = _u1[k];
	      ++k;
	    }
	}
    }
  else
    {
      k = 0;
      for (i = 0; i < _nin; ++i)
	{
	  for (j = 0; j < GetInPortRows (block, i + 1); ++j)
	    {
	      uytmp = GetRealInPortPtrs (block, i + 1);
	      _y1[k] = uytmp[j];
	      ++k;
	    }
	}
    }
}
