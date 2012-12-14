/* 
 * Copyright (C) 2012-2012 Alan Layec (Enpc) 
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
 * set of nsp macros rewriten as C functions.
 *
 * scicos_dist2polyline
 * scicos_dist2polyline_jpc
 * scicos_rotate
 * scicos_get_data_block
 * scicos_get_data_text
 * scicos_get_data_link
 * scicos_getobj
 * scicos_getblock
 * scicos_getblocklink
 * scicos_getobjs_in_rect
 * 
 */

#include <nsp/nsp.h>
#include <nsp/objects.h>
#include <nsp/compound.h>
#include "blocks/blocks.h"

/* scicos_dist2polyline
 *
 * [d,pt_out,ind]=dist2polyline(xp,yp,np,pt)
 *
 */

static int scicos_dist2polyline(double *xp,double *yp,int np,const double *pt,double *d,double *pt_out,int *ind)
{
  int *cr=NULL, npp=np , i;
  double x=pt[0],y=pt[1],v;
  double *xpp=NULL, *ypp=NULL, *spp=NULL;

  /* cr computation */
  if (( cr=malloc(sizeof(int)*(np-1)) ) == NULL) return FALSE;
  
  for (i=0;i<(np-1);i++) 
    {
      cr[i] = 0;
      v = (xp[i]-x) * (xp[i]-xp[i+1]) + (yp[i]-y) * (yp[i]-yp[i+1]);
      if ( v > 0.0 )
	cr[i] = 4;
      else if (v < 0.0)
	cr[i] = -4;
      v = (xp[i+1]-x) * (xp[i+1]-xp[i]) + (yp[i+1]-y) * (yp[i+1]-yp[i]);
      if ( v > 0.0 )
	cr[i] += 1;
      else if (v < 0.0)
	cr[i] += -1;
      if (cr[i]==5) npp++;
    }
  if ((npp-np)>0) {
    double dx,dy,d_d,d_x,d_y;
    int k=0;

    if (( xpp=malloc(sizeof(double)* npp) ) == NULL) goto err1;
    if (( ypp=malloc(sizeof(double)* npp) ) == NULL) goto err1bis;

    for (i=0;i<np;i++) {
      xpp[i]=xp[i];
      ypp[i]=yp[i];
    }

    for (i=0;i<(np-1);i++) {
      if (cr[i]==5) {
        dx=xpp[i+1]-xpp[i];
        dy=ypp[i+1]-ypp[i];

        d_d=dx*dx+dy*dy;

        d_x=( dy*( -xpp[i+1]*ypp[i] + xpp[i]*ypp[i+1]) + dx*(dx*pt[0]+dy*pt[1])) / d_d;
        d_y=(-dx*( -xpp[i+1]*ypp[i] + xpp[i]*ypp[i+1]) + dy*(dx*pt[0]+dy*pt[1])) / d_d;

        xpp[np+k]=d_x;
        ypp[np+k]=d_y;

        k++;
      }
    }

  } else {
    xpp=xp;
    ypp=yp;
  }

  if ((spp=malloc(sizeof(double)* npp)) == NULL) goto err2;

  for (i=0;i<npp;i++) {
    spp[i] = (xpp[i]-pt[0])*(xpp[i]-pt[0]) + (ypp[i]-pt[1])*(ypp[i]-pt[1]);
  }

  (*ind)=nsp_array_mini(npp, spp, 1, d);
  (*d)=sqrt((*d));

  pt_out[0]=xpp[(*ind)-1];
  pt_out[1]=ypp[(*ind)-1];

  if ((*ind)>np) {
    int k=0;
    for (i=0;i<(np-1);i++) {
      if (cr[i]==5) {
        k++;
        if (k==((*ind)-np)) {
          (*ind)=(i+1);
          break;
        }
      }
    }
  } else {
    (*ind)=-(*ind);
  }

  free(spp);
  if ((npp-np)>0) {
    free(xpp);
    free(ypp);
  }
  free(cr);
  return TRUE;

err1:
  free(cr);
  return FALSE;

err1bis:
  free(cr);
  free(xpp);
  return FALSE;

err2:
  free(cr);
  if ((npp-np)>0) {
    free(xpp);
    free(ypp);
  }
  return FALSE;
}

/**************************************************
 * utility function
 * distance from a point to a polyline
 * the point is on the segment [kmin,kmin+1] (note that
 * kmin is < size(xp,'*'))
 * and its projection is at point
 * pt = [ xp(kmin)+ pmin*(xp(kmin+1)-xp(kmin)) ;
 *        yp(kmin)+ pmin*(yp(kmin+1)-yp(kmin))
 * the distance is dmin
 * Copyright ENPC
 **************************************************/

static void scicos_dist2polyline_jpc(double *xp,double *yp,int np,const double pt[2],
                                     double pt_proj[2],int *kmin,double *pmin,
                                     double *dmin)
{
  double ux,uy,wx,wy,un,gx,gy;
  int n= np;
  double p,d;
  int i;
  *dmin = 1.0+10; /* XXXXX max_double */
  for ( i = 0 ; i < n-1 ; i++)
    {
      ux = xp[i+1]-xp[i];
      uy = yp[i+1]-yp[i];
      wx = pt[0] - xp[i];
      wy = pt[1] - yp[i];
      un= Max(ux*ux + uy*uy,1.e-10); /* XXXX */
      p = Max(Min((ux*wx+ uy*wy)/un,1),0);
      /* the projection of pt on each segment */
      gx= wx -  p * ux;
      gy= wy -  p * uy;
      d = Max(Abs(gx),Abs(gy));
      if ( d < *dmin )
        {
          *dmin = d;
          *pmin = p;
          *kmin = i+1;
          pt_proj[0]= xp[i]+ p*ux;
          pt_proj[1]= yp[i]+ p*uy;
        }
    }
}

/* scicos_rotate
 *
 * [xy_out]=rotate(xy_in,nxy,teta,orig)
 */

static void scicos_rotate(const double *xy_in,int nxy,double teta,const double *orig,double *xy_out)
{
  int i; 
  double cost=cos(teta), sint = sin(teta);
  for (i=0 ; i < nxy ; i++) 
    {
      xy_out[i] = cost*(xy_in[i] -orig[0]) + sint*(xy_in[i+nxy] -orig[1]) + orig[0];
      xy_out[i+nxy] = -sint*(xy_in[i] -orig[0]) + cost*(xy_in[i+nxy] -orig[1]) + orig[1];
    }
}

/* scicos_get_data_block
 *
 * [data]=get_data_block(o,pt)
 * return %TRUE or %FALSE if pt is inside object boundary or not 
 *
 */

static int scicos_get_data_block(NspObject *o,const double *pt)
{
  NspObject *gr;
  double rect[4], eps_blk=3;
  
  nsp_hash_find((NspHash*)o,"gr",&gr);
  if ( gr == NULL) return FALSE;
  
  rect[0]=((NspCompound *)gr)->obj->bounds->R[0] - eps_blk;
  rect[1]=((NspCompound *)gr)->obj->bounds->R[1] - eps_blk;
  rect[2]=((NspCompound *)gr)->obj->bounds->R[2] + eps_blk;
  rect[3]=((NspCompound *)gr)->obj->bounds->R[3] + eps_blk;
  return ((rect[0]-pt[0])*(rect[2] -pt[0]) < 0) 
    && ((rect[1]-pt[1])*(rect[3] -pt[1]) < 0 );
}


/* scicos_get_data_text
 *
 * [data]=get_data_text(o,pt)
 *
 * compute the enclosing rectangle of the string
 * taking care of angles. data is negative when
 * pt is inside the bounds of the text
 * return %TRUE or %FALSE if pt is inside object boundary or not 
 * 
 */

static int scicos_get_data_text(NspObject *o,const double *pt)
{
  NspObject *graphics, *T;
  double *orig, *sz, theta, xy[2], center[2];
  nsp_hash_find((NspHash*)o,"graphics",&graphics);
  nsp_hash_find((NspHash*)graphics,"orig",&T);
  orig=((NspMatrix *)T)->R;
  nsp_hash_find((NspHash*)graphics,"sz",&T);
  sz=((NspMatrix *)T)->R;
  nsp_hash_find((NspHash*)graphics,"theta",&T);
  theta=((NspMatrix *)T)->R[0];
  theta=-theta*M_PI/180;
  center[0]=orig[0]+sz[0]/2;
  center[1]=orig[1]+sz[1]/2;
  
  scicos_rotate(pt,1,theta,center,xy);

  return ((orig[0]-xy[0])*(orig[0]+sz[0]-xy[0]) < 0 )
    && ( (orig[1]-xy[1])*(orig[1]+sz[1]-xy[1]) < 0);
}

/* scicos_get_data_link
 *
 * [data,wh]=get_data_link(o,pt)
 *
 * return %TRUE or %FALSE if pt is inside object boundary or not 
 * 
 */

static int scicos_get_data_link(NspObject *o,const double *pt, int *wh)
{
  NspObject *xx, *yy;
  double *xp, *yp, pt_out[2], pmin, data, eps_lnk=4;
  int np;

  *wh=-1;
  
  nsp_hash_find((NspHash*)o,"xx",&xx);
  nsp_hash_find((NspHash*)o,"yy",&yy);
  
  xp=((NspMatrix *)xx)->R;
  yp=((NspMatrix *)yy)->R;
  np=((NspMatrix *)xx)->mn;

  scicos_dist2polyline_jpc(xp,yp,np,pt,pt_out,wh,&pmin,&data);
  data=data-eps_lnk;
  
  /* fprintf(stderr,"scicos_dist2polyline_jpc : data=%f, wh=%d\n",(*data),*wh);
   *   
   *   scicos_dist2polyline(xp,yp,np,pt,data,pt_out,wh);
   *   (*data)=(*data)-eps_lnk;
   *   
   * fprintf(stderr,"scicos_dist2polyline : data=%f, wh=%d\n\n",(*data),*wh);
   */

   return (data<0) ;
}

/* scicos_getobj
 *
 * [k,wh]=scicos_getobj(scs_m,pt)
 *
 * nb : we don't use scicos_is_x to optimize
 *      loops on large diagram (remove supposed
 *      not needed test if...)
 */

int scicos_getobj(NspObject *obj,const double *pt,int *k, int *wh)
{
  NspHash *scs_m = (NspHash*) obj;
  NspObject *objs;
  NspObject *T;
  NspObject *o;
  Cell *cloc;

  int i,j,n;

  if (!IsHash(obj)) return FALSE;
  if (nsp_hash_find(scs_m,"objs",&objs) == FAIL) return FALSE;
  if (!IsList(objs) ) return FALSE;

  n = ((NspList *) objs)->nel;

  /* loop on list elements
   * one assume that user "most of time"
   * do operation on lastest handled
   * block in the diagram
   */
  cloc = ((NspList *) objs)->last;
  for (i=n;i>0;i--) {
    o=cloc->O;
    nsp_hash_find((NspHash*) o,"type",&T);
    if (strcmp(((NspSMatrix *)T)->S[0],"Block") == 0) {
      if (scicos_get_data_block(o,pt) == TRUE) {
        (*k)=i;
        nsp_hash_find((NspHash*) o,"gui",&T);
        /* second pass to detect crossing link */
        if (!((strcmp(((NspSMatrix *)T)->S[0],"IMPSPLIT_f") == 0) ||	\
              (strcmp(((NspSMatrix *)T)->S[0],"SPLIT_f") == 0) ||	\
              (strcmp(((NspSMatrix *)T)->S[0],"BUSSPLIT") == 0) ||	\
              (strcmp(((NspSMatrix *)T)->S[0],"CLKSPLIT_f") == 0))) {
          cloc = cloc->next;
          for (j=i+1;j<=n;j++) {
            o=cloc->O;
            nsp_hash_find((NspHash*) o,"type",&T);
            if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
              if (scicos_get_data_link(o,pt,wh) == TRUE) {
               (*k)=j;
               return TRUE;
              }
            }
            cloc = cloc->next;
          }
        }
        return TRUE;
       }
    }
    cloc = cloc->prev;
  }
  
  /* loop on list elements
   * one checks link and text
   */
  cloc = ((NspList *) objs)->last;
  for (i=n;i>0;i--) 
    {
      const char *str;
      o=cloc->O;
      nsp_hash_find((NspHash*) o,"type",&T);
      str = ((NspSMatrix *)T)->S[0];
      if (strcmp(str,"Text") == 0) {
        if (scicos_get_data_text(o,pt) == TRUE) {
          (*k)=i;
          return TRUE;
        }
      }
      else if (strcmp(str,"Link") == 0) {
        if (scicos_get_data_link(o,pt,wh) == TRUE) {
          (*k)=i;
          return TRUE;
        }
      }
      cloc = cloc->prev;
    }
  return TRUE;
}

/* scicos_getblock
 *
 * [k]=scicos_getblock(scs_m,pt)
 *
 * nb : we don't use scicos_is_x to optimize
 *      loops on large diagram (remove supposed
 *      not needed test if...)
 */

int scicos_getblock(NspObject *obj,double *pt,int *k)
{
  NspHash *scs_m = (NspHash*) obj;
  NspObject *objs, *T, *o;
  Cell *cloc;
  int i,n;
  
  if (!IsHash(obj)) return FALSE;
  if (nsp_hash_find(scs_m,"objs",&objs) == FAIL) return FALSE;
  if (!IsList(objs) ) return FALSE;
  
  n = ((NspList *) objs)->nel;

  /* loop on list elements */
  cloc = ((NspList *) objs)->last;
  for (i=n;i>0;i--) {
    o=cloc->O;
    nsp_hash_find((NspHash*) o,"type",&T);
    if (strcmp(((NspSMatrix *)T)->S[0],"Block") == 0) {
      if (scicos_get_data_block(o,pt) == TRUE) {
        (*k)=i;
        return TRUE;
      }
    }
    cloc = cloc->prev;
  }
  return TRUE;
}

/* scicos_getblocklink
 *
 * [k,wh]=scicos_getblocklink(scs_m,pt)
 *
 * nb : we don't use scicos_is_x to optimize
 *      loops on large diagram (remove supposed
 *      not needed test if...)
 */

int scicos_getblocklink(NspObject *obj,double *pt,int *k, int *wh)
{
  NspHash *scs_m = (NspHash*) obj;
  NspObject *objs;
  NspObject *T;
  NspObject *o;
  Cell *cloc;

  int i,n;

  if (!IsHash(obj)) return FALSE;
  if (nsp_hash_find(scs_m,"objs",&objs) == FAIL) return FALSE;
  if (!IsList(objs) ) return FALSE;

  n = ((NspList *) objs)->nel;

  /* loop on list elements */
  cloc = ((NspList *) objs)->last;
  for (i=n;i>0;i--) {
    o=cloc->O;
    nsp_hash_find((NspHash*) o,"type",&T);
    if (strcmp(((NspSMatrix *)T)->S[0],"Block") == 0) {
      if (scicos_get_data_block(o,pt) == TRUE) {
        (*k)=i;
        return TRUE;
      }
    }
    else if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
      if (scicos_get_data_link(o,pt,wh)==TRUE) {
        (*k)=i;
        return TRUE;
      }
    }
    cloc = cloc->prev;
  }
  return TRUE;
}

/* scicos_getobjs_in_rect
 *
 * [in,out]=scicos_getobjs_in_rect(scs_m,ox,oy,w,h)
 *
 * nb : we don't use scicos_is_x to optimize
 *      loops on large diagram (remove supposed
 *      not needed test if...)
 */

void scicos_getobjs_in_rect(NspList *objs,double ox,double oy,double w,double h,
			    int *nin,double *in,int *nout,double *out)
{
  NspObject *T,*o;
  int i,ok ;
  Cell *cloc = objs->first;
  int n = ((NspList *) objs)->nel, n_in=0, n_out=0;
  /* loop on list elements */
  for ( i=1 ; i <= n ; i++) 
    {
      const char *str;
      ok=0;
      o=cloc->O;
      nsp_hash_find((NspHash*) o,"type",&T);
      str = ((NspSMatrix *)T)->S[0];
      if (strcmp(str,"Block") == 0 || strcmp(str,"Text") == 0) 
	{
	  NspObject *gr;
	  double *rect;
	  nsp_hash_find((NspHash*)o,"gr",&gr);
	  rect = ((NspCompound *)gr)->obj->bounds->R;
	  if ( (ox <= rect[0]) && (oy >= rect[3]) &&	  
	       ((ox+w) >= rect[2]) && ((oy-h) <= rect[1])) 
	    {
	      ok=1;  in[n_in]=i;n_in++;
	    }
	}
      else if (strcmp(str,"Link") == 0) 
	{
	  NspObject *xx, *yy;
	  double lx_min,lx_max, ly_min,ly_max;

	  nsp_hash_find((NspHash*)o,"xx",&xx);
	  nsp_hash_find((NspHash*)o,"yy",&yy);

	  nsp_array_mini(((NspMatrix *)xx)->mn, ((NspMatrix *)xx)->R, 1, &lx_min);
	  nsp_array_maxi(((NspMatrix *)xx)->mn, ((NspMatrix *)xx)->R, 1, &lx_max);
	  nsp_array_mini(((NspMatrix *)yy)->mn, ((NspMatrix *)yy)->R, 1, &ly_min);
	  nsp_array_maxi(((NspMatrix *)yy)->mn, ((NspMatrix *)yy)->R, 1, &ly_max);

	  if ( (ox <= lx_min) && (oy >= ly_max) && 
	       ((ox+w) >= lx_max) && ((oy-h) <= ly_min))
	    {
	      ok=1;  in[n_in]=i;n_in++;
	    }
	}
      
      if (!ok) 
	{
	  out[n_out]=i;n_out++;
	}
      cloc = cloc->next;
    }
  *nin=n_in;
  *nout= n_out;
}

