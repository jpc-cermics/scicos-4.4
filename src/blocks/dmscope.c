/* Nsp
 * Copyright (C) 2012-2012 J.P. Chancelier 
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
#include <nsp/qcurve.h>
#include <nsp/grarc.h>
#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"

static void  nsp_oscillo_add_point(NspList *L,double t,const double *y, int n);
static void scicos_cscope_axes_update(NspAxes *axe,double t, double Ts,
				      double ymin,double ymax);
static void nsp_list_delete_axes(NspList *L);
/**
 * scicos_dmscope_block:
 * @block: 
 * @flag: 
 * 
 * a multi scope inside the diagram 
 **/

typedef struct _dmscope_ipar dmscope_ipar;

struct _dmscope_ipar
{
  /* buffer_size is the number of data to accumulate before redrawing */
  int wid, number_of_subwin, buffer_size , wpos[2], wdim[2];
};

typedef struct _dmscope_rpar dmscope_rpar;
struct _dmscope_rpar
{
  /* dt: unused, yminmax: start of ymin, ymax */
  double dt, yminmax;
};

typedef struct _dmscope_data dmscope_data;

struct _dmscope_data
{
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspFigure *F;
};

/* creates a new Axes object for the multiscope 
 *
 */

static NspAxes *nsp_mscope_new_axe(double *bounds,int ncurves,const int *style, double ymin, double ymax)
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
  axe->obj->top = FALSE;
  /* upper-left width height  */
  axe->obj->wrect->R[0] = bounds[0];
  axe->obj->wrect->R[1] = bounds[3];
  axe->obj->wrect->R[2] = bounds[2]-bounds[0];
  axe->obj->wrect->R[3] = bounds[3]-bounds[1];
  return axe;
}

/* nswin : number of subwindows
 * ncs[i] : number of curves in subsin i
 * style[k]: style for curve k 
 */

static int nsp_mscope_obj(NspCompound *Gr,int nswin,const int *ncs,const int *style,
			  const double *period, int yfree,const double *yminmax)
{
  const int *cstyle = style;
  NspAxes *axe;
  int i;
  /* clean the compound */
  nsp_list_delete_axes(Gr->obj->children);
  /* create nswin axes */
  for ( i = 0 ; i < nswin ; i++) 
    {
      if ((axe = nsp_mscope_new_axe(Gr->obj->bounds->R,ncs[i],cstyle,-1,1))== NULL)
	return FAIL;
      /* store in Compound */
      if ( nsp_list_end_insert(Gr->obj->children,(NspObject *) axe)== FAIL) 
	{
	  nsp_axes_destroy(axe);
	  return FAIL;
	}
      cstyle += ncs[i];
    }
  nsp_list_link_figure(Gr->obj->children, ((NspGraphic *) Gr)->obj->Fig,((NspGraphic *) Gr)->obj->Axe);
  nsp_graphic_invalidate((NspGraphic *) Gr);  
  return OK;
}

static void nsp_list_delete_axes(NspList *L)
{
  Cell *Loc = L->first;
  while ( Loc != NULLCELL ) 
    {
      if ( Loc->O != NULLOBJ  &&  IsAxes(Loc->O)) 
	{ 
	  nsp_remove_cell_from_list(L, Loc);
	  L->icurrent = 0;
	  L->current = NULLCELL;
	  nsp_cell_destroy(&Loc);
	  return;
	}
      Loc = Loc->next;
    }
}

void scicos_dmscope_block (scicos_block * block, int flag)
{
  /* used to decode parameters by name */
  dmscope_ipar *csi = (dmscope_ipar *) GetIparPtrs (block);
  dmscope_rpar *csr = (dmscope_rpar *) GetRparPtrs (block);
  /* int nipar = GetNipar (block); */
  /* number of curves in each subwin */
  int *nswin = ((int *) csi) +7 ;
  /* colors */
  int *colors = ((int *) csi) + 7 + csi->number_of_subwin;
  /* refresh period for each curve */
  double *period = ((double *) csr) + 1; 
  /* ymin,ymax for each curve */
  double *yminmax =((double *) csr) + 1 + csi->number_of_subwin;
  double t = scicos_get_scicos_time ();
  NspGraphic *Gr=Scicos->Blocks[Scicos->params.curblk -1].grobj;
  
  if (flag == 2)
    {
      int i;
      Cell *cloc;
      dmscope_data *D = (dmscope_data *) (*block->work);
      NspList *L =NULL;
      t = GetScicosTime (block);
      /*k = D->count;*/
      D->count++;
      D->tlast = t;
      L= ((NspCompound *) Gr)->obj->children;
      /* insert the points */
      i=0;
      cloc = L->first ;
      while ( cloc != NULLCELL ) 
	{
	  if ( cloc->O != NULLOBJ && IsAxes(cloc->O) ) 
	    {
	      double *u1 = GetRealInPortPtrs (block, i + 1);
	      NspAxes *axe = (NspAxes *) cloc->O;
	      /* add nu points for time t, nu is the number of curves */
	      nsp_oscillo_add_point (axe->obj->children, t, u1,nswin[i]);
	      i++;
	    }
	  cloc = cloc->next;
	}
      if (  D->count %  csi->buffer_size == 0 ) 
	{
	  /* redraw each csi->buffer_size accumulated points 
	   * first check if we need to change the xscale 
	   */
	  i=0;
	  cloc = L->first ;
	  while ( cloc != NULLCELL ) 
	    {
	      if ( cloc->O != NULLOBJ && IsAxes(cloc->O)) 
		{
		  double ymin = yminmax[2*i];
		  double ymax = yminmax[2*i+1];
		  NspAxes *axe = (NspAxes *) cloc->O;
		  /* add nu points for time t, nu is the number of curves */
		  scicos_cscope_axes_update(axe,t,period[i],ymin,ymax);
		  nsp_axes_invalidate((NspGraphic *)axe);
		  i++;
		}
	      cloc = cloc->next;
	    }
	}
    }
  else if (flag == 4)
    {
      /* initialize a scope window */
      dmscope_data *D;
      Gr = Scicos->Blocks[Scicos->params.curblk -1].grobj;
      if (!(Gr != NULL && IsCompound((NspObject *) Gr)))
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ( nsp_mscope_obj((NspCompound *) Gr,csi->number_of_subwin,nswin,colors,period, TRUE,yminmax)== FAIL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      if ((*block->work = scicos_malloc (sizeof (dmscope_data))) == NULL)
	{
	  scicos_set_block_error (-16);
	  return;
	}
      /* store created data in work area of block */
      D = (dmscope_data *) (*block->work);
      /* keep a copy in case Figure is destroyed during simulation 
       * note that is a by reference object 
       */
      D->count = 0;
      D->tlast = t;
    }
  else if (flag == 5)
    {
      dmscope_data *D = (dmscope_data *) (*block->work);
      /* we have locally incremented the count of figure: thus 
       * we can destroy figure here. It will only decrement the ref 
       * counter
       if ( D->F->obj->ref_count >= 1 ) 
	{
	  nsp_figure_destroy(D->F);
	}
      */
      scicos_free (D);
    }
}

/* add one point for each curve in qcurve data  */

static void  nsp_oscillo_add_point(NspList *L,double t,const double *y, int n)
{
  int count =0;
  Cell *Loc = L->first;
  while ( Loc != NULLCELL ) 
    {
      if ( Loc->O != NULLOBJ )
	{ 
	  NspQcurve *curve =(NspQcurve *) Loc->O;
	  if ( count >= n ) return;
	  nsp_qcurve_addpt(curve,&t,&y[count],1);
	  count++;
	}
      Loc = Loc->next;
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
