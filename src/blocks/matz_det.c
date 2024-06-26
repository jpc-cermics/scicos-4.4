# include "blocks.h"

typedef struct
{
  int *ipiv;
  double *wrk;
} mat_det_struct;

void matz_det (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *ur;
  double *yr;
  double *ui;
  double *yi;
  int nu;
  int info;
  int i;
  doubleC D, l;
  double A;
  mat_det_struct *mdet;

  nu = GetInPortRows (block, 1);
  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  yr = GetRealOutPortPtrs (block, 1);
  yi = GetImagOutPortPtrs (block, 1);
  /*init : initialization */
  if (flag == 4)

    {
      if ((*(_work) =
	   (mat_det_struct *) scicos_malloc (sizeof (mat_det_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  return;
	}
      mdet = *(_work);
      if ((mdet->ipiv = (int *) scicos_malloc (sizeof (int) * nu)) == NULL)
	{
	  set_block_error (-16);
	  scicos_free (mdet);
	  return;
	}
      if ((mdet->wrk =
	   (double *) scicos_malloc (sizeof (double) * (2 * nu * nu))) ==
	  NULL)
	{
	  set_block_error (-16);
	  scicos_free (mdet->ipiv);
	  scicos_free (mdet);
	  return;
	}
    }

  /* Terminaison */
  else if (flag == 5)
    {
      mdet = *(_work);
      if (mdet->wrk != NULL)
	{
	  scicos_free (mdet->ipiv);
	  scicos_free (mdet->wrk);
	  scicos_free (mdet);
	  return;
	}
    }

  else
    {
      mdet = *(_work);
      for (i = 0; i < (nu * nu); i++)
	{
	  mdet->wrk[2 * i] = ur[i];
	  mdet->wrk[2 * i + 1] = ui[i];
	}
      C2F (zgetrf) (&nu, &nu, (doubleC *) mdet->wrk, &nu, mdet->ipiv, &info);
      if (info != 0)
	{
	  if (flag != 6)
	    {
	      set_block_error (-7);
	      return;
	    }
	}
      D.r = 1;
      D.i = 0;
      for (i = 0; i < nu; i++)
	{
	  if ((*(mdet->ipiv + i)) != i + 1)
	    {
	      D.r = -D.r;
	      D.i = -D.i;
	    }
	  l.r = *(mdet->wrk + i * 2 * (nu + 1));
	  l.i = *(mdet->wrk + 1 + i * 2 * (nu + 1));
	  A = D.r;
	  D.r = D.r * l.r - D.i * l.i;
	  D.i = D.i * l.r + A * l.i;
	};
      *yr = D.r;
      *yi = D.i;
    }
}
