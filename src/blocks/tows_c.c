/* Nsp
 * Copyright (C) 2007-2012 Alan Layec Inria/Metalau and 
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

#define tows_name_len 64

typedef struct _tows_data tows_data;

struct _tows_data
{
  int infinite;    /* infinite workspace */
  int start;
  NspMatrix *time; /* matrix to store time */
  NspCells *values; /* cell array to store values */
  int m,n;          /* each value in values is a mxn matrix */
  char name[tows_name_len];
};

static int nsp_store_tows_data(tows_data *D,int type, int m, int n, void *data, double time);
static int nsp_alloc_tows_data(tows_data **hD,int size,int m,int n, int *ipar);
static int nsp_tows_data_to_toplevel(tows_data *D);

/*
 * This block record data and at the end 
 * register the recorded data in the global frame.
 * If the object name is A then A.time is an 1xsz array containing
 * simulation times and A.values is a 1xsz cell array containing 
 * data values. sz and the name to give to the variable are block parameters.
 */

void tows_c (scicos_block * block, int flag)
{
  int *ipar = GetIparPtrs (block);     /* parameters */
  int nu  = GetInPortRows (block, 1);	/* number of rows of inputs */
  int nu2 = GetInPortCols (block, 1);	/* number of cols of inputs */
  int ut  = GetInType (block, 1);	/* input type */
  int nz  = ipar[0];		        /* buffer size */
  
  if (flag == 4)
    {
      tows_data *D;
      /* initialization: if nz < 0 data will be allocated dynamically during 
       * the simulation. Note that a buffer size of %inf will give a <0 value here 
       */
      if ( nsp_alloc_tows_data(&D,nz,nu,nu2,ipar) == FAIL) 
	{
	  set_block_error (-16);
	  return;
	}
      *block->work = D;
    }
  else if (flag == 5)
    {			
      /* finish */
      tows_data *D = (tows_data *) (*block->work);
      if ( D== NULL ||  nsp_tows_data_to_toplevel(D)==FAIL) 
	{
	  set_block_error (-16);
	  return;
	}
    }
  else if ((flag == 2) || (flag == 0))
    {
      double t = GetScicosTime (block) ;
      /* update state */
      tows_data *D = (tows_data *) (*block->work);
      void *data = GetInPortPtrs (block, 1);
      /* check data dimension */
      if ( nu != D->m || (nu2 != D->n))
	{
	  Coserror ("Error: Size of buffer or input size have changed!\n");
	  return;
	}
      if ( nz >= 0 &&  D->time->mn != Max(nz,1)) 
	{
	  Coserror ("Error: Size of buffer or input size have changed!\n");
	  return;
	}
      /* get old time 
	 {
	 int told = (D->start == 0 ) ? D->time->R[D->time->mn -1] : D->time->R[D->start -1];
	 Sciprintf("name=%s told = %f, t=%f\n",D->name,told,t);
	 }
      */
      if ( nsp_store_tows_data(D,ut, nu,nu2,  data,t) == FAIL) 
	{
	  Coserror ("Unable to store data!\n");
	  return;
	}
    }
}

static int nsp_alloc_tows_data(tows_data **hD,int rsize,int m,int n, int *ipar)
{
  int i, size = Max(rsize,1);
  tows_data *D=NULL;
  if ((D= malloc(sizeof(tows_data)))== NULL) goto end;
  D->infinite = (rsize < 0 ) ? TRUE : FALSE;
  D->time = NULL;
  D->values = NULL;
  D->start = 0;
  D->m = m;
  D->n = n;
  for ( i = 0 ; i < Min(ipar[1],tows_name_len-2) ; i++)  D->name[i] = ipar[2+i];
  D->name[i]='\0';
  if ( D->infinite == TRUE ) size= 1024;
  if ((D->time= nsp_matrix_create("time",'r',1,size))==NULL) goto end;
  D->time->R[D->time->mn -1]=0.0;
  if ((D->values= nsp_cells_create("values",1,size))==NULL) goto end;
  *hD = D;
  return OK;
 end:
  if ( D->time != NULL) nsp_matrix_destroy(D->time);
  if ( D->values != NULL) nsp_cells_destroy(D->values);
  if ( D != NULL) free(D);
  return FAIL;
}

/* store data in D at position D->start using circular indices 
 * i.e data at the end are at position [0,D->start-1] if D->values->objs[D->start]== NULL. 
 * or at position [D->start, D->time->mn-1,0,D->start-1] if the queue is fully filled. 
 * When objects at position D->start does not exists it is created. We assume that the 
 * type of objects when set are not changed.
 * When D->infinite is TRUE we enlarge D during simulation. 
 */

static int nsp_store_tows_data(tows_data *D,int type, int m, int n, void *data, double time)
{
  D->time->R[D->start]= time;
  switch (type)
    {
    case SCSREAL_N:
    case SCSCOMPLEX_N:
      {
	int ctype = (type == SCSCOMPLEX_N) ? 'c': 'r';
	NspMatrix *M; 
	if ( D->values->objs[D->start] == NULL) 
	  {
	    if ((M = nsp_matrix_create("M",ctype,m,n))==NULL) return FAIL;
	    D->values->objs[D->start]= NSP_OBJECT(M);
	  }
	else
	  {
	    M= (NspMatrix *) D->values->objs[D->start];
	  }
	D->start++; 
	if ( D->start == D->time->mn ) 
	  {
	    if ( D->infinite == FALSE )
	      {
		D->start = 0;
	      }
	    else
	      {
		if ( nsp_matrix_resize(D->time, 1, D->time->mn + 1024) == FAIL) 
		  {
		    return FAIL;
		  }
		if ( nsp_cells_resize(D->values, 1, D->values->mn + 1024) == FAIL) 
		  {
		    return FAIL;
		  }
	      }
	  }
	if ( ctype== 'c' ) 
	  {
	    int i;
	    for (i = 0 ; i < M->mn ; i++) 
	      {
		M->C[i].r = ((double *) data)[i];
		M->C[i].i = (((double *) data) + m*n)[i];
	      }
	  }
	else 
	  {
	    memcpy(M->R,data, m*n*sizeof(double));
	  }
      }
      break;
#define ICREATE(itype,type)						\
      {									\
	NspIMatrix *Im;							\
	if ( D->values->objs[D->start] == NULL)				\
	  {								\
	    if ((Im = nsp_imatrix_create("M",m,n, itype ))==NULL) return FAIL; \
	    D->values->objs[D->start]= NSP_OBJECT(Im);			\
	  }								\
	else								\
	  {								\
	    Im= (NspIMatrix *) D->values->objs[D->start];		\
	  }								\
	memcpy(Im->Iv,data, m*n*sizeof(type));				\
      }
    case SCSINT8_N: ICREATE(nsp_gint8,gint8);break;
    case SCSINT16_N:ICREATE(nsp_gint16,gint16);break;
    case SCSINT32_N:ICREATE(nsp_gint32,gint32);break;
    case SCSUINT8_N:ICREATE(nsp_guint8,guint8);break;
    case SCSUINT16_N:ICREATE(nsp_guint16,guint16);break;
    case SCSUINT32_N:ICREATE(nsp_guint32,guint32);break;
#undef ICREATE
    }
  return OK;
}

static int nsp_tows_data_to_toplevel(tows_data *D)
{
  NspHash *H;
  /* size of final data: should be D->time->mn or D->start */
  /*
   * i.e data at the end are at position [0,D->start-1] if D->values->objs[D->start]== NULL. 
   * or at position [D->start, D->time->mn-1,0,D->start-1] if the queue is fully filled. 
   * When objects at position D->start does not exists it is created. We assume that the 
   * type of objects when set are not changed.
   */
  if ( D->values->objs[D->start] == NULL ) 
    {
      /* we have less data than the buffer size 
       */
      if ( nsp_matrix_resize(D->time, 1 ,Max(D->start-1,0) ) == FAIL) goto end;
      if ( nsp_cells_resize(D->values,1, Max(D->start-1,0))  == FAIL) goto end;
    }
  else
    {
      int i, k=0;
      /* we need to reorder the queue */
      NspMatrix *time;  
      NspCells *values;
      if (( time= nsp_matrix_create("time",'r',1,D->time->mn ))==NULL) goto end;
      if (( values= nsp_cells_create("values",1,D->time->mn))==NULL) goto end;
      for ( i = D->start ; i < D->time->mn ; i++) 
	{
	  time->R[k]= D->time->R[i];
	  values->objs[k] = D->values->objs[i];
	  D->values->objs[i] = NULL;
	  k++;
	}
      for ( i = 0 ; i < D->start ;i++) 
	{
	  time->R[k]= D->time->R[i];
	  values->objs[k] = D->values->objs[i];
	  D->values->objs[i] = NULL;
	  k++;
	}
      nsp_matrix_destroy(D->time);
      nsp_cells_destroy(D->values);
      D->time = time;
      D->values = values;
    }
  /* create a struct */
  if (( H = nsp_hash_create(D->name,2)) == NULLHASH) goto end;
  if (nsp_hash_enter(H,NSP_OBJECT(D->time))== FAIL) goto end;
  if (nsp_hash_enter(H,NSP_OBJECT(D->values))== FAIL) goto end;
  free(D);
  if ( nsp_global_frame_replace_object(NSP_OBJECT(H)) == FAIL) goto end; 
  return OK;
 end:
  return FAIL;
}


