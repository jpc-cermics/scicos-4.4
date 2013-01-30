#include <nsp/nsp.h>
#include <nsp/objects.h>
#include <nsp/graphics-new/Graphics.h> 
#include <nsp/objs3d.h>
#include <nsp/polyline3d.h>
#include <nsp/points3d.h>
#include <nsp/polyhedron.h>
#include <nsp/figuredata.h>
#include <nsp/figure.h>
#include <nsp/gmatrix.h>

#include "blocks.h"

extern BCG *scicos_set_win(int wid,int *oldwid);

typedef struct _cscope_data cscope_data;

struct _cscope_data
{
  NspObjs3d *objs3d;
  NspMatrix *Mcol;
  int count;    /* number of points inserted in the scope buffer */
  int max;      /* number of points which can be inserted */
  int malloc_size ; /* we allocate malloc_size rows on re-allocation */
};

typedef struct _cscopxy3D_rpar cscopxy3D_rpar;
struct _cscopxy3D_rpar
{
  double xmin,xmax,ymin,ymax,zmin,zmax;
  double alpha,theta;
};

static int cscopexy3d_add_pts(cscope_data *D);
static int cscopexy3d_add_value(cscope_data *D,double *u1,double *u2,double *u3);

void cscopxy3d (scicos_block * block, int flag)
{
  SCSINT_COP nbcurv = GetInPortRows(block,1);
  SCSINT_COP *ipar = (SCSINT_COP *) GetIparPtrs(block);
  BCG *Xgc=NULL;
  int cur=0;
  int buffer_size= (int) ipar[2];
  int *color= (int *) &ipar[3];
  
  switch (flag) 
  {
    case Initialization:
      {
	cscope_data *D=NULL;
	cscopxy3D_rpar *csr = (cscopxy3D_rpar *) GetRparPtrs(block);
	int wid=(int) ipar[0];
	int nclr=(int) ipar[1];
	/* int *line_size=(int *) &ipar[3+nclr]; */
	/* int animed=(int) ipar[3+2*nclr]; */
	int wpos[2],wdim[2];
	int i,l;
        NspFigure *F;
        
	/* wid */
	wid = (wid == -1) ? 20000 + scicos_get_block_number () : wid;
	/* buffer size: 
	 *  when animated==0 it means draw when buffer_size new points are acquired. 
	 *  when animated==1 it is the number of past points to keep for drawing.
	 */
	buffer_size = (int) ipar[2];
	/* wpos, wdim */
	wpos[0] = ipar[3+2*nclr+1];
	wpos[1] = ipar[3+2*nclr+2];
	wdim[0] = ipar[3+2*nclr+3];
	wdim[1] = ipar[3+2*nclr+4];

	if ((*block->work = scicos_malloc(sizeof(cscope_data))) == NULL) goto err;

	/* store created data in work area of block */
	D=(cscope_data *) (*block->work);
	/* we allocate points by increment of alloc_size */
	D->malloc_size = Max(buffer_size,1000);
	Xgc=scicos_set_win(wid, &cur);
        /* clean previous plots.  */
        if ((F = nsp_check_for_figure(Xgc,FALSE))== NULL) goto err;
        l=nsp_list_length(F->obj->children);
        for ( i= 1; i <= l ; i++)
          nsp_list_remove_first(F->obj->children);
	if (wpos[0]>=0) {
	  Xgc->graphic_engine->xset_windowpos (Xgc, wpos[0],wpos[1]);
	}
	if (wdim[0]>=0) {
	  Xgc->graphic_engine->xset_windowdim (Xgc, wdim[0],wdim[1]);
	}
	D->objs3d=NULL;
	if((D->objs3d=nsp_check_for_objs3d(Xgc,NULL)) == NULL) goto err;
	D->objs3d->obj->alpha=csr->alpha;
	D->objs3d->obj->theta=csr->theta;
	Xgc->scales->alpha=csr->alpha;
	Xgc->scales->theta=csr->theta;
	D->objs3d->obj->ebox->R[0]=csr->xmin;
	D->objs3d->obj->ebox->R[1]=csr->xmax;
	D->objs3d->obj->ebox->R[2]=csr->ymin;
	D->objs3d->obj->ebox->R[3]=csr->ymax;
	D->objs3d->obj->ebox->R[4]=csr->zmin;
	D->objs3d->obj->ebox->R[5]=csr->zmax;
        D->objs3d->obj->fixed=TRUE;
        D->objs3d->obj->box_style=SCILAB;
	if ((D->Mcol = nsp_matrix_create("col",'r',1,1))== NULLMAT) goto err;
        for (i=0;i<nbcurv;i++) {
          NspObject *obj;
          NspMatrix *M;
          if ((M=nsp_matrix_create("coord",'r',D->malloc_size,3))== NULLMAT) goto err;
          if (color[i]>0) {
            NspMatrix *Mc;
            if ((Mc=nsp_matrix_create("col",'r',1,1))== NULLMAT) goto err;
            Mc->R[0]=color[i];
            obj=(NspObject *)nsp_polyline3d_create("pol",M,NULL,Mc,NULL,0,0,NULL);
            if (obj==NULL) goto err;
          } 
          else {
            obj=(NspObject *)nsp_points3d_create("pts",M,NULL,-1,-color[i],-1,NULL,0,0,NULL);
            if (obj==NULL) goto err;
          }
          if (nsp_objs3d_insert_child(D->objs3d, (NspGraphic *)obj,FALSE)== FAIL) goto err;
        }
	/* SetEch3d1(Xgc, nsp_box_3d *box,const double *bbox,csr->theta,csr->alpha,(i=0)); */
        nsp_objs3d_invalidate(((NspGraphic *) D->objs3d));
        D->count=0;
        D->max=D->malloc_size;
        break;
      }
    case StateUpdate:
      {
	cscope_data *D=(cscope_data *) (*GetPtrWorkPtrs(block));
	double *u1 = GetRealInPortPtrs (block, 1);
	double *u2 = GetRealInPortPtrs (block, 2);
	double *u3 = GetRealInPortPtrs (block, 3);
	/* increase curve size by step of buffer_size points */
        if (D->count >= D->max) {
          /* need to expand D->max */
          if (cscopexy3d_add_pts(D) == FAIL) {
            scicos_set_block_error(-16);
            return;
          }
        }
        /* add one point */
        cscopexy3d_add_value(D,u1,u2,u3);
        D->count++;
        if (D->count % buffer_size == 0) {
          /* when we have inserted buffer_size points: then we must draw */
          nsp_objs3d_invalidate(((NspGraphic *) D->objs3d));
        }
        break;
      }
    case Ending:
      {
	cscope_data *D = (cscope_data *) (*GetPtrWorkPtrs(block));
	scicos_free(D);
	break;
      }
  }
  return;
 err: 
  scicos_set_block_error(-16);
}

/* increase size of polylines by D->malloc_size */

static int cscopexy3d_add_pts(cscope_data *D)
{
  NspList *Children= D->objs3d->obj->children;
  /* we have to loop here to collect the number of faces */
  Cell *cloc = Children->first ;
  int count=0;
  while ( cloc != NULLCELL ) 
    {
      NspGraphic *G = (NspGraphic *) cloc->O;
      if (IsPolyline3d(cloc->O)) 
	{
	  if ( nsp_polyline3d_add_pts(G,D->malloc_size) == FAIL) 
	    return FAIL;
	}
      else if (IsPoints3d(cloc->O)) 
	{
	  if ( nsp_points3d_add_pts(G,D->malloc_size) == FAIL) 
	    return FAIL;
	}
      count++;
      cloc = cloc->next;
    }
  D->max += D->malloc_size ; 
  return OK;
}

/* add one new value in the polylines */

static int cscopexy3d_add_value(cscope_data *D,double *u1,double *u2,double *u3)
{
  NspList *Children= D->objs3d->obj->children;
  /* we have to loop here to collect the number of faces */
  Cell *cloc = Children->first ;
  int count=0;
  while ( cloc != NULLCELL ) 
    {
      if (IsPolyline3d(cloc->O)) 
	{
	  nsp_polyline3d *p =((NspPolyline3d *) cloc->O)->obj;
	  NspMatrix *M= p->Mcoord;
	  p->max++; 
	  memcpy(M->R+D->count         ,u1 + count,sizeof(double));
	  memcpy(M->R+M->m+D->count   ,u2 + count,sizeof(double));
	  memcpy(M->R+2*M->m+D->count ,u3 + count,sizeof(double));
	}
      else if (IsPoints3d(cloc->O)) 
	{
	  nsp_points3d *p =((NspPoints3d *) cloc->O)->obj;
	  NspMatrix *M= p->Mcoord;
	  p->max++; 
	  memcpy(M->R+D->count         ,u1 + count,sizeof(double));
	  memcpy(M->R+M->m+D->count   ,u2 + count,sizeof(double));
	  memcpy(M->R+2*M->m+D->count ,u3 + count,sizeof(double));
	}
      count++;
      cloc = cloc->next;
    }
  return OK;
}

