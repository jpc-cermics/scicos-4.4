# include "blocks.h"

typedef struct
{
  double *l0;
  double *LA;
  double *LC;
  double *LS;
  double *LSV;
  double *LSW;
  double *LU;
  double *LUT;
  double *LV;
  double *LVT;
  double *dwork;
} mat_pinv_struct;
void mat_pinv (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *u;
  double *y;
  int nu, mu;
  int info;
  int i, j, ij, ji, ii, lwork;
  mat_pinv_struct *ptr;
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
	   (mat_pinv_struct *) scicos_malloc (sizeof (mat_pinv_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->l0 = (double *) scicos_malloc (sizeof (double))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LA =
	   (double *) scicos_malloc (sizeof (double) * (mu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LC =
	   (double *) scicos_malloc (sizeof (double) * (nu * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LS =
	   (double *) scicos_malloc (sizeof (double) * (nu * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LSV =
	   (double *) scicos_malloc (sizeof (double) * (min (mu, nu)))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LSW =
	   (double *) scicos_malloc (sizeof (double) * (min (mu, nu)))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LU =
	   (double *) scicos_malloc (sizeof (double) * (mu * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LUT =
	   (double *) scicos_malloc (sizeof (double) * (mu * mu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LV =
	   (double *) scicos_malloc (sizeof (double) * (nu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LUT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LVT =
	   (double *) scicos_malloc (sizeof (double) * (nu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LV);
	  scicos_free (ptr->LUT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * lwork)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LV);
	  scicos_free (ptr->LUT);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LC);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if ((ptr->dwork) != 0)
	{
	  scicos_free (ptr->LC);
	  scicos_free (ptr->l0);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LSW);
	  scicos_free (ptr->LS);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LUT);
	  scicos_free (ptr->LV);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      for (i = 0; i < mu * nu; i++)
	y[i] = 0;
      C2F (dlacpy) ("F", &mu, &nu, u, &mu, ptr->LA, &mu, 1);
      C2F (dgesvd) ("A", "A", &mu, &nu, ptr->LA, &mu, ptr->LSV, ptr->LU, &mu,
		    ptr->LVT, &nu, ptr->dwork, &lwork, &info, 1, 1);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
      for (i = 0; i < min (mu, nu); i++)
	{
	  if (*(ptr->LSV + i) != 0)
	    {
	      *(ptr->LSW + i) = 1 / (*(ptr->LSV + i));
	    }
	  else
	    {
	      *(ptr->LSW + i) = 0;
	    }
	}
      *(ptr->l0) = 0;
      C2F (dlaset) ("F", &nu, &mu, ptr->l0, ptr->l0, ptr->LS, &nu, 1);
      for (i = 0; i < min (mu, nu); i++)
	{
	  ii = i + i * nu;
	  *(ptr->LS + ii) = *(ptr->LSW + i);
	}
      for (j = 0; j < mu; j++)
	{
	  for (i = j; i < mu; i++)
	    {
	      ij = i + j * mu;
	      ji = j + i * mu;
	      *(ptr->LUT + ij) = *(ptr->LU + ji);
	      *(ptr->LUT + ji) = *(ptr->LU + ij);
	    }
	}
      for (j = 0; j < nu; j++)
	{
	  for (i = j; i < nu; i++)
	    {
	      ij = i + j * nu;
	      ji = j + i * nu;
	      *(ptr->LV + ij) = *(ptr->LVT + ji);
	      *(ptr->LV + ji) = *(ptr->LVT + ij);
	    }
	}
      nsp_calpack_dmmul (ptr->LV, &nu, ptr->LS, &nu, ptr->LC, &nu, &nu, &nu,
			 &mu);
      nsp_calpack_dmmul (ptr->LC, &nu, ptr->LUT, &mu, y, &nu, &nu, &mu, &mu);
    }
}
