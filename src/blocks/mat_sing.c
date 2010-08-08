# include "blocks.h"

typedef struct
{
  double *LA;
  double *LU;
  double *LVT;
  double *dwork;
} mat_sing_struct;

void mat_sing (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *u;
  double *y;
  int nu, mu;
  int info;
  int lwork;
  mat_sing_struct *ptr;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  u = GetRealInPortPtrs (block, 1);
  y = GetRealOutPortPtrs (block, 1);
  /* for lapack 2.0 (1994) 
     lwork=max(3*min(mu,nu)+max(mu,nu),5*min(mu,nu)-4); */
  /* for lapack 3.1 (2006) */
  lwork = max (3 * min (mu, nu) + max (mu, nu), 5 * min (mu, nu));
  lwork = max (1, lwork);

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
	   (double *) scicos_malloc (sizeof (double) * (mu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LU =
	   (double *) scicos_malloc (sizeof (double) * (mu * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LVT =
	   (double *) scicos_malloc (sizeof (double) * (nu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * lwork)) == NULL)
	{
	  set_block_error (-16);
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
      if (ptr->dwork != 0)
	{
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      C2F (dlacpy) ("F", &mu, &nu, u, &mu, ptr->LA, &mu, 1);
      C2F (dgesvd) ("A", "A", &mu, &nu, ptr->LA, &mu, y, ptr->LU, &mu,
		    ptr->LVT, &nu, ptr->dwork, &lwork, &info, 1, 1);
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
