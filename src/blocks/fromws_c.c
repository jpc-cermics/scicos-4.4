/* Nsp
 * Copyright (C) 2007-2010 Masoud Najafi and Alan Layec Inria/Metalau and 
 *                         Jean-Philippe Chancelier Enpc/Cermics
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
 * rewriten for Nsp: Jean-Philippe Chancelier.
 *--------------------------------------------------------------------------*/

#include "blocks.h"
#include <nsp/matrix.h>
#include <nsp/imatrix.h>
#include <nsp/cells.h>
#include <nsp/hash.h>
#include <nsp/datas.h>


typedef struct _fromws_data fromws_data;

struct _fromws_data
{
  NspMatrix *time; /* matrix to store time */
  NspCells *values; /* cell array to store values */
  int m,n,type;     /* each value in values is a mxn matrix of type type */
  char name[32];
};

static int nsp_fromws_acquire_data(const char *name,fromws_data **D,int m,int n,int type);

void fromws_c (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  int *_ipar = GetIparPtrs (block);
  int my = GetOutPortRows (block, 1);	/* number of rows of Outputs */
  int ny = GetOutPortCols (block, 1);	/* number of cols of Outputs */
  int ytype = GetOutType (block, 1);	/* output type */
  double *_evout = GetNevOutPtrs (block);
  
  /* 
     Fnlength = _ipar[0];
     FName = _ipar + 1;
     Method = _ipar[1 + Fnlength];
     ZC = _ipar[2 + Fnlength];
     OutEnd = _ipar[3 + Fnlength];
  */

  if (flag == 4)
    {
      fromws_data *D;
      int i;
      char name[32];
      for ( i = 0 ; i <  _ipar[0];i++) name[i]= *( _ipar + 1+i);
      name[i]='\0';
      if (nsp_fromws_acquire_data(name,&D,my,ny,ytype)==FAIL) 
	{
	  Coserror ("Cannot acquire data '%s' \n",name);
	  return;
	}
      *block->work = D;
    }
  else if (flag == 1)
    {
      fromws_data *D = (fromws_data *) (*block->work);
      Sciprintf ("fromws_c is to be done for nsp \n");
    }
  else if (flag == 3)
    {
      fromws_data *D = (fromws_data *) (*block->work);
      Sciprintf ("fromws_c is to be done for nsp \n");
    }
  else if (flag == 5)
    {
      fromws_data *D = (fromws_data *) (*block->work);
      Sciprintf ("fromws_c is to be done for nsp \n");
    }
}


#if 0

#define T0        ptr->workt[0]
#define TNm1      ptr->workt[nPoints-1]
#define TP        (TNm1-0)

int Mytridiagldltsolve (double *d, double *l, double *b, int n);
int Myevalhermite2 (const double *t, double *xa, double *xb, double *ya,
		    double *yb, double *da, double *db, double *h, double *dh,
		    double *ddh, double *dddh, int *i);

/* work struct for that block */
typedef struct
{
  int nPoints;
  int Hmat;
  int Yt;
  int Yst;
  int cnt1;
  int cnt2;
  int EVindex;
  int PerEVcnt;
  int firstevent;
  double *D;
  void *work;
  double *workt;
} fromwork_struct;

void fromws_c (scicos_block * block, int flag)
{
  double t, y1, y2, t1, t2, r;
  double *spline, *A_d, *A_sd, *qdy;
  double d1, d2, h, dh, ddh, dddh;
  /* counter and indexes variables */
  int i, inow;
  int j, jfirst;
  int cnt1, cnt2, EVindex, PerEVcnt;

  /* variables for type and dims of data coming from scilab */
  int Ytype, YsubType, mY, nY;
  int nPoints;
  int Ydim[10];
  
  /* variables for type and dims of data of the output port block */
  int ytype, my, ny;

  /* generic pointer */
  SCSREAL_COP *y_d, *y_cd, *ptr_d, *ptr_T, *ptr_D;
  SCSINT8_COP *y_c, *ptr_c;
  SCSUINT8_COP *y_uc, *ptr_uc;
  SCSINT16_COP *y_s, *ptr_s;
  SCSUINT16_COP *y_us, *ptr_us;
  SCSINT32_COP *y_l, *ptr_l;
  SCSUINT32_COP *y_ul, *ptr_ul;

  /* init */
  if (flag == 4)
    {
      /* allocation of the work structure of that block */
      if ((*(_work) =
	   (fromwork_struct *) scicos_malloc (sizeof (fromwork_struct))) ==
	  NULL)
	{
	  set_block_error (-16);
	  C2F (mclose) (&fd, &res);
	  return;
	}
      ptr = *(_work);
      ptr->D = NULL;
      ptr->workt = NULL;
      ptr->work = NULL;

      /*================================*/
      /* check for an increasing time data */
      for (j = 0; j < nPoints - 1; j++)
	{
	  if (ptr_T[j] > ptr_T[j + 1])
	    {
	      Coserror ("The time vector should be an increasing vector.\n");
	      /*set_block_error(-3); */
	      *(_work) = NULL;
	      scicos_free (ptr->workt);
	      scicos_free (ptr->work);
	      scicos_free (ptr);
	      return;
	    }
	}
      /*=================================*/
      if ((Method > 1) && (Ytype == 1) && (!ptr->Hmat))
	{			/* double or complex */

	  if (YsubType == 0)
	    {			/*real */
	      if ((ptr->D =
		   (double *) scicos_malloc (nPoints * mY *
					     sizeof (double))) == NULL)
		{
		  set_block_error (-16);
		  *(_work) = NULL;
		  scicos_free (ptr->workt);
		  scicos_free (ptr->work);
		  scicos_free (ptr);
		  return;
		}
	    }
	  else
	    {			/*complex */
	      if ((ptr->D =
		   (double *) scicos_malloc (2 * nPoints * mY *
					     sizeof (double))) == NULL)
		{
		  set_block_error (-16);
		  *(_work) = NULL;
		  scicos_free (ptr->workt);
		  scicos_free (ptr->work);
		  scicos_free (ptr);
		  return;
		}
	    }

	  if ((spline =
	       (double *) scicos_malloc ((3 * nPoints - 2) *
					 sizeof (double))) == NULL)
	    {
	      Coserror ("Allocation problem in spline.\n");
	      /*set_block_error(-16); */
	      *(_work) = NULL;
	      scicos_free (ptr->D);
	      scicos_free (ptr->workt);
	      scicos_free (ptr->work);
	      scicos_free (ptr);
	      return;
	    }

	  A_d = spline;
	  A_sd = A_d + nPoints;
	  qdy = A_sd + nPoints - 1;

	  for (j = 0; j < mY; j++)
	    {			/* real part */
	      for (i = 0; i <= nPoints - 2; i++)
		{
		  A_sd[i] = 1.0 / (ptr_T[i + 1] - ptr_T[i]);
		  qdy[i] =
		    (ptr_d[i + 1 + j * nPoints] -
		     ptr_d[i + j * nPoints]) * A_sd[i] * A_sd[i];
		}

	      for (i = 1; i <= nPoints - 2; i++)
		{
		  A_d[i] = 2.0 * (A_sd[i - 1] + A_sd[i]);
		  ptr->D[i + j * nPoints] = 3.0 * (qdy[i - 1] + qdy[i]);
		}

	      if (Method == 2)
		{
		  A_d[0] = 2.0 * A_sd[0];
		  ptr->D[0 + j * nPoints] = 3.0 * qdy[0];
		  A_d[nPoints - 1] = 2.0 * A_sd[nPoints - 2];
		  ptr->D[nPoints - 1 + j * nPoints] = 3.0 * qdy[nPoints - 2];
		  Mytridiagldltsolve (A_d, A_sd, &ptr->D[j * nPoints],
				      nPoints);
		}

	      if (Method == 3)
		{
		  /*  s'''(x(2)-) = s'''(x(2)+) */
		  r = A_sd[1] / A_sd[0];
		  A_d[0] = A_sd[0] / (1.0 + r);
		  ptr->D[j * nPoints] =
		    ((3.0 * r + 2.0) * qdy[0] +
		     r * qdy[1]) / ((1.0 + r) * (1.0 + r));
		  /*  s'''(x(n-1)-) = s'''(x(n-1)+) */
		  r = A_sd[nPoints - 3] / A_sd[nPoints - 2];
		  A_d[nPoints - 1] = A_sd[nPoints - 2] / (1.0 + r);
		  ptr->D[nPoints - 1 + j * nPoints] =
		    ((3.0 * r + 2.0) * qdy[nPoints - 2] +
		     r * qdy[nPoints - 3]) / ((1.0 + r) * (1.0 + r));
		  Mytridiagldltsolve (A_d, A_sd, &ptr->D[j * nPoints],
				      nPoints);
		}
	    }

	  if (YsubType == 1)
	    {			/* imag part */
	      for (j = 0; j < mY; j++)
		{
		  for (i = 0; i <= nPoints - 2; i++)
		    {
		      A_sd[i] = 1.0 / (ptr_T[i + 1] - ptr_T[i]);
		      qdy[i] =
			(ptr_d[nPoints + i + 1 + j * nPoints] -
			 ptr_d[nPoints + i +
			       j * nPoints]) * A_sd[i] * A_sd[i];
		    }

		  for (i = 1; i <= nPoints - 2; i++)
		    {
		      A_d[i] = 2.0 * (A_sd[i - 1] + A_sd[i]);
		      ptr->D[i + j * nPoints + nPoints] =
			3.0 * (qdy[i - 1] + qdy[i]);
		    }

		  if (Method == 2)
		    {
		      A_d[0] = 2.0 * A_sd[0];
		      ptr->D[nPoints + 0 + j * nPoints] = 3.0 * qdy[0];
		      A_d[nPoints - 1] = 2.0 * A_sd[nPoints - 2];
		      ptr->D[nPoints + nPoints - 1 + j * nPoints] =
			3.0 * qdy[nPoints - 2];
		      Mytridiagldltsolve (A_d, A_sd,
					  &ptr->D[nPoints + j * nPoints],
					  nPoints);
		    }

		  if (Method == 3)
		    {
		      /*  s'''(x(2)-) = s'''(x(2)+) */
		      r = A_sd[1] / A_sd[0];
		      A_d[0] = A_sd[0] / (1.0 + r);
		      ptr->D[nPoints + j * nPoints] =
			((3.0 * r + 2.0) * qdy[0] +
			 r * qdy[1]) / ((1.0 + r) * (1.0 + r));
		      /*  s'''(x(n-1)-) = s'''(x(n-1)+) */
		      r = A_sd[nPoints - 3] / A_sd[nPoints - 2];
		      A_d[nPoints - 1] = A_sd[nPoints - 2] / (1.0 + r);
		      ptr->D[nPoints + nPoints - 1 + j * nPoints] =
			((3.0 * r + 2.0) * qdy[nPoints - 2] +
			 r * qdy[nPoints - 3]) / ((1.0 + r) * (1.0 + r));
		      Mytridiagldltsolve (A_d, A_sd,
					  &ptr->D[nPoints + j * nPoints],
					  nPoints);
		    }
		}
	    }

	  scicos_free (spline);
	}
      /*===================================*/
      cnt1 = nPoints - 1;
      cnt2 = nPoints;
      for (i = 0; i < nPoints; i++)
	{			/* finding the first positive time instant */
	  if (ptr->workt[i] >= 0)
	    {
	      cnt1 = i - 1;
	      cnt2 = i;
	      break;
	    }
	}
      ptr->nPoints = nPoints;
      ptr->Yt = Ytype;
      ptr->Yst = YsubType;
      ptr->cnt1 = cnt1;
      ptr->cnt2 = cnt2;
      ptr->EVindex = 0;
      ptr->PerEVcnt = 0;
      ptr->firstevent = 1;
      return;
      /*******************************************************/
      /*******************************************************/
    }
  else if (flag == 1)
    {				/* output computation */

      /* retrieve ptr of the structure of that block */
      ptr = *(_work);
      nPoints = ptr->nPoints;
      cnt1 = ptr->cnt1;
      cnt2 = ptr->cnt2;
      EVindex = ptr->EVindex;
      PerEVcnt = ptr->PerEVcnt;

      /* get current simulation time */
      t = GetScicosTime (block);
      t1 = t;

      if (ZC == 1)
	{			/*zero crossing enable */
	  if (OutEnd == 2)
	    {
	      t -= (PerEVcnt) * TP;
	    }
	  inow = nPoints - 1;
	  for (i = cnt1; i < nPoints; i++)
	    {
	      if (i == -1)
		{
		  continue;
		}
	      if (t < ptr->workt[i])
		{
		  inow = i - 1;
		  if (inow < cnt2)
		    {
		      cnt2 = inow;
		    }
		  else
		    {
		      cnt1 = cnt2;
		      cnt2 = inow;
		    }
		  break;
		}
	    }
	}
      else
	{			/*zero crossing disable */
	  if (OutEnd == 2)
	    {
	      if (TP != 0)
		{
		  r = floor ((t / TP));
		}
	      else
		{
		  r = 0;
		}
	      t -= ((int) r) * TP;
	    }
	  inow = nPoints - 1;
	  for (i = 0; i < nPoints; i++)
	    {
	      if (t < ptr->workt[i])
		{
		  inow = i - 1;
		  break;
		}
	    }
	}

      ptr->cnt1 = cnt1;
      ptr->cnt2 = cnt2;
      ptr->EVindex = EVindex;
      ptr->PerEVcnt = PerEVcnt;

      /***************************/
      /* hypermatrix case */
      if (ptr->Hmat)
	{

	  for (j = 0; j < my * ny; j++)
	    {
	      if (ptr->Yt == 1)
		{
		  if (ptr->Yst == 0)
		    {		/* real case */
		      y_d = GetRealOutPortPtrs (block, 1);
		      ptr_d = (double *) ptr->work;

		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_d[j] = 0.0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_d[j] = ptr_d[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_d[j] = 0.0;
			    }
			  else
			    {
			      y_d[j] = ptr_d[inow * ny * my + j];
			    }
			}
		    }
		  else
		    {		/* complexe case */
		      y_d = GetRealOutPortPtrs (block, 1);
		      y_cd = GetImagOutPortPtrs (block, 1);
		      ptr_d = (double *) ptr->work;

		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_d[j] = 0.0;	/* outputs set to zero */
			      y_cd[j] = 0.0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_d[j] = ptr_d[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			      y_cd[j] = ptr_d[nPoints * my * ny + (nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_d[j] = 0.0;	/* outputs set to zero */
			      y_cd[j] = 0.0;	/* outputs set to zero */
			    }
			  else
			    {
			      y_d[j] = ptr_d[inow * ny * my + j];
			      y_cd[j] =
				ptr_d[nPoints * my * ny + inow * ny * my + j];
			    }
			}
		    }
		}
	      else if (ptr->Yt == 8)
		{
		  switch (ptr->Yst)
		    {
		    case 1:	/* ---------------------int8 char  ---------------------------- */
		      y_c = Getint8OutPortPtrs (block, 1);
		      ptr_c = (char *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_c[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_c[j] = ptr_c[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_c[j] = 0;
			    }
			  else
			    {
			      y_c[j] = ptr_c[inow * ny * my + j];
			    }
			}
		      break;

		    case 2:	/* ---------------------int16 short--------------------- */
		      y_s = Getint16OutPortPtrs (block, 1);
		      ptr_s = (SCSINT16_COP *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_s[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_s[j] = ptr_s[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_s[j] = 0;
			    }
			  else
			    {
			      y_s[j] = ptr_s[inow * ny * my + j];
			    }
			}
		      break;

		    case 4:	/* ---------------------int32 long--------------------- */
		      y_l = Getint32OutPortPtrs (block, 1);
		      ptr_l = (SCSINT32_COP *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_l[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_l[j] = ptr_l[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_l[j] = 0;
			    }
			  else
			    {
			      y_l[j] = ptr_l[inow * ny * my + j];
			    }
			}
		      break;

		    case 11:
		      /*--------------------- uint8 uchar---------------------*/
		      y_uc = Getuint8OutPortPtrs (block, 1);
		      ptr_uc = (SCSUINT8_COP *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_uc[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_uc[j] = ptr_uc[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_uc[j] = 0;
			    }
			  else
			    {
			      y_uc[j] = ptr_uc[inow * ny * my + j];
			    }
			}
		      break;

		    case 12:	/* ---------------------uint16 ushort--------------------- */
		      y_us = Getuint16OutPortPtrs (block, 1);
		      ptr_us = (SCSUINT16_COP *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_us[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_us[j] = ptr_us[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_us[j] = 0;
			    }
			  else
			    {
			      y_us[j] = ptr_us[inow * ny * my + j];
			    }
			}
		      break;

		    case 14:	/* ---------------------uint32 ulong--------------------- */
		      y_ul = Getuint32OutPortPtrs (block, 1);
		      ptr_ul = (SCSUINT32_COP *) ptr->work;
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_ul[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_ul[j] = ptr_ul[(nPoints - 1) * ny * my + j];	/* hold outputs at the end */
			    }
			}
		      else
			{
			  if (inow < 0)
			    {
			      y_ul[j] = 0;
			    }
			  else
			    {
			      y_ul[j] = ptr_ul[inow * ny * my + j];
			    }
			}
		      break;
		    }
		}
	    }			/* for j loop */
	}
      /****************************/
      /* scalar of vectorial case */
      else
	{
	  for (j = 0; j < my; j++)
	    {
	      if (ptr->Yt == 1)
		{
		  if ((ptr->Yst == 0) || (ptr->Yst == 1))
		    {		/*  if Real or complex */
		      y_d = GetRealOutPortPtrs (block, 1);
		      ptr_d = (double *) ptr->work;
		      ptr_D = (double *) ptr->D;

		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_d[j] = 0.0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_d[j] = ptr_d[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_d[j] = 0.0;
			    }
			  else
			    {
			      y_d[j] = ptr_d[inow + (j) * nPoints];
			    }
			}
		      else if (Method == 1)
			{
			  if (inow < 0)
			    {
			      inow = 0;
			    }
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = ptr_d[inow + j * nPoints];
			  y2 = ptr_d[inow + 1 + j * nPoints];
			  y_d[j] = (y2 - y1) * (t - t1) / (t2 - t1) + y1;
			}
		      else if (Method >= 2)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = ptr_d[inow + j * nPoints];
			  y2 = ptr_d[inow + 1 + j * nPoints];
			  d1 = ptr_D[inow + j * nPoints];
			  d2 = ptr_D[inow + 1 + j * nPoints];
			  Myevalhermite2 (&t, &t1, &t2, &y1, &y2, &d1, &d2,
					  &h, &dh, &ddh, &dddh, &inow);
			  y_d[j] = h;
			}
		    }
		  if (ptr->Yst == 1)
		    {		/*  --------------complex---------------------- */
		      y_cd = GetImagOutPortPtrs (block, 1);
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_cd[j] = 0.0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_cd[j] = ptr_d[nPoints * my + nPoints - 1 + (j) * nPoints];	// hold outputs at the end
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_cd[j] = 0.0;	/* outputs set to zero */
			    }
			  else
			    {
			      y_cd[j] =
				ptr_d[nPoints * my + inow + (j) * nPoints];
			    }
			}
		      else if (Method == 1)
			{
			  if (inow < 0)
			    {
			      inow = 0;
			    }	/* extrapolation for 0<t<X(0) */
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = ptr_d[nPoints * my + inow + j * nPoints];
			  y2 = ptr_d[nPoints * my + inow + 1 + j * nPoints];
			  y_cd[j] = (y2 - y1) * (t - t1) / (t2 - t1) + y1;
			}
		      else if (Method >= 2)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = ptr_d[inow + j * nPoints + nPoints];
			  y2 = ptr_d[inow + 1 + j * nPoints + nPoints];
			  d1 = ptr_D[inow + j * nPoints + nPoints];
			  d2 = ptr_D[inow + 1 + j * nPoints + nPoints];
			  Myevalhermite2 (&t, &t1, &t2, &y1, &y2, &d1, &d2,
					  &h, &dh, &ddh, &dddh, &inow);
			  y_cd[j] = h;
			}
		    }
		}
	      else if (ptr->Yt == 8)
		{
		  switch (ptr->Yst)
		    {
		    case 1:	/* ---------------------int8 char  ---------------------------- */
		      y_c = Getint8OutPortPtrs (block, 1);
		      ptr_c = (char *) ptr->work;
		      /*y_c[j]=ptr_c[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_c[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_c[j] = ptr_c[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_c[j] = 0;
			    }
			  else
			    {
			      y_c[j] = ptr_c[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  if (inow < 0)
			    {
			      inow = 0;
			    }
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_c[inow + j * nPoints];
			  y2 = (double) ptr_c[inow + 1 + j * nPoints];
			  y_c[j] =
			    (char) ((y2 - y1) * (t - t1) / (t2 - t1) + y1);
			}
		      break;
		    case 2:	/* ---------------------int16 short--------------------- */
		      y_s = Getint16OutPortPtrs (block, 1);
		      ptr_s = (SCSINT16_COP *) ptr->work;
		      /* y_s[j]=ptr_s[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_s[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_s[j] = ptr_s[nPoints - 1 + (j) * nPoints];	// hold outputs at the end
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_s[j] = 0;
			    }
			  else
			    {
			      y_s[j] = ptr_s[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  if (inow < 0)
			    {
			      inow = 0;
			    }
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_s[inow + j * nPoints];
			  y2 = (double) ptr_s[inow + 1 + j * nPoints];
			  y_s[j] =
			    (SCSINT16_COP) ((y2 - y1) * (t - t1) / (t2 - t1) +
					    y1);
			}
		      break;
		    case 4:	/* ---------------------int32 long--------------------- */
		      y_l = Getint32OutPortPtrs (block, 1);
		      ptr_l = (SCSINT32_COP *) ptr->work;
		      /*y_l[j]=ptr_l[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_l[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_l[j] = ptr_l[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_l[j] = 0;
			    }
			  else
			    {
			      y_l[j] = ptr_l[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_l[inow + j * nPoints];
			  y2 = (double) ptr_l[inow + 1 + j * nPoints];
			  y_l[j] =
			    (SCSINT32_COP) ((y2 - y1) * (t - t1) / (t2 - t1) +
					    y1);
			}
		      break;
		    case 11:
		      /*--------------------- uint8 uchar---------------------*/
		      y_uc = Getuint8OutPortPtrs (block, 1);
		      ptr_uc = (SCSUINT8_COP *) ptr->work;
		      /*y_uc[j]=ptr_uc[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_uc[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_uc[j] = ptr_uc[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_uc[j] = 0;
			    }
			  else
			    {
			      y_uc[j] = ptr_uc[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_uc[inow + j * nPoints];
			  y2 = (double) ptr_uc[inow + 1 + j * nPoints];
			  y_uc[j] =
			    (SCSUINT8_COP) ((y2 - y1) * (t - t1) / (t2 - t1) +
					    y1);
			}
		      break;
		    case 12:	/* ---------------------uint16 ushort--------------------- */
		      y_us = Getuint16OutPortPtrs (block, 1);
		      ptr_us = (SCSUINT16_COP *) ptr->work;
		      /* y_us[j]=ptr_us[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_us[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_us[j] = ptr_us[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_us[j] = 0;
			    }
			  else
			    {
			      y_us[j] = ptr_us[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_us[inow + j * nPoints];
			  y2 = (double) ptr_us[inow + 1 + j * nPoints];
			  y_us[j] =
			    (SCSUINT16_COP) ((y2 - y1) * (t - t1) / (t2 -
								     t1) +
					     y1);
			}
		      break;
		    case 14:	/* ---------------------uint32 ulong--------------------- */
		      y_ul = Getuint32OutPortPtrs (block, 1);
		      ptr_ul = (SCSUINT32_COP *) ptr->work;
		      /* y_ul[j]=ptr_ul[inow+(j)*nPoints]; */
		      if (inow >= nPoints - 1)
			{
			  if (OutEnd == 0)
			    {
			      y_ul[j] = 0;	/* outputs set to zero */
			    }
			  else if (OutEnd == 1)
			    {
			      y_ul[j] = ptr_ul[nPoints - 1 + (j) * nPoints];	/* hold outputs at the end */
			    }
			}
		      else if (Method == 0)
			{
			  if (inow < 0)
			    {
			      y_ul[j] = 0;
			    }
			  else
			    {
			      y_ul[j] = ptr_ul[inow + (j) * nPoints];
			    }
			}
		      else if (Method >= 1)
			{
			  t1 = ptr->workt[inow];
			  t2 = ptr->workt[inow + 1];
			  y1 = (double) ptr_ul[inow + j * nPoints];
			  y2 = (double) ptr_ul[inow + 1 + j * nPoints];
			  y_ul[j] =
			    (SCSUINT32_COP) ((y2 - y1) * (t - t1) / (t2 -
								     t1) +
					     y1);
			}
		      break;
		    }
		}
	    }			/* for j loop */
	}
      /********************************************************************/
    }
  else if (flag == 3)
    {				/* event date computation */
      /* retrieve ptr of the structure of that block */
      ptr = *(_work);
      nPoints = ptr->nPoints;
      cnt1 = ptr->cnt1;
      cnt2 = ptr->cnt2;
      EVindex = ptr->EVindex;
      PerEVcnt = ptr->PerEVcnt;

      /* get current simulation time */
      t = GetScicosTime (block);

      if (ZC == 1)
	{			/* generate Events only if ZC is active */
	  if ((Method == 1) || (Method == 0))
	    {
	      /*-------------------------*/
	      if (ptr->firstevent == 1)
		{
		  jfirst = nPoints - 1;	/* finding first positive time instant */
		  for (j = 0; j < nPoints; j++)
		    {
		      if (ptr->workt[j] > 0)
			{
			  jfirst = j;
			  break;
			}
		    }
		  _evout[0] = ptr->workt[jfirst];
		  EVindex = jfirst;
		  ptr->EVindex = EVindex;
		  ptr->firstevent = 0;
		  return;
		}
	      /*------------------------*/
	      i = EVindex;
	      /*------------------------*/
	      if (i < nPoints - 1)
		{
		  _evout[0] = ptr->workt[i + 1] - ptr->workt[i];
		  EVindex = i + 1;
		}
	      /*------------------------*/
	      if (i == nPoints - 1)
		{
		  if (OutEnd == 2)
		    {		/*  Periodic */
		      cnt1 = -1;
		      cnt2 = 0;
		      PerEVcnt++;	/* When OutEnd==2 (perodic output) */
		      jfirst = nPoints - 1;	/* finding first positive time instant */
		      for (j = 0; j < nPoints; j++)
			{
			  if (ptr->workt[j] > 0)
			    {
			      jfirst = j;
			      break;
			    }
			}
		      _evout[0] = ptr->workt[jfirst];
		      EVindex = jfirst;
		    }
		}
	      /*-------------------------- */
	    }
	  else if (Method <= 3)
	    {
	      if (ptr->firstevent == 1)
		{
		  _evout[0] = TP;
		  ptr->firstevent = 0;
		}
	      else
		{
		  if (OutEnd == 2)
		    {
		      _evout[0] = TP;
		    }
		  PerEVcnt++;
		}
	      cnt1 = -1;
	      cnt2 = 0;
	    }
	  ptr->cnt1 = cnt1;
	  ptr->cnt2 = cnt2;
	  ptr->EVindex = EVindex;
	  ptr->PerEVcnt = PerEVcnt;
	}
      /***********************************************************************/
    }
  else if (flag == 5)
    {				/* finish */
      ptr = *(_work);
      if (ptr != NULL)
	{
	  if (ptr->D != NULL)
	    {
	      scicos_free (ptr->D);
	    }
	  if (ptr->work != NULL)
	    {
	      scicos_free (ptr->work);
	    }
	  if (ptr->workt != NULL)
	    {
	      scicos_free (ptr->workt);
	    }
	  scicos_free (ptr);
	}
    }
  /*************************************************************************/
}

int Ishm (int *fd, int *Ytype, int *nPoints, int *my, int *ny, int *YsubType)
{
  int *ptr_i;
  int j, ierr;

  /*work array to store header of hypermat */
  if ((ptr_i = (int *) scicos_malloc (37 * sizeof (int))) == NULL)
    {
      return 0;
    }

  C2F (mgetnc) (fd, ptr_i, (j = 37, &j), fmti, &ierr);	/* read sci id */
  if (ierr != 0)
    {
      return 0;
    }

  if ((ptr_i[0] != 3) ||
      (ptr_i[1] != 1) ||
      (ptr_i[5] != 10) ||
      (ptr_i[6] != 1) ||
      (ptr_i[7] != 3) ||
      (ptr_i[8] != 0) ||
      (ptr_i[9] != 1) ||
      (ptr_i[10] != ptr_i[9] + 2) ||
      (ptr_i[11] != ptr_i[10] + 4) ||
      (ptr_i[12] != ptr_i[11] + 7) ||
      (ptr_i[13] != 17) ||
      (ptr_i[14] != 22) ||
      (ptr_i[15] != 13) ||
      (ptr_i[16] != 18) ||
      (ptr_i[17] != 22) ||
      (ptr_i[18] != 28) ||
      (ptr_i[19] != 14) ||
      (ptr_i[20] != 23) ||
      (ptr_i[21] != 29) ||
      (ptr_i[22] != 27) ||
      (ptr_i[23] != 18) ||
      (ptr_i[24] != 14) ||
      (ptr_i[25] != 28) ||
      (ptr_i[26] != 8) ||
      (ptr_i[27] != 1) || (ptr_i[28] != 3) || (ptr_i[29] != 4))
    {
      Coserror ("Invalid variable type : error in hypermat scilab coding.\n");
      return 0;
    }

  *my = ptr_i[30];		/*37 */
  *ny = ptr_i[31];		/*38 */
  *nPoints = ptr_i[32];		/*39 */
  *Ytype = ptr_i[33];		/*40 */

  if ((ptr_i[34] != ptr_i[30] * ptr_i[31] * ptr_i[32]) || (ptr_i[35] != 1))
    {
      Coserror ("Invalid variable type : error in hypermat scilab coding.\n");
      return 0;
    }

  *YsubType = ptr_i[36];	/*43 */

  scicos_free (ptr_i);
  return 1;
}

int Mytridiagldltsolve (double *dA, double *lA, double *B, int N)
{
  double Temp;
  int j;

  for (j = 1; j <= N - 1; ++j)
    {
      Temp = lA[j - 1];
      lA[j - 1] /= dA[j - 1];
      B[j] -= lA[j - 1] * B[j - 1];
      dA[j] -= Temp * lA[j - 1];
    }

  B[N - 1] /= dA[N - 1];
  for (j = N - 2; j >= 0; --j)
    {
      B[j] = -lA[j] * B[j + 1] + B[j] / dA[j];
    }

  return 0;
}


int Myevalhermite2 (const double *t, double *x1, double *x2, double *y1,
		    double *y2, double *d1, double *d2, double *z, double *dz,
		    double *ddz, double *dddz, int *k)
{
  double Temp, p, p2, p3, D;
  Temp = *t - *x1;
  D = 1.0 / (*x2 - *x1);
  p = (*y2 - *y1) * D;
  p2 = (p - *d1) * D;
  p3 = (*d2 - p + (*d1 - p)) * (D * D);
  *z = p2 + p3 * (*t - *x2);
  *dz = *z + p3 * Temp;
  *ddz = (*dz + p3 * Temp) * 2.;
  *dddz = p3 * 6.0;
  *z = *d1 + *z * Temp;
  *dz = *z + *dz * Temp;
  *z = *y1 + *z * Temp;
  return 0;
}

#endif


static int nsp_fromws_acquire_data(const char *name,fromws_data **hD,int m,int n,int type)
{
  int i;
  NSP_ITYPE_NAMES(names);
  char *st=NULL;
  char type_ref; 
  int ism_ref,itype_ref;
  fromws_data *D;
  NspObject *Obj,*Time,*Values;
  if ((D= malloc(sizeof(fromws_data)))== NULL) return FAIL;
  D->m=m;
  D->n=n;
  D->type=type;
  if ((Obj = nsp_global_frame_search_object(name))== NULL)  return FAIL;
  if ( !IsHash(Obj))   return FAIL;
  if (nsp_hash_find((NspHash *) Obj,"time",&Time) == FAIL) return FAIL;
  if (nsp_hash_find((NspHash *) Obj,"values",&Values) == FAIL) return FAIL;
  if ( !IsMat(Time) ) return FAIL;
  Mat2double((NspMatrix *) Time);
  if ( !IsCells(Values) == FAIL) return FAIL;
  if ( ((NspMatrix *) Time)->mn != ((NspCells *) Values)->mn) 
    {
      Coserror("Time and Values have incompatible size");
      return FAIL;
    }
  if ( ((NspMatrix *) Time)->rc_type != 'r') 
    {
      Coserror("Time and Values have incompatible size");
      return FAIL;
    }
  for ( i = 0 ; i < ((NspCells *) Values)->mn ; i++) 
    {
      NspObject *Loc=  ((NspCells *) Values)->objs[i];
      if ( Loc == NULL || !( IsMat(Loc) || IsIMat(Loc) )) 
	{
	  Coserror("%s.values{%d} should be a real or int matrix",name,i+1);
	  return FAIL;
	}
      switch ( type ) 
	{
	case SCSREAL_N :
	  if ( ! IsMat(Loc) ||  ((NspMatrix *) Loc)->rc_type != 'r') 
	    {
	      Coserror("%s.values{%d} should be a real matrix",name,i+1);
	      return FAIL;
	    }
	  ism_ref=1;
	  type_ref='r';
	  break;
	case SCSCOMPLEX_N :
	  if ( ! IsMat(Loc) ||  ((NspMatrix *) Loc)->rc_type != 'r') 
	    {
	      Coserror("%s.values{%d} should be a complex matrix",name,i+1);
	      return FAIL;
	    }
	  ism_ref=1;
	  type_ref='c';
	  break;
	default:
	  if ( ! IsIMat(Loc) )
	    {
	      Coserror("%s.values{%d} should be an int matrix",name,i+1);
	      return FAIL;
	    }
	  ism_ref = 0;
	  itype_ref = type;
	  st = NSP_ITYPE_NAME(names,((NspIMatrix *)Loc)->itype);
	  switch ( type ) 
	    {
#define TYPE_CASE(scicos_t,nsp_t)					\
	      case scicos_t :						\
		if ( ((NspIMatrix *) Loc)->itype != nsp_t )		\
		  {							\
		    Coserror("%s.values{%d} should be an imatrix of type %s",name,i+1,st); \
		    return FAIL;					\
		  } 
	      TYPE_CASE( SCSINT_N, nsp_gint );break;
	      TYPE_CASE( SCSINT8_N, nsp_gint8 );break;
	      TYPE_CASE( SCSINT16_N, nsp_gint16 );break;
	      TYPE_CASE( SCSINT32_N, nsp_gint32 );break;
	      TYPE_CASE( SCSUINT_N , nsp_guint);break;
	      TYPE_CASE( SCSUINT8_N, nsp_guint8);break;
	      TYPE_CASE( SCSUINT16_N , nsp_guint16);break;
	      TYPE_CASE( SCSUINT32_N,nsp_guint32 );break;
#undef TYPE_CASE 
	    default:
	      return FAIL;
	    }
	}
      /* this works for matrix and imatrix */
      if ( ((NspMatrix *) Loc)->m != D->m || ((NspMatrix *) Loc)->n != D->n)
	{
	  Coserror("%s.values{%d} should be a of size %dx%s",name,i+1,D->m,D->n);
	  return FAIL;
	}
    }
  return OK;
}
