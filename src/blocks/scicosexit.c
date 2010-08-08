#include "blocks.h"

void scicosexit (scicos_block * block, int flag)
{
  if (flag == 1)
    end_scicos_sim ();
}
