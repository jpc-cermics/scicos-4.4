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

#include <nsp/nsp.h>
#include <nsp/objects.h>
#include <nsp/graphics-new/Graphics.h> 
#include <nsp/objs3d.h>
#include <nsp/axes.h>
#include <nsp/figuredata.h>
#include <nsp/figure.h>
#include <nsp/qcurve.h>
#include <nsp/grstring.h>
#include <nsp/compound.h>
#include <nsp/grarc.h>
#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"

static NspAxes *nsp_oscillo_obj(int win,int ncurves,int style[],int width[],int bufsize,
				int yfree,double ymin,double ymax,
				nsp_qcurve_mode mode,NspList **Lc);

static int nsp_oscillo_add_point(NspList *L,double t,double period,const double *y, int n);

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
  if ((Xgc = window_list_get_first ()) != NULL)
    {
      *oldwid = Xgc->graphic_engine->xget_curwin ();
      if (*oldwid != wid)
	{
	  Xgc->graphic_engine->xset_curwin (Max (wid, 0), TRUE);
	  Xgc = window_list_get_first ();
	}
    }
  else
    {
      Xgc = set_graphic_window (Max (wid, 0));
    }
  Xgc->graphic_engine->xselgraphic(Xgc);
  
  return Xgc;
}




/**
 * scicos_absolute_value_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_absolute_value_block (scicos_block * block, int flag)
{
  int ng=GetNg(block);
  double *g=GetGPtrs(block);
  int *mode=GetModePtrs(block);
  double *u1=GetRealInPortPtrs(block,1);
  double *y1=GetRealOutPortPtrs(block,1);
  int i,side;
  int nxm=GetInPortRows(block,1)*GetInPortCols(block,1);
  switch(flag) 
    {
    case 1:
      for(i=0 ; i < nxm ; ++i) 
	{
	  side = (!areModesFixed(block) || ng==0) ?
	    ((u1[i]<0) ? 2 :1) : mode[i];
	  y1[i] = (side==1) ? u1[i] : -u1[i];
	}
      break;
    case 9:
      for( i=0 ; i < nxm ; ++i)
	{
	  g[i]=u1[i];
	  if ( !areModesFixed(block) ) 
	    {
	      mode[i]= (g[i]<0) ? 2 : 1;
	    }
	}
    }
}



/**
 * scicos_acos_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_acos_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = acos (u1[j]);
	}
    }
}

/**
 * scicos_acosh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_acosh_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = acosh (u1[j]);
	}
    }
}

/**
 * scicos_asin_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_asin_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = asin (u1[j]);
	}
    }
}

/**
 * scicos_asinh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_asinh_block (scicos_block * block, int flag)
{
  double *u1=GetRealInPortPtrs(block,1);
  double *y1=GetRealOutPortPtrs(block,1);
  int j;
  if (flag==1) 
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j]=asinh(u1[j]);
	}
    }
}

/**
 * scicos_atan_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_atan_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = atan (u1[j]);
	}
    }
}

/**
 * scicos_atanh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_atanh_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = atanh (u1[j]);
	}
    }
}


/**
 * scicos_tanh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_tanh_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = tanh (u1[j]);
	}
    }
}


/**
 * scicos_tan_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_tan_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = tan (u1[j]);
	}
    }
}


/**
 * scicos_sin_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_sin_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = sin (u1[j]);
	}
    }
}

/**
 * scicos_sinh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_sinh_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = sinh (u1[j]);
	}
    }
}



/**
 * scicos_backlash_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_backlash_block (scicos_block * block, int flag)
{
  void **work = GetPtrWorkPtrs (block);
  double *rpar = GetRparPtrs (block);
  double *g = GetGPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *rw;
  double t = GetScicosTime (block);

  if (flag == 4)
    {
      /* the workspace is used to store previous values */
      if ((*work = scicos_malloc (sizeof (double) * 4)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      rw = *work;
      rw[0] = t;
      rw[1] = t;
      rw[2] = rpar[0];
      rw[3] = rpar[0];
    }
  else if (flag == 5)
    {
      scicos_free (*work);
    }
  else if (flag == 1)
    {
      rw = *work;
      if (!isinTryPhase (block))
	{
	  if (t > rw[1])
	    {
	      rw[0] = rw[1];
	      rw[2] = rw[3];
	    }
	  rw[1] = t;
	  if (u1[0] > rw[2] + rpar[1] / 2)
	    {
	      rw[3] = u1[0] - rpar[1] / 2;
	    }
	  else if (u1[0] < rw[2] - rpar[1] / 2)
	    {
	      rw[3] = u1[0] + rpar[1] / 2;
	    }
	  else
	    {
	      rw[3] = rw[2];
	    }
	}
      y1[0] = rw[3];
    }
  else if (flag == 9)
    {
      rw = *work;
      if (t > rw[1])
	{
	  g[0] = u1[0] - rpar[1] / 2 - rw[3];
	  g[1] = u1[0] + rpar[1] / 2 - rw[3];
	}
      else
	{
	  g[0] = u1[0] - rpar[1] / 2 - rw[2];
	  g[1] = u1[0] + rpar[1] / 2 - rw[2];
	}
      g[0] = u1[0] - rpar[1] / 2 - rw[2];
      g[1] = u1[0] + rpar[1] / 2 - rw[2];
    }
}

/**
 * scicos_cos_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_cos_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = cos (u1[j]);
	}
    }

}


/**
 * scicos_cosh_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_cosh_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int j;
  if (flag == 1)
    {
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  y1[j] = cosh (u1[j]);
	}
    }
}

/**
 * scicos_deadband_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_deadband_block (scicos_block * block, int flag)
{
  /* rpar[0]:upper limit,  rpar[1]:lower limit */
  double *rpar = GetRparPtrs (block);
  int ng = GetNg (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  
  switch (flag)
    {
    case 1:
      if (!areModesFixed (block) || ng == 0)
	{
	  y1[0] = (u1[0] >= rpar[0]) ?  u1[0] - rpar[0] 
	    : ((u1[0] <= rpar[1]) ? u1[0] - rpar[1] : 0.0);
	}
      else
	{
	  y1[0]= (mode[0] == 1) ? (u1[0] - rpar[0]) 
	    : ((mode[0] == 2) ? u1[0] - rpar[1] : 0.0);
	}
      break;
    case 9:
      g[0] = u1[0] - (rpar[0]);
      g[1] = u1[0] - (rpar[1]);
      if (!areModesFixed (block))
	{
	  mode[0] = (g[0] >= 0) ? 1 :  ((g[1] <= 0) ?  2: 3);
	}
      break;
    default:
      break;
    }
}

/**
 * scicos_deriv_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_deriv_block (scicos_block * block, int flag)
{
  void **work = GetPtrWorkPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  /* int  nevprt=GetNevIn(block); */
  double *rw;
  double a0, b0, a1, b1, d, x0, x1, x2, u0, uu1, u2;
  int i;
  double t = GetScicosTime (block);

  if (flag == 4)
    {				
      /* the workspace is used to store previous values */
      if ((*work =
	   scicos_malloc (sizeof (double) * 2 *
			  (1 + GetInPortRows (block, 1)))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      rw = *work;
      rw[0] = t;
      rw[1] = t;
      for (i = 0; i < GetInPortRows (block, 1); ++i)
	{
	  rw[2 + 2 * i] = 0;
	  rw[3 + 2 * i] = 0;
	}
    }
  else if (flag == 5)
    {
      scicos_free (*work);
    }
  else if (flag == 1)
    {
      rw = *work;
      x0 = rw[0];
      x1 = rw[1];
      x2 = t;
      for (i = 0; i < GetInPortRows (block, 1); ++i)
	{
	  u0 = rw[2 + 2 * i];
	  uu1 = rw[3 + 2 * i];
	  u2 = u1[i];
	  d = (x1 - x2) * (x0 - x2) * (x1 - x0);
	  if (d != 0)
	    {
	      a0 = ((u2 - uu1) * (x1 - x0) - (x2 - x1) * (uu1 - u0)) / d;
	      a1 = a0;
	      b0 = (uu1 - u0) / (x1 - x0) - a0 * (x1 - x0);
	      b1 = 2 * a0 * (x1 - x0) + b0;
	      y1[i] = 2 * a1 * (x2 - x1) + b1;
	    }
	  else
	    {
	      if (x2 - x1 != 0.0)
		{
		  y1[i] = (u2 - uu1) / (x2 - x1);
		}
	      else
		{
		  if (x2 - x0 != 0.0)
		    {
		      y1[i] = (u2 - u0) / (x2 - x0);
		    }
		  else
		    {
		      y1[i] = 0.0;
		    }
		}
	    }
	}
    }
  else if (flag == 2)
    {	
      /* called by odoit/ddoit & nevprt <=0 */
      rw = *work;
      x0 = rw[0];
      x1 = rw[1];
      x2 = t;
      for (i = 0; i < GetInPortRows (block, 1); ++i)
	{
	  u0 = rw[2 + 2 * i];
	  uu1 = rw[3 + 2 * i];
	  u2 = u1[i];

	  if (!isinTryPhase (block))
	    {
	      if (x2 >= x1)
		{
		  if (x2 > x1)
		    {
		      rw[0] = x1;
		      rw[2 + 2 * i] = uu1;
		    }
		  rw[1] = x2;
		  rw[3 + 2 * i] = u2;
		}
	    }
	}
    }
}

/*
  cubic interpolation "natural"
  s0(x)=a0*(x-x0)^3+b0*(x-x0)^2+c0*(x-x0)+u0;
  s1(x)=a1*(x-x1)^3+b1*(x-x1)^2+c1*(x-x1)+uu1;

  constraints:
  s0(x1)   = s1(x1)
  sp0(x1)  = sp1(x1)
  spp0(x1) = spp1(x1)

  s1(x2)=u2
  Natural method:
  spp0(x0) = 0
  spp1(x2) = 0

  d=2*(x0-x2)*(x0-x1)*(x2-x1)*(x1-x0);
  a0=(u2*(x1-x0)+u0*(x2-x1)+uu1*(x0-x2))/d;
  a1=a0*(x1-x0)/(x1-x2);
  b1=3*a0*(x1-x0);
  c1=(u2-uu1)/(x2-x1)+2*a0*(x1-x2)*(x1-x0);
  y1[i]=3*a1*(x2-x1)*(x2-x1)+2*b1*(x2-x1)+c1;

*/


/*
  square interpolation "natural"
  s0(x)=a0*(x-x0)^2+b0*(x-x0)+u0;
  s1(x)=a1*(x-x1)^2+b1*(x-x1)+uu1;

  constraints:
  s0(x1)   = s1(x1)
  sp0(x1)  = sp1(x1)
  spp0(x1) = spp1(x1)
  s1(x2)   = u2

  d=(x1-x2)*(x0-x2)*(x1-x0);
  a0=((u2-uu1)*(x1-x0)-(x2-x1)*(uu1-u0))/d;	    
  a1=a0;
  b0=(uu1-u0)/(x1-x0)-a0*(x1-x0);
  b1=2*a0*(x1-x0)+b0;
  y1[i]=2*a1*(x2-x1)+b1;
*/



/**
 * scicos_extractor_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_extractor_block (scicos_block * block, int flag)
{
  int *ipar = GetIparPtrs (block);
  int nipar = GetNipar (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int i, j;
  if (flag == 1)
    {
      for (i = 0; i < nipar; ++i)
	{
	  j = ipar[i] - 1;
	  if (j < 0)
	    j = 0;
	  if (j >= GetInPortRows (block, 1))
	    j = GetInPortRows (block, 1) - 1;
	  y1[i] = u1[j];
	}
    }
}


/**
 * scicos_gainblk_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_gainblk_block (scicos_block * block, int flag)
{
  int i;
  int nu = GetInPortRows (block, 1);
  int ny = GetOutPortRows (block, 1);
  int my = GetOutPortCols (block, 1);
  double *u = GetRealInPortPtrs (block, 1);
  double *y = GetRealOutPortPtrs (block, 1);
  int nrpar = GetNrpar (block);
  double *rpar = GetRparPtrs (block);
  if (nrpar == 1)
    {
      for (i = 0; i < nu * my; ++i)
	{
	  y[i] = rpar[0] * u[i];
	}
    }
  else
    {
      nsp_calpack_dmmul (rpar, &ny, u, &nu, y, &ny, &ny, &nu, &my);
    }
}




/**
 * scicos_time_delay_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_time_delay_block (scicos_block * block, int flag)
{				
  /*  rpar[0]=delay, rpar[1]=init value, ipar[0]=buffer length */
  void **work = GetPtrWorkPtrs (block);
  double *rpar = GetRparPtrs (block);
  int *ipar = GetIparPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *pw, del, t, td, eps;
  int *iw;
  int i, j, k;

  if (flag == 4)
    {				
      /* the workspace is used to store previous values */
      if ((*work =
	   scicos_malloc (sizeof (int) + sizeof (double) *
			  ipar[0] * (1 + GetInPortRows (block, 1)))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      eps = 1.0e-9;		/* shift times to left to avoid replacing 0 */
      pw = *work;
      pw[0] = -rpar[0] * (ipar[0] - 1) - eps;
      for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
	{
	  pw[ipar[0] * j] = rpar[1];
	}

      for (i = 1; i < ipar[0]; i++)
	{
	  pw[i] = pw[i - 1] + rpar[0] - eps;
	  for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
	    {
	      pw[i + ipar[0] * j] = rpar[1];
	    }
	}

      iw = (int *) (pw + ipar[0] * (1 + GetInPortRows (block, 1)));
      *iw = 0;
      for (k = 0; k < GetInPortRows (block, 1); k++)
	{
	  y1[k] = rpar[1];
	}
    }
  else if (flag == 5)
    {
      scicos_free (*work);

    }
  else if (flag == 0 || flag == 2)
    {
      if (flag == 2)
	DoColdRestart (block);
      pw = *work;
      iw = (int *) (pw + ipar[0] * (1 + GetInPortRows (block, 1)));
      t = GetScicosTime (block);
      td = t - rpar[0];
      if (td < pw[*iw])
	{
	  Sciprintf ("delayed time=%f but last stored time=%f\n", td,
		    pw[*iw]);
	  Sciprintf
	    ("Consider increasing the length of buffer in delay block\n");
	}

      if (t > pw[(ipar[0] + *iw - 1) % ipar[0]])
	{
	  for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
	    {
	      pw[*iw + ipar[0] * j] = u1[j - 1];
	    }
	  pw[*iw] = t;
	  /*sciprint("**time is %f. I put %f, in %d \r\n", t,u1[0],*iw); */
	  *iw = (*iw + 1) % ipar[0];

	}
      else
	{
	  for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
	    {
	      pw[(ipar[0] + *iw - 1) % ipar[0] + ipar[0] * j] = u1[j - 1];
	    }
	  pw[(ipar[0] + *iw - 1) % ipar[0]] = t;
	  /*sciprint("**time is %f. I put %f, in %d \r\n", t,u1[0],*iw); */

	}

    }
  else if (flag == 1)
    {
      pw = *work;
      iw = (int *) (pw + ipar[0] * (1 + GetInPortRows (block, 1)));
      t = GetScicosTime (block);

      td = t - rpar[0];

      i = 0;
      j = ipar[0] - 1;

      while (j - i > 1)
	{
	  k = (i + j) / 2;
	  if (td < pw[(k + *iw) % ipar[0]])
	    {
	      j = k;
	    }
	  else if (td > pw[(k + *iw) % ipar[0]])
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
      i = (i + *iw) % ipar[0];
      j = (j + *iw) % ipar[0];
      del = pw[j] - pw[i];
      /*    sciprint("time is %f. interpolating %d and %d, i.e. %f, %f\r\n", t,i,j,pw[i],pw[j]);
         sciprint("values are  %f   %f.\r\n",pw[i+ipar[0]],pw[j+ipar[0]]); */
      if (del != 0.0)
	{
	  for (k = 1; k < GetInPortRows (block, 1) + 1; k++)
	    {
	      y1[k - 1] = ((pw[j] - td) * pw[i + ipar[0] * k] +
			    (td - pw[i]) * pw[j + ipar[0] * k]) / del;
	    }
	}
      else
	{
	  for (k = 1; k < GetInPortRows (block, 1) + 1; k++)
	    {
	      y1[k - 1] = pw[i + ipar[0] * k];
	    }
	}
    }
}


/**
 * scicos_variable_delay_block:
 * @block: 
 * @flag: 
 * 
 **/

void scicos_variable_delay_block (scicos_block * block, int flag)
{
  /*  rpar[0]=max delay, rpar[1]=init value, ipar[0]=buffer length */
  void **work = GetPtrWorkPtrs (block);
  double *rpar = GetRparPtrs (block);
  int *ipar = GetIparPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  double *pw, del, td;
  int *iw;
  int id, i, j, k;
  int phase = GetSimulationPhase (block);
  double t = GetScicosTime (block);
  if (flag == 4)
    {
      /* the workspace is used to store previous values */
      if ((*work =
	   scicos_malloc (sizeof (int) + sizeof (double) *
			  ipar[0] * (1 + GetInPortRows (block, 1)))) == NULL)
	{
	  set_block_error (-16);
	  return;
	}
      pw = *work;
      pw[0] = -rpar[0] * ipar[0];
      for (i = 1; i < ipar[0]; i++)
	{
	  pw[i] = pw[i - 1] + rpar[0];
	  for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
	    {
	      pw[i + ipar[0] * j] = rpar[1];
	    }
	}
      iw = (int *) (pw + ipar[0] * (1 + GetInPortRows (block, 1)));
      *iw = 0;
    }
  else if (flag == 5)
    {
      scicos_free (*work);
    }
  else if (flag == 1)
    {
      if (phase == 1)
	do_cold_restart ();
      pw = *work;
      iw = (int *) (pw + ipar[0] * (1 + GetInPortRows (block, 1)));

      id = scicos_get_fcaller_id ();

      del = min (max (0, u2[0]), rpar[0]);
      td = t - del;
      if (td < pw[*iw])
	{
	  Sciprintf ("delayed time=%f but last stored time=%f\n", td,
		    pw[*iw]);
	  Sciprintf
	    ("Consider increasing the length of buffer in variable delay block\n");
	}
      if (id > 0)
	{
	  if (t > pw[(ipar[0] + *iw - 1) % ipar[0]])
	    {
	      for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
		{
		  pw[*iw + ipar[0] * j] = u1[j - 1];
		}
	      pw[*iw] = t;
	      *iw = (*iw + 1) % ipar[0];
	    }
	  else
	    {
	      for (j = 1; j < GetInPortRows (block, 1) + 1; j++)
		{
		  pw[(ipar[0] + *iw - 1) % ipar[0] + ipar[0] * j] =
		    u1[j - 1];
		}
	      pw[(ipar[0] + *iw - 1) % ipar[0]] = t;
	    }
	}
      i = 0;
      j = ipar[0] - 1;

      while (j - i > 1)
	{
	  k = (i + j) / 2;
	  if (td < pw[(k + *iw) % ipar[0]])
	    {
	      j = k;
	    }
	  else if (td > pw[(k + *iw) % ipar[0]])
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
      i = (i + *iw) % ipar[0];
      j = (j + *iw) % ipar[0];
      del = pw[j] - pw[i];
      if (del != 0.0 && td > 0)
	{
	  for (k = 1; k < GetInPortRows (block, 1) + 1; k++)
	    {
	      y1[k - 1] = ((pw[j] - td) * pw[i + ipar[0] * k] +
			    (td - pw[i]) * pw[j + ipar[0] * k]) / del;
	    }
	}
      else
	{
	  for (k = 1; k < GetInPortRows (block, 1) + 1; k++)
	    {
	      y1[k - 1] = pw[i + ipar[0] * k];
	    }
	}
    }
}


/**
 * scicos_step_func_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_step_func_block (scicos_block * block, int flag)
{
  double *_rpar = GetRparPtrs (block);
  int _nevprt = GetNevIn (block);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  int i;
  if (flag == 1 && _nevprt == 1)
    {
      for (i = 0; i < GetOutPortRows (block, 1); ++i)
	{
	  _y1[i] = _rpar[GetOutPortRows (block, 1) + i];
	}
    }
  else if (flag == 4)
    {
      for (i = 0; i < GetOutPortRows (block, 1); ++i)
	{
	  _y1[i] = _rpar[i];
	}
    }
}



/**
 * scicos_signum_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_signum_block (scicos_block * block, int flag)
{
  int _ng = GetNg (block);
  double *_g = GetGPtrs (block);
  int *_mode = GetModePtrs (block);
  double *_u1 = GetRealInPortPtrs (block, 1);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  /* int phase= GetSimulationPhase(block); */
  int i, j;
  
  if (flag == 1)
    {
      for (i = 0; i < GetInPortRows (block, 1); ++i)
	{
	  if (!areModesFixed (phase) || _ng == 0)
	    {
	      j = (_u1[i] < 0) ? 2 : ((_u1[i] > 0) ? 1 : 0);
	    }
	  else
	    {
	      j = _mode[i];
	    }
	  _y1[i] = (j == 1) ?  1.0 : ((j == 2) ?  -1.0: 0.0);
	}
    }
  else if (flag == 9)
    {
      for (i = 0; i < GetInPortRows (block, 1); ++i)
	{
	  _g[i] = _u1[i];
	  if (!areModesFixed (phase))
	    {
	      _mode[i] =  (_g[i] < 0) ?  2 : 1;
	    }
	}
    }
}



/**
 * scicos_summation_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_summation_block (scicos_block * block, int flag)
{
  int j, k;
  double *y = GetRealOutPortPtrs (block, 1);
  int nu = GetInPortRows (block, 1);
  int mu = GetInPortCols (block, 1);
  int *ipar = GetIparPtrs (block);

  if (flag == 1)
    {
      if (GetNin (block) == 1)
	{
	  double *u = GetRealInPortPtrs (block, 1);
	  y[0] = 0.0;
	  for (j = 0; j < nu * mu; j++)   y[0] +=  u[j];
	}
      else
	{
	  for (j = 0; j < nu * mu; j++)
	    {
	      y[j] = 0.0;
	      for (k = 0; k < GetNin (block); k++)
		{
		  double *u = GetRealInPortPtrs (block, k + 1);
		  y[j] += (ipar[k] > 0) ? u[j] : - u[j];
		}
	    }
	}
    }
}

/**
 * scicos_switch2_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_switch2_block (scicos_block * block, int flag)
{
  int i=0, j;
  double *_rpar = GetRparPtrs (block);
  int *_ipar = GetIparPtrs (block);
  int _ng = GetNg (block);
  double *_g = GetGPtrs (block);
  int *_mode = GetModePtrs (block);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  double *_u2 = GetRealInPortPtrs (block, 2);
  double *uytmp;
  /* int phase=GetSimulationPhase(block); */
  if (flag == 1)
    {
      if (!areModesFixed (phase) || _ng == 0)
	{
	  i = 2;
	  if (*_ipar == 0)
	    {
	      if (*_u2 >= *_rpar)
		i = 0;
	    }
	  else if (*_ipar == 1)
	    {
	      if (*_u2 > *_rpar)
		i = 0;
	    }
	  else
	    {
	      if (*_u2 != *_rpar)
		i = 0;
	    }
	}
      else
	{
	  if (_mode[0] == 1)
	    {
	      i = 0;
	    }
	  else if (_mode[0] == 2)
	    {
	      i = 2;
	    }
	}
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  uytmp = GetRealInPortPtrs (block, i + 1);
	  _y1[j] = uytmp[j];
	}
    }
  else if (flag == 9)
    {
      _g[0] = *_u2 - (*_rpar);
      if (!areModesFixed (phase))
	{
	  i = 2;
	  if (*_ipar == 0)
	    {
	      if (_g[0] >= 0.0)
		i = 0;
	    }
	  else if (*_ipar == 1)
	    {
	      if (_g[0] > 0.0)
		i = 0;
	    }
	  else
	    {
	      if (_g[0] != 0.0)
		i = 0;
	    }
	  if (i == 0)
	    {
	      _mode[0] = 1;
	    }
	  else
	    {
	      _mode[0] = 2;
	    }
	}
    }
}


/**
 * scicos_satur_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_satur_block (scicos_block * block, int flag)
{
  /* rpar[0]:upper limit,  rpar[1]:lower limit */
  double *_rpar = GetRparPtrs (block);
  int _ng = GetNg (block);
  double *_g = GetGPtrs (block);
  int *_mode = GetModePtrs (block);
  double *_u1 = GetRealInPortPtrs (block, 1);
  double *_y1 = GetRealOutPortPtrs (block, 1);

  if (flag == 1)
    {
      if (!areModesFixed (block) || _ng == 0)
	{
	  if (*_u1 >= _rpar[0])
	    {
	      _y1[0] = _rpar[0];
	    }
	  else if (*_u1 <= _rpar[1])
	    {
	      _y1[0] = _rpar[1];
	    }
	  else
	    {
	      _y1[0] = _u1[0];
	    }
	}
      else
	{
	  if (_mode[0] == 1)
	    {
	      _y1[0] = _rpar[0];
	    }
	  else if (_mode[0] == 2)
	    {
	      _y1[0] = _rpar[1];
	    }
	  else
	    {
	      _y1[0] = _u1[0];
	    }
	}
    }
  else if (flag == 9)
    {
      _g[0] = *_u1 - (_rpar[0]);
      _g[1] = *_u1 - (_rpar[1]);
      if (!areModesFixed (block))
	{
	  if (_g[0] >= 0)
	    {
	      _mode[0] = 1;
	    }
	  else if (_g[1] <= 0)
	    {
	      _mode[0] = 2;
	    }
	  else
	    {
	      _mode[0] = 3;
	    }
	}
    }
}

/**
 * scicos_logicalop_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_logicalop_block (scicos_block * block, int flag)
{
  int *_ipar = GetIparPtrs (block);
  int _nin = GetNin (block);
  double *_u1 = GetRealInPortPtrs (block, 1);
  double *_y1 = GetRealOutPortPtrs (block, 1);
  double *uytmp;
  int i, j, k, l;
  i = _ipar[0];
  switch (i)
    {
    case 0:
      if (_nin == 1)
	{
	  _y1[0] = 1.0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      if (_u1[j] <= 0)
		{
		  _y1[0] = 0.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      _y1[j] = 1.0;
	      for (k = 0; k < _nin; k++)
		{
		  uytmp = GetRealInPortPtrs (block, k + 1);
		  if (uytmp[j] <= 0)
		    {
		      _y1[j] = 0.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 1:
      if (_nin == 1)
	{
	  _y1[0] = 0.0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      if (_u1[j] > 0)
		{
		  _y1[0] = 1.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      _y1[j] = 0.0;
	      for (k = 0; k < _nin; k++)
		{
		  uytmp = GetRealInPortPtrs (block, k + 1);
		  if (uytmp[j] > 0)
		    {
		      _y1[j] = 1.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 2:
      if (_nin == 1)
	{
	  _y1[0] = 0.0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      if (_u1[j] <= 0)
		{
		  _y1[0] = 1.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      _y1[j] = 0.0;
	      for (k = 0; k < _nin; k++)
		{
		  uytmp = GetRealInPortPtrs (block, k + 1);
		  if (uytmp[j] <= 0)
		    {
		      _y1[j] = 1.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 3:
      if (_nin == 1)
	{
	  _y1[0] = 1.0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      if (_u1[j] > 0)
		{
		  _y1[0] = 0.0;
		  break;
		}
	    }
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      _y1[j] = 1.0;
	      for (k = 0; k < _nin; k++)
		{
		  uytmp = GetRealInPortPtrs (block, k + 1);
		  if (uytmp[j] > 0)
		    {
		      _y1[j] = 0.0;
		      break;
		    }
		}
	    }
	}
      break;

    case 4:
      if (_nin == 1)
	{
	  l = 0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      if (_u1[j] > 0)
		{
		  l = (l + 1) % 2;
		}
	    }
	  _y1[0] = (double) l;
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      l = 0;
	      for (k = 0; k < _nin; k++)
		{
		  uytmp = GetRealInPortPtrs (block, k + 1);
		  if (uytmp[j] > 0)
		    {
		      l = (l + 1) % 2;
		    }
		}
	      _y1[j] = (double) l;
	    }
	}
      break;

    case 5:
      for (j = 0; j < GetInPortRows (block, 1); j++)
	{
	  if (_u1[j] > 0)
	    {
	      _y1[j] = 0.0;
	    }
	  else
	    {
	      _y1[j] = 1.0;
	    }
	}
    }
}

/**
 * scicos_multiplex_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_multiplex_block (scicos_block * block, int flag)
{
  int nin = GetNin (block);
  int nout = GetNout (block);
  int i;
  if (nin == 1)
    {
      int k = 0;
      char *u1 =(char *) GetInPortPtrs (block, 1);
      for (i = 0; i < nout; ++i)
	{
	  int nui = GetOutPortRows (block, i + 1) * GetSizeOfOut (block, i + 1);
	  char *uytmp =(char *) GetOutPortPtrs (block, i + 1);
	  memcpy (uytmp, u1 + k, nui);
	  k = k + nui;
	}
    }
  else
    {
      int k = 0;
      char *y1 = (char*) GetOutPortPtrs (block, 1);
      for (i = 0; i < nin; ++i)
	{
	  int nui = GetInPortRows (block, i + 1) * GetSizeOfIn (block, i + 1);
	  char * uytmp = (char *) GetInPortPtrs (block, i + 1);
	  memcpy (y1 + k, uytmp, nui);
	  k = k + nui;
	}
    }
}

/**
 * scicos_hystheresis_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_hystheresis_block (scicos_block * block, int flag)
{
  double *rpar = GetRparPtrs (block);
  int ng = GetNg (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  switch (flag)
    {
    case 1:
      if (!areModesFixed (block) || ng == 0)
	{
	  if (u1[0] >= rpar[0])
	    {
	      y1[0] = rpar[2];
	    }
	  else if (u1[0] <= rpar[1])
	    {
	      y1[0] = rpar[3];
	    }
	  else if ((y1[0] != rpar[3]) && (y1[0] != rpar[2]))
	    {
	      y1[0] = rpar[3];
	    }
	}
      else
	{
	  if (mode[0] == 2)
	    {
	      y1[0] = rpar[2];
	    }
	  else
	    {
	      y1[0] = rpar[3];
	    }
	}
      break;
    case 9:
      g[0] = u1[0] - (rpar[0]);
      g[1] = u1[0] - (rpar[1]);
      if (!areModesFixed (block))
	{
	  if (g[0] >= 0)
	    {
	      mode[0] = 2;
	    }
	  else if (g[1] <= 0)
	    {
	      mode[0] = 1;
	    }
	}
      break;
    default:
      break;
    }
}



/**
 * scicos_ramp_block:
 * @block: 
 * @flag: 
 * 
 **/

void scicos_ramp_block (scicos_block * block, int flag)
{
  double dt;
  double *rpar = GetRparPtrs (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  double *y1 = GetRealOutPortPtrs (block, 1);
  switch (flag)
    {
    case 1:
      dt = GetScicosTime (block) - rpar[1];
      if (!areModesFixed (block))
	{
	  if (dt > 0)
	    {
	      y1[0] = rpar[2] + rpar[0] * dt;
	    }
	  else
	    {
	      y1[0] = rpar[2];
	    }
	}
      else
	{
	  if (mode[0] == 1)
	    {
	      y1[0] = rpar[2] + rpar[0] * dt;
	    }
	  else
	    {
	      y1[0] = rpar[2];
	    }
	}
      break;
    case 9:
      g[0] = GetScicosTime (block) - (rpar[1]);
      if (!areModesFixed (block))
	{
	  mode[0]= (g[0] >= 0) ? 1 : 2 ;
	}
      break;
    default:
      break;
    }
}

/**
 * scicos_minmax_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_minmax_block (scicos_block * block, int flag)
{
  /*ipar[0]=1 -> min,  ipar[0]=2 -> max */
  int *ipar = GetIparPtrs (block);
  int nin = GetNin (block);
  int ng = GetNg (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  double *uytmp;
  int i;
  double maxmin;

  switch (flag)
    {
    case 1:
      switch (nin)
	{
	case 1:
	  if (ng == 0 || !areModesFixed (block))
	    {
	      maxmin = u1[0];
	      for (i = 1; i < GetInPortRows (block, 1); ++i)
		{
		  if (ipar[0] == 1)
		    {
		      if (u1[i] < maxmin)
			maxmin = u1[i];
		    }
		  else
		    {
		      if (u1[i] > maxmin)
			maxmin = u1[i];
		    }
		}
	    }
	  else
	    {
	      maxmin = u1[mode[0] - 1];
	    }
	  y1[0] = maxmin;
	  break;
	case 2:
	  for (i = 0; i < GetInPortRows (block, 1); ++i)
	    {
	      if (ng == 0 || !areModesFixed (block))
		{
		  if (ipar[0] == 1)
		    {
		      y1[i] = Min (u1[i], u2[i]);
		    }
		  else
		    {
		      y1[i] = Max (u1[i], u2[i]);
		    }
		}
	      else
		{
		  uytmp = GetRealInPortPtrs (block, mode[0] - 1 + 1);
		  y1[i] = uytmp[i];
		}
	    }
	  break;
	default:
	  break;
	}
      break;
    case 9:
      switch (nin)
	{
	case 1:
	  if (areModesFixed (block))
	    {
	      for (i = 0; i < GetInPortRows (block, 1); ++i)
		{
		  if (i != mode[0] - 1)
		    {
		      g[i] = u1[i] - u1[mode[0] - 1];
		    }
		  else
		    {
		      g[i] = 1.0;
		    }
		}
	    }
	  else
	    {
	      maxmin = u1[0];
	      mode[0] = 1;
	      for (i = 1; i < GetInPortRows (block, 1); ++i)
		{
		  if (ipar[0] == 1)
		    {
		      if (u1[i] < maxmin)
			{
			  maxmin = u1[i];
			  mode[0] = i + 1;
			}
		    }
		  else
		    {
		      if (u1[i] > maxmin)
			{
			  maxmin = u1[i];
			  mode[0] = i + 1;
			}
		    }
		}
	    }
	  break;
	case 2:
	  for (i = 0; i < GetInPortRows (block, 1); ++i)
	    {
	      g[i] = u1[i] - u2[i];
	      if (!areModesFixed (block))
		{
		  if (ipar[0] == 1)
		    {
		      if (g[i] > 0)
			{
			  mode[i] = 2;
			}
		      else
			{
			  mode[i] = 1;
			}
		    }
		  else
		    {
		      if (g[i] < 0)
			{
			  mode[i] = 2;
			}
		      else
			{
			  mode[i] = 1;
			}
		    }
		}
	    }
	  break;
	default:
	  break;
	}
      break;
    default:
      break;
    }
}


/**
 * scicos_modulo_count_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_modulo_count_block (scicos_block * block, int flag)
{
  int *ipar = GetIparPtrs (block);
  double *z = GetDstate (block);
  double *y1 = GetRealOutPortPtrs (block, 1);
  if (flag == 1)
    {
      *y1 = z[0];
    }
  else if (flag == 2)
    {
      z[0] = (1 + (int) z[0]) % (ipar[0]);
    }
}


/**
 * scicos_mswitch_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_mswitch_block (scicos_block * block, int flag)
{
  if ((flag == 1) || (flag == 6))
    {
      int j = 0;
      void *y = GetOutPortPtrs (block, 1);
      int so = GetSizeOfOut (block, 1);
      int my = GetOutPortRows (block, 1);
      int ny = GetOutPortCols (block, 1);
      double *u1 = GetRealInPortPtrs (block, 1);
      int *ipar = GetIparPtrs (block);
      int nin = GetNin (block);
      int i = *(ipar + 1);
      if (i == 0)
	{
	  if (*u1 > 0)
	    {
	      j = (int) floor (*u1);
	    }
	  else
	    {
	      j = (int) ceil (*u1);
	    }
	}
      else if (i == 1)
	{
	  if (*u1 > 0)
	    {
	      j = (int) floor (*u1 + .5);
	    }
	  else
	    {
	      j = (int) ceil (*u1 - .5);
	    }
	}
      else if (i == 2)
	{
	  j = (int) ceil (*u1);
	}
      else if (i == 3)
	{
	  j = (int) floor (*u1);
	}
      j = j + 1 - *ipar;
      j = max (j, 1);
      if (nin == 2)
	{
	  int mu = GetInPortRows (block, 2);
	  int nu = GetInPortCols (block, 2);
	  void *uj = GetInPortPtrs (block, 2);
	  j = min (j, mu * nu);
	  memcpy (y, uj + (j - 1) * my * ny * so, my * ny * so);
	}
      else
	{
	  j = min (j, nin - 1);
	  void *uj = GetInPortPtrs (block, j + 1);
	  memcpy (y, uj, my * ny * so);
	}
    }
}


/**
 * scicos_product_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_product_block (scicos_block * block, int flag)
{
  int *ipar = GetIparPtrs (block);
  int nin = GetNin (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *uytmp;
  int j, k;
  if (flag == 1)
    {
      if (nin == 1)
	{
	  y1[0] = 1.0;
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      y1[0] = y1[0] * u1[j];
	    }
	}
      else
	{
	  for (j = 0; j < GetInPortRows (block, 1); j++)
	    {
	      y1[j] = 1.0;
	      for (k = 0; k < nin; k++)
		{
		  if (ipar[k] > 0)
		    {
		      uytmp = GetRealInPortPtrs (block, k + 1);
		      y1[j] = y1[j] * uytmp[j];
		    }
		  else
		    {
		      uytmp = GetRealInPortPtrs (block, k + 1);
		      if (uytmp[j] == 0)
			{
			  scicos_set_block_error (-2);
			  return;
			}
		      else
			{
			  uytmp = GetRealInPortPtrs (block, k + 1);
			  y1[j] = y1[j] / uytmp[j];
			}
		    }
		}
	    }
	}
    }
}



/**
 * scicos_ratelimiter_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_ratelimiter_block (scicos_block * block, int flag)
{
  /*
   * rpar[0]=rising rate limit, rpar[1]=falling rate limit 
   */
  void **work = GetPtrWorkPtrs (block);
  double *rpar = GetRparPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *pw;
  double rate = 0., t;
  int phase = GetSimulationPhase (block);

  if (flag == 4)
    {
      /* the workspace is used to store previous values */
      if ((*work = scicos_malloc (sizeof (double) * 4)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      pw = *work;
      pw[0] = 0.0;
      pw[1] = 0.0;
      pw[2] = 0.0;
      pw[3] = 0.0;
    }
  else if (flag == 5)
    {
      scicos_free (*work);
    }
  else if (flag == 1)
    {
      if (phase == 1)
	do_cold_restart ();
      pw = *work;
      t = GetScicosTime (block);
      if (t > pw[2])
	{
	  pw[0] = pw[2];
	  pw[1] = pw[3];
	  rate = (u1[0] - pw[1]) / (t - pw[0]);
	}
      else if (t <= pw[2])
	{
	  if (t > pw[0])
	    {
	      rate = (u1[0] - pw[1]) / (t - pw[0]);
	    }
	  else
	    {
	      rate = 0.0;
	    }
	}
      if (rate > rpar[0])
	{
	  y1[0] = (t - pw[0]) * rpar[0] + pw[1];
	}
      else if (rate < rpar[1])
	{
	  y1[0] = (t - pw[0]) * rpar[1] + pw[1];
	}
      else
	{
	  y1[0] = u1[0];
	}
      pw[2] = t;
      pw[3] = y1[0];
    }
}

/**
 * scicos_integral_func_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_integral_func_block (scicos_block * block, int flag)
{
  double *rpar = GetRparPtrs (block);
  double *xd = GetDerState (block);
  double *x = GetState (block);
  double *g = GetGPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  int *mode = GetModePtrs (block);
  int nevprt = GetNevIn (block);
  int nx = GetNstate (block);
  int ng = GetNg (block);
  int i;
  switch (flag)
    {
    case 0:
      if (ng > 0)
	{
	  for (i = 0; i < nx; ++i)
	    {
	      if (mode[i] == 3)
		{
		  xd[i] = u1[i];
		}
	      else
		{
		  xd[i] = 0.0;
		}
	    }
	}
      else
	{
	  for (i = 0; i < nx; ++i)
	    {
	      xd[i] = u1[i];
	    }
	}
      break;
    case 1:
    case 6:
      for (i = 0; i < nx; ++i)
	y1[i] = x[i];
      break;
    case 2:
      if (nevprt == 1)
	{
	  for (i = 0; i < nx; ++i)
	    x[i] = u2[i];
	}
      break;
    case 9:
      if (!areModesFixed (block))
	{
	  for (i = 0; i < nx; ++i)
	    {
	      if (u1[i] >= 0 && x[i] >= rpar[i])
		{
		  mode[i] = 1;
		}
	      else if (u1[i] <= 0 && x[i] <= rpar[nx + i])
		{
		  mode[i] = 2;
		}
	      else
		{
		  mode[i] = 3;
		}
	    }
	}

      for (i = 0; i < nx; ++i)
	{
	  if (mode[i] == 3)
	    {
	      g[i] = (x[i] - (rpar[i])) * (x[i] - (rpar[nx + i]));
	    }
	  else
	    {
	      g[i] = u1[i];
	    }
	}

      break;
    default:
      break;
    }
}

/**
 * scicos_evtvardly_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_evtvardly_block (scicos_block * block, int flag)
{
  double *evout = GetNevOutPtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  if (flag == 3)
    {
      evout[0] = u1[0];
    }
}

/**
 * scicos_relationalop_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_relationalop_block (scicos_block * block, int flag)
{
#define CASE_OP1(op)  y1[0] = (u1[0] op u2[0]) ? 1.0: 0.0;
#define CASE_OP2(op)  mode[0] = (u1[0] op u2[0]) ? 2: 1;
  int *ipar = GetIparPtrs (block);
  int ng = GetNg (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  int i =  ipar[0];
  
  if (flag == 1)
    {
      if (ng != 0 && areModesFixed (block))
	{
	  y1[0] = mode[0] - 1.0;
	}
      else
	{
	  switch (i)
	    {
	    case 0: CASE_OP1(==);break;
	    case 1: CASE_OP1(!=);break;
	    case 2: CASE_OP1(<);break;
	    case 3: CASE_OP1(<=);break;
	    case 4: CASE_OP1(>=);break;
	    case 5: CASE_OP1(>);break;
	    }
	}

    }
  else if (flag == 9)
    {
      g[0] = u1[0] - u2[0];
      if (!areModesFixed (block))
	{
	  switch (i)
	    {
	    case 0: CASE_OP2(==);break;
	    case 1: CASE_OP2(!=);break;
	    case 2: CASE_OP2(<);break;
	    case 3: CASE_OP2(<=);break;
	    case 4: CASE_OP2(>=);break;
	    case 5: CASE_OP2(>);break;
	    }
	}
    }
#undef CASE_OP1
#undef CASE_OP2
}


/**
 * scicos_bounce_ball_block:
 * @block: 
 * @flag: 
 * 
 * computes the dynamics of a multi balls in a box 
 * 
 **/

void scicos_bounce_ball_block (scicos_block * block, int flag)
{
  /* rpar(i): mass of ball i
   * rpar(i+n): radius of ball i 
   * rpar(2n+1:2n+4); [xmin,xmax,ymin,ymax]
   * x: [x1,x1',y1,y1',x2,x2',y2,y2',...,yn']
   * n:number of ball=ny1=ny2 
   * y1: x-coord of balls 
   * y2: y-coord of balls 
   *     ipar: storage de taille [nx(n-1)/2=ng]*2 
   */
  int *ipar = block->ipar;
  int *outsz = block->outsz;
  double *x=block->x, *xd= block->xd, *rpar= block->rpar;
  double *g= block->g;
  int ng = block->ng ;
  int *jroot= block->jroot;
  int i, j, k, n= outsz[0];
  double *y1= block->outptr[0], *y2= block->outptr[1];
  
  /* Parameter adjustments to use index vectors starting at 1 
   * as in Scilab (fortran) 
   */
  --g;  --ipar;  --rpar;  --x;  --xd;  --y2;  --y1;  --jroot;
  
  if (flag == 0)
    {
      double c = rpar[(n << 1) + 6];
      for (i = 1; i <= n; ++i)
	{
	  xd[((i - 1) << 2) + 1] = x[((i - 1) << 2) + 2];
	  xd[((i - 1) << 2) + 3] = x[((i - 1) << 2) + 4];
	  xd[((i - 1) << 2) + 2] = -c * x[((i - 1) << 2) + 2];
	  xd[((i - 1) << 2) + 4] = -rpar[(n << 1) + 5];
	}

    }
  else if (flag == 1)
    {
      for (i = 1; i <= n; ++i)
	{
	  y1[i] = x[((i - 1) << 2) + 1];
	  y2[i] = x[((i - 1) << 2) + 3];
	}
    }
  else if (flag == 9)
    {
      int i1 = ng - (n << 2);
      for (k = 1; k <= i1; ++k)
	{
	  double d1, d2, d3;
	  i = ipar[((k - 1) << 1) + 1];
	  j = ipar[((k - 1) << 1) + 2];
	  d1 = x[((i - 1) << 2) + 1] - x[((j - 1) << 2) + 1];
	  d2 = x[((i - 1) << 2) + 3] - x[((j - 1) << 2) + 3];
	  d3 = rpar[i + n] + rpar[j + n];
	  g[k] = d1 * d1 + d2 * d2 - d3 * d3;
	}
      k = ng - (n << 2) + 1;
      for (i = 1; i <= n; ++i)
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
  else if (flag == 2 && block->nevprt < 0)
    {
      int i1 = ng - (n << 2);
      for (k = 1; k <= i1; ++k)
	{
	  if (jroot[k] < 0)
	    {
	      double s1,s2,s3,s4,xsi,a,b;
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
      for (i = 1; i <= n ; ++i)
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

/**
 * scicos_cscope_block:
 * @block: 
 * @flag: 
 * 
 * a scope:
 * Copyright (C) 2010-2011 J.Ph Chancelier 
 * new nsp graphics
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
  int count_invalidates;
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspAxes *Axes;
  NspList *L;
};

static void scicos_cscope_axes_update(NspAxes *axe,double t, double Ts,
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
      int ret;
      cscope_data *D = (cscope_data *) (*block->work);
      if ( D->Axes->obj->ref_count <= 1 ) 
	{
	  /* Axes was destroyed during simulation */
	  return;
	}
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
      ret=nsp_oscillo_add_point(D->L, t,csr->per, block->inptr[0], nu);
      if (ret==FALSE) {
        scicos_set_block_error (-16);
        return;
      }
      if (  D->count % csi->n == 0 ) 
	{
	  /* redraw each csi->n accumulated points 
	   * first check if we need to change the xscale 
	   */
	  scicos_cscope_axes_update(D->Axes,t,csr->per,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	  D->count_invalidates ++;
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cscope_data *D;
      NspList *L;
      int *width=NULL;
      /* XXX :
       * buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori.
       */
      int scopebs = 10000;
      if ((width = scicos_malloc(sizeof(int)*8)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      for(k=0;k<8;k++) width[k]=0;
      /* create a graphic window filled with an axe 
       * (with predefined limits) and curves.
       * The axe is returned and the curves are accessible through the L list.
       */
      NspAxes *Axes1,*Axes =
	nsp_oscillo_obj (wid, nu , csi->type, width, scopebs, TRUE, -1, 1,qcurve_std, &L);
      scicos_free(width);
      if (Axes == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* keep a copy in case Axes is destroyed during simulation 
       * axe is a by reference object 
       */
      Axes1 = nsp_axes_copy(Axes);
      if ( Axes1 == NULL ) 
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
      D->Axes = Axes1;
      D->L = L;
      D->count = 0;
      D->count_invalidates = 0;
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
      if ( D->count_invalidates == 0 && D->Axes->obj->ref_count >= 1 )
	{
	  /* figure was never invalidated and was not destroyed during simulation
	   * we update the graphics at the end  */
	  scicos_cscope_axes_update(D->Axes,t,csr->per,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	}
      if ( D->Axes->obj->ref_count >= 1 ) 
	{
	  /* Axes was destroyed during simulation 
	   * we finish detruction 
	   */
	  nsp_axes_destroy(D->Axes);
	}
      scicos_free (D);
    }
}

static void scicos_cscope_axes_update(NspAxes *axe,double t, double Ts,
				      double ymin,double ymax)
{
  double frect[4]={ Max(t-Ts,0) , ymin, t, ymax};
  int tag = FALSE;
  double bounds[4];
  if ( isinf(ymin) || isinf(ymax))
    {
      /* only usefull, if ymin or ymax is inf */
      tag = nsp_grlist_compute_inside_bounds(axe->obj->children,bounds);
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
  memcpy(axe->obj->frect->R,frect,4*sizeof(double));
  memcpy(axe->obj->rect->R,frect,4*sizeof(double));
  axe->obj->fixed = TRUE; 
}

/**
 * scicos_cfscope_block:
 * @block: 
 * @flag: 
 * 
 * a floating scope
 * new nsp graphics
 **/

typedef struct _cfscope_ipar cfscope_ipar;
struct _cfscope_ipar
{
  /* n is the number of data to accumulate before redrawing */
  int wid, color_flag, n, type[8], wpos[2], wdim[2], nu, wu[];
};

typedef struct _cfscope_data cfscope_data;

struct _cfscope_data
{
  int count_invalidates;
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspAxes *Axes;
  NspList *L;
  double *outtc;
};

void scicos_cfscope_block (scicos_block * block, int flag)
{
  char *str;
  BCG *Xgc;
  /* used to decode parameters by name */
  cfscope_ipar *csi = (cfscope_ipar *) block->ipar;
  cscope_rpar *csr = (cscope_rpar *) block->rpar;
  double t;
  int nu, cur = 0, k, wid;

  nu = csi->nu;
  t = scicos_get_scicos_time ();

  wid = (csi->wid == -1) ? 20000 + scicos_get_block_number () : csi->wid;
  
  if (flag == 2)
    {
      int ret;
      cfscope_data *D = (cfscope_data *) (*block->work);
      if ( D->Axes->obj->ref_count <= 1 ) 
	{
	  /* Axes was destroyed during simulation */
	  return;
	}
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
      scicos_getouttb (nu, csi->wu, D->outtc);
      ret=nsp_oscillo_add_point(D->L, t,csr->per, D->outtc, nu);
      if (ret==FALSE) {
        scicos_set_block_error (-16);
        return;
      }
      if (  D->count % csi->n == 0 ) 
	{
	  /* redraw each csi->n accumulated points 
	   * first check if we need to change the xscale 
	   */
	  scicos_cscope_axes_update(D->Axes,t,csr->per,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	  D->count_invalidates ++;
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cfscope_data *D;
      NspList *L;
      int *width=NULL;
      /* XXX :
       * buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori.
       */
      int scopebs = 10000;
      if ((width = scicos_malloc (sizeof (int)*8)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      for(k=0;k<8;k++) width[k]=0;
      /* create a graphic window filled with an axe 
       * (with predefined limits) and curves.
       * The axe is returned and the curves are accessible through the L list.
       */
      NspAxes *Axes1,*Axes =
	nsp_oscillo_obj (wid, nu , csi->type, width, scopebs, TRUE, -1, 1,qcurve_std, &L);
      scicos_free(width);
      if (Axes == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* keep a copy in case Axes is destroyed during simulation 
       * axe is a by reference object 
       */
      Axes1 = nsp_axes_copy(Axes);
      if ( Axes1 == NULL ) 
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (cfscope_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (cfscope_data *) (*block->work);
      D->Axes = Axes1;
      D->L = L;
      D->count = 0;
      D->count_invalidates = 0;
      D->tlast = t;
      if ( (D->outtc = scicos_malloc(nu*sizeof(double))) == NULL) {
        scicos_set_block_error (-16);
        return;
      }
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
      cfscope_data *D = (cfscope_data *) (*block->work);
      if ( D->count_invalidates == 0 && D->Axes->obj->ref_count >= 1 )
	{
	  /* figure was never invalidated and was not destroyed during simulation
	   * we update the graphics at the end  */
	  scicos_cscope_axes_update(D->Axes,t,csr->per,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	}
      if ( D->Axes->obj->ref_count >= 1 ) 
	{
	  /* Axes was destroyed during simulation 
	   * we finish detruction 
	   */
	  nsp_axes_destroy(D->Axes);
	}
      scicos_free (D);
    }
}

/**
 * scicos_cmscope_block:
 * @block: 
 * @flag: 
 * 
 * a multi scope:
 * Copyright (C) 2010-2013 J.Ph Chancelier 
 **/

typedef struct _cmscope_ipar cmscope_ipar;
struct _cmscope_ipar
{
  /* buffer_size is the number of data to accumulate before redrawing */
  int wid, number_of_subwin, buffer_size , wpos[2], wdim[2];
};

typedef struct _cmscope_rpar cmscope_rpar;
struct _cmscope_rpar
{
  /* dt: unused, yminmax: start of ymin, ymax */
  double dt, yminmax;
};

typedef struct _cmscope_data cmscope_data;

struct _cmscope_data
{
  int count_invalidates;
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspFigure *F;
};

static void nsp_cmscope_invalidate(cmscope_data *D,double t,double *period, double *yminmax);

/* creates a new Axes object for the multiscope 
 *
 */

static NspAxes *nsp_cmscope_new_axe(int ncurves,const int *style, double ymin, double ymax)
{
  char strflag[]="151";
  char *curve_l=NULL;
  int bufsize= 10000, yfree=TRUE;
  int i;
  double frect[4];
  /* create a new axes */
  NspAxes *axe= nsp_axes_create_default("axe");
  if ( axe == NULL) return NULL;
  frect[0]=0;frect[1]=ymin;frect[2]=100;frect[3]=ymax;
  /* create a set of qcurves and insert them in axe */
  for ( i = 0 ; i < ncurves ; i++) 
    {
      int mark=-1;
      NspQcurve *curve;
      NspMatrix *Pts = nsp_matrix_create("Pts",'r',Max(bufsize,1),2); 
      if ( Pts == NULL) return NULL;
      if ( style[i] <= 0 ) mark = -style[i];
      curve= nsp_qcurve_create("curve",mark,0,0,( style[i] > 0 ) ?  style[i] : -1,
			       qcurve_std,Pts,curve_l,-1,-1,NULL);
      if ( curve == NULL) return NULL;
      /* insert the new curve */
      if ( nsp_axes_insert_child(axe,(NspGraphic *) curve,FALSE)== FAIL) 
	{
	  return NULL;
	}
    }
  /* updates the axes scale information */
  nsp_strf_axes( axe , frect, strflag[1]);
  memcpy(axe->obj->frect->R,frect,4*sizeof(double));
  memcpy(axe->obj->rect->R,frect,4*sizeof(double));
  axe->obj->axes = 1;
  axe->obj->xlog = FALSE;
  axe->obj->ylog=  FALSE;
  axe->obj->iso = FALSE;
  /* use free scales if requested  */
  axe->obj->fixed = ( yfree == TRUE ) ? FALSE: TRUE ;
  return axe;
}

/* nswin : number of subwindows
 * ncs[i] : number of curves in subsin i
 * style[k]: style for curve k 
 */

static NspFigure *nsp_cmscope_obj(int win,int nswin,const int *ncs,const int *style,
				 const double *period, int yfree,const double *yminmax)
{
  const int *cstyle = style;
  NspFigure *F;
  NspAxes *axe;
  BCG *Xgc;
  int i,l;
  /*
   * set current window
   */
  if ((Xgc = window_list_get_first()) != NULL) 
    Xgc->graphic_engine->xset_curwin(Max(win,0),TRUE);
  else 
    Xgc= set_graphic_window_new(Max(win,0));
  /*
   * Gc of new window 
   */
  if ((Xgc = window_list_get_first())== NULL) return NULL;
  if ((F = nsp_check_for_figure(Xgc,FALSE))== NULL) return NULL;
  
  /* clean the figure */
  l =  nsp_list_length(F->obj->children);
  for ( i = 0 ; i < l  ; i++)
    nsp_list_remove_first(F->obj->children);
  /* create nswin axes */
  for ( i = 0 ; i < nswin ; i++) 
    {
      if ((axe = nsp_cmscope_new_axe(ncs[i],cstyle,-1,1))== NULL)
	return NULL;
      /* set the wrect */
      axe->obj->wrect->R[1]= ((double ) i)/nswin;
      axe->obj->wrect->R[3]= 1.0/nswin;
      /* store in Figure */
      if ( nsp_list_end_insert(F->obj->children,(NspObject *) axe)== FAIL) 
	{
	  nsp_axes_destroy(axe);
	  return NULL;
	}
      cstyle += ncs[i];
    }
  nsp_list_link_figure(F->obj->children, F->obj, NULL);
  nsp_figure_invalidate((NspGraphic *) F);
  return F;
}

void scicos_cmscope_block (scicos_block * block, int flag)
{
  char *str;
  BCG *Xgc;
  /* used to decode parameters by name */
  cmscope_ipar *csi = (cmscope_ipar *) GetIparPtrs (block);
  cmscope_rpar *csr = (cmscope_rpar *) GetRparPtrs (block);
  /* int nipar = GetNipar (block); */
  int cur = 0;
  /* number of curves in each subwin */
  int *nswin = ((int *) csi) +7 ;
  /* colors */
  int *colors = ((int *) csi) + 7 + csi->number_of_subwin;
  /* refresh period for each curve */
  double *period = ((double *) csr) + 1; 
  /* ymin,ymax for each curve */
  double *yminmax =((double *) csr) + 1 + csi->number_of_subwin;
  double t = scicos_get_scicos_time ();
  int wid = (csi->wid == -1) ? 20000 + scicos_get_block_number () : csi->wid;
  
  if (flag == 2)
    {
      int i;
      int ret;
      Cell *cloc;
      cmscope_data *D = (cmscope_data *) (*block->work);
      NspList *L =NULL;
      t = GetScicosTime (block);
      /*k = D->count;*/
      D->count++;
      D->tlast = t;
      if ( D->F->obj->ref_count <= 1 ) 
	{
	  /* Figure was destroyed during simulation */
	  return;
	}
      L= D->F->obj->children;
      /* insert the points */
      i=0;
      cloc = L->first ;
      while ( cloc != NULLCELL ) 
	{
	  if ( cloc->O != NULLOBJ ) 
	    {
	      double *u1 = GetRealInPortPtrs (block, i + 1);
	      NspAxes *axe = (NspAxes *) cloc->O;
	      /* add nu points for time t, nu is the number of curves */
	      ret=nsp_oscillo_add_point(axe->obj->children, t,period[i], u1,nswin[i]);
              if (ret==FALSE) {
                scicos_set_block_error (-16);
                return;
              }
	      i++;
	    }
	  cloc = cloc->next;
	}
      /* fprintf(stderr,"test for invalidate %d %d \n",D->count,csi->buffer_size); */
      if (  D->count %  csi->buffer_size == 0 ) 
	{
	  /* redraw each csi->buffer_size accumulated points 
	   * first check if we need to change the xscale 
	   */
	  nsp_cmscope_invalidate(D,t,period,yminmax);
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cmscope_data *D;
      /* create a figure with axes and qcurves  */
      NspFigure *F1,*F = nsp_cmscope_obj(wid,csi->number_of_subwin,nswin,colors,
					period, TRUE,yminmax);
      if (F == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (cmscope_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (cmscope_data *) (*block->work);
      /* keep a copy in case Figure is destroyed during simulation 
       * note that is a by reference object 
       */
      F1 = nsp_figure_copy(F);
      if ( F1 == NULL ) 
	{
	  scicos_set_block_error (-16);
	  return;
	}
      D->F = F1;
      D->count = 0;
      D->count_invalidates=0;
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
      cmscope_data *D = (cmscope_data *) (*block->work);
      if ( D->count_invalidates == 0 && D->F->obj->ref_count > 1 )
	{
	  /* figure was never invalidated and was not destroyed during simulation
	   * we update the graphics at the end  */
	  nsp_cmscope_invalidate(D,t,period,yminmax);
	}
      /* we have locally incremented the count of figure: thus 
       * we can destroy figure here. It will only decrement the ref 
       * counter
       */
      if ( D->F->obj->ref_count >= 1 ) 
	{
	  nsp_figure_destroy(D->F);
	}
      scicos_free (D);
    }
}

static void nsp_cmscope_invalidate(cmscope_data *D,double t,double *period, double *yminmax)
{
  int i=0;
  NspList *L= D->F->obj->children;
  Cell *cloc = cloc = L->first ;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  double ymin = yminmax[2*i];
	  double ymax = yminmax[2*i+1];
	  NspAxes *axe = (NspAxes *) cloc->O;
	  /* add nu points for time t, nu is the number of curves */
	  scicos_cscope_axes_update(axe,t,period[i],ymin,ymax);
	  nsp_axes_invalidate((NspGraphic *)axe);
	  i++;
	  D->count_invalidates ++;
	}
      cloc = cloc->next;
    }
}


/**
 * scicos_canimxy_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_canimxy_block(scicos_block * block, int flag)
{
  scicos_cscopxy_block(block,flag);
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

static int scicos_cscopxy_add_point(NspList *L,int animed,const double *x,const double *y, int n);
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
      int ret;
      double *u1 = GetRealInPortPtrs (block, 1);
      double *u2 = GetRealInPortPtrs (block, 2);
      cscope_data *D = (cscope_data *) (*block->work);
      if ( D->Axes->obj->ref_count <= 1 ) 
	{
	  /* Axes was destroyed during simulation */
	  return;
	}
      D->count++;
      D->tlast = t;
      /* add nu points for time t, nu is the number of curves */
      ret=scicos_cscopxy_add_point(D->L, csi->animed,u1, u2, nu);
      if (ret==FALSE) {
        scicos_set_block_error (-16);
        return;
      }
      if (  D->count % csi->n == 0 ) 
	{
	  /* redraw each csi->n accumulated points 
	   * first check if we need to change the xscale 
	   */
	  scicos_cscopxy_axes_update(D,csr->xmin, csr->xmax,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	  D->count_invalidates ++;
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cscope_data *D;
      NspList *L;
      int *width=NULL;
#define MAXXY 10
      int colors[MAXXY]; /* max number of curves ? */
      /* buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori except for the animated case
       */
      int scopebs = 10000;
      if ( csi->animed == 0 )
	{
	  /* when animated we just want to keep an horizon of n */
	  scopebs = csi->n;
	}
      /* create an axe with predefined limits */
      NspAxes *Axes,*Axes1;
      nu = Min(nu,MAXXY);
      for ( k= 0 ; k < MAXXY ; k++) colors[k]=csi->color+k;
      if ((width = scicos_malloc (sizeof (int)*nu)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      for(k=0;k<nu;k++) width[k]=csi->line_size;
      Axes=nsp_oscillo_obj (wid, nu, colors, width, scopebs, TRUE, -1, 1,qcurve_std, &L);
      scicos_free(width);
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
      /* keep a copy in case Axes is destroyed during simulation 
       * axe is a by reference object 
       */
      Axes1 = nsp_axes_copy(Axes);
      if ( Axes1 == NULL ) 
	{
	  scicos_set_block_error (-16);
	  return;
	}
      D->Axes = Axes1;
      D->L = L;
      D->count = 0;
      D->count_invalidates = 0;
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
      if ( D->count_invalidates == 0 && D->Axes->obj->ref_count >= 1 )
	{
	  /* figure was never invalidated and was not destroyed during simulation
	   * we update the graphics at the end  */
	  scicos_cscopxy_axes_update(D,csr->xmin, csr->xmax,csr->ymin,csr->ymax);
	  nsp_axes_invalidate((NspGraphic *) D->Axes);
	}
      /* we have locally incremented the count of Axes: thus 
       * we can destroy it here. It will only decrement the ref 
       * counter
       */
      if ( D->Axes->obj->ref_count >= 1 ) 
	{
	  nsp_axes_destroy(D->Axes);
	}
      scicos_free (D);
    }
}

static int scicos_cscopxy_add_point(NspList *L,int animed, const double *x,const double *y, int n)
{
  int count =0;
  Cell *Loc = L->first;
  while ( Loc != NULLCELL ) 
    {
      if ( Loc->O != NULLOBJ )
	{ 
	  NspQcurve *curve =(NspQcurve *) Loc->O;
	  if ( count >= n ) return TRUE;
          NspMatrix *M = curve->obj->Pts;
          /* enlarge qcurve to display all pts in the window if needed */
          if ( (((curve->obj->last)+1) == M->m) && (animed==1) )
	    {
	      if ((nsp_qcurve_enlarge(curve,M->m)) == FALSE) return FALSE;
	    }
	  nsp_qcurve_addpt(curve,&x[count],&y[count],1);
	  count++;
	}
      Loc = Loc->next;
    }
  return TRUE;
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
      tag = nsp_grlist_compute_inside_bounds(D->L,bounds);
    }
  if ( isinf(xmin) && tag == TRUE ) frect[0]= bounds[0];
  if ( isinf(xmax) && tag == TRUE ) frect[1]= bounds[1];
  if ( isinf(ymin) && tag == TRUE ) frect[2]= bounds[2];
  if ( isinf(ymax) && tag == TRUE ) frect[3]= bounds[3];
  memcpy(D->Axes->obj->frect->R,frect,4*sizeof(double));
  memcpy(D->Axes->obj->rect->R,frect,4*sizeof(double));
  D->Axes->obj->fixed = TRUE; 
}

/**
 * scicos_scalar2vector_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/
void scicos_scalar2vector_block (scicos_block * block, int flag)
{
  double *u1 = GetRealInPortPtrs (block, 1);
  double *y1 = GetRealOutPortPtrs (block, 1);
  int i;
  if (flag == 1)
    {
      for (i = 0; i < GetOutPortRows (block, 1); ++i)
	{
	  y1[i] = u1[0];
	}
    }
}

/**
 * scicos_cstblk4_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_cstblk4_block (scicos_block * block, int flag)
{
  /*
   * output a vector of constants out(i)=rpar(i)
   * rpar(1:nrpar) : given constants 
   */
  double *rpar = GetRparPtrs (block);
  int nrpar = GetNrpar (block);
  double *y1 = GetRealOutPortPtrs (block, 1);
  /* Copyright INRIA

     Scicos block simulator
     output a vector of constants out(i)=rpar(i)
     rpar(1:nrpar) : given constants */
  memcpy (y1, rpar, nrpar * sizeof (double));
}


/**
 * scicos_transmit_or_zero_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_transmit_or_zero_block (scicos_block * block, int flag)
{
  double **outptr = (double **) block->outptr;
  double **inptr =  (double **) block->inptr;
  int j;
  if (flag == 1)
    {
      if (block->ipar[0] == 1)
	for (j = 0; j < block->insz[0]; j++)
	  {
	    outptr[0][j] = inptr[0][j];
	  }
    }
}

/**
 * scicos_mvswitch_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_mvswitch_block (scicos_block * block, int flag)
{
  double **outptr = (double **) block->outptr;
  double **inptr =  (double **) block->inptr;
  /* switch selected with ipar  */
  int i, j = 0;
  j = Min (Max (block->ipar[0], 0), block->nin - 1);
  for (i = 0; i < block->insz[j]; i++)
    {
      outptr[0][i] = inptr[j][i];
    }
}


/**
 * scicos_csslti4_block:
 * @block: 
 * @flag: 
 * 
 * 
 **/

void scicos_csslti4_block (scicos_block * block, int flag)
{
  /*   continuous state space linear system simulator
   *   rpar(1:nx*nx)=A
   *   rpar(nx*nx+1:nx*nx+nx*nu)=B
   *   rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C
   *   rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D 
   */

  int un = 1, lb, lc, ld;
  int nx = GetNstate (block);
  double *x = GetState (block);
  double *xd = GetDerState (block);
  double *rpar = GetRparPtrs (block);
  double *y = GetRealOutPortPtrs (block, 1);
  double *u = GetRealInPortPtrs (block, 1);
  int noutsz = GetOutPortRows (block, 1);
  int ninsz = GetInPortRows (block, 1);

  lb = nx * nx;
  lc = lb + nx * ninsz;

  if (flag == 1 || flag == 6)
    {
      /* y=c*x+d*u     */
      ld = lc + nx * noutsz;
      if (nx == 0)
	{
	  nsp_calpack_dmmul (&rpar[ld], &noutsz, u, &ninsz, y, &noutsz,
			     &noutsz, &ninsz, &un);
	}
      else
	{
	  nsp_calpack_dmmul (&rpar[lc], &noutsz, x, &nx, y, &noutsz, &noutsz,
			     &nx, &un);
	  nsp_calpack_dmmul1 (&rpar[ld], &noutsz, u, &ninsz, y, &noutsz,
			      &noutsz, &ninsz, &un);
	}
    }

  else if (flag == 0)
    {
      /* xd=a*x+b*u */
      nsp_calpack_dmmul (&rpar[0], &nx, x, &nx, xd, &nx, &nx, &nx, &un);
      nsp_calpack_dmmul1 (&rpar[lb], &nx, u, &ninsz, xd, &nx, &nx, &ninsz,
			  &un);
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

void scicos_affich2_block (scicos_args_F0)
{
  NspGrstring **S= (NspGrstring **) &z__[0] ;
  --ipar;
  if (*flag__ == 1) {
    int cb = Scicos->params.curblk -1;
    NspGraphic *Gr = Scicos->Blocks[cb].grobj;
    *S = NULL;
    if ( Gr != NULL && IsCompound((NspObject *) Gr))
      *S = scicos_affich2_getstring((NspCompound *)Gr);
    /* draw the string matrix */
    if ( *S != NULL)
      scicos_affich2_update(*S,&ipar[5],u,ipar[7],*nu/ipar[7]);
  }
 /* else if (*flag__ == 4)
  *  {
  *    int cb = Scicos->params.curblk -1;
  *    NspGraphic *Gr = Scicos->Blocks[cb].grobj;
  *    *S = NULL;
  *    if ( Gr != NULL && IsCompound((NspObject *) Gr))
  *    {
  *      *S = scicos_affich2_getstring((NspCompound *)Gr);
  *    }
  *  }
  */
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
      char buf[1024];
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

void scicos_affich_block (scicos_args_F0)
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
}



/**
 * scicos_bouncexy_block:
 * @block: 
 * @flag: 
 * 
 * new nsp graphics jpc 
 **/

typedef struct _bouncexy_data bouncexy_data;

struct _bouncexy_data
{
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspFigure *F;
  NspList *L;   /* list of grarcs */
};

static NspAxes *nsp_bouncexy_new_axe(int nb,const int *colors,const double *xminmax)
{
  NspGraphic *gobj = NULL;
  double frect[4];
  char strflag[]="151";
  int i;
  /* create a new axes */
  NspAxes *axe= nsp_axes_create_default("axe");
  if ( axe == NULL) return NULL;
  frect[0]=xminmax[0];frect[1]=xminmax[2];frect[2]=xminmax[1];frect[3]=xminmax[3];
  /* create a set of arcs and insert them in axe */
  for ( i = 0 ; i < nb ; i++) 
    {
      int icolor=-1,iback=colors[i],ithickness=-1;
      if ((gobj =(NspGraphic *) nsp_grarc_create("arc",0,0,0.1,0.1,0,360*64,
						 iback,ithickness,icolor,0.0,NULL)) == NULL)
	    return NULL;
      if (  nsp_axes_insert_child(axe,(NspGraphic *) gobj, TRUE)== FAIL) 
	return NULL;
    }
  /* updates the axes scale information */
  nsp_strf_axes( axe , frect, strflag[1]);
  memcpy(axe->obj->frect->R,frect,4*sizeof(double));
  memcpy(axe->obj->rect->R,frect,4*sizeof(double));
  axe->obj->axes = 2;
  axe->obj->xlog = FALSE;
  axe->obj->ylog=  FALSE;
  axe->obj->iso = TRUE;
  axe->obj->fixed = TRUE;
  return axe;
}

/* nswin : number of subwindows
 * ncs[i] : number of curves in subsin i
 * style[k]: style for curve k 
 */

static NspFigure *nsp_bouncexy_obj(int win,int nb,const int *colors,const double *yminmax,
				   NspList **L)
{
  NspFigure *F;
  NspAxes *axe;
  BCG *Xgc;
  int i,l;
  /*
   * set current window
   */
  if ((Xgc = window_list_get_first()) != NULL) 
    Xgc->graphic_engine->xset_curwin(Max(win,0),TRUE);
  else 
    Xgc= set_graphic_window_new(Max(win,0));
  /*
   * Gc of new window 
   */
  if ((Xgc = window_list_get_first())== NULL) return NULL;
  if ((F = nsp_check_for_figure(Xgc,FALSE))== NULL) return NULL;
  
  /* clean the figure */
  l =  nsp_list_length(F->obj->children);
  for ( i = 0 ; i < l  ; i++)
    nsp_list_remove_first(F->obj->children);
  /* a new axe with arcs */
  if ((axe = nsp_bouncexy_new_axe(nb,colors,yminmax)) == NULL)
    return NULL;
  /* store in Figure */
  if ( nsp_list_end_insert(F->obj->children,(NspObject *) axe)== FAIL) 
    {
      nsp_axes_destroy(axe);
      return NULL;
    }
  nsp_list_link_figure(F->obj->children, F->obj, NULL);
  nsp_figure_invalidate((NspGraphic *) F);
  *L = axe->obj->children;
  return F;
}

void scicos_bouncexy_block (scicos_block * block, int flag)
{
  /* decode ipar : win,imode, colors[] */
  int *ipar = GetIparPtrs (block);
  /* int nipar = GetNipar (block); */
  int win = ipar[0], *colors = ipar + 2;
  /* int imode = ipar[1], */
  /* xmin,xmax,ymin,ymax */
  double *xminmax = GetRparPtrs (block);
  char *str;
  BCG *Xgc;
  int cur = 0;
  double t = scicos_get_scicos_time ();
  int wid = (win == -1) ? 20000 + scicos_get_block_number () : win;
  
  if (flag == 2)
    {
      bouncexy_data *D = (bouncexy_data *) (*block->work);
      Cell *cloc = NULL;
      double *u1 = GetRealInPortPtrs (block, 1);
      double *u2 = GetRealInPortPtrs (block, 2);
      double *z = GetDstate (block);
      int i=0;
      if ( D->F->obj->ref_count <= 1 ) 
	{
	  /* Figure was destroyed during simulation */
	  return;
	}
      cloc = D->L->first;
      /* 
	 t = GetScicosTime (block);
	 k = D->count;
	 D->count++;
	 D->tlast = t;
      */
      while ( cloc != NULLCELL ) 
	{
	  if ( cloc->O != NULLOBJ ) 
	    {
	      double size = z[6 * i + 2];
	      NspGrArc *A = (NspGrArc *)  cloc->O;
	      nsp_graphic_invalidate((NspGraphic *) A);
	      A->obj->x = u1[i] - size / 2;
	      A->obj->y = u2[i] + size / 2;
	      A->obj->w = A->obj->h = size;
	      nsp_graphic_invalidate((NspGraphic *) A);
	      i++;
	    }
	  cloc = cloc->next;
	}
    }
  else if (flag == 4)
    {
      int wdim[]={-1,-1};
      int wpos[]={-1,-1};
      int nballs = GetInPortRows (block, 1);
      /* balls radius in z[6 * i + 2] */
      /* double *z = GetDstate (block); */
      /* initialize a scope window */
      bouncexy_data *D;
      /* create a figure with axes and qcurves  */
      NspList *L = NULL;
      NspFigure *F1,*F = nsp_bouncexy_obj(wid,nballs,colors,xminmax,&L);
      if (F == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (bouncexy_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (bouncexy_data *) (*block->work);
      /* keep a copy in case Figure is destroyed during simulation 
       * note that is a by reference object 
       */
      F1 = nsp_figure_copy(F);
      if ( F1 == NULL ) 
	{
	  scicos_set_block_error (-16);
	  return;
	}
      D->F = F1;
      D->L = L;
      D->count = 0;
      D->tlast = t;
      Xgc = scicos_set_win (wid, &cur);
      if (wpos[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowpos (Xgc,wpos[0],wpos[1]);
	}
      if (wdim[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowdim (Xgc,wdim[0],wdim[1]);
	}
      str = block->label;
      if (str != NULL && strlen (str) != 0 && strcmp (str, " ") != 0)
	Xgc->graphic_engine->setpopupname (Xgc, str);
    }
  else if (flag == 5)
    {
      bouncexy_data *D = (bouncexy_data *) (*block->work);
      /* we have locally incremented the count of figure: thus 
       * we can destroy figure here. It will only decrement the ref 
       * counter
       */
      if ( D->F->obj->ref_count >= 1 ) 
	{
	  nsp_figure_destroy(D->F);
	}
      scicos_free (D);
    }
}




/**
 * scicos_cevscpe_block:
 * @block: 
 * @flag: 
 * 
 * a scope:
 * new nsp graphics jpc 
 **/

typedef struct _cevscpe_ipar cevscpe_ipar;
struct _cevscpe_ipar
{
  int wid, color_flag, colors[8], wpos[2], wdim[2];
};

typedef struct _cevscpe_data cevscpe_data;

struct _cevscpe_data
{
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspAxes *Axes;
  NspList *L;
};

void scicos_cevscpe_block (scicos_block * block, int flag)
{
  char *label = GetLabelPtrs (block);
  BCG *Xgc;
  /* used to decode parameters by name */
  cevscpe_ipar *csi = (cevscpe_ipar *) block->ipar;
  int nipar = GetNipar (block);
  int nbc = nipar - 6; /* nbre de couleur et de courbes */
  int *wpos = block->ipar + nipar -4;
  int *wdim = block->ipar + nipar -2;
  double *rpar = GetRparPtrs (block);
  double period = rpar[0];
  double t;
  int cur = 0,k;
  int wid = (csi->wid == -1) ? 20000 + scicos_get_block_number () : csi->wid;
  t = scicos_get_scicos_time ();
  
  if (flag == 2)
    {
      int ret;
      int i;
      double vals[10]; /* 10 max a revoir */
      cevscpe_data *D = (cevscpe_data *) (*block->work);
      if ( D->Axes->obj->ref_count <= 1 ) 
	{
	  /* Axes was destroyed during simulation */
	  return;
	}
      /*k = D->count;*/
      D->count++;
      D->tlast = t;
      /* A revoir */
      for (i = 0; i < nbc ; i++)
	{
	  vals[i]=0.0;
	  if ((GetNevIn (block) & (1 << i)) == (1 << i))
	    {
	      vals[i]= 0.8;
	    }
	}
      ret=nsp_oscillo_add_point(D->L, t,period, vals, nbc);
      if (ret==FALSE) {
        scicos_set_block_error (-16);
        return;
      }
      scicos_cscope_axes_update(D->Axes,t,period,0,1.0);
      nsp_axes_invalidate((NspGraphic *) D->Axes);
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      cevscpe_data *D;
      NspList *L;
      int *width=NULL;
      /* XXX :
       * buffer size for scope 
       * this should be set to the number of points to keep 
       * in order to cover a csr->per horizon. Unfortunately 
       * this number is not known a-priori.
       */
      int scopebs = 10000;
      if ((width = scicos_malloc (sizeof (int)*8)) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      for(k=0;k<8;k++) width[k]=0;
      /* create an axe with predefined limits */
      NspAxes *Axes1;
      NspAxes *Axes =
	nsp_oscillo_obj (wid, nbc , csi->colors, width, scopebs, TRUE, -1, 1,qcurve_stem, &L);
      scicos_free(width);
      if (Axes == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (cevscpe_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (cevscpe_data *) (*block->work);
      /* keep a copy in case Axes is destroyed during simulation 
       * axe is a by reference object 
       */
      Axes1 = nsp_axes_copy(Axes);
      if ( Axes1 == NULL ) 
	{
	  scicos_set_block_error (-16);
	  return;
	}
      D->Axes = Axes1;
      D->L = L;
      D->count = 0;
      D->tlast = t;
      Xgc = scicos_set_win (wid, &cur);
      if ( wpos[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowpos (Xgc, wpos[0],wpos[1]);
	}
      if ( wdim[0] >= 0)
	{
	  Xgc->graphic_engine->xset_windowdim (Xgc, wdim[0],wdim[1]);
	}
      label = block->label;
      if (label != NULL && strlen (label) != 0 && strcmp (label, " ") != 0)
	Xgc->graphic_engine->setpopupname (Xgc, label);
    }
  else if (flag == 5)
    {
      cevscpe_data *D = (cevscpe_data *) (*block->work);
      /* we have locally incremented the count of Axes: thus 
       * we can destroy it here. It will only decrement the ref 
       * counter
       */
      if ( D->Axes->obj->ref_count >= 1 ) 
	{
	  nsp_axes_destroy(D->Axes);
	}
      scicos_free (D);
    }
}


/**
 * nsp_oscillo_obj:
 * @win: integer giving the window id
 * @ncurves: number of curve to create in the graphic window
 * @style: style for each curve
 * @bufsize: size of points in each curve
 * @yfree: ignored (means that ymin and ymax can move freely).
 * @ymin: min y value 
 * @ymax: max y value 
 * @Lc: If requested returns the list of curves.
 * 
 * 
 * 
 * Returns: a #NspAxes or %NULL
 **/

static NspAxes *nsp_oscillo_obj(int win,int ncurves,int style[],int width[],int bufsize,
				int yfree,double ymin,double ymax,
				nsp_qcurve_mode mode,NspList **Lc)
{
  double frect[4];
  char strflag[]="151";
  NspFigure *F;
  NspAxes *axe;
  BCG *Xgc;
  char *curve_l=NULL;
  int i,l;
  /*
   * set current window
   */
  if ((Xgc = window_list_get_first()) != NULL) 
    Xgc->graphic_engine->xset_curwin(Max(win,0),TRUE);
  else 
    Xgc= set_graphic_window_new(Max(win,0));

  /*
   * Gc of new window 
   */
  if ((Xgc = window_list_get_first())== NULL) return NULL;
  if ((F = nsp_check_for_figure(Xgc,FALSE))== NULL) return NULL;
  
  /* clean the figure */
  l =  nsp_list_length(F->obj->children);
  for ( i = 0 ; i < l  ; i++)
    nsp_list_remove_first(F->obj->children);
  
  /* create a new axe */
  if ((axe=  nsp_check_for_axes(Xgc,NULL)) == NULL) return NULL;
  frect[0]=0;frect[1]=ymin;frect[2]=100;frect[3]=ymax;
  
  /* create a set of qcurves and insert them in axe */
  for ( i = 0 ; i < ncurves ; i++) 
    {
      int mark=-1;
      NspQcurve *curve;
      NspMatrix *Pts = nsp_matrix_create("Pts",'r',Max(bufsize,1),2); 
      if ( Pts == NULL) return NULL;
      if ( style[i] <= 0 ) mark = -style[i];
      curve= nsp_qcurve_create("curve",mark,width[i],0,( style[i] > 0 ) ?  style[i] : -1,
			       mode,Pts,curve_l,-1,-1,NULL);
      if ( curve == NULL) return NULL;
      /* insert the new curve */
      if ( nsp_axes_insert_child(axe,(NspGraphic *) curve,FALSE)== FAIL) 
	{
	  return NULL;
	}
    }
  /* updates the axes scale information */
  nsp_strf_axes( axe , frect, strflag[1]);
  memcpy(axe->obj->frect->R,frect,4*sizeof(double));
  memcpy(axe->obj->rect->R,frect,4*sizeof(double));
  axe->obj->axes = 1;
  axe->obj->xlog = FALSE;
  axe->obj->ylog=  FALSE;
  axe->obj->iso = FALSE;
  /* use free scales if requested  */
  axe->obj->fixed = ( yfree == TRUE ) ? FALSE: TRUE ;
  nsp_axes_invalidate((NspGraphic *) axe);
  if ( Lc != NULL) *Lc = axe->obj->children;
  return axe;
}

/* add one point for each curve in qcurve data  */

static int nsp_oscillo_add_point(NspList *L,double t,double period,const double *y, int n)
{
  int count =0;
  Cell *Loc = L->first;
  while ( Loc != NULLCELL ) 
    {
      if ( Loc->O != NULLOBJ )
	{ 
	  NspQcurve *curve =(NspQcurve *) Loc->O;
	  if ( count >= n ) return TRUE;
          NspMatrix *M = curve->obj->Pts;
          /* enlarge qcurve to display all pts in the period if needed */
          /* fprintf(stderr,"curve(%d) : C->obj->last=%d,M->m=%d,t=%f,period=%f\n",
	     count,curve->obj->last,M->m,t,period); */
          if ( (((curve->obj->last)+1) == M->m) && (t<period) ) {
            if ((nsp_qcurve_enlarge(curve,M->m)) == FALSE) return FALSE;
          }
	  /* fprintf(stderr,"curve(%d) : t=%f, y=%f\n",count,t,y[count]); */
	  nsp_qcurve_addpt(curve,&t,&y[count],1);
	  count++;
	}
      Loc = Loc->next;
    }
  return TRUE;
}
