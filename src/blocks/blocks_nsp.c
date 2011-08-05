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

static void scicos_intp (double x, const double *xd, const double *yd, int n,
			 int nc, double *y);

/* 
 * most of the blocks defined here have the following calling sequence
 */

/*     continuous state space linear system simulator */
/*     rpar(1:nx*nx)=A */
/*     rpar(nx*nx+1:nx*nx+nx*nu)=B */
/*     rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C */
/*     rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D */

void scicos_csslti_block (scicos_args_F0)
{
  int la, lb, lc, ld, c__1 = 1;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  la = 1;
  lb = *nx * *nx + la;
  lc = lb + *nx * *nu;
  if (*flag__ == 1 || *flag__ == 6)
    {
      /*     y=c*x+d*u */
      ld = lc + *nx * *ny;
      nsp_calpack_dmmul (&rpar[lc], ny, &x[1], nx, &y[1], ny, ny, nx, &c__1);
      nsp_calpack_dmmul1 (&rpar[ld], ny, &u[1], nu, &y[1], ny, ny, nu, &c__1);
    }
  else if (*flag__ == 0)
    {
      /*     xd=a*x+b*u */
      nsp_calpack_dmmul (&rpar[la], nx, &x[1], nx, &xd[1], nx, nx, nx, &c__1);
      nsp_calpack_dmmul1 (&rpar[lb], nx, &u[1], nu, &xd[1], nx, nx, nu,
			  &c__1);
    }
}

/*     Ouputs nx*dt delayed input */

void scicos_delay_block (scicos_args_F0)
{
  if (*flag__ == 1 || *flag__ == 4 || *flag__ == 6)
    {
      y[0] = z__[0];
    }
  else if (*flag__ == 2)
    {
      /*     .  shift buffer */
      memmove (&z__[0], &z__[1], sizeof (double) * (*nz - 1));
      z__[*nz - 1] = u[0];
    }
}


/*     SISO, strictly proper adapted transfer function 
 *     u(1)    : main input 
 *     u(2)    : modes adaptation input 
 *     m = ipar(1) : degree of numerator 
 *     n = ipar(2) : degree of denominator n>m 
 *     npt = ipar(3) : number of mesh points 
 *     x = rpar(1:npt) : mesh points abscissae 
 *     rnr = rpar(npt+1:npt+m*npt) : rnr(i,k) i=1:m  is the real part of 
 *          the roots of the numerator at the kth mesh point 
 *     rni = rpar(npt+m*npt+1:npt+2*m*npt) : rni(i,k) i=1:m  is the 
 *          imaginary part of the roots of the numerator at the kth 
 *          mesh point 
 *     rdr = rpar(npt+2*m*np+1:npt+(2*m+n)*npt) : rdr(i,k) i=1:n 
 *          is the real part of the roots of the denominator at the kth 
 *          meshpoint 
 *     rdi = rpar(npt+(2*m+n)*np+1:npt+2*(m+n)*npt) : rdi(i,k) i=1:n 
 *          is the imaginary part of the roots of the denominator at 
 *          the kth  meshpoint 
 *     g   = rpar(npt+2*(m+n)*npt+1:npt+2*(m+n)*npt+npt) is the 
 *           gain values at the mesh points. 
 */


static void coeffs_from_roots (int n, const double *rootr,
			       const double *rooti, double *coeffr,
			       double *coeffi);

void scicos_dlradp_block (scicos_args_F0)
{
  static int c__1 = 1;
  /* static int c_n1 = -1; */
  int i__1;
  int m, n, iflag;
  double yy[201], num[51], den[51], ww[51];
  int npt, mpn;
  double yyp;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  m = ipar[1];
  n = ipar[2];
  if (*flag__ == 2)
    {
      /*     state */
      m = ipar[1];
      n = ipar[2];
      mpn = m + n;
      npt = ipar[3];
      i__1 = (mpn << 1) + 1;
      scicos_intp (u[2], &rpar[1], &rpar[npt + 1], i__1, npt, yy);
      coeffs_from_roots (m, yy, &yy[m], num, ww);
      coeffs_from_roots (n, &yy[m * 2], &yy[(m << 1) + 1 + n - 1], den, ww);
      yyp = -C2F (ddot) (&n, den, &c__1, &z__[m + 1], &c__1)
	+ (C2F (ddot) (&m, num, &c__1, &z__[1], &c__1) + u[1]) * yy[mpn * 2];
      if (m > 0)
	{
	  /* 
	     i__1 = m - 1;
	     scicos_unsfdcopy (&i__1, &z__[2], &c_n1, &z__[1], &c_n1);
	  */
	  memmove (&z__[1], &z__[2], (m - 1) * sizeof (double));
	  z__[m] = u[1];
	}
      /*
	i__1 = n - 1;
	scicos_unsfdcopy (&i__1, &z__[m + 2], &c_n1, &z__[m + 1], &c_n1);
      */
      memmove (&z__[m + 1], &z__[m + 2], (n - 1) * sizeof (double));
      z__[mpn] = yyp;
    }
  else if (*flag__ == 4)
    {
      /*     init */
      m = ipar[1];
      n = ipar[2];
      if (m > 50 || n > 50)
	{
	  iflag = -1;
	  return;
	}
    }
  /*     y */
  y[1] = z__[m + n];
  return;
}

/* utilities for previous function 
 * computes the n+1 coefficients of a polynom given by its n roots
 * the coefficient of max degree is set to 1.
 */

static void coeffs_from_roots (int n, const double *rootr,
			       const double *rooti, double *coeffr,
			       double *coeffi)
{
  int i;
  for (i = 0; i < n + 1; i++)
    coeffr[i] = coeffi[i] = 0.0;
  coeffr[n] = 1.0;
  for (i = 0; i < n; i++)
    {
      int j, nj = n - 1 - i;
      for (j = 0; j < i; j++)
	{
	  coeffr[nj + j] +=
	    (-rootr[i + j]) * coeffr[nj + 1 + j] -
	    (-rooti[i + j]) * coeffi[nj + 1 + j];
	  coeffi[nj + j] +=
	    (-rootr[i + j]) * coeffi[nj + 1 + j] +
	    (-rooti[i + j]) * coeffr[nj + 1 + j];
	}
    }
}


/* Ouputs delayed input */

void scicos_dollar_block (scicos_args_F0)
{
  if (*flag__ == 1 || *flag__ == 6 || *flag__ == 4)
    {
      memcpy (y, z__, (*nu) * sizeof (double));
    }
  else if (*flag__ == 2)
    {
      memcpy (z__, u, (*nu) * sizeof (double));
    }
}



void scicos_dsslti_block (scicos_args_F0)
{
  int c__1 = 1;
  double w[100];
  int la, lb, lc, ld;

  /*     Scicos block simulator */
  /*     discrete state space linear system simulator */
  /*     rpar(1:nx*nx)=A */
  /*     rpar(nx*nx+1:nx*nx+nx*nu)=B */
  /*     rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  la = 1;
  lb = *nz * *nz + la;
  lc = lb + *nz * *nu;
  if (*flag__ == 4)
    {
      if (*nz > 100)
	{
	  *flag__ = -1;
	  return;
	}
    }
  else if (*flag__ == 2)
    {
      /*     x+=a*x+b*u */
      C2F (dcopy) (nz, &z__[1], &c__1, w, &c__1);
      nsp_calpack_dmmul (&rpar[la], nz, w, nz, &z__[1], nz, nz, nz, &c__1);
      nsp_calpack_dmmul1 (&rpar[lb], nz, &u[1], nu, &z__[1], nz, nz, nu,
			  &c__1);
    }
  else if (*flag__ == 1 || *flag__ == 6)
    {
      /*     y=c*x+d*u */
      ld = lc + *nz * *ny;
      nsp_calpack_dmmul (&rpar[lc], ny, &z__[1], nz, &y[1], ny, ny, nz,
			 &c__1);
      nsp_calpack_dmmul1 (&rpar[ld], ny, &u[1], nu, &y[1], ny, ny, nu, &c__1);
    }
}

/*     Event scope */

void scicos_evscpe_block (scicos_args_F0)
{
  return;
}

/* event delay,  delay=rpar(1) */

void scicos_evtdly_block (scicos_args_F0)
{
  if (*flag__ == 3)
    {
      tvec[0] = *t + rpar[0];
    }
}

/*     Outputs a^u(i), a =rpar(1) */

void scicos_expblk_block (scicos_args_F0)
{
  int i;
  if (*flag__ == 1 || *flag__ >= 4)
    {
      for (i = 0; i < *nu; ++i)
	y[i] = exp (log (rpar[0]) * u[i]);
    }
}

/*  For block */

void scicos_forblk_block (scicos_args_F0)
{
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


void scicos_fsv_block (scicos_args_F0)
{
  double d__1, d__2;
  double a, g, a0, b0;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  a = u[1];
  y[1] = 0.;
  if (a > 1.)
    {
      return;
    }
  g = 1.4;
  a0 = 2. / g;
  b0 = (g + 1) / g;
  if (a < .528)
    {
      d__1 = 2 / (g + 1.);
      d__2 = g / (g - 1.);
      a = pow (d__1, d__2);
    }
  y[1] = sqrt (g * 2. * (pow (a, a0) - pow (a, b0)) / (g - 1.));


}

/* just a test */


void scicos_gensin_test (scicos_args_F0)
{
  static double val;
  if (*flag__ == 4)
    {
      /* create_range_controls(&val); */
    }
  y[0] = val * sin (rpar[1] * *t + rpar[2]);

}

void scicos_gensin_block (scicos_args_F0)
{
  y[0] = rpar[0] * sin (rpar[1] * *t + rpar[2]);

}

/*     Square wave generator 
 *     period=2*rpar(1) 
 */

void scicos_gensqr_block (scicos_args_F0)
{
  if (*flag__ == 2)
    {
      z__[0] = -z__[0];
    }
  else if (*flag__ == 1 || *flag__ == 6)
    {
      y[0] = z__[0];
    }

}

/*     Notify simulation to stop  when called 
 *     ipar(1) : stop reference 
 */


void scicos_hltblk_block (scicos_args_F0)
{
  if (*flag__ == 2)
    {
      Scicos->params.halt = 1;
      z__[0] = (*nipar > 0) ? (double) ipar[0] : 0.0;
    }

}


/*     Integrator */

void scicos_integr_block (scicos_args_F0)
{
  if (*flag__ == 1 || *flag__ == 6)
    {
      y[0] = x[0];
    }
  else if (*flag__ == 0)
    {
      xd[0] = u[0];
    }

}


/* linear interpolation to compute y=f(t) for 
 * f a tabulated function from R to R^(ny)
 * ipar(1)             : np number of mesh points 
 * rpar(1:np,1:ny+1) : matrix of mesh point coordinates 
 *                       first row contains t coordinate mesh points 
 *                       next rows contains y coordinates mesh points 
 *                       (one row for each output) 
 */



void scicos_intplt_block (scicos_args_F0)
{
  int np = ipar[0];
  scicos_intp (*t, rpar, rpar + np, *ny, np, y);

}

/* linear interpolation to compute y=f(u) for 
 * for f a tabulated function from R to R^ny
 *    rpar(1:np,1:ny+1) : matrix of mesh point coordinates 
 *                       first row contains u coordinate mesh points 
 *                       next rows contains y coordinates mesh points 
 *                       (one row for each output) 
 */

void scicos_intpol_block (scicos_args_F0)
{
  int np = ipar[0];
  scicos_intp (*u, rpar, rpar + np, *ny, np, y);

}

/* compute y=F(x) by linear interpolation where F : R -> R^n and 
 * F is given by nc values F(xd[i])=ydi where ydi is the i-th row of yd.
 * the xd values are supposed to be increasing values.
 * 
 *  x: value at which to compute F 
 *  xd: increasing vector of size nc
 *  yd: matrix (nc x n): yd(i,:)=F(x(i))
 *  n : F takes its values in R^n.
 *  y : vector of size n filled with F(x)
 *  
 *  F is set to F(xd(1)) for x < xd(1) and to F(xd(nc)) for x>= xd(nc).
 *
 * Originally writen in Fortran by Pejman GOHARI 1996. 
 * C-version Jean-Philippe Chancelier 
 */

static void scicos_intp (double x, const double *xd, const double *yd, int n,
			 int nc, double *y)
{
  int pos = nc - 1, i;
  /* where is x ? this could be improved with dsearch.
   */
  for (i = 0; i < nc; i++)
    {
      if (x < xd[i])
	{
	  pos = i - 1;
	  break;
	}
    }
  /* limit cases */
  if (pos == -1)
    {
      /* return first value */
      for (i = 0; i < n; i++)
	y[i] = yd[nc * i];
    }
  else if (pos == nc - 1)
    {
      /* return last value */
      for (i = 0; i < n; i++)
	y[i] = yd[(nc - 1) + nc * i];
    }
  else
    {
      double alpha = xd[pos + 1] - xd[pos];
      if (alpha < 1.e-10)
	{
	  for (i = 0; i < n; i++)
	    y[i] = yd[(nc - 1) + nc * i];
	}
      else
	{
	  alpha = (x - xd[pos]) / alpha;
	  for (i = 0; i < n; i++)
	    y[i] =
	      (1 - alpha) * yd[pos + nc * i] + alpha * yd[pos + 1 + nc * i];
	}
    }
}


void scicos_intrp2_block (scicos_args_F);

void scicos_intrp2_block (int *flag__, int *nevprt, const double *t,
			 double *xd, double *x, int *nx, double *z__, int *nz,
			 double *tvec, int *ntvec, double *rpar, int *nrpar,
			 int *ipar, int *nipar, double *u1, int *nu1,
			 double *u2, int *nu2, double *y1, int *ny1,
			 double *uy4, int *nuy4, double *uy5, int *nuy5,
			 double *uy6, int *nuy6, double *uy7, int *nuy7,
			 double *uy8, int *nuy8, double *uy9, int *nuy9,
			 double *uy10, int *nuy10, double *uy11, int *nuy11,
			 double *uy12, int *nuy12, double *uy13, int *nuy13,
			 double *uy14, int *nuy14, double *uy15, int *nuy15,
			 double *uy16, int *nuy16, double *uy17, int *nuy17,
			 double *uy18, int *nuy18)
{
  int i__1;
  int i__, j;
  double vx1, vx2, vy1, vy2, vz1, vz2, vz3, vz4;
  /*     ipar(1) : the number of input */
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  i__1 = ipar[1];
  for (i__ = 2; i__ <= i__1; ++i__)
    {
      if (*u1 <= rpar[i__])
	{
	  goto L200;
	}
      /* L100: */
    }
  i__ = ipar[1];
 L200:
  i__1 = ipar[2];
  for (j = 2; j <= i__1; ++j)
    {
      if (*u2 <= rpar[j + ipar[1]])
	{
	  goto L400;
	}
      /* L300: */
    }
  j = ipar[2];
 L400:
  vy1 = rpar[ipar[1] + j - 1];
  vy2 = rpar[ipar[1] + j];
  vz1 = rpar[ipar[1] + ipar[2] + (i__ - 2) * ipar[2] + j - 1];
  vz4 = rpar[ipar[1] + ipar[2] + (i__ - 2) * ipar[2] + j];
  vz2 = rpar[ipar[1] + ipar[2] + (i__ - 1) * ipar[2] + j - 1];
  vz3 = rpar[ipar[1] + ipar[2] + (i__ - 1) * ipar[2] + j];
  vx1 = rpar[i__ - 1];
  vx2 = rpar[i__];
  *y1 =
    (1. - (*u2 - vy1) / (vy2 - vy1)) * (vz1 +
					(vz2 - vz1) * (*u1 - vx1) / (vx2 -
								     vx1)) +
    (*u2 - vy1) / (vy2 - vy1) * (vz4 +
				 (vz3 - vz4) * (*u1 - vx1) / (vx2 - vx1));

}


/*     ipar(1) : the number of input */

void scicos_intrpl_block (scicos_args_F0)
{
  int i, i1 = (*nrpar / 2);
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  for (i = 2; i <= i1; ++i)
    {
      if (*u <= rpar[i])
	{
	  goto L200;
	}
    }
  i = *nrpar / 2;
 L200:
  *y = rpar[i1 + i - 1] +
    (rpar[i1 + i] - rpar[i1 + i - 1]) / (rpar[i] - rpar[i - 1]) *
    (*u - rpar[i - 1]);

}

/*     Outputs the inverse of the input */

void scicos_invblk_block (scicos_args_F0)
{
  int i;
  double ww;

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;

  if (*flag__ == 6)
    {
      for (i = 1; i <= *nu; ++i)
	{
	  ww = u[i];
	  if (ww != 0.)  y[i] = 1. / ww;
	}
    }

  if (*flag__ == 1)
    {
      for (i = 1; i <= *nu; ++i)
	{
	  ww = u[i];
	  if (ww != 0.)
	    {
	      y[i] = 1. / ww;
	    }
	  else
	    {
	      *flag__ = -2;
	      return;
	    }
	}
    }
}


void scicos_iocopy_block (scicos_args_F0)
{
  memcpy (y, u, *nu * sizeof (double));
}



void scicos_logblk_block (scicos_args_F0)
{
  int i__1;
  int i__;
  /*     y=log(u)/log(rpar(1)) */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 1)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (u[i__] > 0.)
	    {
	      y[i__] = log (u[i__]) / log (rpar[1]);
	    }
	  else
	    {
	      *flag__ = -2;
	      return;
	    }
	  /* L15: */
	}
    }
  if (*flag__ == 6)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (u[i__] > 0.)
	    {
	      y[i__] = log (u[i__]) / log (rpar[1]);
	    }
	  /* L20: */
	}
    }
}

void scicos_lookup_block (scicos_args_F0)
{
  int i__1;
  double dout;
  int i__, n;
  double du;

  /*     rpar(1:n)  =  u coordinate discretisation must be strictly increasing */
  /*     rpar(n+1:2*n)  =  y coordinate discretisation */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  n = *nrpar / 2;
  if (n > 2)
    {
      i__1 = n - 1;
      for (i__ = 2; i__ <= i__1; ++i__)
	{
	  if (u[1] <= rpar[i__])
	    {
	      goto L20;
	    }
	  /* L10: */
	}
    }
  else
    {
      if (n == 1)
	{
	  y[1] = rpar[2];
	  return;
	}
      i__ = 2;
    }
 L20:
  du = rpar[i__] - rpar[i__ - 1];
  dout = rpar[n + i__] - rpar[n + i__ - 1];
  y[1] = rpar[n + i__] - (rpar[i__] - u[1]) * dout / du;
}



void scicos_lsplit_block (scicos_args_F0)
{

  int i__1, i__2;
  int i__, j, k;

  /*     splitting signals */

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  j = 0;
  i__1 = *ny / *nu;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      i__2 = *nu;
      for (k = 1; k <= i__2; ++k)
	{
	  ++j;
	  y[j] = u[k];
	}
    }
}

void scicos_lusat_block (scicos_args_F);


void scicos_lusat_block (int *flag__, int *nevprt, const double *t, double *xd,
			double *x, int *nx, double *z__, int *nz,
			double *tvec, int *ntvec, double *rpar, int *nrpar,
			int *ipar, int *nipar, double *u, int *nu, double *y,
			int *ny, double *g, int *ng, double *uy4, int *nuy4,
			double *uy5, int *nuy5, double *uy6, int *nuy6,
			double *uy7, int *nuy7, double *uy8, int *nuy8,
			double *uy9, int *nuy9, double *uy10, int *nuy10,
			double *uy11, int *nuy11, double *uy12, int *nuy12,
			double *uy13, int *nuy13, double *uy14, int *nuy14,
			double *uy15, int *nuy15, double *uy16, int *nuy16,
			double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  int i__1;
  int i__;
  /*     Lower-Upper saturation */
  /*     Continous block, MIMO */
  --g;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 9)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  g[i__] = u[i__] - rpar[1];
	  g[i__ + *nu] = u[i__] - rpar[2];
	  /* L10: */
	}
    }
  if (*flag__ == 1)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (u[i__] <= rpar[1])
	    {
	      y[i__] = rpar[1] * rpar[3];
	    }
	  else if (u[i__] >= rpar[2])
	    {
	      y[i__] = rpar[2] * rpar[3];
	    }
	  else
	    {
	      y[i__] = rpar[3] * u[i__];
	    }
	  /* L15: */
	}
    }
}


void scicos_maxblk_block (scicos_args_F0)
{
  int i__1;
  double d__1, d__2;
  int i__;
  double ww;

  /*     outputs the maximum of all inputs */

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  ww = u[1];
  i__1 = *nu;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      /* Computing MAX */
      d__1 = ww, d__2 = u[i__];
      ww = Max (d__1, d__2);
      /* L15: */
    }
  y[1] = ww;
}

/*     returns sample and hold  of the input */

void scicos_memo_block (scicos_args_F0)
{
  if (*flag__ == 2)
    {
      memcpy (y, u, (*nu) * sizeof (double));
    }
  else if (*flag__ == 4)
    {
      memcpy (y, rpar, (*nu) * sizeof (double));
    }
}


/*     multifrequency clock */

void scicos_mfclck_block (scicos_args_F0)
{
  if (*flag__ == 4)
    {
      z__[0] = 0.;
    }
  else if (*flag__ == 2)
    {
      z__[0] += 1.;
      if (z__[0] == (double) ipar[0])
	{
	  z__[0] = 0.;
	}
    }
  else if (*flag__ == 3)
    {
      if (z__[0] == (double) (ipar[0] - 1))
	{
	  tvec[0] = *t - 1.;
	  tvec[1] = *t + rpar[0];
	}
      else
	{
	  tvec[0] = *t + rpar[0];
	  tvec[1] = *t - 1.;
	}
    }
}

/*     outputs the minimum of all inputs */

void scicos_minblk_block (scicos_args_F0)
{
  int i;
  double ww = u[0];
  for (i = 1; i < *nu; i++)
    ww = Min (ww, u[i]);
  y[0] = ww;
}


void scicos_mscope_block (scicos_args_F0)
{

}


void scicos_pload_block (scicos_args_F0)
{
  int i__1;
  int i__;

  /*     Preload function */
  /*     if u(i).lt.0 then y(i)=-u(i)-rpar(i) */
  /*     else y(i)=u(i)+rpar(i) */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  /* L10: */
  i__1 = *nu;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (u[i__] < 0.)
	{
	  y[i__] = u[i__] - rpar[i__];
	}
      else if (u[i__] > 0.)
	{
	  y[i__] = u[i__] + rpar[i__];
	}
      else
	{
	  y[i__] = 0.;
	}
      /* L15: */
    }
}


void scicos_powblk_block (scicos_args_F0)
{
  int i__1;
  int i__;

  /*     rpar(1) is power */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*nrpar == 1)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (u[i__] < 0.)
	    {
	      if (*flag__ >= 4)
		{
		  return;
		}
	      *flag__ = -2;
	      return;
	    }
	  else if (u[i__] == 0. && rpar[1] <= 0.)
	    {
	      if (*flag__ >= 4)
		{
		  return;
		}
	      *flag__ = -2;
	      return;
	    }
	  y[i__] = pow (u[i__], rpar[1]);
	  /* L15: */
	}
    }
  else
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  if (ipar[1] <= 0 && u[i__] == 0.)
	    {
	      if (*flag__ >= 4)
		{
		  return;
		}
	      *flag__ = -2;
	      return;
	    }
	  y[i__] = pow (u[i__], ipar[1]);	/* pow_di */
	}
    }
}


/*     Gives quantized signal by ceiling method */
/*     rpar(i) quantization step used for i input */

void scicos_qzcel_block (scicos_args_F0)
{
  double d__1;
  int i__;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  for (i__ = 1; i__ <= *nu; ++i__)
    {
      d__1 = u[i__] / rpar[i__] - .5;
      y[i__] = rpar[i__] * d_nint (d__1);
    }
}

/*     Gives quantized signal by floor method */
/*     rpar(i) quantization step used for i input */

void scicos_qzflr_block (scicos_args_F0)
{
  double d__1;
  int i__;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  for (i__ = 1; i__ <= *nu; ++i__)
    {
      d__1 = u[i__] / rpar[i__] + .5;
      y[i__] = rpar[i__] * d_nint (d__1);
    }
}

/* quantize a signal using round method
 * rpar(i) quantization step used for i input 
 */

extern double round (double x);

void scicos_qzrnd_block (scicos_args_F0)
{
  int i;
  for (i = 0; i < *nu; i++)
    {
      y[i] = rpar[i] * round (u[i] / rpar[i]);
    }
}

/*     Gives quantized signal by truncation method */
/*     rpar(i) quantization step used for i input */

void scicos_qztrn_block (scicos_args_F0)
{
  int i__;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  for (i__ = 1; i__ <= *nu; ++i__)
    {
      if (u[i__] < 0.)
	{
	  y[i__] = rpar[i__] * anint (u[i__] / rpar[i__] + .5);
	}
      else
	{
	  y[i__] = rpar[i__] * anint (u[i__] / rpar[i__] - .5);

	}
    }
}


/*     ipar(1) */
/*            0 : uniform */
/*            1 : normal */
/*     rpar(1:ny)=mean */
/*     rpar(ny+1:2*ny)=deviation */
/*     rpar(2*ny+1)=dt */

void scicos_rndblk_block (scicos_args_F0)
{

  int i__1;
  int i__;
  double t1, si;
  int iy;
  double sr;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 1 || *flag__ == 6)
    {
      i__1 = *ny;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  y[i__] = rpar[i__] + rpar[*ny + i__] * z__[i__ + 1];
	}
    }
  else if (*flag__ == 2 || *flag__ == 4)
    {
      /*     uniform */
      if (ipar[1] == 0)
	{
	  iy = (int) z__[1];
	  i__1 = *nz - 1;
	  for (i__ = 1; i__ <= i__1; ++i__)
	    {
	      z__[i__ + 1] = nsp_urand (&iy);
	    }
	}
      else
	{
	  iy = (int) z__[1];
	  /*     normal */
	  i__1 = *nz - 1;
	  for (i__ = 1; i__ <= i__1; ++i__)
	    {
	    L75:
	      sr = nsp_urand (&iy) * 2. - 1.;
	      si = nsp_urand (&iy) * 2. - 1.;
	      t1 = sr * sr + si * si;
	      if (t1 > 1.)
		{
		  goto L75;
		}
	      z__[i__ + 1] = sr * sqrt (log (t1) * -2. / t1);
	    }
	}
      z__[1] = (double) iy;
      /*         if(ntvec.eq.1) tvec(1)=t+rpar(2*(nz-1)+1) */
    }
}

/*     returns sample and hold  of the input */

void scicos_samphold_block (scicos_args_F0)
{
  if (*flag__ == 1)
    {
      memcpy (y, u, *nu * sizeof (double));
    }
  
}


void scicos_sawtth_block (scicos_args_F0)
{
  if (*flag__ == 1 && *nevprt == 0)
    {
      y[0] = *t - z__[0];
    }
  else if (*flag__ == 1 && *nevprt == 1)
    {
      y[0] = 0.;
    }
  else if (*flag__ == 2 && *nevprt == 1)
    {
      z__[0] = *t;
    }
  else if (*flag__ == 4)
    {
      z__[0] = 0.;
    }
  
}

void scicos_scope_block (scicos_args_F);

void 
scicos_scope_block (int *flag__, int *nevprt, const double *t, double *xd,
		    double *x, int *nx, double *z__, int *nz, double *tvec,
		    int *ntvec, double *rpar, int *nrpar, int *ipar,
		    int *nipar, double *u, int *nu, double *uy2, int *nuy2,
		    double *uy3, int *nuy3, double *uy4, int *nuy4,
		    double *uy5, int *nuy5, double *uy6, int *nuy6,
		    double *uy7, int *nuy7, double *uy8, int *nuy8,
		    double *uy9, int *nuy9, double *uy10, int *nuy10,
		    double *uy11, int *nuy11, double *uy12, int *nuy12,
		    double *uy13, int *nuy13, double *uy14, int *nuy14,
		    double *uy15, int *nuy15, double *uy16, int *nuy16,
		    double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  
}

void scicos_scopxy_block (scicos_args_F0)
{
  
}


void scicos_scoxy_block (scicos_args_F0)
{
  
}

/*     Selector block */

void scicos_selblk_block (scicos_args_F0)
{
  int ic, nev;
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 2 && *nevprt > 0)
    {
      ic = 0;
      nev = *nevprt;
    L10:
      if (nev >= 1)
	{
	  ++ic;
	  nev /= 2;
	  goto L10;
	}
      z__[1] = (double) ic;
    }
  else if (*flag__ == 1 || *flag__ == 6)
    {
      y[1] = u[(int) z__[1]];
    }
  
}


void scicos_sinblk_block (scicos_args_F0)
{
  int i;
  for (i = 0; i < *nu; ++i)
    y[i] = sin (u[i]);
  
}

/*
 * y=sqrt(u);
 */


void scicos_sqrblk_block (scicos_args_F0)
{
  int i;
  for (i = 0; i < *nu; ++i)
    {
      if (u[i] >= 0.)
	{
	  y[i] = sqrt (u[i]);
	}
      else
	{
	  *flag__ = -2;
	  return;
	}
    }
}

/*     adds the inputs weighed by rpar */

void scicos_sum2_block (scicos_args_F);

void scicos_sum2_block (int *flag__, int *nevprt, const double *t, double *xd,
		       double *x, int *nx, double *z__, int *nz, double *tvec,
		       int *ntvec, double *rpar, int *nrpar, int *ipar,
		       int *nipar, double *u1, int *nu1, double *u2, int *nu2,
		       double *y, int *ny, double *uy4, int *nuy4,
		       double *uy5, int *nuy5, double *uy6, int *nuy6,
		       double *uy7, int *nuy7, double *uy8, int *nuy8,
		       double *uy9, int *nuy9, double *uy10, int *nuy10,
		       double *uy11, int *nuy11, double *uy12, int *nuy12,
		       double *uy13, int *nuy13, double *uy14, int *nuy14,
		       double *uy15, int *nuy15, double *uy16, int *nuy16,
		       double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  int i__1;
  int i__;

  --y;
  --u2;
  --u1;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  i__1 = *nu1;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      y[i__] = u1[i__] * rpar[1] + u2[i__] * rpar[2];
    }
}

void scicos_sum3_block (scicos_args_F);

void scicos_sum3_block (int *flag__, int *nevprt, const double *t, double *xd,
		       double *x, int *nx, double *z__, int *nz, double *tvec,
		       int *ntvec, double *rpar, int *nrpar, int *ipar,
		       int *nipar, double *u1, int *nu1, double *u2, int *nu2,
		       double *u3, int *nu3, double *y, int *ny, double *uy5,
		       int *nuy5, double *uy6, int *nuy6, double *uy7,
		       int *nuy7, double *uy8, int *nuy8, double *uy9,
		       int *nuy9, double *uy10, int *nuy10, double *uy11,
		       int *nuy11, double *uy12, int *nuy12, double *uy13,
		       int *nuy13, double *uy14, int *nuy14, double *uy15,
		       int *nuy15, double *uy16, int *nuy16, double *uy17,
		       int *nuy17, double *uy18, int *nuy18)
{
  int i__1;
  int i__;

  /*     adds the inputs weighed by rpar */
  --y;
  --u3;
  --u2;
  --u1;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  i__1 = *nu1;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      y[i__] = u1[i__] * rpar[1] + u2[i__] * rpar[2] + u3[i__] * rpar[3];
      /* L1: */
    }
}



void scicos_tanblk_block (scicos_args_F0)
{
  int i;
  double ww;

  for (i = 0; i < *nu; i++)
    {
      ww = cos (u[i]);
      if (ww != 0.)
	{
	  y[i] = sin (u[i]) / ww;
	}
      else
	{
	  *flag__ = -2;
	  return;
	}
    }
}


/* Table of constant values */

void scicos_tcslti_block (scicos_args_F);

void
scicos_tcslti_block (int *flag__, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z__, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar,
		     int *nipar, double *u1, int *nu1, double *u2, int *nu2,
		     double *y, int *ny, double *uy4, int *nuy4, double *uy5,
		     int *nuy5, double *uy6, int *nuy6, double *uy7,
		     int *nuy7, double *uy8, int *nuy8, double *uy9,
		     int *nuy9, double *uy10, int *nuy10, double *uy11,
		     int *nuy11, double *uy12, int *nuy12, double *uy13,
		     int *nuy13, double *uy14, int *nuy14, double *uy15,
		     int *nuy15, double *uy16, int *nuy16, double *uy17,
		     int *nuy17, double *uy18, int *nuy18)
{
  int c__1 = 1;
  int la, lb, lc, ld;

  /*     Scicos block simulator */
  /*     continuous state space linear system simulator */
  /*     rpar(1:nx*nx)=A */
  /*     rpar(nx*nx+1:nx*nx+nx*nu)=B */
  /*     rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C */
  /*     rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D */
  /* ! */


  --y;
  --u2;
  --u1;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  la = 1;
  lb = *nx * *nx + la;
  lc = lb + *nx * *nu1;
  if (*flag__ == 1 || *flag__ == 6)
    {
      /*     y=c*x+d*u1 */
      ld = lc + *nx * *ny;
      nsp_calpack_dmmul (&rpar[lc], ny, &x[1], nx, &y[1], ny, ny, nx, &c__1);
      nsp_calpack_dmmul1 (&rpar[ld], ny, &u1[1], nu1, &y[1], ny, ny, nu1,
			  &c__1);
    }
  else if (*flag__ == 2 && *nevprt == 1)
    {
      /*     x+=u2 */
      C2F (dcopy) (nx, &u2[1], &c__1, &x[1], &c__1);
    }
  else if (*flag__ == 0 && *nevprt == 0)
    {
      /*     xd=a*x+b*u1 */
      nsp_calpack_dmmul (&rpar[la], nx, &x[1], nx, &xd[1], nx, nx, nx, &c__1);
      nsp_calpack_dmmul1 (&rpar[lb], nx, &u1[1], nu1, &xd[1], nx, nx, nu1,
			  &c__1);
    }
  
}


void scicos_tcsltj_block (scicos_args_F0)
{
  static int c__1 = 1;
  int la, lb, lc;

  /*     continuous state space linear system simulator */
  /*     rpar(1:nx*nx)=A */
  /*     rpar(nx*nx+1:nx*nx+nx*nu)=B */
  /*     rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C */
  /*     rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D */
  /* ! */

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  la = 1;
  lb = *nx * *nx + la;
  lc = lb;
  if (*flag__ == 1 || *flag__ == 6)
    {
      /*     y=c*x */
      nsp_calpack_dmmul (&rpar[lc], ny, &x[1], nx, &y[1], ny, ny, nx, &c__1);
    }
  else if (*flag__ == 2 && *nevprt == 1)
    {
      /*     x+=u2 */
      C2F (dcopy) (nx, &u[1], &c__1, &x[1], &c__1);
    }
  else if (*flag__ == 0 && *nevprt == 0)
    {
      /*     xd=a*x */
      nsp_calpack_dmmul (&rpar[la], nx, &x[1], nx, &xd[1], nx, nx, nx, &c__1);
    }
  
}


void scicos_timblk_block (scicos_args_F0)
{
  y[0] = *t;
  
}


void scicos_trash_block (scicos_args_F0)
{
  
}


void scicos_zcross_block (scicos_args_F0)
{
  int i__1;
  double d__1;
  int i__, j, l, kev;

  /*     zero crossing block */

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  if (*flag__ == 3 && *nevprt < 0)
    {
      kev = 0;
      i__1 = *ny;
      for (j = 1; j <= i__1; ++j)
	{
	  kev = (int) ((kev << 1) + (d__1 = y[*ny + 1 - j], Abs (d__1)));
	  /* L44: */
	}
      i__1 = *ny;
      for (j = 1; j <= i__1; ++j)
	{
	  kev <<= 1;
	  if (y[*ny + 1 - j] == -1.)
	    {
	      ++kev;
	    }
	  /* L45: */
	}
      l = kev * *ntvec;
      i__1 = *ntvec;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  tvec[i__] = rpar[l + i__] + *t;
	  /* L10: */
	}
    }
  else if (*flag__ == 9)
    {
      i__1 = *ny;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  y[i__] = u[i__];
	  /* L20: */
	}
    }
  
}

void scicos_plusblk_block (scicos_args_F2);

void scicos_plusblk_block (int *flag, int *nevprt, const double *t, double *xd,
			   double *x, int *nx, double *z, int *nz, double *tvec,
			   int *ntvec, double *rpar, int *nrpar, int *ipar,
			   int *nipar, double **inptr, int *insz, int *nin,
			   double **outptr, int *outsz, int *nout)
{
  int n=outsz[0]; 
  int k, i;
  double *y = (double *) outptr[0], *u;
  for (i = 0; i < n; i++)
    {
      y[i] = 0.0;
      for (k = 0; k < *nin; k++)
	{
	  u = (double *) inptr[k];
	  y[i] = y[i] + u[i];
	}
    }
}

void scicos_switchn_block (scicos_args_F2);

void scicos_switchn_block (int *flag, int *nevprt, const double *t,
			   double *xd, double *x, int *nx, double *z, int *nz,
			   double *tvec, int *ntvec, double *rpar, int *nrpar,
			   int *ipar, int *nipar, double **inptr, int *insz,
			   int *nin, double **outptr, int *outsz, int *nout)
{

  int k;
  double *y;
  double *u;
  int /*nev, */ ic;
  ic = ipar[0];
  if (*nin > 1)
    {
      y = (double *) outptr[0];
      u = (double *) inptr[ic];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
  else
    {
      y = (double *) outptr[ic];
      u = (double *) inptr[0];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
}

void scicos_selector_block (scicos_args_F2);

void
scicos_selector_block (int *flag, int *nevprt, const double *t, double *xd,
		       double *x, int *nx, double *z, int *nz, double *tvec,
		       int *ntvec, double *rpar, int *nrpar, int *ipar,
		       int *nipar, double **inptr, int *insz, int *nin,
		       double **outptr, int *outsz, int *nout)
{
  int k;
  double *y;
  double *u;
  int nev, ic;

  ic = (int) z[0];
  if ((*flag) < 3)
    {
      ic = -1;
      nev = *nevprt;
      while (nev >= 1)
	{
	  ic = ic + 1;
	  nev = nev / 2;
	}
    }
  if (*nin > 1)
    {
      y = (double *) outptr[0];
      u = (double *) inptr[ic];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
  else
    {
      y = (double *) outptr[ic];
      u = (double *) inptr[0];
      for (k = 0; k < outsz[0]; k++)
	*(y++) = *(u++);
    }
}


void scicos_relay_block (scicos_args_F2);

void
scicos_relay_block (int *flag, int *nevprt, const double *t, double *xd,
		    double *x, int *nx, double *z, int *nz, double *tvec,
		    int *ntvec, double *rpar, int *nrpar, int *ipar,
		    int *nipar, double **inptr, int *insz, int *nin,
		    double **outptr, int *outsz, int *nout)
{
  int k;
  double *y;
  double *u;
  int nev, ic;
  ic = (int) z[0];
  if ((*flag) < 3)
    {
      if ((*nevprt) > 0)
	{
	  ic = -1;
	  nev = *nevprt;
	  while (nev >= 1)
	    {
	      ic = ic + 1;
	      nev = nev / 2;
	    }
	}
      if ((*flag) == 2)
	{
	  z[0] = ic;
	  return;
	}
      if (*nin > 1)
	{
	  y = (double *) outptr[0];
	  u = (double *) inptr[ic];
	  for (k = 0; k < outsz[0]; k++)
	    *(y++) = *(u++);
	}
      else
	{
	  y = (double *) outptr[ic];
	  u = (double *) inptr[0];
	  for (k = 0; k < outsz[0]; k++)
	    *(y++) = *(u++);
	}
    }
}


void scicos_prod_block (scicos_args_F2);


void
scicos_prod_block (int *flag, int *nevprt, const double *t, double *xd,
		   double *x, int *nx, double *z, int *nz, double *tvec,
		   int *ntvec, double *rpar, int *nrpar, int *ipar,
		   int *nipar, double **inptr, int *insz, int *nin,
		   double **outptr, int *outsz, int *nout)
{
  int k, i, n;
  double *y;
  double *u;

  n = outsz[0];			/* insz[0]==insz[1] .. ==insz[*nin]== outsz[0] */

  y = (double *) outptr[0];

  for (i = 0; i < n; i++)
    {
      y[i] = 1.0;
      for (k = 0; k < *nin; k++)
	{
	  u = (double *) inptr[k];
	  y[i] = y[i] * u[i];
	}
    }
}

void scicos_sum_block (scicos_args_F2);

void scicos_sum_block (int *flag, int *nevprt, const double *t, double *xd,
		       double *x, int *nx, double *z, int *nz, double *tvec,
		       int *ntvec, double *rpar, int *nrpar, int *ipar,
		       int *nipar, double **inptr, int *insz, int *nin,
		       double **outptr, int *outsz, int *nout)
{
  int k, i, n;
  double *y;
  double *u;

  n = outsz[0];			/* insz[0]==insz[1] .. ==insz[*nin]== outsz[0] */

  y = (double *) outptr[0];

  for (i = 0; i < n; i++)
    {
      y[i] = 0.0;
      for (k = 0; k < *nin; k++)
	{
	  u = (double *) inptr[k];
	  y[i] = y[i] + u[i] * rpar[k];
	}
    }
}

void scicos_zcross2_block (scicos_args_F0);

void
scicos_zcross2_block (int *flag, int *nevprt, const double *t, double *xd,
		      double *x, int *nx, double *z, int *nz, double *tvec,
		      int *ntvec, double *rpar, int *nrpar, int *ipar,
		      int *nipar, double *u, int *nu, double *g, int *ng)
{

  int i, j;
  int surface_matched, exist_enabled_surface;

  exist_enabled_surface = 0;
  if ((*flag == 3) && (*nevprt < 0))
    {
      for (i = 0; i < *ntvec; i++)
	{
	  surface_matched = 1;
	  exist_enabled_surface = 0;

	  for (j = 0; j < *ng; j++)
	    {
	      if (rpar[(*ng + 1) * i + j] != 0)
		{
		  exist_enabled_surface = 1;
		  if ((rpar[(*ng + 1) * i + j] * g[j]) <= 0)
		    {
		      surface_matched = 0;
		    }
		}
	    }

	  if ((surface_matched == 1) && (exist_enabled_surface == 1))
	    tvec[i] = *t + rpar[(*ng + 1) * i + *ng];
	  else
	    tvec[i] = -1;

	}
    }
  else
    {
      if (*flag == 9)
	{
	  for (i = 0; i < *ng; i++)
	    g[i] = u[i];
	}
    }
}

void scicos_bound (scicos_args_F0)
{

  int i__1;
  int i__;

  /*     Bound y(i)=rpar(nu+i) if u(i)>rpar(i) else y(i)=0 */
  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  i__1 = *nu;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (u[i__] >= rpar[i__])
	{
	  y[i__] = rpar[*nu + i__];
	}
      else
	{
	  y[i__] = 0.;
	}
      /* L15: */
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
  F = (NspFile *) (long) z[3];
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
      z[3] = (long) F;
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
  F = (NspFile *) (long) z[2];
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
      z[2] = (long) F;
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


/*------------------------------------------------
 *     returns Absolute value of the input 
 *------------------------------------------------*/

void scicos_absblk_block (scicos_args_F0)
{
  int i;
  for (i = 0; i < *nu; ++i)
    y[i] = Abs (u[i]);
}

/*------------------------------------------------
 *     Logical and block
 *     if event input exists synchronuously, output is 1 else -1
 *------------------------------------------------*/

void scicos_andlog_block (scicos_args_F0)
{
  if (*flag__ == 1)
    y[0] = (*nevprt != 3) ? -1.00 : 1.00;
}


/*------------------------------------------------
 *     Scicos block simulator 
 *     does nothing 
 *------------------------------------------------*/

void scicos_bidon_block (scicos_args_F0)
{
}

/*------------------------------------------------
 *     input to output Gain
 *     rpar=gain matrix
 *------------------------------------------------*/

void scicos_gain_block (scicos_args_F0)
{
  int un = 1;
  nsp_calpack_dmmul (rpar, ny, u, nu, y, ny, ny, nu, &un);
}

/*------------------------------------------------
 *     Dummy state space x'=sin(t)
 *------------------------------------------------*/

void scicos_cdummy_block (scicos_args_F0)
{
  if (*flag__ == 0)
    xd[0] = sin (*t);
}

/*------------------------------------------------
 *     Dead Band, 
 *     if u(i)<0 ,y(i)=min(0,u+DB(i)/2) 
 *     else       y(i)=max(0,u-DB(i)/2) 
 *     DB(i)=rpar(i) 
 *------------------------------------------------*/

void scicos_dband_block (scicos_args_F0)
{
  int i;

  for (i = 0; i < *nu; i++)
    {
      if (u[i] < 0)
	y[i] = Min (0.00, u[i] + rpar[i] / 2.00);
      else
	y[i] = Max (0.00, u[i] - rpar[i] / 2.00);
    }
}

/*
 * cos 
 */

void scicos_cosblk_block (scicos_args_F0)
{

  int i;
  for (i = 0; i < *nu; i++)
    y[i] = cos (u[i]);
}


/* XXX : blovk de type   ScicosFi 
 * apres nipar ce sont des arguments optionnels 
 * jusqu'a ? 
 */

void scicos_constraint_block (scicos_args_Fi);

void
scicos_constraint_block (int *flag__, int *nevprt, const double *t,
			 double *res, double *xd, double *x, int *nx,
			 double *z__, int *nz, double *tvec, int *ntvec,
			 double *rpar, int *nrpar, int *ipar, int *nipar,
			 double *u, int *nu, double *y, int *ny, double *uy3,
			 int *nuy3, double *uy4, int *nuy4, double *uy5,
			 int *nuy5, double *uy6, int *nuy6, double *uy7,
			 int *nuy7, double *uy8, int *nuy8, double *uy9,
			 int *nuy9, double *uy10, int *nuy10, double *uy11,
			 int *nuy11, double *uy12, int *nuy12, double *uy13,
			 int *nuy13, double *uy14, int *nuy14, double *uy15,
			 int *nuy15, double *uy16, int *nuy16, double *uy17,
			 int *nuy17, double *uy18, int *nuy18)
{
  int i__1;
  int i__;

  --y;
  --u;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  --res;
  if (*flag__ == 0)
    {
      i__1 = *nu;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  res[i__] = xd[i__] - u[i__];
	  res[i__ + *nu] = xd[i__];
	  /* L12: */
	}
    }
  else if (*flag__ == 1)
    {
      i__1 = *ny;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  y[i__] = xd[i__ + *nu];
	  /* L14: */
	}
      /*      elseif(flag.eq.6.or.flag.eq.7) then */
      /*         do 12 i=1,nu */
      /* 12      continue */
    }
  
}

/* XXX : blovk de type   ScicosFi  */

void scicos_diffblk_block (scicos_args_Fi);

void
scicos_diffblk_block (int *flag__, int *nevprt, const double *t, double *res,
		   double *xd, double *x, int *nx, double *z__, int *nz,
		   double *tvec, int *ntvec, double *rpar, int *nrpar,
		   int *ipar, int *nipar, double *u, int *nu, double *y,
		   int *ny, double *uy3, int *nuy3, double *uy4, int *nuy4,
		   double *uy5, int *nuy5, double *uy6, int *nuy6,
		   double *uy7, int *nuy7, double *uy8, int *nuy8,
		   double *uy9, int *nuy9, double *uy10, int *nuy10,
		   double *uy11, int *nuy11, double *uy12, int *nuy12,
		   double *uy13, int *nuy13, double *uy14, int *nuy14,
		   double *uy15, int *nuy15, double *uy16, int *nuy16,
		   double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  int i;
  if (*flag__ == 0)
    {
      for (i = 0; i < *nu; ++i)
	res[i] = x[i] - u[i];
    }
  else if (*flag__ == 1)
    {
      memcpy (y, xd, (*nu) * sizeof (double));
    }
  else if (*flag__ == 6 || *flag__ == 7)
    {
      memcpy (x, u, (*nu) * sizeof (double));
    }
  
}


/* demux revisited, Copyright Enpc Jean-Philippe Chancelier */

void scicos_demux_block (scicos_args_F);

void
scicos_demux_block (int *flag__, int *nevprt, const double *t, double *xd,
		    double *x, int *nx, double *z__, int *nz, double *tvec,
		    int *ntvec, double *rpar, int *nrpar, int *ipar,
		    int *nipar, double *uy1, int *nuy1, double *uy2,
		    int *nuy2, double *uy3, int *nuy3, double *uy4, int *nuy4,
		    double *uy5, int *nuy5, double *uy6, int *nuy6,
		    double *uy7, int *nuy7, double *uy8, int *nuy8,
		    double *uy9, int *nuy9, double *uy10, int *nuy10,
		    double *uy11, int *nuy11, double *uy12, int *nuy12,
		    double *uy13, int *nuy13, double *uy14, int *nuy14,
		    double *uy15, int *nuy15, double *uy16, int *nuy16,
		    double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  int dim = ipar[0] - 1, offset = 0;
  memcpy (uy2, uy1 + offset, (*nuy2) * sizeof (double));
  offset += (*nuy2);
  memcpy (uy3, uy1 + offset, (*nuy3) * sizeof (double));
  offset += (*nuy3);
  if (dim <= 1)
    return;
  memcpy (uy4, uy1 + offset, (*nuy4) * sizeof (double));
  offset += (*nuy4);
  if (dim <= 2)
    return;
  memcpy (uy5, uy1 + offset, (*nuy5) * sizeof (double));
  offset += (*nuy5);
  if (dim <= 3)
    return;
  memcpy (uy6, uy1 + offset, (*nuy6) * sizeof (double));
  offset += (*nuy6);
  if (dim <= 4)
    return;
  memcpy (uy7, uy1 + offset, (*nuy7) * sizeof (double));
  offset += (*nuy7);
  if (dim <= 5)
    return;
  memcpy (uy8, uy1 + offset, (*nuy8) * sizeof (double));
  offset += (*nuy8);
  if (dim <= 6)
    return;
  memcpy (uy9, uy1 + offset, (*nuy9) * sizeof (double));
  
}



void scicos_mux_block (scicos_args_F);

/* mux revisited, Copyright Enpc Jean-Philippe Chancelier */

void
scicos_mux_block (int *flag__, int *nevprt, const double *t, double *xd,
		  double *x, int *nx, double *z__, int *nz, double *tvec,
		  int *ntvec, double *rpar, int *nrpar, int *ipar, int *nipar,
		  double *uy1, int *nuy1, double *uy2, int *nuy2, double *uy3,
		  int *nuy3, double *uy4, int *nuy4, double *uy5, int *nuy5,
		  double *uy6, int *nuy6, double *uy7, int *nuy7, double *uy8,
		  int *nuy8, double *uy9, int *nuy9, double *uy10, int *nuy10,
		  double *uy11, int *nuy11, double *uy12, int *nuy12,
		  double *uy13, int *nuy13, double *uy14, int *nuy14,
		  double *uy15, int *nuy15, double *uy16, int *nuy16,
		  double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  double *res = NULL;
  int dim = ipar[0] - 1, offset = 0;
  switch (dim)
    {
    case 1:
      res = uy3;
      break;
    case 2:
      res = uy4;
      break;
    case 3:
      res = uy5;
      break;
    case 4:
      res = uy6;
      break;
    case 5:
      res = uy7;
      break;
    case 6:
      res = uy8;
      break;
    case 7:
      res = uy9;
      break;
    }
  memcpy (res + offset, uy1, (*nuy2) * sizeof (double));
  offset += (*nuy2);
  memcpy (res + offset, uy2, (*nuy3) * sizeof (double));
  offset += (*nuy3);
  if (dim <= 1)
    return;
  memcpy (res + offset, uy3, (*nuy4) * sizeof (double));
  offset += (*nuy4);
  if (dim <= 2)
    return;
  memcpy (res + offset, uy4, (*nuy5) * sizeof (double));
  offset += (*nuy5);
  if (dim <= 3)
    return;
  memcpy (res + offset, uy5, (*nuy6) * sizeof (double));
  offset += (*nuy6);
  if (dim <= 4)
    return;
  memcpy (res + offset, uy6, (*nuy7) * sizeof (double));
  offset += (*nuy7);
  if (dim <= 5)
    return;
  memcpy (res + offset, uy7, (*nuy8) * sizeof (double));
  offset += (*nuy8);
  if (dim <= 6)
    return;
  memcpy (res + offset, uy8, (*nuy9) * sizeof (double));
  
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
  F = (FILE *) (long) z[2];
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
      z[2] = (long) F;
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
  F = (NspFile *) (long) z[2];
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
      z[2] = (long) F;
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
  F = (NspFile *) (long) z[3];
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
      z[3] = (long) F;

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

  F = (NspFile *) (long) z[3];

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
      z[3] = (long) F;
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

/* XXX    output a vector of constants out(i)=rpar(i) 
 */

void scicos_cstblk_block (scicos_args_F);

void
scicos_cstblk_block (int *flag__, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z__, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar, int *nipar,
		     double *y, int *ny, double *uy2, int *nuy2, double *uy3,
		     int *nuy3, double *uy4, int *nuy4, double *uy5, int *nuy5,
		     double *uy6, int *nuy6, double *uy7, int *nuy7, double *uy8,
		     int *nuy8, double *uy9, int *nuy9, double *uy10, int *nuy10,
		     double *uy11, int *nuy11, double *uy12, int *nuy12,
		     double *uy13, int *nuy13, double *uy14, int *nuy14,
		     double *uy15, int *nuy15, double *uy16, int *nuy16,
		     double *uy17, int *nuy17, double *uy18, int *nuy18)
{
  int c__1 = 1;
  C2F (dcopy) (nrpar, rpar, &c__1, y, &c__1);
  
}


void scicos_delayv_block (scicos_args_F);

void
scicos_delayv_block (int *flag__, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z__, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar,
		     int *nipar, double *u1, int *nu1, double *u2, int *nu2,
		     double *y, int *ny, double *uy4, int *nuy4, double *uy5,
		     int *nuy5, double *uy6, int *nuy6, double *uy7,
		     int *nuy7, double *uy8, int *nuy8, double *uy9,
		     int *nuy9, double *uy10, int *nuy10, double *uy11,
		     int *nuy11, double *uy12, int *nuy12, double *uy13,
		     int *nuy13, double *uy14, int *nuy14, double *uy15,
		     int *nuy15, double *uy16, int *nuy16, double *uy17,
		     int *nuy17, double *uy18, int *nuy18)
{

  int i__1, i__2;
  double dtat, a;
  int i__, j, k, ii, in;
  double u2r;

  /*     rpar(1)=dt */
  /*     delayv=u(nin) */

  --y;
  --u2;
  --u1;
  --ipar;
  --rpar;
  --tvec;
  --z__;
  --x;
  --xd;
  j = (*nz - 1) / *nu1;
  if (*flag__ == 3)
    {
      tvec[1] = *t + rpar[1];
      k = (int) (u2[1] / rpar[1]);
      if (k > j - 3)
	{
	  tvec[2] = *t;
	}
      if (k < 1)
	{
	  tvec[2] = *t;
	}
    }

  /*     .   shift buffer */
  if (*flag__ == 2)
    {
      i__1 = j;
      for (i__ = 1; i__ <= i__1; ++i__)
	{
	  z__[i__] = z__[i__ + 1];
	  /* L10: */
	}
      i__1 = *nu1 - 1;
      for (in = 1; in <= i__1; ++in)
	{
	  i__2 = (in + 1) * j;
	  for (ii = in * j + 1; ii <= i__2; ++ii)
	    {
	      z__[ii] = z__[ii + 1];
	      /* L35: */
	    }
	  /* L30: */
	}
      z__[*nz] = *t;
      i__1 = *nu1;
      for (in = 1; in <= i__1; ++in)
	{
	  z__[j * in] = u1[in];
	  /* L20: */
	}
    }
  if (*flag__ == 1 || *flag__ == 6)
    {
      dtat = *t - z__[*nz];
      i__1 = *nu1;
      for (in = 1; in <= i__1; ++in)
	{
	  /*     extrapolate to find values at delta.t */
	  if (u2[1] <= dtat)
	    {
	      /*     initialisation start */
	      if (dtat < rpar[1] / 100.)
		{
		  a = u2[1] / (rpar[1] + dtat);
		  /*     delete negative delay */
		  if (a <= 0.)
		    {
		      a = 0.;
		    }
		  y[in] = (1 - a) * z__[j * in] + a * z__[j * in - 1];
		}
	      else
		{
		  a = u2[1] / dtat;
		  /*     delete negative delay */
		  if (a <= 0.)
		    {
		      a = 0.;
		    }
		  y[in] = (1 - a) * u1[in] + a * z__[j * in];
		}
	    }
	  else
	    {
	      u2r = u2[1] - dtat;
	      k = (int) (u2r / rpar[1]);
	      /*     limitation of size buffer */
	      if (k > j - 3)
		{
		  k = j - 3;
		  a = 1.;
		}
	      else
		{
		  a = (u2r - k * rpar[1]) / rpar[1];
		}
	      /*     interpolate to find values at t-delay */
	      y[in] = (1 - a) * z__[j * in - k] + a * z__[j * in - k - 1];
	    }
	  /* L8: */
	}
    }
  
}



void scicos_fscope_block (scicos_args_F);

void
scicos_fscope_block (int *flag__, int *nevprt, const double *t, double *xd,
		     double *x, int *nx, double *z__, int *nz, double *tvec,
		     int *ntvec, double *rpar, int *nrpar, int *ipar,
		     int *nipar, double *uy1, int *nuy1, double *uy2,
		     int *nuy2, double *uy3, int *nuy3, double *uy4,
		     int *nuy4, double *uy5, int *nuy5, double *uy6,
		     int *nuy6, double *uy7, int *nuy7, double *uy8,
		     int *nuy8, double *uy9, int *nuy9, double *uy10,
		     int *nuy10, double *uy11, int *nuy11, double *uy12,
		     int *nuy12, double *uy13, int *nuy13, double *uy14,
		     int *nuy14, double *uy15, int *nuy15, double *uy16,
		     int *nuy16, double *uy17, int *nuy17, double *uy18,
		     int *nuy18)
{
  
}

/*     if-then-else block 
 *     if event input exits from then or else clock ouputs based 
 *     on the sign of the unique input (if input>0 then  else )
 */


void scicos_eselect_block (scicos_args_Fm1);

void
scicos_eselect_block (int *flag__, int *nevprt, int *ntvec, double *rpar,
		      int *nrpar, int *ipar, int *nipar, double *u, int *nu)
{
  int i__1, i__2;
  int iu;

  --u;
  --ipar;
  --rpar;
  /* Computing MAX */
  /* Computing MIN */
  i__2 = (int) u[1];
  i__1 = Min (i__2, ipar[1]);
  iu = Max (i__1, 1);
  if (*flag__ == 3)
    {
      *ntvec = iu;
    }
  
}

/* 
 * if-then-else block
 * if event input exits from then or else clock ouputs based 
 * on the sign of the unique input (if input>0 then  else )
 */

void scicos_ifthel_block (scicos_args_Fm1);

void
scicos_ifthel_block (int *flag__, int *nevprt, int *ntvec, double *rpar,
		     int *nrpar, int *ipar, int *nipar, double *u, int *nu)
{
  if (*flag__ == 3)
    {
      *ntvec = (u[0] <= 0.) ? 2 : 1;
    }
  
}


