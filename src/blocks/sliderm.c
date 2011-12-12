/* Nsp
 * Copyright (C) 2010-2011 Jean-Philippe Chancelier (Enpc)
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
#include <nsp/grrect.h>
#include <nsp/compound.h>

#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"


static int scicos_sliderm_check_coumpound(NspCompound *C);
static int scicos_sliderm_update_rects(NspCompound *C,const double *u, 
				       const double *rpar);
static int scicos_sliderm_initialize_rects(NspCompound *C,int n);
static NspCompound *scicos_sliderm_getrects(NspCompound *C);

/*
 * XXX: this is unfinished 
 *  1/ rects have to be removed at the end or if kept then 
 *     they should be detected on restart 
 *  2/ rects could be vertical or horizontal 
 * 
 * follow an input value with a graphic slider 
 * 
 *  rpar = [min-range, max-range] 
 *  ipar = [type(1 or 2),color]
 *  z = size 3
 */

static int vert = 0;

void scicos_sliderm_block (scicos_block * block, int flag)
{
  double *rpar = block->rpar;
  double *u = GetInPortPtrs(block,1);
  int nur = GetInPortRows(block,1);
  /* int nuc = GetInPortCols(block,1); */
  double *z = block->z;
  /* double nz= block->nz; */
  NspCompound **S= (NspCompound **) &z[0] ;
  NspGraphic *Gr=Scicos->Blocks[Scicos->params.curblk -1].grobj;
  switch (flag)
    {
    case StateUpdate:
      /* standard case */
      if ( *S == NULL) return;
      scicos_sliderm_update_rects(*S,u,rpar);
      nsp_graphic_invalidate(Gr);
      break;
    case Initialization:
      /* initial case  */
      *S = NULL;
      Gr = Scicos->Blocks[Scicos->params.curblk -1].grobj;
      if (!(Gr != NULL && IsCompound((NspObject *) Gr))) break;
      *S = scicos_sliderm_getrects((NspCompound *) Gr);
      if ( *S == NULL) break;
      if ( scicos_sliderm_initialize_rects(*S,nur+1)== FAIL)
	{
	  *S = NULL; break;
	}
      break;
    case Ending:
      /* reset back default size */
      /* if ( *S != NULL)  (*S)->obj->w= z[]; */
      break;
    }
}

/* explore C to get a compound filled with rects */

static NspCompound *scicos_sliderm_getrects(NspCompound *C)
{
  NspCompound *S;
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      NspCompound *C = (NspCompound *) cloc->O;
	      if ( scicos_sliderm_check_coumpound(C) == TRUE ) 
		{
		  return C ;
		}
	      else 
		{
		  S = scicos_sliderm_getrects(C);
		  if ( S != NULL) return S;
		}
	    }
	  cloc = cloc->next;
	}
    }
  return NULL;
}


/* checks that a compound contains only a list of 
 * rectangle. 
 */

static int scicos_sliderm_check_coumpound(NspCompound *C) 
{
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if ( IsGrRect(cloc->O) == FALSE )
	    {
	      return FALSE;
	    }
	}
      cloc = cloc->next;
    }
  return TRUE;
}

/* changes the Compound object in such a way that it 
 * contains @n GrRect in its children list. 
 * Note that the initial given C contains on entry at least one 
 * GrRect object which is used to get default values;
 */

static int scicos_sliderm_initialize_rects(NspCompound *C,int n)
{
  int i;
  NspGraphic *G = (NspGraphic *) C;
  NspList *L = C->obj->children;
  int ln = nsp_list_length(L);
  Cell *cloc = L->first;
  NspGrRect *R = (NspGrRect *) cloc->O;
  /* first element should alway be present */
  double x= R->obj->x, y = R->obj->y, w= R->obj->w, h=R->obj->h;
  int color = R->obj->fill_color;
  double hr = h/(n-1);
  double wr = w/(n-1);
  ((NspGraphic *) R)->obj->show = FALSE;
  int icolor=-1,iback=color,ithickness=-1;
  if ( ln < n ) 
    {
      NspGraphic *gobj = NULL;
      for ( i = 0 ; i < n-ln ; i++) 
	{
      	  if ((gobj =(NspGraphic *) nsp_grrect_create("rect",0,0,0,0,iback,
						      ithickness,icolor,0.0,NULL))== NULL)
	    return FAIL;
	  if ( nsp_list_end_insert(L,(NspObject *) gobj )== FAIL)
	    return FAIL;
	}
    }
  else
    {
      for (i=0; i < ln -n ; i++ ) 
	{
	  nsp_list_delete_elt(L,ln-i);
	  nsp_list_length(L);
	}
      ln = nsp_list_length(L);
    }
  
  /* second pass to fix values 
   * the first rectangle is just used to give default values.
   */
  cloc =  cloc->next;
  i = 0;
  while ( cloc != NULLCELL ) 
    {
      R = (NspGrRect *) cloc->O;
      if ( vert ) 
	{
	  R->obj->x= x; R->obj->y= y-i*hr; R->obj->w= w; R->obj->h= hr;
	}
      else
	{
	  R->obj->x= x+i*wr; R->obj->y= y; R->obj->w= wr; R->obj->h= h;
	}
      cloc = cloc->next;
      i++;
    }
  G->type->link_figure(G,G->obj->Fig,G->obj->Axe);
  return OK;
}


static int scicos_sliderm_update_rects(NspCompound *C,const double *u, 
				       const double *rpar)
{
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  double val, percent;
  NspGrRect *R;
  int count = 0;
  double z1=0.0,z2=0.0;
  /* first one */
  R = (NspGrRect *) cloc->O;
  if (vert) 
    {
      z1 = R->obj->w;
    }
  else			
    {
      z1 = R->obj->y;
      z2 = R->obj->h;
    }
  
  cloc = cloc->next;
  while ( cloc != NULLCELL ) 
    {
      R = (NspGrRect *) cloc->O;
      val = Min (rpar[1], Max (rpar[0], u[count]));
      percent = (val - rpar[0]) / (rpar[1] - rpar[0]);
      if ( vert ) 
	{
	  R->obj->w= z1*percent;
	}
      else
	{
	  R->obj->y = z1 - z2*(1-percent);
	  R->obj->h= z2*percent;
	}
      count++;
      cloc = cloc->next;
    }
  return TRUE;
}

