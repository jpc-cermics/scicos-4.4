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

static NspCompound *scicos_sliderm_getrects(NspCompound *C,int nu,int color);
static NspCompound *scicos_sliderm_rects(NspGrRect *R, int nu,int color);

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

void scicos_sliderm_block (scicos_block * block, int flag)
{
  double *rpar = block->rpar;
  double *u = GetInPortPtrs(block,1);
  int nur = GetInPortRows(block,1);
  /* int nuc = GetInPortCols(block,1); */
  double *z = block->z;
  /* double nz= block->nz; */
  double val,percent;
  NspCompound **S= (NspCompound **) &z[0] ;
  NspGraphic *Gr=Scicos->Blocks[Scicos->params.curblk -1].grobj;
  switch (flag)
    {
    case StateUpdate:
      /* standard case */
      if ( *S == NULL) return;
      {
	int count = 0;
	/* loop */
	NspList *L = (*S)->obj->children;
	Cell *cloc = L->first;
	while ( cloc != NULLCELL ) 
	  {
	    if ( cloc->O != NULLOBJ ) 
	      {
		NspGrRect *R = 	(NspGrRect *) cloc->O;
		val = Min (rpar[1], Max (rpar[0], u[count]));
		percent = (val - rpar[0]) / (rpar[1] - rpar[0]);
		z[1] = percent;
		R->obj->w= z[2]*percent;
		count++;
	      }
	    cloc = cloc->next;
	  }
	nsp_graphic_invalidate(Gr);
      break;
    case Initialization:
      /* initial case  */
      z[1] = 0.0;
      Gr = Scicos->Blocks[Scicos->params.curblk -1].grobj;
      *S = NULL;
      if ( Gr != NULL && IsCompound((NspObject *) Gr))
	{
	  *S = scicos_sliderm_getrects((NspCompound *) Gr,nur,block->ipar[1]);
	  if ( *S != NULL) 
	    {
	      NspList *L = (*S)->obj->children;
	      Cell *cloc = L->first;
	      while ( cloc != NULLCELL ) 
		{
		  if ( cloc->O != NULLOBJ ) 
		    {
		      z[2] = ((NspGrRect *) cloc->O)->obj->w;
		      break;
		    }
		  cloc = cloc->next;
		}
	    }
	}
      }
      break;
    case Ending:
      /* reset back default size */
      /* if ( *S != NULL)  (*S)->obj->w= z[2]; */
      break;
    }
}

static NspCompound *scicos_sliderm_getrects(NspCompound *C,int nu,int color)
{
  NspGrRect *R;
  NspCompound *Cr=NULL,*S;
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      S=scicos_sliderm_getrects((NspCompound *) cloc->O,nu,color);
	      if ( S != NULL) return S;
	    }
	  else if ( IsGrRect(cloc->O) )
	    {
	      /* if R is found we insert multiple rectangle */
	      R=(NspGrRect *) cloc->O;
	      ((NspGraphic *) R)->obj->show = FALSE;
	      Cr = scicos_sliderm_rects(R, nu,color);
	      break;
	    }
	}
      cloc = cloc->next;
    }
  if ( Cr != NULL ) 
    {
      if ( nsp_list_end_insert(L,(NspObject *) Cr )== FAIL)
	return NULL;
      return Cr;
    }
  return NULL;
}

/* make a set of rects and put them in a compound */

static NspCompound *scicos_sliderm_rects(NspGrRect *R, int nu,int color)
{
  int i;
  NspList *L;
  NspCompound *C = NULL;
  NspGraphic *G;
  NspGraphic *gobj = NULL;
  double x= R->obj->x, y = R->obj->y, w= R->obj->w, h=R->obj->h;
  double hr = h/nu;
  if ((C= nsp_compound_create("c",NULL,NULL,NULL))== NULL) return NULL;
  L = C->obj->children;
  for ( i = 0 ; i < nu ; i++)
    {
      int icolor=-1,iback=color,ithickness=-1;
      if ((gobj =(NspGraphic *) nsp_grrect_create("rect",x,y -i*hr,w,hr,
						  iback,ithickness,icolor,0.0,NULL))== NULL)
	return NULL;
      /* insert in the compound */
      if ( nsp_list_end_insert(L,(NspObject *) gobj )== FAIL)
	return NULL;
    }
  G= (NspGraphic *) C;
  G->type->link_figure(G,((NspGraphic *) R)->obj->Fig,((NspGraphic *) R)->obj->Axe);
  return C;
} 
