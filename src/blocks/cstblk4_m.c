#include "blocks.h"

/* Copyright INRIA
 *   Scicos block simulator
 *  output a vector of constants out(i)=opar(i)
 *  opar(1:nopar) : given constants 
 */

void cstblk4_m (scicos_block * block, int flag)
{
  /* int nopar = GetNopar (block); */
  void *y = GetOutPortPtrs (block, 1);
  void *opar = GetOparPtrs (block, 1);
  int mo = GetOparSize (block, 1, 1);
  int no = GetOparSize (block, 1, 2);
  int so = GetSizeOfOpar (block, 1);
  memcpy (y, opar, mo * no * so);
}

