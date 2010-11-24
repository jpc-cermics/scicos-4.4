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


#define Y_COMPUTE1(type)						\
  {									\
    type *y_ul = (type *) GetOutPortPtrs (block, 1);			\
    if (inow >= D->time->mn - 1)					\
      {									\
	if (D->OutEnd == 0)						\
	  {								\
	    y_ul[j] = 0;	/* outputs set to zero */		\
	  }								\
	else if (D->OutEnd == 1)					\
	  {								\
	    /* hold outputs at the end */				\
	    y_ul[j] = ((type *) ((NspIMatrix *) D->values->objs[D->time->mn-1])->Iv)[j]; \
	  }								\
      }									\
    else if (D->Method == 0)						\
      {									\
	y_ul[j] =(inow < 0)?  0:  ((type *) ((NspIMatrix *) D->values->objs[inow])->Iv)[j]; \
      }									\
    else if (D->Method >= 1)						\
      {									\
    	double t1,t2,y1,y2;						\
	if (inow < 0) inow = 0;						\
	t1 = D->time->R[inow];						\
	t2 = D->time->R[inow + 1];					\
	y1 = (double) ((type *) ((NspIMatrix *) D->values->objs[inow])->Iv)[j]; \
	y2 = (double) ((type *) ((NspIMatrix *) D->values->objs[inow+1])->Iv)[j]; \
	y_ul[j] =  (type) ((y2 - y1) * (t - t1) / (t2 - t1) + y1);	\
      }									\
  }

typedef struct _fromws_data fromws_data;

struct _fromws_data
{
  NspMatrix *time; /* matrix to store time */
  NspCells *values; /* cell array to store values */
  int m,n,type;     /* each value in values is a mxn matrix of type type */
  char name[32];
  int Method, ZC, OutEnd;
  double *D;
  int cnt1; 
  int cnt2; 
  int EVindex;
  int PerEVcnt;
  int firstevent;
};

static int nsp_fromws_acquire_data(const char *name,fromws_data **D,int m,int n,int type);
static int nsp_alloc_for_spline(fromws_data *D);
static int Mytridiagldltsolve (double *d, double *l, double *b, int n);
static int Myevalhermite2 (const double *t, double *xa, double *xb, double *ya,
			   double *yb, double *da, double *db, double *h, double *dh,
			   double *ddh, double *dddh, int *i);

void fromws_c (scicos_block * block, int flag)
{
  int *_ipar = GetIparPtrs (block);
  int my = GetOutPortRows (block, 1);	/* number of rows of Outputs */
  int ny = GetOutPortCols (block, 1);	/* number of cols of Outputs */
  int ytype = GetOutType (block, 1);	/* output type */
  double *_evout = GetNevOutPtrs (block);

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
      D->Method = *(_ipar+ 1 + _ipar[0]);
      D->ZC =     *(_ipar+ 2 + _ipar[0]);
      D->OutEnd = *(_ipar+ 3 + _ipar[0]);
      if ( nsp_alloc_for_spline(D) == FAIL) 
	{
	  Coserror ("Cannot acquire data '%s' \n",name);
	  return;
	}
      *block->work = D;

    }
  else if (flag == 1)
    {
      int i,j, inow;
      fromws_data *D = (fromws_data *) (*block->work);
      int cnt1 = D->cnt1;
      int cnt2 = D->cnt2;
      int EVindex = D->EVindex;
      int PerEVcnt = D->PerEVcnt;
      double t = GetScicosTime (block);

      if (D->ZC == 1)
	{
	  /*zero crossing enable */
	  if (D->OutEnd == 2)
	    {
	      t -= (PerEVcnt) * D->time->R[D->time->mn-1];
	    }
	  inow = D->time->mn - 1;
	  for (i = cnt1; i < D->time->mn; i++)
	    {
	      if (i == -1)
		{
		  continue;
		}
	      if (t < D->time->R[i])
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
	  if (D->OutEnd == 2)
	    {
	      double r;
	      if ( D->time->R[D->time->mn-1] != 0)
		{
		  r = floor ((t /D->time->R[D->time->mn-1]));
		}
	      else
		{
		  r = 0;
		}
	      t -= ((int) r) *D->time->R[D->time->mn-1];
	    }
	  inow = D->time->mn - 1;
	  for (i = 0; i < D->time->mn ; i++)
	    {
	      if (t < D->time->R[i])
		{
		  inow = i - 1;
		  break;
		}
	    }
	}

      D->cnt1 = cnt1;
      D->cnt2 = cnt2;
      D->EVindex = EVindex;
      D->PerEVcnt = PerEVcnt;

      for (j = 0; j < D->m*D->n; j++)
	{
	  if ( D->type == SCSREAL_N || D->type == SCSCOMPLEX_N)
	    {
	      double *y_d = GetRealOutPortPtrs (block, 1);
	      double *ptr_D = (double *) D->D;
	      if (inow >= D->time->mn - 1)
		{
		  if (D->OutEnd == 0)
		    {
		      y_d[j] = 0.0;	/* outputs set to zero */
		    }
		  else if (D->OutEnd == 1)
		    {
		      /* hold outputs at the end */
		      y_d[j] = ((NspMatrix *) D->values->objs[D->time->mn - 1])->R[j]; 
		    }
		}
	      else if (D->Method == 0)
		{
		  y_d[j] =(inow < 0)?  0.0:  ((NspMatrix *) D->values->objs[inow])->R[j];
		}
	      else if (D->Method == 1)
		{
		  double t1,t2,y1,y2;
		  if (inow < 0) inow = 0;
		  t1 = D->time->R[inow];
		  t2 = D->time->R[inow + 1];
		  y1 = ((NspMatrix *) D->values->objs[inow])->R[j];
		  y2 = ((NspMatrix *) D->values->objs[inow+1])->R[j];
		  y_d[j] = (y2 - y1) * (t - t1) / (t2 - t1) + y1;
		}
	      else if (D->Method >= 2)
		{
		  double h,dh,ddh,dddh;
		  double t1,t2,y1,y2,d1,d2;
		  if (inow < 0) inow = 0;
		  t1 = D->time->R[inow];
		  t2 = D->time->R[inow + 1];
		  y1 = ((NspMatrix *) D->values->objs[inow])->R[j];
		  y2 = ((NspMatrix *) D->values->objs[inow+1])->R[j];
		  d1 = ptr_D[inow + j * D->time->mn];
		  d2 = ptr_D[inow + 1 + j * D->time->mn];
		  Myevalhermite2 (&t, &t1, &t2, &y1, &y2, &d1, &d2, &h, &dh, &ddh, &dddh, &inow);
		  y_d[j] = h;
		}
	      if ( D->type == SCSCOMPLEX_N) 
		{
		  /*  --------------complex---------------------- */
		  double *y_cd = GetImagOutPortPtrs (block, 1);
		  if (inow >= D->time->mn - 1)
		    {
		      if (D->OutEnd == 0)
			{
			  y_cd[j] = 0.0;	/* outputs set to zero */
			}
		      else if (D->OutEnd == 1)
			{
			  y_cd[j] = ((NspMatrix *) D->values->objs[D->time->mn - 1])->C[j].i;
			}
		    }
		  else if (D->Method == 0)
		    {
		      if (inow < 0)
			{
			  y_cd[j] = 0.0;	/* outputs set to zero */
			}
		      else
			{
			  y_cd[j] =((NspMatrix *) D->values->objs[inow])->C[j].i;
			}
		    }
		  else if (D->Method == 1)
		    {
		      double t1,t2,y1,y2;
		      if (inow < 0) inow = 0;
		      t1 = D->time->R[inow];
		      t2 = D->time->R[inow + 1];
		      y1= ((NspMatrix *) D->values->objs[inow])->C[j].i;
		      y2= ((NspMatrix *) D->values->objs[inow+1])->C[j].i;
		      y_cd[j] = (y2 - y1) * (t - t1) / (t2 - t1) + y1;
		    }
		  else if (D->Method >= 2)
		    {
		      double h,dh,ddh,dddh;
		      double t1,t2,y1,y2,d1,d2;
		      t1 = D->time->R[inow];
		      t2 = D->time->R[inow + 1];
		      y1 = ((NspMatrix *) D->values->objs[inow])->C[j].i;
		      y2 = ((NspMatrix *) D->values->objs[inow+1])->C[j].i;
		      d1 = ptr_D[inow + j * D->time->mn + D->time->mn];
		      d2 = ptr_D[inow + 1 + j * D->time->mn + D->time->mn];
		      Myevalhermite2 (&t, &t1, &t2, &y1, &y2, &d1, &d2,
				      &h, &dh, &ddh, &dddh, &inow);
		      y_cd[j] = h;
		    }
		}
	    }
	  else
	    {
	      switch ( D->type )
		{
		case 1:  Y_COMPUTE1(gint8); break;
		case 2:  Y_COMPUTE1(gint16); break;
		case 4:  Y_COMPUTE1(gint32); break;
		case 11: Y_COMPUTE1(guint8); break;
		case 12: Y_COMPUTE1(guint16); break;
		case 14: Y_COMPUTE1(guint32); break;
		}
	    }
	} 
    }
  else if (flag == 3)
    {
      int jfirst,i,j;
      fromws_data *D = (fromws_data *) (*block->work);
      /* event date computation */
      int cnt1 = D->cnt1;
      int cnt2 = D->cnt2;
      int EVindex = D->EVindex;
      int PerEVcnt = D->PerEVcnt;
      /* get current simulation time */
      if (D->ZC == 1)
	{	
	  /* generate Events only if ZC is active */
	  if ((D->Method == 1) || (D->Method == 0))
	    {
	      /*-------------------------*/
	      if (D->firstevent == 1)
		{
		  jfirst = D->time->mn - 1;
		  /* finding first positive time instant */
		  for (j = 0; j < D->time->mn; j++)
		    {
		      if (D->time->R[j] > 0)
			{
			  jfirst = j;
			  break;
			}
		    }
		  _evout[0] = D->time->R[jfirst];
		  EVindex = jfirst;
		  D->EVindex = EVindex;
		  D->firstevent = 0;
		  return;
		}
	      /*------------------------*/
	      i = EVindex;
	      /*------------------------*/
	      if (i < D->time->mn - 1)
		{
		  _evout[0] = D->time->R[i + 1] - D->time->R[i];
		  EVindex = i + 1;
		}
	      /*------------------------*/
	      if (i == D->time->mn - 1)
		{
		  if (D->OutEnd == 2)
		    {
		      /*  Periodic */
		      cnt1 = -1;
		      cnt2 = 0;
		      PerEVcnt++;	/* When OutEnd==2 (perodic output) */
		      jfirst = D->time->mn - 1;	/* finding first positive time instant */
		      for (j = 0; j < D->time->mn; j++)
			{
			  if (D->time->R[j] > 0)
			    {
			      jfirst = j;
			      break;
			    }
			}
		      _evout[0] = D->time->R[jfirst];
		      EVindex = jfirst;
		    }
		}
	      /*-------------------------- */
	    }
	  else if (D->Method <= 3)
	    {
	      if (D->firstevent == 1)
		{
		  _evout[0] = D->time->R[D->time->mn-1];
		  D->firstevent = 0;
		}
	      else
		{
		  if (D->OutEnd == 2)
		    {
		      _evout[0] = D->time->R[D->time->mn-1];
		    }
		  PerEVcnt++;
		}
	      cnt1 = -1;
	      cnt2 = 0;
	    }
	  D->cnt1 = cnt1;
	  D->cnt2 = cnt2;
	  D->EVindex = EVindex;
	  D->PerEVcnt = PerEVcnt;
	}
    }
  else if (flag == 5)
    {
      fromws_data *D = (fromws_data *) (*block->work);
      Sciprintf ("fromws_c is to be done for nsp \n");
    }
}


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
  D->D=NULL;
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
  /* check that times are increasing */
  for (i = 0; i < D->time->mn - 1; i++)
    {
      if ( D->time->R[i] > D->time->R[i + 1])
	{
	  Coserror("Error: %s.time(%d) > %s.time(%d), time should be an increasing vector",name,i,i+1);
	  return FAIL;
	}
    }
  D->cnt1 = D->time->mn - 1;
  D->cnt2 = D->time->mn;
  for (i = 0; i < D->time->mn;  i++)
    {			
      /* finding the first positive time instant */
      if ( D->time->R[i]  >= 0)
	{
	  D->cnt1 = i - 1;
	  D->cnt2 = i;
	  break;
	}
    }
  D->EVindex = 0;
  D->PerEVcnt = 0;
  D->firstevent = 1;
  return OK;
}

/* Only allocate here when data is double or complex 
 *
 */

static int nsp_alloc_for_spline(fromws_data *D)
{
  int i,j;
  NspMatrix *Vt, *Vtp1;
  double *spline, *A_d, *A_sd, *qdy;
  int mY = D->m*D->n;
  int nPoints = D->time->mn;
  int iscomplex = (D->type == SCSREAL_N) ? 0:1;
  double *ptr_T = D->time->R;

  if ( D->type != SCSREAL_N && D->type != SCSCOMPLEX_N) return OK;
  if ( D->Method <= 1) return OK;

  if ((D->D = malloc ( (1+iscomplex) * D->time->mn * mY * sizeof (double))) == NULL)
    {
      set_block_error (-16);
      return FAIL;
    }
  if ((spline =  (double *) scicos_malloc ((3 * nPoints - 2) * sizeof (double))) == NULL)
    {
      Coserror ("Allocation problem in spline.\n");
      /*set_block_error(-16); */
      return FAIL;
    }
  A_d = spline;
  A_sd = A_d + nPoints;
  qdy = A_sd + nPoints - 1;
  
  for (j = 0; j < mY; j++)
    {	
      /* real part */
      for (i = 0; i <= nPoints - 2; i++)
	{
	  Vt = (NspMatrix *) D->values->objs[i];
	  Vtp1 = (NspMatrix *) D->values->objs[i+1];
	  A_sd[i] = 1.0 / (ptr_T[i + 1] - ptr_T[i]);
	  qdy[i] = (Vtp1->R[j] - Vt->R[j])* A_sd[i] * A_sd[i];
	}

      for (i = 1; i <= nPoints - 2; i++)
	{
	  A_d[i] = 2.0 * (A_sd[i - 1] + A_sd[i]);
	  D->D[i + j * nPoints] = 3.0 * (qdy[i - 1] + qdy[i]);
	}

      if (D->Method == 2)
	{
	  A_d[0] = 2.0 * A_sd[0];
	  D->D[0 + j * nPoints] = 3.0 * qdy[0];
	  A_d[nPoints - 1] = 2.0 * A_sd[nPoints - 2];
	  D->D[nPoints - 1 + j * nPoints] = 3.0 * qdy[nPoints - 2];
	  Mytridiagldltsolve (A_d, A_sd, &D->D[j * nPoints], nPoints);
	}

      if (D->Method == 3)
	{
	  /*  s'''(x(2)-) = s'''(x(2)+) */
	  double r = A_sd[1] / A_sd[0];
	  A_d[0] = A_sd[0] / (1.0 + r);
	  D->D[j * nPoints] =  ((3.0 * r + 2.0) * qdy[0] +
				  r * qdy[1]) / ((1.0 + r) * (1.0 + r));
	  /*  s'''(x(n-1)-) = s'''(x(n-1)+) */
	  r = A_sd[nPoints - 3] / A_sd[nPoints - 2];
	  A_d[nPoints - 1] = A_sd[nPoints - 2] / (1.0 + r);
	  D->D[nPoints - 1 + j * nPoints] =
	    ((3.0 * r + 2.0) * qdy[nPoints - 2] +
	     r * qdy[nPoints - 3]) / ((1.0 + r) * (1.0 + r));
	  Mytridiagldltsolve (A_d, A_sd, &D->D[j * nPoints],  nPoints);
	}
    }
  
  if ( iscomplex )
    {	
      /* imag part */
      for (j = 0; j < mY; j++)
	{
	  for (i = 0; i <= nPoints - 2; i++)
	    {
	      Vt = (NspMatrix *) D->values->objs[i];
	      Vtp1 = (NspMatrix *) D->values->objs[i+1];
	      A_sd[i] = 1.0 / (ptr_T[i + 1] - ptr_T[i]);
	      qdy[i] =( Vtp1->C[j].i - Vt->C[j].i)  * A_sd[i] * A_sd[i];
	    }
	  for (i = 1; i <= nPoints - 2; i++)
	    {
	      A_d[i] = 2.0 * (A_sd[i - 1] + A_sd[i]);
	      D->D[i + j * nPoints + nPoints] = 3.0 * (qdy[i - 1] + qdy[i]);
	    }
	  if (D->Method == 2)
	    {
	      A_d[0] = 2.0 * A_sd[0];
	      D->D[nPoints + 0 + j * nPoints] = 3.0 * qdy[0];
	      A_d[nPoints - 1] = 2.0 * A_sd[nPoints - 2];
	      D->D[nPoints + nPoints - 1 + j * nPoints] = 3.0 * qdy[nPoints - 2];
	      Mytridiagldltsolve (A_d, A_sd, &D->D[nPoints + j * nPoints], nPoints);
	    }
	  if (D->Method == 3)
	    {
	      /*  s'''(x(2)-) = s'''(x(2)+) */
	      double r = A_sd[1] / A_sd[0];
	      A_d[0] = A_sd[0] / (1.0 + r);
	      D->D[nPoints + j * nPoints] =((3.0 * r + 2.0) * qdy[0] + r * qdy[1]) 
		/ ((1.0 + r) * (1.0 + r));
	      /*  s'''(x(n-1)-) = s'''(x(n-1)+) */
	      r = A_sd[nPoints - 3] / A_sd[nPoints - 2];
	      A_d[nPoints - 1] = A_sd[nPoints - 2] / (1.0 + r);
	      D->D[nPoints + nPoints - 1 + j * nPoints] =
		((3.0 * r + 2.0) * qdy[nPoints - 2] +
		 r * qdy[nPoints - 3]) / ((1.0 + r) * (1.0 + r));
	      Mytridiagldltsolve (A_d, A_sd, &D->D[nPoints + j * nPoints],  nPoints);
	    }
	}
    }
  free(spline);
  return OK;
}


static int Mytridiagldltsolve (double *dA, double *lA, double *B, int N)
{
  int j;
  for (j = 1; j <= N - 1; ++j)
    {
      double Temp = lA[j - 1];
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


static int Myevalhermite2 (const double *t, double *x1, double *x2, double *y1,
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
