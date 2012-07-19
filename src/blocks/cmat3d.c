/* Nsp
 * Copyright (C) 2010-2011 Jean-Philippe Chancelier Enpc/Cermics
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
#include <nsp/objs3d.h>
#include <nsp/polyhedron.h>
#include <nsp/figuredata.h>
#include <nsp/figure.h>
#include <nsp/gmatrix.h>

#include "blocks.h"

typedef struct _cmat3d_data cmat3d_data;

struct _cmat3d_data
{
  NspObjs3d *objs3d;
  NspSPolyhedron *pol;
  NspMatrix *x,*y;
  double alpha,theta;
};

static void nsp_cmat3d(cmat3d_data *D,int win, char *label,NspMatrix *cmap,
		       double rect[],int dim_i, int dim_j);


void cmat3d (scicos_block * block, int flag)
{
  double *u1;
  int dim_i = GetInPortRows (block, 1);
  int dim_j = GetInPortCols (block, 1);
  switch (flag)
    {
    case Initialization:
      {
	/* ipar=[ zmin,zmax,size(colormap,1),xyvector_size],
	 * the colormap is stored in rpar; the vectors also
	 * rpar=[colormap(:);vec_x(:);vec_y(:)];
	 */
	double rect[6]={0,1,0,1,0,1}; /* xmin,xmax,ymin,ymax,zmin,zmax */
	NspMatrix *cmap;
	cmat3d_data *D;
	int wid;
	int *ipar= GetIparPtrs (block);	
	int size_mat= ipar[2] ;	
	double *rpar=GetRparPtrs (block);
	char *label= GetLabelPtrs (block);
	if ((*block->work = scicos_malloc (sizeof (cmat3d_data))) == NULL)
	  {
	    scicos_set_block_error (-16);
	    return;
	  }
	D = (cmat3d_data *) (*block->work);
	/* should be used to set the colormap */
	cmap = nsp_matrix_create("cmap",'r',size_mat,3);
	memcpy(cmap->R,rpar,3*size_mat*sizeof(double));
	/* boundaries */
	rect[4]=ipar[0]; /* zmin = ipar[0];*/
	rect[5]=ipar[1]; /* zmax = ipar[1];*/
	if (ipar[3] == 1)
	  {
	    /* use matrix dimensions as X,Y sizes */
	    rect[1] = GetInPortSize (block, 1, 1);
	    rect[3] = GetInPortSize (block, 1, 2);
	  }
	else
	  {
	    /* X and Y are of size ipar[3] and stored after colormap */
	    double *xv = rpar+3*size_mat,*yv= xv + ipar[3];
	    rect[0]=xv[0]; rect[1]=xv[ipar[3]-1];/* xmin ,xmax*/
	    rect[2]=yv[0]; rect[3]=yv[ipar[3]-1];/* xmin ,xmax*/
	    /* Sciprintf("found [%f,%f] [%f,%f]\n",rect[0],rect[1],rect[2],rect[3]); */
	  }
	wid = 20000 + scicos_get_block_number();
	/* 
	 */
	if (GetNopar(block)==2) 
	  {
	    D->alpha= *(GetRealOparPtrs(block,1));
	    D->theta= *(GetRealOparPtrs(block,2));
	  }
	else 
	  {
	    D->alpha = 35; 
	    D->theta = 45;
	  }
	nsp_cmat3d(D,wid,label,cmap,rect, dim_i,dim_j);
	/* keep a copy in case Axes is destroyed during simulation 
	 * axe is a by reference object 
	 */
	D->objs3d = nsp_objs3d_copy(D->objs3d);
	if ( D->objs3d == NULL ) 
	  {
	    scicos_set_block_error (-16);
	    return;
	  }
	break;
      }
    case StateUpdate:
      {
	cmat3d_data *D = (cmat3d_data *) (*block->work);
	if ( D->objs3d->obj->ref_count <= 1 ) 
	  {
	    /* Axes was destroyed during simulation */
	    return;
	  }
	/* matrix to be vizualized */
	u1 = GetInPortPtrs (block, 1);
	dim_i = GetInPortRows (block, 1);
	dim_j = GetInPortCols (block, 1);
	nsp_spolyhedron_update_from_triplet(D->pol,D->x->R,D->y->R,u1,dim_i,dim_j,NULL,0);
	nsp_objs3d_invalidate(((NspGraphic *) D->objs3d));
	break;
      }	
    case Ending:
      {
	cmat3d_data *D = (cmat3d_data *) (*block->work);
	if ( D->objs3d->obj->ref_count <= 1 ) 
	  {
	    /* Axes was destroyed during simulation 
	     * we finish detruction 
	     */
	    nsp_objs3d_destroy(D->objs3d);
	    nsp_matrix_destroy(D->x);
	    nsp_matrix_destroy(D->y);
	  }
	scicos_free (D);
	break;
      }
    }
}

static void nsp_cmat3d(cmat3d_data *D,int win, char *label,NspMatrix *cmap,
		       double rect[],int dim_i, int dim_j)
{
  NspSPolyhedron *pol;  
  BCG *Xgc;
  NspMatrix *z,*x,*y;
  int i,l;

  D->objs3d= NULL;
  
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
  if ((Xgc = window_list_get_first())== NULL) return;
  if ((D->objs3d = nsp_check_for_objs3d(Xgc,NULL)) == NULL) return;

  D->objs3d->obj->alpha= D->alpha;
  D->objs3d->obj->theta= D->theta;
  D->objs3d->obj->box_style=SCILAB;

  if (cmap != NULL ) 
    {
      if ( D->objs3d->obj->colormap != NULL) 
	nsp_matrix_destroy(D->objs3d->obj->colormap);
      D->objs3d->obj->colormap=cmap; 
    }
  
  if (label != NULL && strlen(label) != 0 && strcmp(label," ") != 0)
    Xgc->graphic_engine->setpopupname (Xgc, label);
  
  /* clean previous plots in case objs3d is in use.  */ 

  l =  nsp_list_length(D->objs3d->obj->children);
  for ( i = 0 ; i < l  ; i++)
    nsp_list_remove_first(D->objs3d->obj->children);
  
  /* create a polyhedron and insert it in objs3d */
  if (( x = nsp_matrix_create("x",'r',1,dim_i)) == NULL) return;
  if (( y = nsp_matrix_create("x",'r',1,dim_j)) == NULL) return;
  if (( z = nsp_matrix_create("x",'r',dim_i,dim_j)) == NULL) return;
  
  for ( i = 0 ; i < dim_i ; i++) x->R[i]= rect[0]+ (((double) i)/dim_i)*(rect[1]-rect[0]);
  for ( i = 0 ; i < dim_j ; i++) y->R[i]= rect[2]+ (((double) i)/dim_j)*(rect[3]-rect[2]);
  for ( i = 0 ; i < dim_j*dim_i ; i++) z->R[i]=0.0;
  pol = nsp_spolyhedron_create_from_triplet("pol",x->R,y->R,z->R,dim_i,dim_j,NULL,0);
  D->pol = pol ;
  if ( pol == NULL) return;
  D->x = x;
  D->y = y;
  nsp_matrix_destroy(z);
  
  /* fix the mesh according to flag 
   * Note that when flg == 0 we should 
   * only draw the mesh 
   */
  D->pol->obj->mesh = TRUE;
  D->pol->obj->shade = FALSE;/* shade; */
  /* insert the new polyhedron */
  if ( nsp_objs3d_insert_child(D->objs3d, (NspGraphic *) D->pol,FALSE)== FAIL)
    {
      Scierror("Error: failed to insert contour in Figure\n");
      return;
    }
  nsp_objs3d_invalidate(((NspGraphic *) D->objs3d));

}


