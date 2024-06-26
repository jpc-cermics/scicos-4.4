# include "blocks.h"

typedef struct
{
  int *ipiv;
  int *rank;
  int *jpvt;
  int *iwork;
  double *dwork;
  double *LAF;
  double *LBT;
  double *LAT;
} mat_div_struct;

void mat_div (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *u1;
  double *u2;
  double *y;
  int mu1, mu2;
  int nu;
  /*int nu2;*/
  int info;
  int i, j, l, lw, lu, ij, ji;
  mat_div_struct *ptr;
  double rcond, ANORM, EPS;

  mu2 = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  mu1 = GetInPortRows (block, 2);
  /*nu2 = GetInPortCols (block, 2);*/
  u2 = GetRealInPortPtrs (block, 1);
  u1 = GetRealInPortPtrs (block, 2);
  y = GetRealOutPortPtrs (block, 1);
  l = max (mu1, nu);
  lu = max (4 * nu, min (mu1, nu) + 3 * mu1 + 1);
  lw = max (lu, 2 * min (mu1, nu) + mu2);
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_div_struct *) scicos_malloc (sizeof (mat_div_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->ipiv = (int *) scicos_malloc (sizeof (int) * nu)) == NULL)
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
      if ((ptr->jpvt = (int *) scicos_malloc (sizeof (int) * mu1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->iwork = (int *) scicos_malloc (sizeof (int) * nu)) == NULL)
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
	   (double *) scicos_malloc (sizeof (double) * (nu * mu1))) == NULL)
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
      if ((ptr->LBT =
	   (double *) scicos_malloc (sizeof (double) * (l * mu2))) == NULL)
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
      if ((ptr->LAT =
	   (double *) scicos_malloc (sizeof (double) * (nu * mu1))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LBT);
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
      if ((ptr->LAT) != NULL)
	{
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->LAF);
	  scicos_free (ptr->LBT);
	  scicos_free (ptr->LAT);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      EPS = C2F (dlamch) ("e", 1L);
      ANORM = C2F (dlange) ("l", &mu1, &nu, u1, &mu1, ptr->dwork, 1);
      for (j = 0; j < mu1; j++)
	{
	  for (i = 0; i < nu; i++)
	    {
	      ij = i + j * nu;
	      ji = j + i * mu1;
	      *(ptr->LAT + ij) = *(u1 + ji);
	    }
	}
      for (j = 0; j < mu2; j++)
	{
	  for (i = 0; i < nu; i++)
	    {
	      ij = i + j * l;
	      ji = j + i * mu2;
	      *(ptr->LBT + ij) = *(u2 + ji);
	    }
	}
      if (mu1 == nu)
	{
	  C2F (dlacpy) ("F", &nu, &nu, ptr->LAT, &nu, ptr->LAF, &nu, 1);
	  C2F (dgetrf) (&nu, &nu, ptr->LAF, &nu, ptr->ipiv, &info);
	  rcond = 0;
	  if (info == 0)
	    {
	      C2F (dgecon) ("1", &nu, ptr->LAF, &nu, &ANORM, &rcond,
			    ptr->dwork, ptr->iwork, &info, 1);
	      if (rcond > pow (EPS, 0.5))
		{
		  C2F (dgetrs) ("N", &nu, &mu2, ptr->LAF, &nu, ptr->ipiv,
				ptr->LBT, &nu, &info, 1);
		  for (j = 0; j < nu; j++)
		    {
		      for (i = 0; i < mu2; i++)
			{
			  ij = i + j * mu2;
			  ji = j + i * nu;
			  *(y + ij) = *(ptr->LBT + ji);
			}
		    }
		  return;
		}
	    }
	}
      rcond = pow (EPS, 0.5);
      for (i = 0; i < mu1; i++)
	*(ptr->jpvt + i) = 0;
      nsp_ctrlpack_dgelsy1 (&nu, &mu1, &mu2, ptr->LAT, &nu, ptr->LBT, &l,
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
      for (j = 0; j < mu1; j++)
	{
	  for (i = 0; i < mu2; i++)
	    {
	      ij = i + j * mu2;
	      ji = j + i * l;
	      *(y + ij) = *(ptr->LBT + ji);
	    }
	}
    }
}
