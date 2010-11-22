#include "blocks.h"

#define CASE_OP1(op)  _y1[0] = (_u1[0] op _u2[0]) ? 1.0: 0.0;
#define CASE_OP2(op)  _mode[0] = (_u1[0] op _u2[0]) ? 2: 1;

void relationalop (scicos_block * block, int flag)
{
  int *_ipar = GetIparPtrs (block);
  int _ng = GetNg (block);
  double *_g = GetGPtrs (block);
  int *_mode = GetModePtrs (block);
  double *_u1 = GetRealInPortPtrs (block, 1);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  double *_u2 = GetRealInPortPtrs (block, 2);
  int i =  _ipar[0];
  
  if (flag == 1)
    {
      if (_ng != 0 && areModesFixed (block))
	{
	  _y1[0] = _mode[0] - 1.0;
	}
      else
	{
	  switch (i)
	    {
	    case 0: CASE_OP1(==);break;
	    case 1: CASE_OP1(!=);break;
	    case 2: CASE_OP1(<);break;
	    case 3: CASE_OP1(<=);break;
	    case 4: CASE_OP1(>=);break;
	    case 5: CASE_OP1(>);break;
	    }
	}

    }
  else if (flag == 9)
    {
      _g[0] = _u1[0] - _u2[0];
      if (!areModesFixed (block))
	{
	  switch (i)
	    {
	    case 0: CASE_OP2(==);break;
	    case 1: CASE_OP2(!=);break;
	    case 2: CASE_OP2(<);break;
	    case 3: CASE_OP2(<=);break;
	    case 4: CASE_OP2(>=);break;
	    case 5: CASE_OP2(>);break;
	    }
	}
    }
}
