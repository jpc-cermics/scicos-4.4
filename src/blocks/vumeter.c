/* Nsp
 * Copyright (C) 2012-2012 Jean-Philippe Chancelier (Enpc)
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
#include <nsp/arrows.h>
#include <nsp/compound.h>

#include <nsp/interf.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "blocks.h"


static NspGrstring *scicos_vumeter_getstring(NspCompound *C);
static NspArrows *scicos_vumeter_getarrows(NspCompound *C);
static void scicos_vumeter_str_update(NspGrstring *S,const int form[], double v);

void scicos_vumeter_block (scicos_block * block, int flag)
{
  double val,percent;
  double *rpar = block->rpar;
  int *ipar =  block->ipar;
  double *u = GetInPortPtrs(block,1);
  /* int nur = GetInPortRows(block,1); */
  /* int nuc = GetInPortCols(block,1); */
  double *z = block->z;
  /* double nz= block->nz; */
  NspGrstring **GrS= (NspGrstring **) &z[0] ;
  NspArrows **Arrows= (NspArrows **) &z[1] ;
  NspGraphic *Gr=Scicos->Blocks[Scicos->params.curblk -1].grobj;
  
  switch (flag)
    {
    case StateUpdate:
      /* standard case */
      if ( *GrS == NULL) return;
      if ( ipar[0] == 1 ) 
	{
	  scicos_vumeter_str_update(*GrS,&ipar[4], u[0]);
	}
      if ( *Arrows == NULL) return;
      val = Min (rpar[1], Max (rpar[0], u[0]));
      percent = (val - rpar[0]) / (rpar[1] - rpar[0]);
      (*Arrows)->obj->x->R[1]=(*Arrows)->obj->x->R[0]- z[2]*cos( M_PI*(100-percent));
      (*Arrows)->obj->y->R[1]=(*Arrows)->obj->y->R[0]- z[2]*sin( M_PI*(100-percent));
      nsp_graphic_invalidate(Gr);
      break;
    case Initialization:
      /* initial case  */
      Gr = Scicos->Blocks[Scicos->params.curblk -1].grobj;
      *GrS = NULL;
      if ( Gr != NULL && IsCompound((NspObject *) Gr))
	{
	  double dx,dy;
	  *GrS = scicos_vumeter_getstring((NspCompound *) Gr);
	  *Arrows= scicos_vumeter_getarrows((NspCompound *) Gr);
	  dx= (*Arrows)->obj->x->R[1]-(*Arrows)->obj->x->R[0];
	  dy= (*Arrows)->obj->y->R[1]-(*Arrows)->obj->y->R[0];
	  z[2]= sqrt(dx*dx+dy*dy);
	  if (GrS != NULL &&  ipar[0] == 0 ) 
	    {
	      ((NspGraphic *) (*GrS))->obj->show = FALSE;
	    }
	}
      break;
    case Ending:
      /* reset back default size: we cannot use z[0] here */
      if (Gr!= NULL &&  ipar[0] == 0 ) 
	{
	  NspGrstring *S = scicos_vumeter_getstring((NspCompound *) Gr);
	  if ( S != NULL) 
	    ((NspGraphic *) S)->obj->show = TRUE;
	}
      break;
    }
}


static NspGrstring *scicos_vumeter_getstring(NspCompound *C)
{
  NspGrstring *S;
  NspList *L = C->obj->children;
  Cell *cloc = L->last;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      S=scicos_vumeter_getstring((NspCompound *) cloc->O);
	      if ( S != NULL) return S;
	    }
	  else if ( IsGrstring(cloc->O) )
	    {
	      return (NspGrstring *) cloc->O;
	    }
	}
      cloc = cloc->prev;
    }
  return NULL;
}

static NspArrows *scicos_vumeter_getarrows(NspCompound *C)
{
  NspArrows *S;
  NspList *L = C->obj->children;
  Cell *cloc = L->last;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      S=scicos_vumeter_getarrows((NspCompound *) cloc->O);
	      if ( S != NULL) return S;
	    }
	  else if ( IsArrows(cloc->O) )
	    {
	      return (NspArrows*) cloc->O;
	    }
	}
      cloc = cloc->prev;
    }
  return NULL;
}


static void scicos_vumeter_str_update(NspGrstring *S,const int form[], double v)
{
  /* int ok = FALSE; */
  char *st=S->obj->text->S[0];
  char buf[128];
  int kj =sprintf(buf,"%*.*f",form[0], form[1], v);
  if ( kj > form[0]) 
    {
      kj = sprintf(buf,"%*s",form[0],"*");
    }
  if ( strlen(st) != strlen(buf) )
    {
      Sciprintf("Warning: buffer has wrong size\n");
    }
  /* if ( strcmp(st,buf) != 0 ) ok = TRUE; */
  snprintf(st,strlen(st)+1,"%s",buf);
}
