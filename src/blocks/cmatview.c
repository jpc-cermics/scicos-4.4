/* Nsp
 * Copyright (C) 1998-2010 Jean-Philippe Chancelier Enpc/Cermics
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
 * Display a matrix using a NspGMatrix object 
 * XXX the fact that we should use rpar to change the colormap 
 *     remains to be done 
 * XXX verify that the matrix is properly drawn (transpose or not ?).
 *
 *--------------------------------------------------------------------------*/

#define NEW_GRAPHICS

#include <nsp/nsp.h>
#include <nsp/objects.h>
#include <nsp/graphics-new/Graphics.h> 
#include <nsp/axes.h>
#include <nsp/figuredata.h>
#include <nsp/figure.h>
#include <nsp/gmatrix.h>

#include "blocks.h"

static NspAxes *nsp_cmatview(int win,char *label,int zmin,int zmax, int dim_i, int dim_j,NspGMatrix **gm);

typedef struct _cmatview_data cmatview_data;

struct _cmatview_data
{
  NspAxes *Axes;
  NspGMatrix *gm;
};


void cmatview (scicos_block * block, int flag)
{
  double *u1;
  int dim_i = GetInPortRows (block, 1);
  int dim_j = GetInPortCols (block, 1);
  
  switch (flag)
    {
    case Initialization:
      {
	cmatview_data *D;
	int wid, i;
	NspGMatrix *gm;
	/* ipar=[ zmin,zmax, colormap_size],
	 * the colormap is stored in rpar; 
	 */
	int *ipar= GetIparPtrs (block);	
	int size_mat= ipar[2] ;	
	double *rpar=GetRparPtrs (block);
	double *mat;
	char *label= GetLabelPtrs (block);

	if ((*block->work = scicos_malloc (sizeof (cmatview_data))) == NULL)
	  {
	    scicos_set_block_error (-16);
	    return;
	  }
	D = (cmatview_data *) (*block->work);

	mat = (double *) scicos_malloc(size_mat * sizeof (double));
	for (i = 0; i < size_mat; i++)
	  {
	    mat[i] = rpar[i + 2];
	  }
	wid = 20000 + scicos_get_block_number();
	D->Axes = nsp_cmatview(wid,label, ipar[0],ipar[1],dim_i,dim_j,&gm);
	/* keep a copy in case Axes is destroyed during simulation 
	 * axe is a by reference object 
	 */
	D->Axes = nsp_axes_copy(D->Axes);
	D->gm = gm;
	if ( D->Axes == NULL ) 
	  {
	    scicos_set_block_error (-16);
	    return;
	  }
	break;
      }
    case StateUpdate:
      {
	cmatview_data *D = (cmatview_data *) (*block->work);
	if ( D->Axes->obj->ref_count <= 1 ) 
	  {
	    /* Axes was destroyed during simulation */
	    return;
	  }
	/* matrix to be vizualized */
	u1 = GetInPortPtrs (block, 1);
	dim_i = GetInPortRows (block, 1);
	dim_j = GetInPortCols (block, 1);
	memcpy(D->gm->obj->data->R,u1,dim_i*dim_j*sizeof(double));
	/* invalidate gm */
	nsp_graphic_invalidate((NspGraphic *) D->gm);
	break;
      }	
    case Ending:
      {
	cmatview_data *D = (cmatview_data *) (*block->work);
	if ( D->Axes->obj->ref_count <= 1 ) 
	  {
	    /* Axes was destroyed during simulation 
	     * we finish detruction 
	     */
	    nsp_axes_destroy(D->Axes);
	  }
	scicos_free (D);
	break;
      }
    }
}

static NspAxes *nsp_cmatview(int win, char *label,int zmin,int zmax, int dim_i, int dim_j,NspGMatrix **gm)
{
  NspAxes *axe;
  BCG *Xgc;
  NspMatrix *z; 
  double rect[]={0,0,dim_j,dim_i} ; /* verifier */
  int i,j,l, remap=TRUE;
  NspMatrix *Mrect=NULL,*Mzminmax=NULL,*Mcolminmax=NULL;
  char *strf="181";
  
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
  if ((axe=  nsp_check_for_axes(Xgc,NULL)) == NULL) return NULL;

  if (label != NULL && strlen(label) != 0 && strcmp(label," ") != 0)
    Xgc->graphic_engine->setpopupname (Xgc, label);
  
  /* clean previous plots in case axe is in use.  */ 

  l =  nsp_list_length(axe->obj->children);
  for ( i = 0 ; i < l  ; i++)
    nsp_list_remove_first(axe->obj->children);
  
  /* create a gmatrix and insert-it in axes */
  if ( ( z = nsp_matrix_create("z",'r',dim_i,dim_j)) == NULLMAT) return NULL;
  for ( i = 0 ; i < z->m ; i++) 
    for ( j = 0 ; j < z->n ; j++) 
      z->R[i+z->m*j]= (i+j)/10.0;
  
  if ( (Mcolminmax = nsp_matrix_create("z",'r',1,2)) == NULLMAT) return NULL;
  Mcolminmax->R[0]=0;  /* XX to be updated */
  Mcolminmax->R[1]=32; /* XX to be updated */
  if ( (Mzminmax = nsp_matrix_create("z",'r',1,2)) == NULLMAT) return NULL;
  Mzminmax->R[0]=zmin;
  Mzminmax->R[1]=zmax;
  *gm= nsp_gmatrix_create("gm",z,Mrect,remap,Mcolminmax,Mzminmax,NULL);
  if ( *gm == NULL) return NULL;
  /* insert the new matrix */
  if ( nsp_axes_insert_child(axe,(NspGraphic *) *gm, FALSE)== FAIL) 
    {
      Scierror("Error: failed to insert rectangle in Figure\n");
      return NULL;
    }
  /* updates the axes scale information */
  nsp_strf_axes( axe ,rect, strf[1]);
  axe->obj->axes = strf[2] -'0';
  nsp_axes_invalidate(((NspGraphic *) axe));
  return axe;
}

