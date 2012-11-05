/* Nsp
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

#include <string.h>
#include <nsp/nsp.h>
#include <nsp/object.h>
#include <scicos/simul4.h>

/* 
 * data structure selection 
 * Pointer to the beginning of the imported data 
 * nv,   size of the imported data 
 * type  type of the imported data 0:int,1:double 
 */

int scicos_getscicosvars (int what, double **v, int *nv, int *type)
{
  int nblk;
  if (Scicos->status == run_off)
    {
      *v = NULL;
      return (2);		/* undefined import table scicos is not running */
    }
  nblk = Scicos->sim.nblk;
  /* imported from */
  switch (what)
    {
    case 1:			/* continuous state */
      *nv = (int) (Scicos->sim.xptr[nblk] - Scicos->sim.xptr[0]);
      *v = (void *) (Scicos->sim.x);
      *type = 1;
      break;
    case 2:			/* continuous state splitting array */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.xptr);
      *type = 0;
      break;
    case 3:			/* continuous state splitting array */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.zcptr);
      *type = 0;
      break;
    case 4:			/* discrete state */
      *nv = (int) (Scicos->sim.zptr[nblk] - Scicos->sim.zptr[0]);
      *v = (void *) (Scicos->sim.z);
      *type = 1;
      break;
    case 5:			/* discrete  state splitting array */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.zptr);
      *type = 0;
      break;
    case 6:			/* rpar */
      *nv = (int) (Scicos->sim.rpptr[nblk] - Scicos->sim.rpptr[0]);
      *v = (void *) (Scicos->sim.rpar);
      *type = 1;
      break;
    case 7:			/* rpar  splitting array */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.rpptr);
      *type = 0;
      break;
    case 8:			/* ipar */
      *nv = (int) (Scicos->sim.ipptr[nblk] - Scicos->sim.ipptr[0]);
      *v = (void *) (Scicos->sim.ipar);
      *type = 0;
      break;
    case 9:			/* ipar  splitting array */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.ipptr);
      *type = 0;
      break;
    case 10:			/* outtb */
      /* A revoir XXX 
       *nv=(int)(Scicos->sim.nout);
       *v=(void *) (Scicos->sim.outtb);
       *type=1;
       */
      break;
    case 11:			/* inpptr */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.inpptr);
      *type = 0;
      break;
    case 12:			/* outptr */
      *nv = (int) (nblk + 1);
      *v = (void *) (Scicos->sim.outptr);
      *type = 0;
      break;
    case 13:			/* inplnk */
      *nv = (int) (Scicos->sim.inpptr[nblk] - Scicos->sim.inpptr[0]);
      *v = (void *) (Scicos->sim.inplnk);
      *type = 0;
      break;
    case 14:			/* outlnk */
      *nv = (int) (Scicos->sim.outptr[nblk] - Scicos->sim.outptr[0]);
      *v = (void *) (Scicos->sim.outlnk);
      *type = 0;
      break;
    case 15:			/* lnkptr */
      /* 
       *nv=(int)(Scicos->sim.nlnkptr);
       *v=(void *) (Scicos->sim.lnkptr); 
       *type=0;
       */
      break;
    }
  return (0);
}


char *scicos_getlabel (int kf)
{
  return Scicos->Blocks[kf - 1].label;
}


int scicos_get_block_by_label (const char *label)
{
  int nblk = Scicos->sim.nblk, k;
  for (k = 0; k < nblk; k++)
    {
      if (strcmp (Scicos->Blocks[k].label, label) == 0)
	return k + 1;
    }
  return 0;
}

int scicos_getscilabel (int kfun, char **label)
{
  if (Scicos->status == run_off)
    return FAIL;
  *label = Scicos->Blocks[kfun - 1].label;
  return OK;
}

int scicos_getcurblock (void)
{
  return Scicos->params.curblk;
}


/* used in fscope
 *
 * 30/06/06, Alan : Rewritte to preserve compatibility with fscope.f.
 * Only first element of matrix is delivred and converted to double data.
 *
 */

void scicos_getouttb (int nsize, int *nvec, double *outtc)
{
  /* declaration of ptr for typed port */
  void **outtbptr;		/*to store outtbptr */
  SCSREAL_COP *outtbdptr;	/*to store double of outtb */
  SCSINT8_COP *outtbcptr;	/*to store int8 of outtb */
  SCSINT16_COP *outtbsptr;	/*to store int16 of outtb */
  SCSINT32_COP *outtblptr;	/*to store int32 of outtb */
  SCSUINT8_COP *outtbucptr;	/*to store unsigned int8 of outtb */
  SCSUINT16_COP *outtbusptr;	/*to store unsigned int16 of outtb */
  SCSUINT32_COP *outtbulptr;	/*to store unsigned int32 of outtb */
  int outtb_nelem;		/*to store maximum number of element */
  int outtbtyp;			/*to store type of data */
  /*int *outtbsz;*/			/*to store size of data */
  outtb_el *outtb_elem;		/*to store ptr of outtb_elem structure */

  /*auxiliary variable */
  int j, lnk, pos;

  /*get outtbptr from import struct. */
  outtbptr = Scicos->sim.outtbptr;
  /*get outtb_elem from import struct. */
  outtb_elem = Scicos->sim.elems;
  /*get outtbsz from import struct. */
  /*outtbsz = Scicos->sim.outtbsz;*/
  /*get max number of elem in outtb */
  outtb_nelem = Scicos->sim.nelem;

  /*initialization of position in outtc */
  j = 0;

  while (j < nsize)
    {
      /*test to know if we are outside outtb_elem */
      if (nvec[j] > outtb_nelem)
	{
	  set_block_error (-1);
	  return;
	}

      lnk = outtb_elem[nvec[j] - 1].lnk;
      pos = outtb_elem[nvec[j] - 1].pos;
      outtbtyp = Scicos->sim.outtbtyp[lnk];

      /*double data type */
      if (outtbtyp == SCSREAL_N)
	{
	  outtbdptr = (SCSREAL_COP *) outtbptr[lnk];
	  outtc[j] = (double) outtbdptr[pos];
	  j++;
	}
      /*complex data type */
      else if (outtbtyp == SCSCOMPLEX_N)
	{
	  /*sz = outtbsz[2 * lnk] + outtbsz[(2 * lnk) + 1];*/
	  outtbdptr = (SCSCOMPLEX_COP *) outtbptr[lnk];
	  outtc[j] = (double) outtbdptr[pos];
	  /*outtc[j+1] =  (double)outtbdptr[pos+sz]; */
	  /*j=j+2; */
	  j++;
	}
      /*integer data type */
      else
	{
	  switch (outtbtyp)
	    {
	    case SCSINT8_N:
	      outtbcptr = (SCSINT8_COP *) outtbptr[lnk];	/*int8 */
	      outtc[j] = (double) outtbcptr[pos];
	      j++;
	      break;

	    case SCSINT16_N:
	      outtbsptr = (SCSINT16_COP *) outtbptr[lnk];	/*int16 */
	      outtc[j] = (double) outtbsptr[pos];
	      j++;
	      break;

	    case SCSINT32_N:
	      outtblptr = (SCSINT32_COP *) outtbptr[lnk];	/*int32 */
	      outtc[j] = (double) outtblptr[pos];
	      j++;
	      break;

	    case SCSUINT8_N:
	      outtbucptr = (SCSUINT8_COP *) outtbptr[lnk];	/*uint8 */
	      outtc[j] = (double) outtbucptr[pos];
	      j++;
	      break;

	    case SCSUINT16_N:
	      outtbusptr = (SCSUINT16_COP *) outtbptr[lnk];	/*uint16 */
	      outtc[j] = (double) outtbusptr[pos];
	      j++;
	      break;

	    case SCSUINT32_N:
	      outtbulptr = (SCSUINT32_COP *) outtbptr[lnk];	/*uint32 */
	      outtc[j] = (double) outtbulptr[pos];
	      j++;
	      break;

	    default:
	      outtc[j] = 0;
	      j++;
	      break;
	    }
	}
    }
}


void scicos_send_halt (void)
{
  if ( Scicos != NULL) 
    Scicos->params.halt = 1;
}
