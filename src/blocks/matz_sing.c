# include "blocks.h"

typedef struct
{
  double *LA;
  double *LX;
  double *LU;
  double *LVT;
  double *dwork;
  double *rwork;
} mat_sing_struct;


void matz_sing (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *ur;
  double *ui;
  double *yr;
  /*double *yi;*/
  int nu, mu;
  int info;
  int i, rw, lwork;
  mat_sing_struct *ptr;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  yr = GetRealOutPortPtrs (block, 1);
  /*yi = GetImagOutPortPtrs (block, 1);*/
  lwork = max (3 * min (mu, nu) + max (mu, nu), 5 * min (mu, nu) - 4);
  rw = 5 * min (mu, nu);
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_sing_struct *) scicos_malloc (sizeof (mat_sing_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->LA =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LU =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu * mu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LVT =
	   (double *) scicos_malloc (sizeof (double) * (2 * nu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LX =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * lwork)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->rwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * rw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if ((ptr->rwork) != NULL)
	{
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->rwork);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      for (i = 0; i < (mu * nu); i++)
	{
	  ptr->LA[2 * i] = ur[i];
	  ptr->LA[2 * i + 1] = ui[i];
	}
      C2F (zgesvd) ("A", "A", &mu, &nu, (doubleC *) ptr->LA, &mu, yr,
		    (doubleC *) ptr->LU, &mu, (doubleC *) ptr->LVT, &nu,
		    (doubleC *) ptr->dwork, &lwork, ptr->rwork, &info, 1, 1);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
    }
}
