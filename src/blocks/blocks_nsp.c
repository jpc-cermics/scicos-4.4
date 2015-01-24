/* Nsp
 * Copyright (C) 2007-2011 Ramine Nikoukhah (Inria) 
 *               See the note at the end of banner
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
 * Scicos blocks copyrighted GPL in this version by Ramine Nikoukhah
 * this code was obtained by f2c + manual modification (Jean-Philippe Chancelier).
 * Some blocks have specific authors which are named in the code. 
 * 
 *--------------------------------------------------------------------------*/

/* This module encloses set of 'old' scicos blocks
 * related to nsp-scicos implementation
 */

#include <nsp/nsp.h> 
#include <nsp/object.h>
#include <nsp/matrix.h>
#include <nsp/smatrix.h>
#include <nsp/hash.h>
#include <nsp/file.h>
#include <nsp/libstab.h>
#include <nsp/gtk/gobject.h>	/* FIXME: nsp_gtk_eval_function */
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "../librand/grand.h"	/* rand_ranf() */
#include "../system/files.h"	/*  FSIZE */
#include "blocks.h"

/*  For block */

void scicos_forblk_block (scicos_args_F0)
{
  scicos_run *Scicos=scicos_get_scicos_run();
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 3)
    {
      if (*nevprt == 1)
	{
	  z__[2] = u[1];
	  z__[1] = 1.;

	  if (u[1] >= 1.)
	    {
	      tvec[1] = *t - 1.;
	      tvec[2] = *t + Scicos->params.ttol / 2.;
	    }
	  else
	    {
	      tvec[1] = *t - 1.;
	      tvec[2] = *t - 1.;
	    }
	}
      else
	{
	  z__[1] += 1.;

	  if (z__[1] >= z__[2])
	    {
	      tvec[1] = *t + Scicos->params.ttol / 2.;
	      tvec[2] = *t - 1.;
	    }
	  else
	    {
	      tvec[1] = *t - 1.;
	      tvec[2] = *t + Scicos->params.ttol / 2.;
	    }
	}
    }
  if (*flag__ == 1 || *flag__ == 3)
    {
      y[1] = z__[1];
    }
}

/*     Notify simulation to stop  when called 
 *     ipar(1) : stop reference 
 */


void scicos_hltblk_block (scicos_args_F0)
{
  scicos_run *Scicos=scicos_get_scicos_run();
  if (*flag__ == 2)
    {
      Scicos->params.halt = 1;
      z__[0] = (*nipar > 0) ? (double) ipar[0] : 0.0;
    }

}

/* extracted from libst.c */

static int st_ulaw_to_linear (unsigned char ulawbyte)
{
  static int exp_lut[8] = { 0, 132, 396, 924, 1980, 4092, 8316, 16764 };
  int sign, exponent, mantissa, sample;

  ulawbyte = ~ulawbyte;
  sign = (ulawbyte & 0x80);
  exponent = (ulawbyte >> 4) & 0x07;
  mantissa = ulawbyte & 0x0F;
  sample = exp_lut[exponent] + (mantissa << (exponent + 3));
  if (sign != 0)
    sample = -sample;
  return sample;
}

void scicos_readau_block (scicos_args_F2);

void scicos_readau_block (int *flag, int *nevprt, const double *t, double *xd,
			  double *x, int *nx, double *z, int *nz,
			  double *tvec, int *ntvec, double *rpar, int *nrpar,
			  int *ipar, int *nipar, double **inptr, int *insz,
			  int *nin, double **outptr, int *outsz, int *nout)
{
  /* ipar=[len : file name length,  ipar[2:4] = fmt  : numbers type ascii code,
   *       unused, nchannels, swap, first : first record to read, 
   *       ipar[10:9+lfil] character codes for file name]
   */
  typedef struct _readau_ipar readau_ipar;
  struct _readau_ipar
  {
    int len, fmt[3], ievt, n, maxvoie, swap, first, fname;
  };
  readau_ipar *wi = (readau_ipar *) ipar;
  NspFile *F;
  int n, k, kmax, nread, m, i, mu;
  double *buffer;
  unsigned long offset;
  --z;
  F = (NspFile *) NSP_POINTER_CAST_TO_INT z[3];
  buffer = (z + 4);

  /*
   *  k    : record counter within the buffer
   *  kmax :  number of records in the buffer
   */

  if (*flag == 1)
    {
      unsigned char *record = (unsigned char *) buffer;
      n = wi->n;
      k = (int) z[1];
      /* copy current record to output */
      record += (k - 1) * wi->maxvoie;
      for (i = 0; i < *nout; i++)
	{
	  mu = st_ulaw_to_linear (record[i]);
	  *outptr[i] = mu / 32768.0;
	}
      if (*nevprt > 0)
	{
	  /*     discrete state */
	  kmax = (int) z[2];
	  if (k >= kmax && kmax == n)
	    {
	      m = wi->n * wi->maxvoie;
	      /* assuming 8-bits mu-law */
	      if (nsp_mget (F, buffer, m, "uc", &nread) == FAIL)
		goto read_fail;
	      /* XXX : check eof */
	      kmax = wi->n;
	      z[1] = 1.0;
	      z[2] = kmax;
	    }
	  else if (k < kmax)
	    z[1] = z[1] + 1.0;
	}
    }
  else if (*flag == 4)
    {
      char str[FSIZE];
      int i;
      unsigned int au_format;
      /* get the file name from its ascii code  */
      for (i = 0; i < wi->len; i++)
	str[i] = *(&wi->fname + i);
      str[wi->len] = '\0';
      if ((F = nsp_file_open (str, "rb", FALSE, wi->swap)) == NULL)
	{
	  Scierror
	    ("Error: in scicos_readau_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  return;
	}
      z[3] = NSP_POINTER_CAST_TO_INT F;
      /* read the header */
      if (nsp_mget (F, buffer, 4, "c", &nread) == FAIL)
	goto read_fail;
      if (strncmp ((char *) buffer, ".snd", 4) != 0)
	goto read_fail;
      if (nsp_mget (F, buffer, 1, "ulb", &nread) == FAIL)
	goto read_fail;		/* offset */
      offset = *((unsigned int *) buffer);
      if (nsp_mget (F, buffer, 1, "ulb", &nread) == FAIL)
	goto read_fail;		/* databytes */
      if (nsp_mget (F, buffer, 1, "ulb", &nread) == FAIL)
	goto read_fail;		/* format */
      au_format = *((unsigned int *) buffer);
      if (nsp_mget (F, buffer, 1, "ulb", &nread) == FAIL)
	goto read_fail;		/* rate */
      if (nsp_mget (F, buffer, 1, "ulb", &nread) == FAIL)
	goto read_fail;		/* channels */
      if (nsp_fseek (F, offset - 24, "set") == FAIL)
	goto read_fail;		/* last comment */
      if (au_format != 1)
	goto read_fail;		/* assuming 8-bits au-law */
      /* skip first records */
      if (wi->first > 1)
	{
	  offset = (wi->first - 1) * wi->maxvoie * sizeof (char);
	  if (nsp_fseek (F, offset, "set") == FAIL)
	    goto read_fail;	/* last comment */
	}
      /* read data in buffer */
      m = wi->n * wi->maxvoie;
      /* assuming 8-bits mu-law */
      if (nsp_mget (F, buffer, m, "uc", &nread) == FAIL)
	goto read_fail;
      /* XXXXX eof reached is to be done */
      kmax = wi->n;
      z[1] = 1.0;
      z[2] = kmax;
    }
  else if (*flag == 5)
    {
      if (z[3] == 0)
	return;
      nsp_file_close (F);
      nsp_file_destroy (F);
      z[3] = 0.0;
    }
  return;
 read_fail:
  Scierror ("Error: in scicos_readau_block, read error \n");
  *flag = -1;
  nsp_file_close (F);
  nsp_file_destroy (F);
  z[3] = 0.0;
  return;

}





#undef ZEROTRAP			/* turn off the trap as per the MIL-STD */
#define uBIAS 0x84		/* define the add-in bias for 16 bit samples */
#define uCLIP 32635
#define ACLIP 31744

static unsigned char st_linear_to_ulaw (int sample)
{
  static int exp_lut[256] = { 0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
			      4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
			      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
			      5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
			      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
			      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
			      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
			      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
			      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
  };
  int sign, exponent, mantissa;
  unsigned char ulawbyte;

  /* Get the sample into sign-magnitude. */
  sign = (sample >> 8) & 0x80;	/* set aside the sign */
  if (sign != 0)
    sample = -sample;		/* get magnitude */
  if (sample > uCLIP)
    sample = uCLIP;		/* clip the magnitude */

  /* Convert from 16 bit linear to ulaw. */
  sample = sample + uBIAS;
  exponent = exp_lut[(sample >> 7) & 0xFF];
  mantissa = (sample >> (exponent + 3)) & 0x0F;
  ulawbyte = ~(sign | (exponent << 4) | mantissa);
#ifdef ZEROTRAP
  if (ulawbyte == 0)
    ulawbyte = 0x02;		/* optional CCITT trap */
#endif
  return ulawbyte;
}

void scicos_writeau_block (scicos_args_F2);

void scicos_writeau_block (int *flag, int *nevprt, const double *t,
			   double *xd, double *x, int *nx, double *z, int *nz,
			   double *tvec, int *ntvec, double *rpar, int *nrpar,
			   int *ipar, int *nipar, double **inptr, int *insz,
			   int *nin, double **outptr, int *outsz, int *nout)
{
  /* ipar=[len : file name length,  ipar[2:4] = fmt  : numbers type ascii code,
   *       n, swap, ipar[10:9+lfil] character codes for file name]
   */
  typedef struct _writeau_ipar writeau_ipar;
  struct _writeau_ipar
  {
    int len, fmt[3], n, swap, fname;
  };
  writeau_ipar *wi = (writeau_ipar *) ipar;
  NspFile *F;
  int n, k, i;
  double *buffer;
  const int SCALE = 32768;
  --z;
  F = (NspFile *) NSP_POINTER_CAST_TO_INT z[2];
  buffer = (z + 3);
  /*
   *    k    : record counter within the buffer
   */
  if (*flag == 2 && *nevprt > 0)
    {
      unsigned char *record = (unsigned char *) buffer;
      /* add a new record to the buffer */
      n = wi->n;
      k = (int) z[1];
      record += (k - 1) * (*nin);
      for (i = 0; i < *nin; i++)
	{
	  record[i] = st_linear_to_ulaw ((int) (SCALE * (*inptr[i])));
	}
      if (k < n)
	z[1] = z[1] + 1.0;
      else
	{
	  if (nsp_mput (F, buffer, wi->n * (*nin), "uc") == FAIL)
	    goto write_fail;	/* offset */
	  z[1] = 1.0;
	}
    }
  else if (*flag == 4)
    {
      char str[FSIZE];
      int i;
      unsigned int xx;
      /* get the file name from its ascii code  */
      for (i = 0; i < wi->len; i++)
	str[i] = *(&wi->fname + i);
      str[wi->len] = '\0';
      if ((F = nsp_file_open (str, "wb", FALSE, wi->swap)) == NULL)
	{
	  Scierror
	    ("Error: in scicos_readau_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  return;
	}
      z[2] = NSP_POINTER_CAST_TO_INT F;
      /* write the header */
      if (nsp_mput (F, ".snd", 4, "c") == FAIL)
	goto write_fail;
      xx = 24;
      if (nsp_mput (F, &xx, 1, "ulb") == FAIL)
	goto write_fail;	/* offset */
      xx = 0;
      if (nsp_mput (F, &xx, 1, "ulb") == FAIL)
	goto write_fail;	/* databytes (optional) */
      xx = 1;
      if (nsp_mput (F, &xx, 1, "ulb") == FAIL)
	goto write_fail;	/* format mu-law 8-bits */
      xx = 22050 / (*nin);
      if (nsp_mput (F, &xx, 1, "ulb") == FAIL)
	goto write_fail;	/* rate */
      xx = *nin;
      if (nsp_mput (F, &xx, 1, "ulb") == FAIL)
	goto write_fail;	/* channels */
      z[1] = 1.0;
    }
  else if (*flag == 5)
    {
      if (z[2] == 0)
	return;
      k = (int) z[1];
      if (k > 1)
	{
	  if (nsp_mput (F, buffer, (k - 1) * (*nin), "uc") == FAIL)
	    goto write_fail;	/* offset */
	}
      nsp_file_close (F);
      nsp_file_destroy (F);
      z[2] = 0.0;
    }
  return;
 write_fail:
  Scierror ("Error: in scicos_writedau_block, write error \n");
  *flag = -1;
  nsp_file_close (F);
  nsp_file_destroy (F);
  z[2] = 0.0;
  return;
}


/*
 * Write in ascii mode with format 
 * Note that the name is writef but the format 
 * should be a C-style format with just one directive 
 * the format is re-explored for each data 
 * default value "%lf" 
 */

void scicos_writef_block (scicos_args_F0);

void
scicos_writef_block (int *flag, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar,
		     int *nipar, double *u, int *nu, double *y, int *ny)
{
  /* ipar code model.ipar=[length(fname);length(format);unused;
   *                       N;str2code(fname);str2code(fmt)] 
   */
  typedef struct _writec_ipar writec_ipar;
  struct _writec_ipar
  {
    int len, lfmt, unu, n, fname, fmt;
  };
  writec_ipar *wi = (writec_ipar *) ipar;

  FILE *F;
  int k, i;
  double *buffer, *record;

  --z;
  F = (FILE *) NSP_POINTER_CAST_TO_INT z[2];
  buffer = (z + 3);
  /* k    : record counter within the buffer */
  k = (int) z[1];

  if (*flag == 2 && *nevprt > 0)
    {
      /* on first entry k == 1 
       * write t at position z[2+k]=t
       * and u[i] at position z[2+k+ N*(i+1)]=u[i]
       * stop if wi->n records are writen 
       */
      record = buffer + (k - 1);
      record[0] = *t;
      for (i = 0; i < *nu; i++)
	record[wi->n * (i + 1)] = *(u + i);
      if (k < wi->n)
	{
	  z[1] = z[1] + 1.0;
	}
      else
	{
	  char fmt[128];
	  int i, j;
	  /* converts the format from ascii to str */
	  if (wi->lfmt > 0)
	    {
	      for (i = 0; i < wi->lfmt; i++)
		fmt[i] = *(&wi->fmt + wi->len - 1 + i);
	      fmt[wi->lfmt] = '\0';
	    }
	  else
	    {
	      strcpy (fmt, "%10.3f");
	    }
	  /* write K sequence of (t,u1,....unu) */
	  for (j = 0; j < k; j++)
	    {
	      /* we reexplore the format */
	      fprintf (F, fmt, buffer[j]);	/* t */
	      fprintf (F, " ");
	      for (i = 0; i < *nu; i++)
		{
		  fprintf (F, fmt, buffer[j + wi->n * (i + 1)]);
		  fprintf (F, " ");
		}
	      fprintf (F, "\n");
	    }
	  /* in case of error *flag = -3;return */
	  z[1] = 1.0;
	}
    }
  else if (*flag == 4)
    {
      char str[FSIZE];
      char fname[FSIZE + 1];
      int i;
      /* get the file name from its ascii code  */
      for (i = 0; i < wi->len; i++)
	str[i] = *(&wi->fname + i);
      str[wi->len] = '\0';
      nsp_path_expand (str, fname, FSIZE);
      sciprint ("Trying to open [%s] in writef\n", str);
      if ((F = fopen (fname, "w")) == NULL)
	{
	  Scierror
	    ("Error: in scicos_writef_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  return;
	}
      z[2] = NSP_POINTER_CAST_TO_INT F;
      z[1] = 1.0;
    }
  else if (*flag == 5)
    {
      if (z[2] == 0)
	return;
      k = (int) z[1];
      if (k >= 1)
	{
	  char fmt[128];
	  int i, j;
	  /* converts the format from ascii to str */
	  if (wi->lfmt > 0)
	    {
	      for (i = 0; i < wi->lfmt; i++)
		fmt[i] = *(&wi->fmt + wi->len - 1 + i);
	      fmt[wi->lfmt] = '\0';
	    }
	  else
	    {
	      strcpy (fmt, "%10.3f");
	    }
	  /* write K sequence of (t,u1,....unu) */
	  for (j = 0; j < k - 1; j++)
	    {
	      /* we reexplore the format */
	      fprintf (F, fmt, buffer[j]);	/* t */
	      fprintf (F, " ");
	      for (i = 0; i < *nu; i++)
		{
		  fprintf (F, fmt, buffer[j + wi->n * (i + 1)]);
		  fprintf (F, " ");
		}
	      fprintf (F, "\n");
	    }
	}
      if ((fclose (F)) == FAIL)
	{
	  *flag = -3;
	  return;
	}
      z[2] = 0.0;
    }
  return;
}

/*
 * Write in binary mode 
 */


void scicos_writec_block (scicos_args_F2);

void
scicos_writec_block (int *flag, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar,
		     int *nipar, double **inptr, int *insz, int *nin,
		     double **outptr, int *outsz, int *nout)
{
  /* ipar code model.ipar=[length(fname);str2code(frmt);N;swap;str2code(fname)] */
  typedef struct _writec_ipar writec_ipar;
  struct _writec_ipar
  {
    int len, fmt[3], n, swap, fname;
  };
  writec_ipar *wi = (writec_ipar *) ipar;

  NspFile *F;
  int k, i;
  double *buffer, *record;

  --z;
  F = (NspFile *) NSP_POINTER_CAST_TO_INT z[2];
  buffer = (z + 3);
  k = (int) z[1];
  /*
   * k    : record counter within the buffer
   */

  if (*flag == 2 && *nevprt > 0)
    {
      /* add a new record to the buffer */
      /* copy current record to output */
      record = buffer + (k - 1) * (insz[0]);
      for (i = 0; i < insz[0]; i++)
	record[i] = *(inptr[0] + i);
      if (k < wi->n)
	{
	  z[1] = z[1] + 1.0;
	}
      else
	{
	  char type[4];
	  int i;
	  /* get the type from its ascii code  */
	  for (i = 0; i < 3; i++)
	    type[i] = wi->fmt[i];
	  type[3] = '\0';
	  /* buffer is full write it to the file */
	  if (nsp_mput (F, buffer, wi->n * insz[0], type) == FAIL)
	    {
	      *flag = -3;
	      return;
	    }
	  z[1] = 1.0;
	}
    }
  else if (*flag == 4)
    {
      char str[FSIZE];
      char fname[FSIZE + 1];
      int i;
      /* get the file name from its ascii code  */
      for (i = 0; i < wi->len; i++)
	str[i] = *(&wi->fname + i);
      str[wi->len] = '\0';
      nsp_path_expand (str, fname, FSIZE);
      sciprint ("Trying to open [%s] in writec\n", str);
      if ((F = nsp_file_open (fname, "wb", FALSE, wi->swap)) == NULL)
	{
	  Scierror
	    ("Error: in scicos_writec_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  return;
	}
      z[2] = NSP_POINTER_CAST_TO_INT F;
      z[1] = 1.0;
    }
  else if (*flag == 5)
    {
      if (z[2] == 0)
	return;
      k = (int) z[1];
      if (k >= 1)
	{
	  /* flush rest of buffer */
	  char type[4];
	  int i;
	  /* get the type from its ascii code  */
	  for (i = 0; i < 3; i++)
	    type[i] = wi->fmt[i];
	  type[3] = '\0';
	  if (nsp_mput (F, buffer, (k - 1) * insz[0], type) == FAIL)
	    {
	      *flag = -3;
	      nsp_file_close (F);
	      nsp_file_destroy (F);
	      z[2] = 0.0;
	      return;
	    }
	}
      if ((nsp_file_close (F)) == FAIL)
	{
	  *flag = -3;
	  nsp_file_destroy (F);
	  z[2] = 0.0;
	  return;
	}
      nsp_file_destroy (F);
      z[2] = 0.0;
    }
  return;
}

static int worldsize (char type[4])
{
  char c = (type[0] == 'u') ? type[1] : type[0];
  switch (c)
    {
    case 'l':
      return sizeof (long);
    case 's':
      return sizeof (short);
    case 'c':
      return sizeof (char);
    case 'd':
      return sizeof (double);
    case 'f':
      return sizeof (float);
    }
  return 0;
}

void scicos_readc_block (scicos_args_F2);

void scicos_readc_block (int *flag, int *nevprt, const double *t, double *xd,
			 double *x, int *nx, double *z, int *nz, double *tvec,
			 int *ntvec, double *rpar, int *nrpar, int *ipar,
			 int *nipar, double **inptr, int *insz, int *nin,
			 double **outptr, int *outsz, int *nout)
{
  /* ipar[1]   = lfil : file name length
   * ipar[2:4] = fmt  : numbers type ascii code
   * ipar[5]   = is there a time record
   * ipar[6]   = n : buffer length in number of records
   * ipar[7]   = maxvoie : record size
   * ipar[8]   = swap
   * ipar[9]   = first : first record to read
   * ipar[10:9+lfil] = character codes for file name
   * ipar[10+lfil:9+lfil++ny+ievt] = reading mask
   */
  typedef struct _readc_ipar readc_ipar;
  struct _readc_ipar
  {
    int len, fmt[3], ievt, n, maxvoie, swap, first, fname;
  };
  readc_ipar *wi = (readc_ipar *) ipar;
  NspFile *F;
  double *buffer, *record;
  int k, kmax, m, *mask, nread;
  long offset;
  --z;
  F = (NspFile *) NSP_POINTER_CAST_TO_INT z[3];
  buffer = (z + 4);

  /* pointer to the mask start position */
  mask = &wi->fname + wi->len;

  /*
   *    k  : record counter within the buffer
   *    kmax :  number of records in the buffer
   */

  if (*flag == 1)
    {
      char type[4];
      int i;
      /* get the type from its ascii code  */
      for (i = 0; i < 3; i++)
	type[i] = wi->fmt[i];
      for (i = 2; i >= 0; i--)
	if (type[i] == ' ')
	  type[i] = '\0';
      /* value of k */
      k = (int) z[1];
      /* copy current record to output */
      record = buffer + (k - 1) * wi->maxvoie;
      for (i = 0; i < outsz[0]; i++)
	*(outptr[0] + i) = record[mask[wi->ievt + i]];
      if (*nevprt > 0)
	{
	  /*     discrete state */
	  kmax = (int) z[2];
	  if (k >= kmax && kmax == wi->n)
	    {
	      /*     read a new buffer */
	      m = wi->n * wi->maxvoie;
	      if (nsp_mget (F, buffer, m, type, &nread) == FAIL)
		{
		  Scierror
		    ("Error: in scicos_readc_block, read error during fseek\n");
		  *flag = -1;
		  nsp_file_close (F);
		  nsp_file_destroy (F);
		  z[3] = 0.0;
		  return;
		}
	      if (nread < m)
		{
		  /* fill with zero when no more inputs */
		  int un = 1, nc = m - nread;
		  double zero = 0.0;
		  nsp_dset (&nc, &zero, buffer + nread, &un);
		}
	      kmax = wi->n;
	      z[1] = 1.0;
	      z[2] = kmax;
	    }
	  else if (k < kmax)
	    z[1] = z[1] + 1.0;
	}
    }
  else if (*flag == 3)
    {
      k = (int) z[1];
      kmax = (int) z[2];
      if (k > kmax && kmax < wi->n)
	{
	  if (wi->ievt)
	    tvec[0] = *t - 1.0;
	  else
	    tvec[0] = *t * (1.0 + 0.0000000001);
	}
      else
	{
	  record = buffer + (k - 1) * wi->maxvoie;
	  if (wi->ievt)
	    tvec[0] = record[mask[0]];
	}
    }
  else if (*flag == 4)
    {
      char type[4];
      char str[FSIZE + 1];
      char fname[FSIZE + 1];
      int i;
      /* get the file name from its ascii code  */
      for (i = 0; i < wi->len; i++)
	str[i] = *(&wi->fname + i);
      str[wi->len] = '\0';
      /* expand SCI,NSP,.... */
      nsp_path_expand (str, fname, FSIZE);
      sciprint ("Trying to open [%s] in readc\n", str);
      if ((F = nsp_file_open (fname, "rb", FALSE, wi->swap)) == NULL)
	{
	  Scierror
	    ("Error: in scicos_readc_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  return;
	}
      z[3] = NSP_POINTER_CAST_TO_INT F;

      /* get the type from its ascii code  */
      for (i = 0; i < 3; i++)
	type[i] = wi->fmt[i];
      for (i = 2; i >= 0; i--)
	if (type[i] == ' ')
	  type[i] = '\0';

      /* skip first records */
      if (wi->first > 1)
	{
	  offset = (wi->first - 1) * wi->maxvoie * worldsize (type);
	  if (nsp_fseek (F, offset, "set") == FAIL)
	    {
	      Scierror
		("Error: in scicos_readc_block, read error during fseek\n");
	      *flag = -1;
	      nsp_file_close (F);
	      nsp_file_destroy (F);
	      z[3] = 0.0;
	      return;
	    }
	}
      /* read first buffer */
      m = wi->n * wi->maxvoie;
      if (nsp_mget (F, buffer, m, type, &nread) == FAIL)
	{
	  Scierror ("Error: in scicos_readc_block, read error during mget\n");
	  *flag = -1;
	  nsp_file_close (F);
	  nsp_file_destroy (F);
	  z[3] = 0.0;
	  return;
	}
      if (nread < m)
	{
	  /* fill with last value when no more inputs */
	  int un = 1, nc = m - nread;
	  double zero = 0.0;
	  nsp_dset (&nc, &zero, buffer + nread, &un);
	}
      kmax = wi->n;
      z[1] = 1.0;
      z[2] = kmax;
    }
  else if (*flag == 5)
    {
      if (z[3] == 0)
	return;
      nsp_file_close (F);
      nsp_file_destroy (F);
      z[3] = 0.0;
    }
  return;
}

/* 
 *     read from a file with format 
 *     ipar(1) = lfil : file name length 
 *     ipar(2) = lfmt : format length (0) if binary file 
 *     ipar(3) = ievt  : 1 if each data have a an associated time 
 *     ipar(4) = N : buffer length 
 *     ipar(5:4+lfil) = character codes for file name 
 *     ipar(5+lfil:4+lfil+lfmt) = character codes for format if any 
 *     ipar(5+lfil+lfmt:5+lfil+lfmt+ny+ievt) = reading mask 
 */


typedef struct _readf_ipar readf_ipar;
struct _readf_ipar
{
  int lfil, lfmt, ievt, n, fname;
};

static int bfrdr (NspFile * F, readf_ipar * rf, int *ipar, double *z, int *no,
		  int *kmax);

void scicos_readf_block (scicos_args_F0);


void
scicos_readf_block (int *flag, int *nevprt, const double *t, double *xd,
		    double *x, int *nx, double *z, int *nz, double *tvec,
		    int *ntvec, double *rpar, int *nrpar, int *ipar,
		    int *nipar, double *u, int *nu, double *y, int *ny)
{
  /* ipar[1]   = lfil : file name length
   * ipar[2]   = lfmt  : format length (0 if binary file).
   * ipar[3]   = ievt : 1 if each data have a an associated time
   * ipar[4]   = n : buffer length in number of records
   * ipar[5:4+lfil]   = character codes for file name
   * ipar[5+lfil:4+lfil+lfmt]   =  character codes for format if any
   * ipar[5+lfil+lfmt:5+lfil+lfmt+ny+ievt]   = reading mask;
   */
  readf_ipar *rf = (readf_ipar *) ipar;
  NspFile *F;
  int un = 1, kmax, k, no;
  /* Parameter adjustments */
  --y;
  --u;
  --z;
  --x;

  F = (NspFile *) NSP_POINTER_CAST_TO_INT z[3];

  if (*flag == 1)
    {
      /*     discrete state */
      k = (int) z[1];
      kmax = (int) z[2];
      if (k + 1 > kmax && kmax == rf->n)
	{
	  /*     output */
	  C2F (dcopy) (ny, &z[rf->n * rf->ievt + 3 + k], &rf->n, &y[1], &un);
	  /*     .     read a new buffer */
	  no = (*nz - 3) / rf->n;
	  if (bfrdr (F, rf, ipar, &z[4], &no, &kmax) == FAIL)
	    {
	      Scierror ("Error: read error in scicos_readf !\n");
	      *flag = -1;
	      nsp_file_close (F);
	      nsp_file_destroy (F);
	      z[3] = 0.0;
	      return;
	    }
	  z[1] = 1.;
	  z[2] = (double) kmax;
	}
      else if (k < kmax)
	{
	  /*     output */
	  C2F (dcopy) (ny, &z[rf->n * rf->ievt + 3 + k], &rf->n, &y[1], &un);
	  z[1] += 1.;
	}
    }
  else if (*flag == 3)
    {
      k = (int) z[1];
      kmax = (int) z[2];
      if (k > kmax && kmax < rf->n)
	{
	  tvec[0] = *t - 1.;
	}
      else
	{
	  tvec[0] = z[k + 3];
	}
    }
  else if (*flag == 4)
    {
      char str[FSIZE];
      char fname[FSIZE + 1];
      int i;
      /* get the file name from its ascii code  */
      for (i = 0; i < rf->lfil; i++)
	str[i] = *(&rf->fname + i);
      str[rf->lfil] = '\0';
      nsp_path_expand (str, fname, FSIZE);
      /* sciprint("Trying to open [%s] in readf\n",str); */
      if ((F = nsp_file_open (fname, "r", FALSE, FALSE)) == NULL)
	{
	  Scierror
	    ("Error: in scicos_readf_block, could not open the file %s !\n",
	     str);
	  *flag = -3;
	  z[3] = 0.0;
	  return;
	}
      z[3] = NSP_POINTER_CAST_TO_INT F;
      /*     buffer initialisation */
      no = (*nz - 3) / rf->n;
      if (bfrdr (F, rf, ipar, &z[4], &no, &kmax) == FAIL)
	{
	  Scierror ("Error: read error in %s !\n", str);
	  *flag = -1;
	  nsp_file_close (F);
	  nsp_file_destroy (F);
	  z[3] = 0.0;
	  return;
	}
      z[1] = 1.;
      z[2] = (double) kmax;
    }
  else if (*flag == 5)
    {
      if (z[3] == 0)
	return;
      nsp_file_close (F);
      nsp_file_destroy (F);
      z[3] = 0.0;
    }
}

int bfrdr (NspFile * F, readf_ipar * rf, int *ipar, double *z, int *no,
	   int *kmax)
{
  char fmt[128];
  int i, j, imask, mm;
  double tmp[100];

  /*      no=(nz-3)/N */
  /*     maximum number of value to read */
  imask = rf->lfil + 5 + rf->lfmt - 1;
  if (rf->ievt == 0)
    ++imask;
  mm = 0;
  for (i = 0; i <= *no - 1; ++i)
    {
      mm = Max (mm, ipar[imask + i]);
    }
  *kmax = 0;
  if (rf->lfmt == 0)
    {
      strcpy (fmt, "%lf");
    }
  else
    {
      for (i = 0; i < rf->lfmt; i++)
	fmt[i] = *(&rf->fname + rf->lfil + i);
      fmt[rf->lfmt] = '\0';
    }

  for (i = 1; i <= rf->n; ++i)
    {
      for (j = 1; j <= mm; ++j)
	{
	  int ns = fscanf (F->obj->file, fmt, &tmp[j - 1]);
	  /* printf("read = %s %lf\n",fmt,tmp[j - 1]); */
	  /* Here we should be able to return to 
	   * scicos a stop to tell that we have 
	   * reached the end of file. 
	   * or have a special event port for that.
	   */
	  if (ns == EOF)
	    tmp[j - 1] = 0.0;
	  else if (ns != 1)
	    return FAIL;
	}
      for (j = 0; j <= *no - 1; ++j)
	{
	  z[j * rf->n + i - 1] = tmp[ipar[imask + j] - 1];
	}
      ++(*kmax);
    }
  return OK;
}
