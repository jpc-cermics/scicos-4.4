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

/* This module encloses set of 'new' scicos blocks
 */

#include "blocks.h"

/* to be moved elsewhere XXXX  */
#if WIN32
extern double asinh (double x);
extern double acosh (double x);
extern double atanh (double x);
#endif

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

