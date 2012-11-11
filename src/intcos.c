/* Nsp
 * Copyright (C) 2005-2012 Jean-Philippe Chancelier Enpc/Cermics, Alan
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

#include <nsp/nsp.h>
#include <nsp/graphics-new/Graphics.h>
#include <nsp/object.h>
#include <nsp/matrix.h>
#include <nsp/imatrix.h>
#include <nsp/smatrix.h>
#include <nsp/hash.h>
#include <nsp/list.h>
#include <nsp/plist.h>
#include <nsp/serial.h>
#include <nsp/cells.h>
#include <nsp/graphic.h>
#include <nsp/interf.h>
#include <scicos/simul4.h>
#include <scicos/blocks.h>
#include "control/ctrlpack.h"

extern void *scicos_scid2ptr (double x);
extern void create_scicos_about(void);
static int scicos_fill_gr(scicos_run *r_scicos, NspCells *Gr);
static void nsp_simul_error_msg(int err_code,int *curblk);

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
  const char *action_name[] = { "finish", "linear", "run", "start", NULL };
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
      nsp_simul_error_msg(ierr,&curblk);
      return RET_BUG;
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
  /* int nb = scsim->nblk; */
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

static const char *var_names[] =
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
      if ((L = nsp_list_create (NVOID)) == NULLLIST)
	return RET_BUG;
      MoveObj (stack, 1, NSP_OBJECT (L));
      return 1;
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
  if (A->m == A->n && A->m == 2)  m1 = -1;

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

/* get the entry point name associated to a 
 * simulator name. i.e search names in tabsim 
 * it can be name or scicos_name_block
 */

extern void scicos_get_function_name (char *fname,char *rname);

static int int_scicos_get_internal_name(Stack stack, int rhs, int opt, int lhs)
{
  char name[256],*fname;
  CheckRhs(1,1);
  CheckLhs(0,1);
  if ((fname = GetString(stack,1)) == (char*)0)   return RET_BUG;
  scicos_get_function_name(fname,name);
  if ( nsp_move_string(stack,1,name,-1) ==FAIL)  return RET_BUG;
  return 1;
}

#include "calelm/calpack.h"

static int int_rat(Stack stack, int rhs, int opt, int lhs)
{
  double eps=1.e-6,ma=0.0;
  int i;
  NspMatrix *M, *N=NULL,*D=NULL;
  CheckStdRhs(1,2);
  CheckLhs(0,2);
  if ((M = GetRealMat(stack,1)) == NULLMAT) return RET_BUG;
  if ( rhs >= 2 ) 
    {
      if (GetScalarDouble (stack, 2, &eps) == FAIL)
	return RET_BUG;
    }
  if ((N = nsp_matrix_create(NVOID, M->rc_type, M->m, M->n))==NULL)
    return RET_BUG;
  if ( lhs >=2 )
    {
      if ((D = nsp_matrix_create(NVOID, M->rc_type, M->m, M->n))==NULL)
	return RET_BUG;
    }
  for ( i=0; i < M->mn ; i++)
    {
      double d=Abs(M->R[i]);
      if ( d > ma) ma=d;
    }
  if ( ma != 0.0) eps *= ma;
  
  for ( i=0; i < M->mn ; i++)
    {
      int n,d;
      if ( nsp_calpack_rat(M->R[i],eps,&n,&d) == FAIL) 
	goto bug;
      if ( lhs >= 2)
	{
	  N->R[i]=n;
	  D->R[i]=d;
	}
      else
	{
	  N->R[i]=n/d;
	}
    }
  MoveObj(stack,1,NSP_OBJECT(N));
  if ( lhs >= 2 )
    MoveObj(stack,2,NSP_OBJECT(D));
  return Max(lhs,1);
 bug: 
  if (N != NULL)   nsp_matrix_destroy(N);
  if (D != NULL)   nsp_matrix_destroy(D);
  return RET_BUG;
}


/* Computes ppol 
 */

static int int_ppol(Stack stack, int rhs, int opt, int lhs)
{
  int worksize, worksize1, worksize2,i,ierr=0;
  double tol=0.0;
  NspMatrix *A=NULL, *B=NULL,*P=NULL,*Work=NULL,*Z=NULL,*Nblk=NULL,*G=NULL,*Po=NULL;
  double *wrka,*wrk1,*wrk2,*rm1,*rm2,*rv1,*rv2,*rv3,*rv4;
  int *iwrk, *jpvt, ncont, indcon,mode=1;
  CheckStdRhs(3,3);
  CheckLhs(0,1);
  if ((A = GetRealMatCopy(stack,1)) == NULLMAT) return RET_BUG;
  if ((B = GetRealMatCopy(stack,2)) == NULLMAT) return RET_BUG;
  if ((P = GetMat(stack,3)) == NULLMAT) return RET_BUG;
  CheckSquare(NspFname(stack),1,A);
  if ( B->m != A->m )
    { 
      Scierror("%s: second argument is incompatible, expecting a %dxm matrix\n"
	       ,NspFname(stack),A->m);
      return RET_BUG;
    }
  if ( P->mn != A->m) 
    {
      Scierror("%s: third argument is incompatible, expecting a %d vector\n"
	       ,NspFname(stack),A->m);
      return RET_BUG;
    }
  /* canonical form 
   * wrka: double(A->m*B->n), wrk1: double(B->n), wrk2: double(B->n), iwrk: int(B->n);
   */
  worksize1 = A->m*B->n+3*B->n;
  /* Pole placement worksize 
   * jpvt: int B->n
   * rm1:  double B->nxB->n; rm2:  double B->nxMax(B->n,2);
   * rv1,rv2: double A->m; rv3,rv4: double B->n;
   */
  worksize2 = B->n + B->n*B->n + B->n*Max(B->n,2) + 2*A->m+2*B->n;
  worksize = Max(worksize1, worksize2);
  if ((Work = nsp_matrix_create(NVOID,A->rc_type, 1, worksize))==NULL)
    goto fail;
  /* work affectation one */
  wrka = Work->R ;
  wrk1 = wrka + A->m*B->n;
  wrk2 = wrk1 + B->n;
  iwrk = (int *) (wrk2 + B->m);
  /* work affectation two */
  jpvt = Work->I;
  rm1 = Work->R + B->n;
  rm2 = rm1 + B->n*B->n;
  rv1 = rm2 + B->n*Max(B->n,2);
  rv2 = rv1 + A->m;
  rv3 = rv2 + A->m;
  rv4 = rv3 + B->n;
  /* */
  if ((Z = nsp_matrix_create(NVOID,A->rc_type, A->m,A->n))==NULL)
    goto fail;
  if ((Nblk = nsp_matrix_create(NVOID,A->rc_type, A->m, 1))==NULL)
    goto fail;
  if ((Po = nsp_matrix_create(NVOID,'r',P->mn,2))==NULL)
    goto fail;
  if ( P->rc_type == 'c')
    {
      for ( i=0; i < P->mn; i++)
	{
	  Po->R[i] = P->C[i].r;
	  Po->R[i+Po->m] = P->C[i].i;
	}
    }
  else
    {
      for ( i=0; i < P->mn; i++)
	{
	  Po->R[i] = P->R[i];
	  Po->R[i+Po->m] = 0.0;
	}
    }
  if ((G = nsp_matrix_create(NVOID,A->rc_type, B->n, A->m))==NULL)
    goto fail;
  /*  calcul de la forme canonique orthogonale */
  nsp_ctrlpack_ssxmc(&A->m,&B->n, A->R,&A->m, B->R,&ncont,&indcon,
		     Nblk->I, Z->R, wrka, wrk1,wrk2,iwrk,&tol,&mode);
  if( ncont != A->m )
    {
      Scierror("Error: given pair (A,B) is not controlable !\n");
      goto fail;
    }
  nsp_ctrlpack_polmc(&A->m,&B->n,&A->m,&B->n,A->R,B->R,G->R,Po->R,Po->R+Po->m,
		     Z->R,&indcon,Nblk->I,&ierr, jpvt,rm1,rm2,rv1,rv2,rv3,rv4);
  if( ierr != 0)
    {
      Scierror("Error: given pair (A,B) is not controlable !\n");
      goto fail;
    }
  MoveObj(stack,1,NSP_OBJECT(G));
  FREE(Work);FREE(Z);FREE(Nblk);FREE(Po);
  return 1;
 fail:
  FREE(Work);FREE(Z);FREE(Nblk);FREE(G);FREE(Po);
  return RET_BUG;
}

static int int_coserror(Stack stack, int rhs, int opt, int lhs)
{
  NspSMatrix *SMat1;
  int i;
  CheckRhs(1,1);
  if ((SMat1=GetSMat(stack,1))==NULLSMAT) return RET_BUG;
  for(i=0;i<SMat1->mn;i++) {
    Scierror("%s\n",SMat1->S[i]);
  }
  scicos_set_block_error(-5);
  return 0;
}

/*
 * scicos_moddimtoblkport : allocate scicos C block in/out ports
 * from a scicos nsp model in/out ports definition
 *
 * input :
 *   NspMatrix *Dim1  : model.in/out
 *   NspMatrix *Dim2  : model.in2/out2
 *   NspMatrix *Typ   : model.intyp/outtyp
 *   const char *name : "in" or "out" -for error message-
 *
 * output :
 *   int *n      : allocated block.nin/nout
 *   int **sz    : allocated block.insz/outsz
 *   void ***ptr : allocated block.inptr/outptr
 *
 * Return OK or FAIL
 *
 */

static int scicos_moddimtoblkport(NspMatrix *Dim1,
                                  NspMatrix *Dim2,
                                  NspMatrix *Typ,
                                  int *n,
                                  int **sz,
                                  void ***ptr,
                                  const char *name)
{
  int blk_n=0;
  int *blk_sz=NULL;
  void **blk_ptr=NULL;
  int i,j;
  
  if (Dim1->mn==0) {
    *n=blk_n;
    *sz=blk_sz;
    *ptr=blk_ptr;
    return OK;
  }
  
  if ( (Dim1->mn!=Dim2->mn) || (Dim1->mn!=Typ->mn) ) {
    Scierror("Cross size checking not ok for model.%s, model.%s2, model.%styp.\n",name,name,name);
    return FAIL;
  } else {
    Sciprintf("Cross size checking ok for model.(%s,%s2,%styp)!\n",name,name,name);
    for (i=0;i<Dim1->mn;i++) {
      if (Dim1->R[i]<0) {
        Scierror("Bad value for model.%s(%d)=%d.\n",name,i+1,(int) Dim1->R[i]);
        return FAIL;
      }
      if (Dim2->R[i]<0) {
        Scierror("Bad value for model.%s2(%d)=%d.\n",name,i+1,(int) Dim2->R[i]);
        return FAIL;
      }
      if ( (Typ->R[i]!=1.) && (Typ->R[i]!=2.) && (Typ->R[i]!=3.) && (Typ->R[i]!=4.) && \
           (Typ->R[i]!=5.) && (Typ->R[i]!=6.) && (Typ->R[i]!=7.) && (Typ->R[i]!=8.) && \
           (Typ->R[i]!=9.) ) {
        Scierror("Bad value for model.%styp(%d)=%d.\n",name,i+1,(int) Typ->R[i]);
        return FAIL;
      }
    }
    Sciprintf("Dims and type value ok for model.(%s,%s2,%styp)!\n",name,name,name);
    /* blk->n allocation */
    blk_n = Dim1->mn;
    /* blk->sz allocation */
    if ((blk_sz=(int *) malloc(blk_n*3*sizeof(int))) == NULL) {
      Scierror("Allocation error for blk->%ssz.\n",name);
      return FAIL;
    }
    for(i=0;i<blk_n;i++) {
      blk_sz[i]=(int) Dim1->R[i];
      blk_sz[blk_n+i]=(int) Dim2->R[i];
      if (Typ->R[i]==1.) blk_sz[2*blk_n+i]=SCSREAL_N;
      else if (Typ->R[i]==2.) blk_sz[2*blk_n+i]=SCSCOMPLEX_N;
      else if (Typ->R[i]==3.) blk_sz[2*blk_n+i]=SCSINT32_N;
      else if (Typ->R[i]==4.) blk_sz[2*blk_n+i]=SCSINT16_N;
      else if (Typ->R[i]==5.) blk_sz[2*blk_n+i]=SCSINT8_N;
      else if (Typ->R[i]==6.) blk_sz[2*blk_n+i]=SCSUINT32_N;
      else if (Typ->R[i]==7.) blk_sz[2*blk_n+i]=SCSUINT16_N;
      else if (Typ->R[i]==8.) blk_sz[2*blk_n+i]=SCSUINT8_N;
      else if (Typ->R[i]==9.) blk_sz[2*blk_n+i]=SCSBOOL_N;
    }
    /* blk->ptr allocation */
    if ((blk_ptr=(void **) malloc(blk_n*sizeof(void *))) == NULL) {
      Scierror("Allocation error for blk->%sptr.\n",name);
      return FAIL;
    }
    for(i=0;i<blk_n;i++) {
      switch(blk_sz[2*blk_n+i])
      {
        case SCSREAL_N    :
          if ((blk_ptr[i]=(SCSREAL_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSREAL_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSREAL_COP *)(blk_ptr[i])+j)=0.;
          break;
        case SCSCOMPLEX_N :
          if ((blk_ptr[i]=(SCSCOMPLEX_COP *) malloc((2*blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSCOMPLEX_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<2*(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSCOMPLEX_COP *)(blk_ptr[i])+j)=0.;
          break;
        case SCSINT32_N   :
          if ((blk_ptr[i]=(SCSINT32_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSINT32_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSINT32_COP *)(blk_ptr[i])+j)=0;
          break;
        case SCSINT16_N   :
          if ((blk_ptr[i]=(SCSINT16_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSINT16_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSINT16_COP *)(blk_ptr[i])+j)=0;
          break;
        case SCSINT8_N    :
          if ((blk_ptr[i]=(SCSINT8_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSINT8_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSINT8_COP *)(blk_ptr[i])+j)=0;
          break;
        case SCSUINT32_N  :
          if ((blk_ptr[i]=(SCSUINT32_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSUINT32_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSUINT32_COP *)(blk_ptr[i])+j)=0;
          break;
        case SCSUINT16_N  :
          if ((blk_ptr[i]=(SCSUINT16_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSUINT16_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSUINT16_COP *)(blk_ptr[i])+j)=0;
          break;
        case SCSUINT8_N   :
          if ((blk_ptr[i]=(SCSUINT8_COP *) malloc((blk_sz[i]*blk_sz[blk_n+i])*sizeof(SCSUINT8_COP))) == NULL) {
            Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
            return FAIL;
          }
          for (j=0;j<(blk_sz[i]*blk_sz[blk_n+i]);j++) *((SCSUINT8_COP *)(blk_ptr[i])+j)=0;
          break;
/*        case SCSBOOL_N    :
 *         TODO
 *         break;
 */
      }
    }
  }
    
  *n=blk_n;
  *sz=blk_sz;
  *ptr=blk_ptr;
  return OK;
}

/*
 * scicos_modlisttoblktdata : allocate scicos C block typed data
 * from a scicos nsp list definition
 *
 * input :
 *   NspObject *Obj : a nsp list
 *   const char *name : "in" or "out" -for error message-
 *
 * output :
 *   int *n      : allocated block.npar
 *   int **sz    : allocated block.sz
 *   int **typ   : allocated block.typ
 *   void ***ptr : allocated block.ptr
 *
 * Return OK or FAIL
 *
 */

static int scicos_modlisttoblktdata(NspObject *Obj,
                                    int *n,
                                    int **sz,
                                    int **typ,
                                    void ***ptr,
                                    const char *name) 
{
  int blk_n;
  int *blk_sz;
  int *blk_typ;
  void **blk_ptr;
  NspList *L;
  int i,nel;
  
  blk_n=0;
  blk_sz=NULL;
  blk_typ=NULL;
  blk_ptr=NULL;
  L = (NspList *) Obj;
  
  *n=blk_n;
  *sz=blk_sz; 
  *typ=blk_typ;
  *ptr=blk_ptr;
  nel=L->nel;

  if (nel!=0) {
    for(i=nel-1;i>=0;i--) {
      NspObject *elt = nsp_list_get_element(L, i+1);
      if ( !(IsIMat(elt)) &&  !(IsMat(elt)) ) {
        Scierror("Bad object for model.%s(%d).\n",name,i+1);
        return FAIL;
      }
    }
    Sciprintf("Object type are ok for model.%s!\n",name);
    /* blk_n allocation */
    blk_n=nel;
    /* blk_sz allocation */
    if ((blk_sz=(int *) malloc(blk_n*2*sizeof(int))) == NULL) {
      Scierror("Allocation error for blk->%ssz.\n",name);
      return FAIL;
    }
    /* blk_typ allocation */
    if ((blk_typ=(int *) malloc(blk_n*sizeof(int))) == NULL) {
      Scierror("Allocation error for blk->%styp.\n",name);
      return FAIL;
    }
    /* blk_ptr allocation */
    if ((blk_ptr=(void **) malloc(blk_n*sizeof(void *))) == NULL) {
      Scierror("Allocation error for blk->%sptr.\n",name);
      return FAIL;
    }
    for(i=nel-1;i>=0;i--) {
      NspObject *elt = nsp_list_get_element(L, i+1);
      if (IsMat(elt)) {
        NspMatrix *M = (NspMatrix *) elt;
        blk_sz[i]=M->m;
        blk_sz[i+blk_n]=M->n;
        switch (M->rc_type)
        {
          case 'c' :
            if ((blk_ptr[i]=(SCSCOMPLEX_COP *) malloc(2*M->mn*sizeof(SCSCOMPLEX_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSCOMPLEX_N;
            memcpy((SCSCOMPLEX_COP *)blk_ptr[i], (double *)M->R, 2*M->mn*sizeof(SCSCOMPLEX_COP));
            break;
          case 'r' :
            if ((blk_ptr[i]=(SCSREAL_COP *) malloc(M->mn*sizeof(SCSREAL_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSREAL_N;
            memcpy((SCSREAL_COP *)blk_ptr[i], (double *)M->R, M->mn*sizeof(SCSREAL_COP));
            break; 
          default  :
            Scierror("Bad matrix type for model.%s(%d).\n",name,i+1);
            return FAIL;
        }
      } else {
        NspIMatrix *M = (NspIMatrix *) elt;
        blk_sz[i]=M->m;
        blk_sz[i+blk_n]=M->n;
        switch (M->itype)
        {
          case nsp_gint    :
            if ((blk_ptr[i]=(SCSINT_COP *) malloc(M->mn*sizeof(SCSINT_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSINT_N;
            memcpy((SCSINT_COP *) blk_ptr[i], (gint *) M->Gint, M->mn*sizeof(SCSINT_COP));
            break;
          case nsp_gint8   :
            if ((blk_ptr[i]=(SCSINT8_COP *) malloc(M->mn*sizeof(SCSINT8_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSINT8_N;
            memcpy((SCSINT8_COP *) blk_ptr[i], (gint8 *) M->Gint8, M->mn*sizeof(SCSINT8_COP));
            break;
          case nsp_gint16  :
            if ((blk_ptr[i]=(SCSINT16_COP *) malloc(M->mn*sizeof(SCSINT16_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSINT16_N;
            memcpy((SCSINT16_COP *) blk_ptr[i], (gint16 *) M->Gint16, M->mn*sizeof(SCSINT16_COP));
            break;
          case nsp_gint32  :
            if ((blk_ptr[i]=(SCSINT32_COP *) malloc(M->mn*sizeof(SCSINT32_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSINT32_N;
	    memcpy((SCSINT32_COP *) blk_ptr[i], (gint32 *) M->Gint32, M->mn*sizeof(SCSINT32_COP));
            break;
          case nsp_guint   :
            if ((blk_ptr[i]=(SCSUINT_COP *) malloc(M->mn*sizeof(SCSUINT_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSUINT_N;
            memcpy((SCSUINT_COP *) blk_ptr[i], (guint *) M->Guint, M->mn*sizeof(SCSUINT_COP));
            break;

          case nsp_guint8  :
            if ((blk_ptr[i]=(SCSUINT8_COP *) malloc(M->mn*sizeof(SCSUINT8_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSUINT8_N;
            memcpy((SCSUINT8_COP *) blk_ptr[i], (guint8 *) M->Guint8, M->mn*sizeof(SCSUINT8_COP));
            break;
    
          case nsp_guint16 :
            if ((blk_ptr[i]=(SCSUINT16_COP *) malloc(M->mn*sizeof(SCSUINT16_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSUINT16_N;
            memcpy((SCSUINT16_COP *) blk_ptr[i], (guint16 *) M->Guint16, M->mn*sizeof(SCSUINT16_COP));
            break;
          case nsp_guint32 :
            if ((blk_ptr[i]=(SCSUINT32_COP *) malloc(M->mn*sizeof(SCSUINT32_COP))) == NULL) {
              Scierror("Allocation error for blk->%sptr[%d].\n",name,i);
              return FAIL;
            }
            blk_typ[i]=SCSUINT32_N;
            memcpy((SCSUINT32_COP *) blk_ptr[i], (guint32 *) M->Guint32, M->mn*sizeof(SCSUINT32_COP));
            break;
          default          :
            Scierror("Bad imatrix type for model.%s(%d).\n",name,i+1);
            return FAIL;
        }
      } 
    }
  }

  *n=blk_n;
  *sz=blk_sz; 
  *typ=blk_typ;
  *ptr=blk_ptr;
  return OK;
}

/* scicos_modvectoblkvec : allocate scicos C block double
 * vector from a scicos nsp list vector. Serialize if needeed.
 *
 * input :
 *   NspObject *Obj : a nsp list
 *   scicos_funflag funflag : a scicos_funflag to know if it is a nsp blk
 *   const char *name : "z" or "rpar" -for error message-
 *
 * output :
 *   int *n      : allocated block.n
 *   double **x  : allocated block.x
 *
 * Return OK or FAIL
 *
 */
  
static int scicos_modvectoblkvec(NspObject *obj,
                                 int *n,
                                 double **x,
                                 scicos_funflag funflag,
                                 const char* name)
{
  NspMatrix *M;
  double *v;
  
  M=(NspMatrix *)obj;
  v=NULL;
  *n=M->mn;
  *x=v;
  
  if (M->mn!=0) {
    if (funflag == fun_pointer) {
      if ((v=(double *) malloc(*n*sizeof(double)))==NULL) return FAIL;
      memcpy(v, M->R, *n*sizeof(double));
    } else {
      /* serialize for scilab block
       * to be fixed in scicoslab
       */
      NspObject *S;
      NspMatrix *M2;
      if ((S=nsp_object_serialize(obj))==NULLOBJ) return FAIL;
      M2=nsp_serial_to_matrix((NspSerial *) S);
      nsp_object_destroy (&S);
      if (M2==NULLMAT) return FAIL;
      *n=M2->mn;
      if ((v=(double *) malloc(*n*sizeof(double)))==NULL) return FAIL;
      memcpy(v, M2->R, *n*sizeof(double));
      nsp_matrix_destroy(M2); 
    }
  }
  
  *x=v;
  return OK;
}

/*
 * scicos_modobjtoblkobj : allocate scicos C block typed data
 * from a scicos nsp list definition. Extract if needeed.
 *
 * input :
 *   NspObject *Obj : a nsp list
 *   scicos_funflag funflag : a scicos_funflag to know if it is a nsp blk
 *   const char *name : "odstate" or "opar" -for error message-
 *
 * output :
 *   int *n      : allocated block.noz/nopar
 *   int **sz    : allocated block.ozsz/oparsz
 *   int **typ   : allocated block.oztyp/opartyp
 *   void ***ptr : allocated block.ozptr/oparptr
 *
 * Return OK or FAIL
 *
 */

static int scicos_modobjtoblkobj(NspObject *Obj,
                                 int *n,
                                 int **sz,
                                 int **typ,
                                 void ***ptr,
                                 scicos_funflag funflag,
                                 const char *name)
{
  int blk_n;
  int *blk_sz;
  int *blk_typ;
  void **blk_ptr;
  
  blk_n=0;
  blk_sz=NULL;
  blk_typ=NULL;
  blk_ptr=NULL;
  
  *n=blk_n;
  *sz=blk_sz; 
  *typ=blk_typ;
  *ptr=blk_ptr;

  if (funflag == fun_pointer) {
    if ((scicos_modlisttoblktdata(Obj,
                                  &blk_n,
                                  &blk_sz,
                                  &blk_typ,
                                  &blk_ptr,
                                  name)) == FAIL)
      return FAIL;
  } else {
    /* scilab block : don't extract */
    NspList *L = (NspList *) Obj;
    int nel;
    nel=L->nel;
    if (nel!=0) {
      blk_n=1;
      if ((blk_sz=(int *) malloc(2*blk_n*sizeof(int)))==NULL)
        return FAIL;
      if ((blk_typ=(int *) malloc(blk_n*sizeof(int)))==NULL)
        return FAIL;
      if ((blk_ptr=(void **) malloc(blk_n*sizeof(void *)))==NULL)
        return FAIL;
      blk_sz[0]=1;
      blk_sz[1]=1;
      blk_typ[0]=SCSUNKNOW_N;
      if ((blk_ptr[0]=(void *)nsp_list_full_copy(L))==NULLLIST)
        return FAIL;
    }
  }

  *n=blk_n;
  *sz=blk_sz; 
  *typ=blk_typ;
  *ptr=blk_ptr;
  return OK;
}

/* unalloc a C scicos block struct
 *
 */
void scicos_unalloc_block(scicos_block *Block)
{
  int j;

  if (Block->nin!=0) {
    FREE(Block->insz);
    for(j=0;j<Block->nin;j++) FREE(Block->inptr[j]);
    FREE(Block->inptr);
  }
  
  if (Block->nout!=0) {
    FREE(Block->outsz);
    for(j=0;j<Block->nout;j++) FREE(Block->outptr[j]);
    FREE(Block->outptr);
  }
  
  if (Block->nevout!=0) {
    FREE(Block->evout);
  }
  
  if (Block->nx!=0) {
    FREE(Block->x);
    FREE(Block->xd);
    FREE(Block->res);
    FREE(Block->xprop);
  }
  
  if (Block->nz!=0) {
    FREE(Block->z);
  }
  
  if (Block->noz!=0) {
    FREE(Block->ozsz);
    FREE(Block->oztyp);
    for(j=0;j<Block->noz;j++) FREE(Block->ozptr[j]);
    FREE(Block->ozptr);
  }
  
  if (Block->nrpar!=0) {
    FREE(Block->rpar);
  }
  
  if (Block->nipar!=0) {
    FREE(Block->ipar);
  }
  
  if (Block->nopar!=0) {
    FREE(Block->oparsz);
    FREE(Block->opartyp);
    for(j=0;j<Block->nopar;j++) FREE(Block->oparptr[j]);
    FREE(Block->oparptr);
  }
  
  if (strlen(Block->label)!=0) {
    FREE(Block->label);
  }
  
  if (Block->ng!=0) {
    FREE(Block->g);
    FREE(Block->jroot);
  }
  
  if (Block->nmode!=0) {
    FREE(Block->mode);
  }
}

extern int scicos_update_scsptr(scicos_block *Block, int funtyp, scicos_funflag funflag, void * funptr);
extern int scicos_get_scsptr(NspObject *obj, scicos_funflag *funflag, void **funptr);

/*
 * fill a scicos_block structure 
 * with pointers from the Hash table Model
 *
 */

static int scicos_fill_model(NspHash *Model,scicos_block *Block)
{
  NspObject *obj;
  NspObject *Dim1;
  NspObject *Dim2;
  NspObject *Typ;
  NspMatrix *M,*M2;
  NspSMatrix *SMat;
  int i,funtyp=0;
  scicos_funflag funflag;
  void *funptr;

  char *model[]={"sim","in","in2","intyp","out","out2","outtyp",
                 "evtin","evtout","state","dstate","odstate","rpar","ipar","opar",
                 "blocktype","firing","dep_ut","label","nzcross","nmode","equations"};

  const int nmodel=22;
  
  for (i =0;i<nmodel;i++) {
    if (nsp_hash_find(Model,model[i],&obj)==FAIL) return FAIL;
  }

  /* minimal block list structure allocation */
  Block->type=0;
  Block->nin=0;
  Block->nout=0;
  Block->nevout=0;
  Block->nx=0;
  Block->nz=0;
  Block->noz=0;
  Block->nrpar=0;
  Block->nipar=0;
  Block->nopar=0;
  Block->label="";
  Block->ng=0;
  Block->ztyp=0;
  Block->nmode=0;
  Block->work=NULL;
  
  /* 1 : model.sim  */
  nsp_hash_find(Model,model[0],&obj);
  if (IsList(obj)) {
    NspMatrix *M;
    M = (NspMatrix *) nsp_list_get_element((NspList *)obj,2);
    funtyp = (int) M->R[0];
    obj = nsp_list_get_element((NspList *)obj,1);
  } else {
    funtyp = 0;
  }
  
  if ((scicos_get_scsptr(obj,&funflag,&funptr)) == FAIL)
    goto err;

  if ((scicos_update_scsptr(Block,funtyp,funflag,funptr)) == FAIL)
    goto err;
        
  /* TODO */
  /* debugging block */
  /*if (funtyp==99) scsim->debug_block = kf;*/

  /* input ports      */
  /* 2 : model.in     */
  /* 3 : model.in2    */
  /* 4 : model.intyp  */
  nsp_hash_find(Model,model[1],&Dim1);
  nsp_hash_find(Model,model[2],&Dim2);
  nsp_hash_find(Model,model[3],&Typ);
  if ((scicos_moddimtoblkport((NspMatrix *)Dim1,
                              (NspMatrix *)Dim2,
                              (NspMatrix *)Typ,
                              &Block->nin,
                              &Block->insz,
                              &Block->inptr,
                              "in")) == FAIL)
    goto err;
  
  /* output ports     */
  /* 5 : model.out    */
  /* 6 : model.out2   */
  /* 7 : model.outtyp */
  nsp_hash_find(Model,model[4],&Dim1);
  nsp_hash_find(Model,model[5],&Dim2);
  nsp_hash_find(Model,model[6],&Typ);
  if ((scicos_moddimtoblkport((NspMatrix *)Dim1,
                              (NspMatrix *)Dim2,
                              (NspMatrix *)Typ,
                              &Block->nout,
                              &Block->outsz,
                              &Block->outptr,
                              "out")) == FAIL)
    goto err;
  
  /* event input port */
  /* 8 : model.evtin  */

  /* event output port  */
  /* 9 : model.evtout   */
  /* 17 : model.firing  */
  nsp_hash_find(Model,model[8],&obj);
  M=(NspMatrix *)obj;
  nsp_hash_find(Model,model[16],&obj);
  M2=(NspMatrix *)obj;
  Block->nevout=M->mn;
  Block->evout=NULL;
  if (M->mn!=0) {
    if ((Block->evout=(double *) malloc(Block->nevout*sizeof(double)))==NULL)
      goto err;
    if (M->mn==M2->mn) {
      memcpy(Block->evout, M2->R, M->mn*sizeof(double));
    }
    else {
      for(i=0;i<Block->nevout;i++) {
        Block->evout[i]=-1.;
      }
    }
  }
  
  /* continuous state  */
  /* 10 : model.state  */
  nsp_hash_find(Model,model[9],&obj);
  M=(NspMatrix *)obj;
  Block->nx=M->mn;
  Block->x=NULL;
  Block->xd=NULL;
  Block->res=NULL;
  Block->xprop=NULL;
  if (M->mn!=0) {
    if ((Block->x=(double *) malloc(Block->nx*sizeof(double)))==NULL)
      goto err;
    if ((Block->xd=(double *) malloc(Block->nx*sizeof(double)))==NULL)
      goto err;
    if ((Block->res=(double *) malloc(Block->nx*sizeof(double)))==NULL)
      goto err;
    if ((Block->xprop=(int *) malloc(Block->nx*sizeof(int)))==NULL)
      goto err;
    memcpy(Block->x, M->R, M->mn*sizeof(double));
    for(i=0;i<Block->nx;i++) Block->xd[i]=0.;
    for(i=0;i<Block->nx;i++) Block->res[i]=0.;
    for(i=0;i<Block->nx;i++) Block->xprop[i]=1;
  }
  
  /* discrete state  */
  /* 11 : model.dstate  */
  nsp_hash_find(Model,model[10],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nz,
                             &Block->z,
                             Block->scsptr_flag,
                             "z")) == FAIL)
       goto err;

  /* discrete object state  */
  /* 12 : model.odstate  */
  nsp_hash_find(Model,model[11],&obj);
  if ((scicos_modobjtoblkobj(obj,
                             &Block->noz,
                             &Block->ozsz,
                             &Block->oztyp,
                             &Block->ozptr,
                             Block->scsptr_flag,
                             "odstate")) == FAIL)
    goto err;

  /* real parameters */
  /* 13 : model.rpar  */
  nsp_hash_find(Model,model[12],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nrpar,
                             &Block->rpar,
                             Block->scsptr_flag,
                             "rpar")) == FAIL)
    goto err;
  
  
  /* integer parameters */
  /* 14 : model.ipar  */
  nsp_hash_find(Model,model[13],&obj);
  M=(NspMatrix *)obj;
  Block->nipar=M->mn;
  Block->ipar=NULL;
  if (M->mn!=0) {
    if ((Block->ipar=(int *) malloc(Block->nipar*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->nipar;i++) Block->ipar[i]=(int)M->R[i];
  }
  
  /* object parameters */
  /* 15 : model.opar  */
  nsp_hash_find(Model,model[14],&obj);
  if ((scicos_modobjtoblkobj(obj,
                             &Block->nopar,
                             &Block->oparsz,
                             &Block->opartyp,
                             &Block->oparptr,
                             Block->scsptr_flag,
                             "opar")) == FAIL)
      goto err;

  /* labels */
  /* 19 : model.label  */
  nsp_hash_find(Model,model[18],&obj);
  SMat=(NspSMatrix *)obj;
  if (SMat->mn!=0) {
    int len_str=strlen(SMat->S[0]);
    if (len_str!=0) {
      if ((Block->label=(char *) malloc((len_str+1)*sizeof(char)))==NULL)
        goto err; 
      strcpy(Block->label,SMat->S[0]);
    }
  }

  /* zero crossing */
  /* 20 : model.nzcross  */
  nsp_hash_find(Model,model[19],&obj);
  M=(NspMatrix *)obj;
  Block->g=NULL;
  Block->jroot=NULL;
  if (M->mn!=0) {
    Block->ng=(int) M->R[0];
    if ((Block->g=(double *) malloc(Block->ng*sizeof(double)))==NULL)
      goto err;
    if ((Block->jroot=(int *) malloc(Block->ng*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->ng;i++) Block->g[i]=0.;
    for(i=0;i<Block->ng;i++) Block->jroot[i]=0;
    Block->ztyp=1;
  }
   
  /* mode */
  /* 21 : model.nmode  */
  nsp_hash_find(Model,model[20],&obj);
  M=(NspMatrix *)obj;
  Block->mode=NULL;
  if (M->mn!=0) {
    Block->nmode=M->R[0];
    if ((Block->mode=(int *) malloc(Block->nmode*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->nmode;i++) Block->mode[i]=0;
  }
  
  /* work */
  if ((Block->work=(void **) malloc(sizeof(void*)))==NULL)
    goto err;
  *Block->work=NULL;
  
  return OK;
  
  err :
    scicos_unalloc_block(Block);
    return FAIL;
}

extern NspHash *createblklist(double time, scicos_block *Block);
extern int scicos_list_to_vars(void *outptr[], int nout, int outsz[], int outsz2[], int outtyp[],
                               NspObject *Ob);
extern void callf(const double *t, scicos_block * block, int *flag);
/* 
 * int_model2blk : Build a scicos_block structure from
 * a scicos model.
 *
 * [Block]=model2blk(objs.model)
 *
 */
 
static int int_model2blk(Stack stack, int rhs, int opt, int lhs)
{
  NspHash *Model;
  NspHash *HModel;
  scicos_block Block;
  double time=0.;
  
  CheckLhs(0,1);
  CheckRhs(1,1);

  if ((Model=GetHashCopy(stack,1))==NULLHASH) return RET_BUG;
  if (scicos_fill_model(Model,&Block)==FAIL) {
    Scierror("Bad scicos block model.\n");
    return RET_BUG;
  }
  if ((HModel = createblklist(time, &Block))==NULL) {
    scicos_unalloc_block(&Block);
    return RET_BUG;
  }
  scicos_unalloc_block(&Block);
  MoveObj(stack,1,NSP_OBJECT(HModel));
  return Max(lhs,1);
}

/* extractblklist : create a scicos_block C structure from
 * a scicos_block nsp structure.
 *
 * Input : NspHash : the nsp scicos_block structure
 *
 * Output : Block : C scicos_block structure
 * 
 * return FAIL if error, OK else
 *
 * initial rev 13/11/07, Alan
 */

static int extractblklist(NspHash *Hi,scicos_block *Block)
{
  
  NspObject *obj;
  NspMatrix *M;
  NspSMatrix *SMat;
  int i;
  
  char *fields[]={"nevprt","type","scsptr","scsptr_flag","funpt",
                  "z","oz","x","xd","res","xprop",
                  "nin","insz","inptr","nout","outsz","outptr",
                  "nevout","evout",
                  "rpar","ipar","opar","g","ztyp","jroot","label","work","mode"};
                  
  const int nfields=28;
  
  for (i =0;i<nfields;i++) {
    if (nsp_hash_find(Hi,fields[i],&obj)==FAIL) return FAIL;
  }

  /* minimal block list structure allocation */
  Block->type=0;
  Block->nin=0;
  Block->nout=0;
  Block->nevout=0;
  Block->nx=0;
  Block->nz=0;
  Block->noz=0;
  Block->nrpar=0;
  Block->nipar=0;
  Block->nopar=0;
  Block->label="";
  Block->ng=0;
  Block->ztyp=0;
  Block->nmode=0;
  Block->work=NULL;
  
  /************* time */
  /* 1 - nevprt */
  nsp_hash_find(Hi,fields[0],&obj);
  M=(NspMatrix *)obj;
  Block->nevprt = (int) M->R[0];
  
  /* 2 - type */
  nsp_hash_find(Hi,fields[1],&obj);
  M=(NspMatrix *)obj;
  Block->type = (int) M->R[0];
  
  /* 3 - scsptr */
  nsp_hash_find(Hi,fields[2],&obj);
  M=(NspMatrix *)obj;
  Block->scsptr = scicos_scid2ptr(M->R[0]);
  
  /* 4 - scsptr_flag */
  nsp_hash_find(Hi,fields[3],&obj);
  M=(NspMatrix *)obj;
  i=(int) M->R[0];
  Block->scsptr_flag = (scicos_funflag) i;
  
  /* 5 - funpt */
  nsp_hash_find(Hi,fields[4],&obj);
  M=(NspMatrix *) obj;
  Block->funpt = scicos_scid2ptr (M->R[0]);
  
  /************* nz */
  /* 6 - z */
  nsp_hash_find(Hi,fields[5],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nz,
                             &Block->z,
                             Block->scsptr_flag,
                             "z")) == FAIL)
    goto err;
    
  /************** noz */
  /************** ozsz */
  /************** oztyp */
  /* 7 - oz */
  nsp_hash_find(Hi,fields[6],&obj);
  if ((scicos_modobjtoblkobj(obj,
                             &Block->noz,
                             &Block->ozsz,
                             &Block->oztyp,
                             &Block->ozptr,
                             Block->scsptr_flag,
                             "odstate")) == FAIL)
    goto err;
  
  /************** nx */
  /* 8 - x */
  nsp_hash_find(Hi,fields[7],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nx,
                             &Block->x,
                             fun_pointer,
                             "x")) == FAIL)
    goto err;
  
  /* 9 - xd */
  nsp_hash_find(Hi,fields[8],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nx,
                             &Block->xd,
                             fun_pointer,
                             "xd")) == FAIL)
    goto err;
    
  /* 10 - res */
  nsp_hash_find(Hi,fields[9],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nx,
                             &Block->res,
                             fun_pointer,
                             "res")) == FAIL)
    goto err;
  
  /* 11 - xprop */
  nsp_hash_find(Hi,fields[10],&obj);
  M=(NspMatrix *)obj;
  Block->xprop=NULL;
  if (M->mn!=0) {
    if ((Block->xprop=(int *) malloc(Block->nx*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->nx;i++) Block->xprop[i]=(int)M->R[i];
  }
  
  /* 12 - nin */
  nsp_hash_find(Hi,fields[11],&obj);
  M=(NspMatrix *)obj;
  Block->nin = (int) M->R[0];
  
  /* 13 - insz */
  nsp_hash_find(Hi,fields[12],&obj);
  M=(NspMatrix *)obj;
  Block->insz=NULL;
  if (M->mn!=0) {
    if ((Block->insz=(int *) malloc(3*Block->nin*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<3*Block->nin;i++) Block->insz[i]=(int)M->R[i];
  }
  
  /* 14 - inptr */
  nsp_hash_find(Hi,fields[13],&obj);
  if (Block->nin != 0) {
    if ((Block->inptr=(void **) malloc(Block->nin*sizeof(void *))) == NULL)
      goto err;
    for (i=0;i<Block->nin;i++) {
      switch (Block->insz[2*Block->nin+i])
      {
        case SCSREAL_N    :
          if ((Block->inptr[i]=(SCSREAL_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSREAL_COP))) == NULL)
            goto err;
          break;
        case SCSCOMPLEX_N :
          if ((Block->inptr[i]=(SCSCOMPLEX_COP *) malloc((2*Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSCOMPLEX_COP))) == NULL)
            goto err;
          break;
        case SCSINT32_N   :
          if ((Block->inptr[i]=(SCSINT32_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSINT32_COP))) == NULL)
            goto err;
          break;
        case SCSINT16_N   :
          if ((Block->inptr[i]=(SCSINT16_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSINT16_COP))) == NULL)
            goto err;
          break;
        case SCSINT8_N    :
          if ((Block->inptr[i]=(SCSINT8_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSINT8_COP))) == NULL)
            goto err;
          break;
        case SCSUINT32_N  :
          if ((Block->inptr[i]=(SCSUINT32_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSUINT32_COP))) == NULL)
            goto err;
          break;
        case SCSUINT16_N  :
          if ((Block->inptr[i]=(SCSUINT16_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSUINT16_COP))) == NULL)
            goto err;
          break;
        case SCSUINT8_N   :
          if ((Block->inptr[i]=(SCSUINT8_COP *) malloc((Block->insz[i]*Block->insz[Block->nin+i])*sizeof(SCSUINT8_COP))) == NULL)
            goto err;
          break;
/*        case SCSBOOL_N    :
 *         TODO
 *         break;
 */
      }
    }
    if (scicos_list_to_vars((void **) Block->inptr, Block->nin,
        Block->insz, &(Block->insz[Block->nin]), &(Block->insz[2*Block->nin]), obj) == FAIL)
      goto err;
  }
  
  /* 15 - nout */
  nsp_hash_find(Hi,fields[14],&obj);
  M=(NspMatrix *)obj;
  Block->nout = (int) M->R[0];
  
  /* 16 - outsz */
  nsp_hash_find(Hi,fields[15],&obj);
  M=(NspMatrix *)obj;
  Block->outsz=NULL;
  if (M->mn!=0) {
    if ((Block->outsz=(int *) malloc(3*Block->nout*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<3*Block->nout;i++) Block->outsz[i]=(int)M->R[i];
  }
  
  /* 17 - outptr */
  nsp_hash_find(Hi,fields[16],&obj);
  if (Block->nout != 0) {
    if ((Block->outptr=(void **) malloc(Block->nout*sizeof(void *))) == NULL)
      goto err;
    for (i=0;i<Block->nout;i++) {
      switch (Block->outsz[2*Block->nout+i])
      {
        case SCSREAL_N    :
          if ((Block->outptr[i]=(SCSREAL_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSREAL_COP))) == NULL)
            goto err;
          break;
        case SCSCOMPLEX_N :
          if ((Block->outptr[i]=(SCSCOMPLEX_COP *) malloc((2*Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSCOMPLEX_COP))) == NULL)
            goto err;
          break;
        case SCSINT32_N   :
          if ((Block->outptr[i]=(SCSINT32_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSINT32_COP))) == NULL)
            goto err;
          break;
        case SCSINT16_N   :
          if ((Block->outptr[i]=(SCSINT16_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSINT16_COP))) == NULL)
            goto err;
          break;
        case SCSINT8_N    :
          if ((Block->outptr[i]=(SCSINT8_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSINT8_COP))) == NULL)
            goto err;
          break;
        case SCSUINT32_N  :
          if ((Block->outptr[i]=(SCSUINT32_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSUINT32_COP))) == NULL)
            goto err;
          break;
        case SCSUINT16_N  :
          if ((Block->outptr[i]=(SCSUINT16_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSUINT16_COP))) == NULL)
            goto err;
          break;
        case SCSUINT8_N   :
          if ((Block->outptr[i]=(SCSUINT8_COP *) malloc((Block->outsz[i]*Block->outsz[Block->nout+i])*sizeof(SCSUINT8_COP))) == NULL)
            goto err;
          break;
/*        case SCSBOOL_N    :
 *         TODO
 *         break;
 */
      }
    }
    if (scicos_list_to_vars((void **) Block->outptr, Block->nout,
        Block->outsz, &(Block->outsz[Block->nout]), &(Block->outsz[2*Block->nout]), obj) == FAIL)
      goto err;
  }
  
  /* 18 - nevout */
  /* 19 - evout */
  nsp_hash_find(Hi,fields[18],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nevout,
                             &Block->evout,
                             fun_pointer,
                             "evout")) == FAIL)
    goto err;
  
  /************** nrpar */
  /* 20 - rpar */
  nsp_hash_find(Hi,fields[19],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->nrpar,
                             &Block->rpar,
                             Block->scsptr_flag,
                             "rpar")) == FAIL)
    goto err;
  
  /************** nipar */
  /* 21 - ipar */
  nsp_hash_find(Hi,fields[20],&obj);
  M=(NspMatrix *)obj;
  Block->ipar=NULL;
  Block->nipar=M->mn;
  if (M->mn!=0) {
    if ((Block->ipar=(int *) malloc(Block->nipar*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->nipar;i++) Block->ipar[i]=(int)M->R[i];
  }
  
  /************** nopar */
  /************** oparsz */
  /************** opartyp */
  /* 22 - opar */
  nsp_hash_find(Hi,fields[21],&obj);
  if ((scicos_modobjtoblkobj(obj,
                             &Block->nopar,
                             &Block->oparsz,
                             &Block->opartyp,
                             &Block->oparptr,
                             Block->scsptr_flag,
                             "opar")) == FAIL)
    goto err;
  
  /************** ng */
  /* 23 - g */
  nsp_hash_find(Hi,fields[22],&obj);
  if ((scicos_modvectoblkvec(obj,
                             &Block->ng,
                             &Block->g,
                             fun_pointer,
                             "g")) == FAIL)
    goto err;
  
  /* 24 - ztyp */
  nsp_hash_find(Hi,fields[23],&obj);
  M=(NspMatrix *)obj;
  Block->ztyp = (int) M->R[0];
  
  /* 25 - jroot */
  nsp_hash_find(Hi,fields[24],&obj);
  M=(NspMatrix *)obj;
  Block->jroot=NULL;
  if (M->mn!=0) {
    if ((Block->jroot=(int *) malloc(Block->ng*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->ng;i++) Block->jroot[i]=(int)M->R[i];
  }
  
  /* 26 - label */
  nsp_hash_find(Hi,fields[25],&obj);
  SMat=(NspSMatrix *)obj;
  if (SMat->mn!=0) {
    int len_str=strlen(SMat->S[0]);
    if (len_str!=0) {
      if ((Block->label=(char *) malloc((len_str+1)*sizeof(char)))==NULL)
        goto err; 
      strcpy(Block->label,SMat->S[0]);
    }
  }
  
  /* 27 - work*/
  nsp_hash_find(Hi,fields[26],&obj);
  M=(NspMatrix *)obj;
  Block->work = (void **) scicos_scid2ptr(M->R[0]);

  /************** nmode*/
  /* 28 - mode */
  nsp_hash_find(Hi,fields[27],&obj);
  M=(NspMatrix *)obj;
  Block->mode=NULL;
  Block->nmode=M->mn;
  if (M->mn!=0) {
    if ((Block->mode=(int *) malloc(Block->nmode*sizeof(int)))==NULL)
      goto err;
    for(i=0;i<Block->nmode;i++) Block->mode[i]=(int)M->R[i];
  }
  
  return OK;
  
  err :
    scicos_unalloc_block(Block);
    return FAIL;
}

/*
 * int_callblk  : Call a scicos block defined by
 * a nsp scicos_block structure.
 *
 * [Block]=callblk(Block,flag,t)
 *
 */

static int int_callblk(Stack stack, int rhs, int opt, int lhs)
{
  NspHash *BlkHash_IN,*BlkHash_OUT;
  scicos_block Block;
  int flag;
  double tcur;
  scicos_run r_scicos;

  CheckRhs (3,3);

  if ((BlkHash_IN=GetHashCopy(stack,1))==NULLHASH) return RET_BUG;
  if (GetScalarInt(stack,2,&flag)==FAIL) return RET_BUG;
  if (GetScalarDouble(stack,3,&tcur)==FAIL) return RET_BUG;
  
  if (extractblklist(BlkHash_IN, &Block)==FAIL) return RET_BUG;
  
  //TOBEREVIEWED
  Scicos = &r_scicos;
  Scicos->params.solver=0;
  Scicos->params.debug=0;
  Scicos->params.curblk=1;
  Scicos->params.phase=1;
  
  callf(&tcur, &Block, &flag);
  
  if ((BlkHash_OUT = createblklist(tcur, &Block))==NULL) {
    scicos_unalloc_block(&Block);
    return RET_BUG;
  }
  
  scicos_unalloc_block(&Block);
  MoveObj(stack,1,NSP_OBJECT(BlkHash_OUT));
  return Max(lhs,1);
}

extern int scicos_is_split(NspObject *obj);
extern int scicos_is_block(NspObject *obj);
extern int scicos_is_link(NspObject *obj);
extern int scicos_is_text(NspObject *obj);
extern int scicos_is_modelica_block(NspObject *obj);

typedef int (isfun)(NspObject *obj);

static int int_scicos_is(Stack stack, int rhs, int opt, int lhs, isfun F)
{
  NspObject *obj;
  CheckRhs (1,1);
  CheckLhs (0,1);
  if ((obj =nsp_get_object(stack,1))== NULLOBJ) return RET_BUG; 
  if ( nsp_move_boolean(stack,1,F(obj)) == FAIL )  return RET_BUG; 
  return 1;
}

static int int_scicos_is_split(Stack stack, int rhs, int opt, int lhs)
{
  return int_scicos_is(stack,rhs,opt,lhs,scicos_is_split);
}
static int int_scicos_is_block(Stack stack, int rhs, int opt, int lhs)
{
  return int_scicos_is(stack,rhs,opt,lhs,scicos_is_block);
}

static int int_scicos_is_text(Stack stack, int rhs, int opt, int lhs)
{
  return int_scicos_is(stack,rhs,opt,lhs,scicos_is_text);
}

static int int_scicos_is_link(Stack stack, int rhs, int opt, int lhs)
{
  return int_scicos_is(stack,rhs,opt,lhs,scicos_is_link);
}

static int int_scicos_is_modelica_block(Stack stack, int rhs, int opt, int lhs)
{
  return int_scicos_is(stack,rhs,opt,lhs,scicos_is_modelica_block);
}

extern const char *scicos_get_sim(NspObject *obj) ;

static int int_scicos_is_super(Stack stack, int rhs, int opt, int lhs)
{
  NspSMatrix *S;
  int rep=FALSE,i;
  const char *sim1;
  NspObject *obj;
  CheckRhs (2,2);
  CheckLhs (0,1);
  if ((obj =nsp_get_object(stack,1))== NULLOBJ) return RET_BUG; 
  if ((S = GetSMat(stack,2))== NULL) return RET_BUG; 
  if (( sim1 = scicos_get_sim(obj))== NULL) 
    {
      if ( nsp_move_boolean(stack,1,FALSE) == FAIL )  return RET_BUG; 
      return 1;
    }
  for ( i= 0 ; i < S->mn; i++)
    {
      if ( strcmp(S->S[i],sim1)==0) 
	{
	  rep=TRUE;
	  break;
	}
    }
  if ( nsp_move_boolean(stack,1,rep) == FAIL )  return RET_BUG; 
  return 1;
}


extern int scicos_count_blocks(NspObject *obj);

static int int_scicos_count_blocks(Stack stack, int rhs, int opt, int lhs)
{
  int n;
  NspObject *obj;
  CheckRhs (1,1);
  CheckLhs (0,1);
  if ((obj =nsp_get_object(stack,1))== NULLOBJ) return RET_BUG; 
  n = scicos_count_blocks(obj);
  if ( nsp_move_double(stack,1,n) == FAIL )  return RET_BUG; 
  return 1;
}



static OpTab Scicos_func[] = {
  {"scicos_count_blocks", int_scicos_count_blocks},
  {"scicos_is_split", int_scicos_is_split},
  {"scicos_is_block", int_scicos_is_block},
  {"scicos_is_text", int_scicos_is_text},
  {"scicos_is_link", int_scicos_is_link},
  {"scicos_is_modelica_block", int_scicos_is_modelica_block},
  {"scicos_is_super", int_scicos_is_super},
  {"sci_tree4", int_scicos_ftree4},
  {"sci_sctree", int_sctree},
  {"sci_tree2", int_tree2},
  {"sci_tree3", int_tree3},
  {"scicos_debug", int_scicos_debug},
  {"scicosim", int_scicos_sim},
  {"curblock", int_curblock},
  {"setblockerror", int_setblockerror},
  {"time_scicos", int_time_scicos},
  {"scicos_time", int_time_scicos},
  {"duplicate", int_duplicate},
  {"xproperty", int_xproperty},
  {"phase_simulation", int_get_phase_simulation},
  {"setxproperty", int_setxproperty},
  {"scicos_debug_count", int_scicos_debug_count},
  {"buildouttb", int_buildouttb},
  {"scicos_about", int_scicos_about},
  {"scicos_get_internal_name", int_scicos_get_internal_name },
  {"coserror", int_coserror},

  {"model2blk", int_model2blk},
  {"callblk", int_callblk},

  /* utilities */
  {"rat",int_rat},
  {"ppol",int_ppol},
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


static void nsp_simul_error_msg(int err_code,int *curblk)
{
  switch (err_code)
    {
    case 1  : Scierror("Error: scheduling problem");
      *curblk=0;
      break;
    case 2  : Scierror("Error: input to zero-crossing stuck on zero");
      *curblk=0;
      break;
    case 3  : Scierror("Error: event conflict");
      *curblk=0;
      break;
    case 4  : Scierror("Error: algrebraic loop detected");
      *curblk=0;
      break;
    case 5  : Scierror("Error: cannot allocate memory");
      *curblk=0;
      break;
    case 6  : Scierror("Error:the block %d has been called with input out of its domain",*curblk);
      break;
    case 7  : Scierror("Error: singularity in a block");
      break;
    case 8  : Scierror("Error: block produces an internal error");
      break;
    case 10  : /* nothnig to do here the error message was 
		* already performed in a block through a Coserror 
		* which call Scierror
		*/
      break;
    case 20  : Scierror("Error: initial conditions not converging");
      *curblk=0;
      break;
    case 21  : Scierror("Error: cannot allocate memory in block=%d",*curblk);
      *curblk=0;
      break;
    case 22  : Scierror("Error: sliding mode condition, cannot integrate");
      *curblk=0;
      break;
    case 23  : Scierror("Error: Cannot find the initial mode, maybe there is a sliding mode condition");
      *curblk=0;
      break;
    case 24  : Scierror("Error: You have changed a parameter in your model, but the model has been "
			"compiled to use an XML file containing initial values and parameters. "
			"So you should either recompile your Scicos diagram or [re]launch the "
			"initialization interface to regenerate the XML file  with new parameters.");
      *curblk=0;
      break;
    case 25  : Scierror("Error: Undefined data type.");
      *curblk=0;
      break;
    case 26  : Scierror("Error: The number of parameters provided by Scicos blocks is different from"
			"the number expected by the code generated by the Modelica compiler."
			"You might have relaxed a parameter using FIXED property (i.e., fixed=false) "
			"in a Modelica model. "
			"This will be corrected in the next version.");
      *curblk=0;
      break;
    case 33:
      Scierror ("Error: sliding mode condition, cannot integrate");
      break;

      /*In this case, you need to turn off the parameter embedded code generation mode by setting 
       * Modelica_ParEmb=%f in the Scilab command window, and  recompile the Scicos diagram
       */

      /* IDA error messages*/
    case 201  : Scierror("Error: IDA_MEM_NULL:The argument ida_mem was NULL");
      *curblk=0;
      break;
    case 202  : Scierror("Error: IDA_ILL_INPUT: One of the input arguments was illegal. "
			 "This errors message may be returned if the linear solver function initialization "
			 "(called by the user after calling IDACreate) failed to set the linear "
			 "solver-specific lsolve field in ida_mem.");
      *curblk=0;
      break;
    case 203  : Scierror("Error: IDA_NO_MALLOC: indicating that ida_mem was not allocated.");
      *curblk=0;
      break;
    case 204  : Scierror("Error: IDA_TOO_MUCH_WORK: The solver took mxstep internal"
			 " steps but could not reach tout. "
			 "The default value for mxstep is MXSTEP_DEFAULT = 500.");
      *curblk=0;
      break;
    case 205  : Scierror("Error: IDA_TOO_MUCH_ACC: The solver could not satisfy the accuracy "
			 "demanded by the user for some internal step.");
      *curblk=0;
      break;
    case 206  : Scierror("Error: IDA_ERR_FAIL: Error test failures occurred too many times "
			 "(=MXETF = 10) during one internal step or occurred with |h|=h_min");
      *curblk=0;
      break;
    case 207  : Scierror("Error: IDA_CONV_FAIL: IDACalcIC->Failed to get convergence of the Newton iterations. "
			 "Or IDA_solve->Convergence test failures occurred too many times"
			 " (= MXNCF = 10) during one internal step.");
      *curblk=0;
      break;
    case 208  : Scierror("Error: IDA_LINIT_FAIL: The linear solver''s initialization routine failed.");
      *curblk=0;
      break;
    case 209  : Scierror("Error: IDA_LSETUP_FAIL: The linear solver''s setup routine had a non-recoverable error.");
      *curblk=0;
      break;
    case 210  : Scierror("Error: IDA_LSOLVE_FAIL: The linear solver''s solve routine had a non-recoverable error.");
      *curblk=0;
      break;
    case 211  : Scierror("Error: IDA_RES_FAIL: The user''s residual routine returned a non-recoverable error flag.");
      *curblk=0;
      break;
    case 212  : Scierror("Error: IDA_CONSTR_FAIL: IDACalcIC was unable to find a solution"
			 " satisfying the inequality constraints.");
      *curblk=0;
      break;
    case 213  : Scierror("Error: IDA_REP_RES_ERR: The user''s residual function repeatedly returned a "
			 "recoverable error flag, but the solver was unable to recover.");
      *curblk=0;
      break;
    case 214  : Scierror("Error: IDA_MEM_FAIL: A memory allocation failed.");
      *curblk=0;
      break;
    case 215  : Scierror("Error: IDA_BAD_T: t is not in the interval [tn-hu,tn].");
      *curblk=0;
      break;
    case 216  : Scierror("Error: IDA_BAD_EWT: Some component of the error weight vector is zero (illegal), "
			 "either for the input value of y0 or a corrected value.");
      *curblk=0;
      break;
    case 217  : Scierror("Error: IDA_FIRST_RES_FAIL: The user''s residual routine returned  a recoverable "
			 "error flag on the first call, but IDACalcIC was unable to recover.");
      *curblk=0;
      break;
    case 218  : Scierror("Error: IDA_LINESEARCH_FAIL: The Linesearch algorithm failed to find a solution "
			 "with a step larger than steptol in weighted RMS norm.");
      *curblk=0;
      break;
    case 219  : Scierror("Error: IDA_NO_RECOVERY: The user''s residual routine, or the linear solver''s "
			 "setup or solve routine had a  recoverable error, "
			 "but IDACalcIC was unable to recover.");
      *curblk=0;
      break;
    case 220  : Scierror("Error: IDA_RTFUNC_FAIL: The root founding function failed.");
      *curblk=0;
      break;
    case 228  : Scierror("Error: IDA_YOUT_NULL: ''yout'' = NULL illegal.");
      *curblk=0;
      break;
    case 229  : Scierror("Error: IDA_TRET_NULL: ''tret'' = NULL illegal.");
      *curblk=0;
      break;
    case 230  : Scierror("Error: IDA_BAD_ITASK: Illegal value for itask.");
      *curblk=0;
      break;
    case 231  : Scierror("Error: IDA_NO_ESTOP: itask = IDA_NORMAL_TSTOP or itask ="
			 " IDA_ONE_STEP_TSTOP but tstop was not set");
      *curblk=0;
      break;
    case 232  : Scierror("Error: IDA_BAD_H0: h0 and tout - t0 inconsistent.");
      *curblk=0;
      break;
    case 233  : Scierror("Error: IDA_BAD_TSTOP: tstop is behind current simulation time"
			 " in the direction of integration.");
      *curblk=0;
      break;
    case 234  : Scierror("Error: IDA_BAD_INIT_ROOT: Root found at and very near initial t.");
      *curblk=0;
      break;
    case 235  : Scierror("Error: IDA_NO_EFUN: itol = IDA_WF but no EwtSet function was provided.");
      *curblk=0;
      break;
    case 236  : Scierror("Error: IDA_EWT_FAIL: The user-provide EwtSet function failed.");
      *curblk=0;
      break;
    case 237  : Scierror("Error: IDACalc cannot find the initial condition at this point. "
			 "If you are using a Modelica model, you can try with the "
			 "initialization GUI to try with other nonlinear solvers.");
      *curblk=0;
      break;
    case 238  : Scierror("Error: IDA_LSOLVE_NULL: The linear solver''s solve routine is NULL.");
      *curblk=0;
      break;
    case 239  : Scierror("Error: IDA_NULL_Y0: y0 = NULL illegal.");
      *curblk=0;
      break;
    case 240  : Scierror("Error: IDA_BAD_ITOL:Illegal value for itol. The legal values are IDA_SS, IDA_SV, and IDA_WF.");
      *curblk=0;
      break;
    case 241  : Scierror("Error: IDA_NULL_F: user supplied ODE routine is (NULL) illegal.");
      *curblk=0;
      break;
    case 242  : Scierror("Error: IDA_BAD_NVECTOR: A required vector operation is not implemented.");
      *curblk=0;
      break;
    case 243  : Scierror("Error: IDA_NULL_ABSTOL: absolute tolerances is = NULL illegal.");
      *curblk=0;
      break;
    case 244  : Scierror("Error: IDA_BAD_RELTOL: relative tolerances is reltol < 0 illegal.");
      *curblk=0;
      break;
    case 245  : Scierror("Error: IDA_BAD_ABSTOL: abstol has negative component(s) (illegal).");
      *curblk=0;
      break;
    case 246  : Scierror("Error: IDA_NULL_G: user supplied zero-crossing routine is (NULL) illegal..");
      *curblk=0;
      break;
    case 247  : Scierror("Error: IDA_BAD_TOUT: Trouble interpolating. ''tout'' too far"
			 " back in direction of integration");
      *curblk=0;
      break;
    case 248  : Scierror("Error: IDA_YP0_NULL: the derivative yp0 = NULL is illegal.");
      *curblk=0;
      break;
    case 249  : Scierror("Error: IDA_RES_NULL: th returned residual res = NULL is illegal.");
      *curblk=0;
      break;
    case 250  : Scierror("Error: IDA_YRET_NULL: yret = NULL illegal..");
      *curblk=0;
      break;
    case 251  : Scierror("Error: IDA_YPRET_NULL: yret = NULL illegal..");
      *curblk=0;
      break;
    case 252  : Scierror("Error: IDA_BAD_HINIT: yret = NULL illegal..");
      *curblk=0;
      break;
    case 253  : Scierror("Error: IDA_MISSING_ID :id = NULL (''id'' defines algebraic and"
			 " differential states) but suppressalg option on.");
      *curblk=0;
      break;
    case 254  : Scierror("Error: IDA_Y0_FAIL_CONSTR: y0 fails to satisfy constraints.");
      *curblk=0;
      break;
    case 255  : Scierror("Error: IDA_TOO_CLOSE: ''tout'' too close to ''t0'' to start integration.");
      *curblk=0;
      break;
    case 256  : Scierror("Error: IDA_CLOSE_ROOTS: Root found at and very near starting time.");
      *curblk=0;
      break;
    case 257  : Scierror("Error: IDA_Residual_NAN: The residual function returns NAN.");
      *curblk=0;
      break;
    case 258  : Scierror("Error: IDA_Rootfunction_NAN: The Root function returns NAN.");
      *curblk=0;
      break;
      /* CVODE error messages*/
    case 301  : Scierror("Error: CV_TOO_MUCH_WORK: The solver took mxstep internal steps"
			 " but could not reach ''tout''. "
			 "The default value for mxstep is MXSTEP_DEFAULT = 500.");
      *curblk=0;
      break;
    case 302  : Scierror("Error: CV_TOO_MUCH_ACC: The solver could not satisfy the accuracy"
			 " demanded by the user for some internal step");
      *curblk=0;
      break;
    case 303  : Scierror("Error: CV_ERR_FAILURE: Error test failures occurred too many times "
			 "(=MXETF = 7) during one internal step or occurred with |h|=h_min ");
      *curblk=0;
      break;
    case 304  : Scierror("Error: CV_CONV_FAILURE: Convergence test failures occurred too many times "
			 "(= MXNCF = 10) during one internal time step or occurred with |h| = hmin.");
      *curblk=0;
      break;
    case 305  : Scierror("Error: CV_LINIT_FAIL: The linear solver''s initialization function failed.");
      *curblk=0;
      break;
    case 306  : Scierror("Error: CV_LSETUP_FAIL: The linear solver''s setup routine failed"
			 " in an unrecoverable manner.");
      *curblk=0;
      break;
    case 307  : Scierror("Error: CV_LSOLVE_FAIL: The linear solver''s solve routine failed"
			 " in an unrecoverable manner.");
      *curblk=0;
      break;
    case 308  : Scierror("Error: CV_RHSFUNC_FAIL: The right-hand side function (user supplied ODE)"
			 " failed in an unrecoverable manner");
      *curblk=0;
      break;
    case 309  : Scierror("Error: CV_FIRST_RHSFUNC_ERR: The right-hand side function (user supplied ODE) "
			 "had a recoverable error at th efirst call");
      *curblk=0;
      break;
    case 310  : Scierror("Error: CV_REPTD_RHSFUNC_ERR: Convergence tests occurred too many times due to repeated "
			 "recoverable errors in the right-hand side function (user supplied ODE). This error "
			 "may be raised due to repeated  recoverable errors during the estimation of an "
			 "initial step size.");
      *curblk=0;
      break;
    case 311  : Scierror("Error: CV_UNREC_RHSFUNC_ERR: The right-hand side function (user supplied ODE) had "
			 "a recoverable error, but no recovery was possible.");
      *curblk=0;
      break;
    case 312  : Scierror("Error: CV_RTFUNC_FAIL: The rootfinding routine failed in an unrecoverable manner.");
      *curblk=0;
      break;
    case 320  : Scierror("Error: CV_MEM_FAIL: a memory allocation failed, including an attempt to increase maxord");
      *curblk=0;
      break;
    case 321  : Scierror("Error: CV_MEM_NULL: the cvode memory was NULL");
      *curblk=0;
      break;
    case 322  : Scierror("Error: CV_ILL_INPUT: indicating an input argument was illegal. "
			 "This include the situation where a component of the error weight vector becomes "
			 "negative during internal time-stepping. This also includes if the linear solver "
			 "function initialization (called by the user after calling CVodeCreat) failed to "
			 "set the linear solver-specific ''lsolve'' field in cvode_mem. This error happens "
			 "if number of root functions is positive but the return surface value is NULL.");
      *curblk=0;
      break;
    case 323  : Scierror("Error: CV_NO_MALLOC: indicating that cvode_mem has not been allocated "
			 "(i.e., CVodeMalloc has not been called).");
      *curblk=0;
      break;
    case 324  : Scierror("Error: CV_BAD_K: k (the order of the derivative of y to be computed) "
			 "is not in the range 0, 1, ..., qu, where qu is the order last used");
      break;
    case 325  : Scierror("Error: CV_BAD_T: t is not in the interval [tn-hu,tn].");
      *curblk=0;
      break;
    case 326  : Scierror("Error: CV_BAD_DKY:  The dky argument was NULL. dky is the output"
			 " derivative vector [((d/dy)^k)y](t).");
      *curblk=0;
      break;
    case 327  : Scierror("Error: CV_TOO_CLOSE: ''tout'' too close to ''t0'' to start integration.");
      *curblk=0;
      break;
    case 328  : Scierror("Error: CV_YOUT_NULL: ''yout'' = NULL illegal.");
      *curblk=0;
      break;
    case 329  : Scierror("Error: CV_TRET_NULL: ''tret'' = NULL illegal.");
      *curblk=0;
      break;
    case 330  : Scierror("Error: CV_BAD_ITASK: Illegal value for itask.");
      *curblk=0;
      break;
    case 331  : Scierror("Error: CV_NO_ESTOP: itask = CV_NORMAL_TSTOP or itask = CV_ONE_STEP_TSTOP"
			 " but tstop was not set");
      *curblk=0;
      break;
    case 332  : Scierror("Error: CV_BAD_H0: h0 and tout - t0 inconsistent.");
      *curblk=0;
      break;
    case 333  : Scierror("Error: CV_BAD_TSTOP: tstop is behind current simulation time in the direction of integration.");
      *curblk=0;
      break;
    case 334  : Scierror("Error: CV_BAD_INIT_ROOT: Root found at and very near initial t.");
      *curblk=0;
      break;
    case 335  : Scierror("Error: CV_NO_EFUN: itol = CV_WF but no EwtSet function was provided.");
      *curblk=0;
      break;
    case 336  : Scierror("Error: CV_EWT_FAIL: The user-provide EwtSet function failed.");
      *curblk=0;
      break;    
    case 337  : Scierror("Error: CV_BAD_EWT: Initial ewt has component(s) equal to zero (illegal).");
      *curblk=0;
      break;    
    case 338  : Scierror("Error: CV_LSOLVE_NULL: The linear solver''s solve routine is NULL.");
      *curblk=0;
      break;
    case 339  : Scierror("Error: CV_NULL_Y0: y0 = NULL illegal.");
      *curblk=0;
      break;
    case 340  : Scierror("Error: CV_BAD_ITOL:Illegal value for itol. The legal values are CV_SS, CV_SV, and CV_WF.");
      *curblk=0;
      break;
    case 341  : Scierror("Error: CV_NULL_F: user supplied ODE routine is (NULL) illegal.");
      *curblk=0;
      break;
    case 342  : Scierror("Error: CV_BAD_NVECTOR: A required vector operation is not implemented.");
      *curblk=0;
      break;
    case 343  : Scierror("Error: CV_NULL_ABSTOL: absolute tolerances is = NULL illegal.");
      *curblk=0;
      break;
    case 344  : Scierror("Error: CV_BAD_RELTOL: relative tolerances is reltol < 0 illegal.");
      *curblk=0;
      break;
    case 345  : Scierror("Error: CV_BAD_ABSTOL: abstol has negative component(s) (illegal).");
      *curblk=0;
      break;
    case 346  : Scierror("Error: CV_NULL_G: user supplied zero-crossing routine is (NULL) illegal..");
      *curblk=0;
      break;
    case 347  : Scierror("Error: CV_BAD_TOUT: Trouble interpolating. ''tout'' too far"
			 " back in direction of integration.");
      *curblk=0;
      break;
    case 348  : Scierror("Error: CV_CLOSE_ROOTS: Root found at and very near starting time.");
      *curblk=0;
      break;
    case 349  : Scierror("Error: CV_Derivative_NAN: The Derivatives returned by blocks are NAN.");
      *curblk=0;
      break;
    case 350  : Scierror("Error: CV_Rootfunction_NAN: The Root function returns NAN.");
      *curblk=0;
      break;
    case 401  : Scierror("Error: KIN_MEM_NULL: An error in the memory allocation in KINCreate or KINMalloc.");
      *curblk=0;
      break;
    case 402  : Scierror("Error: KIN_ILL_INPUT: A supplied parameter is invalid (check error message).");
      *curblk=0;
      break;
    case 403  : Scierror("Error: KIN_NO_MALLOC: Additional system memory has not yet been  allocated"
			 " for vector storage (forgot to call the  KINMalloc routine).");
      *curblk=0;
      break;
    case 404  : Scierror("Error: KIN_MEM_FAIL: An error occurred during memory allocation "
			 "either insufficient system resources are available "
			 "or the vector kernel has not yet been initialized.");
      *curblk=0;
      break;
    case 405  : Scierror("Error: KIN_LINESEARCH_NONCONV:  The line-search algorithm was unable to find "
			 "an iterate sufficiently distinct from the current iterate failure to satisfy "
			 "the sufficient decrease condition could mean the current iterate "
			 "is close to an approximate solution of the given nonlinear system,"
			 "the finite-difference  approximation "
			 "of the matrix-vector product  J(u)*v is inaccurate, or the real scalar"
			 " scsteptol is too large.");
      *curblk=0;
      break;
    case 406  : Scierror("Error: KIN_MAXITER_REACHED: The maximum number of nonlinear iterations has been reached.");
      *curblk=0;
      break;
    case 407  : Scierror("Error: KIN_MXNEWT_5X_EXCEEDE: Five consecutive steps have been taken that"
			 " satisfy the following inequality: "
			 "||uscale*p||_L2 > 0.99*mxnewtstep where p denotes the current step and "
			 "mxnewtstep is a real scalar upper bound on the scaled step length such "
			 "a failure may mean ||fscale*func(u)||_L2 asymptotes "
			 "from above to a finite value, or the real scalar mxnewtstep is too small.");
      *curblk=0;
      break;
    case 408 : Scierror("Error: KIN_LINESEARCH_BCFAI: The line search algorithm (KINLineSearch) was unable"
			"to satisfy the beta-condition for MXNBCF + 1 nonlinear iterations"
			"(not necessarily consecutive), "
			"which may indicate the algorithm is making  poor progress.");
      *curblk=0;
      break;

    case 409  : Scierror("Error: KIN_LINSOLV_NO_RECOVERY: The user-supplied routine psolve encountered"
			 "a recoverable error,but the preconditioner is already current.");
      *curblk=0;
      break;

    case 410  : Scierror("Error: KIN_LINIT_FAIL: The linear solver initialization routine (linit)"
			 " encountered an error.");
      break;

    case 411  : Scierror("Error: KIN_LSETUP_FAIL: The user-supplied routine pset (used to compute"
			 "the preconditioner) encountered an unrecoverable error.");
      *curblk=0;
      break;

    case 412  : Scierror("Error: KIN_LSOLVE_FAIL: Either the user-supplied routine psolve (used to to solve the "
			 "preconditioned linear system) encountered an unrecoverable error, or the linear "
			 "solver routine (lsolve) encountered an error condition.");
      *curblk=0;
      break;

    case 413   : Scierror("Error: KIN_SYSFUNC_FAIL: Error in the computing function. Please verify your model.");
      *curblk=0;
      break;

    case 414   : Scierror("Error: KIN_FIRST_SYSFUNC_ERR: The system function failed at the first call. "
			  "Please verify your model. There might be an error in the computing function, "
			  "for example a function may be called with illegal inputs.");
      *curblk=0;
      break;

    case 415   : Scierror("Error: KIN_REPTD_SYSFUNC_ERR: The system function failed repeatedly. "
			  "Please verify your model. There might be an error in the computing function, "
			  "for example a function may be called with illegal inputs");
      *curblk=0;
      break;

    case 416  :  Scierror("Error: KIN_NAN_ERR: The residual function returns NAN. "
			  "Please verify your model: some functions might be called with illegal inputs.");
      *curblk=0;
      break;

    case 501  :  Scierror("Error: LSODAR_TOO_MUCH_WORK: an excessive amount of work (more than mxstep steps) "
			  "was done on this call, before completing the requested task, but the integration"
			  " was otherwise successful as far as t. "
			  "(mxstep is an optional input and is normally 500.) to continue, the user may"
			  "simply reset istate to a value .gt. 1 "
			  "and call again (the excess work step counter will be reset to 0). "
			  "In addition, the user may increase mxstep to avoid this error return");
      *curblk=0;
      break;

    case 502  :  Scierror("Error: LSODAR_TOO_MUCH_ACC: too much accuracy was requested for the precision "
			  "of the machine being used. "
			  "This was detected before completing the requested task, but the integration "
			  "was successful as far as t. "
			  "To continue, the tolerance parameters must be reset, and istate must be set to 3. "
			  "The optional output tolsf may be used for this purpose. "
			  "(note.. if this condition is detected before taking any steps, then an illegal "
			  "input return (istate = -3) occurs instead.)");
      *curblk=0;
      break;

    case 503  :  Scierror("Error: LSODAR_ILL_INPUT: illegal input was detected, before taking any integration steps. "
			  "See written message for details. "
			  "Note..  if the solver detects an infinite loop of calls to the solver with illegal"
			  " input, it will cause the run to stop.");
      *curblk=0;
      break;

    case 504  :  Scierror("Error: LSODAR_ERR_FAILURE: there were repeated error test failures on one "
			  "attempted step, before completing the requested  task, "
			  "but the integration was successful as far as t. "
			  "The problem may have a singularity, or the input  may be inappropriate.");
      *curblk=0;
      break;

    case 505  :  Scierror("Error: LSODAR_CONV_FAILURE: there were repeated convergence test failures on "
			  "one attempted step, before completing the requested task, "
			  "but the integration was successful as far as t. "
			  "This may be caused by an inaccurate jacobian matrix, if one is being used.");
      *curblk=0;
      break;

    case 506  :  Scierror("Error: LSODAR_BAD_EWT: ewt(i) became zero for some i during the integration. "
			  "Pure relative error control (atol(i)=0.0) was requested on a variable which "
			  "has now vanished. "
			  "The integration was successful as far as t.");
      *curblk=0;
      break;

    case 507  :  Scierror("Error: LSODAR_I_R_HOT_SHORT: the length of rwork and/or iwork was too small to proceed,"
			  "but the integration was successful as far as t. "
			  "This happens when lsodar chooses to switch methods but lrw and/or liw is too small "
			  "for the new method.");
      *curblk=0;
      break;

    case 551  :  Scierror("Error: DOPRI5: The Dopri5 solver cannot converge. Two much steps have been taken.");
      *curblk=0;
      break; /* DP5_TOO_MUCH_WORK defined in dopri5m.h*/

    case 555  :  Scierror("Error: DOPRI5: the step size becomes too small.");
      *curblk=0;
      break; /*DP5_CONV_FAILURE defined in dopri5m.h*/

    default:
      if(err_code >= 1000)
	{
	  Scierror ("Error: unknown or erroneous block\n");
	}
      else if (err_code >= 100)
	{
	  int istate = -(err_code - 100);
	  Scierror ("Error: integration problem istate=\"%d\"\n", istate);
	}
      else
	{
	  Scierror ("Error: scicos unexpected error,please report...\n");
	}
      break;
    }
}
  


