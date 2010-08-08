# include "blocks.h"


typedef struct
{
  int *iwork;
  double *dwork;
} mat_exp_struct;

void matz_expm (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *ur, *ui;
  double *yr, *yi;
  int nu;
  int ierr;
  mat_exp_struct *ptr;

  nu = GetInPortCols (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  yr = GetRealOutPortPtrs (block, 1);
  yi = GetImagOutPortPtrs (block, 1);
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_exp_struct *) scicos_malloc (sizeof (mat_exp_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->iwork =
	   (int *) scicos_malloc (sizeof (int) * (2 * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) *
				     (nu * (4 * nu + 4 * nu + 7)))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if (ptr->dwork != NULL)
	{
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      nsp_ctrlpack_wexpm1 (&nu, ur, ui, &nu, yr, yi, &nu, ptr->dwork,
			   ptr->iwork, &ierr);
      if (ierr != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
    }
}
