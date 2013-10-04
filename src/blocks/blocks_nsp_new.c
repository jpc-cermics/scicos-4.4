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
 * related to nsp-scicos implementation
 */

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
  scicos_run *Scicos=scicos_get_scicos_run();
  
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
#define BUFSIZE 1024
      char buf[BUFSIZE];
      for ( j= 0 ; j < n ; j++) 
	{
	  int kj =snprintf(buf+k,128-k, "%*.*f" , form[0], form[1], v[i+m*j]);
	  if ( kj > form[0]) 
	    {
	      kj = snprintf(buf+k, 128-k , "%*s",form[0],"*");
	    }
	  k += kj;
	  if ( j != n-1) snprintf(buf+k,128-k, " ");k++;
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
  scicos_run *Scicos=scicos_get_scicos_run();
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
