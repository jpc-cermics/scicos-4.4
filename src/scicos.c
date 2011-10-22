/* 
 * Copyright (C) 2007-2010 Ramine Nikoukhah (Inria) 
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
 * adapted to nsp by Jean-Philippe Chancelier 2007-2010
 * 
 *--------------------------------------------------------------------------*/

#include <nsp/nsp.h> 
#include <nsp/linking.h>
#include <nsp/graphics-new/Graphics.h>
#include <scicos/scicos4.h>
#include <scicos/blocks.h>
#include <nsp/matutil.h>
#include <nsp/sciio.h>
#include <nsp/system.h>
#include <nsp/blas.h>
#include <nsp/menus.h>
#include <nsp/sharedlib.h>
#include "../libinteg/integ.h"
#include "sundials/sundials.h"
#include "ezxml.h"

extern void scicos_send_halt(void);

#define TABSIM			/* to force include of tabsim definition */
#include "scicos/blocks.h"

/* IMPORT for win32 */

IMPORT ode_err ierode_;

typedef struct
{
  void *ida_mem;
  N_Vector ewt;
  double *rwork;
  int *iwork;
  double *gwork;		/* just added for a very special use: a
				   space passing to grblkdakr for zero crossing surfaces
				   when updating mode variables during initialization */
} *User_IDA_data;

typedef struct
{
  void *cvode_mem;
} *User_CV_data;

typedef struct
{
  double *rwork;
  double *uscale;
} *User_KIN_data;



static int check_flag (void *flagvalue, char *funcname, int opt);
static void cosini (double *told);
static void cosend (double *told);
static void cossimdaskr (double *told);
static void cossim (double *told);
static void callf (const double *t, scicos_block * block, int *flag);
static int lsodar2_simblk (const int *neq1, const double *t, double *xc,
			   double *xcdot, void *param);
static int lsodar2_grblk (const int *neq1, const double *t, double *xc,
			  const int *ng1, double *g, double *param);
static int CVsimblk (double t, N_Vector yy, N_Vector yp, void *f_data);
static void DP5simblk (unsigned n, double t, double *x, double *y,
		       void *udata);
static int DP5grblk (unsigned n, double t, double *xc, double *g,
		     void *udata);
static int simblkdaskr (double tres, N_Vector yy, N_Vector yp,
			N_Vector resval, void *rdata);
static int CVgrblk (double t, N_Vector yy, double *gout, void *g_data);
static int grblkdaskr (double t, N_Vector yy, N_Vector yp, double *gout,
		       void *g_data);
static int simblkKinsol (N_Vector, N_Vector, void *);
static void addevs (double, int *, int *);
static void putevs (const double *, int *, int *);
static void idoit (double *);
static void cdoit (double *);
static void doit (double *);
static void ddoit (double *);
static void edoit (double *, int *);
static void odoit (const double *told, double *xt, double *xtd,
		   double *residual);
static void ozdoit (const double *, double *, double *, int *);
static void zdoit (const double *told, double *xt, double *xtd, double *g);
static void Jdoit (double *, double *, double *, double *, int *);
static void reinitdoit (double *);
static int synchro_nev (int, int *);
static int synchro_g_nev (double *, int, int *);
static int Jacobians (long int Neq, double, N_Vector, N_Vector, N_Vector,
		      double, void *, DenseMat, N_Vector, N_Vector, N_Vector);
static int KinJacobians1 (long int, DenseMat, N_Vector, N_Vector, void *,
			  N_Vector, N_Vector);
static void Multp (double *, double *, double *, int, int, int, int);
static int read_id (ezxml_t *, char *, double *);
static int Convert_number (char *, double *);
static int CallKinsol (double *);

void Set_Jacobian_flag (int flag);
double Get_Scicos_SQUR (void);
int KinJacobians0 (long int, DenseMat, N_Vector, N_Vector, void *,
			  N_Vector, N_Vector);
#if 0 
static int rhojac_ (double *a, double *lambda, double *x, double *jac,
		    int *col, double *rpar, int *ipar);
static int rho_ (double *, double *, double *, double *, double *, int *);
static int fx_ (double *, double *);
static int hfjac_ (double *, double *, int *);
#endif 

/* simplify some calls to Scicos->sim */

#define nmod Scicos->sim.nmod
#define iwa Scicos->sim.iwa
#define xptr Scicos->sim.xptr
#define evtspt Scicos->sim.evtspt
#define pointi Scicos->sim.pointi
#define mod Scicos->sim.mod
#define outtbptr Scicos->sim.outtbptr
#define outtbsz Scicos->sim.outtbsz
#define outtbtyp Scicos->sim.outtbtyp
#define Blocks Scicos->Blocks

static int *ierr;
static double *t0, *tf;

/* pass to external variable for code generation */
/* reserved variable name */

int *block_error;
double scicos_time;
int Jacobian_Flag;
double CI, CJ;
double SQuround;
int Sfcallerid;

/* Jacobian*/
static int AJacobian_block;
/* Jacobian*/
int TCritWarning;

void call_debug_scicos (scicos_block * block, int *flag, int flagi,
			int deb_blk);

scicos_run *Scicos = NULL;
int scicos_debug_level = -1;

int scicos_main (scicos_run * sr, double *t0_in, double *tf_in,
		 double *simpar, int *flag__, int *ierr_out)
{
  int kf, mxtb, ierr0, kfun0, i, j, k, ni, no;
  double *W;

  /* associate the function scicos_send_halt to the stop menu */
  set_stop_menu_handler(scicos_send_halt);

  TCritWarning = 0;
  Scicos = sr;
  Scicos->params.debug = scicos_debug_level;
  t0 = t0_in;
  tf = tf_in;
  ierr = ierr_out;

  Scicos->params.Atol = simpar[0];
  Scicos->params.rtol = simpar[1];
  Scicos->params.ttol = simpar[2];
  Scicos->params.deltat = simpar[3];
  Scicos->params.scale = simpar[4];
  Scicos->params.solver = (int) simpar[5];
  Scicos->params.hmax = simpar[6];
  Scicos->params.debug_counter = 0;
  *ierr = 0;

  Scicos->sim.xd = &Scicos->sim.x[xptr[Scicos->sim.nblk] - 1];
  Scicos->params.neq = &Scicos->sim.nx;

  for (i = 1; i <= Scicos->sim.nblk; ++i)
    {
      if (Scicos->sim.funtyp[-1 + i] < 10000)
	{
	  Scicos->sim.funtyp[-1 + i] %= 1000;
	}
      else
	{
	  Scicos->sim.funtyp[-1 + i] =
	    Scicos->sim.funtyp[-1 + i] % 1000 + 10000;
	}
      ni = Scicos->sim.inpptr[i] - Scicos->sim.inpptr[-1 + i];
      no = Scicos->sim.outptr[i] - Scicos->sim.outptr[-1 + i];
      if (Scicos->sim.funtyp[-1 + i] == 1)
	{
	  if (ni + no > 11)
	    {
	      /*     hard coded maxsize in callf.c */
	      Scierror ("Too many input/output ports for hilited block\n");
	      Scicos->params.curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
      else if (Scicos->sim.funtyp[-1 + i] == 2
	       || Scicos->sim.funtyp[-1 + i] == 3)
	{
	  /*     hard coded maxsize in scicos.h */
	  if (ni + no > SZ_SIZE)
	    {
	      Scierror ("Too many input/output ports for hilited block\n");
	      Scicos->params.curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
      mxtb = 0;
      if (Scicos->sim.funtyp[-1 + i] == 0)
	{
	  if (ni > 1)
	    {
	      for (j = 1; j <= ni; ++j)
		{
		  k =
		    Scicos->sim.inplnk[-1 + Scicos->sim.inpptr[-1 + i] - 1 +
				       j];
		  mxtb += (outtbsz[k - 1] * outtbsz[(k - 1) + Scicos->sim.nlnk]);	/* XXX k-1 ou k ? */
		}
	    }
	  if (no > 1)
	    {
	      for (j = 1; j <= no; ++j)
		{
		  k =
		    Scicos->sim.outlnk[-1 + Scicos->sim.outptr[-1 + i] - 1 +
				       j];
		  mxtb +=
		    (outtbsz[k - 1] * outtbsz[(k - 1) + Scicos->sim.nlnk]);
		}
	    }
	  if (mxtb > TB_SIZE)
	    {
	      Scierror ("Too many input/output entries for hilited block\n");
	      Scicos->params.curblk = i;
	      *ierr = i + 1005;
	      return 0;
	    }
	}
    }


  /* Scicos->sim.debug_block = -1;*/	/* no debug block for start */

  Scicos->params.debug_counter = 0;

  if (*flag__ == 1)
    {
      /*     initialisation des blocks */
      for (kf = 0; kf < Scicos->sim.nblk; ++kf)
	{
	  *(Blocks[kf].work) = NULL;
	}
      Scicos->params.phase = 1;
      cosini (t0);
      if (*ierr != 0)
	{
	  ierr0 = *ierr;
	  kfun0 = Scicos->params.curblk;
	  cosend (t0);
	  *ierr = ierr0;
	  Scicos->params.curblk = kfun0;
	}
    }
  else if (*flag__ == 2)
    {
      /*     integration */
      Scicos->params.phase = 1;
      if (Scicos->params.solver == 0)
	{
	  /*  Lsodar: Method: BDF,   Nonlinear solver= NEWTON     */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 1)
	{
	  /*  CVODE: Method: BDF,   Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 2)
	{
	  /*  CVODE: Method: BDF,   Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 3)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= NEWTON     */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 4)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 5)
	{
	  /*  CVODE: Method: ADAMS, Nonlinear solver= FUNCTIONAL */
	  cossim (t0);
	}
      else if (Scicos->params.solver == 100)
	{
	  /* IDA  : Method:       , Nonlinear solver=  */
	  cossimdaskr (t0);
	}
      else
	{
	  /*     add a warning message please */
	}
      if (*ierr != 0)
	{
	  ierr0 = *ierr;
	  kfun0 = Scicos->params.curblk;
	  cosend (t0);
	  *ierr = ierr0;
	  Scicos->params.curblk = kfun0;
	}
    }
  else if (*flag__ == 3)
    {
      /* finish:  closing the blocks  */
      Scicos->params.phase = 1;
      cosend (t0);
    }
  else if (*flag__ == 4)
    {
      int jj;
      /* linear */
      Scicos->params.phase = 2;
      idoit (t0);
      if (*ierr == 0)
	{
	  if ((W =
	       malloc (sizeof (double) *
		       Max (Scicos->sim.nx, Scicos->sim.ng))) == NULL)
	    {
	      *ierr = 5;
	      return 0;
	    }
	  if (Scicos->sim.ng > 0 && nmod > 0)
	    {
	      /* updating modes as a function of state values; this was necessary in iGUI */
	      zdoit (t0, Scicos->sim.x, Scicos->sim.x + Scicos->sim.nx, W);
	    }
	  for (jj = 0; jj < Scicos->sim.nx; jj++)
	    W[jj] = 0.0;
	  C2F (ierode).iero = 0;
	  *ierr = 0;
	  if (Scicos->params.solver < 100)
	    {
	      odoit (t0, Scicos->sim.x, W, W);
	    }
	  else
	    {
	      odoit (t0, Scicos->sim.x, Scicos->sim.x + Scicos->sim.nx, W);
	    }
	  C2F (ierode).iero = *ierr;
	  /*-----------------------------------------*/
	  for (i = 0; i < Scicos->sim.nx; ++i)
	    {
	      Scicos->sim.x[i] = W[i];
	    }
	  FREE (W);
	}
    }
  else if (*flag__ == 5)
    {
      /* initial_KINSOL= "Kinsol" */
      C2F (ierode).iero = 0;
      *ierr = 0;
      idoit (t0);
      CallKinsol (t0);
      *ierr = C2F (ierode).iero;
    }
  return 0;
}

/*
 * get a function in blocks functions from its name 
 */

void *scicos_get_function (char *fname)
{
  int (*loc) ();
  int i = 0;
  while (tabsim[i].name != (char *) NULL)
    {
      if (strcmp (fname, tabsim[i].name) == 0)
	return tabsim[i].fonc;
      i++;
    }
  /* search if symbol is in a dynamically linked shared archive*/
  if ( nsp_link_search(fname,-1,&loc) != -1 ) return loc ;
  return NULL;
}

/* get the real entry name for block from block function name
 * we get the name by searching shared libraries for symbols 
 * 
 */

void scicos_get_function_name (const char *fname,char *rname)
{
  char fname1[256], *str;
  /* first check if scicos_<name>_block exists */
  sprintf(rname,"scicos_%s_block",fname);
  if ( nsp_sharedlib_table_find_symbol(rname)==OK) return;
  /* then check if name is name1_blk and in that case search if 
   * scicos_<name>_block symbols exists 
   */
  strcpy(fname1,fname);
  str=strstr(fname1,"_blk");
  if ( str != NULL)
    {
      *str='\0';
      sprintf(rname,"scicos_%s_block",fname1);
      if ( nsp_sharedlib_table_find_symbol(rname)==OK) return;
    }
  /* return name */
  /* clear scierror raised */
  nsp_error_message_clear();
  strcpy(rname,fname);
}

/* check_flag */

static int check_flag (void *flagvalue, char *funcname, int opt)
{
  int *errflag;
  /* Check if SUNDIALS function returned NULL pointer - no memory allocated */
  if (opt == 0 && flagvalue == NULL)
    {
      Sciprintf("SUNDIALS_ERROR: %s() failed - returned NULL pointer\n\n",
		funcname);
      return (1);
    }
  /* Check if flag < 0 */
  else if (opt == 1)
    {
      errflag = (int *) flagvalue;
      if (*errflag < 0)
	{
	  Sciprintf("SUNDIALS_ERROR: %s() failed with flag = %d\n\n",
		    funcname, *errflag);
	  return (1);
	}
    }
  /* Check if function returned NULL pointer - no memory allocated */
  else if (opt == 2 && flagvalue == NULL)
    {
      Sciprintf("MEMORY_ERROR: %s() failed - returned NULL pointer\n\n",
		funcname);
      return (1);
    }
  return (0);
}

/* expand X expression in a swith 
 * #define X(name) for ( i=0 ; i < A->mn ; i++) {if ( A->name[i] ) count++;} break;
 * NSP_ITYPE_SWITCH(s,itype,X);
 */

#define NSP_COSTYPE_SWITCH(itype,X,arg)			\
  switch (itype ) {					\
  case SCSREAL_N: X(SCSREAL_COP,0,1,arg);		\
  case SCSCOMPLEX_N : X(SCSCOMPLEX_COP,1,2,arg);	\
  case SCSINT8_N    : X(SCSINT8_COP,2,1,arg);		\
  case SCSINT16_N   : X(SCSINT16_COP,3,1,arg);		\
  case SCSINT32_N   : X(SCSINT32_COP ,4,1,arg);		\
  case SCSUINT8_N   : X(SCSUINT8_COP ,5,1,arg);		\
  case SCSUINT16_N  : X(SCSUINT16_COP ,6,1,arg);	\
  case SCSUINT32_N  : X(SCSUINT32_COP ,7,1,arg);	\
  default  : /* Add a message here */			\
    break;						\
  }

/* Subroutine cosini */

static void cosini (double *told)
{
  double c_b14 = 0.;
  int jj, ii, kk;		/*local counters */
  int sszz;			/*local size of element of outtb */
  int c1 = 1, flag__, i, kfune = 0;
  int sz_outtb[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
  void *outtb[8] = { NULL };
  int cur_outtb[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

  /* first pass to compute the sizes */
  for (ii = 0; ii < Scicos->sim.nlnk; ii++)
    {
#define X(name,pos,tag,arg) sz_outtb[pos] +=tag*outtbsz[ii]*outtbsz[ii+Scicos->sim.nlnk]; break;
      NSP_COSTYPE_SWITCH (outtbtyp[ii], X, "void");
#undef X
    }
  /* second pass to allocate and set to zero */
  for (ii = 0; ii < Scicos->sim.nlnk; ii++)
    {
#define X(name,pos,tag,arg) outtb[pos]= calloc(sz_outtb[pos],sizeof(name));break;
      NSP_COSTYPE_SWITCH (outtbtyp[ii], X, "void");
#undef X
    }

  /* Jacobian */
  AJacobian_block = 0;

  /* Function Body */
  *ierr = 0;

  /*     initialization (flag 4) */
  /*     loop on blocks */
  nsp_dset (&Scicos->sim.ng, &c_b14, Scicos->sim.g, &c1);

  for (Scicos->params.curblk = 1; Scicos->params.curblk <= Scicos->sim.nblk;
       ++Scicos->params.curblk)
    {
      flag__ = 4;
      if (Blocks[Scicos->params.curblk - 1].nx > 0)
	{
	  Blocks[Scicos->params.curblk - 1].x =
	    &Scicos->sim.x[xptr[Scicos->params.curblk - 1] - 1];
	  Blocks[Scicos->params.curblk - 1].xd =
	    &Scicos->sim.xd[xptr[Scicos->params.curblk - 1] - 1];
	}
      Blocks[Scicos->params.curblk - 1].nevprt = 0;
      if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >= 0)
	{
	  /* debug_block is not called here */
	  Jacobian_Flag = 0;
	  callf (told, &Blocks[Scicos->params.curblk - 1], &flag__);
	  if (flag__ < 0 && *ierr == 0)
	    {
	      *ierr = 5 - flag__;
	      kfune = Scicos->params.curblk;
	    }
	  if ((Jacobian_Flag == 1) && (AJacobian_block == 0))
	    AJacobian_block = Scicos->params.curblk;
	}
    }
  if (*ierr != 0)
    {
      Scicos->params.curblk = kfune;
      goto err;
    }

  /*     initialization (flag 6) */
  flag__ = 6;
  for (jj = 1; jj <= Scicos->sim.ncord; ++jj)
    {
      Scicos->params.curblk = Scicos->sim.cord[jj - 1];
      Blocks[Scicos->params.curblk - 1].nevprt = 0;
      if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >= 0)
	{
	  callf (told, &Blocks[Scicos->params.curblk - 1], &flag__);
	  if (flag__ < 0)
	    {
	      *ierr = 5 - flag__;
	      goto err;
	    }
	}
    }
  /*     point-fix iterations */
  flag__ = 6;
  for (i = 1; i <= Scicos->sim.nblk + 1; ++i)
    {				/*for each block */
      /*     loop on blocks */
      for (jj = 1; jj <= Scicos->sim.nblk; ++jj)
	{
	  Scicos->params.curblk = jj;
	  Blocks[Scicos->params.curblk - 1].nevprt = 0;
	  if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >= 0)
	    {
	      callf (told, &Blocks[Scicos->params.curblk - 1], &flag__);
	      if (flag__ < 0)
		{
		  *ierr = 5 - flag__;
		  goto err;
		}
	    }
	}

      flag__ = 6;
      for (jj = 1; jj <= Scicos->sim.ncord; ++jj)
	{			/*for each continous block */
	  Scicos->params.curblk = Scicos->sim.cord[jj - 1];
	  if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >= 0)
	    {
	      callf (told, &Blocks[Scicos->params.curblk - 1], &flag__);
	      if (flag__ < 0)
		{
		  *ierr = 5 - flag__;
		  goto err;
		}
	    }
	}

      /*comparison between outtb and arrays */
      for (kk = 0; kk < 7; kk++)
	cur_outtb[kk] = 0;
      for (jj = 0; jj < Scicos->sim.nlnk; jj++)
	{
#define X(name,pos,tag,arg)						\
	  sszz=tag*outtbsz[jj]*outtbsz[jj+Scicos->sim.nlnk];		\
	  for( kk=0 ; kk < sszz ; kk++)					\
	    {								\
	      if( *(((name *) outtbptr[jj]) + kk) != *(((name *) outtb[pos]) + cur_outtb[pos]+kk)) goto L30; \
	    }								\
	  cur_outtb[pos] +=sszz;					\
	  break;
	  NSP_COSTYPE_SWITCH (outtbtyp[jj], X, "void");
#undef X
	}
      goto err;

    L30:
      /* Save data of outtb in arrays */
      for (kk = 0; kk < 7; kk++)
	cur_outtb[kk] = 0;
      for (ii = 0; ii < Scicos->sim.nlnk; ii++)	/*for each link */
	{
#define X(name,pos,tag,arg)						\
	  sszz=tag*outtbsz[ii]*outtbsz[ii+Scicos->sim.nlnk];		\
	  for( kk=0 ; kk < sszz ; kk++)					\
	    {								\
	      *(((name *) outtb[pos]) + cur_outtb[pos]+kk)= *(((name *) outtbptr[ii]) + kk); \
	    }								\
	  cur_outtb[pos] +=sszz;					\
	  break;
	  NSP_COSTYPE_SWITCH (outtbtyp[ii], X, "void");
#undef X
	}
    }
  *ierr = 20;
 err:
  for (kk = 0; kk < 7; kk++)
    FREE (outtb[kk]);
}				/* cosini_ */



int Setup_Cvode (void **cvode_mem, int solver, int N, N_Vector * y,
		 User_CV_data * cv_data, double reltol, double *abstol,
		 double t0, double *x, int ng1, double hmax)
{
  int flag;
  //CVodeMem cv_mem;
  //cv_mem = (CVodeMem) (*cvode_mem);

  if (N <= 0)
    return 0;

  *y = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*y), "N_VNewEmpty_Serial", 0))
    {
      *ierr = 10000;
      return -1;
    }

  *cvode_mem = NULL;
  NV_DATA_S ((*y)) = x;
  switch (solver)
    {
    case 1:
      *cvode_mem = CVodeCreate (CV_BDF, CV_NEWTON);
      break;
    case 2:
      *cvode_mem = CVodeCreate (CV_BDF, CV_FUNCTIONAL);
      break;
    case 3:
      *cvode_mem = CVodeCreate (CV_ADAMS, CV_NEWTON);
      break;
    case 4:
      *cvode_mem = CVodeCreate (CV_ADAMS, CV_FUNCTIONAL);
      break;
    }

  if (check_flag ((void *) (*cvode_mem), "CVodeCreate", 0))
    {
      *ierr = 10000;
      N_VDestroy_Serial ((*y));
      return -1;
    }

  if ((*cv_data = (User_CV_data) MALLOC (sizeof (**cv_data))) == NULL)
    {
      *ierr = 10000;
      CVodeFree (cvode_mem);
      N_VDestroy_Serial ((*y));
      return -1;
    };

  (*cv_data)->cvode_mem = *cvode_mem;
  CVodeSetFdata (*cvode_mem, *cv_data);

  flag = CVodeMalloc (*cvode_mem, CVsimblk, t0, *y, CV_SS, reltol, abstol);
  if (check_flag (&flag, "CVodeMalloc", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }

  flag = CVodeRootInit (*cvode_mem, ng1, CVgrblk, NULL);
  if (check_flag (&flag, "CVodeRootInit", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }
  /* Call CVDense to specify the CVDENSE dense linear solver */
  flag = CVDense (*cvode_mem, N);
  if (check_flag (&flag, "CVDense", 1))
    {
      *ierr = 300 + (-flag);
      FREE ((*cv_data));
      CVodeFree ((cvode_mem));
      N_VDestroy_Serial ((*y));
      return -1;
    }

  if (hmax > 0)
    {
      flag = CVodeSetMaxStep (*cvode_mem, (double) hmax);
      if (check_flag (&flag, "CVodeSetMaxStep", 1))
	{
	  *ierr = 300 + (-flag);
	  FREE ((*cv_data));
	  CVodeFree ((cvode_mem));
	  N_VDestroy_Serial ((*y));
	  return -1;
	}
    }

  CVodeSetMaxNumSteps (*cvode_mem, 50000);

  /* Set the Jacobian routine to Jac (user-supplied) 
     flag = CVDenseSetJacFn(cvode_mem, Jac, NULL);
     if (check_flag(&flag, "CVDenseSetJacFn", 1)) return(1);  */
  return 0;
}



int Setup_Lsodar (int *nrwp, int *niwp, double **rhot, int **ihot,
		  double hmax, int *iopt, int N, int ng1)
{
  int jj;
  int c1 = 1;
  int c__0 = 0;
  double c_b14 = 0.0;
  *nrwp = (N) * Max (16, N + 9) + 22 + ng1 * 3;
  *niwp = N + 20 + ng1;		/* + ng is for change in lsodar2 to handle masking */

  if ((*rhot = MALLOC (sizeof (double) * (*nrwp + 1))) == NULL)
    {
      *ierr = 10000;
      return -1;
    }
  if ((*ihot = MALLOC (sizeof (int) * (*niwp + 1))) == NULL)
    {
      *ierr = 10000;
      FREE ((*rhot));
      return -1;
    }
  jj = *niwp + 1;
  nsp_iset (&jj, &c__0, *ihot, &c1);	/*set to 0  */
  jj = *nrwp + 1;
  nsp_dset (&jj, &c_b14, *rhot, &c1);	/*set to 0.0 */

  *iopt = 1;			/*rwork/iwork have valid values */

  /*mxstep  iwork(6) */
  (*ihot)[6] = 50000;		/*maximum number of (internally defined) steps allowed during
				  one call to the solver. The default value is 500. */
  if (hmax > 0)
    {
      (*rhot)[6] = hmax;
    }

  return 0;
}


static void cossim (double *told)
{
  int c1 = 1;
  static int otimer = 0;
  int ntimer;
  int i3;
  static int flag__;
  static int ierr1;
  static int j, k;
  static double t, hmax_auto;
  static int jj;
  static double rhotmp, tstop;
  int inxsci;
  static int kpo, kev;
  int Discrete_Jump;
  int *jroot, *zcros;
  double reltol, abstol;
  N_Vector y = NULL;
  void *cvode_mem = NULL;
  User_CV_data cv_data = NULL;

  DOPRI5_mem *dopri5_mem = NULL;
  User_DP5_data *dopri5_udata = NULL;

  int flag, flagr;
  int cnt = 0;
  double *rhot = NULL;
  int *ihot = NULL, niwp, nrwp;
  int itask;
  int jt, kk, lyh;
  int istate, iopt, itt;
  double tzero = 0.0, tn = 0.0;
  int zcrossing_unhandeled = 0, *jroottmp = NULL;
  int X_contain_xn = 1;
  double tnext;

  Sfcallerid = 99;
  jroot = NULL;
  zcros = NULL;
  if (Scicos->sim.ng > 0)
    {
      if ((jroot = MALLOC (sizeof (int) * Scicos->sim.ng * 2)) == NULL)
	{
	  *ierr = 10000;
	  return;
	}
      for (jj = 0; jj < Scicos->sim.ng * 2; jj++)
	jroot[jj] = 0;
      jroottmp = jroot + Scicos->sim.ng;
      if ((zcros = MALLOC (sizeof (int) * Scicos->sim.ng)) == NULL)
	{
	  *ierr = 10000;
	  FREE (jroot);
	  return;
	}
    }

  reltol = (double) Scicos->params.rtol;
  abstol = (double) Scicos->params.Atol;	/* Ith(abstol,1) = double) Atol; */
  hmax_auto = (Scicos->params.hmax > 0) ? Scicos->params.hmax : (*tf / 100.0);

  switch (Scicos->params.solver)
    {
    case 0:			/* LSODAR initialization */
      flag =
	Setup_Lsodar (&nrwp, &niwp, &rhot, &ihot, hmax_auto, &iopt,
		      *Scicos->params.neq, Scicos->sim.ng);
      break;
    case 1:
    case 2:
    case 3:
    case 4:			/* CVODE does not work with NEQ==0 */
      flag =
	Setup_Cvode (&cvode_mem, Scicos->params.solver, *Scicos->params.neq,
		     &y, &cv_data, reltol, &abstol, *told, Scicos->sim.x,
		     Scicos->sim.ng, hmax_auto);
      break;
    case 5:			/* DOPRI5 initialization */
      flag =
	Setup_dopri5 (&dopri5_mem, *Scicos->params.neq, DP5simblk, *told, *tf,
		      reltol, &abstol, 0, hmax_auto, Scicos->sim.ng, DP5grblk,
		      &dopri5_udata);
      break;
    }

  if (flag < 0)
    {
      if (Scicos->sim.ng > 0)
	FREE (jroot);
      if (Scicos->sim.ng > 0)
	FREE (zcros);
      return;
    }

  /* Function Body */
  Scicos->params.halt = 0;
  *ierr = 0;
  inxsci = nsp_check_events_activated ();
  /* Initialization */
  nsp_realtime_init (told, &Scicos->params.scale);
  Scicos->params.phase = 1;
  Scicos->params.hot = 0;
  itask = 5;
  jt = 2;			/*just for LSODAR */

  jj = 0;
  for (Scicos->params.curblk = 1; Scicos->params.curblk <= Scicos->sim.nblk;
       ++Scicos->params.curblk)
    {
      if (Blocks[Scicos->params.curblk - 1].ng >= 1)
	{
	  zcros[jj] = Scicos->params.curblk;
	  ++jj;
	}
    }
  /*     . Il faut:  ng >= jj */
  if (jj != Scicos->sim.ng)
    {
      zcros[jj] = -1;
    }
  /*     initialisation (propagation of constant blocks outputs) */
  idoit (told);
  if (*ierr != 0)
    {
      goto err;
      return;
    }
  /*--discrete zero crossings----dzero--------------------*/
  if (Scicos->sim.ng > 0)
    {				/* storing ZC signs just after a solver call */
      /*zdoit(told, g, x, x); */
      zdoit (told, Scicos->sim.x, Scicos->sim.x, Scicos->sim.g);
      if (*ierr != 0)
	{
	  goto err;
	  return;
	}
      for (jj = 0; jj < Scicos->sim.ng; ++jj)
	if (Scicos->sim.g[jj] >= 0)
	  jroottmp[jj] = 5;
	else
	  jroottmp[jj] = -5;
    }
  /*--discrete zero crossings----dzero--------------------*/

  /*     main loop on time */

  tstop = *tf + Scicos->params.ttol;

  while (*told < *tf)
    {

      if (inxsci == TRUE)
	{
	  /* what follows can modify Scicos->params.halt */
	  ntimer = nsp_stimer ();
	  if (ntimer != otimer)
	    {
	      nsp_check_gtk_events ();
	      otimer = ntimer;
	    }
	}
      if (Scicos->params.halt != 0)
	{
	  if (Scicos->params.halt == 2)
	    *told = *tf;	/* end simulation */
	  Scicos->params.halt = 0;
	  goto err;
	  return;
	}
      if (*pointi == 0)
	{
	  t = *tf;
	}
      else
	{
	  t = Scicos->sim.tevts[-1+*pointi];
	}
      if (Abs (t - *told) < Scicos->params.ttol)
	{
	  t = *told;
	  /*     update output part */
	}
      if (*told > t)
	{
	  /*     !  scheduling problem */
	  *ierr = 1;
	  goto err;
	  return;
	}

      if (*told >= *tf - Scicos->params.ttol)
	{
	  Scicos->params.phase = 0;
	  odoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.xd);
	  /*     .     we are at the end, update continuous part before leaving */
	  if (Scicos->sim.ncord > 0)
	    {
	      cdoit (told);
	    }
	  goto err;
	  return;
	}

      if (*told != t)
	{
	  if (xptr[Scicos->sim.nblk] == 1)
	    {
	      /*     .     no continuous state */

	      Scicos->params.phase = 0;
	      odoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.xd);
	      Scicos->params.phase = 1;

	      tnext = Min (*told + hmax_auto, *told + Scicos->params.deltat);

	      if (tnext + Scicos->params.ttol > t)
		{
		  *told = t;
		}
	      else
		{
		  *told = tnext;
		}

	      /*     .     update outputs of 'c' type blocks with no continuous state */
	      if (*told >= *tf - Scicos->params.ttol)
		{
		  Scicos->params.phase = 0;
		  odoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.xd);
		  /*     .     we are at the end, update continuous part before leaving */
		  if (Scicos->sim.ncord > 0)
		    {
		      cdoit (told);
		    }
		  goto err;
		  return;
		}
	    }
	  else
	    {
	      /*     integrate */
	      rhotmp = *tf + Scicos->params.ttol;
	      if (*pointi != 0)
		{
		  kpo = *pointi;
		L20:
		  if (Scicos->sim.critev[-1+kpo] == 1)
		    {
		      rhotmp = Scicos->sim.tevts[-1+kpo];
		      goto L30;
		    }
		  kpo = evtspt[-1+kpo];
		  if (kpo != 0)
		    {
		      goto L20;
		    }
		L30:
		  if (rhotmp > *tf + Scicos->params.ttol)
		    rhotmp = *tf + Scicos->params.ttol;
		  if (rhotmp < tstop - Scicos->params.ttol)
		    {
		      Scicos->params.hot = 0;
		    }
		}
	      tstop = rhotmp;
	      t =
		Min (*told + Scicos->params.deltat,
		     Min (t, *tf + Scicos->params.ttol));

	      if (Scicos->sim.ng > 0 && Scicos->params.hot == 0 && nmod > 0)
		{
		  zdoit (told, Scicos->sim.x, Scicos->sim.x, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		}
	      /*---------  solver's cold/hot restart management :beginning ---------------------*/
	      switch (Scicos->params.solver)
		{
		case 0:
		  if (Scicos->params.hot == 0)
		    {		/* hot==0 : cold restart */
		      rhot[1] = tstop;
		      istate = 1;
		    }
		  else
		    {
		      istate = 2;
		    }
		  break;

		case 1:
		case 2:
		case 3:
		case 4:
		  if (Scicos->params.hot == 0)
		    {		/* hot==0 : cold restart */
		      flag = CVodeSetStopTime (cvode_mem, (double) tstop);	/* Setting the stop time */
		      if (check_flag (&flag, "CVodeSetStopTime", 1))
			{
			  *ierr = 300 + (-flag);
			  goto err;
			  return;
			}
		      flag =
			CVodeReInit (cvode_mem, CVsimblk, (double) (*told), y,
				     CV_SS, reltol, &abstol);
		      if (check_flag (&flag, "CVodeReInit", 1))
			{
			  *ierr = 300 + (-flag);
			  goto err;
			  return;
			}
		    }
		  break;

		case 5:	/* DOPRI5 */
		  if (Scicos->params.hot == 0)
		    {		/* hot==0 : cold restart */
		      set_tstop (dopri5_mem, tstop);
		    }
		  break;
		}
	      /*---------  solver's cold/hot restart management : end ---------------------*/

	      if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
		{
		  Sciprintf ("****Solver from: %f to %f hot= %d  \n", *told,
			     t, Scicos->params.hot);
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      /*--check for Dzeros after Mode settings or ddoit()----*/
	      Discrete_Jump = 0;

	      if (Scicos->sim.ng > 0 && Scicos->params.hot == 0)
		{
		  zdoit (told, Scicos->sim.x, Scicos->sim.x, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    {
		      if ((Scicos->sim.g[jj] >= 0.0) && (jroottmp[jj] == -5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = 1;
			}
		      else if ((Scicos->sim.g[jj] < 0.0)
			       && (jroottmp[jj] == 5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = -1;
			}
		      else
			jroottmp[jj] = 0;
		    }
		}
	      /*--discrete zero crossings----dzero--------------------*/

	      if (Discrete_Jump == 0)
		{		/* if there was a dzero, its event should be activated */
		  Scicos->params.phase = 2;

		  if (Scicos->params.hot == 0)
		    {
		      tn = *told;
		      X_contain_xn = 1;
		      zcrossing_unhandeled = 0;
		    }
		  flag = 0;
		  if (!zcrossing_unhandeled)
		    {
		      if ((t > tn))
			{

			  if (X_contain_xn == 0)
			    {
			      switch (Scicos->params.solver)
				{
				case 0:
				  lyh = 21 + 3 * Scicos->sim.ng;
				  kk = 0;
				  C2F (intdy) (&tn, &kk, &(rhot[lyh]),
					       Scicos->params.neq,
					       Scicos->sim.x, &itt);
				  break;
				case 1:
				case 2:
				case 3:
				case 4:
				  CVodeGetDky (cvode_mem, tn, 0, y);
				  break;
				case 5:
				  //  for (i = 0; i < dopri5_mem->n; i++)
				  // contd5 (dopri5_mem, i, *told, double xold, double h_old)
				  break;
				}
			    }
			  Scicos->params.phase = 0;
			  odoit (&tn, Scicos->sim.x, Scicos->sim.xd,
				 Scicos->sim.xd);

			  Scicos->params.phase = 2;
			  switch (Scicos->params.solver)
			    {
			    case 0:
			      C2F (lsodar2) ((ode_f) lsodar2_simblk,
					     Scicos->params.neq,
					     Scicos->sim.x, told, &t, &c1,
					     &Scicos->params.rtol,
					     &Scicos->params.Atol, &itask,
					     &istate, &iopt, &rhot[1], &nrwp,
					     &ihot[1], &niwp, NULL, &jt,
					     (lsodar_g) lsodar2_grblk,
					     &Scicos->sim.ng, jroot, NULL);
			      tn = rhot[13];
			      if (istate > 0)
				flag = istate + 200;
			      else
				flag = istate - 200;

			      break;
			    case 1:
			    case 2:
			    case 3:
			    case 4:
			      flag =
				CVode (cvode_mem, t, y, told,
				       CV_ONE_STEP_TSTOP);
			      CVodeGetCurrentTime (cvode_mem, &tn);
			      break;
			    case 5:
			      flag =
				dopri5_solve (dopri5_mem, told, t,
					      Scicos->sim.x,
					      Scicos->params.hot);
			      break;
			    }
			  if ((flag == LSODAR_ZERO_DETACH_RETURN)
			      || (flag == LSODAR_ROOT_RETURN)
			      || (flag == CV_ZERO_DETACH_RETURN)
			      || (flag == CV_ROOT_RETURN))
			    {
			      tzero = *told;
			      zcrossing_unhandeled = flag;
			      flag = 200;
			    }
			  X_contain_xn = 1;
			}
		    }
		  if (t <= tn)
		    *told = t;

		  if (zcrossing_unhandeled)
		    {
		      if (t >= tzero - Scicos->params.ttol)
			{
			  *told = tzero;
			  flag = zcrossing_unhandeled;
			}
		    }

		  if (*told <= tn)
		    {
		      switch (Scicos->params.solver)
			{
			case 0:
			  lyh = 21 + 3 * Scicos->sim.ng;
			  kk = 0;
			  C2F (intdy) (told, &kk, &(rhot[lyh]),
				       Scicos->params.neq, Scicos->sim.x,
				       &istate);
			  break;
			case 1:
			case 2:
			case 3:
			case 4:
			  CVodeGetDky (cvode_mem, *told, 0, y);
			  break;
			case 5:
			  //      for (i = 0; i < dopri5_mem->n; i++)
			  // contd5 (dopri5_mem, i, *told, double xold, double h_old)

			  break;
			}
		      X_contain_xn = 0;
		    }

		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  Scicos->params.phase = 1;
		}
	      else
		{
		  flag = LSODAR_ROOT_RETURN;	/* in order to handle discrete jumps */
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    jroot[jj] = jroottmp[jj];
		}
	      Sfcallerid = 98;

	      /*     .     update outputs of 'c' type  blocks if we are at the end */
	      if (*told >= *tf - Scicos->params.ttol)
		{
		  Scicos->params.phase = 0;
		  odoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.xd);
		  if (Scicos->sim.ncord > 0)
		    {
		      cdoit (told);
		    }
		  goto err;
		  return;
		}

	      if (flag >= 0)
		{
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    Sciprintf ("****Solver reached: %f\n", *told);
		  Scicos->params.hot = 1;
		  cnt = 0;
		}
	      else if (flag == CV_CONV_FAILURE || flag == CV_ERR_FAILURE ||
		       flag == LSODAR_CONV_FAILURE
		       || flag == LSODAR_ERR_FAILURE)
		{
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    Sciprintf
		      ("****Solver: cannot converge at time=%g (stiff region, change RTOL and ATOL)\n",
		       *told);
		  Scicos->params.hot = 0;
		  cnt++;
		  if (cnt > 5)
		    {
		      *ierr = 300 + (-flag);
		      goto err;
		      return;
		    }
		}
	      else if (flag == CV_TOO_MUCH_WORK
		       || flag == LSODAR_TOO_MUCH_WORK)
		{
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    Sciprintf
		      ("****Solver: too much work at time=%g (stiff region, change RTOL and ATOL)\n",
		       *told);
		  Scicos->params.hot = 1;
		  istate = 2;
		  cnt++;
		  if (cnt > 5)
		    {
		      Scicos->params.hot = 0;
		    };
		}
	      else
		{
		  if (flag < 0)
		    *ierr = 300 + (-flag);	/* raising errors due to internal errors, other wise erros due to flagr */
		  goto err;
		  return;
		}

	      if (flag == CV_ZERO_DETACH_RETURN
		  || flag == LSODAR_ZERO_DETACH_RETURN
		  || flag == DP5_ZERO_DETACH_RETURN)
		{
		  Scicos->params.hot = 0;
		  zcrossing_unhandeled = 0;
		};		/* new feature of sundials, detects zero-detaching */

	      if (flag == CV_ROOT_RETURN || flag == LSODAR_ROOT_RETURN
		  || flag == DP5_ROOT_RETURN)
		{
		  zcrossing_unhandeled = 0;
		  /*     .        at a least one root has been found */
		  Scicos->params.hot = 0;
		  if (Discrete_Jump == 0)
		    {
		      switch (Scicos->params.solver)
			{
			case 0:
			  break;
			case 1:
			case 2:
			case 3:
			case 4:
			  flagr = CVodeGetRootInfo (cvode_mem, jroot);
			  if (check_flag (&flagr, "CVodeGetRootInfo", 1))
			    {
			      *ierr = 300 + (-flagr);
			      goto err;
			      return;
			    }
			  break;
			case 5:
			  flagr = DP5_Get_RootInfo (dopri5_mem, jroot);
			  break;
			}
		    }
		  /*     .        at a least one root has been found */
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    {
		      Sciprintf ("root found at t=: %f\n", *told);
		    }
		  /*     .        update outputs affecting ztyp blocks ONLY FOR OLD BLOCKS */

		  zdoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }

		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    {
		      Scicos->params.curblk = zcros[jj];
		      if (Scicos->params.curblk == -1)
			{
			  break;
			}
		      kev = 0;

		      for (j = Scicos->sim.zcptr[-1+Scicos->params.curblk] - 1;
			   j <
			     Scicos->sim.zcptr[-1+Scicos->params.curblk + 1] - 1;
			   ++j)
			{
			  if (jroot[j] != 0)
			    {
			      kev = 1;
			      break;
			    }
			}
		      /*   */
		      if (kev != 0)
			{
			  Blocks[Scicos->params.curblk - 1].jroot =
			    &jroot[Scicos->sim.zcptr[-1+Scicos->params.curblk] -
				   1];
			  if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >
			      0)
			    {

			      if (Blocks[Scicos->params.curblk - 1].nevout >
				  0)
				{
				  flag__ = 3;
				  if (Blocks[Scicos->params.curblk - 1].nx >
				      0)
				    {
				      Blocks[Scicos->params.curblk - 1].x =
					&Scicos->sim.
					x[xptr[Scicos->params.curblk - 1] -
					  1];
				      Blocks[Scicos->params.curblk - 1].xd =
					&Scicos->sim.
					xd[xptr[Scicos->params.curblk - 1] -
					   1];
				    }
				  /* call corresponding block to determine output event (kev) */
				  Blocks[Scicos->params.curblk - 1].nevprt =
				    -kev;

				  callf (told,
					 &Blocks[Scicos->params.curblk - 1],
					 &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  /*     .              update event agenda */
				  for (k = 0;
				       k <
					 Blocks[Scicos->params.curblk -
						1].nevout; ++k)
				    {
				      if (Blocks[Scicos->params.curblk - 1].
					  evout[k] >= 0.)
					{
					  i3 =
					    k +
					    Scicos->sim.clkptr[-1+Scicos->params.curblk];
					  addevs (Blocks
						  [Scicos->params.curblk -
						   1].evout[k] + (*told), &i3,
						  &ierr1);
					  if (ierr1 != 0)
					    {
					      /*     .                       nevts too small */
					      *ierr = 3;
					      goto err;
					      return;
					    }
					}
				    }
				}
			      /*     .              update state */
			      if ((Blocks[Scicos->params.curblk - 1].nx > 0)
				  || (Blocks[Scicos->params.curblk - 1].nz >
				      0)
				  || (Blocks[Scicos->params.curblk - 1].noz >
				      0)
				  || (*Blocks[Scicos->params.curblk - 1].
				      work != NULL))
				{
				  /*     .              call corresponding block to update state */
				  flag__ = 2;
				  Blocks[Scicos->params.curblk - 1].x =
				    &Scicos->sim.
				    x[xptr[Scicos->params.curblk - 1] - 1];
				  Blocks[Scicos->params.curblk - 1].xd =
				    &Scicos->sim.
				    xd[xptr[Scicos->params.curblk - 1] - 1];
				  Blocks[Scicos->params.curblk - 1].nevprt =
				    -kev;
				  callf (told,
					 &Blocks[Scicos->params.curblk - 1],
					 &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				}
			    }
			}
		    }
		}
	    }
	  /*--discrete zero crossings----dzero--------------------*/
	  if (Scicos->sim.ng > 0)
	    {			/* storing ZC signs just after a sundials call */
	      zdoit (told, Scicos->sim.x, Scicos->sim.x, Scicos->sim.g);
	      if (*ierr != 0)
		{
		  goto err;
		  return;
		}
	      for (jj = 0; jj < Scicos->sim.ng; ++jj)
		{
		  if (Scicos->sim.g[jj] >= 0)
		    {
		      jroottmp[jj] = 5;
		    }
		  else
		    {
		      jroottmp[jj] = -5;
		    }
		}
	    }
	  /*--discrete zero crossings----dzero--------------------*/
	  nsp_realtime (told);
	}
      else
	{
	  /*     .  t==told */
	  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
	    {
	      Sciprintf ("Event: %d activated at t=%f\n", *pointi, *told);
	      for (kev = 0; kev < Scicos->sim.nblk; kev++)
		{
		  if (Blocks[kev].nmode > 0)
		    {
		      Sciprintf ("mode of block %d=%d, ", kev,
				 Blocks[kev].mode[0]);
		    }
		}
	      Sciprintf ("**mod**\n");
	    }
	  ddoit (told);

	  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
	    {
	      Sciprintf ("End of activation\n");
	    }
	  if (*ierr != 0)
	    {
	      goto err;
	      return;
	    }

	}
      /*     end of main loop on time */
    }

  Scicos->params.phase = 0;
  odoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.xd);
 err:
  switch (Scicos->params.solver)
    {
    case 0:
      FREE (rhot);
      FREE (ihot);
      break;
    case 1:
    case 2:
    case 3:
    case 4:
      if (*Scicos->params.neq > 0)
	{
	  FREE (cv_data);
	  CVodeFree (&cvode_mem);
	  N_VDestroy_Serial (y);
	};
      break;
    case 5:
      dopri5_free (dopri5_mem);
      break;
    }
  if (Scicos->sim.ng > 0)
    FREE (jroot);
  if (Scicos->sim.ng > 0)
    FREE (zcros);
}				/* cossim_ */

//int Setup_IDA(void **ida_mem),int N, N_Vector *y,User_CV_data *cv_data,
//double reltol, double *abstol,double t0,double *x,int ng1, double hmax){
int Setup_IDA (void **ida_mem, int N, N_Vector * yy, double *x, N_Vector * yp,
	       double *xd, N_Vector * IDx, double reltol, double *abstol,
	       double t0, int ng1, double hmax, User_IDA_data * ida_data)
{
  int flag, Jn, Jnx, Jno, Jni, Jactaille;
  int maxnj, maxnit, arret = 0;

  if (N <= 0)
    return 0;
  /*--------*/
  *yy = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*yy), "N_VNew_Serial", 0))
    {
      *ierr = 10000;
      return -1;
    }
  NV_DATA_S ((*yy)) = x;
  /*--------*/
  *yp = N_VNewEmpty_Serial (N);
  if (check_flag ((void *) (*yp), "N_VNew_Serial", 0))
    {
      N_VDestroy_Serial ((*yp));
      *ierr = 10000;
      return -1;
    }
  NV_DATA_S ((*yp)) = xd;
  /*--------*/
  *IDx = N_VNew_Serial (N);
  if (check_flag ((void *) (*IDx), "N_VNew_Serial", 0))
    {
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 10000;
      return -1;
    }
  /*--------*/
  *ida_mem = NULL;
  *ida_mem = IDACreate ();
  if (check_flag ((void *) (*ida_mem), "IDACreate", 0))
    {
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 10000;
      return -1;
    }
  /*--------*/
  flag =
    IDAMalloc (*ida_mem, simblkdaskr, t0, *yy, *yp, IDA_SS, reltol, abstol);
  if (check_flag (&flag, "IDAMalloc", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  flag = IDARootInit (*ida_mem, ng1, grblkdaskr, NULL);
  if (check_flag (&flag, "IDARootInit", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  flag = IDADense (*ida_mem, N);
  if (check_flag (&flag, "IDADense", 1))
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  if ((*ida_data = (User_IDA_data) MALLOC (sizeof (**ida_data))) == NULL)
    {
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  (*ida_data)->ida_mem = *ida_mem;
  (*ida_data)->ewt = NULL;
  (*ida_data)->iwork = NULL;
  (*ida_data)->rwork = NULL;
  (*ida_data)->gwork = NULL;
  /*--------*/
  (*ida_data)->ewt = N_VNew_Serial (N);
  if (check_flag ((void *) ((*ida_data)->ewt), "N_VNew_Serial", 0))
    {
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }
  /*--------*/
  if (ng1 > 0)
    {
      if (((*ida_data)->gwork =
	   (double *) MALLOC (ng1 * sizeof (double))) == NULL)
	{
	  N_VDestroy_Serial (((*ida_data)->ewt));
	  FREE ((*ida_data));
	  IDAFree ((ida_mem));
	  N_VDestroy_Serial ((*IDx));
	  N_VDestroy_Serial ((*yp));
	  N_VDestroy_Serial ((*yy));
	  *ierr = 200 + (-flag);
	  return -1;
	}
    }
  /*--------*/
  /*Jacobian_Flag=0; */
  if (AJacobian_block > 0)
    {			
      /* set by the block with A-Jac in flag-4 using Set_Jacobian_flag(1); */
      Jn = *Scicos->params.neq;
      Jnx = Blocks[AJacobian_block - 1].nx;
      Jno = Blocks[AJacobian_block - 1].nout;
      Jni = Blocks[AJacobian_block - 1].nin;
    }
  else
    {
      Jn = *Scicos->params.neq;
      Jnx = 0;
      Jno = 0;
      Jni = 0;
    }

  Jactaille =
    3 * Jn + (Jn + Jni) * (Jn + Jno) + Jnx * (Jni + 2 * Jn + Jno) + (Jn -
								     Jnx) *
    (2 * (Jn - Jnx) + Jno + Jni) + 2 * Jni * Jno;
  if (((*ida_data)->rwork =
       (double *) MALLOC (Jactaille * sizeof (double))) == NULL)
    {
      if (ng1 > 0)
	FREE ((*ida_data)->gwork);
      N_VDestroy_Serial (((*ida_data)->ewt));
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }

  flag = IDADenseSetJacFn (*ida_mem, Jacobians, *ida_data);
  if (check_flag (&flag, "IDADenseSetJacFn", 1))
    arret = 1;

  flag = IDASetRdata (*ida_mem, *ida_data);
  if (check_flag (&flag, "IDASetRdata", 1))
    arret = 1;

  if (hmax > 0)
    {
      flag = IDASetMaxStep (*ida_mem, (double) hmax);
      if (check_flag (&flag, "IDASetMaxStep", 1))
	arret = 1;
    }

  maxnj = 100;			/* setting the maximum number of Jacobian evaluation during a Newton step */
  flag = IDASetMaxNumJacsIC (*ida_mem, maxnj);
  if (check_flag (&flag, "IDASetMaxNumJacsIC", 1))
    arret = 1;

  maxnit = 10;			/* setting the maximum number of Newton iterations in any one attemp to solve CIC */
  flag = IDASetMaxNumItersIC (*ida_mem, maxnit);
  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
    arret = 1;

  /* setting the maximum number of steps in an integration interval */
  flag = IDASetMaxNumSteps (*ida_mem, 2000);
  if (check_flag (&flag, "IDASetMaxNumSteps", 1))
    arret = 1;

  if (arret)
    {
      FREE ((*ida_data)->rwork);
      if (ng1 > 0)
	FREE ((*ida_data)->gwork);
      N_VDestroy_Serial (((*ida_data)->ewt));
      FREE ((*ida_data));
      IDAFree ((ida_mem));
      N_VDestroy_Serial ((*IDx));
      N_VDestroy_Serial ((*yp));
      N_VDestroy_Serial ((*yy));
      *ierr = 200 + (-flag);
      return -1;
    }

  return 0;
}

static void cossimdaskr (double *told)
{
  static int otimer = 0;
  int i3;
  static int flag__;
  static int ierr1;
  static int j, k;
  static double t;
  static int kk, jj, jt;
  static int ntimer;
  static double rhotmp, tstop, hmax_auto;
  int inxsci;
  static int kpo, kev;

  int *jroot = NULL, *zcros = NULL;
  int maxord;
  int *Mode_save;
  int Mode_change = 0;
  double *tmpneq = NULL;

  int flag, flagr;
  N_Vector yy = NULL, yp = NULL;
  double reltol, abstol;
  int Discrete_Jump;
  N_Vector IDx = NULL;
  double *scicos_xproperty = NULL;
  N_Vector bidon = NULL, tempv1 = NULL, tempv2 = NULL, tempv3 = NULL;
  DenseMat TJacque = NULL;
  double *Jacque_col;
  double tnext;
  void *ida_mem = NULL;
  User_IDA_data ida_data = NULL;
  IDAMem copy_IDA_mem = NULL;
  /*-------------------- Analytical Jacobian memory allocation ----------*/
  int maxnj;
  double uround;
  int cnt = 0, N_iters;
  double tzero = 0.0, tn = 0.0;
  int zcrossing_unhandeled = 0, *jroottmp = NULL;
  int X_contain_xn = 1;

  maxord = 5;
  Sfcallerid = 99;

  CI = 1.0;
  for (jj = 0; jj < *Scicos->params.neq; jj++)
    {
      Scicos->sim.alpha[jj] = CI;
      //beta[jj]=CJ;
    }

  if (Scicos->sim.ng != 0)
    {
      if ((jroot = MALLOC (sizeof (int) * Scicos->sim.ng * 2)) == NULL)
	{
	  *ierr = 10000;
	  return;
	}
      jroottmp = jroot + Scicos->sim.ng;
      for (jj = 0; jj < Scicos->sim.ng * 2; jj++)
	jroot[jj] = 0;
      if ((zcros = MALLOC (sizeof (int) * Scicos->sim.ng)) == NULL)
	{
	  *ierr = 10000;
	  if (Scicos->sim.ng != 0)
	    FREE (jroot);
	  return;
	}
    }

  Mode_save = NULL;
  if (nmod != 0)
    {
      if ((Mode_save = MALLOC (sizeof (int) * nmod)) == NULL)
	{
	  *ierr = 10000;
	  if (Scicos->sim.ng != 0)
	    FREE (jroot);
	  if (Scicos->sim.ng != 0)
	    FREE (zcros);
	  return;
	}
    }
  tmpneq = NULL;
  if (*Scicos->params.neq != 0)
    {
      if ((tmpneq = MALLOC (*Scicos->params.neq * sizeof (double))) == NULL)
	{
	  *ierr = 10000;
	  if (nmod)
	    FREE (Mode_save);
	  if (Scicos->sim.ng != 0)
	    FREE (jroot);
	  if (Scicos->sim.ng != 0)
	    FREE (zcros);
	  return;
	}
    }


  reltol = (double) Scicos->params.rtol;
  abstol = (double) Scicos->params.Atol;	/*  Ith(abstol,1) = double) Atol; */
  hmax_auto = (Scicos->params.hmax > 0) ? Scicos->params.hmax : (*tf / 100.0);

  if (*Scicos->params.neq > 0)
    {
      flag =
	Setup_IDA (&ida_mem, *Scicos->params.neq, &yy, Scicos->sim.x, &yp,
		   Scicos->sim.xd, &IDx, reltol, &abstol, *told,
		   Scicos->sim.ng, hmax_auto, &ida_data);
      if (flag < 0)
	{
	  *ierr = 10000;
	  if (*Scicos->params.neq > 0)
	    FREE (tmpneq);
	  if (nmod)
	    FREE (Mode_save);
	  if (Scicos->sim.ng)
	    FREE (jroot);
	  if (Scicos->sim.ng)
	    FREE (zcros);
	  return;
	}
      copy_IDA_mem = (IDAMem) ida_mem;
      TJacque =
	(DenseMat) DenseAllocMat (*Scicos->params.neq, *Scicos->params.neq);
    }

  uround = 1.0;
  do
    {
      uround = uround * 0.5;
    }
  while (1.0 + uround != 1.0);
  uround = uround * 2.0;
  SQuround = sqrt (uround);
  /* Function Body */

  Scicos->params.halt = 0;
  *ierr = 0;
  /*     hot = .false. */
  Scicos->params.phase = 1;
  Scicos->params.hot = 0;

  jt = 2;
  /*      stuck=.false. */
  inxsci = nsp_check_events_activated ();
  /*     initialization */
  nsp_realtime_init (told, &Scicos->params.scale);
  /*     ATOL and RTOL are scalars */

  jj = 0;
  for (Scicos->params.curblk = 1; Scicos->params.curblk <= Scicos->sim.nblk;
       ++Scicos->params.curblk)
    {
      if (Blocks[Scicos->params.curblk - 1].ng >= 1)
	{
	  zcros[jj] = Scicos->params.curblk;
	  ++jj;
	}
    }
  /*     . Il faut:  ng >= jj */
  if (jj != Scicos->sim.ng)
    {
      zcros[jj] = -1;
    }
  /*     initialisation (propagation of constant blocks outputs) */
  idoit (told);
  if (*ierr != 0)
    {
      goto err;
      return;
    }

  /*--discrete zero crossings----dzero--------------------*/
  if (Scicos->sim.ng > 0)
    {				/* storing ZC signs just after a solver call */
      zdoit (told, Scicos->sim.x, Scicos->sim.x, Scicos->sim.g);
      if (*ierr != 0)
	{
	  goto err;
	  return;
	}
      for (jj = 0; jj < Scicos->sim.ng; ++jj)
	if (Scicos->sim.g[jj] >= 0)
	  jroottmp[jj] = 5;
	else
	  jroottmp[jj] = -5;
    }
  /*     main loop on time */
  tstop = *tf + Scicos->params.ttol;

  while (*told < *tf)
    {
      if (inxsci == TRUE)
	{
	  /* what follows can modify Scicos->params.halt */
	  ntimer = nsp_stimer ();
	  if (ntimer != otimer)
	    {
	      nsp_check_gtk_events ();
	      otimer = ntimer;
	    }
	}

      if (Scicos->params.halt != 0)
	{
	  if (Scicos->params.halt == 2)
	    *told = *tf;	/* end simulation */
	  Scicos->params.halt = 0;
	  goto err;
	  return;
	}
      if (*pointi == 0)
	{
	  t = *tf;
	}
      else
	{
	  t = Scicos->sim.tevts[-1+*pointi];
	}
      if (Abs (t - *told) < Scicos->params.ttol)
	{
	  t = *told;
	  /*     update output part */
	}
      if (*told > t)
	{
	  /*     !  scheduling problem */
	  *ierr = 1;
	  goto err;
	  return;
	}

      if (*told >= *tf - Scicos->params.ttol)
	{
	  /*     .     we are at the end, update continuous part before leaving */
	  Scicos->params.phase = 0;
	  odoit (told, Scicos->sim.x, Scicos->sim.xd, tmpneq);
	  cdoit (told);
	  goto err;
	  return;
	}

      if (*told != t)
	{
	  if (xptr[Scicos->sim.nblk] == 1)
	    {
	      Scicos->params.phase = 0;
	      odoit (told, Scicos->sim.x, Scicos->sim.xd, tmpneq);
	      Scicos->params.phase = 1;

	      tnext = Min (*told + hmax_auto, *told + Scicos->params.deltat);
	      if (tnext + Scicos->params.ttol > t)
		{
		  *told = t;
		}
	      else
		{
		  *told = tnext;
		}

	      /*     .     update outputs of 'c' type blocks with no continuous state */
	      if (*told >= *tf - Scicos->params.ttol)
		{
		  /*     .     we are at the end, update continuous part before leaving */
		  Scicos->params.phase = 0;
		  odoit (told, Scicos->sim.x, Scicos->sim.xd, tmpneq);
		  cdoit (told);
		  goto err;
		  return;
		}
	    }
	  else
	    {
	      rhotmp = *tf + Scicos->params.ttol;
	      if (*pointi != 0)
		{
		  kpo = *pointi;
		L20:
		  if (Scicos->sim.critev[-1+kpo] == 1)
		    {
		      rhotmp = Scicos->sim.tevts[-1+kpo];
		      goto L30;
		    }
		  kpo = evtspt[-1+kpo];
		  if (kpo != 0)
		    {
		      goto L20;
		    }
		L30:
		  if (rhotmp > *tf + Scicos->params.ttol)
		    rhotmp = *tf + Scicos->params.ttol;
		  if (rhotmp < tstop - Scicos->params.ttol)
		    {
		      Scicos->params.hot = 0;	/* Do cold-restart the solver:if the new TSTOP isn't beyong the previous one */
		    }
		}
	      tstop = rhotmp;
	      t =
		Min (*told + Scicos->params.deltat,
		     Min (t, *tf + Scicos->params.ttol));

	      if (Scicos->params.hot == 0)
		{		/* CIC calculation when hot==0 */
		  /* Setting the stop time */
		  flag = IDASetStopTime (ida_mem, (double) tstop);
		  if (check_flag (&flag, "IDASetStopTime", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    }

		  if (Scicos->sim.ng > 0 && nmod > 0)
		    {
		      Scicos->params.phase = 1;
		      zdoit (told, Scicos->sim.x, Scicos->sim.xd,
			     Scicos->sim.g);
		      if (*ierr != 0)
			{
			  goto err;
			  return;
			}
		    }
		  /*----------ID setting/checking------------*/
		  N_VConst (SUNDIALS_ONE, IDx);	/* Initialize id to 1's. */
		  scicos_xproperty = NV_DATA_S (IDx);
		  Sfcallerid = -18;	/*Added beacuse reinitdoit() has call to blocks with flag-0 */
		  reinitdoit (told);
		  if (*ierr > 0)
		    {
		      goto err;
		      return;
		    }

		  CI = 0.0;
		  CJ = 100.0;
		  for (jj = 0; jj < *Scicos->params.neq; jj++)
		    {
		      if (Scicos->sim.xprop[jj] == 1)
			scicos_xproperty[jj] = SUNDIALS_ONE;
		      if (Scicos->sim.xprop[jj] == -1)
			scicos_xproperty[jj] = SUNDIALS_ZERO;
		      Scicos->sim.alpha[jj] = CI;
		      Scicos->sim.beta[jj] = CJ;
		    }

		  Jacobians (*Scicos->params.neq, (double) (*told), yy, yp,
			     bidon, (double) CJ, ida_data, TJacque, tempv1,
			     tempv2, tempv3);

		  for (jj = 0; jj < *Scicos->params.neq; jj++)
		    {
		      Jacque_col = DENSE_COL (TJacque, jj);
		      CI = SUNDIALS_ZERO;
		      for (kk = 0; kk < *Scicos->params.neq; kk++)
			{
			  if ((Jacque_col[kk] - Jacque_col[kk] != 0))
			    {
			      CI = -SUNDIALS_ONE;
			      break;
			    }
			  else
			    {
			      if (Jacque_col[kk] != 0)
				{
				  CI = SUNDIALS_ONE;
				  break;
				}
			    }
			}
		      if (CI >= SUNDIALS_ZERO)
			{
			  scicos_xproperty[jj] = CI;
			}
		      else
			{
			  fprintf (stderr, "Warning: xproperties do not match for i=%d!\n",
				   jj);
			}
		    }
		  /* printf("\n"); for(jj=0;jj<*Scicos->params.neq;jj++) { printf("x%d=%g ",jj,scicos_xproperty[jj]); } */
		  flag = IDASetId (ida_mem, IDx);
		  if (check_flag (&flag, "IDASetId", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    }
		  CI = 1.0;
		  for (jj = 0; jj < *Scicos->params.neq; jj++)
		    {
		      Scicos->sim.alpha[jj] = CI;
		      /* Scicos->sim.beta[jj]=CJ; */
		    }

		  /*--------------------------------------------*/
		  maxnj = 100;	/* setting the maximum number of Jacobian evaluation during a Newton step */
		  flag = IDASetMaxNumJacsIC (ida_mem, maxnj);
		  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };
		  flag = IDASetLineSearchOffIC (ida_mem, FALSE);	/* (def=false)  */
		  if (check_flag (&flag, "IDASetLineSearchOffIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };
		  flag = IDASetMaxNumItersIC (ida_mem, 10);	/* (def=10) setting the maximum number of Newton iterations in any one attemp to solve CIC */
		  if (check_flag (&flag, "IDASetMaxNumItersIC", 1))
		    {
		      *ierr = 200 + (-flag);
		      goto err;
		      return;
		    };

		  N_iters = 10 + Min (nmod * 3, 30);
		  for (j = 0; j <= N_iters; j++)
		    {		/* counter to reevaluate the
				   modes in  mode->CIC->mode->CIC-> loop
				   do it once in the absence of mode (nmod=0) */
		      /* updating the modes through Flag==9, Phase==1 */
		      if (inxsci == TRUE)
			{
			  /* what follows can modify Scicos->params.halt */
			  ntimer = nsp_stimer ();
			  if (ntimer != otimer)
			    {
			      nsp_check_gtk_events ();
			      otimer = ntimer;
			    }
			}

		      if (Scicos->params.halt != 0)
			{
			  Scicos->params.halt = 0;
			  goto err;
			  return;
			}

		      /* yy->PH */
		      flag =
			IDAReInit (ida_mem, simblkdaskr, (double) (*told), yy,
				   yp, IDA_SS, reltol, &abstol);
		      if (check_flag (&flag, "CVodeReInit", 1))
			{
			  *ierr = 200 + (-flag);
			  goto err;
			  return;
			}

		      Scicos->params.phase = 2;	/* IDACalcIC: PHI-> yy0: if (ok) yy0_cic-> PHI */
		      copy_IDA_mem->ida_kk = 1;

		      flagr =
			IDACalcIC (ida_mem, IDA_YA_YDP_INIT, (double) (t));
		      Scicos->params.phase = 1;
		      flag = IDAGetConsistentIC (ida_mem, yy, yp);	/* PHI->YY */

		      if (*ierr > 5)
			{	/* *ierr>5 => singularity in block */
			  goto err;
			  return;
			}

		      if ((Scicos->params.debug >= 1)
			  && (Scicos->params.debug != 3))
			{
			  if (flagr >= 0)
			    {
			      Sciprintf
				("**** Solver succesfully initialized *****\n");
			    }
			  else
			    {
			      Sciprintf
				("**** Solver failed to initialize ->try again *****\n");
			    }
			}
		      /*-------------------------------------*/
		      /* saving the previous modes */
		      for (jj = 0; jj < nmod; ++jj)
			{
			  Mode_save[jj] = mod[jj];
			}
		      if (Scicos->sim.ng > 0 && nmod > 0)
			{
			  Scicos->params.phase = 1;
			  zdoit (told, Scicos->sim.x, Scicos->sim.xd,
				 Scicos->sim.g);
			  if (*ierr != 0)
			    {
			      goto err;
			      return;
			    }
			}
		      /*------------------------------------*/
		      Mode_change = 0;
		      for (jj = 0; jj < nmod; ++jj)
			{
			  if (Mode_save[jj] != mod[jj])
			    {
			      Mode_change = 1;
			      break;
			    }
			}
		      if (Mode_change == 0)
			{
			  if (flagr >= 0)
			    {
			      break;	/*   if (flagr>=0) break;  else{ *ierr=200+(-flagr); goto err;  return; } */
			    }
			  else if (j >= (int) (N_iters / 2))
			    {
			      /* IDASetMaxNumStepsIC(mem,10); *//* maxnh (def=5) */
			      IDASetMaxNumJacsIC (ida_mem, 10);	/* maxnj 100 (def=4) */
			      /* IDASetMaxNumItersIC(mem,100000); *//* maxnit in IDANewtonIC (def=10) */
			      IDASetLineSearchOffIC (ida_mem, TRUE);	/* (def=false)  */
			      /* IDASetNonlinConvCoefIC(mem,1.01); *//* (def=0.01-0.33 */
			      flag = IDASetMaxNumItersIC (ida_mem, 1000);
			      if (check_flag
				  (&flag, "IDASetMaxNumItersIC", 1))
				{
				  *ierr = 200 + (-flag);
				  goto err;
				  return;
				};
			    }
			}
		    }		/* mode-CIC  counter */
		  if (Mode_change == 1)
		    {
		      /* In tghis case, we try again by relaxing all modes and calling IDA_calc again 
		         /Masoud */
		      Scicos->params.phase = 1;
		      copy_IDA_mem->ida_kk = 1;
		      flagr =
			IDACalcIC (ida_mem, IDA_YA_YDP_INIT, (double) (t));
		      Scicos->params.phase = 1;
		      flag = IDAGetConsistentIC (ida_mem, yy, yp);	/* PHI->YY */
		      if ((flagr < 0) || (*ierr > 5))
			{	/* *ierr>5 => singularity in block */
			  *ierr = 23;
			  goto err;
			  return;
			}
		    }
		  /*-----If flagr<0 the initialization solver has not converged-----*/
		  if (flagr < 0)
		    {
		      *ierr = 237;
		      goto err;
		      return;
		    }

		}		/* CIC calculation when hot==0 */

	      if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
		{
		  Sciprintf ("****Solver from: %f to %f hot= %d  \n", *told,
			     t, Scicos->params.hot);
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      /*--check for Dzeros after Mode settings or ddoit()----*/
	      Discrete_Jump = 0;
	      if (Scicos->sim.ng > 0 && Scicos->params.hot == 0)
		{
		  zdoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    {
		      if ((Scicos->sim.g[jj] >= 0.0) && (jroottmp[jj] == -5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = 1;
			}
		      else if ((Scicos->sim.g[jj] < 0.0)
			       && (jroottmp[jj] == 5))
			{
			  Discrete_Jump = 1;
			  jroottmp[jj] = -1;
			}
		      else
			jroottmp[jj] = 0;
		    }
		}

	      /*--discrete zero crossings----dzero--------------------*/
	      if (Discrete_Jump == 0)
		{	
		  /* if there was a dzero, its event should be activated */
		  Scicos->params.phase = 2;
		  if (Scicos->params.hot == 0)
		    {
		      tn = *told;
		      X_contain_xn = 1;
		      zcrossing_unhandeled = 0;
		    }

		  flag = 0;
		  if (!zcrossing_unhandeled)
		    {
		      if ((t > tn))
			{
			  if (X_contain_xn == 0)
			    {
			      IDAGetSolution (ida_mem, tn, yy, yp);
			    }
			  Scicos->params.phase = 0;
			  odoit (&tn, Scicos->sim.x, Scicos->sim.xd, tmpneq);
			  Scicos->params.phase = 2;
			  flagr =
			    IDASolve (ida_mem, t, told, yy, yp,
				      IDA_ONE_STEP_TSTOP);
			  IDAGetCurrentTime (ida_mem, &tn);
			  if ((flagr == IDA_ZERO_DETACH_RETURN)
			      || (flagr == IDA_ROOT_RETURN))
			    {
			      tzero = *told;
			      zcrossing_unhandeled = flagr;
			      flagr = 0;
			    }

			}
		      X_contain_xn = 1;
		    }
		  if (t <= tn)
		    *told = t;

		  if (zcrossing_unhandeled)
		    {
		      if (t >= tzero - Scicos->params.ttol)
			{
			  *told = tzero;
			  flagr = zcrossing_unhandeled;
			}
		    }
		  if (*told <= tn)
		    {
		      IDAGetSolution (ida_mem, *told, yy, yp);
		      X_contain_xn = 0;
		    }

		  Scicos->params.phase = 1;
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		}
	      else
		{
		  flagr = IDA_ROOT_RETURN;	/* in order to handle discrete jumps */
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    jroot[jj] = jroottmp[jj];
		}
	      Sfcallerid = 98;
	      if (flagr >= 0)
		{
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    Sciprintf ("****Solver reached: %f\n", *told);
		  Scicos->params.hot = 1;
		  cnt = 0;
		}
	      else if (flagr == IDA_TOO_MUCH_WORK || flagr == IDA_CONV_FAIL
		       || flagr == IDA_ERR_FAIL)
		{
		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    Sciprintf
		      ("**** Solver: too much work at time=%g (stiff region, change RTOL and ATOL)\n",
		       *told);
		  Scicos->params.hot = 0;
		  cnt++;
		  if (cnt > 5)
		    {
		      *ierr = 200 + (-flagr);
		      goto err;
		      return;
		    }
		}
	      else
		{
		  if (flagr < 0)
		    *ierr = 200 + (-flagr);	/* raising errors due to internal errors, other wise erros due to flagr */
		  goto err;
		  return;
		}

	      /*     update outputs of 'c' type  blocks if we are at the end */
	      if (*told >= *tf - Scicos->params.ttol)
		{
		  Scicos->params.phase = 0;
		  odoit (told, Scicos->sim.x, Scicos->sim.xd, tmpneq);
		  cdoit (told);
		  goto err;
		  return;
		}

	      if (flagr == IDA_ZERO_DETACH_RETURN)
		{
		  Scicos->params.hot = 0;
		  zcrossing_unhandeled = 0;
		};		/* new feature of sundials, detects unmasking */
	      if (flagr == IDA_ROOT_RETURN)
		{
		  zcrossing_unhandeled = 0;
		  /*     .        at a least one root has been found */
		  Scicos->params.hot = 0;
		  if (Discrete_Jump == 0)
		    {
		      flagr = IDAGetRootInfo (ida_mem, jroot);
		      if (check_flag (&flagr, "IDAGetRootInfo", 1))
			{
			  *ierr = 200 + (-flagr);
			  goto err;
			  return;
			}
		    }

		  if ((Scicos->params.debug >= 1)
		      && (Scicos->params.debug != 3))
		    {
		      Sciprintf ("root found at t=: %f\n", *told);
		    }
		  /*     .        update outputs affecting ztyp blocks  ONLY FOR OLD BLOCKS */
		  zdoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    {
		      Scicos->params.curblk = zcros[jj];
		      if (Scicos->params.curblk == -1)
			{
			  break;
			}
		      kev = 0;
		      for (j = Scicos->sim.zcptr[-1+Scicos->params.curblk] - 1;
			   j <
			     Scicos->sim.zcptr[-1+Scicos->params.curblk + 1] - 1;
			   ++j)
			{
			  if (jroot[j] != 0)
			    {
			      kev = 1;
			      break;
			    }
			}
		      if (kev != 0)
			{
			  Blocks[Scicos->params.curblk - 1].jroot =
			    &jroot[Scicos->sim.zcptr[-1+Scicos->params.curblk] -
				   1];
			  if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >
			      0)
			    {
			      if (Blocks[Scicos->params.curblk - 1].nevout >
				  0)
				{
				  flag__ = 3;
				  if (Blocks[Scicos->params.curblk - 1].nx >
				      0)
				    {
				      Blocks[Scicos->params.curblk - 1].x =
					&Scicos->sim.
					x[xptr[Scicos->params.curblk - 1] -
					  1];
				      Blocks[Scicos->params.curblk - 1].xd =
					&Scicos->sim.
					xd[xptr[Scicos->params.curblk - 1] -
					   1];
				    }
				  /*     call corresponding block to determine output event (kev) */
				  Blocks[Scicos->params.curblk - 1].nevprt =
				    -kev;
				  callf (told,
					 &Blocks[Scicos->params.curblk - 1],
					 &flag__);
				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  /*     update event agenda */
				  for (k = 0;
				       k <
					 Blocks[Scicos->params.curblk -
						1].nevout; ++k)
				    {
				      if (Blocks[Scicos->params.curblk - 1].
					  evout[k] >= 0)
					{
					  i3 =
					    k +
					    Scicos->sim.clkptr[-1+Scicos->params.
							       curblk];
					  addevs (Blocks
						  [Scicos->params.curblk -
						   1].evout[k] + (*told), &i3,
						  &ierr1);
					  if (ierr1 != 0)
					    {
					      /*     .                       nevts too small */
					      *ierr = 3;
					      goto err;
					      return;
					    }
					}
				    }
				}
			      /* update state */
			      if ((Blocks[Scicos->params.curblk - 1].nx > 0)
				  || (Blocks[Scicos->params.curblk - 1].nz >
				      0)
				  || (Blocks[Scicos->params.curblk - 1].noz >
				      0)
				  || (*Blocks[Scicos->params.curblk - 1].
				      work != NULL))
				{
				  /* call corresponding block to update state */
				  flag__ = 2;
				  if (Blocks[Scicos->params.curblk - 1].nx >
				      0)
				    {
				      Blocks[Scicos->params.curblk - 1].x =
					&Scicos->sim.
					x[xptr[Scicos->params.curblk - 1] -
					  1];
				      Blocks[Scicos->params.curblk - 1].xd =
					&Scicos->sim.
					xd[xptr[Scicos->params.curblk - 1] -
					   1];
				    }
				  Blocks[Scicos->params.curblk - 1].nevprt =
				    -kev;
				  Blocks[Scicos->params.curblk - 1].xprop =
				    &Scicos->sim.xprop[-1 +
						       xptr[Scicos->params.
							    curblk - 1]];
				  callf (told,
					 &Blocks[Scicos->params.curblk - 1],
					 &flag__);

				  if (flag__ < 0)
				    {
				      *ierr = 5 - flag__;
				      goto err;
				      return;
				    }
				  for (j = 0; j < *Scicos->params.neq; j++)
				    {	/* Adjust xprop for IDx */
				      if (Scicos->sim.xprop[j] == 1)
					scicos_xproperty[j] = SUNDIALS_ONE;
				      if (Scicos->sim.xprop[j] == -1)
					scicos_xproperty[j] = SUNDIALS_ZERO;
				    }
				}
			    }
			}
		    }
		}

	      if (inxsci == TRUE)
		{
		  /* what follows can modify Scicos->params.halt */
		  ntimer = nsp_stimer ();
		  if (ntimer != otimer)
		    {
		      nsp_check_gtk_events ();
		      otimer = ntimer;
		    }
		}

	      if (Scicos->params.halt != 0)
		{
		  Scicos->params.halt = 0;
		  goto err;
		  return;
		}
	      /* if(*pointi!=0){
	         t=tevts[-1+*pointi];
	         if(*told<t-Scicos->params.ttol){
	         cdoit(told);
	         goto L15;
	         }
	         }else{
	         if(*told<*tf){
	         cdoit(told);
	         goto L15;
	         }
	         } */

	      /*--discrete zero crossings----dzero--------------------*/
	      if (Scicos->sim.ng > 0)
		{		/* storing ZC signs just after a ddaskr call */
		  zdoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.g);
		  if (*ierr != 0)
		    {
		      goto err;
		      return;
		    }
		  for (jj = 0; jj < Scicos->sim.ng; ++jj)
		    {
		      if (Scicos->sim.g[jj] >= 0)
			{
			  jroottmp[jj] = 5;
			}
		      else
			{
			  jroottmp[jj] = -5;
			}
		    }
		}
	      /*--discrete zero crossings----dzero--------------------*/
	    }
	  nsp_realtime (told);
	}
      else
	{
	  /*     .  t==told */
	  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
	    {
	      Sciprintf ("Event: %d activated at t=%f\n", *pointi, *told);
	    }

	  ddoit (told);
	  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
	    {
	      Sciprintf ("End of activation");
	    }
	  if (*ierr != 0)
	    {
	      goto err;
	      return;
	    }
	}
      /*     end of main loop on time */
    }
  Scicos->params.phase = 0;
  odoit (told, Scicos->sim.x, Scicos->sim.xd, tmpneq);
 err:
  if (*Scicos->params.neq > 0)
    FREE (TJacque);
  if (*Scicos->params.neq > 0)
    FREE (ida_data->rwork);
  if ((Scicos->sim.ng > 0) && (*Scicos->params.neq > 0))
    FREE (ida_data->gwork);
  if (*Scicos->params.neq > 0)
    N_VDestroy_Serial (ida_data->ewt);
  if (*Scicos->params.neq > 0)
    FREE (ida_data);
  if (*Scicos->params.neq > 0)
    IDAFree (&ida_mem);
  if (*Scicos->params.neq > 0)
    N_VDestroy_Serial (IDx);
  if (*Scicos->params.neq > 0)
    N_VDestroy_Serial (yp);
  if (*Scicos->params.neq > 0)
    N_VDestroy_Serial (yy);
  if (*Scicos->params.neq > 0)
    FREE (tmpneq);
  if (Scicos->sim.ng > 0)
    FREE (jroot);
  if (Scicos->sim.ng > 0)
    FREE (zcros);
  if (nmod > 0)
    FREE (Mode_save);
}				/* cossimdaskr_ */


static void cosend (double *told)
{
  static int flag__;
  static int kfune;
  *ierr = 0;
  /*     loop on blocks */
  for (Scicos->params.curblk = 1; Scicos->params.curblk <= Scicos->sim.nblk;
       ++Scicos->params.curblk)
    {
      flag__ = 5;
      Blocks[Scicos->params.curblk - 1].nevprt = 0;
      if (Scicos->sim.funtyp[Scicos->params.curblk - 1] >= 0)
	{
	  if (Blocks[Scicos->params.curblk - 1].nx > 0)
	    {
	      Blocks[Scicos->params.curblk - 1].x =
		&Scicos->sim.x[xptr[Scicos->params.curblk - 1] - 1];
	      Blocks[Scicos->params.curblk - 1].xd =
		&Scicos->sim.xd[xptr[Scicos->params.curblk - 1] - 1];
	    }
	  callf (told, &Blocks[Scicos->params.curblk - 1], &flag__);
	  if (flag__ < 0 && *ierr == 0)
	    {
	      *ierr = 5 - flag__;
	      kfune = Scicos->params.curblk;
	    }
	}
    }
  if (*ierr != 0)
    {
      Scicos->params.curblk = kfune;
      return;
    }
}				/* cosend_ */

static void callf (const double *t, scicos_block * block, int *flag)
{
  double *args[SZ_SIZE];
  int sz[SZ_SIZE];
  double intabl[TB_SIZE];
  double outabl[TB_SIZE];

  int ii, in, out, ki, ko, no, ni, k, j;
  int szi, flagi;
  double *ptr_d = NULL;

  /* function pointers type def */
  voidf loc;
  ScicosF0 loc0;
  ScicosF loc1;
  ScicosF2 loc2;
  ScicosF2z loc2z;
  ScicosFi loci1;
  ScicosFi2 loci2;
  ScicosFi2z loci2z;
  ScicosF4 loc4;
  
  int solver = Scicos->params.solver;
  int cosd = Scicos->params.debug;
  /*int kf     = Scicos->params.curblk; */
  scicos_time = *t;
  block_error = flag;

  /* debug block is never called */
  /*if (kf==(Scicos->sim.debug_block+1)) return; */
  if (block->type == 99)
    return;

  /* flag 7 implicit initialization */
  flagi = *flag;
  /* change flag to zero if flagi==7 for explicit block */
  if (flagi == 7 && block->type < 10000)
    {
      *flag = 0;
    }

  /* display information for debugging mode */
  if (cosd > 1)
    {
      if (cosd != 3)
	{
	  Sciprintf ("block %d is called ", Scicos->params.curblk);
	  Sciprintf ("with flag=%d ", *flag);
	  Sciprintf ("Phase=%d ", Scicos->params.phase);
	  Sciprintf ("at time %f \n", *t);
	}
      if (Scicos->sim.debug_block > -1)
	{
	  if (cosd != 3)
	    Sciprintf ("Entering the block \n");
	  fprintf (stderr, "Entering the block=%d  %d %d %p \n",
		   Scicos->sim.debug_block, flagi, *flag, block);
	  call_debug_scicos (block, flag, flagi, Scicos->sim.debug_block);
	  if (*flag < 0)
	    return;		/* error in debug block */
	}
    }
  
  /* this parameters can be transmited with Scicos */
  Scicos->params.scsptr = block->scsptr; 
  Scicos->params.scsptr_flag = block->scsptr_flag;
  

  /* get pointer of the function */
  loc = block->funpt;

  /* continuous state */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      ptr_d = block->xd;
      block->xd = block->res;
    }

  /* switch loop */
  switch (block->type)
    {
      /*******************/
      /* function type 0 */
      /*******************/
    case 0:
      {				/* This is for compatibility */
	/* jroottmp is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* concatenated entries and concatened outputs */
	/* catenate inputs if necessary */
	ni = 0;
	if (block->nin > 1)
	  {
	    ki = 0;
	    for (in = 0; in < block->nin; in++)
	      {
		szi = block->insz[in] * block->insz[in + block->nin];
		for (ii = 0; ii < szi; ii++)
		  {
		    intabl[ki++] = *((double *) (block->inptr[in]) + ii);
		  }
		ni = ni + szi;
	      }
	    args[0] = &(intabl[0]);
	  }
	else
	  {
	    if (block->nin == 0)
	      {
		args[0] = NULL;
	      }
	    else
	      {
		args[0] = (double *) (block->inptr[0]);
		ni = block->insz[0] * block->insz[1];
	      }
	  }

	/* catenate outputs if necessary */
	no = 0;
	if (block->nout > 1)
	  {
	    ko = 0;
	    for (out = 0; out < block->nout; out++)
	      {
		szi = block->outsz[out] * block->outsz[out + block->nout];
		for (ii = 0; ii < szi; ii++)
		  {
		    outabl[ko++] = *((double *) (block->outptr[out]) + ii);
		  }
		no = no + szi;
	      }
	    args[1] = &(outabl[0]);
	  }
	else
	  {
	    if (block->nout == 0)
	      {
		args[1] = NULL;
	      }
	    else
	      {
		args[1] = (double *) (block->outptr[0]);
		no = block->outsz[0] * block->outsz[1];
	      }
	  }

	loc0 = (ScicosF0) loc;

	(*loc0) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		 block->z, &block->nz,
		 block->evout, &block->nevout, block->rpar, &block->nrpar,
		 block->ipar, &block->nipar, (double *) args[0], &ni,
		 (double *) args[1], &no);

	/* split output vector on each port if necessary */
	if (block->nout > 1)
	  {
	    ko = 0;
	    for (out = 0; out < block->nout; out++)
	      {
		szi = block->outsz[out] * block->outsz[out + block->nout];
		for (ii = 0; ii < szi; ii++)
		  {
		    *((double *) (block->outptr[out]) + ii) = outabl[ko++];
		  }
	      }
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }
      
      /*******************/
      /* function type 1 */
      /*******************/
    case 1:
      {	
	/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* one entry for each input or output */
	for (in = 0; in < block->nin; in++)
	  {
	    args[in] = block->inptr[in];
	    sz[in] = block->insz[in];
	  }
	for (out = 0; out < block->nout; out++)
	  {
	    args[in + out] = block->outptr[out];
	    sz[in + out] = block->outsz[out];
	  }
	/* with zero crossing */
	if (block->ztyp > 0)
	  {
	    args[block->nin + block->nout] = block->g;
	    sz[block->nin + block->nout] = block->ng;
	  }

	loc1 = (ScicosF) loc;

	(*loc1) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		 block->z, &block->nz,
		 block->evout, &block->nevout, block->rpar, &block->nrpar,
		 block->ipar, &block->nipar,
		 (double *) args[0], &sz[0],
		 (double *) args[1], &sz[1], (double *) args[2], &sz[2],
		 (double *) args[3], &sz[3], (double *) args[4], &sz[4],
		 (double *) args[5], &sz[5], (double *) args[6], &sz[6],
		 (double *) args[7], &sz[7], (double *) args[8], &sz[8],
		 (double *) args[9], &sz[9], (double *) args[10], &sz[10],
		 (double *) args[11], &sz[11], (double *) args[12], &sz[12],
		 (double *) args[13], &sz[13], (double *) args[14], &sz[14],
		 (double *) args[15], &sz[15], (double *) args[16], &sz[16],
		 (double *) args[17], &sz[17]);

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /*******************/
      /* function type 2 */
      /*******************/
    case 2:
      {				/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* no zero crossing */
	if (block->ztyp == 0)
	  {
	    loc2 = (ScicosF2) loc;
	    (*loc2) (flag, &block->nevprt, t, block->xd, block->x, &block->nx,
		     block->z, &block->nz,
		     block->evout, &block->nevout, block->rpar, &block->nrpar,
		     block->ipar, &block->nipar, (double **) block->inptr,
		     block->insz, &block->nin,
		     (double **) block->outptr, block->outsz, &block->nout);
	  }
	/* with zero crossing */
	else
	  {
	    loc2z = (ScicosF2z) loc;
	    (*loc2z) (flag, &block->nevprt, t, block->xd, block->x,
		      &block->nx, block->z, &block->nz, block->evout,
		      &block->nevout, block->rpar, &block->nrpar, block->ipar,
		      &block->nipar, (double **) block->inptr, block->insz,
		      &block->nin, (double **) block->outptr, block->outsz,
		      &block->nout, block->g, &block->ng);
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /*******************/
      /* function type 4 */
      /*******************/
    case 4:
      {				/* get pointer of the function type 4 */
	loc4 = (ScicosF4) loc;

	(*loc4) (block, *flag);

	break;
      }

      /***********************/
      /* function type 10001 */
      /***********************/
    case 10001:
      {				/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* implicit block one entry for each input or output */
	for (in = 0; in < block->nin; in++)
	  {
	    args[in] = block->inptr[in];
	    sz[in] = block->insz[in];
	  }
	for (out = 0; out < block->nout; out++)
	  {
	    args[in + out] = block->outptr[out];
	    sz[in + out] = block->outsz[out];
	  }
	/* with zero crossing */
	if (block->ztyp > 0)
	  {
	    args[block->nin + block->nout] = block->g;
	    sz[block->nin + block->nout] = block->ng;
	  }

	loci1 = (ScicosFi) loc;
	(*loci1) (flag, &block->nevprt, t, block->res, block->xd, block->x,
		  &block->nx, block->z, &block->nz,
		  block->evout, &block->nevout, block->rpar, &block->nrpar,
		  block->ipar, &block->nipar,
		  (double *) args[0], &sz[0],
		  (double *) args[1], &sz[1], (double *) args[2], &sz[2],
		  (double *) args[3], &sz[3], (double *) args[4], &sz[4],
		  (double *) args[5], &sz[5], (double *) args[6], &sz[6],
		  (double *) args[7], &sz[7], (double *) args[8], &sz[8],
		  (double *) args[9], &sz[9], (double *) args[10], &sz[10],
		  (double *) args[11], &sz[11], (double *) args[12], &sz[12],
		  (double *) args[13], &sz[13], (double *) args[14], &sz[14],
		  (double *) args[15], &sz[15], (double *) args[16], &sz[16],
		  (double *) args[17], &sz[17]);

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /***********************/
      /* function type 10002 */
      /***********************/
    case 10002:
      {				/* This is for compatibility */
	/* jroot is returned in g for old type */
	if (block->nevprt < 0)
	  {
	    for (j = 0; j < block->ng; ++j)
	      {
		block->g[j] = (double) block->jroot[j];
	      }
	  }

	/* implicit block, inputs and outputs given by a table of pointers */
	/* no zero crossing */
	if (block->ztyp == 0)
	  {
	    loci2 = (ScicosFi2) loc;
	    (*loci2) (flag, &block->nevprt, t, block->res,
		      block->xd, block->x, &block->nx,
		      block->z, &block->nz,
		      block->evout, &block->nevout, block->rpar,
		      &block->nrpar, block->ipar, &block->nipar,
		      (double **) block->inptr, block->insz, &block->nin,
		      (double **) block->outptr, block->outsz, &block->nout);
	  }
	/* with zero crossing */
	else
	  {
	    loci2z = (ScicosFi2z) loc;
	    (*loci2z) (flag, &block->nevprt, t, block->res,
		       block->xd, block->x, &block->nx,
		       block->z, &block->nz,
		       block->evout, &block->nevout, block->rpar,
		       &block->nrpar, block->ipar, &block->nipar,
		       (double **) block->inptr, block->insz, &block->nin,
		       (double **) block->outptr, block->outsz, &block->nout,
		       block->g, &block->ng);
	  }

	/* adjust values of output register */
	for (in = 0; in < block->nevout; ++in)
	  {
	    block->evout[in] = block->evout[in] - *t;
	  }

	break;
      }

      /***********************/
      /* function type 10004 */
      /***********************/
    case 10004:
      {				/* get pointer of the function type 4 */
	loc4 = (ScicosF4) loc;

	(*loc4) (block, *flag);

	break;
      }

      /***********/
      /* default */
      /***********/
    default:
      {
	Sciprintf ("Undefined Function type\n");
	*flag = -1000;
	return;			/* exit */
      }
    }

  /* Implicit Solver & explicit block & flag==0 */
  /* adjust continuous state vector after call */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      block->xd = ptr_d;
      if (flagi != 7)
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->res[k] = block->res[k] - block->xd[k];
	    }
	}
      else
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->xd[k] = block->res[k];
	    }
	}
    }

  /* debug block */
  if (cosd > 1)
    {
      if (Scicos->sim.debug_block > -1)
	{
	  if (*flag < 0)
	    return;		/* error in block */
	  if (cosd != 3)
	    Sciprintf ("Leaving block %d \n", Scicos->params.curblk);
	  call_debug_scicos (block, flag, flagi, Scicos->sim.debug_block);
	  /*call_debug_scicos(flag,kf,flagi,Scicos->sim.debug_block); */
	}
    }
}				/* callf */


void call_debug_scicos (scicos_block * block, int *flag, int flagi,
			int deb_blk)
{
  voidf loc;
  int solver = Scicos->params.solver, k;
  ScicosF4 loc4;
  double *ptr_d = NULL;

  Scicos->params.debug_counter += 1;
  Scicos->params.scsptr = Blocks[deb_blk].scsptr; 
  Scicos->params.scsptr_flag = Blocks[deb_blk].scsptr_flag;

  loc = Blocks[deb_blk].funpt;	/* GLOBAL */
  loc4 = (ScicosF4) loc;

  /* continuous state */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      ptr_d = block->xd;
      block->xd = block->res;
    }
  fprintf (stderr, "In the block=%d  %d %d %p  loc=%p\n", deb_blk, flagi,
	   *flag, block, loc);

  (*loc4) (block, *flag);
  fprintf (stderr, "Out the block=%d  %d %d %p \n", deb_blk, flagi, *flag,
	   block);

  /* Implicit Solver & explicit block & flag==0 */
  /* adjust continuous state vector after call */
  if (solver == 100 && block->type < 10000 && *flag == 0)
    {
      block->xd = ptr_d;
      if (flagi != 7)
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->res[k] = block->res[k] - block->xd[k];
	    }
	}
      else
	{
	  for (k = 0; k < block->nx; k++)
	    {
	      block->xd[k] = block->res[k];
	    }
	}
    }

  if (*flag < 0)
    Sciprintf ("Error in the Debug block \n");
}				/* call_debug_scicos */

/* simblk: used by lsodar2 
 */

int lsodar2_simblk (const int *neq1, const double *t, double *xc,
		    double *xcdot, void *param)
{
  double c_b14 = 0.;
  int nantest = 0, c1 = 1, i;
  nsp_dset (neq1, &c_b14, xcdot, &c1);
  C2F (ierode).iero = 0;
  Sfcallerid = callerid_.fcallerid;
  *ierr = 0;
  odoit (t, xc, xcdot, xcdot);
  C2F (ierode).iero = *ierr;
  if (*ierr == 0)
    {
      for (i = 0; i < *neq1; i++)
	{			/* NaN checking */
	  if ((xcdot[i] - xcdot[i] != 0))
	    {
	      Sciprintf("Warning: The computing function #%d returns a NaN/Inf",
			i);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  C2F (ierode).iero = -1;
	  return 0;		/* recoverable error; */
	}
    }


  return 0;
}

void DP5simblk (unsigned n, double t, double *x, double *y, void *udata)
{
  DOPRI5_mem *dopri5_mem = NULL;
  dopri5_mem = ((User_DP5_data *) udata)->dopri5_mem;
  DP5_Get_fcallerid (dopri5_mem, &Sfcallerid);

  C2F (ierode).iero = 0;
  *ierr = 0;
  odoit (&t, x, y, y);
  C2F (ierode).iero = *ierr;

  return;
}


int CVsimblk (double t, N_Vector yy, N_Vector yp, void *f_data)
{
  double c_b14 = 0.;
  double tx, *x, *xd;
  int i, nantest, c1 = 1;
  void *cvode_mem;

  cvode_mem = ((User_CV_data) f_data)->cvode_mem;
  CVodeGetfcallerid (cvode_mem, &Sfcallerid);

  tx = (double) t;
  x = (double *) NV_DATA_S (yy);
  xd = (double *) NV_DATA_S (yp);

  /*C2F(simblk)(neq, &tx, x, xd); */
  nsp_dset (Scicos->params.neq, &c_b14, xd, &c1);
  C2F (ierode).iero = 0;
  *ierr = 0;
  odoit (&tx, x, xd, xd);
  C2F (ierode).iero = *ierr;

  if (*ierr == 0)
    {
      nantest = 0;
      for (i = 0; i < *Scicos->params.neq; i++)
	{			/* NaN checking */
	  if ((xd[i] - xd[i] != 0))
	    {
	      Sciprintf("Warning: The computing function #%d returns a NaN/Inf",
			i);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	return 349;		/* recoverable error; */
    }

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */

}				/* simblk */

/* grblk */

int lsodar2_grblk (const int *neq1, const double *t, double *xc,
		   const int *ng1, double *g, double *param)
{
  C2F (ierode).iero = 0;
  *ierr = 0;
  zdoit (t, xc, xc, (double *) g);

  C2F (ierode).iero = *ierr;
  return 0;
}

int DP5grblk (unsigned n, double t, double *xc, double *g, void *udata)
{
  double tx = 0;
  /*DOPRI5_mem *dopri5_mem=NULL;
    dopri5_mem = ((User_DP5_data*) udata)->dopri5_mem; */
  tx = t;
  C2F (ierode).iero = 0;
  *ierr = 0;
  zdoit (&tx, xc, xc, (double *) g);

  C2F (ierode).iero = *ierr;
  return 0;
}

int CVgrblk (double t, N_Vector yy, double *gout, void *g_data)
{
  double tx, *x;
  int jj, nantest;

  tx = (double) t;
  x = (double *) NV_DATA_S (yy);

  lsodar2_grblk (Scicos->params.neq, &tx, x, &Scicos->sim.ng, (double *) gout,
		 NULL);

  if (*ierr == 0)
    {
      nantest = 0;
      for (jj = 0; jj < Scicos->sim.ng; jj++)
	if (gout[jj] - gout[jj] != 0)
	  {
	    Sciprintf("Warning: The zero_crossing function #%d returns a NaN/Inf",
		      jj);
	    nantest = 1;
	    break;
	  }			/* NaN checking */
      if (nantest == 1)
	return 350;		/* recoverable error; */
    }
  C2F (ierode).iero = *ierr;

  return 0;
}				/* grblk */

/* simblkdaskr */
int simblkdaskr (double tres, N_Vector yy, N_Vector yp, N_Vector resval,
		 void *rdata)
{
  int c1 = 1;
  double tx;
  double *xc, *xcdot, *residual;
  double alpha;
  void *ida_mem;

  User_IDA_data ida_data;

  double hh;
  int qlast;
  int jj, flag, nantest;

  ida_data = (User_IDA_data) rdata;
  ida_mem = ida_data->ida_mem;
  IDAGetfcallerid (ida_mem, &Sfcallerid);

  if (!areModesFixed (block))
    {
      /* Just to update mode in a very special case, i.e., when initialization using modes fails.
         in this case, we relax all modes and try again one more time.
      */
      zdoit (&tx, NV_DATA_S (yy), NV_DATA_S (yp), (double *) ida_data->gwork);
    }


  hh = SUNDIALS_ZERO;
  flag = IDAGetCurrentStep (ida_mem, &hh);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  qlast = 0;
  flag = IDAGetCurrentOrder (ida_mem, &qlast);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  alpha = SUNDIALS_ZERO;
  for (jj = 0; jj < qlast; jj++)
    alpha = alpha - SUNDIALS_ONE / (jj + 1);
  if (hh != 0)
    CJ = -alpha / hh;
  else
    {
      *ierr = 217;
      return (*ierr);
    }
  for (jj = 0; jj < *Scicos->params.neq; jj++)
    {
      // alpha[jj]=CI;
      Scicos->sim.beta[jj] = CJ;
    }

  xc = (double *) NV_DATA_S (yy);
  xcdot = (double *) NV_DATA_S (yp);
  residual = (double *) NV_DATA_S (resval);
  tx = (double) tres;

  C2F (dcopy) (Scicos->params.neq, xcdot, &c1, residual, &c1);
  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&tx, xc, xcdot, residual);

  C2F (ierode).iero = *ierr;

  if (*ierr == 0)
    {
      nantest = 0;
      for (jj = 0; jj < *Scicos->params.neq; jj++)
	if (residual[jj] - residual[jj] != 0)
	  {			/* NaN checking */
	    /* Sciprintf("\nWarning: The residual function #%d returns a NaN",jj); */
	    nantest = 1;
	    break;
	  }
      if (nantest == 1)
	return 257;		/* recoverable error; */
    }

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */
}				/* simblkdaskr */


int grblkdaskr (double t, N_Vector yy, N_Vector yp, double *gout,void *g_data)
{
  double tx;
  int jj, nantest;

  tx = (double) t;

  *ierr = 0;
  C2F (ierode).iero = 0;
  zdoit (&tx, NV_DATA_S (yy), NV_DATA_S (yp), (double *) gout);
  if (*ierr == 0)
    {
      nantest = 0;		/* NaN checking */
      for (jj = 0; jj < Scicos->sim.ng; jj++)
	{
	  if (gout[jj] - gout[jj] != 0)
	    {
	      Sciprintf("Warning: The zero-crossing function #%d returns a NaN",
			jj);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  return 258;		/* recoverable error; */
	}
    }
  C2F (ierode).iero = *ierr;
  return (*ierr);
}				/* grblkdaskr */




void addevs (double t, int *evtnb, int *ierr1)
{
  static int i, j;
  /* Function Body */
  *ierr1 = 0;
  if (evtspt[-1+*evtnb] != -1)
    {
      if ((evtspt[-1+*evtnb] == 0) && (*pointi == *evtnb))
	{
	  Scicos->sim.tevts[-1+*evtnb] = t;
	  return;
	}
      else
	{
	  if (*pointi == *evtnb)
	    {
	      *pointi = evtspt[-1+*evtnb];	/* remove from chain */
	    }
	  else
	    {
	      i = *pointi;
	      while (*evtnb != evtspt[-1+i])
		{
		  i = evtspt[-1+i];
		}
	      evtspt[-1+i] = evtspt[-1+*evtnb];	/* remove old evtnb from chain */
	      if (TCritWarning == 0)
		{
		  Sciprintf("Warning:an event is reprogrammed at t=%g by removing another",
			    t);
		  Sciprintf("\t(already programmed) event. There may be an error in");
		  Sciprintf("\tyour model. Please check your model\n");
		  TCritWarning = 1;
		}
	      do_cold_restart ();	/* the erased event could be a critical
					   event, so do_cold_restart is added to
					   refresh the critical event table */
	    }
	  evtspt[-1+*evtnb] = 0;
	  Scicos->sim.tevts[-1+*evtnb] = t;
	}
    }
  else
    {
      evtspt[-1+*evtnb] = 0;
      Scicos->sim.tevts[-1+*evtnb] = t;
    }
  if (*pointi == 0)
    {
      *pointi = *evtnb;
      return;
    }
  if (t < Scicos->sim.tevts[-1+*pointi])
    {
      evtspt[-1+*evtnb] = *pointi;
      *pointi = *evtnb;
      return;
    }
  i = *pointi;

 L100:
  if (evtspt[-1+i] == 0)
    {
      evtspt[-1+i] = *evtnb;
      return;
    }
  if (t >= Scicos->sim.tevts[-1+evtspt[-1+i]])
    {
      j = evtspt[-1+i];
      if (evtspt[-1+j] == 0)
	{
	  evtspt[-1+j] = *evtnb;
	  return;
	}
      i = j;
      goto L100;
    }
  else
    {
      evtspt[-1+*evtnb] = evtspt[-1+i];
      evtspt[-1+i] = *evtnb;
    }
}				/* addevs */

/* Subroutine putevs */
void putevs (const double *t, int *evtnb, int *ierr1)
{
  /* Function Body */
  *ierr1 = 0;
  if (evtspt[-1+*evtnb] != -1)
    {
      *ierr1 = 1;
      return;
    }
  else
    {
      evtspt[-1+*evtnb] = 0;
      Scicos->sim.tevts[-1+*evtnb] = *t;
    }
  if (*pointi == 0)
    {
      *pointi = *evtnb;
      return;
    }
  evtspt[-1+*evtnb] = *pointi;
  *pointi = *evtnb;
}				/* putevs */

/* Subroutine idoit */
void idoit (double *told)
{	
  /* initialisation (propagation of constant blocks outputs) */
  /*     Copyright INRIA */

  int i2;
  int flag;
  int i, j;
  int ierr1;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("idoit: %f\n", *told);

  flag = 1;
  for (j = 0; j < Scicos->sim.niord; j++)
    {
      kf = &Scicos->sim.iord[j];
      Scicos->params.curblk = *kf;	/* */
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt = Scicos->sim.iord[j + (Scicos->sim.niord)];
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}				/* idoit_ */

/* Subroutine doit */
void doit (double *told)
{				/* propagation of blocks outputs on discrete activations */
  /*     Copyright INRIA */

  int i, i2;
  int flag, nord;
  int ierr1;
  int ii, kever;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("doit: %f\n", *told);

  kever = *pointi;
  *pointi = evtspt[-1+kever];
  evtspt[-1+kever] = -1;

  nord = Scicos->sim.ordptr[kever] - Scicos->sim.ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }

  for (ii = Scicos->sim.ordptr[kever - 1];
       ii <= Scicos->sim.ordptr[kever] - 1; ii++)
    {
      kf = &Scicos->sim.ordclk[ii - 1];
      Scicos->params.curblk = *kf;
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt =
	    Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}				/* doit_ */

/* Subroutine cdoit */
void cdoit (double *told)
{
  /* propagation of continuous blocks outputs */
  /*     Copyright INRIA */
  int i2;
  int flag;
  int ierr1;
  int i, j;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("cdoit: %f\n", *told);

  /* Function Body */
  for (j = 0; j < (Scicos->sim.ncord); j++)
    {
      kf = &Scicos->sim.cord[j];
      Scicos->params.curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = Scicos->sim.cord[j + (Scicos->sim.ncord)];
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      doit (told);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}				/* cdoit_ */

/* Subroutine ddoit */
void ddoit (double *told)
{				/* update states & event out on discrete activations */
  /*     Copyright INRIA */
  int i2, j;
  int flag, kiwa;
  int i, i3, ierr1;
  int ii, keve;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("ddoit(): %f\n", *told);

  /* Function Body */
  kiwa = 0;
  edoit (told, &kiwa);
  if (*ierr != 0)
    {
      return;
    }

  /* update continuous and discrete states on event */
  if (kiwa == 0)
    {
      return;
    }
  for (i = 0; i < kiwa; i++)
    {
      keve = iwa[i];
      if (Scicos->sim.critev[-1+keve] != 0)
	{
	  Scicos->params.hot = 0;
	}
      i2 = Scicos->sim.ordptr[keve] - 1;
      for (ii = Scicos->sim.ordptr[keve - 1]; ii <= i2; ii++)
	{
	  kf = &Scicos->sim.ordclk[ii - 1];
	  Scicos->params.curblk = *kf;
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	    }

	  Blocks[*kf - 1].nevprt =
	    Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1];

	  if (Blocks[*kf - 1].nevout > 0)
	    {
	      if (Scicos->sim.funtyp[*kf - 1] >= 0)
		{
		  /* initialize evout */
		  for (j = 0; j < Blocks[*kf - 1].nevout; j++)
		    {
		      Blocks[*kf - 1].evout[j] = -1;
		    }
		  flag = 3;

		  if (Blocks[*kf - 1].nevprt > 0)
		    {		/* if event has continuous origin don't call */
		      callf (told, &Blocks[*kf - 1], &flag);
		      if (flag < 0)
			{
			  *ierr = 5 - flag;
			  return;
			}
		    }

		  for (j = 0; j < Blocks[*kf - 1].nevout; j++)
		    {
		      if (Blocks[*kf - 1].evout[j] >= 0.)
			{
			  i3 = j + Scicos->sim.clkptr[*kf - 1];
			  addevs (Blocks[*kf - 1].evout[j] + (*told), &i3,
				  &ierr1);
			  if (ierr1 != 0)
			    {
			      /* event conflict */
			      *ierr = 3;
			      return;
			    }
			}
		    }
		}
	    }

	  if (Blocks[*kf - 1].nevprt > 0)
	    {
	      if (Blocks[*kf - 1].nx + Blocks[*kf - 1].nz +
		  Blocks[*kf - 1].noz > 0 || *Blocks[*kf - 1].work != NULL)
		{
		  /*  if a hidden state exists, must also call (for new scope eg)  */
		  /*  to avoid calling non-real activations */
		  flag = 2;
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	    }
	  else
	    {
	      if (*Blocks[*kf - 1].work != NULL)
		{
		  flag = 2;
		  Blocks[*kf - 1].nevprt = 0;	/* in case some hidden continuous blocks need updating */
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	    }
	}
    }
}				/* ddoit_ */

/* Subroutine edoit */
void edoit (double *told, int *kiwa)
{				/* update blocks output on discrete activations */
  /*     Copyright INRIA */

  int i2;
  int flag;
  int ierr1, i;
  int kever, ii;
  int *kf;
  int nord;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("edoit(): %f\n", *told);

  /* Function Body */
  kever = *pointi;

  *pointi = evtspt[-1+kever];
  evtspt[-1+kever] = -1;

  nord = Scicos->sim.ordptr[kever] - Scicos->sim.ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }
  iwa[*kiwa] = kever;
  ++(*kiwa);
  for (ii = Scicos->sim.ordptr[kever - 1];
       ii <= Scicos->sim.ordptr[kever] - 1; ii++)
    {
      kf = &Scicos->sim.ordclk[ii - 1];
      Scicos->params.curblk = *kf;

      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	    }

	  Blocks[*kf - 1].nevprt =
	    Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);

	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      i = synchro_nev (*kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      edoit (told, kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }
}				/* edoit_ */

/* Subroutine odoit */
void odoit (const double *told, double *xt, double *xtd, double *residual)
{
  /* update blocks derivative of continuous time block */
  /*     Copyright INRIA */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("odoit(): %f\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < (Scicos->sim.noord); jj++)
    {
      kf = &Scicos->sim.oord[jj];
      Scicos->params.curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
	}

      Blocks[*kf - 1].nevprt = Scicos->sim.oord[jj + (Scicos->sim.noord)];
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      if (Blocks[*kf - 1].nmode > 0)
		{
		  i2 =
		    Blocks[*kf - 1].mode[0] + Scicos->sim.clkptr[*kf - 1] - 1;
		}
	      else
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
		}
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }

  /*  update states derivatives */
  for (ii = 0; ii < (Scicos->sim.noord); ii++)
    {
      kf = &Scicos->sim.oord[ii];
      Scicos->params.curblk = *kf;
      if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	{
	  /* work tests if a hidden state exists, used for delay block */
	  switch (Scicos->params.phase)
	    {
	    case 0:
	    case 1:
	      flag = 2;
	      Blocks[*kf - 1].nevprt = 0;
	      break;
	    case 2:
	    default:
	      flag = 0;
	      Blocks[*kf - 1].nevprt =
		Scicos->sim.oord[ii + (Scicos->sim.noord)];
	      break;
	    }

	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
	    }
	  callf (told, &Blocks[*kf - 1], &flag);

	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = iwa[i];
      for (ii = Scicos->sim.ordptr[keve - 1];
	   ii <= Scicos->sim.ordptr[keve] - 1; ii++)
	{
	  kf = &Scicos->sim.ordclk[ii - 1];
	  Scicos->params.curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	    {
	      /* work tests if a hidden state exists */
	      switch (Scicos->params.phase)
		{
		case 0:
		case 1:
		  flag = 2;
		  Blocks[*kf - 1].nevprt = 0;
		  break;
		case 2:
		default:
		  flag = 0;
		  Blocks[*kf - 1].nevprt =
		    Scicos->sim.oord[ii + (Scicos->sim.noord)];
		  break;
		}
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt =
		Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
	      callf (told, &Blocks[*kf - 1], &flag);

	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}				/* odoit_ */

/* Subroutine reinitdoit */
void reinitdoit (double *told)
{				/* update blocks xproperties of continuous time block */
  /*     Copyright INRIA */

  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("reinitdoit(): %f\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < (Scicos->sim.noord); jj++)
    {
      kf = &Scicos->sim.oord[jj];
      Scicos->params.curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = Scicos->sim.oord[jj + (Scicos->sim.noord)];
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0 && Scicos->sim.funtyp[*kf - 1] < 0)
	{
	  i = synchro_nev (*kf, ierr);
	  if (*ierr != 0)
	    {
	      return;
	    }
	  if (Blocks[*kf - 1].nmode > 0)
	    {
	      Blocks[*kf - 1].mode[0] = i;
	    }
	  i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	  putevs (told, &i2, &ierr1);
	  if (ierr1 != 0)
	    {
	      /* event conflict */
	      *ierr = 3;
	      return;
	    }
	  doit (told);
	  if (*ierr != 0)
	    {
	      return;
	    }
	}
    }

  /* re-initialize */
  for (ii = 0; ii < (Scicos->sim.noord); ii++)
    {
      kf = &Scicos->sim.oord[ii];
      Scicos->params.curblk = *kf;
      if (Blocks[*kf - 1].nx > 0)
	{
	  flag = 7;
	  Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].res = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].nevprt = Scicos->sim.oord[ii + (Scicos->sim.noord)];
	  Blocks[*kf - 1].xprop = &Scicos->sim.xprop[-1 + xptr[*kf - 1]];
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = iwa[i];
      for (ii = Scicos->sim.ordptr[keve - 1];
	   ii <= Scicos->sim.ordptr[keve] - 1; ii++)
	{
	  kf = &Scicos->sim.ordclk[ii - 1];
	  Scicos->params.curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      flag = 7;
	      Blocks[*kf - 1].x = &Scicos->sim.x[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].res = &Scicos->sim.xd[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].nevprt =
		Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
	      Blocks[*kf - 1].xprop = &Scicos->sim.xprop[-1 + xptr[*kf - 1]];
	      callf (told, &Blocks[*kf - 1], &flag);
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}				/* reinitdoit_ */

/* Subroutine ozdoit */
void ozdoit (const double *told, double *xt, double *xtd, int *kiwa)
{				/* update blocks output of continuous time block on discrete activations */
  /*     Copyright INRIA */

  int i2;
  int flag, nord;
  int ierr1, i;
  int ii, kever;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("ozdoit(): %f\n", *told);

  /* Function Body */
  kever = *pointi;
  *pointi = evtspt[-1+kever];
  evtspt[-1+kever] = -1;

  nord = Scicos->sim.ordptr[kever] - Scicos->sim.ordptr[kever - 1];
  if (nord == 0)
    {
      return;
    }
  iwa[*kiwa] = kever;
  ++(*kiwa);

  for (ii = Scicos->sim.ordptr[kever - 1];
       ii <= Scicos->sim.ordptr[kever] - 1; ii++)
    {
      kf = &Scicos->sim.ordclk[ii - 1];
      Scicos->params.curblk = *kf;
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  /* continuous state */
	  if (Blocks[*kf - 1].nx > 0)
	    {
	      Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
	      Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
	    }
	  Blocks[*kf - 1].nevprt =
	    Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      if (Scicos->params.phase == 1 || Blocks[*kf - 1].nmode == 0)
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		}
	      else
		{
		  i = Blocks[*kf - 1].mode[0];
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, kiwa);
	    }
	}
    }
}				/* ozdoit_ */

/* Subroutine zdoit */
void zdoit (const double *told, double *xt, double *xtd, double *g)
{				/* update blocks zcross of continuous time block  */
  /*     Copyright INRIA */
  int i2;
  int flag, keve, kiwa;
  int ierr1, i, j;
  int ii, jj;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("zdoit(): %f\n", *told);

  /* Function Body */
  for (i = 0; i < (Scicos->sim.ng); i++)
    {
      g[i] = 0.;
    }

  kiwa = 0;
  for (jj = 0; jj < (Scicos->sim.nzord); jj++)
    {
      kf = &Scicos->sim.zord[jj];
      Scicos->params.curblk = *kf;
      /* continuous state */
      if (Blocks[*kf - 1].nx > 0)
	{
	  Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
	  Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
	}
      Blocks[*kf - 1].nevprt = Scicos->sim.zord[jj + (Scicos->sim.nzord)];

      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      /* Initialize tvec */
      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      if (Scicos->params.phase == 1 || Blocks[*kf - 1].nmode == 0)
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		}
	      else
		{
		  i = Blocks[*kf - 1].mode[0];
		}
	      i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	      if (*ierr != 0)
		{
		  return;
		}
	    }
	}
    }

  /* update zero crossing surfaces */
  for (ii = 0; ii < (Scicos->sim.nzord); ii++)
    {
      kf = &Scicos->sim.zord[ii];
      Scicos->params.curblk = *kf;
      if (Blocks[*kf - 1].ng > 0)
	{
	  /* update g array ptr */
	  Blocks[*kf - 1].g = &g[Scicos->sim.zcptr[*kf - 1] - 1];
	  if (Scicos->sim.funtyp[*kf - 1] > 0)
	    {
	      flag = 9;
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt =
		Scicos->sim.zord[ii + (Scicos->sim.nzord)];
	      callf (told, &Blocks[*kf - 1], &flag);
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	  else
	    {
	      j = synchro_g_nev (g, *kf, ierr);
	      if (*ierr != 0)
		{
		  return;
		}
	      if ((Scicos->params.phase == 1) && (Blocks[*kf - 1].nmode > 0))
		{
		  Blocks[*kf - 1].mode[0] = j;
		}
	    }

	  // Blocks[*kf-1].g = &Scicos->sim.g[Scicos->sim.zcptr[*kf]-1];

	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = iwa[i];
      for (ii = Scicos->sim.ordptr[keve - 1];
	   ii <= Scicos->sim.ordptr[keve] - 1; ii++)
	{
	  kf = &Scicos->sim.ordclk[ii - 1];
	  Scicos->params.curblk = *kf;
	  if (Blocks[*kf - 1].ng > 0)
	    {
	      /* update g array ptr */
	      Blocks[*kf - 1].g = &g[Scicos->sim.zcptr[*kf - 1] - 1];
	      if (Scicos->sim.funtyp[*kf - 1] > 0)
		{
		  flag = 9;
		  /* continuous state */
		  if (Blocks[*kf - 1].nx > 0)
		    {
		      Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		    }
		  Blocks[*kf - 1].nevprt =
		    Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
		  callf (told, &Blocks[*kf - 1], &flag);
		  if (flag < 0)
		    {
		      *ierr = 5 - flag;
		      return;
		    }
		}
	      else
		{
		  j = synchro_g_nev (g, *kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  if ((Scicos->params.phase == 1)
		      && (Blocks[*kf - 1].nmode > 0))
		    {
		      Blocks[*kf - 1].mode[0] = j;
		    }
		}

	      //Blocks[*kf-1].g = &Scicos->sim.g[Scicos->sim.zcptr[*kf]-1];
	    }
	}
    }
}				/* zdoit_ */

/* Subroutine Jdoit */
void Jdoit (double *told, double *xt, double *xtd, double *residual, int *job)
{				/* update blocks jacobian of continuous time block  */
  /*     Copyright INRIA */

  int i2;
  int flag, keve, kiwa;
  int ierr1, i;
  int ii, jj;
  int *kf;

  if ((Scicos->params.debug >= 1) && (Scicos->params.debug != 3))
    Sciprintf ("Jdoit: %f\n", *told);

  /* Function Body */
  kiwa = 0;
  for (jj = 0; jj < (Scicos->sim.noord); jj++)
    {
      kf = &Scicos->sim.oord[jj];
      Scicos->params.curblk = *kf;
      Blocks[*kf - 1].nevprt = Scicos->sim.oord[jj + (Scicos->sim.noord)];
      if (Scicos->sim.funtyp[*kf - 1] > -1)
	{
	  flag = 1;
	  /* applying desired output */
	  if ((*job == 2) && (Scicos->sim.oord[jj] == AJacobian_block))
	    {
	    }
	  else
	    /* continuous state */
	    if (Blocks[*kf - 1].nx > 0)
	      {
		Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
	      }

	  callf (told, &Blocks[*kf - 1], &flag);
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}

      if (Blocks[*kf - 1].nevout > 0)
	{
	  if (Scicos->sim.funtyp[*kf - 1] < 0)
	    {
	      if (Blocks[*kf - 1].nmode > 0)
		{
		  i2 =
		    Blocks[*kf - 1].mode[0] + Scicos->sim.clkptr[*kf - 1] - 1;
		}
	      else
		{
		  i = synchro_nev (*kf, ierr);
		  if (*ierr != 0)
		    {
		      return;
		    }
		  i2 = i + Scicos->sim.clkptr[*kf - 1] - 1;
		}
	      putevs (told, &i2, &ierr1);
	      if (ierr1 != 0)
		{
		  /* event conflict */
		  *ierr = 3;
		  return;
		}
	      ozdoit (told, xt, xtd, &kiwa);
	    }
	}
    }

  /* update states derivatives */
  for (ii = 0; ii < (Scicos->sim.noord); ii++)
    {
      kf = &Scicos->sim.oord[ii];
      Scicos->params.curblk = *kf;
      if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	{
	  /* work tests if a hidden state exists, used for delay block */
	  flag = 0;
	  if (((*job == 1) && (Scicos->sim.oord[ii] == AJacobian_block))
	      || (*job != 1))
	    {
	      if (*job == 1)
		flag = 10;
	      /* continuous state */
	      if (Blocks[*kf - 1].nx > 0)
		{
		  Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		  Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
		}
	      Blocks[*kf - 1].nevprt =
		Scicos->sim.oord[ii + (Scicos->sim.noord)];
	      callf (told, &Blocks[*kf - 1], &flag);
	    }
	  if (flag < 0)
	    {
	      *ierr = 5 - flag;
	      return;
	    }
	}
    }

  for (i = 0; i < kiwa; i++)
    {
      keve = iwa[i];
      for (ii = Scicos->sim.ordptr[keve - 1];
	   ii <= Scicos->sim.ordptr[keve] - 1; ii++)
	{
	  kf = &Scicos->sim.ordclk[ii - 1];
	  Scicos->params.curblk = *kf;
	  if (Blocks[*kf - 1].nx > 0 || *Blocks[*kf - 1].work != NULL)
	    {
	      /* work tests if a hidden state exists */
	      flag = 0;
	      if (((*job == 1)
		   && (Scicos->sim.oord[ii - 1] == AJacobian_block))
		  || (*job != 1))
		{
		  if (*job == 1)
		    flag = 10;
		  /* continuous state */
		  if (Blocks[*kf - 1].nx > 0)
		    {
		      Blocks[*kf - 1].x = &xt[xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].xd = &xtd[xptr[*kf - 1] - 1];
		      Blocks[*kf - 1].res = &residual[xptr[*kf - 1] - 1];
		    }
		  Blocks[*kf - 1].nevprt =
		    Abs (Scicos->sim.ordclk[ii + (Scicos->sim.nordclk) - 1]);
		  callf (told, &Blocks[*kf - 1], &flag);
		}
	      if (flag < 0)
		{
		  *ierr = 5 - flag;
		  return;
		}
	    }
	}
    }
}				/* Jdoit_ */

/* Subroutine synchro_nev */

int synchro_nev (int kf, int *ierr)
{
  /* synchro blocks computation  */
  /*     Copyright INRIA */
  SCSREAL_COP *outtbdptr;	/*to store double of outtb */
  SCSINT8_COP *outtbcptr;	/*to store int8 of outtb */
  SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
  SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
  SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
  SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
  SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */

  int cond;
  int i = 0;			/* return 0 by default */

  /* variable for param */
  int *funtyp = Scicos->sim.funtyp;
  int *inplnk = Scicos->sim.inplnk;
  int *inpptr = Scicos->sim.inpptr;

  /* if-then-else blk */
  if (funtyp[kf - 1] == -1)
    {
      switch (outtbtyp[-1 + inplnk[inpptr[kf - 1] - 1]])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbcptr <= 0);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbsptr <= 0);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtblptr <= 0);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbucptr <= 0);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbusptr <= 0);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  cond = (*outtbulptr <= 0);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
      if (cond)
	{
	  i = 2;
	}
      else
	{
	  i = 1;
	}
    }
  /* eselect blk */
  else if (funtyp[kf - 1] == -2)
    {
      switch (outtbtyp[-1 + inplnk[inpptr[kf - 1] - 1]])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbcptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbsptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtblptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbucptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbusptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  i = Max (Min ((int) *outtbulptr, Blocks[kf - 1].nevout), 1);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
    }
  return i;
}				/* synchro_nev */

/* Subroutine synchro_g_nev */

int synchro_g_nev (double *g, int kf, int *ierr)
{
  /* synchro blocks with zcross computation  */
  /*     Copyright INRIA */
  SCSREAL_COP *outtbdptr;	/*to store double of outtb */
  SCSINT8_COP *outtbcptr;	/*to store int8 of outtb */
  SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
  SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
  SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
  SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
  SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */

  int cond;
  int i = 0;			/* return 0 by default */
  int jj = 0;

  /* variable for param */
  int *funtyp = Scicos->sim.funtyp;
  int *inplnk = Scicos->sim.inplnk;
  int *inpptr = Scicos->sim.inpptr;
  int *zcptr = Scicos->sim.zcptr;

  /* if-then-else blk */
  if (funtyp[kf - 1] == -1)
    {
      switch (outtbtyp[-1 + inplnk[inpptr[kf - 1] - 1]])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = *outtbdptr;
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = *outtbdptr;
	  cond = (*outtbdptr <= 0.);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtbcptr;
	  cond = (*outtbcptr <= 0);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtbsptr;
	  cond = (*outtbsptr <= 0);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtblptr;
	  cond = (*outtblptr <= 0);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtbucptr;
	  cond = (*outtbucptr <= 0);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtbusptr;
	  cond = (*outtbusptr <= 0);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  g[zcptr[kf - 1] - 1] = (double) *outtbulptr;
	  cond = (*outtbulptr <= 0);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
      if (cond)
	{
	  i = 2;
	}
      else
	{
	  i = 1;
	}
    }
  /* eselect blk */
  else if (funtyp[kf - 1] == -2)
    {
      switch (outtbtyp[-1 + inplnk[inpptr[kf - 1] - 1]])
	{
	case SCSREAL_N:
	  outtbdptr =
	    (SCSREAL_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] = *outtbdptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSCOMPLEX_N:
	  outtbdptr =
	    (SCSCOMPLEX_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] = *outtbdptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbdptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT8_N:
	  outtbcptr =
	    (SCSINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtbcptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbcptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT16_N:
	  outtbsptr =
	    (SCSINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtbsptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbsptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSINT32_N:
	  outtblptr =
	    (SCSINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtblptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtblptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT8_N:
	  outtbucptr =
	    (SCSUINT8_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtbucptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbucptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT16_N:
	  outtbusptr =
	    (SCSUINT16_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtbusptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbusptr, Blocks[kf - 1].nevout), 1);
	  break;

	case SCSUINT32_N:
	  outtbulptr =
	    (SCSUINT32_COP *) outtbptr[-1 + inplnk[inpptr[kf - 1] - 1]];
	  for (jj = 0; jj < Blocks[kf - 1].nevout - 1; jj++)
	    {
	      g[zcptr[kf - 1] - 1 + jj] =
		(double) *outtbulptr - (double) (jj + 2);
	    }
	  i = Max (Min ((int) *outtbulptr, Blocks[kf - 1].nevout), 1);
	  break;

	default:		/* Add a message here */
	  *ierr = 25;
	  return 0;
	  break;
	}
    }
  return i;
}				/* synchro_g_nev */



/* Subroutine funnum */
#if 0
int C2F (funnum) (char *fname)
{
  int i = 0, ln;
  int loc = -1;
  while (tabsim[i].name != (char *) NULL)
    {
      if (strcmp (fname, tabsim[i].name) == 0)
	return (i + 1);
      i++;
    }
  ln = (int) strlen (fname);
  C2F (iislink) (fname, &loc);
  C2F (iislink) (fname, &loc);
  if (loc >= 0)
    return (ntabsim + (int) loc + 1);
  return (0);
}
#endif

int scicos_get_phase_simulation ()
{
  return Scicos->params.phase;
}

/* 
   CVODE: 2,3 -> Functional iterations
   CVODE: 4,5 -> Newton iterations
   CVODE: 1  -> The very first call to block at cold-start
   CVODE: -2  -> (numerical-Jacobian) 
   CVODE: -3  -> CVYddNorm (Second derivative computing)
   CVODE: -4  -> (CVDoErrorTest)
   ------------------------------------------------
   IDA: 10,11 -> Newton iteration
   IDA: -12   -> (numerical-Jacobian) integration
   IDA: 13   -> (IDAnlsIC) consistent initial condition computation 
   IDA: -14   -> (IDAfnorm) consistent initial condition computation 
   IDA: -15   -> (numerical-Jacobian) consistent initial condition computation
   IDA: -17   -> (Jacobians) Analytical Jacobian defined in scicos.c
   IDA: -18   -> (reinitdoit) called by reinitdoit
*/

int scicos_get_fcaller_id ()
{
  return Sfcallerid;
}

void scicos_do_cold_restart ()
{
  Scicos->params.hot = 0;
  return;
}

int scicos_what_is_hot ()
{
  return Scicos->params.hot;
}

/* get_scicos_time : return the current
 * simulation time
 */
double scicos_get_scicos_time ()
{
  return scicos_time;
}

double scicos_get_final_time ()
{
  return *tf;
}

/* get_block_number : return the current
 * block number
 */

int scicos_get_block_number ()
{
  return Scicos->params.curblk;
}

/* set_block_number : set the current
 * block number
 */

void set_block_number (int block_number)
{
  Scicos->params.curblk = block_number;
}

/* set_block_error : set an error number
 * for block_error
 */

void scicos_set_block_error (int err)
{
  if (block_error != NULL)
    *block_error = err;
  return;
}

/* Coserror : copy an error message
 * in coserr.buf an set block_error to -5 
 */

void Coserror (char *fmt, ...)
{
  static char buf[4096];
  int retval;
  va_list ap;
  va_start (ap, fmt);
  retval = vsnprintf (buf, 4095, fmt, ap);
  if (retval == -1)
    buf[0] = '\0';
  va_end (ap);
  Scierror("%s",buf);
  /* coserror use error number 10 */
  *block_error = -5;
}

/* get_block_error: get the block error
 * number
 */

int scicos_get_block_error (void)
{
  return *block_error;
}

void scicos_end_scicos_sim (void)
{
  Scicos->params.halt = 2;
  return;
}

/* get_pointer_xproperty */

int *scicos_get_pointer_xproperty (void)
{
  return &Scicos->sim.xprop[-1 + xptr[Scicos->params.curblk - 1]];
}

/* get_Npointer_xproperty */

int scicos_get_npointer_xproperty (void)
{
  return Blocks[Scicos->params.curblk - 1].nx;
}

/* set_pointer_xproperty */

void scicos_set_pointer_xproperty (int *pointer)
{
  int i;
  for (i = 0; i < Blocks[Scicos->params.curblk - 1].nx; i++)
    {
      Blocks[Scicos->params.curblk - 1].xprop[i] = pointer[i];
    }
  return;
}

char *scicos_get_label (int kf)
{
  return Blocks[kf - 1].label;
}

void Set_Jacobian_flag (int flag)
{
  Jacobian_Flag = flag;
  return;
}

double Get_Jacobian_ci (void)
{
  return CI;
}

double Get_Jacobian_cj (void)
{
  return CJ;
}


double Get_Scicos_SQUR (void)
{
  return SQuround;
}

/*-----------------------------------------------------------------------*/

int Jacobians (long int Neq, double tt, N_Vector yy, N_Vector yp,
	       N_Vector resvec, double cj, void *jdata, DenseMat Jacque,
	       N_Vector tempv1, N_Vector tempv2, N_Vector tempv3)
{
  double ttx;
  double *xc, *xcdot, *residual;
  /*  char chr; */
  int i, j, n, nx, ni, no, nb, m, flag;
  double *RX, *Fx, *Fu, *Gx, *Gu, *ERR1, *ERR2;
  double *Hx, *Hu, *Kx, *Ku, *HuGx, *FuKx, *FuKuGx, *HuGuKx;
  double ysave;
  int job;
  double **y = NULL;
  double **u = NULL;
  /*  taill1= 3*n+(n+ni)*(n+no)+nx(2*nx+ni+2*m+no)+m*(2*m+no+ni)+2*ni*no */
  double inc, inc_inv, xi, xpi, srur;
  double *Jacque_col;

  double hh;
  N_Vector ewt;
  double *ewt_data;
  void *ida_mem;
  User_IDA_data ida_data;

  *ierr = 0;

  ida_data = (User_IDA_data) jdata;
  ewt = ida_data->ewt;
  ida_mem = ida_data->ida_mem;

  flag = IDAGetCurrentStep (ida_data->ida_mem, &hh);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  flag = IDAGetErrWeights (ida_data->ida_mem, ewt);
  if (flag < 0)
    {
      *ierr = 200 + (-flag);
      return (*ierr);
    };

  ewt_data = NV_DATA_S (ewt);
  xc = (double *) N_VGetArrayPointer (yy);
  xcdot = (double *) N_VGetArrayPointer (yp);
  /*residual=(double *) NV_DATA_S(resvec); */
  ttx = (double) tt;
  CJ = (double) cj;
  for (j = 0; j < Neq; j++)
    {
      // alpha[j]=CI;
      Scicos->sim.beta[j] = CJ;
    }

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  if (AJacobian_block > 0)
    {
      nx = Blocks[AJacobian_block - 1].nx;	/* quant on est là cela signifie que AJacobian_block>0 */
      no = Blocks[AJacobian_block - 1].nout;
      ni = Blocks[AJacobian_block - 1].nin;
      y = (double **) Blocks[AJacobian_block - 1].outptr;	/*for compatibility */
      u = (double **) Blocks[AJacobian_block - 1].inptr;	/*warning pointer of y and u have changed to void ** */
    }
  else
    {
      nx = 0;
      no = 0;
      ni = 0;
    }
  n = Neq;
  nb = Scicos->sim.nblk;
  m = n - nx;

  residual = (double *) ida_data->rwork;
  ERR1 = residual + n;
  ERR2 = ERR1 + n;
  RX = ERR2 + n;
  Fx = RX + (n + ni) * (n + no);	/* car (nx+ni)*(nx+no) peut etre > `a n*n */
  Fu = Fx + nx * nx;
  Gx = Fu + nx * ni;
  Gu = Gx + no * nx;
  Hx = Gu + no * ni;
  Hu = Hx + m * m;
  Kx = Hu + m * no;
  Ku = Kx + ni * m;
  HuGx = Ku + ni * no;
  FuKx = HuGx + m * nx;
  FuKuGx = FuKx + nx * m;
  HuGuKx = FuKuGx + nx * nx;
  /* HuGuKx+m*m; =>  m*m=size of HuGuKx */
  /* ------------------ Numerical Jacobian--->> Hx,Kx */
  Sfcallerid = -17;
  /* read residuals; */
  job = 0;
  Jdoit (&ttx, xc, xcdot, residual, &job);
  if (*ierr < 0)
    return -1;

  /* "residual" already contains the current residual, 
     so the first call to Jdoit can be remoevd */

  for (i = 0; i < m; i++)
    for (j = 0; j < ni; j++)
      Kx[j + i * ni] = u[j][0];

  for (i = 0; i < m; i++)
    {
      xi = xc[i];
      xpi = xcdot[i];
      inc =
	MAX (srur * MAX (ABS (xi), ABS (hh * xpi)),
	     SUNDIALS_ONE / ewt_data[i]);
      if (hh * xpi < SUNDIALS_ZERO)
	inc = -inc;
      inc = (xi + inc) - xi;

      if (CI == 0)
	{
	  inc = MAX (srur * ABS (hh * xpi), SUNDIALS_ONE);
	  if (hh * xpi < SUNDIALS_ZERO)
	    inc = -inc;
	  inc = (xpi + inc) - xpi;
	}
      xc[i] += CI * inc;
      xcdot[i] += CJ * inc;
      /*a= Max(Abs(H[0]*xcdot[i]),Abs(1.0/Ewt[i]));
	b= Max(1.0,Abs(xc[i]));
	del=SQUR[0]*Max(a,b);    */
      job = 0;			/* read residuals */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hx[m * i + j] = (ERR2[j] - residual[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Kx[j + i * ni] = (u[j][0] - Kx[j + i * ni]) * inc_inv;
      xc[i] = xi;
      xcdot[i] = xpi;
    }
  /*----- Numerical Jacobian--->> Hu,Ku */

  if ((AJacobian_block == 0))
    {
      for (j = 0; j < m; j++)
	{
	  Jacque_col = DENSE_COL (Jacque, j);
	  for (i = 0; i < m; i++)
	    {
	      Jacque_col[i] = Hx[i + j * m];
	    }
	}
      C2F (ierode).iero = *ierr;
      return 0;
    }
  /****------------------***/
  job = 0;
  Jdoit (&ttx, xc, xcdot, ERR1, &job);
  for (i = 0; i < no; i++)
    for (j = 0; j < ni; j++)
      Ku[j + i * ni] = u[j][0];

  for (i = 0; i < no; i++)
    {
      ysave = y[i][0];
      inc = srur * MAX (ABS (ysave), 1);
      inc = (ysave + inc) - ysave;
      /*del=SQUR[0]* Max(1.0,Abs(y[i][0]));
	del=(y[i][0]+del)-y[i][0]; */
      y[i][0] += inc;
      job = 2;			/* applying y[i][0] to the output of imp block */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hu[m * i + j] = (ERR2[j] - ERR1[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Ku[j + i * ni] = (u[j][0] - Ku[j + i * ni]) * inc_inv;
      y[i][0] = ysave;
    }
  /*----------------------------------------------*/
  for (j = 0; j < nx * nx + nx * ni + no * nx + no * ni; j++)
    Fx[j] = 0.0;		/* Filling up FX:Fu:Gx:Gu */
  job = 1;			/* read jacobian through flag=10; */
  Jdoit (&ttx, xc, xcdot, &Fx[-m], &job);	/* Filling up the FX:Fu:Gx:Gu */
  if (*ierr != 0)
    {
      Sciprintf ("error in Jacobian");
      return -1;
    }
  /*-------------------------------------------------*/

  Multp (Fu, Ku, RX, nx, ni, ni, no);
  Multp (RX, Gx, FuKuGx, nx, no, no, nx);

  for (j = 0; j < nx; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j + m);
      for (i = 0; i < nx; i++)
	{
	  Jacque_col[i + m] = Fx[i + j * nx] + FuKuGx[i + j * nx];
	}
    }

  Multp (Hu, Gx, HuGx, m, no, no, nx);

  for (i = 0; i < nx; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i + m);
      for (j = 0; j < m; j++)
	{
	  Jacque_col[j] = HuGx[j + i * m];
	}
    }

  Multp (Fu, Kx, FuKx, nx, ni, ni, m);

  for (i = 0; i < m; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i);
      for (j = 0; j < nx; j++)
	{
	  Jacque_col[j + m] = FuKx[j + i * nx];
	}
    }


  Multp (Hu, Gu, RX, m, no, no, ni);
  Multp (RX, Kx, HuGuKx, m, ni, ni, m);

  for (j = 0; j < m; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j);
      for (i = 0; i < m; i++)
	{
	  Jacque_col[i] = Hx[i + j * m] + HuGuKx[i + j * m];
	}
    }

  /*  chr='Z';   printf("\n t=%g",ttx); DISP(Z,n,n,chr); */
  C2F (ierode).iero = *ierr;
  return 0;

}

/*----------------------------------------------------*/
void Multp (A, B, R, ra, ca, rb, cb)
  double *A, *B, *R;
int ra, rb, ca, cb;
{
  int i, j, k;
  /*if (ca!=rb) Sciprintf("Error: in matrix multiplication"); */
  for (i = 0; i < ra; i++)
    for (j = 0; j < cb; j++)
      {
	R[i + ra * j] = 0.0;
	for (k = 0; k < ca; k++)
	  R[i + ra * j] += A[i + k * ra] * B[k + j * rb];
      }
  return;
}

/*----------------------------------------------------*/
/* void DISP(A,ra ,ca,name)
   double *A;
   int ra,ca,*name;
   {
   int i,j;
   Sciprintf("\n");
   for (i=0;i<ca;i++)
   for (j=0;j<ra;j++){
   if (A[j+i*ra]!=0) 
   Sciprintf(" %s(%d,%d)=%g;",name,j+1,i+1,A[j+i*ra]);
   }; 
   }*/
/* Jacobian*/


/*----------------------------------------------------------*/
int read_xml_initial_states (int nvar, const char *xmlfile, char **ids,
			     double *svars)
{
  ezxml_t model, elements;
  int result, i;
  double vr;

  if (nvar == 0)
    return 0;
  result = 0;
  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") != 0)
	{
	  result = 1;
	  break;
	}
    }
  if (result == 0)
    return 0;

  model = ezxml_parse_file (xmlfile);

  if (model == NULL)
    {
      Sciprintf ("Error: cannot find '%s'  \n", xmlfile);
      return -1;		/* file does not existe */
    }

  elements = ezxml_child (model, "elements");
  for (i = 0; i < nvar; i++)
    {
      vr = 0.0;
      result = read_id (&elements, ids[i], &vr);
      if (result == 1)
	svars[i] = vr;
      else
	Sciprintf ("Error: cannot find \"%s\" in the XML file\n", ids[i]);
    }
  ezxml_free (model);
  return 0;
}

int read_id (ezxml_t * elements, char *id, double *value)
{
  char V1[100], V2[100];
  int ok, i, ln;

  if (strcmp (id, "") == 0)
    return 0;
  ok = ezxml_search_in_child (elements, id, V1);
  if (ok == 0)
    {
      /*Sciprintf("Cannot find: %s=%s  \n",id,V1);      */
      return 0;
    }
  else
    {
      if (Convert_number (V1, value) != 0)
	{
	  ln = (int) (strlen (V1));
	  if (ln > 2)
	    {
	      for (i = 1; i <= ln - 2; i++)
		V2[i - 1] = V1[i];
	      V2[ln - 2] = '\0';
	      ok = read_id (elements, V2, value);
	      return ok;
	    }
	  else
	    return 0;
	}
      else
	{
	  /*      printf("\n ---->>>%s= %g",V1,*value); */
	  return 1;
	}
    }
}


int Convert_number (char *s, double *out)
{
  char *endp;
  double d;
  long int l;
  d = strtod (s, &endp);
  if (s != endp && *endp == '\0')
    {
      /*    printf("  It's a float with value %g ", d); */
      *out = d;
      return 0;
    }
  else
    {
      l = strtol (s, &endp, 0);
      if (s != endp && *endp == '\0')
	{
	  /*printf("  It's an int with value %ld ", 1); */
	  *out = (double) l;
	  return 0;
	}
      else
	{
	  /*printf("  string "); */
	  return -1;
	}
    }
}

/*----------------------------------------------------------*/
int write_xml_states (int nvar, const char *xmlfile, char **ids, double *x)
{
  ezxml_t model, elements;
  int result, i, err = 0;
  FILE *fd;
  char *s;
  char **xv;

  if (nvar == 0)
    return 0;
  result = 0;
  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") != 0)
	{
	  result = 1;
	  break;
	}
    }
  if (result == 0)
    return 0;

  xv = malloc (nvar * sizeof (char *));
  for (i = 0; i < nvar; i++)
    {
      xv[i] = malloc (nvar * 100 * sizeof (char));
      sprintf (xv[i], "%g", x[i]);
    }

  model = ezxml_parse_file (xmlfile);
  if (model == NULL)
    {
      Sciprintf("Error: cannot find '%s'  \n", xmlfile);
      return -1;		/* file does not existe */
    }

  elements = ezxml_child (model, "elements");

  for (i = 0; i < nvar; i++)
    {
      if (strcmp (ids[i], "") == 0)
	continue;
      result = ezxml_write_in_child (&elements, ids[i], xv[i]);
      if (result == 0)
	{
	  Sciprintf ("Error: cannot find \"%s\" in the XML file \n", ids[i]);
	  /* err= -1; *//* Varaible does not existe */
	}
    }

  s = ezxml_toxml (model);
  ezxml_free (model);

  fd = fopen (xmlfile, "wb");
  if (fd < 0)
    {
      Sciprintf("Error: cannot write to '%s'\n", xmlfile);
      return -3;		/* cannot write to file */
    }

  fputs (s, fd);
  fclose (fd);

  return err;
}

#if 0
static int fx_ (double *x, *residual);
{
  double *xdot, t;
  xdot = x + *Scicos->params.neq;
  t = 0;
  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&t, x, xdot, residual);
  C2F (ierode).iero = *ierr;
  return (*ierr);
}
#endif


#if 0
static int rho_ (double *a, double *L, double *x, double *rho, double *rpar,
	  int *ipar)
{
  int i, N = *Scicos->params.neq;
  fx_ (x, rho);
  for (i = 0; i < N; i++)
    rho[i] += (-1 + *L) * a[i];
  return 0;
}
#endif

#if 0
static int rhojac_ (double *a, double *lambda, double *x, double *jac, int *col,
	     double *rpar, int *ipar)
{
  /* MATRIX [d_RHO/d_LAMBDA, d_RHO/d_X_col] */
  int j, N;
  double *work;
  int job;
  double inc, inc_inv, xi, srur;
  N = *Scicos->params.neq;
  if (*col == 1)
    {
      for (j = 0; j < N; j++)
	jac[j] = a[j];
    }
  else
    {
      if ((work = (double *) malloc (N * sizeof (double))) == NULL)
	{
	  *ierr = 10000;
	  return *ierr;
	}
      rho_ (a, lambda, x, work, rpar, ipar);
      srur = 1e-10;
      xi = x[*col - 2];
      inc = srur * Max (Abs (xi), 1);
      inc = (xi + inc) - xi;
      x[*col - 2] += inc;

      job = 0;
      rho_ (a, lambda, x, jac, rpar, ipar);
      inc_inv = 1.0 / inc;

      for (j = 0; j < N; j++)
	jac[j] = (jac[j] - work[j]) * inc_inv;

      x[*col - 2] = xi;
      free (work);
    }
  return 0;
}
#endif

#if 0
static int hfjac_ (double *x, double *jac, int *col)
{
  int N, j;
  double *work;
  double *xdot;
  int job;
  double inc, inc_inv, xi, srur;

  N = *Scicos->params.neq;
  if ((work = (double *) MALLOC (N * sizeof (double))) == NULL)
    {
      *ierr = 10000;
      return *ierr;
    }
  srur = (double) RSqrt (UNIT_ROUNDOFF);

  fx_ (x, work);

  xi = x[*col - 1];
  inc = srur * MAX (ABS (xi), 1);
  inc = (xi + inc) - xi;
  x[*col - 1] += inc;
  xdot = x + N;

  job = 0;
  fx_ (x, jac);
  if (*ierr < 0)
    return *ierr;

  inc_inv = SUNDIALS_ONE / inc;

  for (j = 0; j < N; j++)
    jac[j] = (jac[j] - work[j]) * inc_inv;

  x[*col - 1] = xi;

  FREE (work);
  return 0;
}
#endif

static int simblkKinsol (N_Vector yy, N_Vector resval, void *rdata)
{
  int jj, nantest;

  int N = *Scicos->params.neq;
  double t = 0;
  double *xc = (double *) NV_DATA_S (yy);
  double *residual = (double *) NV_DATA_S (resval);
  User_IDA_data kin_data;
  double *xcdot = xc;
  kin_data = (User_IDA_data) rdata;

  if (Scicos->params.phase == 1)
    if (Scicos->sim.ng > 0 && nmod > 0)
      zdoit (&t, xc, xcdot, Scicos->sim.g);

  *ierr = 0;
  C2F (ierode).iero = 0;
  odoit (&t, xc, xcdot, residual);

  if (*ierr == 0)
    {
      nantest = 0;		/* NaN checking */
      for (jj = 0; jj < N; jj++)
	{
	  if (residual[jj] - residual[jj] != 0)
	    {
	      Sciprintf
		("Warning: The initialization system #%d returns a NaN/Inf\n",
		 jj);
	      nantest = 1;
	      break;
	    }
	}
      if (nantest == 1)
	{
	  return 258;		/* recoverable error; */
	}
    }
  C2F (ierode).iero = *ierr;

  return (Abs (*ierr));		/* ierr>0 recoverable error; ierr>0 unrecoverable error; ierr=0: ok */
}

static int CallKinsol (double *told)
{
  static int otimer = 0;
  int ntimer, inxsci;
  N_Vector y = NULL, yscale = NULL, fscale = NULL;
  double *fsdata, *ysdata;
  int N, strategy, i, j, k, status;
  void *kin_mem = NULL;
  int Jn, Jnx, Jno, Jni, Jactaille;
  double reltol, abstol;
  int *Mode_save;
  int Mode_change;
  int N_iters;
  User_KIN_data kin_data = NULL;

  N = *Scicos->params.neq;
  if (N <= 0)
    return 0;

  inxsci = nsp_check_events_activated ();
  reltol = (double) Scicos->params.rtol;
  abstol = (double) Scicos->params.Atol;

  Mode_save = NULL;
  if (nmod > 0)
    {
      if ((Mode_save = MALLOC (sizeof (int) * nmod)) == NULL)
	{
	  *ierr = 10000;
	  return -1;
	}
    }

  y = N_VNewEmpty_Serial (N);
  if (y == NULL)
    {
      FREE (Mode_save);
      return -1;
    }
  NV_DATA_S (y) = Scicos->sim.x;
  yscale = N_VNew_Serial (N);
  if (yscale == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      return -1;
    }
  fscale = N_VNew_Serial (N);
  if (fscale == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      return -1;
    }
  ysdata = NV_DATA_S (yscale);
  fsdata = NV_DATA_S (fscale);
  for (j = 0; j < N; j++)
    {
      ysdata[j] = 1.0;
      fsdata[j] = 1.0;
    }

  kin_mem = KINCreate ();
  if (kin_mem == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      return -1;
    }

  if ((kin_data = (User_KIN_data) MALLOC (sizeof (User_KIN_data))) == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      KINFree (&kin_mem);
      return -1;
    }
  kin_data->uscale = ysdata;

  /*Jacobian_Flag=0; */
  if (AJacobian_block > 0)
    {				
      /* set by the block with A-Jac in flag-4 using Set_Jacobian_flag(1); */
      Jn = *Scicos->params.neq;
      Jnx = Blocks[AJacobian_block - 1].nx;
      Jno = Blocks[AJacobian_block - 1].nout;
      Jni = Blocks[AJacobian_block - 1].nin;
    }
  else
    {
      Jn = *Scicos->params.neq;
      Jnx = 0;
      Jno = 0;
      Jni = 0;
    }
  Jactaille =
    3 * Jn + (Jn + Jni) * (Jn + Jno) + Jnx * (Jni + 2 * Jn + Jno) + (Jn -
								     Jnx) *
    (2 * (Jn - Jnx) + Jno + Jni) + 2 * Jni * Jno;

  if ((kin_data->rwork =
       (double *) MALLOC (Jactaille * sizeof (double))) == NULL)
    {
      FREE (Mode_save);
      N_VDestroy_Serial (y);
      N_VDestroy_Serial (yscale);
      N_VDestroy_Serial (fscale);
      KINFree (&kin_mem);
      FREE (kin_data);
      return -1;
    }
  status = KINMalloc (kin_mem, simblkKinsol, y);
  strategy = KIN_LINESEARCH;	/*KIN_NONE=without LineSearch */
  status = KINDense (kin_mem, N);
  KINDenseSetJacFn (kin_mem, KinJacobians1, kin_data);	/* Using analytical Jacobian */
  status = KINSetNumMaxIters (kin_mem, 200);	/* MaxNumIter=200->2000 */
  status = KINSetRelErrFunc (kin_mem, reltol);	/* FuncRelErr=eps->RTOL */
  status = KINSetMaxSetupCalls (kin_mem, 1);	/* MaxNumSetups=10->1=="Exact Newton" */
  status = KINSetMaxSubSetupCalls (kin_mem, 1);	/* MaxNumSubSetups=5->1 */
  /* status = KINSetNoInitSetup(kin_mem,noInitSetup);  // InitialSetup=true  */
  /* status = KINSetNoMinEps(kin_mem,noMinEps);        // MinBoundEps=true   */
  /* status = KINSetMaxBetaFails(kin_mem,mxnbcf);      // MaxNumBetaFails=10 */
  /* status = KINSetEtaForm(kin_mem,etachoice);        // EtaForm=Type1      */
  /* status = KINSetEtaConstValue(kin_mem,eta); */// Eta=0.1            */
  /* status = KINSetEtaParams(kin_mem,egamma,ealpha);  // EtaGamma=0.9  EtaAlpha=2.0 */
  /* status = KINSetMaxNewtonStep(kin_mem,mxnewtstep); // MaxNewtonStep=0.0  */
  /* status = KINSetFuncNormTol(kin_mem,fnormtol);     // FuncNormTol=eps^(1/3) */
  /* status = KINSetScaledStepTol(kin_mem,scsteptol);  // ScaledStepTol={eps^(2/3) */
  /* xmin =(double) RSqrt(UNIT_ROUNDOFF)*1e6; */
  /*========================================================*/
  Scicos->params.phase = 2;	// modes are fixed
  status = -1;
  N_iters = 10 + Min (nmod * 3, 30);
  for (k = 0; k <= N_iters; k++)
    {				/* loop for mode fixin */
      /*------------KINSOL calls-----------*/
      for (i = 0; i < 4; i++)
	{
	  /*simblkKinsol(y,ffscale,NULL); 
	    for (j=0;j<N;j++)
	    if (ffsdata[j]-ffsdata[j]!=0){
	    Sciprintf("\nWarning: The residual function #%d returns a NaN/Inf",j);
	    freekinsol;*ierr=400-status;C2F(ierode).iero=*ierr; return -1;
	    }
	    for( j=0;j<N;j++){
	    if (Abs(x[j])<=xmin)  xi=xmin;else xi=x[j];
	    if (Abs(ffsdata[j])<=xmin) fi=xmin;else fi=ffsdata[j];
	    ysdata[j]=(5*ysdata[j]+1/Abs(xi))/6;
	    fsdata[j]=(5*fsdata[j]+1/Abs(fi))/6;   
	    } */
	  status = KINSol (kin_mem, y, strategy, yscale, fscale);	/* Calling the Newton Solver */
	  if (status >= 0)
	    break;

	  if (inxsci == TRUE)
	    {
	      /* what follows can modify Scicos->params.halt */
	      ntimer = nsp_stimer ();
	      if (ntimer != otimer)
		{
		  nsp_check_gtk_events ();
		  otimer = ntimer;
		}
	    }
	  if (Scicos->params.halt != 0)
	    {
	      Scicos->params.halt = 0;
	      status = 0;
	      goto end;
	    }
	}
      /*---------end of KINSOL calls-----------*/
      if (Scicos->params.phase == 2)
	{
	  for (j = 0; j < nmod; ++j)
	    {
	      Mode_save[j] = mod[j];
	    }

	  if (Scicos->sim.ng > 0 && nmod > 0)
	    {
	      Scicos->params.phase = 1;	// updating the modes
	      zdoit (told, Scicos->sim.x, Scicos->sim.xd, Scicos->sim.g);
	      if (*ierr != 0)
		{
		  C2F (ierode).iero = *ierr;
		  status = -1;
		  goto end;
		}
	      Scicos->params.phase = 2;
	    }

	  Mode_change = 0;
	  for (j = 0; j < nmod; ++j)
	    {
	      if (Mode_save[j] != mod[j])
		{
		  Mode_change = 1;
		  break;
		}
	    }
	  if (Mode_change == 0 && status >= 0)
	    break;		/*Successful termination */
	  if (status < 0 && k >= N_iters - 0)
	    {			/*Retrying with Scicos->params.phase=1 */
	      Scicos->params.phase = 1;
	    }
	}
      else
	{
	  /* when calling with Scicos->params.phase=1 */
	  if (status >= 0)
	    break;
	}

    }				/* end of the loop for mode fixing */

  if (status < 0)
    {
      *ierr = 400 - status;
      C2F (ierode).iero = *ierr;
    }
 end:
  FREE (Mode_save);
  N_VDestroy_Serial (y);
  N_VDestroy_Serial (fscale);
  N_VDestroy_Serial (yscale);
  FREE (kin_data->rwork);
  FREE (kin_data);
  KINFree (&kin_mem);
  return status;
}


int KinJacobians0 (long int n, DenseMat J, N_Vector u, N_Vector fu,
		   void *jac_data, N_Vector tmp1, N_Vector tmp2)
{
  double inc, inc_inv, ujsaved, ujscale, sign;
  double *tmp2_data, *u_data, *uscale_data;
  N_Vector ftemp, jthCol;
  long int j;
  int retval;
  double srur;
  User_KIN_data data;
  data = (User_KIN_data) jac_data;
  uscale_data = data->uscale;

  tmp2_data = N_VGetArrayPointer (tmp2);
  ftemp = tmp1;
  jthCol = tmp2;

  u_data = N_VGetArrayPointer (u);
  //uscale_data = N_VGetArrayPointer(uscale);

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  for (j = 0; j < n; j++)
    {

      N_VSetArrayPointer (DENSE_COL (J, j), jthCol);

      ujsaved = u_data[j];
      ujscale = SUNDIALS_ONE / uscale_data[j];
      sign = (ujsaved >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (ujsaved), ujscale) * sign;
      u_data[j] += inc;

      retval = simblkKinsol (u, ftemp, jac_data);
      if (retval != 0)
	return (-1);

      u_data[j] = ujsaved;

      inc_inv = SUNDIALS_ONE / inc;
      N_VLinearSum (inc_inv, ftemp, -inc_inv, fu, jthCol);

    }
  N_VSetArrayPointer (tmp2_data, tmp2);

  return (0);
}

int KinJacobians1 (long int Neq, DenseMat Jacque, N_Vector yy,
		   N_Vector resvec, void *jac_data, N_Vector tmp1,
		   N_Vector tmp2)
{
  double ttx;
  double *xc, *xcdot = NULL, *residual, *uscale_data, sign;
  int i, j, n, nx, ni, no, nb, m;
  double *RX, *Fx, *Fu, *Gx, *Gu, *ERR1, *ERR2;
  double *Hx, *Hu, *Kx, *Ku, *HuGx, *FuKx, *FuKuGx, *HuGuKx;
  double ysave;
  int job;
  double **y = NULL;
  double **u = NULL;
  /*  taill1= 3*n+(n+ni)*(n+no)+nx(2*nx+ni+2*m+no)+m*(2*m+no+ni)+2*ni*no */
  double inc, inc_inv, xi, ujscale, srur;
  double *Jacque_col;

  User_KIN_data kin_data;
  *ierr = 0;

  kin_data = (User_KIN_data) jac_data;
  uscale_data = kin_data->uscale;

  xc = (double *) N_VGetArrayPointer (yy);
  //residual=(double *) NV_DATA_S(resvec);
  ttx = 0;
  CJ = 0;
  CI = 1.0;
  for (j = 0; j < Neq; j++)
    {
      Scicos->sim.alpha[j] = CI;
      Scicos->sim.beta[j] = CJ;
    }

  srur = (double) RSqrt (UNIT_ROUNDOFF);

  if (AJacobian_block > 0)
    {
      nx = Blocks[AJacobian_block - 1].nx;	/* quant on est là cela signifie que AJacobian_block>0 */
      no = Blocks[AJacobian_block - 1].nout;
      ni = Blocks[AJacobian_block - 1].nin;
      y = (double **) Blocks[AJacobian_block - 1].outptr;	/*for compatibility */
      u = (double **) Blocks[AJacobian_block - 1].inptr;	/*warning pointer of y and u have changed to void ** */
    }
  else
    {
      nx = 0;
      no = 0;
      ni = 0;
    }
  n = Neq;
  nb = Scicos->sim.nblk;
  m = n - nx;

  residual = (double *) kin_data->rwork;
  ERR1 = residual + n;
  ERR2 = ERR1 + n;
  RX = ERR2 + n;
  Fx = RX + (n + ni) * (n + no);	/* car (nx+ni)*(nx+no) peut etre > `a n*n */
  Fu = Fx + nx * nx;
  Gx = Fu + nx * ni;
  Gu = Gx + no * nx;
  Hx = Gu + no * ni;
  Hu = Hx + m * m;
  Kx = Hu + m * no;
  Ku = Kx + ni * m;
  HuGx = Ku + ni * no;
  FuKx = HuGx + m * nx;
  FuKuGx = FuKx + nx * m;
  HuGuKx = FuKuGx + nx * nx;
  /* HuGuKx+m*m; =>  m*m=size of HuGuKx */
  /* ------------------ Numerical Jacobian--->> Hx,Kx */

  /* read residuals; */
  job = 0;
  Jdoit (&ttx, xc, xcdot, residual, &job);
  if (*ierr < 0)
    return -1;

  for (i = 0; i < m; i++)
    for (j = 0; j < ni; j++)
      Kx[j + i * ni] = u[j][0];

  for (i = 0; i < m; i++)
    {
      xi = xc[i];
      ujscale = SUNDIALS_ONE / uscale_data[i];
      sign = (xi >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (xi), ujscale) * sign;
      inc = (xi + inc) - xi;
      xc[i] += inc;

      job = 0;			/* read residuals */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hx[m * i + j] = (ERR2[j] - residual[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Kx[j + i * ni] = (u[j][0] - Kx[j + i * ni]) * inc_inv;
      xc[i] = xi;
    }
  /*----- Numerical Jacobian--->> Hu,Ku */
  if ((AJacobian_block == 0))
    {
      for (j = 0; j < m; j++)
	{
	  Jacque_col = DENSE_COL (Jacque, j);
	  for (i = 0; i < m; i++)
	    {
	      Jacque_col[i] = Hx[i + j * m];
	    }
	}
      C2F (ierode).iero = *ierr;
      return 0;
    }
  /****------------------***/
  job = 0;
  Jdoit (&ttx, xc, xcdot, ERR1, &job);
  for (i = 0; i < no; i++)
    for (j = 0; j < ni; j++)
      Ku[j + i * ni] = u[j][0];

  for (i = 0; i < no; i++)
    {
      ysave = y[i][0];
      sign = (ysave >= SUNDIALS_ZERO) ? SUNDIALS_ONE : -SUNDIALS_ONE;
      inc = srur * Max (ABS (ysave), 1) * sign;
      inc = (ysave + inc) - ysave;
      y[i][0] += inc;
      job = 2;			/* applying y[i][0] to the output of imp block */
      Jdoit (&ttx, xc, xcdot, ERR2, &job);
      if (*ierr < 0)
	return -1;
      inc_inv = SUNDIALS_ONE / inc;
      for (j = 0; j < m; j++)
	Hu[m * i + j] = (ERR2[j] - ERR1[j]) * inc_inv;
      for (j = 0; j < ni; j++)
	Ku[j + i * ni] = (u[j][0] - Ku[j + i * ni]) * inc_inv;
      y[i][0] = ysave;
    }
  /*----------------------------------------------*/
  job = 1;			/* read jacobian through flag=10; */
  for (j = 0; j < nx * nx + nx * ni + no * nx + no * ni; j++)
    Fx[j] = 0.0;		/* Filling up FX:Fu:Gx:Gu */
  Jdoit (&ttx, xc, xcdot, &Fx[-m], &job);	/* Filling up the FX:Fu:Gx:Gu */
  if (*block_error != 0)
    Sciprintf ("Error: in Jacobian");
  /*-------------------------------------------------*/
  Multp (Fu, Ku, RX, nx, ni, ni, no);
  Multp (RX, Gx, FuKuGx, nx, no, no, nx);

  for (j = 0; j < nx; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j + m);
      for (i = 0; i < nx; i++)
	{
	  Jacque_col[i + m] = Fx[i + j * nx] + FuKuGx[i + j * nx];
	}
    }

  Multp (Hu, Gx, HuGx, m, no, no, nx);

  for (i = 0; i < nx; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i + m);
      for (j = 0; j < m; j++)
	{
	  Jacque_col[j] = HuGx[j + i * m];
	}
    }

  Multp (Fu, Kx, FuKx, nx, ni, ni, m);

  for (i = 0; i < m; i++)
    {
      Jacque_col = DENSE_COL (Jacque, i);
      for (j = 0; j < nx; j++)
	{
	  Jacque_col[j + m] = FuKx[j + i * nx];
	}
    }


  Multp (Hu, Gu, RX, m, no, no, ni);
  Multp (RX, Kx, HuGuKx, m, ni, ni, m);

  for (j = 0; j < m; j++)
    {
      Jacque_col = DENSE_COL (Jacque, j);
      for (i = 0; i < m; i++)
	{
	  Jacque_col[i] = Hx[i + j * m] + HuGuKx[i + j * m];
	}
    }

  C2F (ierode).iero = *ierr;
  return 0;
}
