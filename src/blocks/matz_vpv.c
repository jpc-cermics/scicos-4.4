# include "blocks.h"

typedef struct
{
  double *LA;
  double *LX;
  double *LVR;
  double *dwork;
  double *rwork;
  double *dwork1;
  double *rwork1;
} mat_vpv_struct;

void matz_vpv (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *ur, *ui;
  double *y1r, *y1i, *y2r, *y2i;
  int nu;
  int info;
  int i, lwork, lwork1, j, ii, ij, ji, rw;
  int hermitien;
  double l0;
  mat_vpv_struct *ptr;

  nu = GetInPortRows (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  y1r = GetRealOutPortPtrs (block, 1);
  y1i = GetImagOutPortPtrs (block, 1);
  y2r = GetRealOutPortPtrs (block, 2);
  y2i = GetImagOutPortPtrs (block, 2);
  lwork1 = 2 * nu;
  lwork = 2 * nu - 1;
  rw = 3 * nu - 2;
  /*init : initialization */
  if (flag == 4)
    {
      if ((*(_work) =
	   (mat_vpv_struct *) scicos_malloc (sizeof (mat_vpv_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      ptr = *(_work);
      if ((ptr->LA =
	   (double *) scicos_malloc (sizeof (double) * (2 * nu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LX =
	   (double *) scicos_malloc (sizeof (double) * (2 * nu))) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->LVR =
	   (double *) scicos_malloc (sizeof (double) * (2 * nu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * lwork)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->LVR);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->rwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * rw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->LVR);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork1 =
	   (double *) scicos_malloc (sizeof (double) * 2 * lwork1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->rwork);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->LVR);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->rwork1 =
	   (double *) scicos_malloc (sizeof (double) * 2 * lwork1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->dwork1);
	  scicos_free (ptr->rwork);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->LVR);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LA);
	  scicos_free (ptr);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      if ((ptr->rwork1) != NULL)
	{
	  scicos_free (ptr->LA);
	  scicos_free (ptr->LX);
	  scicos_free (ptr->LVR);
	  scicos_free (ptr->rwork);
	  scicos_free (ptr->rwork1);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->dwork1);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      for (i = 0; i < (nu * nu); i++)
	{
	  ptr->LA[2 * i] = ur[i];
	  ptr->LA[2 * i + 1] = ui[i];
	}
      hermitien = 1;
      for (j = 0; j < nu; j++)
	{
	  for (i = j; i < nu; i++)
	    {
	      ij = i + j * nu;
	      ji = j + i * nu;
	      if (i != j)
		{
		  if ((*(ptr->LA + 2 * ij) == *(ptr->LA + 2 * ji))
		      && (*(ptr->LA + 2 * ij + 1) ==
			  -(*(ptr->LA + 2 * ji + 1))))
		    hermitien *= 1;
		  else
		    {
		      hermitien *= 0;
		      break;
		    }
		}
	    }
	}
      if (hermitien == 1)
	{
	  C2F (zheev) ("V", "U", &nu, (doubleC *) ptr->LA, &nu, ptr->LX,
		       (doubleC *) ptr->dwork, &lwork, ptr->rwork, &info, 1,
		       1);
	  if (info != 0)
	    {
	      if (flag != 6)
		{
		  set_block_error (-7);
		  return;
		}
	    }
	  for (i = 0; i < nu; i++)
	    {
	      ii = i + i * nu;
	      *(y1r + ii) = *(ptr->LX + i);
	    }
	  for (i = 0; i < nu * nu; i++)
	    {
	      *(y2r + i) = *(ptr->LA + 2 * i);
	      *(y2i + i) = *(ptr->LA + 2 * i + 1);
	    }
	}

      else
	{
	  C2F (zgeev) ("N", "V", &nu, (doubleC *) ptr->LA, &nu,
		       (doubleC *) ptr->LX, (doubleC *) ptr->dwork1, &nu,
		       (doubleC *) ptr->LVR, &nu, (doubleC *) ptr->dwork1,
		       &lwork1, ptr->rwork1, &info, 1, 1);
	  if (info != 0)
	    {
	      if (flag != 6)
		{
		  set_block_error (-7);
		  return;
		}
	    }
	  l0 = 0;
	  C2F (dlaset) ("F", &nu, &nu, &l0, &l0, y1r, &nu, 1);
	  C2F (dlaset) ("F", &nu, &nu, &l0, &l0, y1i, &nu, 1);
	  C2F (dlaset) ("F", &nu, &nu, &l0, &l0, y2r, &nu, 1);
	  C2F (dlaset) ("F", &nu, &nu, &l0, &l0, y2i, &nu, 1);
	  for (i = 0; i < nu; i++)
	    {
	      ii = i + i * nu;
	      *(y1r + ii) = *(ptr->LX + 2 * i);
	      *(y1i + ii) = *(ptr->LX + 2 * i + 1);
	    }
	  for (i = 0; i < nu * nu; i++)
	    {
	      *(y2r + i) = *(ptr->LVR + 2 * i);
	      *(y2i + i) = *(ptr->LVR + 2 * i + 1);
	    }
	}
    }
}
