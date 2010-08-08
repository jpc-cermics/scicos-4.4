#include "blocks.h"

typedef struct
{
  int s;
} dol_struct;

void dollar4_m (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  /* c     Copyright INRIA

     Scicos block simulator
     Ouputs delayed input */


  int m, n;
  double *y, *u, *oz;
  dol_struct *ptr;
  m = GetInPortRows (block, 1);
  n = GetInPortCols (block, 1);
  u = GetInPortPtrs (block, 1);
  y = GetOutPortPtrs (block, 1);
  oz = GetOzPtrs (block, 1);

  if (flag == 4)
    {
      *(_work) = (dol_struct *) scicos_malloc (sizeof (dol_struct));
      ptr = *(_work);
      /*        ptr->s=(int) scicos_malloc(sizeof(int)); */
      ptr->s = GetSizeOfOz (block, 1);
    }
  if (flag == 1 || flag == 6)
    {
      ptr = *(_work);
      memcpy (y, oz, m * n * (ptr->s));
    }
  if (flag == 2)
    {
      ptr = *(_work);
      memcpy (oz, u, m * n * ptr->s);
    }
  if (flag == 5)
    {
      ptr = *(_work);
      if (ptr != NULL)
	{
	  scicos_free (ptr);
	}
    }

}
