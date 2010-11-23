#include "blocks.h"

#define BIT_SET(tag, type)						\
  void CNAME(bit_set_,tag) (scicos_block * block, int flag)		\
  {									\
    int i;								\
    int m= GetInPortRows (block, 1);					\
    int n= GetInPortCols (block, 1);					\
    type *opar = (type *) GetOparPtrs (block, 1);			\
    type *u =(type *) GetInPortPtrs (block, 1);				\
    type *y =(type *) GetOutPortPtrs (block, 1);			\
    for (i = 0; i < m * n; i++)						\
      *(y + i) = ((*(u + i)) | (*opar));				\
  }

BIT_SET(8, gint8)
BIT_SET(16, gint16)
BIT_SET(32, gint)

#undef BIT_SET 

