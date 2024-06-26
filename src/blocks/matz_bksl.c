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
  double *IN2X;
  double *IN2;
} mat_bksl_struct;

void matz_bksl (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *u1r, *u1i;
  double *u2r, *u2i;
  double *yr, *yi;
  int mu, vu, wu;
  int nu1;
  int nu2;
  int info;
  int i, j, l, lw, lu, ij, k;
  /*int rw;*/
  mat_bksl_struct *ptr;
  double rcond, ANORM, EPS;
  vu = GetOutPortRows (block, 1);
  wu = GetOutPortCols (block, 1);
  mu = GetInPortRows (block, 1);
  nu1 = GetInPortCols (block, 1);
  nu2 = GetInPortCols (block, 2);
  u1r = GetRealInPortPtrs (block, 1);
  u1i = GetImagInPortPtrs (block, 1);
  u2r = GetRealInPortPtrs (block, 2);
  u2i = GetImagInPortPtrs (block, 2);
  yr = GetRealOutPortPtrs (block, 1);
  yi = GetImagOutPortPtrs (block, 1);
  l = max (mu, nu1);
  lw = max (2 * min (mu, nu1), nu1 + 1);
  lu = max (lw, min (mu, nu1) + nu2);
  lw = max (2 * nu1, min (mu, nu1) + lu);
  /*rw = 2 * nu1;*/
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
      if ((ptr->iwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * nu1)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->dwork =
	   (double *) scicos_malloc (sizeof (double) * 2 * lw)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->IN1F =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu * nu1))) ==
	  NULL)
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
      if ((ptr->IN1 =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu * nu1))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->IN1F);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->IN2X =
	   (double *) scicos_malloc (sizeof (double) * (2 * l * nu2))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->IN1);
	  scicos_free (ptr->IN1F);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr);
	  return;
	}
      if ((ptr->IN2 =
	   (double *) scicos_malloc (sizeof (double) * (2 * mu * nu2))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (ptr->IN2);
	  scicos_free (ptr->IN1);
	  scicos_free (ptr->IN1F);
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
      if ((ptr->IN2) != NULL)
	{
	  scicos_free (ptr->ipiv);
	  scicos_free (ptr->rank);
	  scicos_free (ptr->jpvt);
	  scicos_free (ptr->iwork);
	  scicos_free (ptr->IN1F);
	  scicos_free (ptr->IN1);
	  scicos_free (ptr->IN2X);
	  scicos_free (ptr->IN2);
	  scicos_free (ptr->dwork);
	  scicos_free (ptr);
	  return;
	}
    }

  else
    {
      ptr = *(_work);
      for (i = 0; i < (mu * nu1); i++)
	{
	  ptr->IN1[2 * i] = u1r[i];
	  ptr->IN1[2 * i + 1] = u1i[i];
	}
      for (i = 0; i < (mu * nu2); i++)
	{
	  ptr->IN2[2 * i] = u2r[i];
	  ptr->IN2[2 * i + 1] = u2i[i];
	}
      EPS = C2F (dlamch) ("e", 1L);
      ANORM =
	C2F (zlange) ("1", &mu, &nu1, (doubleC *) ptr->IN1, &mu, ptr->dwork,
		      1);
      if (mu == nu1)
	{
	  C2F (zlacpy) ("F", &mu, &nu1, (doubleC *) ptr->IN1, &mu,
			(doubleC *) ptr->IN1F, &mu, 1);
	  C2F (zgetrf) (&nu1, &nu1, (doubleC *) ptr->IN1F, &nu1, ptr->ipiv,
			&info);
	  rcond = 0;
	  if (info == 0)
	    {
	      C2F (zgecon) ("1", &nu1, (doubleC *) ptr->IN1F, &nu1, &ANORM,
			    &rcond, (doubleC *) ptr->dwork, ptr->iwork, &info,
			    1);
	      if (rcond > pow (EPS, 0.5))
		{
		  C2F (zgetrs) ("N", &nu1, &nu2, (doubleC *) ptr->IN1F, &nu1,
				ptr->ipiv, (doubleC *) ptr->IN2, &nu1, &info,
				1);
		  for (i = 0; i < (mu * nu2); i++)
		    {
		      *(yr + i) = *(ptr->IN2 + 2 * i);
		      *(yi + i) = *(ptr->IN2 + (2 * i) + 1);
		    }
		  return;
		}
	    }
	}
      rcond = pow (EPS, 0.5);
      for (i = 0; i < nu1; i++)
	*(ptr->jpvt + i) = 0;
      C2F (zlacpy) ("F", &mu, &nu2, (doubleC *) ptr->IN2, &mu,
		    (doubleC *) ptr->IN2X, &l, 1);
      nsp_ctrlpack_zgelsy1 (&mu, &nu1, &nu2, (doubleC *) ptr->IN1, &mu,
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
      k = 0;
      for (j = 0; j < wu; j++)
	{
	  for (i = 0; i < vu; i++)
	    {
	      ij = i + j * l;
	      *(yr + k) = *(ptr->IN2X + 2 * ij);
	      *(yi + k) = *(ptr->IN2X + (2 * ij) + 1);
	      k++;
	    }
	}
    }
}
