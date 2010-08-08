# include "blocks.h"

typedef struct
{
  int *bwork;
  int *iwork;
  double *dwork;
  double *LX;
  double *LWI;
  double *LWR;
  double *Rcond;
  double *Ferr;
} ricc_struct;

void ricc_m (scicos_block * block, int flag)
{
  ricc_struct *ptr;
  void **_work = GetPtrWorkPtrs (block);
  int info, i, lw;
  int nu = GetInPortCols (block, 1);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  double *u3 = GetRealInPortPtrs (block, 3);
  double *y = GetRealOutPortPtrs (block, 1);
  int *ipar = GetIparPtrs (block);

  if (ipar[0] == 1)
    {
      if (ipar[1] == 1)
	{
	  lw = 9 * nu * nu + 4 * nu + max (1, 6 * nu);
	}
      else
	{
	  lw = 9 * nu * nu + 7 * nu + 1;
	}
    }
  else
    {
      if (ipar[1] == 1)
	{
	  lw = 12 * nu * nu + 22 * nu + max (21, 4 * nu);
	}
      else
	{
	  lw = 28 * nu * nu + 2 * nu + max (1, 2 * nu);
	}
    }
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (ricc_struct *) scicos_malloc (sizeof (ricc_struct))) == NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->bwork =
	   (int *) scicos_malloc (sizeof (int) * 2 * nu)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->iwork =
	   (int *) scicos_malloc (sizeof (int) * max (2 * nu, nu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * lw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LWR =
	   (double *) scicos_malloc (sizeof (double) * nu)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LWI =
	   (double *) scicos_malloc (sizeof (double) * nu)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LWR);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->Rcond = (double *) scicos_malloc (sizeof (double))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LWI);
	  scicos_free (ptr->LWR);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->Ferr = (double *) scicos_malloc (sizeof (double))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->Rcond);
	  scicos_free (ptr->LWI);
	  scicos_free (ptr->LWR);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LX =
	   (double *) scicos_malloc (sizeof (double) * nu * nu)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->Ferr);
	  scicos_free (ptr->Rcond);
	  scicos_free (ptr->LWI);
	  scicos_free (ptr->LWR);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->bwork);
	  scicos_free (ptr);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if ((ptr->LX) != NULL)
	{
	  scicos_free (ptr->bwork);
	  scicos_free (ptr->Ferr);
	  scicos_free (ptr->Rcond);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->LWR);
	  scicos_free (ptr->LWI);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      if (ipar[0] == 1)
	{
	  if (ipar[1] == 1)
	    {
	      nsp_ctrlpack_riccsl ("N", &nu, u1, &nu, "U", u3, &nu, u2, &nu,
				   ptr->LX, &nu, ptr->LWR, ptr->LWI,
				   ptr->Rcond, ptr->Ferr, ptr->dwork, &lw,
				   ptr->iwork, ptr->bwork, &info, 1, 1);
	    }
	  else
	    {
	      nsp_ctrlpack_riccms ("N", &nu, u1, &nu, "U", u3, &nu, u2, &nu,
				   ptr->LX, &nu, ptr->LWR, ptr->LWI,
				   ptr->Rcond, ptr->Ferr, ptr->dwork, &lw,
				   ptr->iwork, &info, 1, 1);
	    }
	}
      else
	{
	  if (ipar[1] == 1)
	    {
	      nsp_ctrlpack_ricdsl ("N", &nu, u1, &nu, "U", u3, &nu, u2, &nu,
				   ptr->LX, &nu, ptr->LWR, ptr->LWI,
				   ptr->Rcond, ptr->Ferr, ptr->dwork, &lw,
				   ptr->iwork, ptr->bwork, &info, 1, 1);
	    }
	  else
	    {
	      nsp_ctrlpack_ricdmf ("N", &nu, u1, &nu, "U", u3, &nu, u2, &nu,
				   ptr->LX, &nu, ptr->LWR, ptr->LWI,
				   ptr->Rcond, ptr->Ferr, ptr->dwork, &lw,
				   ptr->iwork, &info, 1, 1);
	    }
	}
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
      for (i = 0; i < nu * nu; i++)
	*(y + i) = *(ptr->LX + i);
    }
}
