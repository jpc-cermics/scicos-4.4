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
 */

#include "blocks.h"

/* event delay,  delay=rpar(1) */

void scicos_evtdly_block (scicos_args_F0)
{
  if (*flag__ == 3)
    {
      tvec[0] = *t + rpar[0];
    }
}

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
  int m, n;
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
	  scicos_set_block_error(-2);
	  /*iflag = -1;*/
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
  int surface_matched, exist_enabled_surface = 0;
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
  int dim = ipar[0]-1, offset = 0;
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
  memcpy (res + offset, uy1, (*nuy1) * sizeof (double));
  offset += (*nuy1);
  memcpy (res + offset, uy2, (*nuy2) * sizeof (double));
  offset += (*nuy2);
  if (dim <= 1)
    return;
  memcpy (res + offset, uy3, (*nuy3) * sizeof (double));
  offset += (*nuy3);
  if (dim <= 2)
    return;
  memcpy (res + offset, uy4, (*nuy4) * sizeof (double));
  offset += (*nuy4);
  if (dim <= 3)
    return;
  memcpy (res + offset, uy5, (*nuy5) * sizeof (double));
  offset += (*nuy5);
  if (dim <= 4)
    return;
  memcpy (res + offset, uy6, (*nuy6) * sizeof (double));
  offset += (*nuy6);
  if (dim <= 5)
    return;
  memcpy (res + offset, uy7, (*nuy7) * sizeof (double));
  offset += (*nuy7);
  if (dim <= 6)
    return;
  memcpy (res + offset, uy8, (*nuy9) * sizeof (double));
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






