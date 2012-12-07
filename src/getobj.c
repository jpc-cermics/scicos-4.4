/* getobj.c
 * 
 * rewritten set af nsp macros to improve
 * responsiveness of scicos editor for large diagram
 *
 * Alan Layec, 7/12/12.
 *
 * scicos_dist2polyline
 * scicos_rotate
 * 
 * scicos_get_data_block
 * scicos_get_data_text
 * scicos_get_data_link
 *
 * scicos_getobj
 * scicos_getblock
 * scicos_getblocklink
 *
 * scicos_getobjs_in_rect
 * 
 */

#include <nsp/nsp.h>
#include <nsp/objects.h>
#include <nsp/compound.h>
#include "./blocks/blocks.h"

/* scicos_dist2polyline
 *
 * [d,pt_out,ind]=dist2polyline(xp,yp,np,pt)
 *
 */
int scicos_dist2polyline(double *xp,double *yp,int np,double *pt,double *d,double *pt_out,int *ind)
{
  int *cr=NULL;
  double x,y,v;

  double *xpp=NULL;
  double *ypp=NULL;
  double *spp=NULL;
  int npp;

  int i;

  x=pt[0];
  y=pt[1];

  npp=np;

  /* cr computation */
  if (( cr=malloc(sizeof(int)*(np-1)) ) == NULL) return FALSE;

  for (i=0;i<(np-1);i++) {
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
    if (( ypp=malloc(sizeof(double)* npp) ) == NULL) goto err1;

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

err2:
  free(cr);
  if ((npp-np)>0) {
    free(xpp);
    free(ypp);
  }
  return FALSE;
}

/* scicos_rotate
 *
 * [xy_out]=rotate(xy_in,nxy,teta,orig)
 *
 */
void scicos_rotate(double *xy_in,int nxy,double teta,double *orig,double *xy_out)
{
  int i;

  int n=2;
  double M[4];

  M[0]=cos(teta);
  M[1]=-sin(teta);
  M[2]=-M[1];
  M[3]=M[0];

  for (i=0;i<nxy;i++) {
    xy_in[i]     = xy_in[i]     - orig[0];
    xy_in[i+nxy] = xy_in[i+nxy] - orig[1];
  }

  nsp_calpack_dmmul(M, &n, xy_in, &n, xy_out, &n, &n, &n, &nxy);

  for (i=0;i<nxy;i++) {
    xy_in[i]     = xy_in[i]     + orig[0];
    xy_in[i+nxy] = xy_in[i+nxy] + orig[1];

    xy_out[i]     = xy_out[i]     + orig[0];
    xy_out[i+nxy] = xy_out[i+nxy] + orig[1];
  }
}

/* scicos_get_data_block
 *
 * [data]=get_data_block(o,pt)
 *
 * data is negative when
 * pt is near a bounding box of a blk.
 *
 */
void scicos_get_data_block(NspObject *o,double *pt,double *data)
{
  NspObject *gr;

  double orig[2];
  double sz[2];
  double rect[4];
  double eps_blk=3;

  nsp_hash_find((NspHash*)o,"gr",&gr);

  rect[0]=((NspCompound *)gr)->obj->bounds->R[0];
  rect[1]=((NspCompound *)gr)->obj->bounds->R[1];
  rect[2]=((NspCompound *)gr)->obj->bounds->R[2];
  rect[3]=((NspCompound *)gr)->obj->bounds->R[3];

  orig[0]=rect[0]-eps_blk;
  orig[1]=rect[1]-eps_blk;

  sz[0]=rect[2]-rect[0]+2*eps_blk;
  sz[1]=rect[3]-rect[1]+2*eps_blk;

  data[0]=(orig[0]-pt[0])*(orig[0]+sz[0]-pt[0]);
  data[1]=(orig[1]-pt[1])*(orig[1]+sz[1]-pt[1]);
}

/* scicos_get_data_text
 *
 * [data]=get_data_text(o,pt)
 *
 * compute the enclosing rectangle of the string
 * taking care of angles. data is negative when
 * pt is inside the bounds of the text
 * 
 */
void scicos_get_data_text(NspObject *o,double *pt,double *data)
{
  NspObject *graphics;
  NspObject *T;

  double *orig;
  double *sz;
  double theta;
  double xy[2];
  double center[2];

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

  data[0]=(orig[0]-xy[0])*(orig[0]+sz[0]-xy[0]);
  data[1]=(orig[1]-xy[1])*(orig[1]+sz[1]-xy[1]);
}

/* scicos_get_data_link
 *
 * [data,wh]=get_data_link(o,pt)
 *
 * data is negative when
 * pt is near a segment of a link.
 * 
 */
void scicos_get_data_link(NspObject *o,double *pt,double *data,int *wh)
{
  NspObject *xx;
  NspObject *yy;

  double *xp,*yp;
  double pt_out[2];
  int np;
  double eps_lnk=4;

  nsp_hash_find((NspHash*)o,"xx",&xx);
  nsp_hash_find((NspHash*)o,"yy",&yy);

  xp=((NspMatrix *)xx)->R;
  yp=((NspMatrix *)yy)->R;
  np=((NspMatrix *)xx)->mn;

  scicos_dist2polyline(xp,yp,np,pt,data,pt_out,wh);

  (*data)=(*data)-eps_lnk;
}

/* scicos_getobj
 *
 * [k,wh]=scicos_getobj(scs_m,pt)
 *
 * nb : we don't use scicos_is_x to optimize
 *      loops on large diagram (remove supposed
 *      not needed test if...)
 */
int scicos_getobj(NspObject *obj,double *pt,int *k, int *wh)
{
  NspHash *scs_m = (NspHash*) obj;
  NspObject *objs;
  NspObject *T;
  NspObject *o;
  Cell *cloc;

  double data[2];
  int i,j,n;

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
      scicos_get_data_block(o,pt,data);
      if ((data[0]<0) && (data[1]<0)) {
        (*k)=i;
        nsp_hash_find((NspHash*) o,"gui",&T);
        /* second pass to detect crossing link */
        if (!((strcmp(((NspSMatrix *)T)->S[0],"IMPSPLIT_f") == 0) || \
              (strcmp(((NspSMatrix *)T)->S[0],"SPLIT_f") == 0) || \
              (strcmp(((NspSMatrix *)T)->S[0],"BUSSPLIT") == 0) || \
              (strcmp(((NspSMatrix *)T)->S[0],"CLKSPLIT_f") == 0))) {
          cloc = cloc->next;
          for (j=i+1;j<=n;j++) {
            o=cloc->O;
            nsp_hash_find((NspHash*) o,"type",&T);
            if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
              scicos_get_data_link(o,pt,data,wh);
              if ((*data)<0) {
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

  cloc = ((NspList *) objs)->last;
  for (i=n;i>0;i--) {
    o=cloc->O;
    nsp_hash_find((NspHash*) o,"type",&T);
    if (strcmp(((NspSMatrix *)T)->S[0],"Text") == 0) {
      scicos_get_data_text(o,pt,data);
      if ((data[0]<0) && (data[1]<0)) {
        (*k)=i;
        return TRUE;
      }
    }
    else if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
      scicos_get_data_link(o,pt,data,wh);
      if ((*data)<0) {
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
  NspObject *objs;
  NspObject *T;
  NspObject *o;
  Cell *cloc;

  double data[2];
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
      scicos_get_data_block(o,pt,data);
      if ((data[0]<0) && (data[1]<0)) {
        (*k)=i;
        nsp_hash_find((NspHash*) o,"gui",&T);
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

  double data[2];
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
      scicos_get_data_block(o,pt,data);
      if ((data[0]<0) && (data[1]<0)) {
        (*k)=i;
        nsp_hash_find((NspHash*) o,"gui",&T);
        return TRUE;
      }
    }
    else if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
      scicos_get_data_link(o,pt,data,wh);
      if ((*data)<0) {
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
int scicos_getobjs_in_rect(NspObject *obj,double ox,double oy,double w,double h, \
                           int *nin,int **in,int *nout,int **out)
{
  NspHash *scs_m = (NspHash*) obj;
  NspObject *objs;
  NspObject *T;
  NspObject *o;
  Cell *cloc;

  int i,n,ok;
  int *tmp;

  if (!IsHash(obj)) return FALSE;
  if (nsp_hash_find(scs_m,"objs",&objs) == FAIL) return FALSE;
  if (!IsList(objs) ) return FALSE;

  n = ((NspList *) objs)->nel;

  /* loop on list elements */
  cloc = ((NspList *) objs)->first;
  for (i=1;i<=n;i++) {
    ok=0;
    o=cloc->O;
    nsp_hash_find((NspHash*) o,"type",&T);
    if ((strcmp(((NspSMatrix *)T)->S[0],"Block") == 0) || \
        (strcmp(((NspSMatrix *)T)->S[0],"Text") == 0)) {
      NspObject *gr;

      double rect[4];
      double orig[2];
      double sz[2];

      nsp_hash_find((NspHash*)o,"gr",&gr);

      rect[0]=((NspCompound *)gr)->obj->bounds->R[0];
      rect[1]=((NspCompound *)gr)->obj->bounds->R[1];
      rect[2]=((NspCompound *)gr)->obj->bounds->R[2];
      rect[3]=((NspCompound *)gr)->obj->bounds->R[3];

      orig[0]=rect[0];
      orig[1]=rect[1];

      sz[0]=rect[2]-rect[0];
      sz[1]=rect[3]-rect[1];

      if ( (ox <= orig[0]) && \
           (oy >= (orig[1]+sz[1])) && \
           ((ox+w) >= (orig[0]+sz[0])) && \
           ((oy-h) <= orig[1]) ) {
        ok=1;
        (*nin)++;

        tmp = realloc((*in),(*nin)*sizeof(int));
        if (tmp==NULL) {
          if ((*in)!=NULL) free((*in));
          if ((*out)!=NULL) free((*out));
          return FALSE;
        } else {
          (*in)=tmp;
        }
        (*in)[(*nin)-1]=i;
      }
    }
    else if (strcmp(((NspSMatrix *)T)->S[0],"Link") == 0) {
      NspObject *xx;
      NspObject *yy;

      double lx_min,lx_max;
      double ly_min,ly_max;

      nsp_hash_find((NspHash*)o,"xx",&xx);
      nsp_hash_find((NspHash*)o,"yy",&yy);

      nsp_array_mini(((NspMatrix *)xx)->mn, ((NspMatrix *)xx)->R, 1, &lx_min);
      nsp_array_maxi(((NspMatrix *)xx)->mn, ((NspMatrix *)xx)->R, 1, &lx_max);
      nsp_array_mini(((NspMatrix *)yy)->mn, ((NspMatrix *)yy)->R, 1, &ly_min);
      nsp_array_maxi(((NspMatrix *)yy)->mn, ((NspMatrix *)yy)->R, 1, &ly_max);

      if ( (ox <= lx_min) && \
           (oy >= ly_max) && \
           ((ox+w) >= lx_max) && \
           ((oy-h) <= ly_min) ) {
        ok=1;
        (*nin)++;

        tmp = realloc((*in),(*nin)*sizeof(int));
        if (tmp==NULL) {
          if ((*in)!=NULL) free((*in));
          if ((*out)!=NULL) free((*out));
          return FALSE;
        } else {
          (*in)=tmp;
        }
        (*in)[(*nin)-1]=i;
      }
    }

    if (!ok) {
      (*nout)++;

      tmp = realloc((*out),(*nout)*sizeof(int));
      if (tmp==NULL) {
        if ((*in)!=NULL) free((*in));
        if ((*out)!=NULL) free((*out));
        return FALSE;
      } else {
        (*out)=tmp;
      }
      (*out)[(*nout)-1]=i;
    }
    cloc = cloc->next;
  }

  return TRUE;
}
