# include "blocks.h"

typedef struct
{
  double *l0;
  doubleC *LA;
  doubleC *LU;
  double *LSV;
  double *LVT;
  doubleC *dwork;
  double *rwork;
} mat_sdv_struct;


void matz_svd (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *ur, *ui;
  double *y1r, *y2r, *y3r;
  double *y1i, *y3i;
  int nu, mu;
  int info;
  int i, j, ij, ji, ii, lwork, rw;
  mat_sdv_struct *ptr;
  mu = GetInPortRows (block, 1);
  nu = GetInPortCols (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  y1r = GetRealOutPortPtrs (block, 1);
  y2r = GetRealOutPortPtrs (block, 2);
  y3r = GetRealOutPortPtrs (block, 3);
  y1i = GetImagOutPortPtrs (block, 1);
  //y2i=GetImagOutPortPtrs(block,2);
  y3i = GetImagOutPortPtrs (block, 3);
  lwork = max (3 * min (mu, nu) + max (mu, nu), 5 * min (mu, nu) - 4);
  rw = 5 * min (mu, nu);
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_sdv_struct *) scicos_malloc (sizeof (mat_sdv_struct))) ==
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
	   (doubleC *) scicos_malloc (sizeof (double) * (2 * mu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LU =
	   (doubleC *) scicos_malloc (sizeof (double) * (2 * mu * mu))) ==
	  NULL)
	{
	  set_block_error (-16);
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
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LVT =
	   scicos_malloc (sizeof (double) * (2 * nu * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork = scicos_malloc (sizeof (double) * 2 * lwork)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->l0);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->rwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * rw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->LVT);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LU);
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
      if ((ptr->rwork) != NULL)
	{
	  scicos_free (ptr->l0);
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LU);
	  scicos_free (ptr->LSV);
	  scicos_free (ptr->LVT);
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
	  ptr->LA[i].r = ur[i];
	  ptr->LA[i].i = ui[i];
	}
      C2F (zgesvd) ("A", "A", &mu, &nu, ptr->LA, &mu, ptr->LSV, ptr->LU, &mu,
		    (doubleC *) ptr->LVT, &nu, ptr->dwork, &lwork, ptr->rwork,
		    &info, 1, 1);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}

      *(ptr->l0) = 0;
      C2F (dlaset) ("F", &mu, &nu, ptr->l0, ptr->l0, y2r, &mu, 1);
      for (i = 0; i < min (mu, nu); i++)
	{
	  ii = i + i * mu;
	  *(y2r + ii) = *(ptr->LSV + i);
	}
      for (j = 0; j < nu; j++)
	{
	  for (i = j; i < nu; i++)
	    {
	      ij = i + j * nu;
	      ji = j + i * nu;
	      *(y3r + ij) = *(ptr->LVT + 2 * ji);
	      *(y3r + ji) = *(ptr->LVT + 2 * ij);
	      *(y3i + ij) = -(*(ptr->LVT + 2 * ji + 1));
	      *(y3i + ji) = -(*(ptr->LVT + 2 * ij + 1));
	    }
	}
      for (i = 0; i < mu * mu; i++)
	{
	  *(y1r + i) = ptr->LU[i].r;	/* *(ptr->LU+2*i); */
	  *(y1i + i) = ptr->LU[i].i;	/* *(ptr->LU+2*i+1);} */
	}
    }
}
