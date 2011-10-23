/* Nsp
 * Copyright (C) 2006-2011 Jean-Philippe Chancelier (Enpc), Alan Layec
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
 * This code is a nsp version of the code necessary to call a block 
 * defined by nsp code
 * 
 *--------------------------------------------------------------------------*/

#include "nsp/machine.h"
#include <nsp/graphics-new/Graphics.h>
#include <nsp/object.h>
#include <nsp/matrix.h>
#include <nsp/smatrix.h>
#include <nsp/imatrix.h> 
#include <nsp/hash.h>
#include <nsp/serial.h>
#include <nsp/list.h>

#include <nsp/interf.h>

#include "nsp/interf.h"
#include "scicos/scicos4.h"

/* XXXXX */
extern int nsp_gtk_eval_function (NspPList * func, NspObject * args[],
				  int n_args, NspObject * ret[], int *nret);
extern int nsp_gtk_eval_function_by_name (char *name, NspObject * args[],
					  int n_args, NspObject * ret[],
					  int *nret);

static int scicos_scifunc (scicos_funflag scsptr_flag, void *scsptr, NspObject ** Args, 
			   int mrhs, NspObject ** Ret, int *mlhs)
{
  switch (scsptr_flag)
    {
    case fun_macros:
      /* 
       *         Sciprintf("Evaluate a given macro\n");
       *         nsp_object_print( Scicos->params.scsptr,0,0,0);
       */
      return nsp_gtk_eval_function ((NspPList *) scsptr, Args,   mrhs, Ret, mlhs);
      break;
    case fun_macro_name:
      /* 
       *         Sciprintf("Evaluate a macro given by its name: %s\n",
       *         Scicos->params.scsptr);
       */
      return nsp_gtk_eval_function_by_name (scsptr, Args, mrhs,  Ret, mlhs);
    case fun_pointer:
      Scierror ("Internal error: Expecting a macro or macro name\n");
      return FAIL;
    }
  return FAIL;
}

/**
 * scicos_itosci:
 * @name: 
 * @x: 
 * @mx: 
 * @nx: 
 * 
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_itosci (const char *name, const int *x, int mx,int nx)
{
  int i;
  NspMatrix *M;
  if ((M = nsp_matrix_create (name, 'r', mx, nx)) == NULLMAT)
    return NULLOBJ;
  for (i = 0; i < M->mn; i++)
    M->R[i] = (double) x[i];
  return NSP_OBJECT (M);
}

/**
 * scicos_inttosci:
 * @name: 
 * @x: 
 * @mx: 
 * @nx: 
 * @typ:
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_inttosci (const char *name, const void *x, int mx,int nx, int typ)
{
  nsp_itype itype;
  NspIMatrix *M;
  
  switch (typ)
  {
    case SCSINT_N    : itype=nsp_gint;
                       break;
    case SCSINT8_N   : itype=nsp_gint8;
                       break;
    case SCSINT16_N  : itype=nsp_gint16;
                       break;
    case SCSINT32_N  : itype=nsp_gint32;
                       break; 
    case SCSUINT_N   : itype=nsp_guint;
                       break; 
    case SCSUINT8_N  : itype=nsp_guint8;
                       break; 
    case SCSUINT16_N : itype=nsp_guint16;
                       break;  
    case SCSUINT32_N : itype=nsp_guint32;
                       break; 
    default          : return NULLOBJ;
  }
  
  if ((M = nsp_imatrix_create(name, mx, nx, itype)) == NULLIMAT) return NULLOBJ;
  
  switch (typ)
  {
    case SCSINT_N    : memcpy((gint *) M->Gint, (SCSINT_COP *) x, M->mn*sizeof(gint));
                       break;
    case SCSINT8_N   : memcpy((gint8 *) M->Gint8, (SCSINT8_COP *) x, M->mn*sizeof(gint8));
                       break;
    case SCSINT16_N  : memcpy((gint16 *) M->Gint16, (SCSINT16_COP *) x, M->mn*sizeof(gint16));
                       break;
    case SCSINT32_N  : memcpy((gint32 *) M->Gint32, (SCSINT32_COP *) x, M->mn*sizeof(gint32));
                       break; 
    case SCSUINT_N   : memcpy((guint *) M->Guint, (SCSUINT_COP *) x, M->mn*sizeof(guint));
                       break; 
    case SCSUINT8_N  : memcpy((guint8 *) M->Guint8, (SCSUINT8_COP *) x, M->mn*sizeof(guint8));
                       break; 
    case SCSUINT16_N : memcpy((guint16 *) M->Guint16, (SCSUINT16_COP *) x, M->mn*sizeof(guint16));
                       break;  
    case SCSUINT32_N : memcpy((guint32 *) M->Guint32, (SCSUINT32_COP *) x, M->mn*sizeof(guint32));
                       break;
  }

  return NSP_OBJECT(M);
}

/**
 * scicos_dtosci:
 * @name: 
 * @x: 
 * @mx: 
 * @nx: 
 * @type: 
 * 
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_dtosci (const char *name, const double *x, int mx,int nx,char type)
{
  NspMatrix *M;
  if ((M = nsp_matrix_create (name, type, mx, nx)) == NULLMAT) return NULLOBJ;
  if (type=='c') {
    memcpy(M->R, x, 2*M->mn*sizeof(double));
  } else {
    memcpy(M->R, x, M->mn*sizeof(double));
  }
  return NSP_OBJECT (M);
}

/**
 * scicos_str2sci:
 * @name: 
 * @x: 
 * 
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_str2sci (const char *name, nsp_const_string x)
{
  return (NspObject *) nsp_smatrix_create (name, 1, 1, x, 1);
}

/**
 * scicos_obj_to_mserial:
 * @x: array pointer 
 * @nx: size of @x 
 * @Obj: #NspObject to be stored in @x
 * 
 * fills array @x of size @nx with the Matrix serialized version 
 * of nsp object @Obj. If @nx is not equal to the serialized size 
 * an error is raised
 * 
 * Return value: %OK or %FAIL
 **/

static int scicos_obj_to_mserial (double *x, int nx, const NspObject * Obj)
{
  int i;
  NspObject *S;
  NspMatrix *A;
  if (nx == 0)
    return OK;
  if ((S = nsp_object_serialize (Obj)) == NULLOBJ)
    return FAIL;
  /* serialize in a matrix */
  A = nsp_serial_to_matrix ((NspSerial *) S);
  nsp_object_destroy (&S);
  if (A == NULLMAT)
    return FAIL;
  if (A->mn != nx)
    {
      Sciprintf
	("Error: cannot store a serialized nsp object (size %d) in double array (soze %d)\n",
	 A->mn, nx);
    }
  for (i = 0; i < A->mn; i++)
    x[i] = A->R[i];
  nsp_matrix_destroy (A);
  return OK;
}

/**
 * scicos_mserial_to_obj:
 * @x: array pointer 
 * @nx: size of @x 
 * 
 * unserialize the nsp object stored in a double array @x.
 * 
 * Return value: %NULLOBJ or a new #NspObject
 **/

static NspObject *scicos_mserial_to_obj (const char *name, const double *x,int nx)
{
  NspMatrix *Z = NULL;
  NspSerial *S = NULL;
  NspObject *Obj = NULL;
  /* new matrix from x */
  if ((Z = nsp_matrix_create_from_array (NVOID, 1, nx, x, NULL)) == NULL)
    goto err;
  if (nx == 0)
    {
      if (nsp_object_set_name (NSP_OBJECT (Z), name) == FAIL)
	goto err;
      return NSP_OBJECT (Z);
    }
  /* Z is supposed to contain serialized data  */
  if ((S = nsp_matrix_to_serial (Z)) == NULL)
    goto err;
  /* unserialize S */
  if ((Obj = nsp_object_unserialize (S)) == NULLOBJ)
    goto err;
  if (nsp_object_set_name (Obj, name) == FAIL)
    goto err;
 err:
  if (S != NULL)
    nsp_serial_destroy (S);
  if (Z != NULL)
    nsp_matrix_destroy (Z);
  return Obj;
}

/**
 * scicos_scitod:
 * @: 
 * @mx: 
 * @nx: 
 * @Ob: 
 * 
 * 
 * Return value: 
 **/

static int scicos_scitod(double *x, int mx, int nx, const NspObject * Ob)
{
  NspMatrix *M = ((NspMatrix *) Ob);
  if (mx * nx == 0 || M->mn == 0)
    return OK;
  if (M->m != mx || M->n != nx || M->rc_type != 'r' || M->rc_type != 'c') {
    Sciprintf("Expecting a (%d,%d) matrix and (%d,%d) returned\n", mx, nx,
              M->m, M->n);
  }
  if (M->rc_type=='c') {
    memcpy(x, M->R, 2*Min(M->mn, mx * nx)*sizeof(double));
  } else {
    memcpy(x, M->R, Min(M->mn, mx * nx)*sizeof(double));
  }
  return OK;
}

/**
 * scicos_scitoi:
 * @: 
 * @mx: 
 * @nx: 
 * @Ob: 
 * 
 * 
 * 
 * Return value: 
 **/

static int scicos_scitoi(int x[], int mx, int nx, const NspObject * Ob)
{
  NspMatrix *M = ((NspMatrix *) Ob);
  int i;
  if (mx * nx == 0 || M->mn == 0)
    return OK;
  if (M->m != mx || M->n != nx || M->rc_type != 'r') {
    Sciprintf ("Expecting a (%d,%d) matrix and (%d,%d) returned\n", mx, nx,M->m, M->n);
  }
  for (i = 0; i < Min (M->mn, mx * nx); i++) x[i] = M->R[i];
  return OK;
}

/**
 * scicos_scitoint:
 * @: 
 * @mx: 
 * @nx: 
 * @Ob: 
 * 
 * 
 * 
 * Return value: 
 **/

static int scicos_scitoint(void *x, int mx, int nx, const NspObject *Ob)
{
  NspIMatrix *M = (NspIMatrix *) Ob;

  if (mx * nx == 0 || M->mn == 0) return OK;
  if (M->m != mx || M->n != nx) {
    Sciprintf("Expecting a (%d,%d) matrix and (%d,%d) returned\n", mx, nx,
              M->m, M->n);
  }
 
  switch (M->itype)
  {
    case nsp_gint    : memcpy((SCSINT_COP *) x, (gint *) M->Gint, M->mn*sizeof(SCSINT_COP));
                       break;
    case nsp_gint8   : memcpy((SCSINT8_COP *) x, (gint8 *) M->Gint8, M->mn*sizeof(SCSINT_COP));
                       break;
    case nsp_gint16  : memcpy((SCSINT16_COP *) x, (gint16 *) M->Gint16, M->mn*sizeof(SCSINT_COP));
                       break;
    case nsp_gint32  : memcpy((SCSINT32_COP *) x, (gint32 *) M->Gint32, M->mn*sizeof(SCSINT_COP));
                       break;
    case nsp_guint   : memcpy((SCSUINT_COP *) x, (guint *) M->Guint, M->mn*sizeof(SCSUINT_COP));
                       break;
    case nsp_guint8  : memcpy((SCSUINT8_COP *) x, (guint8 *) M->Guint8, M->mn*sizeof(SCSUINT8_COP));
                       break;
    case nsp_guint16 : memcpy((SCSUINT16_COP *) x, (guint16 *) M->Guint16, M->mn*sizeof(SCSUINT16_COP));
                       break;
    case nsp_guint32 : memcpy((SCSUINT32_COP *) x, (guint32 *) M->Guint32, M->mn*sizeof(SCSUINT32_COP));
                       break;
    default          : return FAIL;
  }

  return OK;
}

/**
 * scicos_list_to_nsp_list:
 * @:
 * @name:
 * @inptr:
 * @nin:
 * @insz:
 * @insz2:
 * @intyp:
 * 
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_list_to_nsp_list(const char *name, void **inptr,
                                          int nin, int *insz, int *insz2, int *intyp)
{
  NspList *Ob;
  if (nin!=0) {
    if (IsList(NSP_OBJECT(inptr[0]))) {
      if ((Ob=nsp_list_full_copy((NspList *)NSP_OBJECT(inptr[0])))==NULLLIST) return NULL;
      nsp_object_set_name(NSP_OBJECT(Ob),name);
    } else { 
      Sciprintf("Expecting a list for %s. Return an empty list.\n",name);
      if ((Ob=nsp_list_create(name))==NULLLIST) return NULL;
    }
  } else {
    if ((Ob=nsp_list_create(name))==NULLLIST) return NULL;
  }
  return NSP_OBJECT(Ob);
}

/**
 * scicos_nsp_list_to_list:
 * @:
 * @outptr:
 * @nout:
 * @outsz:
 * @outsz2:
 * @outtyp:
 * @Ob:
 * 
 * 
 * 
 * Return value: 
 **/

static int scicos_nsp_list_to_list(void *outptr[], int nout, int outsz[], int outsz2[], int outtyp[],
                                   NspObject *Ob)
{
  int i,nel;
  NspObject *O;
  NspList *L1 = (NspList *) NSP_OBJECT(outptr[0]);
  NspList *L2 = (NspList *) Ob;
  
  /* Remove all elts of L1 */
  nel=L1->nel;
  for (i=0;i<nel;i++) {
    nsp_list_remove_first(L1);
  }
  
  /* Copy all elts of L2 in L1 */
  nel=L2->nel;
  for (i=0;i<nel;i++) {
    if ( (O = nsp_list_get_element(L2,i+1)) == NULLOBJ ) return FAIL;
    if ( (O = nsp_object_copy_with_name(O)) == NULLOBJ ) return FAIL;
    if ( nsp_list_end_insert(L1,O) == FAIL ) {
      return FAIL;
    }
  }
  
  return OK;
}


/**
 * scicos_list_to_vars:
 * @: 
 * @outptr:
 * @nout:
 * @outsz:
 * @outsz2:
 * @outtyp:
 * @Ob:
 * 
 * 
 * 
 * Return value: 
 **/

static int scicos_list_to_vars(void *outptr[], int nout, int outsz[], int outsz2[], int outtyp[],
                               NspObject * Ob)
{
  int k;
  NspList *L = (NspList *) Ob;
  for (k=nout-1;k>=0;k--) {
    NspObject *elt = nsp_list_get_element(L, k+1);
    if (elt == NULL) return FAIL;
    if (IsIMat(elt)) {
      if (scicos_scitoint(outptr[k], outsz[k], outsz2[k], elt) == FAIL) return FAIL;
    } else {
      if (scicos_scitod((double *)outptr[k], outsz[k], outsz2[k], elt) == FAIL) return FAIL;
    }
  }
  return OK;
}

/**
 * scicos_vars_to_list:
 * @:
 * @name:
 * @inptr:
 * @nin:
 * @insz:
 * @insz2:
 * @intyp:
 * 
 * 
 * 
 * Return value: 
 **/

static NspObject *scicos_vars_to_list(const char *name, void **inptr,
                                      int nin, int *insz, int *insz2, int *intyp)
{
  int k;
  NspList *Ob;
  if ((Ob = nsp_list_create (name)) == NULL) return NULL;
  for (k=0;k<nin;k++) {
    NspObject *elt;
    switch (intyp[k])
    {
      case SCSREAL_N    :
        if ((elt=scicos_dtosci("el", (double *)inptr[k], insz[k], insz2[k],'r')) == NULL) {
          nsp_list_destroy(Ob);
          return NULL;
        }
        break;
      case SCSCOMPLEX_N :
        if ((elt=scicos_dtosci("el", (double *)inptr[k], insz[k], insz2[k],'c')) == NULL) {
          nsp_list_destroy(Ob);
          return NULL;
        }
        break;
      case SCSINT_N     :
      case SCSINT8_N    :
      case SCSINT16_N   : 
      case SCSINT32_N   : 
      case SCSUINT_N    :
      case SCSUINT8_N   :
      case SCSUINT16_N  :
      case SCSUINT32_N  :
        if ((elt=scicos_inttosci("el", inptr[k], insz[k], insz2[k],intyp[k])) == NULL) {
          nsp_list_destroy(Ob);
          return NULL;
        }
        break;
      default           :
        Sciprintf("Unknown type for vars_to_list. Returning a NULL object.\n",name);
        return NULL;
    }
    if (nsp_list_insert(Ob, elt, k+1) == FAIL) {
      nsp_list_destroy(Ob);
      return NULL;
    }
  }
  return NSP_OBJECT (Ob);
}

/* XXX: note that the array z transmited here is suposed 
 * to be a nsp object serialized in a matrix. 
 * Thus we have to serialize/unserialize here.
 * Voir livre page 205-> Note however that it should be the case 
 * for type 5 blocks (sciblk4) but maybe not for sciblk2 ? 
 *
 */

void scicos_sciblk2 (int *flag, int *nevprt, double *t, double *xd, double *x,
		     int *nx, double *z, int *nz, double *tvec, int *ntvec,
		     double *rpar, int *nrpar, int *ipar, int *nipar,
		     double **inptr, int *insz, int *nin, double **outptr,
		     int *outsz, int *nout)
{
  int mlhs = 5, mrhs = 8;
  int i;
  NspObject *Args[8] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
  NspObject *Ret[5] = { NULL, NULL, NULL, NULL, NULL };

  /* we give no names to Args, they will be freed by scicos_scifunc */
  if ((Args[0] = scicos_itosci (NVOID, flag, 1, 1)) == NULL)
    goto err;
  if ((Args[1] = scicos_itosci (NVOID, nevprt, 1, 1)) == NULL)
    goto err;
  if ((Args[2] = scicos_dtosci (NVOID, t, 1, 1,'r')) == NULL)
    goto err;
  if ((Args[3] = scicos_dtosci (NVOID, x, *nx, 1,'r')) == NULL)
    goto err;
  if ((Args[4] = scicos_mserial_to_obj (NVOID, z, *nz)) == NULL)
    goto err;
  if ((Args[5] = scicos_mserial_to_obj (NVOID, rpar, *nrpar)) == NULL)
    goto err;
  if ((Args[6] = scicos_itosci (NVOID, ipar, *nipar, 1)) == NULL)
    goto err;
  if ((Args[7] = scicos_vars_to_list (NVOID, (void **)inptr,
                                      *nin, insz, &insz[(*nin)], &insz[2*(*nin)])) == NULLOBJ)
    goto err;

  /* function to be evaluated or name of function to be evaluated */

  if (scicos_scifunc (Scicos->params.scsptr_flag,Scicos->params.scsptr, Args, mrhs, Ret, &mlhs) == FAIL)
    goto err;

  switch (*flag)
    {
    case 1:
      if (scicos_obj_to_mserial (z, *nz, Ret[2]) == FAIL)
	goto err;
      scicos_scitod (x, *nx, 1, Ret[1]);
      if (*nout != 0)
	{
	  if (scicos_list_to_vars ((void **)outptr, *nout,
	                           outsz, &outsz[(*nout)], &outsz[2*(*nout)], Ret[0]) == FAIL)
	    goto err;
	}
      break;
    case 0:
      /*     [y,x,z,tvec,xd]=func(flag,nevprt,t,x,z,rpar,ipar,u) */
      /*  x'  computation */
      scicos_scitod (xd, *nx, 1, Ret[4]);
      break;
    case 2:
      if (scicos_obj_to_mserial (z, *nz, Ret[2]) == FAIL)
	goto err;
      scicos_scitod (x, *nx, 1, Ret[1]);
      break;
    case 3:
      scicos_scitod (tvec, *ntvec, 1, Ret[3]);
      break;
    case 4:
    case 5:
      if (scicos_obj_to_mserial (z, *nz, Ret[2]) == FAIL)
	goto err;
      scicos_scitod (x, *nx, 1, Ret[1]);
      break;
    case 6:
      if (scicos_obj_to_mserial (z, *nz, Ret[2]) == FAIL)
	goto err;
      scicos_scitod (x, *nx, 1, Ret[1]);
      if (*nout != 0)
	{
	  if (scicos_list_to_vars ((void **)outptr, *nout,
	      outsz, &outsz[(*nout)], &outsz[2*(*nout)], Ret[0]) == FAIL)
	    goto err;
	}
      break;
    }
  for (i = 0; i < mlhs; i++)
    {
      if (Ret[i] != NULLOBJ)
	nsp_object_destroy (&Ret[i]);
    }
  return;
 err:
  *flag = -1;
}

/**
 * createblklist:
 * @:
 * @time:
 * @Block:
 * 
 * create a Nsp hash table from a Scicos C block struct
 * 
 * Return value:  %NULLOBJ or a new #NspHash
 **/

static NspHash *createblklist(double time, scicos_block *Block)
{
  NspHash *Hi = NULL;
  NspObject *Hel[32];
  int p=0, i;
  
  if ((Hel[p++] = scicos_dtosci("time", &time, 1, 1,'r')) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("nevprt", &Block->nevprt, 1, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("type", &Block->type, 1, 1)) == NULL)
    goto err;
  /* if ((Hel[p++]=   scicos_itosci(&Block->scsptr,0,1))== NULL) goto err; */
  /* if ((Hel[p++]=   scicos_itosci("nz",&Block->nz,1,1))== NULL) goto err; */
  if (Block->scsptr_flag == fun_pointer) {
    if ((Hel[p++] = scicos_dtosci("z", Block->z, Block->nz, 1,'r')) == NULL)
      goto err;
  } else {
    if ((Hel[p++] = scicos_mserial_to_obj("z", Block->z, Block->nz)) == NULL)
      goto err;
  }
  if (Block->scsptr_flag == fun_pointer) {
    if ((Hel[p++] = scicos_vars_to_list("oz", Block->ozptr, Block->noz,
                            Block->ozsz,&(Block->ozsz[Block->noz]),Block->oztyp)) == NULLOBJ)
      goto err;
  } else {
    if ((Hel[p++] = scicos_list_to_nsp_list("oz", Block->ozptr, Block->noz,
                                 Block->ozsz,&(Block->ozsz[Block->noz]),Block->oztyp)) == NULLOBJ)
      goto err;
  }
  /* if ((Hel[p++] = scicos_itosci("nx",&Block->nx,1,1))== NULL) goto err; */
  if ((Hel[p++] = scicos_dtosci("x", Block->x, Block->nx, 1,'r')) == NULL)
    goto err;
  if ((Hel[p++] = scicos_dtosci("xd", Block->xd, Block->nx, 1,'r')) == NULL)
    goto err;
  if ((Hel[p++] = scicos_dtosci("res", Block->res, Block->nx, 1,'r')) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("nin", &Block->nin, 1, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("insz", Block->insz, Block->nin, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_vars_to_list("inptr", Block->inptr, Block->nin,
                           Block->insz,&(Block->insz[Block->nin]),&(Block->insz[2*Block->nin]))) == NULLOBJ)
    goto err;
  if ((Hel[p++] =
       scicos_itosci("outsz", Block->outsz, Block->nout, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("nout", &Block->nout, 1, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_vars_to_list("outptr", Block->outptr, Block->nout,
                           Block->outsz,&(Block->outsz[Block->nout]),&(Block->outsz[2*Block->nout]))) == NULLOBJ)
    goto err;
  if ((Hel[p++] = scicos_itosci("nevout", &Block->nevout, 1, 1)) == NULL)
    goto err;
  if ( Block->nevout != 0 ) {
    if ((Hel[p++] = scicos_dtosci("evout", Block->evout, Block->nevout, 1,'r')) == NULL)
      goto err;
  }
  /* if ((Hel[p++] = scicos_itosci("nrpar",&Block->nrpar,1,1))== NULL) goto err; */
  if (Block->scsptr_flag == fun_pointer) {
    if ((Hel[p++] = scicos_dtosci("rpar", Block->rpar, Block->nrpar, 1,'r')) == NULL)
      goto err;
  } else {
    if ((Hel[p++] = scicos_mserial_to_obj("rpar", Block->rpar, Block->nrpar)) == NULL)
      goto err;
  }
  /* if ((Hel[p++] = scicos_itosci("nipar",&Block->nipar,1,1))== NULL) goto err; */
  if ((Hel[p++] = scicos_itosci("ipar", Block->ipar, Block->nipar, 1)) == NULL)
    goto err;
  if (Block->scsptr_flag == fun_pointer) {
    if ((Hel[p++] = scicos_vars_to_list("opar", Block->oparptr, Block->nopar,
                            Block->oparsz,&(Block->oparsz[Block->nopar]),Block->opartyp)) == NULLOBJ)
      goto err;
  } else {
    if ((Hel[p++] = scicos_list_to_nsp_list("opar", Block->oparptr, Block->nopar,
                                 Block->oparsz,&(Block->oparsz[Block->nopar]),Block->opartyp)) == NULLOBJ)
      goto err;
  }
  /* if ((Hel[p++]=   scicos_itosci("ng",&Block->ng,1,1))== NULL) goto err; */
  if ((Hel[p++] = scicos_dtosci("g", Block->g, Block->ng, 1,'r')) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("ztyp", &Block->ztyp, 1, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_itosci("jroot", Block->jroot, Block->ng, 1)) == NULL)
    goto err;
  if ((Hel[p++] = scicos_str2sci("label", Block->label)) == NULL)
    goto err;
  if ((Hel[p++]=  scicos_itosci("work",(int *)&Block->work,1,1))== NULL)
    goto err;
  /* if ((Hel[p++]=  scicos_itosci("nmode",&Block->nmode,1,1))== NULL) goto err; */
  if ((Hel[p++] = scicos_itosci("mode", Block->mode, Block->nmode, 1)) == NULL)
    goto err;
 
  if ((Hi = nsp_hash_create(NVOID, p)) == NULLHASH)
    goto err;
  
  for (i = 0; i < p; i++) {
    if (nsp_hash_enter(Hi, Hel[i]) == FAIL)
      goto err;
  }
  return Hi;
  
 err:
   for (i=0;i<p;i++) {
     nsp_object_destroy(&Hel[i]);
   }
   return NULL;
}

/* 
 * time added in block 
 * Note that we can entre scicos_sciblk4 even if Blocks is not 
 * nsp block, just because we are in debug mode and the evaluated block
 * is the debug block. 
 * Thus here we have to test the Block type since for real nsp-coded blocks 
 * "z" and "rpar" are to be serialized. 
 * 
 * XXX: note that the array z transmited here is suposed 
 * to be a nsp object serialized in a matrix. 
 * Thus we have to serialize/unserialize here.
 * Voir livre page 205-> Note however that it should be the case 
 * for type 5 blocks (sciblk4) but maybe not for sciblk2 ? 
 */

void scicos_sciblk4 (scicos_block *Blocks, int flag)
{
  int mlhs = 1, mrhs = 2;
  NspObject *Ob;
  NspHash *H = NULL, *Hi = NULL;
  NspObject *Args[2], *Ret[1];
  double time = scicos_get_scicos_time ();
  if ((Hi = createblklist(time, Blocks)) == NULL) 
    goto err;
  Args[0] = NSP_OBJECT(Hi);
  if ((Args[1] = scicos_itosci (NVOID, &flag, 1, 1)) == NULL)
    goto err;

  if (scicos_scifunc (Scicos->params.scsptr_flag,Scicos->params.scsptr, Args, mrhs, Ret, &mlhs) == FAIL)
    goto err;
  
  H = (NspHash *) Ret[0];
  switch (flag)
    {
    case 0:
      /*  x'  computation */
      if (Blocks->nx != 0) {
        if (nsp_hash_find (H, "xd", &Ob) == FAIL) goto err;
        scicos_scitod (Blocks->xd, Blocks->nx, 1, Ob);
        /* res XXX */
        if (nsp_hash_find (H, "res", &Ob) == FAIL) goto err;
        scicos_scitod (Blocks->res, Blocks->nx, 1, Ob);
      }
      break;
    case 1:
      /* outptr */
      if (Blocks->nout != 0) {
        if (nsp_hash_find (H, "outptr", &Ob) == FAIL) goto err;
        if (scicos_list_to_vars(Blocks->outptr, Blocks->nout,
                                Blocks->outsz, &(Blocks->outsz[Blocks->nout]), &(Blocks->outsz[2*Blocks->nout]), Ob) == FAIL)
          goto err;
      }
      break;
    case 2:
      /* z */
      if (Blocks->nz != 0) {
        if (nsp_hash_find (H, "z", &Ob) == FAIL) goto err;
        if (Blocks->scsptr_flag == fun_pointer) {
          scicos_scitod (Blocks->z, Blocks->nz, 1, Ob);
        } else {
          if (scicos_obj_to_mserial (Blocks->z, Blocks->nz, Ob) == FAIL) goto err;
        }
      }
      /* oz */
      if (Blocks->noz != 0) {
        if (nsp_hash_find (H, "oz", &Ob) == FAIL) goto err;
        if (Blocks->scsptr_flag == fun_pointer) {
          if (scicos_list_to_vars
              (Blocks->ozptr,Blocks->noz,
               Blocks->ozsz,&(Blocks->ozsz[Blocks->nout]),Blocks->oztyp,Ob) == FAIL) goto err;
        } else {
          if (scicos_nsp_list_to_list
              (Blocks->ozptr,Blocks->noz,
               Blocks->ozsz,&(Blocks->ozsz[Blocks->nout]),Blocks->oztyp,Ob) == FAIL) goto err;
        }
      }
      /* x */
      if (Blocks->nx != 0) {
        if (nsp_hash_find (H, "x", &Ob) == FAIL) goto err;
          scicos_scitod (Blocks->x, Blocks->nx, 1, Ob);
          if (nsp_hash_find (H, "xd", &Ob) == FAIL) goto err;
          scicos_scitod (Blocks->xd, Blocks->nx, 1, Ob);
      }
      /* mode */
      if (nsp_hash_find (H, "mode", &Ob) == FAIL) goto err;
      scicos_scitoi (Blocks->mode, Blocks->nmode, 1, Ob);
      break;
    case 3:
      /* evout */
      if (nsp_hash_find (H, "evout", &Ob) == FAIL) goto err;
      scicos_scitod (Blocks->evout, Blocks->nevout, 1, Ob);
      break;
    case 4:
    case 5:
    case 6:
      /* z */
      if (Blocks->nz != 0) {
        if (nsp_hash_find (H, "z", &Ob) == FAIL) goto err;
        if (Blocks->scsptr_flag == fun_pointer) {
          scicos_scitod (Blocks->z, Blocks->nz, 1, Ob);
        } else {
        if (scicos_obj_to_mserial (Blocks->z, Blocks->nz, Ob) == FAIL) goto err;
        }
      }
      /* oz */
      if (Blocks->noz != 0) {
        if (nsp_hash_find (H, "oz", &Ob) == FAIL) goto err;
        if (Blocks->scsptr_flag == fun_pointer) {
          if (scicos_list_to_vars
              (Blocks->ozptr,Blocks->noz,
               Blocks->ozsz,&(Blocks->ozsz[Blocks->nout]),Blocks->oztyp,Ob) == FAIL) goto err;
        } else {
          if (scicos_nsp_list_to_list
              (Blocks->ozptr,Blocks->noz,
               Blocks->ozsz,&(Blocks->ozsz[Blocks->nout]),Blocks->oztyp,Ob) == FAIL) goto err;
        }
      }
      if (flag!=5) {
        /* x */
        if (Blocks->nx != 0) {
          if (nsp_hash_find (H, "x", &Ob) == FAIL) goto err;
          scicos_scitod (Blocks->x, Blocks->nx, 1, Ob);
          if (nsp_hash_find (H, "xd", &Ob) == FAIL) goto err;
          scicos_scitod (Blocks->xd, Blocks->nx, 1, Ob);
        }
      }
      if (flag==6) {
        /* outptr */
        if (Blocks->nout != 0) {
          if (nsp_hash_find (H, "outptr", &Ob) == FAIL) goto err;
          if (scicos_list_to_vars(Blocks->outptr, Blocks->nout,
                                  Blocks->outsz, &(Blocks->outsz[Blocks->nout]), &(Blocks->outsz[2*Blocks->nout]), Ob) == FAIL)
            goto err;
        }
      }
      break;
    case 7:
      if (Blocks->nx != 0)
	{
	  /* xd */
	  if (nsp_hash_find (H, "xd", &Ob) == FAIL)
	    goto err;
	  scicos_scitod (Blocks->xd, Blocks->nx, 1, Ob);
	}
      /* mode */
      if (nsp_hash_find (H, "mode", &Ob) == FAIL)
	goto err;
      scicos_scitoi (Blocks->mode, Blocks->nmode, 1, Ob);
      break;
    case 9:
      /* g */
      if (nsp_hash_find (H, "g", &Ob) == FAIL)
	goto err;
      scicos_scitod (Blocks->g, Blocks->ng, 1, Ob);
      /* mode */
      if (nsp_hash_find (H, "mode", &Ob) == FAIL)
	goto err;
      scicos_scitoi (Blocks->mode, Blocks->nmode, 1, Ob);
      break;
    case 10:
      /*  res */
      if (Blocks->nx != 0) {
        if (nsp_hash_find (H, "res", &Ob) == FAIL) goto err;
        scicos_scitod (Blocks->res, Blocks->nx, 1, Ob);
      }
      break;
    }
  nsp_hash_destroy (H);
  return;
 err:
  if (H != NULL)
    nsp_hash_destroy (H);
  if (mlhs == RET_ABORT)
    {
      /* XXXX add a code for abort */
    }
  scicos_set_block_error (-1);
}

/*     routine used to evaluate a block defined by a scilab function 
 *     scilab function syntax must be 
 *     [y,x,z,tvec,xd]=func(flag,nevprt,t,x,z,rpar,ipar,u) 
 *     with 
 *        t      scalar current time 
 *        x      column vector continuous state 
 *        z      column vector discrete state 
 *        u      column vector block input 
 *        nevprt int 
 *        flag   int 
 *        y      column vector block output 
 *        xd     column vector block state derivative 
 */

void scicos_sciblk (int *flag, int *nevprt, double *t, double *xd, double *x,
		    int *nx, double *z, int *nz, double *tvec, int *ntvec,
		    double *rpar, int *nrpar, int *ipar, int *nipar,
		    double *u, int *nu, double *y, int *ny)
{
  int mlhs = 5, mrhs = 8;
  NspObject *Args[9];
  NspObject *Ret[6];
  /* FIXME: give names to all */
  if ((Args[0] = scicos_itosci (NVOID, flag, 1, 1)) == NULL)
    goto err;
  if ((Args[1] = scicos_itosci (NVOID, nevprt, 1, 1)) == NULL)
    goto err;
  if ((Args[2] = scicos_dtosci (NVOID, t, 1, 1,'r')) == NULL)
    goto err;
  if ((Args[3] = scicos_dtosci (NVOID, x, *nx, 1,'r')) == NULL)
    goto err;
  if ((Args[4] = scicos_mserial_to_obj (NVOID, z, *nz)) == NULL)
    goto err;
  if ((Args[5] = scicos_mserial_to_obj (NVOID, rpar, *nrpar)) == NULL)
    goto err;
  if ((Args[6] = scicos_itosci (NVOID, ipar, *nipar, 1)) == NULL)
    goto err;
  if ((Args[8] = scicos_dtosci (NVOID, u, *nu, 1,'r')) == NULL)
    goto err;
  /*     macro execution */

  if (scicos_scifunc (Scicos->params.scsptr_flag,Scicos->params.scsptr, Args, mrhs, Ret, &mlhs) == FAIL)
    goto err;
  /*     transfer output variables to fortran */
  switch (*flag)
    {
      /*     [y,x,z,tvec,xd]=func(flag,nevprt,t,x,z,rpar,ipar,u) */
    case 1:
      /* y or z computation */
      scicos_scitod (z, *nz, 1, Ret[2]);
      scicos_scitod (x, *nx, 1, Ret[1]);
      scicos_scitod (y, *ny, 1, Ret[0]);
      break;
    case 0:
      scicos_scitod (xd, *nx, 1, Ret[4]);
      break;
    case 2:
      /*  x'  computation */
      scicos_scitod (z, *nz, 1, Ret[2]);
      scicos_scitod (x, *nx, 1, Ret[1]);
      break;
    case 3:
      scicos_scitod (tvec, *ntvec, 1, Ret[3]);
      break;
    case 4:
    case 5:
      scicos_scitod (z, *nz, 1, Ret[2]);
      scicos_scitod (x, *nx, 1, Ret[1]);
      break;
    case 6:
      scicos_scitod (z, *nz, 1, Ret[2]);
      scicos_scitod (x, *nx, 1, Ret[1]);
      scicos_scitod (y, *ny, 1, Ret[0]);
      break;
    }
  return;
 err:
  *flag = -1;
  return;
}
