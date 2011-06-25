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
#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"

/**
 * scicos_cscope_block:
 * @block: 
 * @flag: 
 * 
 * a scope:
 * new nsp graphics jpc 
 **/

/*
 * ipar = [win_num, number of subwindows (input ports),  buffer size,
 *         wpos(1),wpos(2) //  window position 
 *         wdim(1),wdim(2) // window dimension 
 *         ipar(8:7+ipar(2)) // input port sizes 
 *         ipar(8+ipar(2):7+ipar(2)+nu) // line type for ith curve 
 */

typedef struct _cmscope_ipar cmscope_ipar;
struct _cmscope_ipar
{
  /* n is the number of data to accumulate before redrawing */
  int wid, number_of_subwin, buffer_size , wpos[2], wdim[2];
};

typedef struct _cmscope_rpar cmscope_rpar;
struct _cmscope_rpar
{
  double dt, ymin, ymax, per;
};

typedef struct _cmscope_data cmscope_data;

struct _cmscope_data
{
  int count;    /* number of points inserted in the scope buffer */
  double tlast; /* last time inserted in csope data */
  NspFigure *F;
};

NspAxes *nsp_moscillo_new_axe(int ncurves,const int *style, double ymin, double ymax)
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

NspFigure *nsp_moscillo_obj(int win,int nswin,const int *ncs,const int *style,
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
      if ((axe = nsp_moscillo_new_axe(ncs[i],cstyle,-1,1))== NULL)
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

static void scicos_cmscope_axes_update(NspAxes *axe,double t, double Ts,
				      double ymin,double ymax);

void scicos_cmscope_block (scicos_block * block, int flag)
{
  char *str;
  BCG *Xgc;
  /* used to decode parameters by name */
  cmscope_ipar *csi = (cmscope_ipar *) GetIparPtrs (block);
  cmscope_rpar *csr = (cmscope_rpar *) GetRparPtrs (block);
  /* int nipar = GetNipar (block); */
  int cur = 0, k;
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
      cmscope_data *D = (cmscope_data *) (*block->work);
      t = GetScicosTime (block);
      k = D->count;
      D->count++;
      D->tlast = t;
      if (  D->count %  csi->buffer_size == 0 ) 
	{
	  int i=0;
	  /* redraw each csi->buffer_size accumulated points 
	   * first check if we need to change the xscale 
	   */
	  NspList *L = D->F->obj->children;
	  Cell *cloc = L->first ;
	  while ( cloc != NULLCELL ) 
	    {
	      if ( cloc->O != NULLOBJ ) 
		{
		  double *u1 = GetRealInPortPtrs (block, i + 1);
		  double ymin = yminmax[2*i];
		  double ymax = yminmax[2*i+1];
		  NspAxes *axe = (NspAxes *) cloc->O;
		  /* add nu points for time t, nu is the number of curves */
		  nsp_oscillo_add_point (axe->obj->children, t, u1,nswin[i]);
		  scicos_cmscope_axes_update(axe,t,period[i],ymin,ymax);
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
      cmscope_data *D;
      /* create a figure with axes and qcurves  */
      NspFigure *F = nsp_moscillo_obj(wid,csi->number_of_subwin,nswin,colors,
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
      D->F = F;
      D->count = 0;
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
      scicos_free (D);
      /* Xgc = scicos_set_win(wid,&cur); */
    }
}

extern int scicos_cscope_get_bounds(NspList *L, double *bounds);


static void scicos_cmscope_axes_update(NspAxes *axe,double t, double Ts,
				      double ymin,double ymax)
{
  double frect[4]={ Max(t-Ts,0) , ymin, t, ymax};
  int tag = FALSE;
  double bounds[4];
  if ( isinf(ymin) || isinf(ymax))
    {
      /* only usefull, if ymin or ymax is inf */
      tag = scicos_cscope_get_bounds(axe->obj->children,bounds);
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
