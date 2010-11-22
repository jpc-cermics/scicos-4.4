#include "blocks.h"

void bit_clear_8_old (scicos_block * block, int flag)
{
  int n, m, i;
  char *opar;
  char *u, *y;
  opar = Getint8OparPtrs (block, 1);
  u = Getint8InPortPtrs (block, 1);
  y = Getint8OutPortPtrs (block, 1);
  n = GetInPortCols (block, 1);
  m = GetInPortRows (block, 1);
  for (i = 0; i < m * n; i++)
    *(y + i) = ((*(u + i)) & (*opar));
}

#define BIT_CLEAR(tag, type)						\
  void CNAME(new_bit_clear_,tag) (scicos_block * block, int flag)	\
  {									\
    int i;								\
    int m= GetInPortRows (block, 1);					\
    int n= GetInPortCols (block, 1);					\
    type *opar = (type *) GetOparPtrs (block, 1);			\
    type *u =(type *) GetInPortPtrs (block, 1);				\
    type *y =(type *) GetOutPortPtrs (block, 1);			\
    for (i = 0; i < m * n; i++)						\
      *(y + i) = ((*(u + i)) & (*opar));				\
  }

BIT_CLEAR(8, gint8)
BIT_CLEAR(16, gint16)
BIT_CLEAR(32, gint)

#undef BIT_CLEAR 

