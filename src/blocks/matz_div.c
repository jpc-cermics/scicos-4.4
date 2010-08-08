# include "blocks.h"

typedef struct
{
  int *ipiv;
  int *rank;
  int *jpvt;
  double *iwork;
  double *dwork;
  double *IN1F;
  double *IN1;
  double *urT1, *uiT1;
  double *IN2X;
  double *IN2;
  double *urT2, *uiT2;
  double *yrT, *yiT;
} mat_bksl_struct;

void matz_div (scicos_block * block, int flag)
{
  void **st;
  void **_work = GetPtrWorkPtrs (block);
  int info, i;
  mat_bksl_struct *ptr;
  double rcond, ANORM, EPS;
  int mu1 = GetInPortRows (block, 2);
  int nu = GetInPortCols (block, 1);
  int mu2 = GetInPortRows (block, 1);
  double *u1r = GetRealInPortPtrs (block, 2);
  double *u1i = GetImagInPortPtrs (block, 2);
  double *u2r = GetRealInPortPtrs (block, 1);
  double *u2i = GetImagInPortPtrs (block, 1);
  double *yr = GetRealOutPortPtrs (block, 1);
  double *yi = GetImagOutPortPtrs (block, 1);
  int l = max (mu1, nu);
  int lw1 = max (2 * min (mu1, nu), mu1 + 1);
  int lu = max (lw1, min (mu1, nu) + mu2);
  int lw = max (2 * nu, min (mu1, nu) + lu);

  if (flag == 4)
    {
      /* initialization */
      if ((ptr = *(_work) = scicos_malloc (sizeof (mat_bksl_struct))) == NULL)
	{
	  set_block_error (-16);
	  return;
	}
      /* set to zero */
      memset (ptr, '\0', sizeof (mat_bksl_struct));
      if ((ptr->ipiv = scicos_malloc (sizeof (int) * nu)) == NULL)
	goto err;
      if ((ptr->rank = scicos_malloc (sizeof (int))) == NULL)
	goto err;
      if ((ptr->jpvt = scicos_malloc (sizeof (int) * mu1)) == NULL)
	goto err;
      if ((ptr->iwork = scicos_malloc (sizeof (double) * 2 * mu1)) == NULL)
	goto err;
      if ((ptr->dwork = scicos_malloc (sizeof (double) * 2 * lw)) == NULL)
	goto err;
      if ((ptr->IN1F =
	   scicos_malloc (sizeof (double) * (2 * mu1 * nu))) == NULL)
	goto err;
      if ((ptr->IN1 =
	   scicos_malloc (sizeof (double) * (2 * mu1 * nu))) == NULL)
	goto err;
      if ((ptr->urT1 = scicos_malloc (sizeof (double) * (mu1 * nu))) == NULL)
	goto err;
      if ((ptr->uiT1 = scicos_malloc (sizeof (double) * (mu1 * nu))) == NULL)
	goto err;
      if ((ptr->IN2X =
	   scicos_malloc (sizeof (double) * (2 * l * mu2))) == NULL)
	goto err;
      if ((ptr->IN2 =
	   scicos_malloc (sizeof (double) * (2 * mu2 * nu))) == NULL)
	goto err;
      if ((ptr->urT2 = scicos_malloc (sizeof (double) * (mu2 * nu))) == NULL)
	goto err;
      if ((ptr->uiT2 = scicos_malloc (sizeof (double) * (mu2 * nu))) == NULL)
	goto err;
      if ((ptr->yiT = scicos_malloc (sizeof (double) * (mu2 * l))) == NULL)
	goto err;
      if ((ptr->yrT = scicos_malloc (sizeof (double) * (mu2 * l))) == NULL)
	goto err;
    }
  /* Terminaison */
  else if (flag == 5)
    {
      ptr = *(_work);
      goto free;
    }
  else
    {
      ptr = *(_work);
      scicos_mtran (u1r, mu1, ptr->urT1, nu, mu1, nu);
      scicos_mtran (u1i, mu1, ptr->uiT1, nu, mu1, nu);
      scicos_mtran (u2r, mu2, ptr->urT2, nu, mu2, nu);
      scicos_mtran (u2i, mu2, ptr->uiT2, nu, mu2, nu);
      for (i = 0; i < (mu1 * nu); i++)
	{
	  ptr->IN1[2 * i] = ptr->urT1[i];
	  ptr->IN1[2 * i + 1] = -ptr->uiT1[i];
	}

      for (i = 0; i < (mu2 * nu); i++)
	{
	  ptr->IN2[2 * i] = ptr->urT2[i];
	  ptr->IN2[2 * i + 1] = -ptr->uiT2[i];
	}
      EPS = C2F (dlamch) ("e", 1L);
      ANORM =
	C2F (zlange) ("1", &nu, &mu1, (doubleC *) ptr->IN1, &nu, ptr->dwork,
		      1);
      if (mu1 == nu)
	{
	  C2F (zlacpy) ("F", &nu, &nu, (doubleC *) ptr->IN1, &nu,
			(doubleC *) ptr->IN1F, &nu, 1);
	  C2F (zgetrf) (&nu, &nu, (doubleC *) ptr->IN1F, &nu, ptr->ipiv,
			&info);
	  rcond = 0;
	  if (info == 0)
	    {
	      C2F (zgecon) ("1", &nu, (doubleC *) ptr->IN1F, &nu, &ANORM,
			    &rcond, (doubleC *) ptr->dwork, ptr->iwork, &info,
			    1);
	      if (rcond > pow (EPS, 0.5))
		{
		  C2F (zgetrs) ("N", &nu, &mu2, (doubleC *) ptr->IN1F, &nu,
				ptr->ipiv, (doubleC *) ptr->IN2, &nu, &info,
				1);
		  for (i = 0; i < (mu2 * nu); i++)
		    {
		      *(ptr->yrT + i) = *(ptr->IN2 + 2 * i);
		      *(ptr->yiT + i) = -(*(ptr->IN2 + (2 * i) + 1));
		    }
		  scicos_mtran (ptr->yrT, mu1, yr, mu2, mu1, mu2);
		  scicos_mtran (ptr->yiT, mu1, yi, mu2, mu1, mu2);
		  return;
		}
	    }
	}
      rcond = pow (EPS, 0.5);
      for (i = 0; i < mu1; i++)
	*(ptr->jpvt + i) = 0;
      C2F (zlacpy) ("F", &nu, &mu2, (doubleC *) ptr->IN2, &nu,
		    (doubleC *) ptr->IN2X, &l, 1);
      nsp_ctrlpack_zgelsy1 (&nu, &mu1, &mu2, (doubleC *) ptr->IN1, &nu,
			    (doubleC *) ptr->IN2X, &l, ptr->jpvt, &rcond,
			    ptr->rank, (doubleC *) ptr->dwork, &lw,
			    ptr->iwork, &info);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
      for (i = 0; i < (l * mu2); i++)
	{
	  *(ptr->yrT + i) = *(ptr->IN2X + 2 * i);
	  *(ptr->yiT + i) = -(*(ptr->IN2X + (2 * i) + 1));
	}
      scicos_mtran (ptr->yrT, l, yr, mu2, mu1, mu2);
      scicos_mtran (ptr->yiT, l, yi, mu2, mu1, mu2);
    }
  return;
 free:
 err:
  st = (void **) ptr;
  /* 15 is the number of elements of mat_bksl_struct */
  for (i = 0; i < 15; i++)
    {
      /* free non null pointers */
      if (*st != NULL)
	scicos_free (*st);
      st++;
    }
  scicos_free (ptr);
}
