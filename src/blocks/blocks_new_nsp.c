/* Nsp
 * Copyright (C) 2007-2011 Ramine Nikoukhah (Inria) 
 *               See the note at the end of banner
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * 
 * Scicos blocks copyrighted GPL in this version by Ramine Nikoukhah
 * Some blocks have specific authors which are named in the code. 
 * 
 *--------------------------------------------------------------------------*/

#define NEW_GRAPHICS

#include <nsp/nsp.h>
#include <nsp/objects.h>
#ifdef NEW_GRAPHICS
#include <nsp/graphics-new/Graphics.h> 
#include <nsp/objs3d.h>
#include <nsp/axes.h>
#include <nsp/figuredata.h>
#include <nsp/figure.h>
#include <nsp/qcurve.h>
#include <nsp/grstring.h>
#include <nsp/compound.h>
#include <nsp/qcurve.h>
#else 
#include <nsp/graphics-old/Graphics.h> 
#endif 
#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"

/* should be replaced by new in the future */
extern int nsp_plot2d_old(BCG *Xgc,double x[],double y[],int *n1,int *n2,
		      int style[],char *strflag,const char *legend,
		      int leg_pos,double brect[],int aaint[]);

/* to be moved elsewhere XXXX  */

#if WIN32
extern double asinh (double x);
extern double acosh (double x);
extern double atanh (double x);
#endif

/*
 * utility to set wid as the current graphic window
 */

BCG *scicos_set_win (int wid, int *oldwid)
{
  BCG *Xgc;
#ifdef  NEW_GRAPHICS 
  if ((Xgc = window_list_get_first ()) != NULL)
#else 
  if ((Xgc = window_list_get_first_old ()) != NULL)
#endif 
    {
      *oldwid = Xgc->graphic_engine->xget_curwin ();
      if (*oldwid != wid)
	{
	  Xgc->graphic_engine->xset_curwin (Max (wid, 0), TRUE);
#ifdef  NEW_GRAPHICS 
	  Xgc = window_list_get_first ();
#else
	  Xgc = window_list_get_first_old ();
#endif
	}
    }
  else
    {
#ifdef  NEW_GRAPHICS 
      Xgc = set_graphic_window (Max (wid, 0));
#else 
      Xgc = set_graphic_window_old(Max (wid, 0));
#endif 
    }
  return Xgc;
}




void scicos_absolute_value_block (scicos_block * block, int flag)
{
  int i, j;
  switch (flag)
    {
    case 1:
      if (block->ng > 0)
	{
	  for (i = 0; i < block->insz[0]; ++i)
	    {
	      if (scicos_get_phase_simulation () == 1)
		{
		  if (block->inptr[0][i] < 0)
		    {
		      j = 2;
		    }
		  else
		    {
		      j = 1;
		    }
		}
	      else
		{
		  j = block->mode[i];
		}
	      if (j == 1)
		{
		  block->outptr[0][i] = block->inptr[0][i];
		}
	      else
		{
		  block->outptr[0][i] = -block->inptr[0][i];
		}
	    }
	}
      else
	{
	  for (i = 0; i < block->insz[0]; ++i)
	    {
	      if (block->inptr[0][i] < 0)
		{
		  block->outptr[0][i] = -block->inptr[0][i];
		}
	      else
		{
		  block->outptr[0][i] = block->inptr[0][i];
		}
	    }
	}
      break;
    case 9:
      for (i = 0; i < block->insz[0]; ++i)
	{
	  block->g[i] = block->inptr[0][i];
	  if (scicos_get_phase_simulation () == 1)
	    {
	      if (block->g[i] < 0)
		{
		  block->mode[i] = 2;
		}
	      else
		{
		  block->mode[i] = 1;
		}
	    }
	}
    }
}



void scicos_acos_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = acos (block->inptr[0][j]);
	}
    }
}

void scicos_acosh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = acosh (block->inptr[0][j]);
	}
    }
}

void scicos_asin_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = asin (block->inptr[0][j]);
	}
    }
}

void scicos_asinh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = asinh (block->inptr[0][j]);
	}
    }
}

void scicos_atan_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = atan (block->inptr[0][j]);
	}
    }
}

void scicos_atanh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = atanh (block->inptr[0][j]);
	}
    }
}


void scicos_tanh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = tanh (block->inptr[0][j]);
	}
    }
}


void scicos_tan_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = tan (block->inptr[0][j]);
	}
    }
}


void scicos_sin_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = sin (block->inptr[0][j]);
	}
    }
}

void scicos_sinh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = sinh (block->inptr[0][j]);
	}
    }
}



void scicos_backlash_block (scicos_block * block, int flag)
{
  double *rw, t;
  if (flag == 4)
    {				/* the workspace is used to store previous values */
      if ((*block->work = scicos_malloc (sizeof (double) * 4)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      rw = *block->work;
      t = scicos_get_scicos_time ();
      rw[0] = t;
      rw[1] = t;
      rw[2] = block->rpar[0];
      rw[3] = block->rpar[0];
    }
  else if (flag == 5)
    {
      scicos_free (*block->work);
    }
  else if (flag == 1)
    {
      rw = *block->work;
      t = scicos_get_scicos_time ();
      if (t > rw[1])
	{
	  rw[0] = rw[1];
	  rw[2] = rw[3];
	}
      rw[1] = t;
      if (block->inptr[0][0] > rw[2] + block->rpar[1] / 2)
	{
	  rw[3] = block->inptr[0][0] - block->rpar[1] / 2;
	}
      else if (block->inptr[0][0] < rw[2] - block->rpar[1] / 2)
	{
	  rw[3] = block->inptr[0][0] + block->rpar[1] / 2;
	}
      else
	{
	  rw[3] = rw[2];
	}
      block->outptr[0][0] = rw[3];
    }
  else if (flag == 9)
    {
      rw = *block->work;
      t = scicos_get_scicos_time ();
      if (t > rw[1])
	{
	  block->g[0] = block->inptr[0][0] - block->rpar[1] / 2 - rw[3];
	  block->g[1] = block->inptr[0][0] + block->rpar[1] / 2 - rw[3];
	}
      else
	{
	  block->g[0] = block->inptr[0][0] - block->rpar[1] / 2 - rw[2];
	  block->g[1] = block->inptr[0][0] + block->rpar[1] / 2 - rw[2];
	}
    }
}

void scicos_cos_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = cos (block->inptr[0][j]);
	}
    }
}

void scicos_cosh_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = cosh (block->inptr[0][j]);
	}
    }
}

void scicos_deadband_block (scicos_block * block, int flag)
{				/* rpar[0]:upper limit,  rpar[1]:lower limit */
  if (flag == 1)
    {
      if (scicos_get_phase_simulation () == 1 || block->ng == 0)
	{
	  if (*block->inptr[0] >= block->rpar[0])
	    {
	      block->outptr[0][0] = *block->inptr[0] - block->rpar[0];
	    }
	  else if (*block->inptr[0] <= block->rpar[1])
	    {
	      block->outptr[0][0] = *block->inptr[0] - block->rpar[1];
	    }
	  else
	    {
	      block->outptr[0][0] = 0.0;
	    }
	}
      else
	{
	  if (block->mode[0] == 1)
	    {
	      block->outptr[0][0] = *block->inptr[0] - block->rpar[0];
	    }
	  else if (block->mode[0] == 2)
	    {
	      block->outptr[0][0] = *block->inptr[0] - block->rpar[1];
	    }
	  else
	    {
	      block->outptr[0][0] = 0.0;
	    }
	}
    }
  else if (flag == 9)
    {
      block->g[0] = *block->inptr[0] - (block->rpar[0]);
      block->g[1] = *block->inptr[0] - (block->rpar[1]);
      if (scicos_get_phase_simulation () == 1)
	{
	  if (block->g[0] >= 0)
	    {
	      block->mode[0] = 1;
	    }
	  else if (block->g[1] <= 0)
	    {
	      block->mode[0] = 2;
	    }
	  else
	    {
	      block->mode[0] = 3;
	    }
	}
    }
}


void scicos_deriv_block (scicos_block * block, int flag)
{
  double *rw;
  double t, dt;
  int i;
  if (flag == 4)
    {				/* the workspace is used to store previous values */
      if ((*block->work =
	   scicos_malloc (sizeof (double) * 2 * (1 + block->insz[0]))) ==
	  NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      rw = *block->work;
      t = scicos_get_scicos_time ();
      rw[0] = t;
      rw[1] = t;
      for (i = 0; i < block->insz[0]; ++i)
	{
	  rw[2 + 2 * i] = 0;
	  rw[3 + 2 * i] = 0;
	}
    }
  else if (flag == 5)
    {
      scicos_free (*block->work);
    }
  else if (flag == 1)
    {
      rw = *block->work;
      t = scicos_get_scicos_time ();
      if (t > rw[1])
	{
	  rw[0] = rw[1];
	  for (i = 0; i < block->insz[0]; ++i)
	    {
	      rw[2 + 2 * i] = rw[3 + 2 * i];
	    }
	}
      rw[1] = t;
      for (i = 0; i < block->insz[0]; ++i)
	{
	  rw[3 + 2 * i] = block->inptr[0][i];
	}
      dt = rw[1] - rw[0];

      if (dt != 0.0)
	{
	  for (i = 0; i < block->insz[0]; ++i)
	    block->outptr[0][i] = (rw[3 + 2 * i] - rw[2 + 2 * i]) / dt;
	}
    }
}


void scicos_extractor_block (scicos_block * block, int flag)
{
  int i, j;
  if (flag == 1)
    {
      for (i = 0; i < block->nipar; ++i)
	{
	  j = block->ipar[i] - 1;
	  if (j < 0)
	    j = 0;
	  if (j >= block->insz[0])
	    j = block->insz[0] - 1;
	  block->outptr[0][i] = block->inptr[0][j];
	}
    }
}


void scicos_gainblk_block (scicos_block * block, int flag)
{
  int i, un = 1;
  if (block->nrpar == 1)
    {
      for (i = 0; i < block->insz[0]; ++i)
	{
	  block->outptr[0][i] = block->rpar[0] * block->inptr[0][i];
	}
    }
  else
    {
      nsp_calpack_dmmul (block->rpar, &block->outsz[0], block->inptr[0],
			 &block->insz[0], block->outptr[0], &block->outsz[0],
			 &block->outsz[0], &block->insz[0], &un);
    }
}




void scicos_time_delay_block (scicos_block * block, int flag)
{				/*  rpar[0]=delay, rpar[1]=init value, ipar[0]=buffer length */
  double *pw, del, t, td;
  int *iw;
  int i, j, k;
  if (flag == 4)
    {				/* the workspace is used to store previous values */
      if ((*block->work =
	   scicos_malloc (sizeof (int) + sizeof (double) *
			  block->ipar[0] * (1 + block->insz[0]))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      pw = *block->work;
      pw[0] = -block->rpar[0] * block->ipar[0];
      for (i = 1; i < block->ipar[0]; i++)
	{
	  pw[i] = pw[i - 1] + block->rpar[0];
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[i + block->ipar[0] * j] = block->rpar[1];
	    }
	}
      iw = (int *) (pw + block->ipar[0] * (1 + block->insz[0]));
      *iw = 0;
    }
  else if (flag == 5)
    {
      scicos_free (*block->work);
    }
  else if (flag == 0 || flag == 2)
    {
      if (flag == 2)
	scicos_do_cold_restart ();
      pw = *block->work;
      iw = (int *) (pw + block->ipar[0] * (1 + block->insz[0]));
      t = scicos_get_scicos_time ();
      td = t - block->rpar[0];
      if (td < pw[*iw])
	{
	  Sciprintf ("delayed time=%f but last stored time=%f \r\n", td,
		     pw[*iw]);
	  Sciprintf
	    ("Consider increasing the length of buffer in delay block \r\n");
	}

      if (t > pw[(block->ipar[0] + *iw - 1) % block->ipar[0]])
	{
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[*iw + block->ipar[0] * j] = block->inptr[0][j - 1];
	    }
	  pw[*iw] = t;
	  /*sciprint("**time is %f. I put %f, in %d \r\n", t,block->inptr[0][0],*iw); */
	  *iw = (*iw + 1) % block->ipar[0];

	}
      else
	{
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[(block->ipar[0] + *iw - 1) % block->ipar[0] +
		 block->ipar[0] * j] = block->inptr[0][j - 1];
	    }
	  pw[(block->ipar[0] + *iw - 1) % block->ipar[0]] = t;
	  /*sciprint("**time is %f. I put %f, in %d \r\n", t,block->inptr[0][0],*iw); */

	}

    }
  else if (flag == 1)
    {
      pw = *block->work;
      iw = (int *) (pw + block->ipar[0] * (1 + block->insz[0]));
      t = scicos_get_scicos_time ();
      td = t - block->rpar[0];

      i = 0;
      j = block->ipar[0] - 1;

      while (j - i > 1)
	{
	  k = (i + j) / 2;
	  if (td < pw[(k + *iw) % block->ipar[0]])
	    {
	      j = k;
	    }
	  else if (td > pw[(k + *iw) % block->ipar[0]])
	    {
	      i = k;
	    }
	  else
	    {
	      i = k;
	      j = k;
	      break;
	    }
	}
      i = (i + *iw) % block->ipar[0];
      j = (j + *iw) % block->ipar[0];
      del = pw[j] - pw[i];
      /*sciprint("time is %f. interpolating %d and %d, i.e. %f, %f\r\n", t,i,j,pw[i],pw[j]); */
      if (del != 0.0)
	{
	  for (k = 1; k < block->insz[0] + 1; k++)
	    {
	      block->outptr[0][k - 1] =
		((pw[j] - td) * pw[i + block->ipar[0] * k] +
		 (td - pw[i]) * pw[j + block->ipar[0] * k]) / del;
	    }
	}
      else
	{
	  for (k = 1; k < block->insz[0] + 1; k++)
	    {
	      block->outptr[0][k - 1] = pw[i + block->ipar[0] * k];
	    }
	}
    }
}



void scicos_variable_delay_block (scicos_block * block, int flag)
{				/*  rpar[0]=max delay, rpar[1]=init value, ipar[0]=buffer length */
  double *pw, del, t, td;
  int *iw;
  int i, j, k;
  if (flag == 4)
    {				/* the workspace is used to store previous values */
      if ((*block->work =
	   scicos_malloc (sizeof (int) + sizeof (double) *
			  block->ipar[0] * (1 + block->insz[0]))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      pw = *block->work;
      pw[0] = -block->rpar[0] * block->ipar[0];
      for (i = 1; i < block->ipar[0]; i++)
	{
	  pw[i] = pw[i - 1] + block->rpar[0];
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[i + block->ipar[0] * j] = block->rpar[1];
	    }
	}
      iw = (int *) (pw + block->ipar[0] * (1 + block->insz[0]));
      *iw = 0;
    }
  else if (flag == 5)
    {
      scicos_free (*block->work);
    }
  else if (flag == 1)
    {
      if (scicos_get_phase_simulation () == 1)
	scicos_do_cold_restart ();
      pw = *block->work;
      iw = (int *) (pw + block->ipar[0] * (1 + block->insz[0]));
      t = scicos_get_scicos_time ();
      del = Min (Max (0, block->inptr[1][0]), block->rpar[0]);
      td = t - del;
      if (td < pw[*iw])
	{
	  sciprint ("delayed time=%f but last stored time=%f \r\n", td,
		    pw[*iw]);
	  sciprint
	    ("Consider increasing the length of buffer in variable delay block\r\n");
	}
      if (t > pw[(block->ipar[0] + *iw - 1) % block->ipar[0]])
	{
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[*iw + block->ipar[0] * j] = block->inptr[0][j - 1];
	    }
	  pw[*iw] = t;
	  *iw = (*iw + 1) % block->ipar[0];
	}
      else
	{
	  for (j = 1; j < block->insz[0] + 1; j++)
	    {
	      pw[(block->ipar[0] + *iw - 1) % block->ipar[0] +
		 block->ipar[0] * j] = block->inptr[0][j - 1];
	    }
	  pw[(block->ipar[0] + *iw - 1) % block->ipar[0]] = t;
	}

      i = 0;
      j = block->ipar[0] - 1;

      while (j - i > 1)
	{
	  k = (i + j) / 2;
	  if (td < pw[(k + *iw) % block->ipar[0]])
	    {
	      j = k;
	    }
	  else if (td > pw[(k + *iw) % block->ipar[0]])
	    {
	      i = k;
	    }
	  else
	    {
	      i = k;
	      j = k;
	      break;
	    }
	}
      i = (i + *iw) % block->ipar[0];
      j = (j + *iw) % block->ipar[0];
      del = pw[j] - pw[i];
      if (del != 0.0)
	{
	  for (k = 1; k < block->insz[0] + 1; k++)
	    {
	      block->outptr[0][k - 1] =
		((pw[j] - td) * pw[i + block->ipar[0] * k] +
		 (td - pw[i]) * pw[j + block->ipar[0] * k]) / del;
	    }
	}
      else
	{
	  for (k = 1; k < block->insz[0] + 1; k++)
	    {
	      block->outptr[0][k - 1] = pw[i + block->ipar[0] * k];
	    }
	}
    }
}


void scicos_step_func_block (scicos_block * block, int flag)
{
  int i;
  if (flag == 1 && block->nevprt == 1)
    {
      for (i = 0; i < block->outsz[0]; ++i)
	{
	  block->outptr[0][i] = block->rpar[block->outsz[0] + i];
	}
    }
  else if (flag == 4)
    {
      for (i = 0; i < block->outsz[0]; ++i)
	{
	  block->outptr[0][i] = block->rpar[i];
	}
    }
}



void scicos_signum_block (scicos_block * block, int flag)
{
  int i, j;
  if (flag == 1)
    {
      for (i = 0; i < block->insz[0]; ++i)
	{
	  if (scicos_get_phase_simulation () == 1 || block->ng == 0)
	    {
	      if (block->inptr[0][i] < 0)
		{
		  j = 2;
		}
	      else if (block->inptr[0][i] > 0)
		{
		  j = 1;
		}
	      else
		{
		  j = 0;
		}
	    }
	  else
	    {
	      j = block->mode[i];
	    }
	  if (j == 1)
	    {
	      block->outptr[0][i] = 1.0;
	    }
	  else if (j == 2)
	    {
	      block->outptr[0][i] = -1.0;
	    }
	  else
	    {
	      block->outptr[0][i] = 0.0;
	    }
	}
    }
  else if (flag == 9)
    {
      for (i = 0; i < block->insz[0]; ++i)
	{
	  block->g[i] = block->inptr[0][i];
	  if (scicos_get_phase_simulation () == 1)
	    {
	      if (block->g[i] < 0)
		{
		  block->mode[i] = 2;
		}
	      else
		{
		  block->mode[i] = 1;
		}
	    }
	}
    }
}


void scicos_summation_block (scicos_block * block, int flag)
{
  int j, k;
  if (flag == 1)
    {
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 0.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][0] = block->outptr[0][0] + block->inptr[0][j];
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 0.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->ipar[k] > 0)
		    {
		      block->outptr[0][j] =
			block->outptr[0][j] + block->inptr[k][j];
		    }
		  else
		    {
		      block->outptr[0][j] =
			block->outptr[0][j] - block->inptr[k][j];
		    }
		}
	    }
	}
    }
}


void scicos_switch2_block (scicos_block * block, int flag)
{
  int i = 0, j, phase;
  if (flag == 1)
    {
      phase = scicos_get_phase_simulation ();
      if (phase == 1)
	{
	  i = 2;
	  if (*block->ipar == 0)
	    {
	      if (*block->inptr[1] >= *block->rpar)
		i = 0;
	    }
	  else if (*block->ipar == 1)
	    {
	      if (*block->inptr[1] > *block->rpar)
		i = 0;
	    }
	  else
	    {
	      if (*block->inptr[1] != *block->rpar)
		i = 0;
	    }
	}
      else
	{
	  if (block->mode[0] == 1)
	    {
	      i = 0;
	    }
	  else if (block->mode[0] == 2)
	    {
	      i = 2;
	    }
	}
      for (j = 0; j < block->insz[0]; j++)
	{
	  block->outptr[0][j] = block->inptr[i][j];
	}
    }
  else if (flag == 9)
    {
      phase = scicos_get_phase_simulation ();
      block->g[0] = *block->inptr[1] - (*block->rpar);
      if (phase == 1)
	{
	  i = 2;
	  if (*block->ipar == 0)
	    {
	      if (block->g[0] >= 0.0)
		i = 0;
	    }
	  else if (*block->ipar == 1)
	    {
	      if (block->g[0] > 0.0)
		i = 0;
	    }
	  else
	    {
	      if (block->g[0] != 0.0)
		i = 0;
	    }
	  if (i == 0)
	    {
	      block->mode[0] = 1;
	    }
	  else
	    {
	      block->mode[0] = 2;
	    }
	}
    }
}



void scicos_satur_block (scicos_block * block, int flag)
{				/* rpar[0]:upper limit,  rpar[1]:lower limit */
  if (flag == 1)
    {
      if (scicos_get_phase_simulation () == 1 || block->ng == 0)
	{
	  if (*block->inptr[0] >= block->rpar[0])
	    {
	      block->outptr[0][0] = block->rpar[0];
	    }
	  else if (*block->inptr[0] <= block->rpar[1])
	    {
	      block->outptr[0][0] = block->rpar[1];
	    }
	  else
	    {
	      block->outptr[0][0] = block->inptr[0][0];
	    }
	}
      else
	{
	  if (block->mode[0] == 1)
	    {
	      block->outptr[0][0] = block->rpar[0];
	    }
	  else if (block->mode[0] == 2)
	    {
	      block->outptr[0][0] = block->rpar[1];
	    }
	  else
	    {
	      block->outptr[0][0] = block->inptr[0][0];
	    }
	}
    }
  else if (flag == 9)
    {
      block->g[0] = *block->inptr[0] - (block->rpar[0]);
      block->g[1] = *block->inptr[0] - (block->rpar[1]);
      if (scicos_get_phase_simulation () == 1)
	{
	  if (block->g[0] >= 0)
	    {
	      block->mode[0] = 1;
	    }
	  else if (block->g[1] <= 0)
	    {
	      block->mode[0] = 2;
	    }
	  else
	    {
	      block->mode[0] = 3;
	    }
	}
    }
}


void scicos_logicalop_block (scicos_block * block, int flag)
{
  int i, j, k, l;
  i = block->ipar[0];
  switch (i)
    {
    case 0:
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 1.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      if (block->inptr[0][j] <= 0)
		{
		  block->outptr[0][0] = 0.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 1.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->inptr[k][j] <= 0)
		    {
		      block->outptr[0][j] = 0.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 1:
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 0.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      if (block->inptr[0][j] > 0)
		{
		  block->outptr[0][0] = 1.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 0.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->inptr[k][j] > 0)
		    {
		      block->outptr[0][j] = 1.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 2:
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 0.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      if (block->inptr[0][j] <= 0)
		{
		  block->outptr[0][0] = 1.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 0.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->inptr[k][j] <= 0)
		    {
		      block->outptr[0][j] = 1.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 3:
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 1.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      if (block->inptr[0][j] > 0)
		{
		  block->outptr[0][0] = 0.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 1.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->inptr[k][j] > 0)
		    {
		      block->outptr[0][j] = 0.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 4:
      if (block->nin == 1)
	{
	  l = 0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      if (block->inptr[0][j] > 0)
		{
		  l = (l + 1) % 2;
		}
	    }
	  block->outptr[0][0] = (double) l;
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      l = 0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->inptr[k][j] > 0)
		    {
		      l = (l + 1) % 2;
		    }
		}
	      block->outptr[0][j] = (double) l;
	    }
	}
      break;

    case 5:
      for (j = 0; j < block->insz[0]; j++)
	{
	  if (block->inptr[0][j] > 0)
	    {
	      block->outptr[0][j] = 0.0;
	    }
	  else
	    {
	      block->outptr[0][j] = 1.0;
	    }
	}
    }
}


void scicos_multiplex_block (scicos_block * block, int flag)
{
  int i, j, k;
  if (block->nin == 1)
    {
      k = 0;
      for (i = 0; i < block->nout; ++i)
	{
	  for (j = 0; j < block->outsz[i]; ++j)
	    {
	      block->outptr[i][j] = block->inptr[0][k];
	      ++k;
	    }
	}
    }
  else
    {
      k = 0;
      for (i = 0; i < block->nin; ++i)
	{
	  for (j = 0; j < block->insz[i]; ++j)
	    {
	      block->outptr[0][k] = block->inptr[i][j];
	      ++k;
	    }
	}
    }
}


void scicos_hystheresis_block (scicos_block * block, int flag)
{
  if (flag == 1)
    {
      if (scicos_get_phase_simulation () == 1)
	{
	  if (*block->inptr[0] >= block->rpar[0])
	    {
	      block->outptr[0][0] = block->rpar[2];
	    }
	  else if (*block->inptr[0] <= block->rpar[1])
	    {
	      block->outptr[0][0] = block->rpar[3];
	    }
	}
      else
	{
	  if (block->mode[0] < 2)
	    {
	      block->outptr[0][0] = block->rpar[3];
	    }
	  else
	    {
	      block->outptr[0][0] = block->rpar[2];
	    }
	}
    }
  else if (flag == 9)
    {
      block->g[0] = *block->inptr[0] - (block->rpar[0]);
      block->g[1] = *block->inptr[0] - (block->rpar[1]);
      if (scicos_get_phase_simulation () == 1)
	{
	  if (block->g[0] >= 0)
	    {
	      block->mode[0] = 2;
	    }
	  else if (block->g[1] <= 0)
	    {
	      block->mode[0] = 1;
	    }
	}
    }
}



void scicos_ramp_block (scicos_block * block, int flag)
{
  double dt;
  if (flag == 1)
    {
      dt = scicos_get_scicos_time () - block->rpar[1];
      if (scicos_get_phase_simulation () == 1)
	{
	  if (dt > 0)
	    {
	      block->outptr[0][0] = block->rpar[2] + block->rpar[0] * dt;
	    }
	  else
	    {
	      block->outptr[0][0] = block->rpar[2];
	    }
	}
      else
	{
	  if (block->mode[0] == 1)
	    {
	      block->outptr[0][0] = block->rpar[2] + block->rpar[0] * dt;
	    }
	  else
	    {
	      block->outptr[0][0] = block->rpar[2];
	    }
	}
    }
  else if (flag == 9)
    {
      block->g[0] = scicos_get_scicos_time () - (block->rpar[1]);
      if (scicos_get_phase_simulation () == 1)
	{
	  if (block->g[0] >= 0)
	    {
	      block->mode[0] = 1;
	    }
	  else
	    {
	      block->mode[0] = 2;
	    }
	}
    }
}


void scicos_minmax_block (scicos_block * block, int flag)
{
  /*ipar[0]=1 -> min,  ipar[0]=2 -> max */
  int i, phase;
  double maxmin;
  phase = scicos_get_phase_simulation ();
  if (flag == 1)
    {
      if (block->nin == 1)
	{
	  if ((block->ng == 0) | (phase == 1))
	    {
	      maxmin = block->inptr[0][0];
	      for (i = 1; i < block->insz[0]; ++i)
		{
		  if (block->ipar[0] == 1)
		    {
		      if (block->inptr[0][i] < maxmin)
			maxmin = block->inptr[0][i];
		    }
		  else
		    {
		      if (block->inptr[0][i] > maxmin)
			maxmin = block->inptr[0][i];
		    }
		}
	    }
	  else
	    {
	      maxmin = block->inptr[0][block->mode[0] - 1];
	    }
	  block->outptr[0][0] = maxmin;

	}
      else if (block->nin == 2)
	{
	  for (i = 0; i < block->insz[0]; ++i)
	    {
	      if ((block->ng == 0) | (phase == 1))
		{
		  if (block->ipar[0] == 1)
		    {
		      block->outptr[0][i] =
			Min (block->inptr[0][i], block->inptr[1][i]);
		    }
		  else
		    {
		      block->outptr[0][i] =
			Max (block->inptr[0][i], block->inptr[1][i]);
		    }
		}
	      else
		{
		  block->outptr[0][i] = block->inptr[block->mode[0] - 1][i];
		}
	    }
	}
    }
  else if (flag == 9)
    {
      if (block->nin == 1)
	{
	  if (block->nin == 1)
	    {
	      if (phase == 2)
		{
		  for (i = 0; i < block->insz[0]; ++i)
		    {
		      if (i != block->mode[0] - 1)
			{
			  block->g[i] =
			    block->inptr[0][i] -
			    block->inptr[0][block->mode[0] - 1];
			}
		      else
			{
			  block->g[i] = 1.0;
			}
		    }
		}
	      else if (phase == 1)
		{
		  maxmin = block->inptr[0][0];
		  for (i = 1; i < block->insz[0]; ++i)
		    {
		      block->mode[0] = 1;
		      if (block->ipar[0] == 1)
			{
			  if (block->inptr[0][i] < maxmin)
			    {
			      maxmin = block->inptr[0][i];
			      block->mode[0] = i + 1;
			    }
			}
		      else
			{
			  if (block->inptr[0][i] > maxmin)
			    {
			      maxmin = block->inptr[0][i];
			      block->mode[0] = i + 1;
			    }
			}
		    }
		}
	    }
	}
      else if (block->nin == 2)
	{
	  for (i = 0; i < block->insz[0]; ++i)
	    {
	      block->g[i] = block->inptr[0][i] - block->inptr[1][i];
	      if (phase == 1)
		{
		  if (block->ipar[0] == 1)
		    {
		      if (block->g[i] > 0)
			{
			  block->mode[i] = 2;
			}
		      else
			{
			  block->mode[i] = 1;
			}
		    }
		  else
		    {
		      if (block->g[i] < 0)
			{
			  block->mode[i] = 2;
			}
		      else
			{
			  block->mode[i] = 1;
			}
		    }
		}
	    }
	}
    }
}


void scicos_modulo_count_block (scicos_block * block, int flag)
{
  if (flag == 1)
    {
      *block->outptr[0] = block->z[0];
    }
  else if (flag == 2)
    {
      block->z[0] = (1 + (int) block->z[0]) % (block->ipar[0]);
    }
}



void scicos_mswitch_block (scicos_block * block, int flag)
{
  int i, j = 0;
  i = block->ipar[1];
  if (i == 0)
    {
      if (*block->inptr[0] > 0)
	{
	  j = (int) floor (*block->inptr[0]);
	}
      else
	{
	  j = (int) ceil (*block->inptr[0]);
	}
    }
  else if (i == 1)
    {
      if (*block->inptr[0] > 0)
	{
	  j = (int) floor (*block->inptr[0] + .5);
	}
      else
	{
	  j = (int) ceil (*block->inptr[0] - .5);
	}
    }
  else if (i == 2)
    {
      j = (int) ceil (*block->inptr[0]);
    }
  else if (i == 3)
    {
      j = (int) floor (*block->inptr[0]);
    }
  j = j + 1 - block->ipar[0];
  j = Max (j, 1);
  j = Min (j, block->nin - 1);
  for (i = 0; i < block->insz[j]; i++)
    {
      block->outptr[0][i] = block->inptr[j][i];
    }
}


void scicos_product_block (scicos_block * block, int flag)
{
  int j, k;
  if (flag == 1)
    {
      if (block->nin == 1)
	{
	  block->outptr[0][0] = 1.0;
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][0] = block->outptr[0][0] * block->inptr[0][j];
	    }
	}
      else
	{
	  for (j = 0; j < block->insz[0]; j++)
	    {
	      block->outptr[0][j] = 1.0;
	      for (k = 0; k < block->nin; k++)
		{
		  if (block->ipar[k] > 0)
		    {
		      block->outptr[0][j] =
			block->outptr[0][j] * block->inptr[k][j];
		    }
		  else
		    {
		      if (block->inptr[k][j] == 0)
			{
			  scicos_set_block_error (-2);
			  return;
			}
		      else
			{
			  block->outptr[0][j] =
			    block->outptr[0][j] / block->inptr[k][j];
			}
		    }
		}
	    }
	}
    }
}

/*
 * rpar[0]=rising rate limit, rpar[1]=falling rate limit 
 */

void scicos_ratelimiter_block (scicos_block * block, int flag)
{
  double *pw, rate = 0.0, t;
  if (flag == 4)
    {				/* the workspace is used to store previous values */
      if ((*block->work = scicos_malloc (sizeof (double) * 4)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      pw = *block->work;
      pw[0] = 0.0;
      pw[1] = 0.0;
      pw[2] = 0.0;
      pw[3] = 0.0;
    }
  else if (flag == 5)
    {
      scicos_free (*block->work);
    }
  else if (flag == 1)
    {
      if (scicos_get_phase_simulation () == 1)
	scicos_do_cold_restart ();
      pw = *block->work;
      t = scicos_get_scicos_time ();
      if (t > pw[2])
	{
	  pw[0] = pw[2];
	  pw[1] = pw[3];
	  rate = (block->inptr[0][0] - pw[1]) / (t - pw[0]);
	}
      else if (t <= pw[2])
	{
	  if (t > pw[0])
	    {
	      rate = (block->inptr[0][0] - pw[1]) / (t - pw[0]);
	    }
	  else
	    {
	      rate = 0.0;
	    }
	}
      if (rate > block->rpar[0])
	{
	  block->outptr[0][0] = (t - pw[0]) * block->rpar[0] + pw[1];
	}
      else if (rate < block->rpar[1])
	{
	  block->outptr[0][0] = (t - pw[0]) * block->rpar[1] + pw[1];
	}
      else
	{
	  block->outptr[0][0] = block->inptr[0][0];
	}
      pw[2] = t;
      pw[3] = block->outptr[0][0];
    }
}

void scicos_integral_func_block (scicos_block * block, int flag)
{
  int i;
  if (flag == 0)
    {
      if (block->ng > 0)
	{
	  for (i = 0; i < block->nx; ++i)
	    {
	      if (block->mode[i] == 3)
		{
		  block->xd[i] = block->inptr[0][i];
		}
	      else
		{
		  block->xd[i] = 0.0;
		}
	    }
	}
      else
	{
	  for (i = 0; i < block->nx; ++i)
	    {
	      block->xd[i] = block->inptr[0][i];
	    }
	}
    }
  else if (flag == 1)
    {
      for (i = 0; i < block->nx; ++i)
	{
	  block->outptr[0][i] = block->x[i];
	}
    }
  else if (flag == 2 && block->nevprt == 1)
    {
      for (i = 0; i < block->nx; ++i)
	{
	  block->x[i] = block->inptr[1][i];
	}
    }
  else if (flag == 9)
    {
      for (i = 0; i < block->nx; ++i)
	{
	  if (block->mode[i] == 3)
	    {
	      block->g[i] =
		(block->x[i] - (block->rpar[0])) * (block->x[i] -
						    (block->rpar[1]));
	    }
	  else
	    {
	      block->g[i] = block->inptr[0][i];
	    }
	  if (scicos_get_phase_simulation () == 1)
	    {
	      if (block->inptr[0][i] >= 0 && block->x[i] >= block->rpar[0])
		{
		  block->mode[i] = 1;
		}
	      else if (block->inptr[0][i] <= 0
		       && block->x[i] <= block->rpar[1])
		{
		  block->mode[i] = 2;
		}
	      else
		{
		  block->mode[i] = 3;
		}
	    }
	}
    }
}

void scicos_evtvardly_block (scicos_block * block, int flag)
{
  if (flag == 3)
    {
      block->evout[0] = block->inptr[0][0];
    }
}


void scicos_relationalop_block (scicos_block * block, int flag)
{
  int i;
  i = block->ipar[0];
  if (flag == 1)
    {
      if ((block->ng != 0) & (scicos_get_phase_simulation () == 2))
	{
	  block->outptr[0][0] = block->mode[0] - 1.0;
	}
      else
	{
	  switch (i)
	    {
	    case 0:
	      if (block->inptr[0][0] == block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;

	    case 1:
	      if (block->inptr[0][0] != block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;
	    case 2:
	      if (block->inptr[0][0] < block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;
	    case 3:
	      if (block->inptr[0][0] <= block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;
	    case 4:
	      if (block->inptr[0][0] >= block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;
	    case 5:
	      if (block->inptr[0][0] > block->inptr[1][0])
		{
		  block->outptr[0][0] = 1.0;
		}
	      else
		{
		  block->outptr[0][0] = 0.0;
		}
	      break;
	    }
	}

    }
  else if (flag == 9)
    {
      block->g[0] = block->inptr[0][0] - block->inptr[1][0];
      if (scicos_get_phase_simulation () == 1)
	{
	  switch (i)
	    {
	    case 0:
	      if (block->inptr[0][0] == block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;

	    case 1:
	      if (block->inptr[0][0] != block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;
	    case 2:
	      if (block->inptr[0][0] < block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;
	    case 3:
	      if (block->inptr[0][0] <= block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;
	    case 4:
	      if (block->inptr[0][0] >= block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;
	    case 5:
	      if (block->inptr[0][0] > block->inptr[1][0])
		{
		  block->mode[0] = (int) 2.0;
		}
	      else
		{
		  block->mode[0] = (int) 1.0;
		}
	      break;
	    }
	}
    }
}


void scicos_bounce_ball_block (scicos_block * block, int flag)
{
  int nevprt, nx, *ipar;
  int *outsz;
  double *x, *xd, *rpar;
  double *g;
  int ng;
  int *jroot;

  int i1;
  double d1, d2, d3;

  static double a, b, c;
  static int i, j, k, n;
  static double s1, s2, s3, s4, xsi, *y1, *y2;

  /*     Scicos block simulator */
  /*     bouncing ball */
  /*     rpar(i): mass of ball i */
  /*     rpar(i+n): radius of ball i */
  /*     rpar(2n+1:2n+4); [xmin,xmax,ymin,ymax] */
  /*     x: [x1,x1',y1,y1',x2,x2',y2,y2',...,yn'] */
  /*     n:number of ball=ny1=ny2 */
  /*     y1: x-coord des balles */
  /*     y2: y-coord des balles */
  /*     ipar: storage de taille [nx(n-1)/2=ng]*2 */
  nevprt = block->nevprt;
  nx = block->nx;
  ipar = block->ipar;
  outsz = block->outsz;
  x = block->x;
  xd = block->xd;
  rpar = block->rpar;

  g = block->g;
  ng = block->ng;
  jroot = block->jroot;
  /* Parameter adjustments to index vectors as in Scilab (fortran) */
  --g;
  --ipar;
  --rpar;
  --x;
  --xd;
  y1 = block->outptr[0];
  y2 = block->outptr[1];
  --y2;
  --y1;
  --jroot;

  n = outsz[0];
  if (flag == 0)
    {
      c = rpar[(n << 1) + 6];
      i1 = n;
      for (i = 1; i <= i1; ++i)
	{
	  xd[((i - 1) << 2) + 1] = x[((i - 1) << 2) + 2];
	  xd[((i - 1) << 2) + 3] = x[((i - 1) << 2) + 4];
	  xd[((i - 1) << 2) + 2] = -c * x[((i - 1) << 2) + 2];
	  xd[((i - 1) << 2) + 4] = -rpar[(n << 1) + 5];
	}

    }
  else if (flag == 1)
    {
      i1 = n;
      for (i = 1; i <= i1; ++i)
	{
	  y1[i] = x[((i - 1) << 2) + 1];
	  y2[i] = x[((i - 1) << 2) + 3];
	}
    }
  else if (flag == 9)
    {
      i1 = ng - (n << 2);
      for (k = 1; k <= i1; ++k)
	{
	  i = ipar[((k - 1) << 1) + 1];
	  j = ipar[((k - 1) << 1) + 2];
	  d1 = x[((i - 1) << 2) + 1] - x[((j - 1) << 2) + 1];
	  d2 = x[((i - 1) << 2) + 3] - x[((j - 1) << 2) + 3];
	  d3 = rpar[i + n] + rpar[j + n];
	  g[k] = d1 * d1 + d2 * d2 - d3 * d3;
	}
      k = ng - (n << 2) + 1;
      i1 = n;
      for (i = 1; i <= i1; ++i)
	{
	  g[k] = x[((i - 1) << 2) + 3] - rpar[i + n] - rpar[(n << 1) + 3];
	  ++k;
	  g[k] = rpar[(n << 1) + 4] - x[((i - 1) << 2) + 3] - rpar[i + n];
	  ++k;
	  g[k] = x[((i - 1) << 2) + 1] - rpar[(n << 1) + 1] - rpar[i + n];
	  ++k;
	  g[k] = rpar[(n << 1) + 2] - rpar[i + n] - x[((i - 1) << 2) + 1];
	  ++k;
	}

    }
  else if (flag == 2 && nevprt < 0)
    {
      i1 = ng - (n << 2);
      for (k = 1; k <= i1; ++k)
	{
	  if (jroot[k] < 0)
	    {
	      i = ipar[((k - 1) << 1) + 1];
	      j = ipar[((k - 1) << 1) + 2];
	      s1 = x[((j - 1) << 2) + 1] - x[((i - 1) << 2) + 1];
	      s2 = -rpar[i] * s1 / rpar[j];
	      s3 = x[((j - 1) << 2) + 3] - x[((i - 1) << 2) + 3];
	      s4 = -rpar[i] * s3 / rpar[j];
	      a =
		rpar[i] * (s1 * s1 + s3 * s3) + rpar[j] * (s2 * s2 + s4 * s4);
	      b =
		rpar[i] * (s1 * x[((i - 1) << 2) + 2] +
			   s3 * x[((i - 1) << 2) + 4]) +
		rpar[j] * (s2 * x[((j - 1) << 2) + 2] +
			   s4 * x[((j - 1) << 2) + 4]);
	      xsi = -(b * 2. / a);
	      x[((i - 1) << 2) + 2] += s1 * xsi;
	      x[((j - 1) << 2) + 2] += s2 * xsi;
	      x[((i - 1) << 2) + 4] += s3 * xsi;
	      x[((j - 1) << 2) + 4] += s4 * xsi;
	    }
	}
      k = ng - (n << 2) + 1;
      i1 = n;
      for (i = 1; i <= i1; ++i)
	{
	  if (jroot[k] < 0)
	    {
	      x[((i - 1) << 2) + 4] = -x[((i - 1) << 2) + 4];
	    }
	  ++k;
	  if (jroot[k] < 0)
	    {
	      x[((i - 1) << 2) + 4] = -x[((i - 1) << 2) + 4];
	    }
	  ++k;
	  if (jroot[k] < 0)
	    {
	      x[((i - 1) << 2) + 2] = -x[((i - 1) << 2) + 2];
	    }
	  ++k;
	  if (jroot[k] < 0)
	    {
	      x[((i - 1) << 2) + 2] = -x[((i - 1) << 2) + 2];
	    }
	  ++k;
	}
    }
}


void scicos_bouncexy_block (scicos_block * block, int flag)
{
  char *str;
  BCG *Xgc = NULL;
  int c__1 = 1;
  int c_n1 = -1;
  int c__5 = 5;
  int c__0 = 0;
  int c__3 = 3;
  int nevprt = block->nevprt;
  double t;
  double *z__;
  int nz;
  double *rpar;
  int nrpar, *ipar, nipar;
  double *u, *y;
  int nu;

  static int cur = 0;
  static int c400 = 400;
  int i__1;

  static double rect[4];
  static double xmin, ymin, xmax, ymax;
  static int i__, n;
  static int on;
  static double zz[10];
  static char buf[40];
  static int wid, nax[4];

  /*     ipar(1) = win_num */
  /*     ipar(2) = mode : animated =0 fixed=1 */
  /*     ipar(3:3+nu-1) = colors of balls */

  /*     rpar(1)=xmin */
  /*     rpar(2)=xmax */
  /*     rpar(3)=ymin */
  /*     rpar(4)=ymax */
  nevprt = block->nevprt;
  nz = block->nz;
  nrpar = block->nrpar;
  nipar = block->nipar;
  nu = block->insz[0];
  z__ = block->z;
  rpar = block->rpar;
  ipar = block->ipar;
  u = block->inptr[0];
  y = block->inptr[1];
  t = scicos_get_scicos_time ();


  /* Parameter adjustments */
  --u;
  --y;
  --ipar;
  --rpar;
  --z__;

  /* Function Body */

  if (flag == 2)
    {
      wid = ipar[1];
      n = nu;
      Xgc = scicos_set_win (wid, &cur);
      Xgc->graphic_engine->xset_recording (Xgc, FALSE);
      rect[0] = xmin;
      rect[1] = ymin;
      rect[2] = xmax;
      rect[3] = ymax;
      nsp_plot2d_old (Xgc, rect, &rect[1], &c__1, &c__1, &c_n1, "030", buf, 0,
		      rect, nax);
      /*     draw new point */
      i__1 = nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  z__[(i__ - 1) * 6 + 1] = u[i__] - z__[(i__ - 1) * 6 + 3] / 2;
	  z__[(i__ - 1) * 6 + 2] = y[i__] + z__[(i__ - 1) * 6 + 4] / 2;
	}
      Xgc->graphic_engine->xset_pixmapclear (Xgc);
      Xgc->graphic_engine->scale->fillarcs (Xgc, &z__[1], &ipar[3], n);
      xmin = rpar[1];
      xmax = rpar[2];
      ymin = rpar[3];
      ymax = rpar[4];
      zz[0] = xmin;
      zz[1] = xmin;
      zz[2] = xmax;
      zz[3] = xmax;
      zz[4] = xmin;
      zz[5] = ymax;
      zz[6] = ymin;
      zz[7] = ymin;
      zz[8] = ymax;
      zz[9] = ymax;
      Xgc->graphic_engine->scale->drawpolylines (Xgc, zz, &zz[5], &c__1, c__1,
						 c__5);
      Xgc->graphic_engine->xset_show (Xgc);
      Xgc->graphic_engine->xset_recording (Xgc, TRUE);
    }
  else if (flag == 4)
    {
      wid = ipar[1];
      n = nu;
      xmin = rpar[1];
      xmax = rpar[2];
      ymin = rpar[3];
      ymax = rpar[4];
      nax[0] = 2;
      nax[1] = 10;
      nax[2] = 2;
      nax[3] = 10;
      Xgc = scicos_set_win (wid, &cur);
      Xgc->graphic_engine->xset_windowdim (Xgc, c400, c400);
      Xgc = scicos_set_win (wid, &cur);
      Xgc->graphic_engine->xset_recording (Xgc, FALSE);
      on = 1;
      Xgc->graphic_engine->xset_pixmapOn (Xgc, on);
      rect[0] = xmin;
      rect[1] = ymin;
      rect[2] = xmax;
      rect[3] = ymax;
      Xgc->graphic_engine->xset_usecolor (Xgc, c__1);
      Xgc->graphic_engine->xset_alufunction1 (Xgc, c__3);
      Xgc->graphic_engine->clearwindow (Xgc);
      Xgc->graphic_engine->tape_clean_plots (Xgc, wid);
      Xgc->graphic_engine->xset_thickness (Xgc, c__1);
      Xgc->graphic_engine->xset_dash (Xgc, c__0);
      nsp_plot2d_old (Xgc, rect, &rect[1], &c__1, &c__1, &c_n1, "030", buf, 0,
		      rect, nax);
      zz[0] = xmin;
      zz[1] = xmin;
      zz[2] = xmax;
      zz[3] = xmax;
      zz[4] = xmin;
      zz[5] = ymax;
      zz[6] = ymin;
      zz[7] = ymin;
      zz[8] = ymax;
      zz[9] = ymax;
      Xgc->graphic_engine->scale->drawpolylines (Xgc, zz, &zz[5], &c__1, c__1,
						 c__5);
      Xgc->graphic_engine->xset_show (Xgc);
      str = block->label;
      if (str != NULL && strlen (str) != 0 && strcmp (str, " ") != 0)
	Xgc->graphic_engine->setpopupname (Xgc, str);
      /* XXXXXXXXX C2F(sxevents)(); */
    }
}


/**
 * scicos_cscope_block:
 * @block: 
 * @flag: 
 * 
 * a scope:
 * new nsp graphics jpc 
 **/


typedef struct _cscope_ipar cscope_ipar;
struct _cscope_ipar
{
  /* n is the number of data to accumulate before redrawing */
  int wid, color_flag, n, type[8], wpos[2], wdim[2];
};

typedef struct _cscope_rpar cscope_rpar;
struct _cscope_rpar
{
  double dt, ymin, ymax, per;
};

typedef struct _cscope_data cscope_data;

struct _cscope_data
{
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspAxes *Axes;
  NspList *L;
};

static void scicos_cscope_axes_update(cscope_data *D,double t, double Ts,
				      double ymin,double ymax);

void scicos_cscope_block (scicos_block * block, int flag)
{
  char *str;
  BCG *Xgc;
  /* used to decode parameters by name */
  cscope_ipar *csi = (cscope_ipar *) block->ipar;
  cscope_rpar *csr = (cscope_rpar *) block->rpar;
  double t;
  int nu, cur = 0, k, wid;

  nu = Min (block->insz[0], 8); /* number of curves */
  t = scicos_get_scicos_time ();

  wid = (csi->wid == -1) ? 20000 + scicos_get_block_number () : csi->wid;
  
  if (flag == 2)
    {
      cscope_data *D = (cscope_data *) (*block->work);
      k = D->count;
      if (k > 0)
	{
	  if (csr->dt > 0.)
	    {
	      t = D->tlast + csr->dt;
	    }
	}
      D->count++;
      D->tlast = t;
      /* add nu points for time t, nu is the number of curves */
      nsp_oscillo_add_point (D->L, t, block->inptr[0], nu);
      if (  D->count % csi->n == 0 ) 
	{
	  /* redraw each csi->n accumulated points 
	   * first check if we need to change the xscale 
	   */
	  scicos_cscope_axes_update(D,t,csr->per,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cscope_data *D;
      NspList *L;
      /* XXX :
       * buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori.
       */
      int scopebs = 10000;
      /* create an axe with predefined limits */
      NspAxes *Axes =
	nsp_oscillo_obj (wid, nu , csi->type, scopebs, TRUE, -1, 1, &L);
      if (Axes == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (cscope_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (cscope_data *) (*block->work);
      D->Axes = Axes;
      D->L = L;
      D->count = 0;
      D->tlast = t;
      Xgc = scicos_set_win (wid, &cur);
      if (csi->wpos[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowpos (Xgc, csi->wpos[0],
					       csi->wpos[1]);
	}
      if (csi->wdim[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowdim (Xgc, csi->wdim[0],
					       csi->wdim[1]);
	}
      str = block->label;
      if (str != NULL && strlen (str) != 0 && strcmp (str, " ") != 0)
	Xgc->graphic_engine->setpopupname (Xgc, str);
    }
  else if (flag == 5)
    {
      cscope_data *D = (cscope_data *) (*block->work);
      scicos_free (D);
      /* Xgc = scicos_set_win(wid,&cur); */
    }
}

/* this function could certainly be replaced by the corresponding 
 * function present in axes.
 */

int scicos_cscope_get_bounds(NspList *L, double *bounds)
{
  double l_bounds[4];
  Cell *cloc = L->first ;
  if ( cloc == NULLCELL) 
    {
      bounds[0]=bounds[1]=0;
      bounds[2]=bounds[3]=0;
      return FALSE;
    }
  bounds[0]=bounds[1]=LARGEST_REAL;
  bounds[2]=bounds[3]=-LARGEST_REAL;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  NspGraphic *G= (NspGraphic *) cloc->O;
	  G->type->bounds(G,l_bounds);
	  if ( l_bounds[0] < bounds[0] ) 
	    bounds[0]= l_bounds[0];
	  if (  l_bounds[2] > bounds[2])
	    bounds[2]= l_bounds[2];
	  if ( l_bounds[1] < bounds[1] ) 
	    bounds[1]= l_bounds[1];
	  if (  l_bounds[3] > bounds[3])
	    bounds[3]= l_bounds[3];
	}
      cloc = cloc->next;
    }
  return TRUE;
}

static void scicos_cscope_axes_update(cscope_data *D,double t, double Ts,
				      double ymin,double ymax)
{
  double frect[4]={ Max(t-Ts,0) , ymin, t, ymax};
  int tag = FALSE;
  double bounds[4];
  if ( isinf(ymin) || isinf(ymax))
    {
      /* only usefull, if ymin or ymax is inf */
      tag = scicos_cscope_get_bounds(D->L,bounds);
    }
  if ( isinf(ymin) && tag == TRUE ) frect[1]= bounds[1];
  if ( isinf(ymax) && tag == TRUE ) frect[3]= bounds[3];
  if ( ~isinf(Ts) )
    {
      frect[0]= Max(0,t-Ts);
      frect[2]= t;
    }
  else
    {
      frect[0]= 0; /*XXX min of stored values */
      frect[2]= t;
    }
  memcpy(D->Axes->obj->frect->R,frect,4*sizeof(double));
  memcpy(D->Axes->obj->rect->R,frect,4*sizeof(double));
  D->Axes->obj->fixed = TRUE; 
}


/**
 * scicos_cscopxy_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

typedef struct _cscopxy_ipar cscopxy_ipar;
struct _cscopxy_ipar
{
  /* n is the number of data to accumulate before redrawing */
  int wid, color_flag, n, color, line_size, animed , wpos[2], wdim[2];
};

typedef struct _cscopxy_rpar cscopxy_rpar;
struct _cscopxy_rpar
{
  double xmin, xmax, ymin, ymax;
};

static void  scicos_cscopxy_add_point(NspList *L,const double *x,const double *y, int n);
static void scicos_cscopxy_axes_update(cscope_data *D,double xmin, double xmax,
				       double ymin,double ymax);

void scicos_cscopxy_block (scicos_block * block, int flag)
{
  int cur = 0, k,nu;
  char *str;
  BCG *Xgc;
  /* used to decode parameters by name */
  cscopxy_ipar *csi = (cscopxy_ipar *) block->ipar;
  cscopxy_rpar *csr = (cscopxy_rpar *) block->rpar;
  int nu1 = GetInPortRows (block, 1);/* number of curves */
  int nu2 = GetInPortRows (block, 2);/* number of curves */
  double t = scicos_get_scicos_time ();
  int wid = (csi->wid == -1) ? 20000 + scicos_get_block_number () : csi->wid;
  nu = Min(nu1,nu2);
  if (flag == 2)
    {
      
      double *u1 = GetRealInPortPtrs (block, 1);
      double *u2 = GetRealInPortPtrs (block, 2);
      cscope_data *D = (cscope_data *) (*block->work);
      D->count++;
      D->tlast = t;
      /* add nu points for time t, nu is the number of curves */
      scicos_cscopxy_add_point(D->L, u1, u2, nu);
      if (  D->count % csi->n == 0 ) 
	{
	  /* redraw each csi->n accumulated points 
	   * first check if we need to change the xscale 
	   */
	  scicos_cscopxy_axes_update(D,csr->xmin, csr->xmax,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cscope_data *D;
      NspList *L;
#define MAXXY 10
      int colors[MAXXY]; /* max number of curves ? */
      /* XXX :
       * buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori.
       */
      int scopebs = 10000;
      /* create an axe with predefined limits */
      NspAxes *Axes;
      nu = Min(nu,MAXXY);
      for ( k= 0 ; k < MAXXY ; k++) colors[k]=csi->color+k;
      Axes=nsp_oscillo_obj (wid, nu, colors, scopebs, TRUE, -1, 1, &L);
      if (Axes == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (cscope_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (cscope_data *) (*block->work);
      D->Axes = Axes;
      D->L = L;
      D->count = 0;
      D->tlast = t;
      Xgc = scicos_set_win (wid, &cur);
      if (csi->wpos[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowpos (Xgc, csi->wpos[0],
					       csi->wpos[1]);
	}
      if (csi->wdim[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowdim (Xgc, csi->wdim[0],
					       csi->wdim[1]);
	}
      str = block->label;
      if (str != NULL && strlen (str) != 0 && strcmp (str, " ") != 0)
	Xgc->graphic_engine->setpopupname (Xgc, str);
    }
  else if (flag == 5)
    {
      cscope_data *D = (cscope_data *) (*block->work);
      scicos_free (D);
      /* Xgc = scicos_set_win(wid,&cur); */
    }
}

static void  scicos_cscopxy_add_point(NspList *L,const double *x,const double *y, int n)
{
  int count =0;
  Cell *Loc = L->first;
  while ( Loc != NULLCELL ) 
    {
      if ( Loc->O != NULLOBJ )
	{ 
	  NspQcurve *curve =(NspQcurve *) Loc->O;
	  if ( count >= n ) return;
	  nsp_qcurve_addpt(curve,&x[count],&y[count],1);
	  count++;
	}
      Loc = Loc->next;
    }
}

static void scicos_cscopxy_axes_update(cscope_data *D,double xmin, double xmax,
				       double ymin,double ymax)
{
  double frect[4]={ xmin , ymin, xmax, ymax};
  int tag = FALSE;
  double bounds[4];
  if ( isinf(xmin) || isinf(xmax) || isinf(ymin) || isinf(ymax) )
    {
      /* only usefull, if some values are inf */
      tag = scicos_cscope_get_bounds(D->L,bounds);
    }
  if ( isinf(xmin) && tag == TRUE ) frect[0]= bounds[0];
  if ( isinf(xmax) && tag == TRUE ) frect[1]= bounds[1];
  if ( isinf(ymin) && tag == TRUE ) frect[2]= bounds[2];
  if ( isinf(ymax) && tag == TRUE ) frect[3]= bounds[3];
  memcpy(D->Axes->obj->frect->R,frect,4*sizeof(double));
  memcpy(D->Axes->obj->rect->R,frect,4*sizeof(double));
  D->Axes->obj->fixed = TRUE; 
}




void scicos_scalar2vector_block (scicos_block * block, int flag)
{
  int i;
  if (flag == 1)
    {
      for (i = 0; i < block->outsz[0]; ++i)
	{
	  block->outptr[0][i] = block->inptr[0][0];
	}
    }
}

void scicos_cstblk4_block (scicos_block * block, int flag)
{
  /*
   * Scicos block simulator
   * output a vector of constants out(i)=rpar(i)
   * rpar(1:nrpar) : given constants 
   */
  memcpy (block->outptr[0], block->rpar, block->nrpar * sizeof (double));
}


void scicos_transmit_or_zero_block (scicos_block * block, int flag)
{
  int j;
  if (flag == 1)
    {
      if (block->ipar[0] == 1)
	for (j = 0; j < block->insz[0]; j++)
	  {
	    block->outptr[0][j] = block->inptr[0][j];
	  }
    }
}


/* switch selected with ipar 
 *
 */

void scicos_mvswitch_block (scicos_block * block, int flag)
{
  int i, j = 0;
  j = Min (Max (block->ipar[0], 0), block->nin - 1);
  for (i = 0; i < block->insz[j]; i++)
    {
      block->outptr[0][i] = block->inptr[j][i];
    }
}

/*  Copyright INRIA
 *    Scicos block simulator
 *   continuous state space linear system simulator
 *   rpar(1:nx*nx)=A
 *   rpar(nx*nx+1:nx*nx+nx*nu)=B
 *   rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C
 *   rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D 
 */

void scicos_csslti4_block (scicos_block * block, int flag)
{
  int un = 1, lb, lc, ld;
  int nx = block->nx;
  double *x = block->x;
  double *xd = block->xd;
  double *rpar = block->rpar;
  double *y = block->outptr[0];
  double *u = block->inptr[0];
  int *outsz = block->outsz;
  int *insz = block->insz;

  lb = nx * nx;
  lc = lb + nx * insz[0];

  if (flag == 1 || flag == 6)
    {
      /* y=c*x+d*u     */
      ld = lc + nx * outsz[0];
      if (nx == 0)
	{
	  nsp_calpack_dmmul (&rpar[ld], outsz, u, insz, y, outsz, outsz, insz,
			     &un);
	}
      else
	{
	  nsp_calpack_dmmul (&rpar[lc], outsz, x, &nx, y, outsz, outsz, &nx,
			     &un);
	  nsp_calpack_dmmul1 (&rpar[ld], outsz, u, insz, y, outsz, outsz,
			      insz, &un);
	}
    }

  else if (flag == 0)
    {
      /* xd=a*x+b*u */
      nsp_calpack_dmmul (&rpar[0], &nx, x, &nx, xd, &nx, &nx, &nx, &un);
      nsp_calpack_dmmul1 (&rpar[lb], &nx, u, insz, xd, &nx, &nx, insz, &un);
    }
}

/*
 *  This is an old block but with new graphics (that's why 
 *  it is temporary here).
 * 
 *  ipar = [font, fontsize, color, win, nt, nd, ipar7 ]
 *     nt : total number of output digits 
 *     nd : number of rationnal part digits
 *     nu2: nu/ipar(7);
 * 
 *  z(6:6+nu*nu2)=value 
 *  z(1) is used to keep the pointer of graphic object 
 *  
 *  To be done: values could be moved to z(2) since we 
 *  do not use the z(2:5).
 *  some ipar values are not taken into account 
 * 
 *  Copyright: J.Ph Chancelier Enpc 
 */

static NspGrstring *scicos_affich2_getstring(NspCompound *C);
static void scicos_affich2_update(NspGrstring *S,const int form[], double *v,int m,int n);

int scicos_affich2_block (scicos_args_F0)
{
  NspGrstring **S= (NspGrstring **) &z__[0] ;
  --ipar;
  if (*flag__ == 1)
    {
      /* draw the string matrix */
      if ( *S != NULL) 
	{
	  scicos_affich2_update(*S,&ipar[5],u,ipar[7],*nu/ipar[7]);
	}
    }
  else if (*flag__ == 4)
    {
      int cb = Scicos->params.curblk -1;
      NspGraphic *Gr = Scicos->Blocks[cb].grobj;
      *S = NULL;
      if ( Gr != NULL && IsCompound((NspObject *) Gr))
	{
	  *S = scicos_affich2_getstring((NspCompound *)Gr);
	}
    }
  return 0;
}

static NspGrstring *scicos_affich2_getstring(NspCompound *C)
{
  NspGrstring *S;
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      S=scicos_affich2_getstring((NspCompound *) cloc->O);
	      if ( S != NULL) return S;
	    }
	  else if ( IsGrstring(cloc->O) )
	    {
	      return (NspGrstring *) cloc->O;
	    }
	}
      cloc = cloc->next;
    }
  return NULL;
}

static void scicos_affich2_update(NspGrstring *S,const int form[], double *v,int m,int n)
{
  int i,j, ok = FALSE;
  NspSMatrix *Str = S->obj->text;
  for (i = 0; i < Str->m ; i++)
    {
      char *st=S->obj->text->S[i];
      int k=0;
      char buf[128];
      for ( j= 0 ; j < n ; j++) 
	{
	  int kj =sprintf(buf+k, "%*.*f" , form[0], form[1], v[i+m*j]);
	  if ( kj > form[0]) 
	    {
	      kj = sprintf(buf+k,"%*s",form[0],"*");
	    }
	  k += kj;
	  if ( j != n-1) sprintf(buf+k," ");k++;
	}
      if ( strlen(st) != strlen(buf) )
	{
	  Sciprintf("Warning: buffer has wrong size\n");
	}
      if ( strcmp(st,buf) != 0 ) ok = TRUE;
      snprintf(st,strlen(st)+1,"%s",buf);
    }
  if ( ok )  nsp_graphic_invalidate((NspGraphic *) S);
}

/*
 *  This is an old block but with new graphics (that's why 
 *  it is temporary here).
 *  This block is only here for backward compatibility since 
 *  it is superseded by affich2.
 * 
 *  Copyright: J.Ph Chancelier Enpc 
 */

int scicos_affich_block (scicos_args_F0)
{
  NspGrstring **S= (NspGrstring **) &z__[0] ;
  --ipar;
  if (*flag__ == 1)
    {
      /* draw the string matrix */
      if ( *S != NULL) 
	{
	  scicos_affich2_update(*S,&ipar[5],u,1,1);
	}
    }
  else if (*flag__ == 4)
    {
      int cb = Scicos->params.curblk -1;
      NspGraphic *Gr = Scicos->Blocks[cb].grobj;
      *S = NULL;
      if ( Gr != NULL && IsCompound((NspObject *) Gr))
	{
	  *S = scicos_affich2_getstring((NspCompound *)Gr);
	}
    }
  return 0;
}

