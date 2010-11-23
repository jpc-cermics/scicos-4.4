#include "blocks.h"

#define BIT_CLEAR(tag, type)						\
  void CNAME(bit_clear_,tag) (scicos_block * block, int flag)		\
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

