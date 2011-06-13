/* Nsp
 * Copyright (C) 2005-2010 Jean-Philippe Chancelier Enpc/Cermics
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
 * Nsp interfaces for scicos updated for 4.4
 *--------------------------------------------------------------------------*/

#include <math.h>
#include <stdio.h>
#include <string.h>

#include "nsp/machine.h"
#include <nsp/graphics-new/Graphics.h>
#include <nsp/object.h>
#include <nsp/matrix.h>
#include <nsp/imatrix.h>
#include <nsp/smatrix.h>
#include <nsp/hash.h>
#include <nsp/list.h>
#include <nsp/cells.h>
#include <nsp/graphic.h>
#include <nsp/interf.h>
#include "scicos/scicos4.h"


extern void create_scicos_about(void);
static int scicos_fill_gr(scicos_run *r_scicos, NspCells *Gr);


static int int_scicos_about (Stack stack, int rhs, int opt, int lhs)
{
  CheckRhs (-1, 0);
  CheckLhs (-1, 0);
  create_scicos_about();
  return 0;
}

/* 
 * [state,t]=scicosim(state,tcur,tf,sim,'start',tol,graphics) 
 * 
 * sim=tlist(['scs','funs','xptr','zptr','zcptr','inpptr',..
 *           'outptr','inplnk','outlnk','lnkptr','rpar',..
 *	     'rpptr','ipar','ipptr','clkptr','ordptr',..
 *	     'execlk','ordclk','cord','oord','zord',..
 *	     'critev','nb','ztyp','nblk','ndcblk',..
 *	     'subscr','funtyp','iord','labels','modptr'],..
 * 4.4 version: 
 *       ozptr: added (integer array) 
 *       lnkptr: removed
 *       opar: added (list of objects) 
 *       opptr: added (integer array) 
 *        - 5  : sim.ozptr  : column vector of real
 *        - 15 : sim.opar   : list of scilab object
 *        - 16 : sim.opptr  : column vector of real
 * 
 * state=tlist(['xcs','x','z','iz','tevts','evtspt','pointi','outtb'],..
 *               x,z,iz,tevts,evtspt,pointi,outtb)
 * 4.4 version:
 *     oz: list of scilab objects 
 *     outtb: is now a list of scilab objects 
 *     
 * graphic if present is a cell containing graphic objects or %f
 */

static int curblk = 0;		/* kept static to be given to curblock in case of 
				 * error 
				 */

static int int_scicos_sim (Stack stack, int rhs, int opt, int lhs)
{
  scicos_run r_scicos;
  double tcur, tf;
  int i, rep, flag, ierr = 0;
  static char *action_name[] = { "finish", "linear", "run", "start", NULL };
  NspHash *State, *Sim;
  NspMatrix *Msimpar;
  NspCells *Gr=NULL;
  double simpar[7];
  CheckRhs (6, 7);
  CheckLhs (1, 3);
  /* first variable : the state */
  if ((State = GetHashCopy (stack, 1)) == NULLHASH)
    return RET_BUG;
  /* next variables */
  if (GetScalarDouble (stack, 2, &tcur) == FAIL)
    return RET_BUG;
  if (GetScalarDouble (stack, 3, &tf) == FAIL)
    return RET_BUG;
  if ((Sim = GetHashCopy (stack, 4)) == NULLHASH)
    return RET_BUG;
  if ((rep = GetStringInArray (stack, 5, action_name, 1)) == -1)
    return RET_BUG;
  switch (rep)
    {
    case 0:
      flag = 3;
      break;
    case 1:
      flag = 4;
      break;
    case 2:
      flag = 2;
      break;
    case 3:
      flag = 1;
      break;
    }
  /* [atol  rtol ttol, deltat, scale, impl, hmax] */
  if ((Msimpar = GetRealMat (stack, 6)) == NULLMAT)
    return RET_BUG;
  if ( rhs == 7 )
    {
      if ((Gr = GetCells(stack,7))== NULLCELLS) 
	return RET_BUG;
    }

  for (i = Min (Msimpar->mn, 7); i < 7; i++)
    simpar[i] = 0.0;
  for (i = 0; i < Min (Msimpar->mn, 7); i++)
    simpar[i] = Msimpar->R[i];
  
  if (scicos_fill_run (&r_scicos, Sim, State) == FAIL)
    return RET_BUG;

  if (scicos_fill_gr(&r_scicos,Gr) == FAIL) 
    return RET_BUG;

  scicos_main (&r_scicos, &tcur, &tf, simpar, &flag, &ierr);

  /* keep track of last block */
  curblk = Scicos->params.curblk;
  /* back convert variables and free allocated variables */
  scicos_clear_run (&r_scicos);

  Scicos = NULL;

  if (ierr > 0)
    {
      switch (ierr)
	{
	case 1:
	  Scierror ("Error: scheduling problem\n");
	  return RET_BUG;
	case 2:
	  Scierror ("Error: input to zero-crossing stuck on zero\n");
	  return RET_BUG;
	case 6:
	  Scierror
	    ("Error: a block has been called with input out of its domain\n");
	  return RET_BUG;
	case 7:
	  Scierror ("Error: singularity in a block\n");
	  return RET_BUG;
	case 8:
	  Scierror ("Error: block produces an internal error\n");
	  return RET_BUG;
	case 3:
	  Scierror ("Error: event conflict\n");
	  return RET_BUG;
	case 20:
	  Scierror ("Error: initial conditions not converging\n");
	  return RET_BUG;
	case 4:
	  Scierror ("Error: algrebraic loop detected\n");
	  return RET_BUG;
	case 5:
	  Scierror ("Error: cannot allocate memory\n");
	  return RET_BUG;
	case 21:
	  Scierror ("Error: cannot allocate memory in block=" ",i5)\n");
	  return RET_BUG;
	case 33:
	  Scierror ("Error: sliding mode condition, cannot integrate");
	  return RET_BUG;
	default:
	  if (ierr >= 1000)
	    {
	      Scierror ("Error: unknown or erroneous block\n");
	    }
	  else if (ierr >= 100)
	    {
	      int istate = -(ierr - 100);
	      Scierror ("Error: integration problem istate=\"%d\"\n", istate);
	    }
	  else
	    {
	      Scierror ("Error: scicos unexpected error,please report...\n");
	    }
	  return RET_BUG;
	}
    }

  NthObj (1)->ret_pos = 1;
  if (lhs >= 2)
    {
      if (nsp_move_double (stack, 2, tcur) == FAIL)
	return RET_BUG;
    }
  if (lhs >= 3)
    {
      if (nsp_move_double (stack, 3, curblk) == FAIL)
	return RET_BUG;
    }
  return Max (lhs, 1);
}

static int scicos_fill_gr(scicos_run *sr, NspCells *Gr)
{
  int kf;
  scicos_sim *scsim = &sr->sim;
  int nb = scsim->nblk;
  scicos_block *Blocks = sr->Blocks;
  for (kf = 0; kf < scsim->nblk; ++kf)
    {
      Blocks[kf].grobj = NULL;
    }
  if ( Gr == NULL || Gr->mn != scsim->nblk ) return OK;
  for (kf = 0; kf < scsim->nblk; ++kf)
    { 
      if ( Gr->objs[kf] != NULLOBJ && IsGraphic(Gr->objs[kf])) 
	{
	  Blocks[kf].grobj = Gr->objs[kf];
	}
    }
  return OK;
}

static int int_sctree (Stack stack, int rhs, int opt, int lhs)
{
  int iok, nord, nb, i;
  NspMatrix *M[5], *ilord, *ok, *work;
  /* [ord,ok]=sctree(vec,in,depu,outptr,cmatp); */
  /* taille nb et entier lv */
  CheckRhs (5, 5);
  CheckLhs (1, 1);
  for (i = 0; i < 5; i++)
    {
      if ((M[i] = GetRealMatCopy (stack, i + 1)) == NULLMAT)
	return RET_BUG;
      M[i] = Mat2int (M[i]);
    }
  nb = M[0]->mn;
  if ((ilord = nsp_matrix_create (NVOID, 'r', 1, nb)) == NULLMAT)
    return RET_BUG;
  if ((ok = nsp_matrix_create (NVOID, 'r', 1, 1)) == NULLMAT)
    return RET_BUG;
  /* which size ? FIXME */
  if ((work = nsp_matrix_create (NVOID, 'r', 1, nb)) == NULLMAT)
    return RET_BUG;
  scicos_sctree (&nb, (int *) M[0]->R, (int *) M[1]->R, (int *) M[2]->R,
		 (int *) M[3]->R, (int *) M[4]->R, (int *) ilord->R, &nord,
		 &iok, (int *) work->R);
  /* renvoyer un tableau de taille nord copie de ilord */
  ilord->convert = 'i';
  ilord = Mat2double (ilord);
  if (nsp_matrix_resize (ilord, nord, 1) == FAIL)
    return RET_BUG;
  ok->R[0] = iok;
  MoveObj (stack, 1, (NspObject *) ilord);
  if (lhs == 2)
    MoveObj (stack, 2, (NspObject *) ok);
  return Max (lhs, 1);
}


static int int_tree2 (Stack stack, int rhs, int opt, int lhs)
{
  int nord, nmvec, iok, i;
  NspMatrix *M[4], *ipord, *ok;
  CheckRhs (4, 4);
  CheckLhs (2, 2);
  for (i = 0; i < 4; i++)
    {
      if ((M[i] = GetRealMatCopy (stack, i + 1)) == NULLMAT)
	return RET_BUG;
      M[i] = Mat2int (M[i]);
    }
  nmvec = M[0]->mn;
  if ((ipord = nsp_matrix_create (NVOID, 'r', 1, nmvec)) == NULLMAT)
    return RET_BUG;
  if ((ok = nsp_matrix_create (NVOID, 'r', 1, 1)) == NULLMAT)
    return RET_BUG;
  /*
    if(.not.getrhsvar(1,'i',nvec,mvec,ipvec)) return
    if(.not.getrhsvar(2,'i',noin,moin,ipoin)) return
    if(.not.getrhsvar(3,'i',noinr,moinr,ipoinr)) return
    if(.not.getrhsvar(4,'i',ndep,mdep,ipdep)) return
    if(.not.createvar(5,'i',nvec*mvec,1,ipord)) return
    if(.not.createvar(6,'i',1,1,ipok)) return
  */

  scicos_ftree2 (M[0]->I, &nmvec, M[3]->I, M[1]->I, M[2]->I, ipord->I, &nord,
		 &iok);
  ipord->convert = 'i';
  ipord = Mat2double (ipord);
  if (nsp_matrix_resize (ipord, nord, 1) == FAIL)
    return RET_BUG;
  ok->R[0] = iok;
  MoveObj (stack, 1, (NspObject *) ipord);
  if (lhs == 2)
    MoveObj (stack, 2, (NspObject *) ok);
  return Max (lhs, 1);
}

static int int_tree3 (Stack stack, int rhs, int opt, int lhs)
{
  NspMatrix *M[7], *ipord, *ok, *ipkk;
  int i, iok, nord, nb;
  CheckRhs (7, 7);
  CheckLhs (2, 2);
  for (i = 0; i < 7; i++)
    {
      if ((M[i] = GetRealMatCopy (stack, i + 1)) == NULLMAT)
	return RET_BUG;
      M[i] = Mat2int (M[i]);
    }
  nb = M[0]->mn;
  if ((ipord = nsp_matrix_create (NVOID, 'r', 1, nb)) == NULLMAT)
    return RET_BUG;
  if ((ipkk = nsp_matrix_create (NVOID, 'r', 1, nb)) == NULLMAT)
    return RET_BUG;
  scicos_ftree3 (M[0]->I, &M[0]->mn, M[1]->I, M[2]->I, M[3]->I, M[4]->I,
		 M[5]->I, M[6]->I, ipkk->I, ipord->I, &nord, &iok);
  nsp_matrix_destroy (ipkk);
  ipord->convert = 'i';
  ipord = Mat2double (ipord);
  if (nsp_matrix_resize (ipord, nord, 1) == FAIL)
    return RET_BUG;
  MoveObj (stack, 1, (NspObject *) ipord);
  if (lhs == 2)
    {
      if ((ok = nsp_matrix_create (NVOID, 'r', 1, 1)) == NULLMAT)
	return RET_BUG;
      ok->R[0] = iok;
      MoveObj (stack, 2, (NspObject *) ok);
    }

  return Max (lhs, 1);
}

static int int_scicos_ftree4 (Stack stack, int rhs, int opt, int lhs)
{
  NspMatrix *M[5], *ipr1, *ipr2;
  int i, nmd, nr;
  CheckRhs (5, 5);
  CheckLhs (2, 2);
  for (i = 0; i < 5; i++)
    {
      if ((M[i] = GetRealMatCopy (stack, i + 1)) == NULLMAT)
	return RET_BUG;
      M[i] = Mat2int (M[i]);
    }
  nmd = M[3]->mn;
  if ((ipr1 = nsp_matrix_create (NVOID, 'r', 1, nmd)) == NULLMAT)
    return RET_BUG;
  if ((ipr2 = nsp_matrix_create (NVOID, 'r', 1, nmd)) == NULLMAT)
    return RET_BUG;
  ipr1->convert = 'i';
  ipr2->convert = 'i';
  /* scicos_ftree4 does not fill all the values thus we init the arrays */
  for (i = 0; i < nmd; i++)
    {
      ipr1->I[i] = 0;
      ipr2->I[i] = 0;
    }
  scicos_ftree4 (M[0]->I, &M[0]->mn, M[3]->I, &M[3]->n,
		 M[4]->I, M[1]->I, M[2]->I, ipr1->I, ipr2->I, &nr);
  ipr1 = Mat2double (ipr1);
  if (nsp_matrix_resize (ipr1, nr, 1) == FAIL)
    return RET_BUG;
  ipr2 = Mat2double (ipr2);
  if (nsp_matrix_resize (ipr2, nr, 1) == FAIL)
    return RET_BUG;
  MoveObj (stack, 1, (NspObject *) ipr1);
  if (lhs == 2)
    MoveObj (stack, 2, (NspObject *) ipr2);
  return Max (lhs, 1);
}

extern int scicos_debug_level;

static int int_scicos_debug (Stack stack, int rhs, int opt, int lhs)
{
  int debug;
  NspMatrix *M;
  CheckRhs (-1, 1);
  CheckLhs (-1, 1);
  if ((lhs==1) && (rhs==0)) {
    if ((M = nsp_matrix_create (NVOID, 'r', 1, 1)) == NULLMAT)
      return RET_BUG;
    M->R[0] = (double) scicos_debug_level;
    NSP_OBJECT (M)->ret_pos = 1;
    StackStore (stack, (NspObject *) M, 1);
    return 1;
  } else {
    if (GetScalarInt (stack, 1, &debug) == FAIL)
    return RET_BUG;
    scicos_debug_level = debug;
    return 0;
  }
}

int scicos_connection (int *path_out, int *path_in)
{
  /* FIXME : call the routine 
   * under_connection 
   * function ninnout=under_connection(path_out,path_in)
   */
  return 0;
}

int scicos_badconnection (int *path_out, int prt_out, int nout, int *path_in,
			  int prt_in, int nin)
{
  /* FXME : call the routine 
   * bad_connection(path_out,prt_out,nout,path_in,prt_in,nin)
   */
  return 0;
}

int scicos_Message (char *code)
{
  /* FIXME call x_message 
   */
  return 0;
}

/* should only be called when Scicos 
 * is initialized i.e Scicos != NULL
 *
 */

static int int_curblock (Stack stack, int rhs, int opt, int lhs)
{
  NspMatrix *M;
  CheckRhs (-1, 0);
  if ((M = nsp_matrix_create (NVOID, 'r', 1, 1)) == NULLMAT)
    return RET_BUG;
  M->R[0] = (Scicos == NULL) ? curblk : Scicos->params.curblk;
  NSP_OBJECT (M)->ret_pos = 1;
  StackStore (stack, (NspObject *) M, 1);
  return 1;
}

static char *var_names[] =
  { "inplnk", "inpptr", "ipar", "ipptr", "lnkptr", "outlnk",
    "outptr", "outtb", "rpar", "rpptr",
    "x", "xptr", "z", "zptr", NULL
  };

const int reps[] = { 12, 10, 7, 8, 14, 13, 11, 9, 5, 6, 1, 2, 3, 4 };

int int_getscicosvars (Stack stack, int rhs, int opt, int lhs)
{
  double *ptr;
  int ierr, nv, type, i;
  NspMatrix *M;
  int rep;
  CheckRhs (1, 1);
  CheckLhs (1, 1);
  if ((rep = GetStringInArray (stack, 1, var_names, 1)) == -1)
    return RET_BUG;
  ierr = scicos_getscicosvars (reps[rep], &ptr, &nv, &type);
  if (ierr != 0)
    {
      Scierror ("scicosim is not running\n");
      return RET_BUG;
    }
  if ((M = nsp_matrix_create (NVOID, 'r', nv, 1)) == NULLMAT)
    return RET_BUG;
  if (type == 0)
    for (i = 0; i < M->mn; i++)
      M->R[i] = ((int *) ptr)[i];
  else
    for (i = 0; i < M->mn; i++)
      M->R[i] = ptr[i];
  MoveObj (stack, 1, (NspObject *) M);
  return 1;
}

int int_setscicosvars (Stack stack, int rhs, int opt, int lhs)
{
  double *ptr;
  int ierr, nv, type, i, rep;
  NspMatrix *x1;
  CheckRhs (2, 2);
  CheckLhs (1, 1);
  if ((x1 = GetRealMatCopy (stack, 1)) == NULLMAT)
    return RET_BUG;
  if ((rep = GetStringInArray (stack, 2, var_names, 1)) == -1)
    return RET_BUG;
  ierr = scicos_getscicosvars (reps[rep], &ptr, &nv, &type);
  if (ierr != 0)
    {
      Scierror ("scicosim is not running\n");
      return RET_BUG;
    }
  CheckLength (NspFname (stack), 1, x1, nv);
  if (type == 0)
    for (i = 0; i < nv; i++)
      ((int *) ptr)[i] = (int) x1->R[i];
  else
    for (i = 0; i < nv; i++)
      ptr[i] = x1->R[i];
  return 0;
}

/* should only be called when Scicos 
 * is initialized i.e Scicos != NULL
 *
 */
#if 0
int int_getblocklabel (Stack stack, int rhs, int opt, int lhs)
{
  int kf;
  char *label = NULL;
  NspObject *Ob;
  CheckRhs (0, 1);
  CheckLhs (1, 1);
  /*  checking variable scale */
  if (rhs == 1)
    {
      if (GetScalarInt (stack, 1, &kf) == FAIL)
	return RET_BUG;
    }
  else
    {
      if (Scicos == NULL)
	{
	  Scierror ("Error: scicosim is not running\n");
	  return RET_BUG;
	}
      kf = Scicos->params.curblk;
    }
  if (scicos_getscilabel (kf, &label) == FAIL)
    {
      Scierror ("Error: scicosim is not running\n");
      return RET_BUG;
    }
  if ((Ob = (NspObject *) nsp_new_string_obj (NVOID, label, -1)) == NULL)
    return RET_BUG;
  MoveObj (stack, 1, Ob);
  return 1;
}
#endif

static int int_time_scicos (Stack stack, int rhs, int opt, int lhs)
{
  CheckRhs (-1, 0);
  CheckLhs (1, 1);
  if (nsp_move_double (stack, 1, (double) scicos_get_scicos_time ()) == FAIL)
    return RET_BUG;
  return 1;
}

/* v=duplicate(u,count) 
 * returns v=[u(1)*ones(count(1),1);
 *            u(2)*ones(count(2),1);
 *            ...
 */

static int duplicata (int n, const double *v, const double *w, double *ww)
{
  int i, j, k;
  k = 0;
  for (i = 0; i < n; i++)
    {
      for (j = 0; j < (int) w[i]; j++)
	{
	  ww[k] = v[i];
	  k = k + 1;
	}
    }
  return k;
}

static int comp_size (const double *v, int n)
{
  int i;
  int nw = 0;
  for (i = 0; i < n; i++)
    {
      if (v[i] > 0)
	nw += (int) v[i];
    }
  return nw;
}

static int int_duplicate (Stack stack, int rhs, int opt, int lhs)
{
  int nres;
  NspMatrix *A, *B, *Res;
  CheckRhs (2, 2);
  CheckLhs (1, 1);
  if ((A = GetRealMat (stack, 1)) == NULLMAT)
    return RET_BUG;
  if ((B = GetRealMat (stack, 2)) == NULLMAT)
    return RET_BUG;
  if (A->mn == 0)
    {
      if ((Res = nsp_matrix_create (NVOID, 'r', 0, 0)) == NULLMAT)
	return RET_BUG;
      MoveObj (stack, 1, NSP_OBJECT (Res));
      return 1;
    }
  CheckSameDims (NspFname (stack), 1, 2, A, B);
  nres = comp_size (B->R, A->mn);
  if ((Res = nsp_matrix_create (NVOID, 'r', nres, 1)) == NULLMAT)
    return RET_BUG;
  nres = duplicata (A->mn, A->R, B->R, Res->R);
  MoveObj (stack, 1, NSP_OBJECT (Res));
  return 1;
}


/* renvoi le type d'equation get_pointer_xproperty() 
 *	(-1: algebriques, +1 differentielles) 
 */

static int int_xproperty (Stack stack, int rhs, int opt, int lhs)
{
  /* 
     int un;
     extern int* pointer_xproperty;
     extern int n_pointer_xproperty;
     CheckRhs(-1,0);
     CheckLhs(1,1);
     CreateVarFromPtr(1,"i",&n_pointer_xproperty,(un=1,&un),&pointer_xproperty);
     LhsVar(1)=1;
  */
  return 0;
}

/* renvoi la phase de simulation phase=get_phase_simulation() */

static int int_get_phase_simulation (Stack stack, int rhs, int opt, int lhs)
{
  CheckRhs (-1, 0);
  CheckLhs (1, 1);
  if (nsp_move_double (stack, 1, (double) scicos_get_phase_simulation ()) ==
      FAIL)
    return RET_BUG;
  return 1;
}

/* count entries in debug block */

static int int_scicos_debug_count (Stack stack, int rhs, int opt, int lhs)
{
  CheckRhs (-1, 0);
  CheckLhs (1, 1);
  int count = (Scicos == NULL) ? 0 : Scicos->params.debug_counter;
  if (nsp_move_double (stack, 1, (double) count) == FAIL)
    return RET_BUG;
  return 1;
}

/* renvoi le type d'equation get_pointer_xproperty() 
 *	(-1: algebriques, +1 differentielles) 
 */

static int int_setxproperty (Stack stack, int rhs, int opt, int lhs)
{
  int m1;
  CheckRhs (1, 1);
  if (GetScalarInt (stack, 1, &m1) == FAIL)
    return RET_BUG;
  scicos_set_pointer_xproperty (&m1);
  return 0;
}


static int int_setblockerror (Stack stack, int rhs, int opt, int lhs)
{
  int m1;
  CheckRhs (1, 1);
  if (GetScalarInt (stack, 1, &m1) == FAIL)
    return RET_BUG;
  scicos_set_block_error (m1);
  return 0;
}



/* used to build an initialized outtb list
 *
 * [outtb]=buildouttb(lnksz,lnktyp)
 *
 * rhs 1 : lnksz gives the size of object in outtb
 *         can be all int type or double matrix
 *         can have n,2 or 2,n size
 *
 * rhs 2 : lnktyp, gives the type of scilab objetc in outtb
 *         1 : double
 *         2 : complex
 *         3 : int32
 *         4 : int16
 *         5 : int8
 *         6 : uint32
 *         7 : uint16
 *         8 : uint8
 *         else : double
 *         can be all int type or double matrix
 *         can have n,1 or 1,n size
 *
 * lhs 1 : a list of size n
 * 
 */


static int int_buildouttb (Stack stack, int rhs, int opt, int lhs)
{
  int n_lnksz = 0, n_lnktyp = 0, m1, i, j;
  NspList *L;
  NspMatrix *A, *B;
  CheckLhs (0, 1);
  CheckRhs (2, 2);
  if ((A = GetRealMat (stack, 1)) == NULLMAT)
    return RET_BUG;
  if ((B = GetRealMat (stack, 2)) == NULLMAT)
    return RET_BUG;
  if (A->mn == 0)
    {
      /* return empty list */
    }
  if (A->m == 2)
    n_lnksz = A->n;
  else if (A->n == 2)
    n_lnksz = A->m;
  else
    {
      Scierror ("Error: bad dimension for first argument of %s\n",
		NspFname (stack));
      return RET_BUG;
    }

  if (B->m != 1 && B->n != 1)
    {
      Scierror ("Error: second argument of %s should be a vector\n",
		NspFname (stack));
      return RET_BUG;
    }
  n_lnktyp = B->mn;
  if (n_lnksz != n_lnktyp)
    {
      Scierror
	("Error: first and second arguments of %s have incompatible sizes\n",
	 NspFname (stack));
      return RET_BUG;
    }
  /* detect the special case of 2,2 matrix A 
   * which is not considered with 2xn but nx2 
   */
  m1 = A->m;
  if ((A->m == A->n) && (B->m == A->m))
    m1 = -1;

  /* fills the list */
  if ((L = nsp_list_create (NVOID)) == NULLLIST)
    return RET_BUG;
  for (i = 0; i < n_lnktyp; i++)
    {

      NspObject *Obj = NULL;
      int nr = (m1 == 2) ? A->R[2 * i] : A->R[i];
      int nc = (m1 == 2) ? A->R[2 * i + 1] : A->R[i + n_lnktyp];
      int type = B->R[i];
      nsp_itype itype[] =
	{ 0, 0, 0, nsp_gint32, nsp_gint16, nsp_gint8, nsp_guint32,
	  nsp_guint16, nsp_guint8 };
      switch (type)
	{
	case 1:
	  /* Mat(nr,nc) initialized to zero */
	  if ((Obj =
	       (NspObject *) nsp_matrix_create (NVOID, 'r', nr,
						nc)) == NULLOBJ)
	    goto err;
	  for (j = 0; j < nr * nc; j++)
	    ((NspMatrix *) Obj)->R[j] = 0.0;
	  break;
	case 2:
	  /* complex matrix Mat(nr,nc) initialized to zero */
	  if ((Obj =
	       (NspObject *) nsp_matrix_create (NVOID, 'c', nr,
						nc)) == NULLOBJ)
	    goto err;
	  for (j = 0; j < 2 * nr * nc; j++)
	    ((NspMatrix *) Obj)->R[j] = 0.0;
	  break;
	case 3:		/* SCSINT32_COP */
	case 4:		/* SCSINT16_COP */
	case 5:		/* char */
	case 6:		/* SCSUINT32_COP */
	case 7:		/* SCSUINT16_COP */
	case 8:		/* SCSUINT8_COP */
	  if ((Obj =
	       (NspObject *) nsp_imatrix_zeros (nr, nc,
						itype[type])) == NULLOBJ)
	    goto err;
	  break;
	default:
	  /* double */
	  break;
	}
      if (nsp_object_set_name (Obj, "lel") == FAIL)
	return RET_BUG;
      if (nsp_list_end_insert (L, Obj) == FAIL)
	return RET_BUG;
    }
  MoveObj (stack, 1, NSP_OBJECT (L));
  return 1;
 err:
  nsp_list_destroy (L);
  return RET_BUG;
}


static OpTab Scicos_func[] = {
  {"sci_tree4", int_scicos_ftree4},
  {"sci_sctree", int_sctree},
  {"sci_tree2", int_tree2},
  {"sci_tree3", int_tree3},
  {"scicos_debug", int_scicos_debug},
  {"scicosim", int_scicos_sim},
  {"curblock", int_curblock},
  {"setblockerror", int_setblockerror},
  {"time_scicos", int_time_scicos},
  {"duplicate", int_duplicate},
  {"xproperty", int_xproperty},
  {"phase_simulation", int_get_phase_simulation},
  {"setxproperty", int_setxproperty},
  {"scicos_debug_count", int_scicos_debug_count},
  {"buildouttb", int_buildouttb},
  {"scicos_about", int_scicos_about},
  {(char *) 0, NULL}
};

int Scicos_Interf (int i, Stack stack, int rhs, int opt, int lhs)
{
  return (*(Scicos_func[i].fonc)) (stack, rhs, opt, lhs);
}

/* used to walk through the interface table 
 * (for adding or removing functions) */

void Scicos_Interf_Info (int i, char **fname, function (**f))
{
  *fname = Scicos_func[i].name;
  *f = Scicos_func[i].fonc;
}
