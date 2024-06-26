# include "blocks.h"

typedef struct
{
  int *ipiv;
  int *rank;
  int *jpvt;
  int *iwork;
  double *dwork;
  double *LAF;
  double *LA;
  double *LXB;
} mat_bksl_struct;

void mat_bksl (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *u1;
  double *u2;
  double *y;
  int mu;
  int nu1;
  int nu2;
  int info;
  int i, l, lw, lu;
  mat_bksl_struct *ptr;
  double rcond, ANORM, EPS;

  mu = GetInPortRows (block, 1);
  nu1 = GetInPortCols (block, 1);
  nu2 = GetInPortCols (block, 2);
  u1 = GetRealInPortPtrs (block, 1);
  u2 = GetRealInPortPtrs (block, 2);
  y = GetRealOutPortPtrs (block, 1);
  l = max (mu, nu1);
  lu = max (4 * nu1, min (mu, nu1) + 3 * nu1 + 1);
  lw = max (lu, 2 * min (mu, nu1) + nu2);
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_bksl_struct *) scicos_malloc (sizeof (mat_bksl_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->ipiv = (int *) scicos_malloc (sizeof (int) * nu1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->rank = (int *) scicos_malloc (sizeof (int))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->jpvt = (int *) scicos_malloc (sizeof (int) * nu1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->iwork = (int *) scicos_malloc (sizeof (int) * nu1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * lw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LAF =
	   (double *) scicos_malloc (sizeof (double) * (mu * nu1))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LA =
	   (double *) scicos_malloc (sizeof (double) * (mu * nu1))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LAF);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LXB =
	   (double *) scicos_malloc (sizeof (double) * (l * nu2))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LAF);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}

    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if (ptr->LXB != NULL)
	{
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->LAF);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LXB);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      EPS = C2F (dlamch) ("e", 1L);
      ANORM = C2F (dlange) ("1", &mu, &nu1, u1, &mu, ptr->dwork, 1);
      C2F (dlacpy) ("F", &mu, &nu1, u1, &mu, ptr->LA, &mu, 1);
      if (mu == nu1)
	{
	  C2F (dlacpy) ("F", &mu, &nu1, ptr->LA, &mu, ptr->LAF, &mu, 1);
	  C2F (dgetrf) (&nu1, &nu1, ptr->LAF, &nu1, ptr->ipiv, &info);
	  rcond = 0;
	  if (info == 0)
	    {
	      C2F (dgecon) ("1", &nu1, ptr->LAF, &nu1, &ANORM, &rcond,
			    ptr->dwork, ptr->iwork, &info, 1);
	      if (rcond > pow (EPS, 0.5))
		{
		  C2F (dlacpy) ("F", &nu1, &nu2, u2, &nu1, ptr->LXB, &nu1, 1);
		  C2F (dgetrs) ("N", &nu1, &nu2, ptr->LAF, &nu1, ptr->ipiv,
				ptr->LXB, &nu1, &info, 1);
		  C2F (dlacpy) ("F", &nu1, &nu2, ptr->LXB, &nu1, y, &nu1, 1);
		  return;
		}
	    }
	}
      rcond = pow (EPS, 0.5);
      C2F (dlacpy) ("F", &mu, &nu2, u2, &mu, ptr->LXB, &l, 1);
      for (i = 0; i < nu1; i++)
	*(ptr->jpvt + i) = 0;

      nsp_ctrlpack_dgelsy1 (&mu, &nu1, &nu2, ptr->LA, &mu, ptr->LXB, &l,
			    ptr->jpvt, &rcond, ptr->rank, ptr->dwork, &lw,
			    &info);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
      C2F (dlacpy) ("F", &nu1, &nu2, ptr->LXB, &l, y, &nu1, 1);
    }
}
