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
 * scicos objects used for simulation 
 *--------------------------------------------------------------------------*/

#include <math.h>
#include <stdio.h>
#include <string.h>

#include "nsp/machine.h"
#include "nsp/matrix-in.h"
#include "nsp/bmatrix-in.h"
#include "scicos/scicos4.h"

static void scicos_clear_state (scicos_sim * scst);
static void scicos_clear_sim (scicos_sim * scsim);
static void scicos_clear_blocks (scicos_block * Blocks, int nblk);
static int scicos_fill_state (NspHash * State, scicos_sim * scst);
static int scicos_fill_sim (NspHash * Sim, scicos_sim * scsim);
static int scicos_fill_from_list (NspList * L, scicos_list_flat * F);

/*
 * fill a scicos_state structure 
 * with pointers from the Hash table State 
 * 
 */

static int scicos_fill_state (NspHash * State, scicos_sim * scst)
{
  int i;
  /* take care that the state names must follow the same 
   * order as in simul44.h int the scicos_sim structure 
   */
  void **loc = (void **) &scst->x;
  const int nstate = 8;
  char *state[] =
    { "x", "z", "oz", "iz", "tevts", "evtspt", "pointi", "outtb" };
  int state_check[] = { 1, 1, 0, 1, 1, 1, 1, 0 };
  if (loc + nstate - 1 != (void *) &scst->outtbl)
    {
      Scierror ("Error: internal error in scicos_fill_state !!\n");
      return FAIL;
    }
  /* keep track of original data */
  scst->State = State;
  for (i = 0; i < nstate; i++)
    {
      NspObject *obj;
      if (nsp_hash_find (State, state[i], &obj) == FAIL)
	return FAIL;
      scst->State_elts[i] = obj;
      if (state_check[i] == 1)
	{
	  if (IsMat (scst->State_elts[i]) == FALSE)
	    return FAIL;
	  if (((NspMatrix *) scst->State_elts[i])->rc_type != 'r')
	    {
	      Scierror ("Elements are supposed to be real matrice\n");
	      return FAIL;
	    }
	  /* put the pointer in the struct */
	  loc[i] = (void *) ((NspMatrix *) scst->State_elts[i])->R;
	}
    }
  /* in place conversion */
  scst->State_elts[5] = Mat2int ((NspMatrix *) scst->State_elts[5]);	/* evtspt */
  scst->State_elts[6] = Mat2int ((NspMatrix *) scst->State_elts[6]);	/* pointi */
  /* constants */
  scst->nevts = ((NspMatrix *) scst->State_elts[5])->m;	/* evtspt */

  /* oz */
  if (IsList (scst->State_elts[2]))
    {
      scicos_list_flat F;
      F.use_elems = FALSE;
      if (scicos_fill_from_list ((NspList *) scst->State_elts[2], &F) == FAIL)
	return FAIL;
      scst->noz = F.n;
      scst->ozptr = F.ptr;
      scst->ozsz = F.sz;
      scst->oztyp = F.type;
    }
  else
    {
      Scierror ("Error: oz should be a list \n");
      return FAIL;
    }

  /* outtb */

  if (IsList (scst->State_elts[7]))
    {
      scicos_list_flat F;
      F.use_elems = TRUE;
      if (scicos_fill_from_list ((NspList *) scst->State_elts[7], &F) == FAIL)
	return FAIL;
      scst->nlnk = F.n;
      scst->outtbptr = F.ptr;
      scst->outtbsz = F.sz;
      scst->outtbtyp = F.type;
      scst->nelem = F.nelem;
      scst->elems = F.elems;
    }
  else
    {
      Scierror ("Error: oz should be a list \n");
      return FAIL;
    }

  /* extra allocations */
  if ((scst->iwa = malloc (sizeof (int) * (scst->nevts))) == NULL)
    {
      Scierror ("Error: running out of memory in state allocation\n");
      scicos_clear_state (scst);
      return FAIL;
    }
  return OK;
}

/* from list of objects to arrays  */

static int scicos_fill_from_list (NspList * L, scicos_list_flat * F)
{
  int i;
  Cell *L_cell = L->first;
  F->n = nsp_list_length (L), i = 0;
  if (F->n == 0)
    {
      F->ptr = NULL;
      F->sz = NULL;
      F->type = NULL;
      F->nelem = 0;
      F->elems = NULL;
      return OK;
    }
  /*Allocation of outtbptr */
  F->ptr = malloc (F->n * sizeof (void *));
  F->sz = malloc (F->n * 2 * sizeof (int));
  F->type = malloc (F->n * sizeof (int));
  if (F->ptr == NULL || F->sz == NULL || F->type == NULL)
    {
      Scierror ("Error: failed to allocate memory for outtb\n");
      return FAIL;
    }
  F->nelem = 0;
  for (i = 0; i < F->n; i++)
    {
      NspObject *Obj = L_cell->O;
      if (Obj == NULLOBJ)
	{
	  Scierror ("Error: outtb(%d) is a null object\n", i + 1);
	  return FAIL;
	}
      if (IsMat (Obj))
	{
	  NspMatrix *A = (NspMatrix *) Obj;
	  F->sz[i] = A->m;
	  F->sz[i + F->n] = A->n;
	  if (A->rc_type == 'r')
	    {
	      F->type[i] = SCSREAL_N;
	      F->ptr[i] = A->R;
	    }
	  else
	    {
	      F->type[i] = SCSCOMPLEX_N;
	      F->ptr[i] = A->C;
	    }
	}
      else if (IsIMat (Obj))
	{
	  NspIMatrix *A = (NspIMatrix *) Obj;
	  F->sz[i] = A->m;
	  F->sz[i + F->n] = A->n;
	  switch (A->itype)
	    {
	    case nsp_gint:
	      F->type[i] = SCSINT32_N;
	      break;
	    case nsp_guint:
	      F->type[i] = SCSUINT32_N;
	      break;
	    case nsp_gint8:
	      F->type[i] = SCSINT8_N;
	      break;
	    case nsp_guint8:
	      F->type[i] = SCSUINT8_N;
	      break;
	    case nsp_gint16:
	      F->type[i] = SCSINT16_N;
	      break;
	    case nsp_guint16:
	      F->type[i] = SCSUINT16_N;
	      break;
	    case nsp_gint32:
	      F->type[i] = SCSINT32_N;
	      break;
	    case nsp_guint32:
	      F->type[i] = SCSUINT32_N;
	      break;
	    default:
	      Scierror ("Error: outtb(%d) has an unsupported integer type\n",
			i + 1);
	      return FAIL;
	    }
	}
      else
	{
	  Scierror ("Error: outtb(%d) is not a real or int matrix\n", i + 1);
	  return FAIL;
	}
      L_cell = L_cell->next;
      F->nelem += F->sz[i] * F->sz[i + F->n];
    }
  /* now if requested fills elems */
  if (F->use_elems == TRUE)
    {
      int k;
      if ((F->elems = malloc (F->nelem * sizeof (outtb_el))) == NULL)
	{
	  Scierror ("Error:  No more free memory.\n");
	  return FAIL;
	}
      k = 0;
      for (i = 0; i < F->n; i++)
	{
	  int l, lmax = F->sz[i] * F->sz[i + F->n];
	  for (l = 0; l < lmax; l++)
	    {
	      F->elems[k + l].lnk = i;
	      F->elems[k + l].pos = l;
	    }
	  k += lmax;
	}
    }
  return OK;
}


/*
 * clear extra allocated variables and 
 * restore the data to their original state 
 */

static void scicos_clear_state (scicos_sim * scst)
{
  FREE (scst->iwa);
  Mat2double ((NspMatrix *) scst->State_elts[5]);
  Mat2double ((NspMatrix *) scst->State_elts[6]);
}

/* get a copy of the state NspHash *State 
 * variable (this is useful during simulation) 
 * to debug. 
 */

NspHash *scicos_get_state_copy (scicos_sim * scst)
{
  return nsp_hash_copy ((NspHash *) scst->State);
}

/*
 * fill a scicos_sim structure 
 * with pointers from the Hash table Sim 
 */

static int scicos_fill_sim (NspHash * Sim, scicos_sim * scsim)
{
  /* indices of sim variables which are to be converted to int 
   * note that indices start at 0 (0 is "funs") 
   */
  const int convert[] =
    { 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22,
      23, 24, 25, 26, 27, 29, 31, -1 };
  const int nsim = 32;
  int i, count;
  void **loc = (void **) &scsim->funs;
  NspList *funs;
  Cell *cloc;

  char *sim[] = { "funs", "xptr", "zptr", "zcptr", "inpptr",
		  "outptr", "inplnk", "outlnk", "ozptr", "rpar",
		  "rpptr", "ipar", "ipptr", "clkptr", "ordptr",
		  "execlk", "ordclk", "cord", "oord", "zord",
		  "critev", "nb", "ztyp", "nblk", "ndcblk",
		  "subscr", "funtyp", "iord", "labels", "modptr",
		  "opar", "opptr"
  };

  if (loc + nsim - 1 != (void *) &scsim->opptr)
    {
      Scierror ("Error: internal error in scicos_fill_sim !!\n");
      return FAIL;
    }

  /* get everything as if it was Matrices except 
   * for funs, labels and opar 
   */

  for (i = 0; i < nsim; i++)
    {
      NspObject *obj;
      if (nsp_hash_find (Sim, sim[i], &obj) == FAIL)
	return FAIL;
      scsim->Sim_elts[i] = obj;
      if (loc + i != (void *) &scsim->funs
	  && loc + i != (void *) &scsim->labels
	  && loc + i != (void *) &scsim->opar)
	loc[i] = (void *) ((NspMatrix *) scsim->Sim_elts[i])->R;
    }

  scsim->Sim = Sim;
  /* convert to int in place */
  i = 0;
  while (1)
    {
      int j;
      if ((j = convert[i]) == -1)
	break;
      scsim->Sim_elts[j] = Mat2int (scsim->Sim_elts[j]);
      i++;
    }
  /* take care of labels and funs */
  funs = scsim->funs = scsim->Sim_elts[0];
  scsim->labels = ((NspSMatrix *) scsim->Sim_elts[28])->S;	/* labels */
  /* initialize to NULL in case of fail */
  scsim->mod = NULL;
  scsim->funflag = NULL;
  scsim->funptr = NULL;
  /* size of funptr */
  scsim->nblk = *scsim->nblkptr;
  if ((scsim->funflag = malloc (scsim->nblk * sizeof (int))) == NULL)
    goto fail;
  if ((scsim->funptr = malloc (scsim->nblk * sizeof (void *))) == NULL)
    goto fail;
  /*
   * scsim->Sim_elts[0] is a list of chars or functions 
   */
  funs = (NspList *) scsim->Sim_elts[0];
  cloc = funs->first;
  count = 0;
  while (cloc != NULLCELL)
    {
      if (cloc->O != NULLOBJ)
	{
	  if (count >= scsim->nblk)
	    {
	      Scierror ("Error: funs lenght should be %d\n", scsim->nblk);
	      goto fail;
	    }
	  if (IsString (cloc->O))
	    {
	      void *fptr =
		scicos_get_function (((NspSMatrix *) cloc->O)->S[0]);
	      if (fptr != NULL)
		{
		  /* a hard code function given by its adress */
		  scsim->funflag[count] = fun_pointer;
		  scsim->funptr[count] = fptr;
		}
	      else
		{
		  /* a macros given ny its name */
		  scsim->funflag[count] = fun_macro_name;
		  scsim->funptr[count] = ((NspSMatrix *) cloc->O)->S[0];
		}
	    }
	  else if (IsNspPList (cloc->O))
	    {
	      /* a macro given by a pointer to its code */
	      scsim->funflag[count] = fun_macros;
	      scsim->funptr[count] = cloc->O;
	    }
	  else
	    {
	      Scierror ("Error: funs should contain strings or macros\n");
	      goto fail;
	    }
	}
      count++;
      cloc = cloc->next;
    }

  /* get the opar variable and make an array version */

  if (IsList (scsim->Sim_elts[30]))
    {
      scicos_list_flat F;
      F.use_elems = FALSE;
      if (scicos_fill_from_list ((NspList *) scsim->Sim_elts[30], &F) == FAIL)
	return FAIL;
      scsim->nopar = F.n;
      scsim->oparptr = F.ptr;
      scsim->oparsz = F.sz;
      scsim->opartyp = F.type;
    }
  else
    {
      Scierror ("Error: opar should be a list \n");
      return FAIL;
    }

  /* a set of constants */
  /* scsim->nlnkptr =  ((NspMatrix *) scsim->Sim_elts[8])->m; *//* lnkptr */
  scsim->nordptr = ((NspMatrix *) scsim->Sim_elts[14])->mn;	/* ordptr  */
  scsim->ncord = ((NspMatrix *) scsim->Sim_elts[17])->m;	/* cord */
  scsim->niord = ((NspMatrix *) scsim->Sim_elts[27])->m;	/* iord */
  scsim->noord = ((NspMatrix *) scsim->Sim_elts[18])->m;	/* oord */
  scsim->nzord = ((NspMatrix *) scsim->Sim_elts[19])->m;	/* zord */
  /* scsim->nblk =  *scsim->nblkptr; already done */
  scsim->ndcblk = *scsim->ndcblkptr;
  scsim->nsubs = ((NspMatrix *) scsim->Sim_elts[25])->m;	/* subscr */

  scsim->nmod = scsim->modptr[scsim->nblk] - 1;
  scsim->nordclk = scsim->ordptr[-1 + scsim->nordptr] - 1;
  /*     computes number of zero crossing surfaces */
  scsim->ng = scsim->zcptr[scsim->nblk] - 1;
  /*     number of  discrete real states */
  scsim->nz = scsim->zptr[scsim->nblk] - 1;
  /*     number of continuous states */
  scsim->nx = scsim->xptr[scsim->nblk] - 1;

  scsim->debug_block = -1;	/* no debug block for start */

  /* extra arguments allocated here */
  if (scsim->nmod > 0)
    {
      if ((scsim->mod = malloc (sizeof (int) * scsim->nmod)) == NULL)
	{
	  scicos_clear_sim (scsim);
	  Scierror ("Error: running out of memory in block allocations\n");
	  goto fail;
	}
    }

  /* to be move in fill_sim */

  if (scsim->nx > 0)
    {
      if ((scsim->xprop =
	   malloc (sizeof (int) * scsim->nx +
		   sizeof (double) * scsim->nx * 2)) == NULL)
	{
	  scicos_clear_sim (scsim);
	  Scierror ("Error: running out of memory in block allocations\n");
	  goto fail;
	}
      scsim->alpha = (double *) (scsim->xprop + scsim->nx);
      scsim->beta = (double *) (scsim->alpha + scsim->nx);
      for (i = 0; i < scsim->nx; i++)
	scsim->xprop[i] = 1;
    }

  if (scsim->nmod > 0)
    {
      if ((scsim->mod = MALLOC (sizeof (int) * scsim->nmod)) == NULL)
	{
	  scicos_clear_sim (scsim);
	  Scierror ("Error: running out of memory in block allocations\n");
	  goto fail;
	}
    }

  if (scsim->ng > 0)
    {
      if ((scsim->g = malloc (sizeof (double) * scsim->ng)) == NULL)
	{
	  scicos_clear_sim (scsim);
	  Scierror ("Error: running out of memory in block allocations\n");
	  goto fail;
	}
    }

  return OK;
 fail:
  scicos_clear_sim (scsim);
  return FAIL;
}

/*
 * clear extra allocated variables and 
 * restore the data to their original state 
 */

static void scicos_clear_sim (scicos_sim * scsim)
{
  int i = 0;
  const int convert[] =
    { 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22,
      23, 24, 25, 26, 27, 29, 31, -1 };
  FREE (scsim->funflag);
  FREE (scsim->funptr);
  FREE (scsim->mod);
  FREE (scsim->ozptr);
  FREE (scsim->ozsz);
  FREE (scsim->oztyp);
  
  FREE (scsim->outtbptr );
  FREE (scsim->outtbsz );
  FREE (scsim->outtbtyp );
  FREE (scsim->elems );

  while (1)
    {
      int j;
      if ((j = convert[i]) == -1)
	break;
      Mat2double (scsim->Sim_elts[j]);
      i++;
    }
}


/* get a copy of the state NspHash *State 
 * variable (this is useful during simulation) 
 * to debug. 
 */

NspHash *scicos_get_sim_copy (scicos_sim * scsim)
{
  return nsp_hash_copy ((NspHash *) scsim->Sim);
}

/*
 * creates and fills an array of Blocks.
 */

static void *scicos_fill_blocks (scicos_sim * scsim, scicos_sim * scst)
{
  int kf, in, out;
  scicos_block *Blocks = NULL;

  if ((Blocks = calloc (scsim->nblk, sizeof (scicos_block))) == NULL)
    {
      Scierror ("Error: running out of memory in block allocations\n");
      return NULL;
    }

  for (kf = 0; kf < scsim->nblk; ++kf)
    {
      int b_type = scsim->funtyp[kf];
      Blocks[kf].type =
	(b_type < 10000) ? (b_type % 1000) : b_type % 1000 + 10000;

      if (scsim->funflag[kf] == fun_pointer)
	{
	  Blocks[kf].scsptr = NULL;
	  Blocks[kf].funpt = scsim->funptr[kf];
	  Blocks[kf].scsptr_flag = scsim->funflag[kf];
	}
      else
	{
	  /* a NspObject containing a macro or a macro name */
	  Blocks[kf].scsptr = scsim->funptr[kf];
	  Blocks[kf].scsptr_flag = scsim->funflag[kf];
	  /* the function is a macro or it is a Debug block */
	  switch (scsim->funtyp[kf])
	    {
	    case 0:
	      Blocks[kf].funpt = scicos_sciblk;
	      break;
	    case 1:
	    case 2:
	      Scierror
		("Error: block %d, type %d function not allowed for scilab blocks\n",
		 kf + 1, scsim->funtyp[kf]);
	      scicos_clear_blocks (Blocks, kf + 1);
	      return NULL;
	    case 3:
	      Blocks[kf].funpt = scicos_sciblk2;
	      Blocks[kf].type = 2;
	      break;
	    case 5:
	      Blocks[kf].funpt = scicos_sciblk4;
	      Blocks[kf].type = 4;
	      break;
	    case 99:		/* debugging block */
	      Blocks[kf].funpt = scicos_sciblk4;
	      Blocks[kf].type = 4;
	      scsim->debug_block = kf;
	      break;
	    case 10005:
	      Blocks[kf].funpt = scicos_sciblk4;
	      Blocks[kf].type = 10004;
	      break;
	    default:
	      Scierror ("Error:block %d, Undefined Function type %d\n",
			kf + 1, scsim->funtyp[kf]);
	      scicos_clear_blocks (Blocks, kf + 1);
	      return NULL;
	    }
	}
      Blocks[kf].ztyp = scsim->ztyp[kf];
      Blocks[kf].nx = scsim->xptr[kf + 1] - scsim->xptr[kf];
      Blocks[kf].ng = scsim->zcptr[kf + 1] - scsim->zcptr[kf];
      Blocks[kf].nz = scsim->zptr[kf + 1] - scsim->zptr[kf];
      Blocks[kf].noz = scsim->oziptr[kf + 1] - scsim->oziptr[kf];
      Blocks[kf].nrpar = scsim->rpptr[kf + 1] - scsim->rpptr[kf];
      Blocks[kf].nipar = scsim->ipptr[kf + 1] - scsim->ipptr[kf];
      Blocks[kf].nopar = scsim->opptr[kf + 1] - scsim->opptr[kf];
      Blocks[kf].nin = scsim->inpptr[kf + 1] - scsim->inpptr[kf];	/* number of input ports */
      Blocks[kf].nout = scsim->outptr[kf + 1] - scsim->outptr[kf];	/* number of output ports */

      /* in insz, we store :
       *  - insz[0..nin-1] : first dimension of input ports
       *  - insz[nin..2*nin-1] : second dimension of input ports
       *  - insz[2*nin..3*nin-1] : type of data of input ports
       */
      Blocks[kf].insz = NULL;
      Blocks[kf].inptr = NULL;
      if (Blocks[kf].nin != 0)
	{
	  Blocks[kf].insz = malloc (Blocks[kf].nin * 3 * sizeof (int));
	  Blocks[kf].inptr = malloc (Blocks[kf].nin * sizeof (double *));
	  if (Blocks[kf].insz == NULL || Blocks[kf].inptr == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }
	  /* Attention ici faut-il decaller les indices 
	   * par rapport � scilab pour inpptr sans doute oui 
	   * d�calage d'indice ? XXXXXXX */

	  for (in = 0; in < Blocks[kf].nin; in++)
	    {
	      int lprt = scsim->inplnk[scsim->inpptr[kf] + in - 1];
	      Blocks[kf].inptr[in] = scst->outtbptr[lprt - 1];
	      Blocks[kf].insz[in] = scst->outtbsz[lprt - 1];
	      Blocks[kf].insz[Blocks[kf].nin + in] =
		scst->outtbsz[(lprt - 1) + scst->nlnk];
	      Blocks[kf].insz[2 * Blocks[kf].nin + in] =
		scst->outtbtyp[lprt - 1];
	    }

	}

      /* in outsz, we store :
       *  - outsz[0..nout-1] : first dimension of output ports
       *  - outsz[nout..2*nout-1] : second dimension of output ports
       *  - outsz[2*nout..3*nout-1] : type of data of output ports
       */
      Blocks[kf].outsz = NULL;
      Blocks[kf].outptr = NULL;
      if (Blocks[kf].nout != 0)
	{
	  Blocks[kf].outsz = malloc (Blocks[kf].nout * 3 * sizeof (int));
	  Blocks[kf].outptr = malloc (Blocks[kf].nout * sizeof (double *));

	  if (Blocks[kf].outsz == NULL || Blocks[kf].outptr == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }

	  /* Attention ici faut-il decaller les indices 
	   * par rapport � scilab pour outptr sans doute oui 
	   * d�calage d'indice ? XXXXXXX 
	   */

	  for (out = 0; out < Blocks[kf].nout; out++)
	    {
	      int lprt = scsim->outlnk[scsim->outptr[kf] + out - 1];
	      Blocks[kf].outptr[out] = scst->outtbptr[lprt - 1];
	      Blocks[kf].outsz[out] = scst->outtbsz[lprt - 1];
	      Blocks[kf].outsz[Blocks[kf].nout + out] =
		scst->outtbsz[(lprt - 1) + scst->nlnk];
	      Blocks[kf].outsz[2 * Blocks[kf].nout + out] =
		scst->outtbtyp[lprt - 1];
	    }
	}

      /* evtout */
      Blocks[kf].nevout = scsim->clkptr[kf + 1] - scsim->clkptr[kf];
      Blocks[kf].evout = NULL;
      if (Blocks[kf].nevout != 0)
	{
	  Blocks[kf].evout = calloc (Blocks[kf].nevout, sizeof (double));
	  if (Blocks[kf].evout == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }
	}

      /* z */
      Blocks[kf].z = &(scst->z[scsim->zptr[kf] - 1]);
      /* oz */
      Blocks[kf].ozsz = NULL;
      if (Blocks[kf].noz == 0)
	{
	  Blocks[kf].ozptr = NULL;
	  Blocks[kf].oztyp = NULL;
	}
      else
	{
	  int i;
	  /* XXXX pas clair */
	  Blocks[kf].ozptr = &(scst->ozptr[scsim->oziptr[kf] - 1]);
	  Blocks[kf].ozsz = malloc (Blocks[kf].noz * 2 * sizeof (int));
	  if (Blocks[kf].ozsz == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }

	  for (i = 0; i < Blocks[kf].noz; i++)
	    {
	      Blocks[kf].ozsz[i] = scst->ozsz[(scsim->oziptr[kf] - 1) + i];
	      Blocks[kf].ozsz[i + Blocks[kf].noz] =
		scst->ozsz[(scsim->oziptr[kf] - 1 + scst->noz) + i];
	    }
	  Blocks[kf].oztyp = &(scst->oztyp[scsim->oziptr[kf] - 1]);
	}

      Blocks[kf].rpar = &(scsim->rpar[scsim->rpptr[kf] - 1]);
      Blocks[kf].ipar = &(scsim->ipar[scsim->ipptr[kf] - 1]);

      /* opar */
      if (Blocks[kf].nopar == 0)
	{
	  Blocks[kf].oparsz = NULL;
	  Blocks[kf].oparptr = NULL;
	  Blocks[kf].opartyp = NULL;
	}
      else
	{
	  int i;
	  Blocks[kf].oparptr = &(scsim->oparptr[scsim->opptr[kf] - 1]);
	  Blocks[kf].oparsz = malloc (Blocks[kf].nopar * 2 * sizeof (int));
	  if (Blocks[kf].oparsz == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }
	  for (i = 0; i < Blocks[kf].nopar; i++)
	    {
	      Blocks[kf].oparsz[i] =
		scsim->oparsz[(scsim->opptr[kf] - 1) + i];
	      Blocks[kf].oparsz[i + Blocks[kf].nopar] =
		scsim->oparsz[(scsim->opptr[kf] - 1 + scsim->nopar) + i];
	    }
	  Blocks[kf].opartyp = &(scsim->opartyp[scsim->opptr[kf] - 1]);
	}
      /* res */
      Blocks[kf].res = NULL;
      Blocks[kf].res_init = NULL;
      if (Blocks[kf].nx != 0)
	{
	  Blocks[kf].res_init = Blocks[kf].res = malloc (Blocks[kf].nx * sizeof (double));
	  if (Blocks[kf].res == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }
	}

      /* label */
      Blocks[kf].label = scsim->labels[kf];

      /* jroot */
      Blocks[kf].jroot = NULL;
      if (Blocks[kf].ng != 0)
	{
	  if ((Blocks[kf].jroot =
	       calloc (Blocks[kf].ng, sizeof (int))) == NULL)
	    {
	      scicos_clear_blocks (Blocks, kf + 1);
	      Scierror
		("Error: running out of memory in block allocations\n");
	      return NULL;
	    }
	}
      Blocks[kf].jroot_init = Blocks[kf].jroot;
      /* work */
      Blocks[kf].work = (void **) (scst->iz + kf);
      /* mode */
      Blocks[kf].nmode = scsim->modptr[kf + 1] - scsim->modptr[kf];
      if (Blocks[kf].nmode != 0)
	{
	  Blocks[kf].mode = &(scsim->mod[scsim->modptr[kf] - 1]);
	}
      /* xprop */
      Blocks[kf].xprop = NULL;
      Blocks[kf].alpha = NULL;
      Blocks[kf].beta = NULL;
      if (Blocks[kf].nx != 0)
	{
	  Blocks[kf].xprop = &(scsim->xprop[scsim->xptr[kf] - 1]);
	  Blocks[kf].alpha = &(scsim->alpha[scsim->xptr[kf] - 1]);
	  Blocks[kf].beta = &(scsim->beta[scsim->xptr[kf] - 1]);
	}
      /* g */
      Blocks[kf].g = NULL;
      if (Blocks[kf].ng != 0)
	{
	  Blocks[kf].g = &(scsim->g[scsim->zcptr[kf] - 1]);
	}

    }
  return Blocks;
}

static void scicos_clear_blocks (scicos_block * Blocks, int nblk)
{
  int kf;
  for (kf = 0; kf < nblk; ++kf)
    {
      FREE (Blocks[kf].insz);
      FREE (Blocks[kf].inptr);
      FREE (Blocks[kf].outsz);
      FREE (Blocks[kf].outptr);
      FREE (Blocks[kf].evout);
      /* take care that Blocks[kf].res is changed 
       * during the simulation. we keep initally 
       * allocated pointer in Blocks[kf].res_init
       */
      FREE (Blocks[kf].res_init);
      FREE (Blocks[kf].jroot_init);
      FREE (Blocks[kf].ozsz);
      FREE (Blocks[kf].oparsz);
    }
  FREE (Blocks);
}


int scicos_fill_run (scicos_run * sr, NspHash * Sim, NspHash * State)
{
  if (scicos_fill_state (State, &sr->sim) == FAIL)
    return FAIL;
  if (scicos_fill_sim (Sim, &sr->sim) == FAIL)
    {
      scicos_clear_state (&sr->sim);
      return FAIL;
    }
  if ((sr->Blocks = scicos_fill_blocks (&sr->sim, &sr->sim)) == NULL)
    {
      scicos_clear_state (&sr->sim);
      scicos_clear_sim (&sr->sim);
      return FAIL;
    }
  sr->status = run_on;
  return OK;
}

void scicos_clear_run (scicos_run * sr)
{
  scicos_clear_state (&sr->sim);
  scicos_clear_sim (&sr->sim);
  scicos_clear_blocks (sr->Blocks, sr->sim.nblk);
  sr->status = run_off;
}