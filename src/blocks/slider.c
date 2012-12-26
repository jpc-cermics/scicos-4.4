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

static NspGrRect *scicos_slider_getrect(NspCompound *C);
#if 0
static int scicos_get_named_color(NspGraphic *G,const char *str);
#endif 
/*
 * follow an input value with a graphic slider 
 * 
 *  rpar = [min-range, max-range] 
 *  ipar = [type,color,window]
 *  z = size 6 
 */


void scicos_slider_block (scicos_args_F0);
void scicos_slider_block (int *flag, int *nevprt, const double *t, double *xd,
			  double *x, int *nx, double *z, int *nz,
			  double *tvec, int *ntvec, double *rpar,
			  int *nrpar, int *ipar, int *nipar,
			  double *u, int *nu, double *y, int *ny)
{
  int red=5,green=3;
  double val,percent,dx;
  NspGrRect **S= (NspGrRect **) &z[0] ;
  NspGraphic *Gr=Scicos->Blocks[Scicos->params.curblk -1].grobj;
  switch (*flag)
    {
    case 2:
      /* standard case */
      if ( *S == NULL) return;
      val = Min (rpar[1], Max (rpar[0], u[0]));
      percent = (val - rpar[0]) / (rpar[1] - rpar[0]);
      if ( TRUE ) 
	{
	  switch ( ipar[0]) 
	    {
	    case 0 :
	      if (percent >= 0.5 ) 
		{
		  (*S)->obj->fill_color= green;
		}
	      else 
		{
		  (*S)->obj->fill_color= red;
		}
	      nsp_graphic_invalidate(Gr);
	      break;
	    case 1 : 
	      z[1] = percent;
	      (*S)->obj->w= z[2]*percent;
	      nsp_graphic_invalidate(Gr);
	      break;
	    case 2 : 
	      (*S)->obj->x= z[3] + z[2]*percent - z[2]*0.05 ;
	      dx = z[3] - (*S)->obj->x;
	      if (dx >= 0) 
		{ (*S)->obj->x = z[3]; (*S)->obj->w=Max(0,z[2]*0.1 - dx);}
	      dx =((*S)->obj->x+z[2]*0.1)-(z[3] + z[2]);
	      if (dx >= 0)
		{
		  (*S)->obj->w= z[2]*0.1 -dx ;
		}
	      nsp_graphic_invalidate(Gr);
	      break;
	    }
	}
      break;
    case 4:
      /* initial case  */
      z[1] = 0.0;
      Gr = Scicos->Blocks[Scicos->params.curblk -1].grobj;
      *S = NULL;
      if ( Gr != NULL && IsCompound((NspObject *) Gr))
	{
	  /* red = scicos_get_named_color(Gr,"red"); */
	  /* green = scicos_get_named_color(Gr,"green"); */
	  *S = scicos_slider_getrect((NspCompound *) Gr);
	  if ( *S != NULL) 
	    {
	      z[2] = (*S)->obj->w;
	      z[3] = (*S)->obj->x;
	      switch (ipar[0])
		{
		case 2:   (*S)->obj->w= z[2]*0.1; break;
		default: break;
		}
	    }
	}
      break;
    case 5:
      /* reset back default size */
      if ( *S != NULL) 
	{
	  switch ( ipar[0]) 
	    {
	    case 0 : (*S)->obj->fill_color=ipar[1]; break;
	    case 1 : (*S)->obj->w= z[2]; break;
	    case 2 : (*S)->obj->x= z[3];(*S)->obj->w= z[2]; break;
	    }
	}
      break;
    }
}

static NspGrRect *scicos_slider_getrect(NspCompound *C)
{
  NspGrRect *S;
  NspList *L = C->obj->children;
  Cell *cloc = L->first;
  while ( cloc != NULLCELL ) 
    {
      if ( cloc->O != NULLOBJ ) 
	{
	  if (IsCompound(cloc->O))
	    {
	      S=scicos_slider_getrect((NspCompound *) cloc->O);
	      if ( S != NULL) return S;
	    }
	  else if ( IsGrRect(cloc->O) )
	    {
	      return (NspGrRect *) cloc->O;
	    }
	}
      cloc = cloc->next;
    }
  return NULL;
}

#if 0
static int scicos_get_named_color(NspGraphic *G,const char *str)
{
  int rep,color;
  BCG *Xgc;
  const char *Table[] = {"black","white","gray","blue","green","lightblue",
			 "red","purple","yellow",NULL};
  nsp_figure *F = G->obj->Fig;
  if ( F == NULL || (Xgc=F->Xgc) == NULL ) return 0;
  rep = is_string_in_array(str,Table,TRUE);
  if ( rep < 0 ) return 0;
  color= Xgc->graphic_engine->xget_last(Xgc)+rep+1;
  fprintf(stderr,"%s is %d %d\n",str,rep,color);
  return color;
}
#endif 

