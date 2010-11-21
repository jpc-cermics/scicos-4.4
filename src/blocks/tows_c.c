/* Nsp
 * Copyright (C) 2007-2010 Alan Layec Inria/Metalau
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
 * rewriten for Nsp: Jean-Philippe Chancelier Enpc/Cermics 2010 
 * 
 *--------------------------------------------------------------------------*/

#include "blocks.h"
#include <nsp/matrix.h>
#include <nsp/imatrix.h>
#include <nsp/cells.h>

typedef struct _tows_data tows_data;

struct _tows_data
{
  int start;
  NspMatrix *time; /* matrix to store time */
  NspCells *values; /* cell array to store values */
  int m,n;          /* each value in values is a mxn matrix */
  char name[32];
};

static int nsp_store_data(tows_data *D,int type, int m, int n, void *data, double time);
static int nsp_alloc_tows_data(tows_data **hD,int size,int m,int n, int *ipar);

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
      /* initialization 
       */
      if ( nsp_alloc_tows_data(&D,Max(nz,0),nu,nu2,ipar) == FAIL) 
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
      /* we should write data in a file 
       * or send it to tolevel 
       * TMPDIR/workspace/variable-name 
       */
      FREE(D);
    }
  else if ((flag == 2) || (flag == 0))
    {
      double t = GetScicosTime (block), told ;
      /* update state */
      tows_data *D = (tows_data *) (*block->work);
      void *data = GetInPortPtrs (block, 1);
      /* check data dimension */
      if ( D->time->mn != nz || nu != D->m || (nu2 != D->n))
	{
	  Coserror ("Size of buffer or input size have changed!\n");
	  /*set_block_error(-1); */
	  return;
	}
      /* get old time */
      told = (D->start == 0 ) ? D->time->R[D->time->mn -1] : D->time->R[D->start -1];
      Sciprintf("name=%s told = %f, t=%f\n",D->name,told,t);
      if ( nsp_store_data(D,ut, nu,nu2,  data,t) == FAIL) 
	{
	  Coserror ("Unable to store data!\n");
	  return;
	}
    }
}

static int nsp_alloc_tows_data(tows_data **hD,int size,int m,int n, int *ipar)
{
  int i;
  tows_data *D=NULL;
  if ((D= malloc(sizeof(tows_data)))== NULL) goto end;
  D->time = NULL;
  D->values = NULL;
  D->start = 0;
  D->m = m;
  D->n = n;
  for ( i = 0 ; i < Min(ipar[1],32-1) ; i++)  D->name[i] = ipar[2+i];
  D->name[i]='\0';
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
 */

static int nsp_store_data(tows_data *D,int type, int m, int n, void *data, double time)
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
	if ( D->start == D->time->mn ) D->start = 0;
	memcpy(M->R,data, m*n*((ctype== 'c') ? 2:1)*sizeof(double));
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

